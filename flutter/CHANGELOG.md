# Changelog

## 1.0.8

- Replace placeholder Flutter SDK documentation URLs with real WilderLinks URLs.
- Document dashboard registration, Android/iOS app profile configuration, and
  optional custom-domain setup for production Flutter SDK integrations.

## 1.0.7

- Update repository and homepage metadata URLs to point to package subdirectory.
- Verified publisher domain integration and code formatting improvements.

## 1.0.6

- Add a dedicated `createShortLink()` example for plain short URLs.
- Clarify when to use short links versus smart deep links in the docs.

## 1.0.5

- Allow link creation by `pathPrefix` so apps can target prefixes like `/CFlU/` without passing an app profile ID.

## 1.0.4

- Support app-specific prefixed links such as `/x4I9/slug`.
- Add `appProfileId` to link-creation examples and package docs.

## 1.0.3

- Clarify the README examples for links with and without `deepLinkPayload`.

## 1.0.2

- Fix the install instructions so apps only add `wilderlinks_flutter_sdk`.

## 1.0.1

- Clean up the public README for pub.dev.
- Update package documentation to use the published `wilderlinks_flutter_sdk` dependency.

## 1.0.0

- Initial release.
- `WildlinksSdk.handleIncomingUri` — resolve a Universal Link / App Link when the app is already installed.
- `WildlinksSdk.checkDeferredInstall` / `matchDeferredToken` — deferred deep link matching after a fresh install.
- `WildlinksListener` — stream-based wrapper around `app_links` that wires the two together automatically.
