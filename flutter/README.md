# WilderLinks Flutter SDK

The Flutter SDK helps your app handle the two main WilderLinks flows:

1. A user taps a smart link and your app is already installed.
2. A user installs the app after tapping a link and your app receives a token
   through a supported, platform-specific handoff.

It also supports app-specific path prefixes when multiple apps share one branded
domain.

## Install

Add the package:

```yaml
dependencies:
  wilderlinks_flutter_sdk: ^1.0.10
```

Then run:

```bash
flutter pub get
```

## What you still need to configure natively

This SDK does not replace iOS Associated Domains or Android App Links setup.

- **Register/configure app profiles**: sign in at
  `https://wilderlinks.space` and create or select your workspace.
  Add each mobile app profile there before testing production links.
- **Android**: in the WilderLinks dashboard, add the Android package name and
  SHA-256 signing certificate fingerprint for your Flutter app. In Flutter,
  add an `intent-filter` with `android:autoVerify="true"` for your WilderLinks
  domain in `android/app/src/main/AndroidManifest.xml`.
- **iOS**: in the WilderLinks dashboard, add the iOS bundle ID, Apple Team ID,
  and App Store URL. In Xcode, enable Associated Domains and add
  `applinks:your-workspace.wilderlinks.space` or your own verified WilderLinks domain.
- **Custom domain**: optional, but recommended for branded production links.
  Add it in the WilderLinks dashboard and follow the generated CNAME/TXT DNS
  records. The custom domain CNAME target is `go.wilderlinks.space`. After
  verification, use that custom host in `domains`.

Those native settings are what allow the OS to hand the link into your app.

## Initialize once

```dart
import 'package:wilderlinks_flutter_sdk/wilderlinks_flutter_sdk.dart';

void main() {
  WilderlinksSdk.init(const WilderlinksConfig(
    baseUrl: 'https://api.wilderlinks.space',
    domains: ['your-workspace.wilderlinks.space'],
  ));
  runApp(const MyApp());
}
```

## Listen for incoming links

Incoming link resolution sends visitor, device, timezone, OS, and language
signals to WilderLinks so smart-routing rules and analytics can match native
app opens more accurately.

```dart
class _MyAppState extends State<MyApp> {
  final _listener = WilderlinksListener();

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

## Create links from a trusted server

The Flutter SDK exposes API-key link and event methods, but organization API
keys must never be embedded in a distributed app. Use the dashboard or a
trusted backend for link creation, QR retrieval, and custom events. See
`https://wilderlinks.space/docs` for the external API.

## Match App Store attribution

If your own iOS attribution flow returns a `wl_<token>` value, exchange it.
The SDK does not automatically retrieve a token from the App Store:

```dart
final result = await WilderlinksSdk.matchInstallAttributionToken(
  'https://api.wilderlinks.space',
  'wl_<token-from-provider>',
  provider: 'app-store-campaign-token',
);
```

## Deferred install matching

The Flutter SDK can read the gesture-gated clipboard fallback token:

```dart
final result = await WilderlinksSdk.checkDeferredInstall();
```

For production Android Play Store installs, use Play Install Referrer through
native Android code or a Flutter plugin. Extract `dl_match_token=<token>` from
the referrer string, then exchange it:

```dart
final result = await WilderlinksSdk.matchDeferredToken(
  'https://api.wilderlinks.space',
  '<32-char-token>',
);
```

### Android Play Install Referrer bridge

If your Flutter app does not already use an install-referrer plugin, add the
native Android bridge below.

Add Google's Install Referrer dependency in `android/app/build.gradle` or
`android/app/build.gradle.kts`:

```kotlin
dependencies {
  implementation("com.android.installreferrer:installreferrer:2.2")
}
```

Then expose the Play referrer from
`android/app/src/main/kotlin/.../MainActivity.kt`:

```kotlin
package your.package.name

import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val channelName = "wilderlinks/install_referrer"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
      .setMethodCallHandler { call, result ->
        if (call.method != "getInstallReferrer") {
          result.notImplemented()
          return@setMethodCallHandler
        }

        val client = InstallReferrerClient.newBuilder(this).build()
        client.startConnection(object : InstallReferrerStateListener {
          override fun onInstallReferrerSetupFinished(responseCode: Int) {
            try {
              if (responseCode == InstallReferrerClient.InstallReferrerResponse.OK) {
                result.success(client.installReferrer.installReferrer)
              } else {
                result.success(null)
              }
            } catch (error: Exception) {
              result.error("INSTALL_REFERRER_ERROR", error.message, null)
            } finally {
              client.endConnection()
            }
          }

          override fun onInstallReferrerServiceDisconnected() {
            result.success(null)
          }
        })
      }
  }
}
```

In Dart startup code, read the referrer, extract the WilderLinks token, and
fall back to the SDK clipboard helper only when the Play referrer does not
contain a token:

```dart
import 'package:flutter/services.dart';
import 'package:wilderlinks_flutter_sdk/wilderlinks_flutter_sdk.dart';

const _installReferrer = MethodChannel('wilderlinks/install_referrer');

Future<ResolvedLink?> checkPlayInstallReferrer() async {
  final referrer =
      await _installReferrer.invokeMethod<String>('getInstallReferrer');
  final token = RegExp(r'dl_match_token=([a-f0-9]{32})')
      .firstMatch(referrer ?? '')
      ?.group(1);

  if (token == null) return null;

  return WilderlinksSdk.matchDeferredToken(
    'https://api.wilderlinks.space',
    token,
  );
}

final playResult = await checkPlayInstallReferrer();
final result = playResult?.matched == true
    ? playResult!
    : await WilderlinksSdk.checkDeferredInstall();
```

## Example URLs used in docs

- API base: `https://api.wilderlinks.space`
- Workspace default domain: `https://your-workspace.wilderlinks.space`
- Custom domain CNAME target: `go.wilderlinks.space`
- Product URL example: `https://wilderlinks.space/docs`
- Registration/dashboard: `https://wilderlinks.space`
- Dashboard app setup: `https://wilderlinks.space/apps`
- Custom domain setup: `https://wilderlinks.space/domains`

## Support

- Website: `https://wilderlinks.space`
- Dashboard: `https://wilderlinks.space`
- Contact: `https://wilderlinks.space/contact`
