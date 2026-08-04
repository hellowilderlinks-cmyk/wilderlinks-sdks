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
