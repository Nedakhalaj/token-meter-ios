# TokenMeter

iOS app that shows how much of your AI usage quota is left — one card per connected
account, each usage window as a colored bar, plus a home-screen widget. SwiftUI, **no
third-party dependencies**, everything on-device: no backend, no account system of its own.

It's the iOS port of [ai-usage-android](https://github.com/ateymoori/ai-usage-android).
`walkthrough.html` in the repo root is the Android app's visual walkthrough and the
reference for what the iOS screens should become.

---

## How to work with me

**Teach, don't autocomplete.** This is a learning project — I'm studying mobile app
development and I want to write the code myself.

- Give code **one file at a time**, in order, with a short explanation of any new
  concept. No essays unless I ask.
- I write it, run it, and report back before we move to the next step.
- Don't silently build three files ahead of where I am.
- When something breaks, walk me through *why* — the debugging is the point.
- Widgets, API integration, OAuth, and App Store submission are all new to me.
- The goal is a portfolio piece and interview material for an internship or first job,
  so prefer the explanation an interviewer would ask about over the quickest fix.

---

## Commands

Build, test, and run all work headlessly — see [Environment](#environment) for why that matters.

```bash
# Pick a simulator (deployment target is iOS 26.5, so 18.x sims will NOT run this app)
xcrun simctl list devices available | sed -n '/-- iOS 2[67]/,/^--/p'
UDID=<paste one>

# Build
xcodebuild build -project TokenMeter.xcodeproj -scheme TokenMeter \
  -destination "platform=iOS Simulator,id=$UDID"

# Test (Swift Testing; currently 2 tests in TokenMeterTests)
xcodebuild test -project TokenMeter.xcodeproj -scheme TokenMeter \
  -destination "platform=iOS Simulator,id=$UDID"

# Run on the simulator
xcrun simctl boot "$UDID"
xcrun simctl install "$UDID" <DerivedData>/Build/Products/Debug-iphonesimulator/TokenMeter.app
xcrun simctl launch "$UDID" nedakhalaj.TokenMeter
xcrun simctl io "$UDID" screenshot shot.png     # no Simulator window on this machine
```

### UI testing with Maestro

Maestro 2.10 is installed at `~/.maestro/bin/maestro` and its MCP server is registered
globally, so UI flows can be driven directly.

```bash
maestro --udid "$UDID" hierarchy          # dump selectors for the current screen
maestro --udid "$UDID" test flow.yaml     # run a flow
```

- SwiftUI exposes **SF Symbol names as accessibility ids** — the toolbar buttons are
  addressable as `id: "gearshape"` and `id: "plus"` with no `.accessibilityIdentifier` needed.
- Swipe syntax is `start: "50%, 12%"` / `end: "50%, 92%"` — not `from:`/`to:`.
- Flow screenshots land in `~/.maestro/tests/<timestamp>/<flow>/`, not the working directory.
- An `assertVisible` on a label proves the label is on screen, not that the behavior
  happened. Screenshot and look when the assertion is weak.

### Key identifiers

| | |
|---|---|
| Bundle id | `nedakhalaj.TokenMeter` (widget: `.TokenMeterWidget`) |
| App Group | `group.nedakhalaj.TokenMeter` |
| Deployment target | iOS 26.5 |
| Xcode | 27 |

---

## Architecture

MVVM plus a service layer. This is a read-only client over several remote APIs with an
on-disk cache the widget also reads, so the networking/auth/caching code is larger than the UI.

**Dependency direction — one way only:**

```
View → ViewModel → AccountStore → UsageService → network
                                → KeychainHelper / AccountFileStore
```

- **View** — no `URLSession`, no provider URLs, no business rules. Renders state, sends
  intent up. Takes its data as a parameter so it can be previewed in every state.
- **ViewModel** (`DashboardViewModel`) — owns per-screen state, dies with the screen.
  **Must not `import SwiftUI`** — that import is the leak detector.
- **AccountStore** — `@Observable @MainActor`, owns `[Account]` and `[UUID: LoadState]`,
  lives for the whole app. Coordinates services and persistence. (This is the
  "repository" layer; it's named `AccountStore`.)
- **Service** — speaks one provider's wire format, returns domain models. Never knows
  about the UI.
- **Models** — `import Foundation` only. No `Color`, no `Image`. Provider accent colors
  live in `Theme.swift`, not in `Provider`.

### The protocol that holds it together

```swift
protocol UsageService {
    var provider: Provider { get }
    func fetchUsage(for account: Account) async throws -> [UsageWindow]
}
```

`AccountStore` holds `[Provider: UsageService]` and contains **no `switch` or `if` on
provider**. Adding a provider = add an enum case, add a service file, register it in the
services table in `ContentView.swift`. Nothing above the service layer changes.
`MockUsageService` makes previews and unit tests work without the network.

### Shared vs wire models

`Account` / `UsageWindow` / `Provider` are the app's shared model. Each provider has its
own `Decodable` DTOs for its unique JSON (`OpenRouterModels.swift`, `ClaudeModels.swift`,
`GoogleDriveModels.swift`), mapped into the shared model **inside its service**.

### Widget constraint

The widget **never fetches**. The app fetches and writes `accounts.json` into the App
Group container; the widget's `TimelineProvider` only reads it, and `AccountStore.persist()`
calls `WidgetCenter.reloadAllTimelines()`.

There is no `Shared/` folder. Sharing is done with **Xcode target membership exceptions**
in `project.pbxproj` — `models/Models.swift`, `models/LoadState.swift`, and
`services/AccountFileStore.swift` are compiled into the widget target too. A new file the
widget needs must be added to that exception list.

### iOS reality vs the Android original

iOS has no equivalent of Android's foreground service, so there is no guaranteed
15-minute refresh. The app fetches on launch and on pull-to-refresh. The UI should show
staleness honestly ("updated 2h ago") rather than pretending the numbers are live —
**not built yet**, and neither is `BGAppRefreshTask`.

---

## Layout

Folders group by type, not by feature. Xcode uses **file-system synchronized groups**, so
a new `.swift` file in these folders is picked up automatically — no `project.pbxproj`
editing, unless it also needs widget membership (see above).

```
CLAUDE.md, README.md, walkthrough.html   # repo root
TokenMeter/                              # app target — SOURCE ONLY (see gotcha below)
├── TokenMeterApp.swift, ContentView.swift   # entry point + the services table
├── models/      Models.swift (Account, UsageWindow, Provider), LoadState.swift,
│                OpenRouterModels.swift, ClaudeModels.swift, GoogleDriveModels.swift
├── services/    UsageService.swift (the protocol), AccountStore.swift,
│                OpenRouterService.swift, ClaudeService.swift, MockUsageService.swift,
│                KeychainHelper.swift, AccountFileStore.swift,
│                GoogleAuthService.swift, PKCE.swift
├── viewModels/  DashboardViewModel.swift
└── views/       DashboardView, AccountCard, UsageWindowRow, AddAccountView,
                 ApiKeyView, ClaudeLoginView, ClaudeLoginScreen, SettingView, Theme
TokenMeterWidget/                        # WidgetKit extension
TokenMeterTests/                         # Swift Testing + StubUsageService
```

Split a file into per-type files once it gets long — not before.

---

## Providers

| Provider | Sign-in | Status |
|---|---|---|
| OpenRouter | paste an API key | working |
| Claude | in-app `WKWebView` login, captures the `sessionKey` cookie | working |
| Google Drive | OAuth + PKCE via `ASWebAuthenticationSession` | **in progress** |
| Codex (OpenAI) | OAuth device code | not started — wired to `MockUsageService` |

Both live endpoints are unofficial. Read only the signed-in user's own usage, and degrade
to an error state rather than crashing when a response shape changes.

Credentials go in the **Keychain, keyed by `account.id.uuidString`** — never in
`accounts.json`, never in `UserDefaults`.

### Google Drive — where it stands

Done: `PKCE.swift`, `GoogleAuthService.authorize()` (returns `code` + `verifier`),
`DriveAboutResponse`, the callback URL scheme in `Info.plist`.

Not done: the token exchange (`code` + `verifier` → access/refresh token), storing the
refresh token, `GoogleDriveService: UsageService` reading
`drive/v3/about?fields=storageQuota,user`, registering it in the services table, and a
connect path through `DashboardViewModel`. `AddAccountView` currently just `print`s the code.

---

## Environment

- **There is no `Simulator.app` on this machine.** It was deleted from the Xcode install,
  so there is no simulator window to watch. Everything works headlessly via `simctl` and
  Maestro; use `simctl io <udid> screenshot` or `recordVideo` to see the screen.
- **Deployment target 26.5** means iOS 18.x simulators can't run the app at all.
- **`TokenMeter/` is a synchronized group, so every file in it is copied into the built
  `.app`.** `CLAUDE.md` used to live there and was shipping inside the app bundle. Keep
  docs and notes in the repo root.

---

## Conventions

- Swift Testing (`@Test` / `#expect`), not XCTest.
- One feature per branch (`feature_<name>`), merged to `main` by PR — see `git log`.
- No third-party dependencies. If something seems to need one, say so and we'll discuss.
- Keep `README.md`'s status table honest when a provider lands.

## Known issues worth fixing

- `reconnect` always presents `ApiKeyView`, which is worded for OpenRouter — reconnecting
  a Claude account is broken (`DashboardView.swift`).
- Codex appears in the Add-account list backed by `MockUsageService`, so it shows random
  fake numbers. Build it or hide the case before any App Store submission.
- `AccountFileStore` force-unwraps `containerURL(forSecurityApplicationGroupIdentifier:)`.
- `KeychainHelper` discards every `OSStatus` and sets no `kSecAttrAccessible`.
- The widget hand-duplicates the bar-color rule instead of sharing `Theme.swift`.
