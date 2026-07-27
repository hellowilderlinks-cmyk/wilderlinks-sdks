# WilderLinks Unity SDK

Use the Unity SDK when your game or app needs to:

- resolve incoming smart links
- recover deferred install matches
- create app links from trusted builds
- send custom engagement events

## Install

Add the package in Unity Package Manager using the Git URL:

```text
https://github.com/wilderbots-droid/wildlinks-sdks.git?path=/unity
```

## Initialize

```csharp
using Wilderbots.Wildlinks;

WildlinksClient.Init(new WildlinksConfig(
    baseUrl: "https://apilink.wilderbots.com",
    domains: new[] { "go.wilderbots.com" },
    apiKey: "dlk_xxx"
));
```

## Resolve a link

```csharp
StartCoroutine(WildlinksClient.HandleIncomingUrl(url, result =>
{
    if (!result.matched) return;
    Debug.Log(result.destinationUrl);
    Debug.Log(result.deepLinkPayloadJson);
}));
```

## Check deferred install

```csharp
StartCoroutine(WildlinksClient.CheckDeferredInstall(result =>
{
    if (result.matched)
    {
        Debug.Log(result.deepLinkPayloadJson);
    }
}));
```

## Create a smart link

```csharp
var request = new WildlinksCreateLinkRequest
{
    defaultUrl = "https://www.clientbrand.com/summer-sale",
    title = "Launch Offer",
    deepLinkPayloadJson = "{\"screen\":\"offer\",\"offerId\":\"summer24\"}"
};

StartCoroutine(WildlinksClient.CreateLink(request, link =>
{
    Debug.Log(link.shortUrl);
}));
```

## Track an event

```csharp
StartCoroutine(WildlinksClient.TrackEvent(new WildlinksTrackEventRequest
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

- Website: `https://wildlinks.wilderbots.com`
- Contact: `https://wildlinks.wilderbots.com/contact`
