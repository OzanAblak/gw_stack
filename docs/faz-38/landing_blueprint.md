\# GW Stack — Landing \& Ödeme Blueprint (FAZ-38 / GATE-4)



Tarih: 2025-11-15  

Faz: FAZ-38  

Gate: GATE-4 (Site / Landing / Ödeme Bloğu)



---



\## 1. Amaç



Bu dokümanın amacı:



\- GW Stack için \*\*tek sayfalık (single-page)\*\*, sade ama net bir landing yapısının çerçevesini çizmek.

\- İlk aşamada:

&nbsp; - Ürünü anlatan basit bir arayüz,

&nbsp; - Erken erişim / kayıt / iletişim toplama,

&nbsp; - Minimum düzeyde \*\*gerçek ödeme\*\* alma (Stripe vb.) akışının planını netleştirmek.

\- Teknik uygulamaya geçildiğinde, CI zinciriyle uyumlu bir şekilde:

&nbsp; - `/site` veya benzeri bir klasörden build alıp,

&nbsp; - İleride otomatik deployment’a bağlanabilecek bir yapı hedeflenir.



Bu doküman \*\*GATE-4.1 (Blueprint)\*\* için “oldu” sayılma kriteridir.



---



\## 2. Hedef Kitle ve Temel Mesaj



\### 2.1 Hedef Kitle (ilk aşama)



\- Teknik tarafta karar veren veya uygulayan kişiler:

&nbsp; - Yazılım geliştiriciler,

&nbsp; - Teknik liderler,

&nbsp; - Küçük/mikro ekiplerin kurucuları.



Bu kişiler için GW Stack:



\- “Teknik işleri daha öngörülebilir, tekrarlanabilir ve izlenebilir hale getiren,

\- CI ve çalışma akışlarını disipline eden,

\- Planlama ve yürütmeyi birbirine bağlayan”

bir arka uç/fonksiyon seti olarak konumlanır.



(Bu metinler ileride gerçek ürün konumlandırmasına göre revize edilebilir; burada amaç iskeleti oluşturmak.)



\### 2.2 Çekirdek Mesaj



\- Problemi özetleyen mesaj:

&nbsp; - “Dağınık CI, belirsiz deploy kuralları ve rastgele süreçler hem zaman hem güven kaybettiriyor.”

\- Çözüm mesajı:

&nbsp; - “GW Stack, CI zincirini, teknik DoD’u ve iş hedeflerini tek bir disiplinli akışta toplar. Hangi değişikliğin ne zaman ‘yayına hazır’ olduğunu net olarak görürsün.”

\- Ana CTA (Call to Action):

&nbsp; - “Erken erişim başvurusu yap”  

&nbsp; - Alternatif veya ek:

&nbsp;   - “Demo iste”

&nbsp;   - “Ön kayıt”



---



\## 3. Sayfa Yapısı (Landing Taslak İskeleti)



Sayfa tek sütunlu, mobil uyumlu, sade bir yapı olarak düşünülür.



\### 3.1 Bölüm 1 — Hero (Üst Kısım)



\- Elemanlar:

&nbsp; - Kısa ana başlık (H1):

&nbsp;   - Örnek taslak: “GW Stack ile CI zincirini kontrol altına al.”

&nbsp; - Destekleyici alt başlık:

&nbsp;   - “Smoketest’ten release’e kadar her adımı görünür ve tekrarlanabilir hale getir.”

&nbsp; - Birincil buton (primary CTA):

&nbsp;   - “Erken erişim başvurusu yap”

&nbsp; - İkincil CTA (opsiyonel):

&nbsp;   - “Teknik detayları incele” (sayfa içi anchor)



\- Hedef:

&nbsp; - Ziyaretçi ilk 5–10 saniyede:

&nbsp;   - Ne olduğumuzu,

&nbsp;   - Kime hitap ettiğimizi,

&nbsp;   - Ne yapmasını istediğimizi anlamalı.



\### 3.2 Bölüm 2 — Problem (Neden Varız?)



\- 3–4 maddelik problem listesi:

&nbsp; - Örneğin:

&nbsp;   - “CI pipeline’lar karışık; kimse hangi koşulda release yapılacağını net bilmiyor.”

&nbsp;   - “DoD kağıt üzerinde, kodda değil.”

&nbsp;   - “Her deploy öncesi ayrı bir kaos toplantısı gerekiyor.”

\- Hedef:

&nbsp; - Okuyan kişi “evet, bizde de böyle” diyebilsin.



\### 3.3 Bölüm 3 — Çözüm (Ne Sunuyoruz?)



\- 3–4 maddelik çözüm listesi:

&nbsp; - “DoD’u CI zincirinin bir parçası haline getirir.”

&nbsp; - “Her smoke run için otomatik DoD ve artefakt üretir.”

&nbsp; - “Release’lerin yanında teknik kanıtları (DoD/ci) asset olarak saklar.”

\- Basit bir görsel/diagram için placeholder:

&nbsp; - “GW Stack akış diyagramı” (ileride görselleştirilecek).



\### 3.4 Bölüm 4 — Nasıl Çalışır? (3 Adım)



\- 3 adımlı mini süreç:

&nbsp; 1. “Repo’nu bağla ve GW Stack CI şablonlarını ekle.”

&nbsp; 2. “DoD ve gate kurallarını tanımla (smoke, post\_smoke, release).”

&nbsp; 3. “Her deploy öncesi tek bakışta neyin hazır olduğunu gör.”



\- Teknik detaylar bu bölümde basit tutulur; derin teknik doküman linki alt bölümde olur.



\### 3.5 Bölüm 5 — Özellikler (Feature Listesi)



\- Bullet list:

&nbsp; - “Deterministik CI artefaktları”

&nbsp; - “Release başına otomatik DoD dosyası”

&nbsp; - “Teknik log ve karar izlenebilirliği”

&nbsp; - “Basit entegrasyon (GitHub Actions odaklı başlangıç)”

\- İleride kategori bazlı ayrılabilir (Core / Advanced / Enterprise vb.).



\### 3.6 Bölüm 6 — Kimler İçin?



\- 2–3 persona:

&nbsp; - “Küçük ürün takımları (2–10 kişi)”

&nbsp; - “Side-project’ini ciddiye alan geliştiriciler”

&nbsp; - “Start-up teknik kurucuları”



\- Her persona için 1 cümlelik değer önerisi.



\### 3.7 Bölüm 7 — Fiyatlandırma Taslağı (İlk Aşama)



\- Çok basit bir modelle başlamak:

&nbsp; - Örneğin:

&nbsp;   - “Beta / Erken Erişim Planı”

&nbsp;     - Aylık sabit ücret (örnek: $X)

&nbsp;     - Sınırlı kullanıcı/servis sayısı

&nbsp; - “Erken kayıtlar için indirim / founding user” mesajı.



\- Bu aşamada:

&nbsp; - Fiyatlar kesin olmayabilir.

&nbsp; - Önemli olan sayfada net bir “para karşılığı değer” algısı yaratmak.



\### 3.8 Bölüm 8 — SSS (FAQ) Taslağı



\- 3–5 soru:

&nbsp; - “GW Stack tam olarak ne yapıyor?”

&nbsp; - “Hangi CI ortamlarını destekliyorsunuz?”

&nbsp; - “Şu an beta mı, production mı?”

&nbsp; - “Verilerim nerede tutuluyor?”

&nbsp; - “Fiyatlandırma nasıl işleyecek?”



\### 3.9 Bölüm 9 — Footer



\- İçerik:

&nbsp; - İletişim e-posta adresi,

&nbsp; - Sosyal hesaplar (varsa),

&nbsp; - Gizlilik / KVKK / Terms linkleri için placeholders.



---



\## 4. Ödeme Akışı (Stripe vb. — Minimum Viable)



Bu bölüm, FAZ-38 + Aralık ayı boyunca hayata geçecek minimum çözümün çerçevesidir.



\### 4.1 İlk Aşama: En Basit Çözüm



\- Hedef:

&nbsp; - “Gerçek” ödeme alabilir hale gelmek,

&nbsp; - Arka planda tam otomatik kullanıcı onboarding olmasa da:

&nbsp;   - Ödeme sonrası manuel onboarding mümkün olsun.



\- Önerilen başlangıç:

&nbsp; 1. Stripe hesabı aç.

&nbsp; 2. Tek bir “GW Stack Early Access” ürünü oluştur.

&nbsp; 3. Bu ürün için tek bir fiyat planı (ör. aylık) tanımla.

&nbsp; 4. Stripe dashboard üzerinden “Payment Link” veya “Hosted Checkout” linki üret.

&nbsp; 5. Landing’deki “Satın al” veya “Erken erişim satın al” butonunu bu linke yönlendir.



\- Bu sayede:

&nbsp; - Arka uç entegrasyonu (webhook, müşteri portalı vb.) ileride gelse bile,

&nbsp; - İlk gelir alma kapasitesi kısa sürede oluşur.



\### 4.2 İkinci Aşama: Basit Backend Entegrasyonu (İleriki Fazlar İçin)



\- Stripe webhook ile:

&nbsp; - Ödeme tamamlandığında:

&nbsp;   - E-posta göndermek,

&nbsp;   - Basit bir “müşteri listesi” dosyası/DB tutmak,

&nbsp;   - Manuel onboarding adımlarını tetiklemek.

\- Bu entegrasyonun teknik detayları ayrı bir fazda (ör. FAZ-40+) planlanabilir.



---



\## 5. Teknik Uygulama Planı (Kısa Vadeli)



Bu kısım GATE-4 için “ne zaman ne yapılacak” özetidir.



\### 5.1 GATE-4.1 — Blueprint (BU DOKÜMAN)



\- Kabul kriteri:

&nbsp; - Bu doküman repo içinde bir dosya olarak kaydedildi (ör: `docs/faz-38/landing\_blueprint.md`).

&nbsp; - İçerik:

&nbsp;   - Landing sayfa iskeleti,

&nbsp;   - Ödeme akışı minimum planı,

&nbsp;   - Hedef kitle ve mesaj taslağı.



\### 5.2 GATE-4.2 — Basit Static Landing (Lokal)



\- Yapılacaklar:

&nbsp; - Repo içinde `/site` veya `/landing` gibi bir klasör oluşturmak.

&nbsp; - Orada:

&nbsp;   - Tek HTML dosyası,

&nbsp;   - Basit CSS (tercihen ayrı dosya),

&nbsp;   - JS minimal veya hiç JS ile:

&nbsp;     - Bu blueprint’teki bölümleri temsil eden bir prototip sayfa.



\- Kabul kriteri:

&nbsp; - `index.html` içinde bölüm başlıkları ve placeholder metinler var.

&nbsp; - Lokal tarayıcıda açıldığında mobilde de okunabilir.



\### 5.3 GATE-4.3 — CI Entegrasyonu (Build/Check)



\- Yapılacaklar:

&nbsp; - Mevcut CI zincirine:

&nbsp;   - Basit bir “site check” job’ı eklemek (ör. HTML lint veya sadece `npm run build` yoksa dahi `ls` kontrollü basit bir step).

&nbsp; - Bu job, smoke veya ayrı bir workflow’da olabilir.



\- Kabul kriteri:

&nbsp; - CI, site klasörünün varlığını ve minimum düzeyde derlenebilirliğini/okunabilirliğini doğruluyor.



\### 5.4 GATE-4.4 — Stripe Link Entegrasyonu



\- Yapılacaklar:

&nbsp; - Stripe tarafında ürün ve fiyat planı oluşturmak.

&nbsp; - Payment link/checkout URL almak.

&nbsp; - Landing’de CTA butonunu bu URL’ye bağlamak.



\- Kabul kriteri:

&nbsp; - Sayfadaki “Satın al” butonu gerçek bir Stripe hosted checkout ekranına yönlendiriyor.

&nbsp; - Ödeme tamamlandığında Stripe dashboard’dan ödeme kaydı görülebiliyor.



---



\## 6. Riskler ve Notlar



\- Risk 1 — Fazla teknik detaya takılıp landing’i geciktirmek:

&nbsp; - Çözüm: İlk sürüm sadece statik HTML/CSS olsun, JS/animasyon vb. daha sonra.

\- Risk 2 — Ödeme entegrasyonunu aşırı karmaşık düşünmek:

&nbsp; - Çözüm: İlk aşamada sadece Stripe hosted checkout + payment link; webhook/otomasyon ileride.

\- Risk 3 — Mesajın belirsiz kalması:

&nbsp; - Çözüm: İlk versiyonda bile “kime, ne sunuyoruz, ne karşılığında” sorularına net cevap vermek; metinleri sık sık revize etmek.



---



Bu doküman, FAZ-38 / GATE-4 kapsamında GW Stack için landing + ödeme bloğunun çerçeve taslağıdır.  

Uygulama adımları (HTML/CSS, Stripe konfigürasyonu, CI entegrasyonu) sonraki fazlarda bu blueprint referans alınarak yapılacaktır.



