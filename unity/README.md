# WilderLinks Unity SDK

Use the Unity SDK when your game or app needs to:

- resolve incoming smart links
- recover deferred install matches
- create app links from trusted builds
- send custom engagement events

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
    domains: new[] { "your-workspace.wilderlinks.space" },
    apiKey: "dlk_xxx"
));
```

Use the default domain shown in your WilderLinks workspace, such as
`your-workspace.wilderlinks.space`, or a verified custom domain. Custom domain
DNS should CNAME to `go.wilderlinks.space`.

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

Then add an Android native plugin that returns the raw Play referrer string from
`InstallReferrerClient.installReferrer.installReferrer`. From Unity startup
code, call that plugin, extract the WilderLinks token, and exchange it:

```csharp
using System.Text.RegularExpressions;
using Wilderbots.Wilderlinks;

void CheckAndroidDeferredInstall()
{
    using (var plugin = new AndroidJavaClass("your.package.WilderlinksReferrerPlugin"))
    {
        var referrer = plugin.CallStatic<string>("getInstallReferrer");
        var match = Regex.Match(referrer ?? "", "dl_match_token=([a-f0-9]{32})");

        if (!match.Success)
        {
            StartCoroutine(WilderlinksClient.CheckDeferredInstall(result =>
            {
                if (result.matched) Debug.Log(result.deepLinkPayloadJson);
            }));
            return;
        }

        StartCoroutine(WilderlinksClient.MatchDeferredToken(
            "https://api.wilderlinks.space",
            match.Groups[1].Value,
            result => Debug.Log(result.deepLinkPayloadJson)
        ));
    }
}
```

## Create a smart link

```csharp
var request = new WilderlinksCreateLinkRequest
{
    defaultUrl = "https://www.clientbrand.com/summer-sale",
    title = "Launch Offer",
    deepLinkPayloadJson = "{\"screen\":\"offer\",\"offerId\":\"summer24\"}"
};

StartCoroutine(WilderlinksClient.CreateLink(request, link =>
{
    Debug.Log(link.shortUrl);
}));
```

## Track an event

```csharp
StartCoroutine(WilderlinksClient.TrackEvent(new WilderlinksTrackEventRequest
{
    name = "level_complete",
    linkId = "link_id",
    value = 1
}, result =>
{
    if (!string.IsNullOrEmpty(result.error)) Debug.LogError(result.error);
}));
```

## Support

- Website: `https://wilderlinks.space`
- Contact: `https://wilderlinks.space/contact`
