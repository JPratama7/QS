# Development Workflow

## Smoke Launch

Run the shell from this repo using the `--path` flag:

```sh
quickshell -p /home/xoid/projects/private/qs-rework
```

Or using the `qs` alias if available:

```sh
qs -p /home/xoid/projects/private/qs-rework
```

## Live Reload

Quickshell watches source files when `settings.watchFiles` is enabled. Edits to QML files should hot-reload automatically in most cases.

If the shell becomes unresponsive, kill and relaunch:

```sh
qs kill
qs -p /home/xoid/projects/private/qs-rework
```

## Testing Alongside a Live Shell

The Wayland layer-shell protocol does not allow two independent shell clients to control their relative z-order within the same layer. Two `Top`-layer bars from different Quickshell instances will overlap unpredictably.

**Recommended workflow when a live shell is running:**

```sh
# 1. Kill the live shell
quickshell kill

# 2. Launch the dev shell
quickshell -p /home/xoid/projects/private/qs-rework

# 3. When done testing, kill the dev shell and relaunch the live shell
quickshell kill
quickshell -p /path/to/live/shell
```

To identify running instances:

```sh
quickshell list
```

## QML Language Server

The `.qmlls.ini` at the repo root configures import resolution for the IDE. If new local import directories are added, update `importPaths` in that file.

## Verification Levels

- **Static**: file opens in IDE without unresolved imports
- **Smoke**: shell launches without crashing
- **Interaction**: manual exercise of new widget/popup/overlay behavior
- **Regression**: previously working surfaces still load correctly
