# WilderLinks Android SDK

Use the Android SDK to resolve App Links, recover deferred install intent, and
exchange install attribution tokens.

## Initialize

```kotlin
import com.wilderbots.wilderlinks.Wilderlinks
import com.wilderbots.wilderlinks.WilderlinksConfig

Wilderlinks.init(
  WilderlinksConfig(
    baseUrl = "https://api.wilderlinks.space",
    domains = listOf("your-workspace.wilderlinks.space")
  )
)
```

## Create links (trusted runtimes only)

The SDK exposes `createLink`, `createDeepLink`, and `createShortLink`, matching
the Flutter SDK. These methods call `POST /api/v1/links` and require an API key
with `links:write`. Organization API keys are secrets: never set `apiKey` in a
distributed Android app. For production mobile flows, call your own
authenticated backend, have it create the link with its server-held key, and
return the URL to the app.

```kotlin
// Trusted backend runtime only; do not put this key in an APK.
Wilderlinks.init(
  WilderlinksConfig(
    baseUrl = "https://api.wilderlinks.space",
    domains = emptyList(),
    apiKey = System.getenv("WILDERLINKS_API_KEY")
  )
)

val link = Wilderlinks.createDeepLink(
  defaultUrl = "https://example.com/offers",
  appProfileId = "<app-profile-id>",
  deepLinkPayload = mapOf("screen" to "offers")
)
println(link.shortUrl)

val shortUrl = Wilderlinks.createShortLink(
  defaultUrl = "https://example.com/campaign"
)
```

`createLink` also accepts routing, attribution, metadata, and extra fields via
its optional arguments. It returns a `CreatedLink`; API failures throw
`WilderlinksApiException` with the HTTP status and service error message.

The link-resolution and deferred-match methods below are `suspend` functions;
call them from your app's coroutine scope.

## Resolve an App Link

```kotlin
import android.content.Context
import android.net.Uri
import com.wilderbots.wilderlinks.Wilderlinks

suspend fun handleIncomingLink(uri: Uri, context: Context) {
  val result = Wilderlinks.handleIncomingUri(uri, context)
  if (result.matched) {
    // result.destinationUrl
    // result.deepLinkPayload
    // result.openId
  }
}
```

## Match a deferred install

Call Play Install Referrer first. WilderLinks redirects Play Store fallback
traffic with `referrer=dl_match_token%3D<token>`, and this method exchanges
that token for the original payload after the first Play-installed launch.

```kotlin
import android.content.Context
import com.wilderbots.wilderlinks.Wilderlinks

suspend fun checkForDeferredInstall(context: Context) {
  val result = Wilderlinks.checkInstallReferrer(context)
  if (result.matched) {
    // result.deepLinkPayload
  }
}
```

If you need to read the clipboard fallback explicitly, call:

```kotlin
import android.content.Context
import com.wilderbots.wilderlinks.Wilderlinks

suspend fun checkClipboardFallback(context: Context) {
  val result = Wilderlinks.checkDeferredInstall(context)
}
```

## Match a known deferred token

```kotlin
import com.wilderbots.wilderlinks.Wilderlinks

suspend fun matchKnownDeferredToken(token: String) {
  val result = Wilderlinks.matchDeferredToken(
    "https://api.wilderlinks.space",
    token
  )
}
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
import com.wilderbots.wilderlinks.Wilderlinks

suspend fun matchAttributionToken(token: String) {
  val result = Wilderlinks.matchInstallAttributionToken(
    "https://api.wilderlinks.space",
    token
  )
}
```

## Support

- Website: `https://wilderlinks.space`
- Contact: `https://wilderlinks.space/contact`
