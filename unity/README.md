# WilderLinks Unity SDK

Use the Unity SDK when your game or app needs to:

- resolve incoming smart links
- exchange deferred tokens when a token reaches the app
- handle configured incoming links after native OS integration

## Install

Add the package in Unity Package Manager using the Git URL:

```text
https://github.com/hellowilderlinks-cmyk/wilderlinks-sdks.git?path=/unity
```

## Initialize

```csharp
using Wilderbots.Wilderlinks;

WilderlinksClient.Init(new WilderlinksConfig(
    baseUrl: "https://api.wilderlinks.space",
    domains: new[] { "your-workspace.wilderlinks.space" }
));
```

Use the default domain shown in your WilderLinks workspace, such as
`your-workspace.wilderlinks.space`, or a verified custom domain. Custom domain
DNS should CNAME to `go.wilderlinks.space`.

Do not embed an organization API key in a distributed Unity client build.
Link creation, QR export, and custom event API-key calls belong on a trusted
server or in the dashboard. The SDK exposes those methods for trusted runtimes.

## Resolve a link

Resolve calls include a stable visitor id, browser-style timezone offset,
device model, and device vendor when available.

```csharp
StartCoroutine(WilderlinksClient.HandleIncomingUrl(url, result =>
{
    if (!result.matched) return;
    Debug.Log(result.destinationUrl);
    Debug.Log(result.deepLinkPayloadJson);
}));
```

## Check deferred install

This reads the clipboard fallback token. For production Android Play Store
installs, read Play Install Referrer in native code and pass the extracted
`dl_match_token` value to `MatchDeferredToken`.

```csharp
StartCoroutine(WilderlinksClient.CheckDeferredInstall(result =>
{
    if (result.matched)
    {
        Debug.Log(result.deepLinkPayloadJson);
    }
}));
```

```csharp
StartCoroutine(WilderlinksClient.MatchDeferredToken(
    "https://api.wilderlinks.space",
    "<32-char-token>",
    result => Debug.Log(result.deepLinkPayloadJson)
));
```

### Android Play Install Referrer bridge

Unity C# cannot read Play Install Referrer by itself. For production Android
deferred deep links, add Google's dependency to the Android app build:

```gradle
dependencies {
    implementation "com.android.installreferrer:installreferrer:2.2"
}
```

Add an app-side Android plugin to read the Play referrer, extract
`dl_match_token`, and pass it to `MatchDeferredToken` above. No native OS/referrer
bridge is bundled with this Unity package. Clipboard fallback is
user/platform-dependent.

## Server-side API-key operations

Create links and submit custom events from a trusted backend instead of a
shipped game client. See `https://wilderlinks.space/docs` for API endpoints and
scopes.

## Support

- Website: `https://wilderlinks.space`
- Contact: `https://wilderlinks.space/contact`
