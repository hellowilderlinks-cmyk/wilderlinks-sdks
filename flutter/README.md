# WilderLinks Flutter SDK

The Flutter SDK helps your app handle the two main WilderLinks flows:

1. A user taps a smart link and your app is already installed.
2. A user taps a smart link, installs the app, and opens it for the first time.

It also supports app-specific path prefixes when multiple apps share one branded
domain.

## Install

Add the package:

```yaml
dependencies:
  wilderlinks_flutter_sdk: ^1.0.6
```

Then run:

```bash
flutter pub get
```

## What you still need to configure natively

This SDK does not replace iOS Associated Domains or Android App Links setup.

- **iOS**: add your branded domain in Xcode using `applinks:go.wilderbots.com`
  or your own WilderLinks domain.
- **Android**: add an `intent-filter` with `android:autoVerify="true"` for your
  branded domain in `AndroidManifest.xml`.

Those native settings are what allow the OS to hand the link into your app.

## Initialize once

```dart
import 'package:wilderlinks_flutter_sdk/wilderlinks_flutter_sdk.dart';

void main() {
  WildlinksSdk.init(const WildlinksConfig(
    baseUrl: 'https://apilink.wilderbots.com',
    domains: ['go.wilderbots.com'],
  ));
  runApp(const MyApp());
}
```

## Listen for incoming links

```dart
class _MyAppState extends State<MyApp> {
  final _listener = WildlinksListener();

  @override
  void initState() {
    super.initState();
    _listener.stream.listen((resolved) {
      if (!resolved.matched) return;

      print('Destination: ${resolved.destinationUrl}');
      print('Open ID: ${resolved.openId}');

      final payload = resolved.deepLinkPayload;
      if (payload != null) {
        Navigator.of(context).pushNamed(
          payload['screen'] as String,
          arguments: payload,
        );
      }
    });
    _listener.start();
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }
}
```

## Create a short link

Use this when you only need a short URL that redirects to a long destination.

```dart
final shortUrl = await WildlinksSdk.createShortLink(
  'https://www.clientbrand.com/summer-sale',
);
```

## Create a smart app link

Use this when your app should receive structured routing data.

```dart
final link = await WildlinksSdk.createDeepLink(
  defaultUrl: 'https://www.clientbrand.com/summer-sale',
  title: 'Summer sale',
  pathPrefix: 'x4I9',
  deepLinkPayload: {
    'screen': 'offer',
    'offerId': 'summer24',
  },
);

print(link.shortUrl);
```

## Match App Store attribution

If your iOS install attribution flow returns a `wl_<token>` value, exchange it:

```dart
final result = await WildlinksSdk.matchInstallAttributionToken(
  'https://apilink.wilderbots.com',
  'wl_<token-from-provider>',
  provider: 'app-store-campaign-token',
);
```

## Example URLs used in docs

- API base: `https://apilink.wilderbots.com`
- Branded domain: `https://go.wilderbots.com`
- Product site example: `https://www.clientbrand.com/summer-sale`

## Support

- Website: `https://wildlinks.wilderbots.com`
- Contact: `https://wildlinks.wilderbots.com/contact`
