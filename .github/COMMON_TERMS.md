# DNN Türkçe Çeviri Kılavuzu

Bu kılavuz, DNN Platform Türkçe dil paketinde tutarlı bir dil kullanmak için hazırlanmıştır. Çeviriye katkıda bulunmadan önce lütfen okuyun.

## Hitap şekli: **Siz**

Kullanıcıya her zaman **siz** ile hitap ediyoruz (ör. *"Lütfen e-posta adresinizi girin"*). *Sen* formu kullanılmaz.

- Emir kipi: *girin*, *seçin*, *tıklayın* (*giriniz*, *seçiniz* değil)
- Düğmeler kısa ve fiil ile: *Kaydet*, *İptal*, *Sil*, *Güncelle*

## Yazım kuralları

- Etiketler ve başlıklarda her kelimenin ilk harfi büyük yazılır: *Site Ayarları*, *Yeni Kullanıcı Ekle*.
- Büyük harfe çevirirken Türkçe **İ / ı** kurallarına dikkat edin: *DİL*, *AYARLAR* (`DIL` değil).
- Yer tutuculara (`{0}`, `[User:DisplayName]`, `[Portal:PortalName]` vb.), HTML etiketlerine ve tokenlara **dokunmayın**; yalnızca sıralarını Türkçe cümle yapısına göre değiştirebilirsiniz.
- Değerlerin başındaki/sonundaki boşlukları ve `:` gibi noktalama işaretlerini İngilizce metindeki gibi koruyun.

## Standart terimler

en-US terim | *Teknik terim* | tr-TR çeviri | Açıklama
--- | --- | --- | ---
admin, administrator | | Yönetici | site yöneticisi
container | container | Konteyner | sayfadaki modül çerçevesi (tema/konteyner)
container (Azure, Google Tag Manager) | | Kapsayıcı | Microsoft ve Google'ın kendi Türkçe arayüzlerindeki terim; yalnızca Azure depolama ve GTM ekranlarında
edit bar | | Edit Bar | ürün adı, çevrilmez
extension | | Uzantı |
file / folder | | Dosya / Klasör |
language | | Dil |
login / logout | | Giriş Yap / Çıkış Yap |
module | | Modül |
page | tab | Sayfa |
persona bar | | Persona Bar | ürün adı, çevrilmez
profile | | Profil |
recycle bin | | Geri Dönüşüm Kutusu |
register | | Kayıt Ol |
role | | Rol |
scheduler | | Zamanlayıcı |
settings | | Ayarlar |
site | portal | Site |
site settings | portal settings | Site Ayarları |
superuser | host | Süper Kullanıcı | tüm sitelerin yöneticisi
template | | Şablon |
theme | skin | Tema |
user | | Kullanıcı |
workflow | | İş Akışı |

## Karar bekleyen terimler

Mevcut çevirilerde bu terimler için birden fazla karşılık kullanılıyor. Karar verildiğinde yukarıdaki tabloya taşıyın ve tüm dosyalarda eşitleyin.

en-US terim | Kullanılan karşılıklar | Not
--- | --- | ---
host | *Sunucu*, *Süper Kullanıcı (Host)* | DNN'de "host" bir kişi/rol (superuser) anlamındadır; *Host Settings* için *Sunucu Ayarları* kullanılıyor
journal / log | ikisi için de *Günlük* | *journal* (sosyal akış) ile *log* (kayıt) ayrıştırılmalı, ör. *journal* → *Akış*, *log* → *Günlük*
