# WilderLinks iOS SDK

Use the iOS SDK to resolve Universal Links and exchange matching tokens that
your app has actually received. iOS App Store token recovery is not automatic.
The Swift Package requires iOS 13 or newer.

## Add the package

Clone `https://github.com/hellowilderlinks-cmyk/wilderlinks-sdks.git`, then in
Xcode choose File → Add Package Dependencies → Add Local and select the `ios`
directory. Link the `WilderlinksSDK` product to your app target. A versioned
Git tag for an SPM version range has not been verified.

## Initialize

```swift
let client = WilderlinksClient(
  config: WilderlinksConfig(
    baseURL: URL(string: "https://api.wilderlinks.space")!,
    domains: ["your-workspace.wilderlinks.space"]
  )
)
```

## Create links (trusted runtimes only)

The SDK exposes `createLink`, `createDeepLink`, and `createShortLink`, matching
the Flutter SDK. These methods call `POST /api/v1/links` and require an API key
with `links:write`. Organization API keys are secrets: never set `apiKey` in a
distributed iOS app. For production mobile flows, call your own authenticated
backend, have it create the link with its server-held key, and return the URL
to the app.

```swift
// Trusted server runtime only; do not compile this key into an iOS app.
let client = WilderlinksClient(
  config: WilderlinksConfig(
    baseURL: URL(string: "https://api.wilderlinks.space")!,
    domains: [],
    apiKey: ProcessInfo.processInfo.environment["WILDERLINKS_API_KEY"]
  )
)

let link = try await client.createDeepLink(
  defaultUrl: "https://example.com/offers",
  appProfileId: "<app-profile-id>",
  deepLinkPayload: ["screen": .string("offers")]
)
print(link.shortUrl)

let shortUrl = try await client.createShortLink(
  defaultUrl: "https://example.com/campaign"
)
```

`createLink` also accepts routing, attribution, metadata, and extra fields via
its optional arguments. It returns a `CreatedLink`; API failures throw
`WilderlinksAPIError` with the HTTP status and service error message.

## Resolve a Universal Link

```swift
let result = await client.handleIncomingURL(url)
if result.matched {
  // result.destinationUrl
  // result.deepLinkPayload
  // result.openId
}
```

## Match a deferred install token

The SDK checks for a pasteboard token that a user-initiated redirect page may
have written. Clipboard access and token persistence depend on platform and user
behavior; there is no automatic App Store install-referrer handoff on iOS.

```swift
let result = await client.checkDeferredInstall()
```

You can also exchange a token obtained through your own attribution flow:

```swift
let result = await client.matchDeferredToken("<32-char-token>")
```

## Match a token from your own attribution flow

```swift
let result = await client.matchInstallAttributionToken("wl_<token-from-provider>")
```

Your integration must obtain that token. This method does not retrieve it from
the App Store by itself.

## Support

- Website: `https://wilderlinks.space`
- Contact: `https://wilderlinks.space/contact`
