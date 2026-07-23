## about the project
i want to create the ios application based on this 
https://github.com/ateymoori/ai-usage-android.git
as you can see it is an android application, there is a file is called walkthrough.html in the root directory of the project, this file is a visual walkthrough of the application, i want to create the same walkthrough for ios application.
this project is new to me , and the purpose of doing this project is educational and evantually i want to upload it in app store to both learn the whole cycle and helping my cv to be more attractive to find a job.

## new to me 
widget, API calling and uploading to the app store is a new journey to me, so i want to teach me like a teacher and help me to code not doing the project by ypurself automatically.

## about me 
i am studing mobile application development in fulkuniversitet onlineand i want to learn how to create ios application and upload it to app store.
i want to encounter and solve challenges that may occure to me during the reall application, and learn from them like security part, performance optimization, and user experience.

## my goal
i have to find an internship or a job in this field, then i have to learn about different aspect of the project to both passing the interview and having a strong portfolio and about real coding.

---

# Target architecture (reference)

MVVM + a service layer. This app is a read-only client over four remote APIs
(Claude, Codex, OpenRouter, Google Drive) with an on-disk cache that a WidgetKit
extension also reads. The networking/auth/caching code will be larger than the UI.

## Folder structure

```
TokenMeter/                          # app target
├── App/
│   └── TokenMeterApp.swift
├── Features/                        # group by feature, not by type
│   ├── Dashboard/
│   │   ├── DashboardViewModel.swift
│   │   ├── DashboardView.swift
│   │   ├── AccountCard.swift
│   │   └── UsageWindowRow.swift
│   ├── AddAccount/
│   └── Settings/
├── Services/
│   ├── UsageService.swift           # protocol — the contract
│   ├── MockUsageService.swift       # previews + tests
│   ├── OpenRouterService.swift      # one file per provider
│   ├── ClaudeService.swift
│   ├── CodexService.swift
│   └── DTO/                         # Codable wire shapes, never leave Services/
├── Persistence/
│   ├── AccountRepository.swift      # source of truth for [Account]
│   └── KeychainStore.swift          # secrets only
└── DesignSystem/
    └── Theme.swift

Shared/                              # membership in BOTH app + widget targets
├── Models.swift                     # Account, UsageWindow, Provider
└── UsageCache.swift                 # JSON in the App Group container

TokenMeterWidget/                    # widget extension target
├── TokenMeterWidget.swift
├── UsageProvider.swift              # TimelineProvider
└── WidgetViews.swift

TokenMeterTests/
```

Split `Models.swift` into per-type files only once it gets long. Same for
`Theme.swift`.

## Dependency direction — one way only

```
View → ViewModel → Repository → Service  → network
                              → Keychain / UsageCache
```

- **View** — no `URLSession`, no provider URLs, no business rules. Renders state,
  sends user intent up. Takes its data as a parameter so it can be previewed in
  every state (empty, loaded, error).
- **ViewModel** — owns screen state (loading, alerts, sort order). Dies with the
  screen. **Must not `import SwiftUI`** — that import is the leak detector.
- **Repository** — owns `[Account]`, lives for the whole app, injected once.
  Coordinates services + persistence.
- **Service** — speaks one provider's wire format, returns domain models.
  Never knows about the UI.
- **Models** — `import Foundation` only. No `Color`, no `Image`. Provider accent
  colors live in `Theme.swift`, not in `Provider`.

## The protocol that holds it together

```swift
protocol UsageService {
    var provider: Provider { get }
    func fetchUsage(for account: Account) async throws -> [UsageWindow]
}
```

Four conformances. The repository holds `[Provider: UsageService]` and contains
**no `switch` or `if` on provider**. Adding a fifth provider = add an enum case,
add a service file, register it. Nothing else changes. `MockUsageService` makes
previews and unit tests possible without the network.

## Widget constraint

The widget **never fetches**. The app fetches and writes to `UsageCache` in the
shared App Group container; the widget's `TimelineProvider` only reads it. This
is why `Models.swift` and `UsageCache.swift` sit in `Shared/` with membership in
both targets.

## iOS reality vs the Android original

iOS has no equivalent of Android's foreground service, so there is no guaranteed
15-minute refresh. `BGAppRefreshTask` runs when iOS decides. The app therefore
fetches on launch/foreground and on widget timeline refresh, and the UI must show
staleness honestly ("updated 2h ago") rather than pretending the numbers are live.

## Build order

1. Dashboard with fake data ✅
2. Repository + ViewModel + `UsageService` protocol + mock
3. OpenRouter (simplest: paste an API key, one plain request)
4. Persistence — Keychain for keys, JSON cache on disk
5. Settings + the `···` menu (rename, remove, refresh, interval)
6. Codex device code, then Claude `WKWebView` login
7. Widget — last, it only reads what already exists on disk

## How to work with me on this

Teach, don't autocomplete. Give code in order, one file at a time, with short
explanations of new concepts — not full essays unless asked. I write the code and
report back before moving on.
