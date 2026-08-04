# WilderLinks Flutter example

This example app shows the full Flutter flow:

- initialize WilderLinks
- listen for incoming links
- recover deferred installs
- inspect matched payloads locally

## Run the example

```bash
cd example
flutter pub get
flutter run
```

## Before you test

Update `lib/main.dart` with:

- your API base URL
- your branded WilderLinks domain
- your Android package/SHA-256 and iOS bundle/Team ID app profile settings in
  the WilderLinks dashboard

The defaults should follow the same format used across the SDK docs:

- API: `https://apilink.wilderbots.com`
- domain: `https://go.wilderbots.com`
- dashboard/register: `https://wilderlinks.space`

## Best way to test

For a real test, open a valid WilderLinks URL on a device that has your app
installed or can install it fresh.

If you are debugging deferred flow behavior locally, you can still simulate a
match token and confirm the SDK plumbing before using a production tap.
