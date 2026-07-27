# WilderLinks CLI

Use the CLI when your team wants to work with WilderLinks from a terminal, CI
pipeline, or admin automation script.

## Install

```bash
npm install -g @wilderbots/wildlinks-cli
```

## Log in

```bash
wl login \
  --api-base https://apilink.wilderbots.com \
  --email ops@clientbrand.com \
  --password '<password>'
```

## Configure with environment variables

```bash
WILDLINKS_API_BASE=https://apilink.wilderbots.com
WILDLINKS_TOKEN=<dashboard-jwt>
WILDLINKS_ORG_ID=<organization-id>
WILDLINKS_API_KEY=<server-api-key>
```

## Common commands

```bash
wl orgs
wl links list --limit 10
wl links get <link-id>
wl links create --url https://www.clientbrand.com/app --title "Launch"
wl qr <link-id> --format png --out launch-qr.png --logo
wl utm generate --url https://www.clientbrand.com/app --title "Summer Launch" --source instagram
```

## Best use cases

- bulk operational link work
- CI-based QR generation
- quick UTM creation
- support and ops workflows

## Support

- Website: `https://wildlinks.wilderbots.com`
- Contact: `https://wildlinks.wilderbots.com/contact`
