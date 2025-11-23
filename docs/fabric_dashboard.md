# Fabric Dashboard Session

Prebuilt kitty session for AI fabric / accelerator control. Ships with KITTYVONCAN as an opt-in layout and keeps all assets under `~/.config/kitty/kittyvoncan/`.

## Launch

- Run `~/.config/kitty/scripts/fabric_dashboard.sh` to start the session.
- The script warns about missing commands and uses the session file at `~/.config/kitty/kittyvoncan/sessions/fabric_dashboard.session`.
- Set `KITTY_FABRIC_WORKDIR` to pin all panes to a workspace (defaults to `~/.config/kitty/kittyvoncan`).

## Layout (defaults)

- **Fabric Control:** `fabricctl status --watch`, `intel_gpu_top`, `watch -n 2 npu-status`, `htop`.
- **AI Ops:** `ov-bench --live`, gateway (`python ./local_llm_gateway.py`), `journalctl -fu openvino-npu.service`, metrics tail (`curl -N ... | grep -E 'npu|gpu|llm'`).
- **MILSPEC:** `dmesg` filter, `/dev/accel*` and `/dev/dri/*` listing, `milspec-guardian --tui`, `tb monitor`.
- **Dev:** `ipython`, `python ./fabric_cli.py`, spare shell.

Each pane stays open with a fallback shell if the command is missing.

## Command Overrides

Set environment variables before launching to match your stack:

- `FABRICCTL_CMD`, `GPU_MONITOR_CMD`, `NPU_STATUS_CMD`, `SYSTEM_MONITOR_CMD`
- `OPENVINO_BENCH_CMD`, `GATEWAY_CMD`, `NPU_LOG_CMD`, `METRICS_CMD`
- `DMESG_CMD`, `DEVICE_LS_CMD`, `GUARDIAN_CMD`, `THERMAL_CMD`
- `IPYTHON_CMD`, `FABRIC_CLI_CMD`

Example:

```bash
KITTY_FABRIC_WORKDIR=~/ai-fabric \
FABRICCTL_CMD="fabricctl status --watch --json" \
GATEWAY_CMD="poetry run python ./services/local_llm_gateway.py" \
~/.config/kitty/scripts/fabric_dashboard.sh
```

## Customize & Bind

- Edit the session template directly: `~/.config/kitty/kittyvoncan/sessions/fabric_dashboard.session`.
- Optional keybinding (add to `kitty.conf` or `custom.conf`):

```conf
map ctrl+shift+f launch --type=tab --cwd=current ~/.config/kitty/scripts/fabric_dashboard.sh
```

## Notes

- Requires kitty remote control (enabled by default in KITTYVONCAN).
- Commands are placeholders; swap them for your fabric control plane binaries and monitoring tools.
