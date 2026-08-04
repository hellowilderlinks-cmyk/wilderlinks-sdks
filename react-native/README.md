# WilderLinks React Native SDK

The React Native SDK helps your app handle:

- direct opens when the app is already installed
- deferred matching after a fresh install
- app-specific smart-link payloads
- App Store attribution token recovery

## Install

```bash
npm install @wilderbots/wilderlinks-react-native
npm install @react-native-clipboard/clipboard
```

The clipboard dependency is only needed for deferred-match recovery flows.

## Native setup

You still need OS-level link configuration:

- **iOS**: add your branded domain in Associated Domains, for example
  `applinks:go.wilderbots.com`
- **Android**: add an App Links `intent-filter` for your branded domain

## Initialize once

```tsx
import { initWilderlinks, useWilderlinks } from '@wilderbots/wilderlinks-react-native';

initWilderlinks({
  baseUrl: 'https://apilink.wilderbots.com',
  domains: ['go.wilderbots.com'],
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
import { createWildlink } from '@wilderbots/wilderlinks-react-native';

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
import { createShortLink } from '@wilderbots/wilderlinks-react-native';

const shortUrl = await createShortLink({
  defaultUrl: 'https://www.clientbrand.com/summer-sale',
});
```

## Match install attribution

```ts
import { matchInstallAttributionToken } from '@wilderbots/wilderlinks-react-native';

const result = await matchInstallAttributionToken(
  'https://apilink.wilderbots.com',
  'wl_<token-from-provider>',
  'app-store-campaign-token'
);
```

## Support

- Website: `https://wilderlinks.wilderbots.com`
- Contact: `https://wilderlinks.wilderbots.com/contact`
