# WilderLinks iOS SDK

Use the iOS SDK to resolve Universal Links, recover deferred install matches,
and exchange App Store attribution tokens.

## Add the package

```swift
.package(url: "https://github.com/hellowilderlinks-cmyk/wilderlinks-sdks.git", from: "1.0.0")
```

## Initialize

```swift
let client = WilderlinksClient(
  config: WilderlinksConfig(
    baseURL: URL(string: "https://api.wilderlinks.space")!,
    domains: ["your-workspace.wilderlinks.space"]
  )
)
```

## Resolve a Universal Link

```swift
let result = await client.handleIncomingURL(url)
if result.matched {
  // result.destinationURL
  // result.deepLinkPayload
  // result.openId
}
```

## Match a deferred install token

WilderLinks uses a pasteboard token as the iOS deferred fallback. The redirect
page writes `dl_match_token=<token>` only after a user gesture, and the SDK
exchanges that token after first launch.

```swift
let result = await client.checkDeferredInstall()
```

You can also exchange a token obtained through your own attribution flow:

```swift
let result = await client.matchDeferredToken("<32-char-token>")
```

## Match App Store attribution

```swift
let result = await client.matchInstallAttributionToken("wl_<token-from-provider>")
```

## Support

- Website: `https://wilderlinks.space`
- Contact: `https://wilderlinks.space/contact`
