# WilderLinks React Native SDK

The React Native SDK helps your app handle:

- direct opens when the app is already installed
- token-based deferred matching when a token reaches the app
- app-specific smart-link payloads
- exchange of attribution tokens supplied by your own integration

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

## Create links and submit events from a trusted server

The package exposes API-key methods, but organization API keys are secrets.
Never embed one in a React Native build. Use the dashboard or call the external
API from your trusted backend for link creation, retrieval, QR export, and
custom events. See `https://wilderlinks.space/docs` for server examples.

## Match install attribution

This method exchanges a token your own attribution integration has supplied;
it does not automatically retrieve an App Store install token.

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

Add an app-side native module to read the raw Play referrer; no such module is
bundled with this package. Extract `dl_match_token` and pass it to
`matchDeferredToken` as shown above. Use clipboard matching only as a fallback.

## Support

- Website: `https://wilderlinks.space`
- Contact: `https://wilderlinks.space/contact`
