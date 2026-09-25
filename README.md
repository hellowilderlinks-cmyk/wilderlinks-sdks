# WilderLinks SDKs

WilderLinks gives your product one link system for:

- direct deep linking
- token-based deferred matching after install when the app receives a token
- Universal Links and Android App Links
- QR campaigns
- analytics-ready routing
- server-side link creation

This folder contains the official SDKs for different client stacks.

## Pick your SDK

| SDK | Best for |
| --- | --- |
| `flutter/` | Flutter apps |
| `react-native/` | React Native apps |
| `android/` | Native Android apps |
| `ios/` | Native iOS apps |
| `web/` | Trusted Node.js backends; limited browser token helper |
| `unity/` | Unity games and interactive apps |
| `cli/` | Terminal workflows and CI automation |

## Product links

- Website: `https://wilderlinks.space`
- Dashboard: `https://wilderlinks.space`
- Developer docs: `https://wilderlinks.space/docs`
- Contact: `https://wilderlinks.space/contact`
- SDK repository: `https://github.com/hellowilderlinks-cmyk/wilderlinks-sdks`

## Shared API base

Most SDK examples in this repo use:

`https://api.wilderlinks.space`

That is the hosted WilderLinks API base used by the examples. If your team runs a
different environment, replace it with your own API origin.

## Shared link-domain example

Examples use:

`https://your-workspace.wilderlinks.space`

Replace that with the default domain shown in your workspace or with your own
verified custom domain when you configure your app. If you add a custom domain,
its DNS CNAME should point to `go.wilderlinks.space`.

## Before production SDK testing

Register or sign in at `https://wilderlinks.space`, then create your
workspace and app profile.

- Android apps need the package name and SHA-256 signing certificate fingerprint
  saved in the dashboard, plus an `android:autoVerify="true"` App Links intent
  filter in the app.
- iOS apps need the bundle ID, Apple Team ID, and App Store URL saved in the
  dashboard, plus the Associated Domains entitlement in Xcode.
- Custom domains are optional. If you use one, add it in the dashboard and
  follow the generated CNAME/TXT DNS records before using it in SDK config.

## Deferred deep link handoff by platform

| Platform | Deferred-token handoff |
| --- | --- |
| Native Android | Built in: call `Wilderlinks.checkInstallReferrer(context)` |
| Flutter | Add a Play Install Referrer MethodChannel or plugin, then call `matchDeferredToken` |
| React Native | Add a native Play Install Referrer module or plugin, then call `matchDeferredToken` |
| Unity | Add an Android native plugin/bridge, then call `MatchDeferredToken` |
| iOS | No automatic App Store token recovery; use gesture-dependent pasteboard or a token supplied by your own attribution flow |
| Web | Cannot read Play Install Referrer; web only exchanges explicit tokens or handles browser fallback |

## What the SDKs handle

Depending on the platform, the SDKs can help with:

- resolving installed-app deep links
- matching deferred installs
- creating short links and smart links
- working with app-specific path prefixes
- exchanging install attribution tokens supplied by the app integration
- sending custom events
- generating QR-ready links from trusted runtimes

Each SDK README explains the supported flows, install steps, and production
integration pattern for that platform.

Organization API keys are secrets. Never embed them in Flutter, React Native,
native mobile, Unity client builds, or browser JavaScript. Create links, fetch
QR codes, and submit API-key custom events from a trusted server or the dashboard.
`POST /api/v1/test/resolve` is a read-only configuration inspector, not the
production `GET /api/v1/resolve` resolver.
