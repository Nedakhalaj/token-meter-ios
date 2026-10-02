# Token Meter

An iOS app that shows how much of your AI usage quota you've used, across **Claude**, **Codex**, **OpenRouter** and **Google Drive**, as simple progress bars on a dashboard and a home-screen widget.

Everything runs on-device. There's no backend and no account system of its own: you connect your own providers, and their credentials are stored only on your phone.

> Built in SwiftUI as the iOS version of an existing Android app ([ai-usage-android](https://github.com/ateymoori/ai-usage-android)). This is a learning project. The goal was to build a real, non-trivial app end to end: real API integration, OAuth, secure storage, persistence, and a widget.

---

## What it does

- **Dashboard**: one card per connected account, showing each usage window as a colored bar (green under 50%, amber 50-80%, red over 80%), a reset countdown, and when the numbers were last updated.
- **Fresh on open**: usage is fetched when the app opens or comes back to the foreground, and on pull-to-refresh.
- **Add accounts**: connect a provider, with a different sign-in flow per provider (see below). Multiple accounts of the same provider are supported.
- **Manage**: refresh, rename, remove (with confirmation), and reconnect an account from a per-card menu.
- **Clear errors**: a sign-in problem offers **Reconnect**; a network or server problem offers **Retry**.
- **Home-screen widget**: a WidgetKit widget that shows your usage bars without opening the app.
- **Settings**: light / dark / system theme, and an about section.

## Providers

| Provider | Sign-in | Reads |
|---|---|---|
| **OpenRouter** | Paste an API key | Credit balance |
| **Claude** | In-app web sign-in (WKWebView), captures the session cookie | 5-hour and weekly limits |
| **Google Drive** | OAuth 2.0 with PKCE (ASWebAuthenticationSession) | Storage quota |
| **Codex (OpenAI)** | OAuth device code | 5-hour and weekly limits |

The Claude and Codex endpoints are unofficial. The app reads only the user's own usage and degrades to an error state rather than crashing when a response changes.

## Architecture

Clean, one-directional layering:

```
Views (SwiftUI)        DashboardView, AccountCard, AddAccountView, SettingView, widget view
      │  talk to
DashboardViewModel     per-screen coordinator; owns UI state, forwards actions
      │  talk to
AccountStore           @Observable @MainActor: the single source of truth (accounts + fetch state)
      │  uses
Services               UsageService protocol → OpenRouterService, ClaudeService,
                       GoogleDriveService, CodexService
```

Some deliberate choices:

- **Protocol-based providers.** Every provider is a `UsageService` that returns the same `[UsageWindow]`. Adding a provider is a new service plus one line in the services table. Nothing above the service layer changes.
- **Shared model vs wire model.** `Account` and `UsageWindow` are the app's shared model. Each provider has its own `Decodable` DTOs for its unique JSON, mapped into the shared model inside its service.
- **Secure storage.** Credentials (API keys, session cookies, OAuth refresh tokens) are kept in the **Keychain**, keyed by the account's id. Codex replaces its refresh token on every refresh, so its service saves the new one immediately.
- **Persistence.** Accounts are saved to disk with `Codable`, in an **App Group** container so the widget can read the same data. New fields are optional, so data saved by older versions keeps loading.
- **Typed errors.** Each account has a `LoadState` (loading, loaded, failed). A failure is a `LoadFailure` type rather than a text message, so the card can tell a rejected sign-in (Reconnect) from a network problem (Retry).
- **Design.** Content matches the Android app exactly: palette, cards and provider logos. Controls use iOS's native Liquid Glass.

## Tech

Swift, SwiftUI, URLSession, Codable, Keychain, WKWebView, ASWebAuthenticationSession, CryptoKit, WidgetKit, App Groups, Swift Testing, MVVM

## Requirements

- Built with Xcode 27
- iOS 26.5+ (deployment target)

## Running

```bash
git clone https://github.com/Nedakhalaj/token-meter-ios.git
cd token-meter-ios
open TokenMeter.xcodeproj
```

Then select the **TokenMeter** scheme and run on a simulator. To connect a provider you'll need your own account:

- **OpenRouter**: create a key at [openrouter.ai/keys](https://openrouter.ai/keys) and paste it in.
- **Claude**: sign in to claude.ai inside the app.
- **Google Drive**: sign in with your Google account. Accounts that use a passkey are easiest to test on a real iPhone.
- **Codex**: the app shows a code; enter it at auth.openai.com/codex/device. First turn on **device code sign-in** in ChatGPT under Settings → Security.

The home-screen widget uses an App Group; the project is already configured for `group.nedakhalaj.TokenMeter`.

## Tests

Run with **⌘U** in Xcode. The tests cover the account store (successful and failed refreshes, Retry vs Reconnect, the last-updated time) and loading data saved by older app versions.

## Project structure

```
TokenMeter/
├── models/            Account, UsageWindow, Provider, LoadState, per-provider DTOs
├── services/          UsageService protocol + providers, AccountStore, Keychain & file storage
├── viewModels/        DashboardViewModel
├── views/             SwiftUI screens, theme, components
└── Assets.xcassets    App icon and provider logos
TokenMeterWidget/      WidgetKit extension (timeline provider + widget view)
TokenMeterTests/       Swift Testing tests
```

## Status & roadmap

Working: all four providers, persistence, typed error handling with Retry and Reconnect, last-updated labels, Android-matched design, settings, home-screen widget, tests.

Planned: App Store release.

## Note

Personal learning project. The provider endpoints are used only to read the signed-in user's own usage; nothing leaves the device except the requests to those providers.
