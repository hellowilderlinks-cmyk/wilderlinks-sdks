# WilderLinks CLI

Use the CLI when your team wants to work with WilderLinks from a terminal, CI
pipeline, or admin automation script.

## Install

```bash
npm install -g @wilderbots/wilderlinks-cli
```

## Log in

```bash
wilderlinks login \
  --api-base https://apilink.wilderbots.com \
  --email ops@clientbrand.com \
  --password '<password>'
```

Or use the short alias:

```bash
wl login \
  --api-base https://apilink.wilderbots.com \
  --email ops@clientbrand.com \
  --password '<password>'
```

## Configure with environment variables

```bash
WILDERLINKS_API_BASE=https://apilink.wilderbots.com
WILDERLINKS_TOKEN=<dashboard-jwt>
WILDERLINKS_ORG_ID=<organization-id>
WILDERLINKS_API_KEY=<server-api-key>
```

## Common commands

```bash
wilderlinks orgs
wilderlinks links list --limit 10
wilderlinks links get <link-id>
wilderlinks links create --url https://www.clientbrand.com/app --title "Launch"
wilderlinks qr <link-id> --format png --out launch-qr.png --logo
wilderlinks utm generate --url https://www.clientbrand.com/app --title "Summer Launch" --source instagram
```

## Best use cases

- bulk operational link work
- CI-based QR generation
- quick UTM creation
- support and ops workflows

## Support

- Website: `https://wilderlinks.space`
- Contact: `https://wilderlinks.space/contact`
