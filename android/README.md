# WilderLinks Android SDK

Use the Android SDK to resolve App Links, recover deferred install intent, and
exchange install attribution tokens.

## Initialize

```kotlin
Wilderlinks.init(
  WilderlinksConfig(
    baseUrl = "https://apilink.wilderbots.com",
    domains = listOf("go.wilderbots.com")
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
  "https://apilink.wilderbots.com",
  "<32-char-token>"
)
```

## Match App Store-style attribution token

```kotlin
val result = Wilderlinks.matchInstallAttributionToken(
  "https://apilink.wilderbots.com",
  "wl_<token-from-provider>"
)
```

## Support

- Website: `https://wilderlinks.wilderbots.com`
- Contact: `https://wilderlinks.wilderbots.com/contact`
