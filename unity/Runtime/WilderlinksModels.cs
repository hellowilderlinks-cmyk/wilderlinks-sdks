using System;
using System.Collections.Generic;

namespace Wilderbots.Wilderlinks
{
    [Serializable]
    public sealed class WilderlinksResolvedLink
    {
        public bool matched;
        public string openId;
        public string title;
        public string destinationUrl;
        public string installAttributionProvider;
        public string error;
        public string deepLinkPayloadJson;
    }

    [Serializable]
    public sealed class WilderlinksLinkResponse
    {
        public string _id;
        public string slug;
        public string title;
        public string defaultUrl;
        public string shortUrl;
        public int clickCount;
        public bool isActive;
        public string startsAt;
        public string expiresAt;
        public string error;
    }

    [Serializable]
    public sealed class WilderlinksQrCodeResponse
    {
        public string shortUrl;
        public string qrCodeDataUrl;
        public string error;
    }

    [Serializable]
    public sealed class WilderlinksEventResponse
    {
        public string id;
        public string name;
        public string linkId;
        public string occurredAt;
        public string error;
    }

    [Serializable]
    public sealed class WilderlinksUtm
    {
        public string source;
        public string medium;
        public string campaign;
        public string term;
        public string content;
    }

    [Serializable]
    public sealed class WilderlinksMarketing
    {
        public string referralCode;
        public string affiliateId;
        public string couponCode;
        public string promoCode;
        public bool appendToDestination = true;
    }

    [Serializable]
    public sealed class WilderlinksCreateLinkRequest
    {
        public string defaultUrl;
        public string domainId;
        public string appProfileId;
        public string pathPrefix;
        public string slug;
        public string title;
        public string rulesJson;
        public string splitTargetsJson;
        public string deepLinkPayloadJson;
        public WilderlinksUtm utm;
        public WilderlinksMarketing marketing;
        public string leadCaptureJson;
        public string retargetingPixelsJson;
        public string ctaOverlayJson;
        public string password;
        public string startsAt;
        public string expiresAt;
        public int? maxClicks;
        public List<string> tags;
        public bool preferShortDomain;
    }

    [Serializable]
    public sealed class WilderlinksTrackEventRequest
    {
        public string name;
        public string linkId;
        public string visitorId;
        public double? value;
        public string currency;
        public string metadataJson;
        public string occurredAt;
    }
}
