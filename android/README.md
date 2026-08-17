# WilderLinks Android SDK

Use the Android SDK to resolve App Links, recover deferred install intent, and
exchange install attribution tokens.

## Initialize

```kotlin
Wilderlinks.init(
  WilderlinksConfig(
    baseUrl = "https://api.wilderlinks.space",
    domains = listOf("your-workspace.wilderlinks.space")
  )
)
```

## Resolve an App Link

```kotlin
val result = Wilderlinks.handleIncomingUri(intent.data!!)
if (result.matched) {
  // result.destinationUrl
  // result.deepLinkPayload
  // result.openId
}
```

## Match a deferred install

Call Play Install Referrer first. WilderLinks redirects Play Store fallback
traffic with `referrer=dl_match_token%3D<token>`, and this method exchanges
that token for the original payload after the first Play-installed launch.

```kotlin
val result = Wilderlinks.checkInstallReferrer(context)
```

If you need to read the clipboard fallback explicitly, call:

```kotlin
val result = Wilderlinks.checkDeferredInstall(context)
```

## Match a known deferred token

```kotlin
val result = Wilderlinks.matchDeferredToken(
  "https://api.wilderlinks.space",
  "<32-char-token>"
)
```

## Android QA checklist

- Use a physical device for install-time deferred deep link testing.
- Add the Play App Signing SHA-256 certificate fingerprint to the WilderLinks
  app profile.
- Uninstall any existing build before testing the Play Store install path.
- Open the WilderLinks URL, install from the Play Store or an Internal Testing
  listing, then launch the app and call `checkInstallReferrer(context)` during
  startup.

## Match App Store-style attribution token

```kotlin
val result = Wilderlinks.matchInstallAttributionToken(
  "https://api.wilderlinks.space",
  "wl_<token-from-provider>"
)
```

## Support

- Website: `https://wilderlinks.space`
- Contact: `https://wilderlinks.space/contact`
