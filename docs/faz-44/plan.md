FAZ-44 PLAN // GW Stack // CI Entegrasyonu — release\_draft + generate\_release\_body



============================================================

1\) AMAÇ

============================================================



FAZ-44’ün ana hedefi:



\- FAZ-43’te hazırlanan `generate\_release\_body.ps1` script’ini,

\- `.github/workflows/release\_draft` iş akışına entegre ederek,

\- Release body’yi CI içinde otomatik (veya yarı otomatik) üretmek.



Bu fazda odak:



\- Mevcut pipeline davranışını BOZMADAN,

\- Sadece ek adım olarak:

&nbsp; - Template’ten gövde üretmek,

&nbsp; - `gh release edit` ile body’yi güncellemek.



============================================================

2\) GİRDİLER (ENV DEĞİŞKENLERİ ve KAYNAKLAR)

============================================================



Script tarafı (generate\_release\_body.ps1) şu ENV değişkenlerini bekliyor:



\- Header/meta:

&nbsp; - `REL\_TAG`        → `{TAG}`

&nbsp; - `REL\_TYPE`       → `{RELEASE\_TYPE}`

&nbsp; - `REL\_BRANCH`     → `{BRANCH}`

&nbsp; - `REL\_COMMIT`     → `{COMMIT}`

&nbsp; - `REL\_URL`        → `{RELEASE\_URL}`



\- CI zinciri:

&nbsp; - `SMOKE\_RUN\_ID`           → `{SMOKE\_RUN\_ID}`

&nbsp; - `SMOKE\_STATUS`           → `{SMOKE\_STATUS}`

&nbsp; - `POST\_SMOKE\_RUN\_ID`      → `{POST\_SMOKE\_RUN\_ID}`

&nbsp; - `POST\_SMOKE\_STATUS`      → `{POST\_SMOKE\_STATUS}`

&nbsp; - `RELEASE\_DRAFT\_RUN\_ID`   → `{RELEASE\_DRAFT\_RUN\_ID}`

&nbsp; - `RELEASE\_DRAFT\_STATUS`   → `{RELEASE\_DRAFT\_STATUS}`

&nbsp; - `SITE\_CHECK\_RUN\_ID`      → `{SITE\_CHECK\_RUN\_ID}`

&nbsp; - `SITE\_CHECK\_STATUS`      → `{SITE\_CHECK\_STATUS}`

&nbsp; - `CI\_PIPELINE\_STATUS`     → `{CI\_PIPELINE\_STATUS}`



\- DoD:

&nbsp; - `DOD\_STATUS`             → `{DOD\_STATUS}`



FAZ-44’te minimum hedef:



\- Header/meta alanlarını CI context’ten doldurmak:

&nbsp; - `REL\_TAG`     → release\_draft’in oluşturduğu tag

&nbsp; - `REL\_TYPE`    → şimdilik sabit `"Pre-release"`

&nbsp; - `REL\_BRANCH`  → `${{ github.ref\_name }}` veya türe göre

&nbsp; - `REL\_COMMIT`  → `${{ github.sha }}`

&nbsp; - `REL\_URL`     → `gh release` çıktısından veya action output’tan



\- CI run ID alanları:

&nbsp; - İlk versiyonda:

&nbsp;   - Sabit string veya “TODO” olarak geçebilir.

&nbsp;   - Bir sonraki fazda `smoke / post\_smoke / site\_check` run\_id’lerini gerçekten bağlama işi yapılır.



============================================================

3\) ÖNERİLEN WORKFLOW ENTEGRASYON İSKELETİ

============================================================



Bu bölüm, `.github/workflows/release\_draft.yml` içine eklenecek adımların TASLAĞIDIR.

Gerçek dosyada:

\- Job ismi, step id’leri, kullanılan action’lar değişik olabilir.

\- Buradaki `create\_release` gibi id’ler senin mevcut workflow’una göre uyarlanacak.



Örnek konsept:



```yaml

jobs:

&nbsp; release\_draft:

&nbsp;   runs-on: ubuntu-latest



&nbsp;   steps:

&nbsp;     - name: Checkout

&nbsp;       uses: actions/checkout@v4



&nbsp;     # Burada halihazırda bir release oluşturma adımın var (ör: gh release create vs.)

&nbsp;     # Bu adımın çıktısından TAG ve URL almak ideal.

&nbsp;     - name: Create draft release

&nbsp;       id: create\_release

&nbsp;       run: |

&nbsp;         # ÖRNEK: gerçekte senin kullandığın komut buraya gelecek

&nbsp;         # gh release create "$TAG" --draft --notes "temp" ...

&nbsp;         echo "TAG=v0.1.1-draft-XXXX" >> $GITHUB\_OUTPUT

&nbsp;         echo "URL=https://github.com/...." >> $GITHUB\_OUTPUT



&nbsp;     - name: Generate release body (template + script)

&nbsp;       shell: pwsh

&nbsp;       env:

&nbsp;         REL\_TAG:   ${{ steps.create\_release.outputs.TAG }}

&nbsp;         REL\_TYPE:  "Pre-release"

&nbsp;         REL\_BRANCH: ${{ github.ref\_name }}

&nbsp;         REL\_COMMIT: ${{ github.sha }}

&nbsp;         REL\_URL:   ${{ steps.create\_release.outputs.URL }}



&nbsp;         # CI run id’leri — FAZ-44 v1’de sabit veya TODO kalabilir:

&nbsp;         SMOKE\_RUN\_ID:         "TODO"

&nbsp;         SMOKE\_STATUS:         "PASS"

&nbsp;         POST\_SMOKE\_RUN\_ID:    "TODO"

&nbsp;         POST\_SMOKE\_STATUS:    "PASS"

&nbsp;         RELEASE\_DRAFT\_RUN\_ID: "TODO"

&nbsp;         RELEASE\_DRAFT\_STATUS: "PASS"

&nbsp;         SITE\_CHECK\_RUN\_ID:    "TODO"

&nbsp;         SITE\_CHECK\_STATUS:    "PASS"

&nbsp;         CI\_PIPELINE\_STATUS:   "ALL PASS"



&nbsp;         # DoD sonucu — ilk versiyonda sabit:

&nbsp;         DOD\_STATUS: "PASS"



&nbsp;       run: |

&nbsp;         pwsh -File "scripts/generate\_release\_body.ps1"



&nbsp;     - name: Update release notes with generated body

&nbsp;       env:

&nbsp;         GITHUB\_TOKEN: ${{ secrets.GITHUB\_TOKEN }}

&nbsp;       run: |

&nbsp;         gh release edit "${{ steps.create\_release.outputs.TAG }}" --notes-file "docs/faz-43/release\_body\_generated.md"



