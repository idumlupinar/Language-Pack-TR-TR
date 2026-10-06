[English](readme.md) | **Türkçe**

# DNN Platform Türkçe Dil Paketi (tr-TR)

[DNN Platform](https://github.com/dnnsoftware/Dnn.Platform) için Türkçe (Türkiye) dil paketi.

Mevcut sürümler:
* DNN Platform 10.04.00

## Kurulum

[Releases](../../releases) sayfasından en güncel `Dnn_Platform_Language-Pack-TR-TR_<sürüm>.zip` dosyasını indirin ve
DNN Platform'da **Persona Bar > Settings > Extensions > Install Extension** üzerinden yükleyin.

## Nasıl katkıda bulunabilirsiniz?

**Önemli:** Çeviriye başlamadan önce lütfen [Türkçe çeviri kılavuzunu](.github/COMMON_TERMS.md) okuyun.

Bir GitHub hesabınızın olması yeterlidir. Tüm katkılar **develop** dalına Pull Request olarak gönderilir.

### Kısa yol (tarayıcıdan)

1. Bu depoyu kendi hesabınıza fork edin.
2. Düzeltmek istediğiniz `.tr-TR.resx` dosyasını GitHub üzerinde düzenleyin.
3. **develop** dalına bir Pull Request açın.

### Çalışan bir DNN Platform sitesiyle

1. Depoyu fork edip bilgisayarınıza klonlayın.
2. Çevirileri DNN Platform içinde (**Settings > Site Settings > Languages**) yapın veya düzeltin.
3. Dosyaları siteden depoya kopyalayın ve manifesti güncelleyin:

   ```powershell
   .\tools\Sync-FromSite.ps1 -SitePath C:\path\to\dnn-platform-site
   .\tools\Build-Manifest.ps1
   ```

4. Değişiklikleri commit edip **develop** dalına Pull Request açın.

`Build-Manifest.ps1`, `Resources\DNNCE_tr-TR.dnn` manifestini depodaki dosyalardan yeniden oluşturur. Her Pull Request'te
`Build-Manifest.ps1 -Check` otomatik olarak çalışır; geçersiz XML veya güncel olmayan bir manifest varsa kontrol başarısız olur.

> Windows'ta bazı dosya yolları 260 karakteri aşabilir. Klonlama hatası alırsanız: `git config --global core.longpaths true`

Depo yapısı ve yeni sürüm yayınlama adımları için [İngilizce README](readme.md) dosyasına bakın.

## Lisans

[MIT](LICENSE)
