[English](CONTRIBUTING.md) | **Türkçe**

# tr-TR dil paketine katkıda bulunma

DNN Platform'un Türkçe çevirisini geliştirmeye yardım ettiğiniz için teşekkürler! Bir GitHub hesabınızın olması yeterlidir.

- [Başlamadan önce](#başlamadan-önce)
- [Sorun bildirme](#sorun-bildirme)
- [Tarayıcıdan hızlı düzeltme](#tarayıcıdan-hızlı-düzeltme)
- [Çalışan bir DNN Platform sitesiyle](#çalışan-bir-dnn-platform-sitesiyle)
- [Pull Request kontrol listesi](#pull-request-kontrol-listesi)
- [Depo yapısı](#depo-yapısı)

## Başlamadan önce

- [Türkçe çeviri kılavuzunu](COMMON_TERMS.md) okuyun. Hitap şekli (*siz*), yazım kuralları ve paket genelinde
  kullanılan standart terimler burada tanımlanmıştır.
- Tüm katkılar **develop** dalına Pull Request olarak gönderilir.

## Sorun bildirme

Dosyaları kendiniz düzenlemek istemiyorsanız [yeni bir kayıt açın](https://github.com/idumlupinar/Language-Pack-TR-TR/issues/new/choose)
ve uygun formu seçin: **Translation issue** (çeviri hatası), **Bug report** (hata bildirimi) veya **Enhancement**
(iyileştirme önerisi). İngilizce arayüzde de görülen hatalar
[DNN Platform deposuna](https://github.com/dnnsoftware/Dnn.Platform/issues) bildirilmelidir.

## Tarayıcıdan hızlı düzeltme

Birkaç metni düzeltmek için en kolay yol.

1. Bu depoyu kendi hesabınıza fork edin.
2. Düzeltmek istediğiniz `.tr-TR.resx` dosyasını açıp GitHub üzerinde düzenleyin. Yalnızca `<value>` öğelerinin
   içindeki metni değiştirin; `{0}` veya `[User:DisplayName]` gibi yer tutucuları ve HTML etiketlerini olduğu gibi bırakın.
3. **develop** dalına bir Pull Request açın.

Bir metnin hangi dosyada olduğunu bilmiyor musunuz? Depoda mevcut Türkçe metni arayın.

## Çalışan bir DNN Platform sitesiyle

Çevirileri yerinde gördüğünüz için daha kapsamlı değişikliklere uygundur.

1. Depoyu fork edip bilgisayarınıza klonlayın.

   > Windows'ta bazı dosya yolları 260 karakteri aşabilir. Klonlama hatası alırsanız
   > `git config --global core.longpaths true` komutunu çalıştırıp yeniden klonlayın.

2. Çevirileri DNN Platform'da **Settings > Site Settings > Languages** altında yapın veya düzeltin.
3. Dosyaları siteden depoya kopyalayın ve manifesti güncelleyin:

   ```powershell
   .\tools\Sync-FromSite.ps1 -SitePath C:\path\to\dnn-platform-site
   .\tools\Build-Manifest.ps1
   ```

   `Sync-FromSite.ps1`, sitedeki tüm `*.tr-TR.resx` dosyalarını kopyalar; `Portals\<id>\` altındaki siteye özel
   değişiklikleri atlar. Sitede artık bulunmayan dosyaları da silmek için `-Mirror` ekleyin.

4. Değişiklikleri gözden geçirin (`git diff`), commit edin ve **develop** dalına bir Pull Request açın.

## Pull Request kontrol listesi

- [ ] Çeviri, [çeviri kılavuzuna](COMMON_TERMS.md) uygun.
- [ ] Değiştirilen değerlerdeki yer tutucular, tokenlar ve HTML değişmedi.
- [ ] `.resx` dosyası eklediyseniz veya sildiyseniz `tools\Build-Manifest.ps1` komutunu çalıştırıp güncellenen
      manifesti commit ettiniz.

Her Pull Request'te **Validate** kontrolü (`tools/Build-Manifest.ps1 -Check`) çalışır. Geçersiz XML veya güncel
olmayan bir manifest varsa başarısız olur; ayrıntıları görmek için aynı komutu kendi bilgisayarınızda çalıştırın.

## Depo yapısı

Yol | Amaç
--- | ---
`Resources/` | Kurulum paketinin içeriği; DNN Platform sitesinin klasör yapısıyla aynıdır
`Resources/DNNCE_tr-TR.dnn` | Paket manifesti; `tools/Build-Manifest.ps1` ile oluşturulur, elle düzenlemeyin
`Resources/ReleaseNotes.txt` | Kurulum sırasında gösterilen sürüm notları
`tools/Sync-FromSite.ps1` | Çalışan bir DNN Platform sitesindeki `*.tr-TR.resx` dosyalarını `Resources/` klasörüne kopyalar
`tools/Build-Manifest.ps1` | Manifesti oluşturur; `-Check` ile doğrular (CI tarafından kullanılır)
`.github/COMMON_TERMS.md` | Türkçe çeviri kılavuzu
`.github/RELEASING.md` | Sürüm yayınlama süreci, bakımcılar için (İngilizce)

`tools/Build-Manifest.ps1` içindeki `$PackageMap` listesinde olmayan uzantıların yeni kaynak dosyaları çekirdek pakete
eklenir. Yeni bir DNN Platform uzantısı kendi kaynak dosyalarıyla geldiğinde buraya bir eşleme ekleyin.
