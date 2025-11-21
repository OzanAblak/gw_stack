BILLING\_API ENTEGRASYON PLANI // FAZ-46

Tarih: 2025-11-19 (TRT/UTC+3)

Repo: gw\_stack



Amaç:

\- billing\_api (FastAPI) servisini ürünün geri kalanına (landing/planner/CI/DoD) nasıl bağlayacağımızı netleştirmek.

\- Payment-Ready hedefi için hangi adımların hangi fazda yapılacağını katmanlı olarak tanımlamak.



===========================================

1\) BİLEŞENLER VE ROLLER

===========================================



1.1) billing\_api (şu anki durum)

\- Konum:

&nbsp; - services/billing\_api/app.py

\- Teknoloji:

&nbsp; - Python + FastAPI

\- Durum:

&nbsp; - FAZ-46 kapsamında STUB seviyesinde:

&nbsp;   - GET /health

&nbsp;   - GET /api/billing/subscription

&nbsp;   - POST /api/billing/checkout/start

&nbsp;   - GET /api/billing/checkout/status



1.2) Diğer ana bileşenler

\- Landing / site:

&nbsp; - Kullanıcının plan seçtiği ve ödeme akışını başlattığı yüz.

\- Planner / ana uygulama:

&nbsp; - Asıl kullanım değeri (planlama fonksiyonları).

&nbsp; - Abonelik durumuna göre “ücretsiz / ücretli / kısıtlı erişim” karar noktası burada.

\- CI + DoD:

&nbsp; - release\_draft, site\_check, release\_stable vb.

&nbsp; - Kalite sinyallerini toplar:

&nbsp;   - Uygulama ayağa kalkıyor mu?

&nbsp;   - Billing API /health çalışıyor mu?

&nbsp;   - E2E testler payment senaryolarını doğruluyor mu?



===========================================

2\) ENTEGRASYON KATMANLARI (AŞAMALI)

===========================================



Bu plan, ödeme entegrasyonunu tek seferde değil, aşama aşama bağlamak için kullanılır.



2.1) Katman 0 — Stub \& İzole Test (FAZ-46)

\- Durum:

&nbsp; - Sadece billing\_api kendi başına çalışır.

&nbsp; - Swagger üzerinden manuel test yapılır.

\- Amaç:

&nbsp; - Domain + API contract + error codes + happy path netleşsin.

&nbsp; - Teknik borç: “henüz gerçek provider yok, henüz planner/landing entegrasyonu yok.”



2.2) Katman 1 — Landing → billing\_api köprüsü

\- Hedef:

&nbsp; - Landing üzerinde “plan seçimi + ödeme akışı başlat” butonları billing\_api’ye bağlansın.

\- Minimum iş:

&nbsp; - Landing tarafında config:

&nbsp;   - BILLING\_API\_BASE\_URL (ör: http://localhost:19100 veya prod için environment’tan).

&nbsp; - API çağrıları:

&nbsp;   - Plan seçimi ekranında:

&nbsp;     - POST /api/billing/checkout/start

&nbsp;   - Success/cancel sayfalarında:

&nbsp;     - GET /api/billing/checkout/status?paymentAttemptId=...

\- Görsel/Tasarım:

&nbsp; - “Ödeme sayfasına yönlendiriliyoruz” gibi net bir ara ekran.

&nbsp; - Başarılı / başarısız durumda test planındaki user-facing mesajlara yakın metinler.



2.3) Katman 2 — Planner → billing\_api abonelik denetimi

\- Hedef:

&nbsp; - Planner/ana uygulama, kullanıcının abonelik durumuna göre davranabilsin.

\- Minimum iş:

&nbsp; - Planner backend’inde (veya ilgili katmanda):

&nbsp;   - Kullanıcı isteği geldiğinde:

&nbsp;     - Kullanıcı kimliğinden subscription key/id çıkartma.

&nbsp;     - billing\_api üzerinden:

&nbsp;       - GET /api/billing/subscription

&nbsp;     - Gelen `status`’e göre karar:

&nbsp;       - `active` → tam erişim.

&nbsp;       - `incomplete` / `past\_due` → uyarı / kısıtlı erişim.

&nbsp;       - `SUBSCRIPTION\_NOT\_FOUND` → ücretsiz mod veya onboarding.

\- Önemli:

&nbsp; - Şimdiki stub mantığında subscription user’a bağlı değil;

&nbsp;   ileride bu noktada gerçek user-bazlı subscription implementasyonu devreye alınacak.



2.4) Katman 3 — CI / site\_check entegrasyonu

\- Hedef:

&nbsp; - CI’nin “billing\_api çalışıyor mu?” sorusuna net cevabı olsun.

\- Minimum iş:

&nbsp; - site\_check veya benzeri workflow’da:

&nbsp;   - billing\_api endpoint’ine istek:

&nbsp;     - GET /health

&nbsp;   - Beklenen:

&nbsp;     - 200 OK

&nbsp;     - body.status = "ok"

&nbsp;     - service = "billing\_api"

&nbsp; - DoD/CI status policy dokümanına:

&nbsp;   - “Billing API health OK değilse release geçilemez” benzeri bir kural eklenmesi (ileri faz).



2.5) Katman 4 — Gerçek ödeme sağlayıcısı adapter’i

\- Hedef:

&nbsp; - Şu anki stub’ları gerçek provider çağrıları ile değiştirmek.

\- Adımlar (ileri faz, özet):

&nbsp; - config/payment.example.env içinde:

&nbsp;   - PAYMENT\_PROVIDER\_API\_KEY

&nbsp;   - PAYMENT\_PROVIDER\_ENDPOINT

&nbsp;   - WEBHOOK\_SECRET

&nbsp;   vb. alanlar.

&nbsp; - billing\_api içinde:

&nbsp;   - Provider adapter katmanı:

&nbsp;     - Örn. services/billing\_api/provider\_adapter.py

&nbsp;     - Sorumluluk:

&nbsp;       - checkout oturumu oluşturmak,

&nbsp;       - durum sorgulamak,

&nbsp;       - webhook olaylarını parse etmek.

&nbsp; - Test:

&nbsp;   - Sağlayıcının test kartları ile Senaryo 1 ve 2’nin gerçekte de çalıştığını doğrulamak.



===========================================

3\) KISA VADELİ SOMUT GÖREVLER (FAZ-46 / FAZ-47)

===========================================



G-1) ENV ve config standardı (FAZ-46/47)

\- config/payment.example.env içinde:

&nbsp; - BILLING\_API\_BASE\_URL

&nbsp; - PAYMENT\_PROVIDER (şimdilik "stub" olarak kalabilir)

\- Amaç:

&nbsp; - Hem landing hem planner hem de test script’leri tek bir kaynaktan URL okusun.



G-2) Landing → billing\_api entegrasyon taslağı (FAZ-47)

\- Doküman:

&nbsp; - docs/faz-47/landing\_billing\_integration.md (ileride)

\- İçerik:

&nbsp; - Hangi sayfada hangi API çağrısı yapılacak?

&nbsp; - Hangi hata kodunda ne gösterilecek?

&nbsp; - Kullanıcı akışındaki ekran akışı (wireframe düzeyinde bile olsa).



G-3) site\_check → billing\_api health (FAZ-47)

\- YAML değişikliği:

&nbsp; - .github/workflows/site\_check.yml içinde:

&nbsp;   - billing\_api /health çağrısı eklenmesi (örn. curl veya küçük bir script).

\- Beklenen DoD katkısı:

&nbsp; - “Billing servis ayakta olmadan release yapmayız” sinyalinin CI’ye taşınması.



===========================================

4\) RİSKLER VE NOTLAR

===========================================



R-1) Aşırı erken entegrasyon riski

\- Çok erken aşamada landing/planner tarafını billing\_api stub’ına bağlamak:

&nbsp; - Değişen contract’lar nedeniyle sık kırılmaya yol açabilir.

\- Çözüm:

&nbsp; - FAZ-46’da contract’ları mümkün olduğunca sabitlemek,

&nbsp; - Sonra entegrasyona başlamak.



R-2) Kullanıcı deneyimi boşlukları

\- Sadece teknik entegrasyon yapmak yeterli değil:

&nbsp; - Kullanıcıya gösterilen hata mesajları (payment\_error\_codes.md),

&nbsp; - İlk ödeme akışındaki adımlar (payment\_flow\_happy\_path.md),

&nbsp; UI ile tutarlı olmalı.



R-3) Güvenlik ve uyumluluk

\- Gerçek provider’a geçerken:

&nbsp; - Kart bilgileri ASLA bizim sunuculardan geçmemeli (her şey provider tarafında).

&nbsp; - Log’larda hassas bilgi tutulmamalı.

\- Bunlar için ayrı bir “payment\_security\_notes.md” dokümanı ileride önerilir.



===========================================

5\) SONUÇ

===========================================



Bu entegrasyon planı ile:

\- billing\_api şu an:

&nbsp; - İzole çalışan bir stub servis ve

&nbsp; - Payment flow testleri için kontrollü bir sandbox.

\- İlerleyen fazlarda:

&nbsp; - Landing ve planner tarafı yavaş yavaş bu servise bağlanacak,

&nbsp; - CI/site\_check pipeline’ı billing\_api health sinyallerini DoD kapsamına dahil edecek,

&nbsp; - Gerçek payment provider adapter’i ile stub katmanı üretim seviyesine taşınacak.



Bu dosya:

\- FAZ-46 sonrası ödeme ile ilgili mimari kararların referans noktası olarak kullanılacaktır.



