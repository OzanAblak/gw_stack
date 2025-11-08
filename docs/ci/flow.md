# CI Akış Şeması — GW Stack (TRT)

```mermaid
flowchart LR
  A[Local/CI Smoke] -->|PASS| B[Upload smoke_artifact]
  B --> C[post_smoke]
  C -->|write| D[docs/ci/last_smoke.txt]
  C -->|compute| E[docs/ci/last_sha256.txt]
  C --> F[release-draft]
  F -->|draft prerelease| G((Releases Draft))
  G -->|manual gate| H[Pre-release Publish]
  H -->|manual promote| I[Stable Release]
