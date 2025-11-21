MASTER CHECKLIST // PAYMENT-READY / LAUNCH-READY

Sürüm: v1 (FAZ-46 başlangıç)

Tarih: 2025-11-19 (TRT/UTC+3)

Repo: gw\_stack



Not:

\- Bu dosya, Payment-Ready (2026-01-01) ve Launch-Ready (2026-01-15) hedefleri için TEK kanonik checklist kaynağıdır.

\- Devir özetlerinde checklist kopyası tutulmaz; sadece bu dosyaya referans verilir.

\- Format:

&nbsp; - \[ ] boş → yapılmadı

&nbsp; - \[x] dolu → tamamlandı

&nbsp; - (C) → kritik (Payment-Ready için şart)

&nbsp; - (L) → Launch-Ready tarafında algı / pazarlama ağırlıklı



================================================

A) ÖDEME / GÜVENLİK / HATA YÖNETİMİ

================================================



\- \[ ] (C) Ödeme sağlayıcısı seçildi ve canlı / test ortamı hesapları açıldı.

\- \[ ] (C) Kartla ödeme akışı uçtan uca çalışıyor:

&nbsp;     - Kullanıcı kart bilgisi giriyor,

&nbsp;     - Ödeme sağlayıcısı yanıt veriyor,

&nbsp;     - Backend bu yanıtı doğru işliyor.

\- \[ ] (C) Başarılı ödeme sonrası:

&nbsp;     - Kullanıcıya anlamlı onay ekranı gösteriliyor,

&nbsp;     - Plan durumu backend’de “aktif” olarak kayıt altına alınıyor.

\- \[ ] (C) Başarısız ödeme / hata durumlarında:

&nbsp;     - Kullanıcıya net ve insan gibi hata mesajı veriliyor,

&nbsp;     - Hata log’lanıyor (en azından dosya / console / basit monitoring).

\- \[ ] (C) Ödeme webhook / callback (varsa):

&nbsp;     - İdempotent çalışacak şekilde kurgulandı (aynı event iki kez gelse bozmuyor).

\- \[ ] (C) Ödeme sırasında kritik veriler (kart numarası vb.):

&nbsp;     - Direkt sistemde saklanmıyor,

&nbsp;     - Ödeme sağlayıcının güvenli alanında tutuluyor (token ile çalışılıyor).

\- \[ ] (C) Ödeme akışı için minimal alarm mekanizması var:

&nbsp;     - Kritik hata durumunda e-posta veya başka bir kanalla sana haber geliyor.



================================================

B) ÜRÜN AKIŞI (LANDING → KAYIT → İLK BAŞARI)

================================================



\- \[ ] (C) Kayıt / giriş akışı:

&nbsp;     - Basit ve çalışır (kayıt → e-posta doğrulama gerekiyorsa açık bir mantık var).

\- \[ ] (C) Kullanıcı kayıt olup giriş yaptıktan sonra:

&nbsp;     - Boş bir ekran yerine yönlendiren bir “ilk ekran” görüyor.

\- \[ ] (C) Plan seçimi / upgrade ekranı:

&nbsp;     - Kullanıcı hangi planı seçtiğini net anlıyor.

\- \[ ] (C) Ödeme sonrası:

&nbsp;     - Kullanıcı ürün içinde “aktif” bir şey görebiliyor (panel, dashboard, ilk özellik).

\- \[ ] (C) İlk 10–30 dakika içinde:

&nbsp;     - Kullanıcı için net bir “ilk küçük başarı” akışı tanımlı

&nbsp;       (örnek: ilk proje oluşturma, ilk raporu görme, ilk entegrasyonu çalıştırma).

\- \[ ] (L) Basit bir mini-onboarding / walkthrough:

&nbsp;     - En azından ilk 2–3 adımda ne yapacağını anlatan kısa yönergeler var.



================================================

C) PLANLAR / FİYATLANDIRMA / TEKLİF

================================================



\- \[ ] (C) En az 1 net ana plan tanımlı:

&nbsp;     - Kimin için olduğu (persona),

&nbsp;     - Fiyatı,

&nbsp;     - Temel faydaları.

\- \[ ] (C) Fiyatlama metni:

&nbsp;     - Gizli masraf hissi yaratmıyor,

&nbsp;     - “Ne zaman ne kadar ödeyeceğim?” sorusuna net cevap veriyor.

\- \[ ] (C) Temel şartlar:

&nbsp;     - Yenileme, iptal, deneme süresi (varsa) sade bir dille açıklanmış durumda.

\- \[ ] (L) En az bir güçlü teklif cümlesi:

&nbsp;     - “X tipindeki kişi/ekip için Y problemini Z sürede çözüyoruz” net yazılmış.

\- \[ ] (L) İlk kampanya / erken erişim / indirim mantığı (opsiyonel ama değerli) belirlenmiş.



================================================

D) LANDING \& ALGILAMA (İLK İNTİBA)

================================================



\- \[ ] (C) Hero başlığı:

&nbsp;     - Ürünün ne yaptığı ve kimin için olduğu 1–2 cümlede net.

\- \[ ] (C) 3–5 maddelik fayda bölümü:

&nbsp;     - “Neyi kolaylaştırıyoruz / hızlandırıyoruz / riskini azaltıyoruz?” sorusuna cevap veriyor.

\- \[ ] (L) 1–2 kısa kullanım senaryosu:

&nbsp;     - Hedef kullanıcı kendini bu senaryoda görebiliyor.

\- \[ ] (L) Tasarım:

&nbsp;     - Font, renk, boşluk, ikon kullanımı tutarlı;

&nbsp;     - “Özensiz / amatör” hissi vermiyor.

\- \[ ] (L) CTA (Call to Action):

&nbsp;     - Sayfada 1 ana CTA var (örneğin “Ücretsiz dene” / “Erken erişim iste”),

&nbsp;     - Kullanıcıya “Sonraki adım nedir?” sorusunu sormuyor.

\- \[ ] (L) Pricing bölümüne landing’den ulaşım:

&nbsp;     - Kullanıcı 1–2 tıkla fiyatlama bilgisine erişebiliyor.



================================================

E) OPERASYONEL MİNİMUM (DESTEK, LOG, ÖLÇÜMLEME)

================================================



\- \[ ] (C) Destek kanalı:

&nbsp;     - En az bir adres (e-posta/form) net şekilde belirtilmiş;

&nbsp;     - Kullanıcı “sorunum olursa nereye yazarım?” diye kalmıyor.

\- \[ ] (C) Hata loglama:

&nbsp;     - Backend hataları asgari düzeyde kayıt altına alınıyor (dosya, SaaS tool veya benzeri).

\- \[ ] (C) Kritik iş akışları (kayıt, login, ödeme) için log’lardan geriye dönük iz sürebiliyorsun.

\- \[ ] (L) Basit analytics:

&nbsp;     - En azından ziyaret / kayıt metriğini göreceğin bir mekanizma var.

\- \[ ] (L) “İlk ödeme” gerçekleştiğinde:

&nbsp;     - Kimin, hangi planı, ne zaman aldığı; hangi kanal üzerinden geldiği işaretlenebiliyor.



================================================

KULLANIM NOTLARI

================================================



\- Payment-Ready (2026-01-01):

&nbsp; - (C) işaretli maddelerin tamamlanmış olması hedeflenir.

\- Launch-Ready (2026-01-15):

&nbsp; - (C) + öncelikli (L) maddelerin önemli bir kısmının tamamlanmış olması hedeflenir.

\- Her faz sonunda:

&nbsp; - Bu dosya güncellenecek,

&nbsp; - Devir özetleri, bu dosyayı referans gösterecek (kopyalamayacak).



