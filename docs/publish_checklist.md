# Publish Checklist — Core (v0.1.2-core)

1) Lokal SMOKE → PASS 19090=200 38888=200 E2E=200
2) Gateway SMOKE → GW_PASS 8088=200 E2E=200
3) Artefakt ZIP + SHA256 → ART PASS SIZE=<n> SHA256=<hex>
4) Tag + Push → GIT PASS TAG=vX.Y.Z-core ZIP_SIZE=<n> SHA256=<hex>
5) Checkpoint dosyası → yaz, commit ve push

Notlar
- E2E tek ölçüt: `compile(planId)=200`. GET rota opsiyonel; 404 kabul.
- CI smoke job’u “tek satır PASS” yoksa publish’i **koşturmaz**.
