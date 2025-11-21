DOD / CI STATUS POLICY // FAZ-46

Tarih: 2025-11-19 (TRT/UTC+3)

Repo: gw\_stack



Amaç:

\- `DOD\_STATUS` ve `CI\_PIPELINE\_STATUS` alanlarının:

&nbsp; - Alabileceği değerleri,

&nbsp; - Bu değerlerin nasıl üretileceğini,

&nbsp; - Payment-Ready (2026-01-01) ve Launch-Ready (2026-01-15) hedefleriyle ilişkisini tanımlamak.



Bu doküman:

\- scripts/generate\_release\_body.ps1

\- scripts/resolve\_ci\_meta.ps1

\- ci\_artifacts/\*

ile birlikte düşünülmelidir.



================================================

1\) DOD\_STATUS POLİTİKASI

================================================



1.1 DOD\_STATUS neyi temsil eder?

--------------------------------

\- `DOD\_STATUS`:

&nbsp; - İlgili release için "Definition of Done" çerçevesinde:

&nbsp;   - Hangi seviyede tamamlandığını,

&nbsp;   - Hangi noktada risk kaldığını

&nbsp; özetleyen tek alan.



\- Kaynaklar:

&nbsp; - `ci\_artifacts/DoD.txt` içeriği

&nbsp; - Env / pipeline vars

&nbsp; - Script içi türetme mantığı (`generate\_release\_body.ps1`)



1.2 Olası değerler

-------------------



Önerilen DOD\_STATUS değer kümesi:



\- `PASS`

&nbsp; - Tanım:

&nbsp;   - O release için belirlenmiş DoD maddelerinin büyük çoğunluğu karşılanmış,

&nbsp;   - Kalanlar "kritik olmayan, sonraki releaselerde ele alınacak iyileştirmeler".

&nbsp; - Kullanım:

&nbsp;   - Normal, sağlıklı release.



\- `PARTIAL`

&nbsp; - Tanım:

&nbsp;   - Bazı önemli maddeler tamamlanmış olsa da:

&nbsp;     - Belirgin eksikler,

&nbsp;     - Bilerek ertelenmiş ama "farkında olunması gereken" kalemler var.

&nbsp; - Kullanım:

&nbsp;   - Controlled risk:

&nbsp;     - Örn. "Ödeme akışı hazır, fakat bazı non-critical UX iyileştirmeleri sonraki faza bırakıldı."



\- `FAIL`

&nbsp; - Tanım:

&nbsp;   - DoD çerçevesine göre bu release'in:

&nbsp;     - Kritik bir açığı var

&nbsp;     - veya "normal şartlarda prod’a gönderilmemeliydi".

&nbsp; - Kullanım:

&nbsp;   - Release body’de çok net uyarı sinyali olmalı.

&nbsp;   - Prod’a göndermemek veya çok sınırlı kitlede test etmek için kullanılır.



\- `UNKNOWN`

&nbsp; - Tanım:

&nbsp;   - DoD bilgisi yok veya okunamıyor:

&nbsp;     - `DoD.txt` artefaktı üretilmemiş,

&nbsp;     - Script bu bilgiyi işleyememiş,

&nbsp;     - Manuel olarak işaretlenmemiş.

&nbsp; - Kullanım:

&nbsp;   - Geçiş sürecinde ya da pipeline henüz bu bilgiyi üretmiyorsa.

&nbsp;   - Uzun vadede “normal” bir durum olmamalı.



1.3 Öncelik sıralaması

----------------------



Birden fazla sinyal / kaynak varsa, `DOD\_STATUS` için öncelik:



1\) Eğer manual override (ileri fazlarda gelir) varsa:

&nbsp;  - Manual değer > diğer tüm kaynaklar.



2\) Aksi halde:

&nbsp;  - Kaynaklardan gelen sinyallere göre:

&nbsp;    - `FAIL` > `PARTIAL` > `PASS` > `UNKNOWN`



Örnek:

\- Eğer DoD.txt içinde hem "kritik bug bilerek ertelendi" bilgisi hem de diğer birçok PASS sinyali varsa:

&nbsp; - `DOD\_STATUS=PARTIAL` seçilebilir.

\- Eğer pipeline çöküyorsa veya kritik test setleri hiç koşmamışsa:

&nbsp; - `DOD\_STATUS=FAIL` tercih edilir.



1.4 Payment-Ready / Launch-Ready ile ilişkisi

---------------------------------------------



\- Payment-Ready (2026-01-01) için:

&nbsp; - Hedef:

&nbsp;   - `DOD\_STATUS` en azından `PASS` veya kontrollü bir `PARTIAL` olmalı.

&nbsp; - "Kontrollü PARTIAL" örneği:

&nbsp;   - Ödeme akışı + güvenlik tamam,

&nbsp;   - Sadece bazı kozmetik / UX eksikleri sonraki release’e bırakılmış.



\- Launch-Ready (2026-01-15) için:

&nbsp; - Hedef:

&nbsp;   - Para almaya hazır durumdan:

&nbsp;     - UX / algı / onboarding tarafında da tatmin edici seviyeye gelinmiş olmalı.

&nbsp;   - İdeal:

&nbsp;     - `DOD\_STATUS=PASS`.

&nbsp;   - `PARTIAL` ancak çok net açıklanmış “bilinçli trade-off” durumlarında kabul edilebilir.



================================================

2\) CI\_PIPELINE\_STATUS POLİTİKASI

================================================



2.1 CI\_PIPELINE\_STATUS neyi temsil eder?

----------------------------------------

\- `CI\_PIPELINE\_STATUS`:

&nbsp; - İlgili release öncesinde:

&nbsp;   - Hangi CI iş akışlarının koştuğunu,

&nbsp;   - Bunların genel durumunu

&nbsp; özetleyen insan okunur bir string.



\- Kaynaklar:

&nbsp; - `resolve\_ci\_meta.ps1` çıktıları:

&nbsp;   - `SMOKE\_STATUS`, `POST\_SMOKE\_STATUS`, `SITE\_CHECK\_STATUS` vb.

&nbsp; - Env:

&nbsp;   - `RELEASE\_DRAFT\_STATUS` vb.



2.2 Önerilen örnek değerler

---------------------------



Temel değer örnekleri:



\- `ALL PASS`

&nbsp; - Tanım:

&nbsp;   - smoke, post\_smoke, site\_check (ve varsa diğer kritik pipeline’lar) başarıyla tamamlanmış.

\- `SMOKE+POST\_SMOKE PASS, SITE\_CHECK SKIPPED`

\- `SMOKE PASS, POST\_SMOKE FAIL`

\- `PIPELINE DEGRADED`

&nbsp; - Örn.:

&nbsp;   - Bazı kritik olmayan iş akışları başarısız / atlanmış fakat bilinçli şekilde prod’a gidilmiş.

\- `PIPELINE UNKNOWN`

&nbsp; - Pipeline meta bilgisi alınamamış veya eksik.



2.3 Üretim mantığı (özet)

-------------------------



Script mantığı (yüksek seviye):



\- Varsayılan (fallback):

&nbsp; - `CI\_PIPELINE\_STATUS=UNKNOWN`

\- Eğer:

&nbsp; - `SMOKE\_STATUS=success`

&nbsp; - `POST\_SMOKE\_STATUS=success`

&nbsp; - `SITE\_CHECK\_STATUS` success veya bilinçli skipped

&nbsp; ise:

&nbsp; - `CI\_PIPELINE\_STATUS=ALL PASS`



\- Eğer karışık durumlar varsa:

&nbsp; - Örn.:

&nbsp;   - `SMOKE\_STATUS=success`

&nbsp;   - `POST\_SMOKE\_STATUS=failure`

&nbsp; ise:

&nbsp; - `CI\_PIPELINE\_STATUS=SMOKE PASS, POST\_SMOKE FAIL`



Gelecekte:

\- Bu mantık `dod\_ci\_status\_policy.md` referans alınarak `generate\_release\_body.ps1` içinde sade ama tutarlı şekilde uygulanır.



2.4 Payment-Ready / Launch-Ready ile ilişkisi

---------------------------------------------



\- Payment-Ready için:

&nbsp; - Minimum beklenti:

&nbsp;   - Smoke ve post\_smoke PASS.

&nbsp; - Site\_check:

&nbsp;   - En azından “bilinçli şekilde SKIPPED değilse” PASS olması hedeflenir.

&nbsp; - Dolayısıyla:

&nbsp;   - İdeal string: `ALL PASS`

&nbsp;   - Kabul edilebilir string (erken dönemde):

&nbsp;     - `SMOKE+POST\_SMOKE PASS, SITE\_CHECK SKIPPED` gibi.



\- Launch-Ready için:

&nbsp; - Hedef:

&nbsp;   - `CI\_PIPELINE\_STATUS=ALL PASS` seviyesini standart hale getirmek.

&nbsp; - Özellikle ilk gerçek müşterilerin sisteme girdiği dönemde:

&nbsp;   - Pipeline sinyalinin güven verici olması kritik.



================================================

3\) DOD\_STATUS ve CI\_PIPELINE\_STATUS ARASINDAKİ İLİŞKİ

================================================



Özet ilişki:



\- `CI\_PIPELINE\_STATUS`:

&nbsp; - “Testler ve pipeline dünyası nasıl durumda?” sorusuna cevap verir.

\- `DOD\_STATUS`:

&nbsp; - “Bu release, Feature + UX + risk yönetimi anlamında ne kadar tamam?” sorusuna cevap verir.



Ana prensipler:



1\) `CI\_PIPELINE\_STATUS=ALL PASS` olsa bile:

&nbsp;  - Eğer büyük, bilinen, çözülememiş bir ürün riski varsa:

&nbsp;    - `DOD\_STATUS` rahatlıkla `PARTIAL` veya `FAIL` olabilir.



2\) `CI\_PIPELINE\_STATUS` karışık veya UNKNOWN olsa bile:

&nbsp;  - Testlerin pipeline dışında manuel koşturulduğu, geçici durumlar olabilir.

&nbsp;  - Bu durumda:

&nbsp;    - DOD.txt içindeki açıklamalar belirleyici olur.



3\) Payment-Ready için kombinasyon hedefi:

&nbsp;  - İdeal:

&nbsp;    - `CI\_PIPELINE\_STATUS=ALL PASS`

&nbsp;    - `DOD\_STATUS=PASS`

&nbsp;  - Erken dönemde kabul edilebilir (kontrollü risk):

&nbsp;    - `CI\_PIPELINE\_STATUS=SMOKE+POST\_SMOKE PASS, SITE\_CHECK SKIPPED`

&nbsp;    - `DOD\_STATUS=PARTIAL`

&nbsp;    - ve DOD.txt / release body içinde bu durumun açıkça anlatılması.



================================================

4\) UYGULAMA NOTLARI (FAZ-46 VE SONRASI)

================================================



\- FAZ-46:

&nbsp; - Bu doküman sadece politika ve taslak üretir.

&nbsp; - Script’lerdeki mantık, bu politika ile karşılaştırılarak sadeleştirilecek / netleştirilecek.



\- FAZ-47+:

&nbsp; - `generate\_release\_body.ps1` içinde:

&nbsp;   - `DOD\_STATUS` ve `CI\_PIPELINE\_STATUS` üretimi bu politika ile bire bir uyumlu hale getirilecek.

&nbsp; - Gerekirse:

&nbsp;   - `ci\_artifacts/DoD.txt` formatı standardize edilecek (örn. basit key/value veya markdown blokları).



\- Devir özetleri:

&nbsp; - Her faz sonunda:

&nbsp;   - Önemli release’ler için:

&nbsp;     - DOD\_STATUS ve CI\_PIPELINE\_STATUS değerleri örnek olarak yazılacak,

&nbsp;     - Kritik sapmalar özellikle not edilecek.



Bu doküman, DOD ve CI status sinyallerini okurken “tek referans” olarak kullanılacaktır.



