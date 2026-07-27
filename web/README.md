# WilderLinks Web SDK

This package covers two client-facing use cases:

1. **Server-side link creation** from Node.js, Next.js, or serverless functions.
2. **Browser-safe matching helpers** for deferred install and attribution checks.

## Install

```bash
npm install @wilderbots/wilderlinks-sdk
```

## Create a short link from your backend

```ts
import { WildlinksClient } from '@wilderbots/wilderlinks-sdk';

const wildlinks = new WildlinksClient({
  apiKey: process.env.DEEPLINK_API_KEY!,
  baseUrl: 'https://apilink.wilderbots.com',
});

const shortUrl = await wildlinks.createShortLink({
  defaultUrl: 'https://www.clientbrand.com/summer-sale',
});

console.log(shortUrl);
```

## Create a smart app link from your backend

```ts
const link = await wildlinks.createDeepLink({
  defaultUrl: 'https://www.clientbrand.com/summer-sale',
  appProfileId: 'app_profile_123',
  deepLinkPayload: { screen: 'offer', offerId: 'summer24' },
  utm: { source: 'newsletter', medium: 'email', campaign: 'summer24' },
});

console.log(link.shortUrl);
```

## Check a deferred match in the browser

```ts
import { checkDeferredMatch } from '@wilderbots/wilderlinks-sdk';

const result = await checkDeferredMatch('https://apilink.wilderbots.com');

if (result.matched) {
  console.log(result.deepLinkPayload);
}
```

## Match App Store attribution

```ts
import { matchInstallAttributionToken } from '@wilderbots/wilderlinks-sdk';

const result = await matchInstallAttributionToken(
  'https://apilink.wilderbots.com',
  'wl_<token-from-provider>',
  'app-store-campaign-token'
);
```

## Notes

- Keep `WildlinksClient` on trusted backends only.
- Use browser helpers in public web apps when no API secret is needed.
- WilderLinks supports both plain and prefixed smart-link paths.

## Support

- Website: `https://wildlinks.wilderbots.com`
- Dashboard: `https://wilderlinks.wilderbots.com`
- Contact: `https://wildlinks.wilderbots.com/contact`
