# WilderLinks React Native SDK

The React Native SDK helps your app handle:

- direct opens when the app is already installed
- deferred matching after a fresh install
- app-specific smart-link payloads
- App Store attribution token recovery

## Install

```bash
npm install @wilderlinks/wilderlinks-react-native
npm install @react-native-clipboard/clipboard
```

The clipboard dependency is only needed for deferred-match recovery flows.

## Native setup

You still need OS-level link configuration:

- **iOS**: add your workspace or branded domain in Associated Domains, for
  example `applinks:your-workspace.wilderlinks.space`
- **Android**: add an App Links `intent-filter` for your branded domain

Use the default domain shown in your WilderLinks workspace, such as
`your-workspace.wilderlinks.space`, or a verified custom domain. Custom domain
DNS should CNAME to `go.wilderlinks.space`.

## Initialize once

```tsx
import { initWilderlinks, useWilderlinks } from '@wilderlinks/wilderlinks-react-native';

initWilderlinks({
  baseUrl: 'https://api.wilderlinks.space',
  domains: ['your-workspace.wilderlinks.space'],
  apiKey: 'dlk_xxx',
});
```

## Resolve links inside your app

```tsx
function App() {
  const { resolved } = useWilderlinks();

  useEffect(() => {
    if (resolved?.matched && resolved.deepLinkPayload) {
      navigation.navigate(
        resolved.deepLinkPayload.screen,
        resolved.deepLinkPayload
      );
    }
  }, [resolved]);
}
```

## Create a smart link

```ts
import { createWildlink } from '@wilderlinks/wilderlinks-react-native';

const link = await createWildlink({
  defaultUrl: 'https://www.clientbrand.com/summer-sale',
  title: 'Summer launch',
  appProfileId: 'app_profile_123',
  deepLinkPayload: { screen: 'offer', offerId: 'summer24' },
});

console.log(link.shortUrl);
```

## Create a plain short link

```ts
import { createShortLink } from '@wilderlinks/wilderlinks-react-native';

const shortUrl = await createShortLink({
  defaultUrl: 'https://www.clientbrand.com/summer-sale',
});
```

## Match install attribution

```ts
import { matchInstallAttributionToken } from '@wilderlinks/wilderlinks-react-native';

const result = await matchInstallAttributionToken(
  'https://api.wilderlinks.space',
  'wl_<token-from-provider>',
  'app-store-campaign-token'
);
```

## Support

- Website: `https://wilderlinks.space`
- Contact: `https://wilderlinks.space/contact`
