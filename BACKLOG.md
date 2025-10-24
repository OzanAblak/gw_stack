# BACKLOG — Çekirdek
## MUST
- Tek override; portlar {gateway:18088, planner:19090}; tek ağ; healthchain (service_healthy)
- /plans bind; Cleaner TTL ≥ 5 dk; 5-satır rapor standardı
- Multi-arch imaj (amd64+arm64) buildx manifest; sürüm pinleme
- CI: Linux e2e, Win/macOS smoke
- UI tek sayfa: Plans, Compile, Plan Detay (JSON), Monitor mini
- i18n ≥10 dil (RTL/LTR), ICU/CLDR; Accept-Language → Content-Language
## SHOULD
- Advanced çekmece (RL/CORS, Nginx önizleme), audit trail, webhook, cURL kopyala
## LATER
- RBAC/SSO, SOC2 yol haritası, çoklu ortam yöneticisi

- [MUST] 429 JSON gövdesi: error_page yerine @rate_limited için garantili body (njs/subrequest). Test: curl -i, PS stream read. 
