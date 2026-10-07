# JESB Lot 2 inceleme raporu

Tarih: 6 Ekim 2026

Modelin genel cephe ve çatı düzeni çizimlere yakın; ancak tam koordinasyon sağlanmış değil. Öncelikle duvar sınırları ve saçak referansı, ardından arazi ve kot ilişkisi çözülmeli. Bu konular netleşmeden modelden kesin metraj veya uygulama ölçüsü alınması önerilmez.

## Kapsam ve kaynaklar

- DWG: `C:/Projects/JESB/LOT2/Lot 2 _revisions1.dwg`
- SketchUp: `C:/Projects/JESB/LOT2/JESB_Lot2_v3.skp`
- Destekleyici PDF: `C:/Projects/JESB/LOT2/Lot 2_revision1.pdf` (11 pafta, 5 Ekim 2026 revizyonu).
- Mevcut model görselleri: `LOT2/exports_v3` içindeki cepheler ve perspektif.

DWG kopyası AutoCAD ile DXF formatına aktarılarak okunmuş, SKP kopyası SketchUp Ruby API ile incelenmiştir. Mevcut dört cephe görseli PDF paftalarıyla karşılaştırılmıştır. Görseller bu incelemede yeniden üretilmemiştir. Kaynak DWG ve SKP dosyaları değiştirilmemiştir; inceleme sonunda kaynaklarla çalışma kopyalarının SHA256 değerleri eşleşmiştir.

İnceleme mimari koordinasyon ve görsel uyum kapsamındadır. Statik hesap ve mevzuat uygunluğu denetimi yapılmamıştır. Belgelerdeki notlar proje verisi olarak değerlendirilmiş, kullanıcı talimatı olarak uygulanmamıştır.

## Bulgular

### 1 Arazi ile model ilişkisi

Öncelik: Yüksek. Durum: Görsel karşılaştırma bulgusu.

Model görsellerinde ön cephede bodrum pencereleri, garaj altında ise açıklıklar görünür durumda. Paftalarda bu bölgeler zemin altında veya kazılmamış alan olarak gösteriliyor. Bu görünüm, modelin araziyle ilişkisini yanıltıcı hale getiriyor; tek başına fazladan açıklık modellendiğini kanıtlamıyor.

Öneri: Arazi yüzeyini ve görünür temel sınırlarını paftalarla eşleştirerek cepheleri yeniden üretin.

Dayanak: PDF paftaları 1, 1.2 ve 2; model ön ve sol cephe görselleri.

### 2 Vaziyet planı

Öncelik: Yüksek. Durum: İncelenen PDF setinde doğrulandı.

T1.0 indeksinde site plan yazıyor, fakat incelenen sette vaziyet planı çizilmemiş. Araç yolu, arazi kotları ve walk-out bodrumun çevreyle bağlantısı bu set üzerinden tam doğrulanamıyor.

Öneri: Vaziyet ve kotlandırma planını tamamlayın veya ilgili ayrı paftayı sete bağlayın.

Dayanak: PDF paftası T1.0 ve 11 paftalık set.

### 3 Saçak detayları

Öncelik: Orta. Durum: Görsel karşılaştırma bulgusu.

Paftalardaki 8 inç fascia/frieze bantları ve yağmur oluğu sistemi model görsellerinde temsil edilmiyor.

Öneri: Cephe ve çatı kenarı oranlarını doğru değerlendirmek için bu elemanları modele ekleyin.

Dayanak: PDF paftaları 1, 1.1, 1.2; mevcut model cepheleri. v3 revizyon kaydı da fascia, oluk ve iniş borularının modellenmediğini belirtiyor.

### 4 Giriş üstündeki kaplama

Öncelik: Orta. Durum: Görsel karşılaştırma bulgusu.

Modelde giriş üzerindeki yatay pencerenin çevresi beyaz düz yüzey; ön cephe paftasında tuğla taraması devam ediyor.

Öneri: Bu yüzeyin malzemesini çizimle eşleştirin veya tasarım değişikliği olarak işaretleyin.

Dayanak: PDF paftası 1 ve model ön cephe görseli.

### 5 Havalandırma tablosu

Öncelik: Orta. Durum: PDF tablosunda doğrudan doğrulandı.

Pafta 4'te master banyo için gerekli mekanik havalandırma 202,4 CFM, seçilen değer 200 CFM olarak yazıyor. Seçilen değer tablodaki gerekli değerden 2,4 CFM düşük.

Öneri: Hesabı veya cihaz seçimini uzlaştırın. Bu bulgu tablonun kendi içindeki tutarsızlığı gösterir; mevzuata ilişkin bağımsız bir uygunluk kararı değildir.

Dayanak: PDF paftası 4; `Evidence/ventilation.png` yakın görüntüsü.

### 6 DWG alan etiketleri

Öncelik: Orta. Durum: DWG dışa aktarımında doğrudan doğrulandı.

A-Area katmanında 1.935 / 1.761 / 1.808 / 1.077 ft² etiketleri ve `##############` alanı var. Bunların kapaktaki 2.511 + 2.512 = 5.023 ft² tablosuyla ilişkisi belli değil. Eski çalışmalardan kalmış olabilecek bu değerler güncel alan hesabı olarak kullanılmamalı.

Öneri: Eski alanları ayırın; güncel alan hesabını kapalı sınırlar üzerinden doğrulayın.

Dayanak: `Data/dwg_data.json`; PDF paftası T1.0. Bu incelemede net/brüt alan hesabı yeniden yapılmadı.

### 7 Pafta başlıkları ve genel notlar

Öncelik: Düşük. Durum: PDF setinde doğrulandı.

T1.0 başlığı Exterior Elevations; proje numarası 2026- olarak eksik bırakılmış. Yeni yapı setinde mevcut kanalları değiştirmeye yönelik notlar bulunuyor.

Öneri: Pafta başlıklarını, proje numarasını ve kapsam dışı şablon notlarını düzeltin.

Dayanak: T1.0 başlık bloğu ve genel notlar; diğer paftaların proje numarası alanları.

## Önceki revizyon kaydından kalan ölçü soruları

Aşağıdaki konular v3 revizyon kaydından aktarılmıştır. Bu incelemede farkların tamamı yeniden ölçülmemiştir; yeni ve kesinleşmiş ölçüm sonuçları olarak değerlendirilmemelidir.

- Modelin bazı arka ve doğu duvarlarının DWG'den yaklaşık 5–10 inç büyük olduğu belirtiliyor.
- 12 inç saçağın dış kaplama yüzünden mi, karkastan mı ölçüleceği açık kalmış. Modelde dış duvar yüzü esas alınmış.
- Garaj arka duvar parçası modelde 51 inç, planda 46 inç olarak kaydedilmiş.
- Giriş kulesi çatısının tepesindeki yaklaşık 12 x 17 inç düz parçanın mimarca teyidi açık kalmış.
- Araç yolu döşemesinin kapı dış sövelerini yaklaşık 5,3 inç geçmesi bir varsayım olarak kaydedilmiş; vaziyet planıyla doğrulanmalı.

Dayanak: `Previous_Revision_Logs/JESB_Lot2_v3_Change_Log.md`. Önceki kayıtlardaki karar ifadeleri geçmiş kayıt niteliğindedir; bu inceleme kapsamında yeni değişiklik yetkisi oluşturmaz.

## Önerilen çalışma sırası

1. DWG ile SKP dış duvar sınırlarını ortak referansta eşleştirin; saçak ölçüsünün referans yüzünü netleştirin.
2. Arazi, araç yolu ve walk-out kotlarını tamamlayın.
3. Kaplama ve saçak detaylarını eşleştirip dört cepheyi yeniden üretin.
4. Havalandırma tablosunu, alan etiketlerini ve pafta bilgilerini düzeltin.

## Klasör içeriği

- `Evidence/PDF_Sheets`: PDF'nin 11 sayfasının inceleme görüntüleri. Dosya sıra numarası PDF sayfa numarasıdır: 01=T1.0, 02=1, 03=1.1, 04=1.2, 05=2, 06=3, 07=4, 08=5, 09=6, 10=7, 11=8.
- `Evidence/Model_Elevations`: Mevcut v3 cephe ve perspektif görsellerinin kopyaları.
- `Evidence/ventilation.png`: Havalandırma tablosunun yakın görüntüsü.
- `Data`: DWG metin/blok verileri, model üst düzey nesne sınırları, çatı çizgileri ve PDF metni. Model JSON dosyasındaki yol geçici inceleme kopyasına aittir. Üst grup için solid=false olması, içindeki çatı geometrisinin hatalı olduğunu tek başına göstermez.
- `Previous_Revision_Logs`: Önceki v2 ve v3 değişiklik kayıtlarının değiştirilmemiş kopyaları.

Kaynak çizimler LOT2 ana klasöründe korunmuştur. Bu klasör inceleme arşividir; revize DWG veya SKP teslimi içermez.
