# WilderLinks Android SDK

Use the Android SDK to resolve App Links, recover deferred install intent, and
exchange install attribution tokens.

## Initialize

```kotlin
Wildlinks.init(
  WildlinksConfig(
    baseUrl = "https://apilink.wilderbots.com",
    domains = listOf("go.wilderbots.com")
  )
)
```

## Resolve an App Link

```kotlin
val result = Wildlinks.handleIncomingUri(intent.data!!)
if (result.matched) {
  // result.destinationUrl
  // result.deepLinkPayload
  // result.openId
}
```

## Match a deferred install

```kotlin
val result = Wildlinks.checkDeferredInstall(context)
```

## Match a known deferred token

```kotlin
val result = Wildlinks.matchDeferredToken(
  "https://apilink.wilderbots.com",
  "<32-char-token>"
)
```

## Match App Store-style attribution token

```kotlin
val result = Wildlinks.matchInstallAttributionToken(
  "https://apilink.wilderbots.com",
  "wl_<token-from-provider>"
)
```

## Support

- Website: `https://wildlinks.wilderbots.com`
- Contact: `https://wildlinks.wilderbots.com/contact`
