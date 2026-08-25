# Token Meter

An iOS app that shows how much of your AI usage quota you've used — across **Claude** and **OpenRouter** — as simple progress bars on a dashboard and a home-screen widget.

Everything runs on-device. There's no backend and no account system of its own: you connect your own providers, and their credentials are stored only on your phone.

> Built in SwiftUI as the iOS version of an existing Android app ([ai-usage-android](https://github.com/ateymoori/ai-usage-android)). This is a learning project — the goal was to build a real, non-trivial app end to end: real API integration, secure storage, persistence, and a widget.

---

## What it does

- **Dashboard** — one card per connected account, showing each usage window as a colored bar (green under 50%, amber 50–80%, red over 80%) with a reset countdown.
- **Add accounts** — connect a provider, with a different sign-in flow per provider (see below). Multiple accounts of the same provider are supported.
- **Manage** — refresh, rename, remove, and reconnect an account from a per-card menu.
- **Home-screen widget** — a WidgetKit widget that shows your usage bars without opening the app.
- **Settings** — light / dark / system theme, and an about section.

## Providers

| Provider | Sign-in | Status |
|---|---|---|
| **OpenRouter** | Paste an API key | Working |
| **Claude** | In-app web sign-in (WKWebView), captures the session cookie | Working |
| Codex (OpenAI) | OAuth device code | Planned |
| Google Drive | OAuth device code | Planned |

Both live endpoints are unofficial — the app reads only the user's own usage and degrades to an error state rather than crashing when a response changes.

## Architecture

Clean, one-directional layering:

```
Views (SwiftUI)        DashboardView, AccountCard, AddAccountView, SettingView, widget view
      │  talk to
DashboardViewModel     per-screen coordinator; owns UI state, forwards actions
      │  talk to
AccountStore           @Observable @MainActor — the single source of truth (accounts + fetch state)
      │  uses
Services               UsageService protocol → OpenRouterService, ClaudeService, MockUsageService
```

Some deliberate choices:

- **Protocol-based providers.** Every provider is a `UsageService` that returns the same `[UsageWindow]`. Adding a provider is a new service plus one line in the services table — nothing above the service layer changes.
- **Shared model vs wire model.** `Account` / `UsageWindow` are the app's shared model; each provider has its own `Decodable` DTOs for its unique JSON, mapped into the shared model inside its service.
- **Secure storage.** Credentials (API key, session cookie) are kept in the **Keychain**, keyed by the account's id.
- **Persistence.** Accounts are saved to disk with `Codable`, in an **App Group** container so the widget can read the same data.
- **Error handling.** Fetches record a per-account `LoadState` (loading / loaded / failed); a 401 maps to an "invalid key" message with a reconnect flow.

## Tech

Swift · SwiftUI · URLSession · Codable · Keychain · WKWebView · WidgetKit · App Groups · MVVM

## Requirements

- Xcode 26+
- iOS 26.5+ (deployment target)

## Running

```bash
git clone https://github.com/Nedakhalaj/token-meter-ios.git
cd token-meter-ios
open TokenMeter.xcodeproj
```

Then select the **TokenMeter** scheme and run on a simulator. To connect a provider you'll need your own account:

- **OpenRouter** — create a key at [openrouter.ai/keys](https://openrouter.ai/keys) and paste it in.
- **Claude** — sign in to claude.ai inside the app (email / password).

The home-screen widget uses an App Group; the project is already configured for `group.nedakhalaj.TokenMeter`.

## Project structure

```
TokenMeter/
├── models/            Account, UsageWindow, Provider, LoadState, per-provider DTOs
├── services/          UsageService protocol + providers, AccountStore, Keychain & file storage
├── viewModels/        DashboardViewModel
├── views/             SwiftUI screens, theme, components
└── ...
TokenMeterWidget/      WidgetKit extension (timeline provider + widget view)
```

## Status & roadmap

Working: OpenRouter, Claude, persistence, error handling + reconnect, settings, home-screen widget.

Planned: Codex and Google Drive providers, and App Store release prep.

## Note

Personal learning project. The provider endpoints are used only to read the signed-in user's own usage; nothing leaves the device except the requests to those providers.
