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

- Website: `https://wildlinks.wilderbots.com`
- Dashboard: `https://wilderlinks.wilderbots.com`
- Pricing: `https://wildlinks.wilderbots.com/pricing`
- Contact: `https://wildlinks.wilderbots.com/contact`
- SDK repository: `https://github.com/wilderbots-droid/wildlinks-sdks`

## Shared API base

Most SDK examples in this repo use:

`https://apilink.wilderbots.com`

That is the hosted WilderLinks API base used by the examples. If your team runs a
different environment, replace it with your own API origin.

## Shared branded-domain example

Examples use:

`https://go.wilderbots.com`

Replace that with your own branded routing domain when you configure your app.

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
