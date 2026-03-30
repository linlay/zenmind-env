# Zenmind Runtime Workspace

## Package

Use [`./scripts/package.sh`](/Users/linlay/Project/zenmind/zenmind/scripts/package.sh) or [`./scripts/deploy/package-zenmind-data.sh`](/Users/linlay/Project/zenmind/zenmind/scripts/deploy/package-zenmind-data.sh) from the sibling [`zenmind`](/Users/linlay/Project/zenmind/zenmind) repo to package publishable `.zenmind` data.

The archive is written to [dist](/Users/linlay/Project/zenmind/.zenmind/dist) as `.zenmind/dist/<version>/zenmind-data-<version>.tar.gz`.

### Usage

```bash
cd /Users/linlay/Project/zenmind/zenmind
./scripts/package.sh
```

The old `.zenmind/package.sh` entry has been removed. Packaging now follows fixed rules and does not accept custom selection flags.

### Registry layout

- `.zenmind/registries.example/`
  Example registry templates used as the packaging source.
- `.zenmind/owner.example/`
  Example owner profile used as the packaging source.
- `.zenmind/registries/`
  Live runtime registry files for the current workspace.
- Packaged archives still write registry files under `registries/` and owner files under `owner/` inside the output bundle.

### Packaging Rules

- `agents/`: package normal directories and `*.example`; exclude `*.demo`
- `chats/`: package `*.example.jsonl` and `*.example/` only
- `root/`: package top-level files and directories whose basename contains `.example`
- `schedules/`: package normal `*.yml|*.yaml` and `*.example.yml|*.example.yaml`; exclude `*.demo.yml|*.demo.yaml`
- `skills-market/`: package normal directories and `*.example`; exclude `*.demo`
- `teams/`: package normal `*.yml|*.yaml` and `*.example.yml|*.example.yaml`; exclude `*.demo.yml|*.demo.yaml`
- `tools/`: not packaged
# zenmind-env
