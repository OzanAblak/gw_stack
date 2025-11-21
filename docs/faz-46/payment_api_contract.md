PAYMENT API CONTRACT // FAZ-46

Tarih: 2025-11-19 (TRT/UTC+3)

Repo: gw\_stack



Amaç:

\- Payment-Ready hedefi için backend ↔ frontend arayüzünü netleştirmek.

\- Abonelik ve ödeme akışı için kullanılacak HTTP endpoint’leri, request/response formatlarını ve status haritasını tanımlamak.

\- Bu doküman, gerçek implementasyon sırasında referans alınacak API sözleşmesidir.



Not:

\- Buradaki path ve JSON şemaları örnek, ama ana fikir şu:

&nbsp; - Endpoint sayısı minimum,

&nbsp; - Anlamları net,

&nbsp; - Payment domain modeli (SUBSCRIPTION + PAYMENT\_ATTEMPT) ile uyumlu.



================================================

1\) GENEL PRENSİPLER

================================================



\- Base path (öneri):

&nbsp; - `/api/billing` (veya benzeri tek bir kök path).

\- Auth:

&nbsp; - Tüm endpoint’ler authenticated kullanıcı üzerinden çalışır (token / session vb.).

&nbsp; - Kullanıcıyı kimliklendiren mekanizma bu dokümanın kapsamı dışında.



\- Genel hata formatı (öneri):



```json

{

&nbsp; "code": "string",          // örn. "PAYMENT\_FAILED", "SUBSCRIPTION\_NOT\_FOUND"

&nbsp; "message": "string",       // kullanıcıya gösterilebilir sade mesaj

&nbsp; "details": "string|null"   // opsiyonel, teknik detay (frontend'de gösterilmeyebilir)

}



