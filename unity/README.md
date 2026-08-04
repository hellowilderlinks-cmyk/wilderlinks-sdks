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

```csharp
StartCoroutine(WilderlinksClient.HandleIncomingUrl(url, result =>
{
    if (!result.matched) return;
    Debug.Log(result.destinationUrl);
    Debug.Log(result.deepLinkPayloadJson);
}));
```

## Check deferred install

```csharp
StartCoroutine(WilderlinksClient.CheckDeferredInstall(result =>
{
    if (result.matched)
    {
        Debug.Log(result.deepLinkPayloadJson);
    }
}));
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
