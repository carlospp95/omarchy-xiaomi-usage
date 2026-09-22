# Xiaomi Agent Usage for Omarchy

A shell plugin that connects the Xiaomi MiMo token plan to Omarchy's built-in
AI usage panel (`omarchy.agents`). It ships no UI: the agents panel discovers
any `*.json` record in `~/.local/state/omarchy/agents/usage/`, and this plugin
writes the Xiaomi record there.

## Install

```bash
omarchy plugin add https://github.com/carlospp95/omarchy-xiaomi-usage.git --enable
```

Or by hand:

```bash
git clone https://github.com/carlospp95/omarchy-xiaomi-usage.git ~/.config/omarchy/plugins/xiaomi.agent-usage
omarchy-shell shell rescanPlugins
omarchy plugin enable xiaomi.agent-usage
sudo ~/.config/omarchy/plugins/xiaomi.agent-usage/install-mark.sh
```

The last step installs the Xiaomi brand mark where the built-in agents panel
resolves it; without it the tab shows the generic bar glyph instead of the
Xiaomi icon. `refresh.sh` keeps the mark installed afterwards and prints a
reminder with this command if it ever goes missing.

The Xiaomi tab appears in the agents panel once the first record lands
(within a minute of the shell starting).

## What it collects

- **Local token stats** from opencode sessions that ran on a Xiaomi provider
  (`xiaomi`, `xiaomi-token-plan-ams`, `xiaomi-token-plan-cn`,
  `xiaomi-token-plan-sgp`; the `mimo-*` models) and from pi/omp sessions on
  the same providers: today, the last 7 days, and all-time totals.
- **Plan limits** (optional): Xiaomi's token-plan API host accepts the `tp-`
  key for inference only — there is no quota endpoint for it. The console
  (platform.xiaomimimo.com) answers only to an authenticated browser
  session, so limits require you to paste that session Cookie header into
  the config (see below). The collector probes the console's undocumented
  `/api/v1/tokenPlan/usage` (monthly + per-cycle token windows) and
  `/api/v1/tokenPlan/detail` (plan name, current period end) and parses
  them defensively; the shape may change at any time.

Without a cookie the tab still shows local stats, and `authHelpText` says how
to add one.

## Configuration

Optional: `~/.config/omarchy/agents/xiaomi.json`

```json
{ "apiKey": "tp-...", "cookie": "serviceToken=...; userId=...; ..." }
```

- `apiKey` is not used for network calls today; it exists so the collector
  can identify the account and for future inference-host endpoints.
- `cookie` is the `Cookie` header your browser sends to
  `platform.xiaomimimo.com` while logged in (DevTools > Network > any
  request > Request Headers). It expires when the session does — the tab
  will tell you when it's time to refresh it.

The API key also resolves from `XIAOMI_API_KEY`/`MIMO_API_KEY`, the live
`~/.local/share/opencode/auth.json` (`xiaomi*` providers), or
`~/.omp|~/.pi/agent/.env`.

## Credentials

The collector looks for a cookie in this order:

1. `cookie` in `~/.config/omarchy/agents/xiaomi.json`
2. Nothing else — the console is the only source, and it only takes a
   session cookie.

## Details

- The record refreshes every 2 minutes and once at shell startup.
- The record file is swapped in atomically, so the panel never reads a
  half-written record.
- The panel's brand mark for a tab resolves inside the built-in agents
  plugin (`assets/<id>.svg`), which a third-party plugin can't extend by
  convention. This plugin bundles its own marks and keeps them installed:
  `refresh.sh` reinstalls `xiaomi.svg` whenever it goes missing (an omarchy
  upgrade can wipe the directory), and for a guaranteed install run
  `sudo ./install-mark.sh` once. Without the mark the tab shows the
  standard bar glyph.
- Disable or remove with `omarchy plugin disable xiaomi.agent-usage` /
  `omarchy plugin remove xiaomi.agent-usage`. Removing the plugin leaves the
  last `xiaomi.json` behind; delete
  `~/.local/state/omarchy/agents/usage/xiaomi.json` if you want the tab gone
  immediately.

## Dependencies

- `python3` (stdlib only — the collector uses no pip packages)
- `jq` (ships with Omarchy's default package set; used by `refresh.sh` to
  sanity-check the record before it lands)
- Local token stats work with no configuration at all; plan limits need the
  optional session cookie.

## License

MIT — see [LICENSE](LICENSE). Xiaomi and MiMo are trademarks of Xiaomi; this
plugin is an independent work, not affiliated with or endorsed by Xiaomi. The
bundled marks are minimal geometric shapes reproduced for identifying the
provider in the user's own panel.
