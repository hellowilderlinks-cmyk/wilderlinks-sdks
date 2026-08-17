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

Incoming link resolution sends a stable visitor id, timezone offset, OS version,
and platform/vendor hints to WilderLinks.

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

## Deferred install matching

The React Native package uses clipboard as the cross-platform fallback:

```ts
import { checkDeferredInstall } from '@wilderlinks/wilderlinks-react-native';

const result = await checkDeferredInstall();
```

For production Android Play Store installs, use a native Play Install Referrer
module. WilderLinks Play Store fallback URLs include
`referrer=dl_match_token%3D<token>`. Extract the token and exchange it:

```ts
import { matchDeferredToken } from '@wilderlinks/wilderlinks-react-native';

const result = await matchDeferredToken(
  'https://api.wilderlinks.space',
  '<32-char-token>'
);
```

### Android Play Install Referrer bridge

React Native JavaScript cannot read Play Install Referrer by itself. Add
Google's dependency to `android/app/build.gradle` or
`android/app/build.gradle.kts`:

```kotlin
dependencies {
  implementation("com.android.installreferrer:installreferrer:2.2")
}
```

Then expose a native method named something like `getInstallReferrer()` from
your Android app. That method should return the raw Play referrer string from
`InstallReferrerClient.installReferrer.installReferrer`.

In React Native startup code, call your native module, extract the WilderLinks
token, then fall back to clipboard only when Play Referrer has no token:

```ts
import { NativeModules } from 'react-native';
import {
  checkDeferredInstall,
  matchDeferredToken,
} from '@wilderlinks/wilderlinks-react-native';

const { WilderlinksInstallReferrer } = NativeModules;

async function checkPlayInstallReferrer() {
  const referrer = await WilderlinksInstallReferrer.getInstallReferrer();
  const token = /dl_match_token=([a-f0-9]{32})/.exec(referrer || '')?.[1];

  if (!token) return null;

  return matchDeferredToken('https://api.wilderlinks.space', token);
}

const playResult = await checkPlayInstallReferrer();
const result = playResult?.matched
  ? playResult
  : await checkDeferredInstall();
```

## Support

- Website: `https://wilderlinks.space`
- Contact: `https://wilderlinks.space/contact`
