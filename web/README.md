# WilderLinks Web SDK

This package covers two client-facing use cases:

1. **Server-side link creation** from Node.js, Next.js, or serverless functions.
2. **Browser-safe matching helpers** for explicit token and attribution checks.

## Install

```bash
npm install @wilderlinks/wilderlinks-sdk
```

## Create a short link from your backend

```ts
import { WilderlinksClient } from '@wilderlinks/wilderlinks-sdk';

const wilderlinks = new WilderlinksClient({
  apiKey: process.env.DEEPLINK_API_KEY!,
  baseUrl: 'https://api.wilderlinks.space',
});

const shortUrl = await wilderlinks.createShortLink({
  defaultUrl: 'https://www.clientbrand.com/summer-sale',
});

console.log(shortUrl);
```

## Create a smart app link from your backend

```ts
const link = await wilderlinks.createDeepLink({
  defaultUrl: 'https://www.clientbrand.com/summer-sale',
  appProfileId: 'app_profile_123',
  deepLinkPayload: { screen: 'offer', offerId: 'summer24' },
  utm: { source: 'newsletter', medium: 'email', campaign: 'summer24' },
});

console.log(link.shortUrl);
```

## Check a deferred match in the browser

This helper is for companion web experiences and legacy browser-storage flows.
Current production mobile redirects do not rely on web storage. Android deferred
installs should use Play Install Referrer, and mobile SDKs can exchange explicit
tokens with `/api/v1/match`.

```ts
import { checkDeferredMatch } from '@wilderlinks/wilderlinks-sdk';

const result = await checkDeferredMatch('https://api.wilderlinks.space');

if (result.matched) {
  console.log(result.deepLinkPayload);
}
```

## Exchange an explicit deferred token

```ts
const response = await fetch('https://api.wilderlinks.space/api/v1/match', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ matchToken: '<32-char-token>' }),
});

const result = await response.json();
```

## Match App Store attribution

```ts
import { matchInstallAttributionToken } from '@wilderlinks/wilderlinks-sdk';

const result = await matchInstallAttributionToken(
  'https://api.wilderlinks.space',
  'wl_<token-from-provider>',
  'app-store-campaign-token'
);
```

## Notes

- Keep `WilderlinksClient` on trusted backends only.
- Use browser helpers in public web apps when no API secret is needed.
- WilderLinks supports both plain and prefixed smart-link paths.

## Support

- Website: `https://wilderlinks.space`
- Dashboard: `https://wilderlinks.space`
- Contact: `https://wilderlinks.space/contact`
