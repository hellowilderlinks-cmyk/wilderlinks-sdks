# WilderLinks SDKs

WilderLinks gives your product one link system for:

- direct deep linking
- deferred deep linking after install
- Universal Links and Android App Links
- QR campaigns
- analytics-ready routing
- server-side link creation

This folder contains the official SDKs for different client stacks.

## Pick your SDK

| SDK | Best for |
| --- | --- |
| `flutter/` | Flutter apps |
| `react-native/` | React Native apps |
| `android/` | Native Android apps |
| `ios/` | Native iOS apps |
| `web/` | Node.js backends and browser web apps |
| `unity/` | Unity games and interactive apps |
| `cli/` | Terminal workflows and CI automation |

## Product links

- Website: `https://wilderlinks.space`
- Dashboard: `https://wilderlinks.space`
- Pricing: `https://wilderlinks.space/pricing`
- Contact: `https://wilderlinks.space/contact`
- SDK repository: `https://github.com/hellowilderlinks-cmyk/wilderlinks-sdks`

## Shared API base

Most SDK examples in this repo use:

`https://apilink.wilderbots.com`

That is the hosted WilderLinks API base used by the examples. If your team runs a
different environment, replace it with your own API origin.

## Shared branded-domain example

Examples use:

`https://go.wilderbots.com`

Replace that with your own branded routing domain when you configure your app.

## Before production SDK testing

Register or sign in at `https://wilderlinks.space`, then create your
workspace and app profile.

- Android apps need the package name and SHA-256 signing certificate fingerprint
  saved in the dashboard, plus an `android:autoVerify="true"` App Links intent
  filter in the app.
- iOS apps need the bundle ID, Apple Team ID, and App Store URL saved in the
  dashboard, plus the Associated Domains entitlement in Xcode.
- Custom domains are optional. If you use one, add it in the dashboard and
  follow the generated CNAME/TXT DNS records before using it in SDK config.

## What the SDKs handle

Depending on the platform, the SDKs can help with:

- resolving installed-app deep links
- matching deferred installs
- creating short links and smart links
- working with app-specific path prefixes
- reading install attribution tokens
- sending custom events
- generating QR-ready links from trusted runtimes

Each SDK README explains the supported flows, install steps, and production
integration pattern for that platform.
