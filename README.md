# 🛒 E-Commerce Relational Database & SQL Analytics

<div align="center">

![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Relational%20DB-CC292B?style=for-the-badge)
![Lucidchart](https://img.shields.io/badge/Lucidchart-ER%20Diagram-F9A01B?style=for-the-badge&logo=lucid&logoColor=white)
![DB Browser](https://img.shields.io/badge/DB%20Browser-for%20SQLite-2D72D9?style=for-the-badge)

<p align="center">
  <b>Modern e-ticaret platformları için tasarlanmış ilişkisel veritabanı mimarisi, ER diyagramı, trigger tabanlı otomatik stok yönetimi ve ileri seviye analitik SQL sorguları.</b>
</p>

</div>

---

## 📌 Proje Genel Bakışı (Overview)

Bu proje; Amazon ve Trendyol benzeri çok satıcılı (multi-vendor) e-ticaret platformlarının temel veri akışlarını simüle eden, ilişkisel bütünlüğü (referential integrity) yüksek ve normalizasyon kurallarına uygun bir ilişkisel veritabanı tasarımıdır.

* **Otomatik Stok Yönetimi:** `AFTER INSERT` tetikleyicisi (Trigger) ile sipariş anında insan hatasını ortadan kaldıran dinamik stok düşüşü.
* **Tarihsel Fiyat Güvencesi:** Ürünün anlık fiyat değişimlerinden bağımsız, sipariş anındaki gerçek satış fiyatını kaydeden detay tablosu mimarisi.
* **Pazar & Ciro Analitiği:** Çoklu tablo birleştirmeleri (`JOIN`), gruplama (`GROUP BY`), zaman serisi analizi (`STRFTIME`) ve atıl envanter/durgun müşteri tespitine (`LEFT JOIN ... IS NULL`) yönelik iş zekası sorguları.

---

## 📊 Varlık-İlişki Diyagramı (ER Diagram)

Veritabanı ilişkileri Lucidchart üzerinde Bire-Çok (1:N) ve Çoka-Çok (N:M) ilişkisel bütünlük ilkelerine göre modellenmiştir:

<div align="center">
  <img src="ER%20Diagram.png" alt="E-Commerce Relational Database ER Diagram" width="850"/>
</div>

---

## 🏗️ Veritabanı Şeması ve Tablo Mimarisi

| Tablo Adı | Rol / Tanım | İlişkisel Bağlantılar (Foreign Keys) |
| :--- | :--- | :--- |
| **`Kategori`** | Ürünlerin gruplandığı üst kategoriler | - |
| **`Satici`** | Platformdaki mağaza ve tedarikçi firmalar | - |
| **`Musteri`** | Kullanıcı profilleri, iletişim ve şehir verileri | - |
| **`Urun`** | Envanter, güncel birim fiyat ve anlık stok bilgileri | `kategori_id` ➔ `Kategori(id)`, `satici_id` ➔ `Satici(id)` |
| **`Siparis`** | Sipariş başlığı, sipariş tarihi, ödeme yöntemi ve genel tutar | `musteri_id` ➔ `Musteri(id)` |
| **`Siparis_Detay`** | Sipariş ve Ürün arasındaki Çoka-Çok (N:M) köprü tablosu. Satış anındaki birim fiyat ve adedi saklar. | `siparis_id` ➔ `Siparis(id)`, `urun_id` ➔ `Urun(id)` |

---

## ⚡ Otomasyon & İş Mantığı (SQL Trigger)

Manuel `UPDATE` operasyonlarından kaynaklanan stok tutarsızlıklarını önlemek amacıyla bir SQL Trigger kullanılmıştır:

```sql
CREATE TRIGGER siparis_sonrasi_stok_guncelle
AFTER INSERT ON Siparis_Detay
FOR EACH ROW
BEGIN
    UPDATE Urun
    SET stok = stok - NEW.adet
    WHERE id = NEW.urun_id;
END;
```

> [!NOTE]
> `Siparis_Detay` tablosuna her yeni satır eklendiğinde (`NEW.adet`), `Urun` tablosundaki ilgili kaydın `stok` miktarı otomatik olarak azaltılır.

---

## 📈 Öne Çıkan Analitik ve Raporlama Sorguları

Tüm sorgular [ecommerce_schema_and_queries.sql](ecommerce_schema_and_queries.sql) dosyası içerisinde hazır ve test edilmiş olarak sunulmaktadır:

* **En Çok Sipariş Veren Müşteriler:** `JOIN` ve `COUNT()` ile sadık müşteri segmentasyonu.
* **Satıcı Ciro & Satış Performansı:** Satıcı bazında brüt satış gelirleri ve ürün adedi kırılımı.
* **Kategori Bazlı Toplam Gelir:** En çok ciro getiren kategorilerin `SUM(adet * fiyat)` ile listelenmesi.
* **Aylık Sipariş Trendleri:** `STRFTIME('%Y-%m', tarih)` fonksiyonuyla zaman serisi ve hacim analizi.
* **Atıl Envanter / Hiç Satılmamış Ürünler:** `LEFT JOIN ... WHERE SD.urun_id IS NULL` ile stoğu olduğu halde hiç sipariş almayan ürünlerin tespiti.
* **Durgun Müşteri Analizi:** Platforma kaydolup henüz hiç sipariş vermemiş kullanıcıların pazarlama kampanyaları için filtrelenmesi.
* **Kategori Bazlı Müşteri Kırılımı:** Belirli bir kategoriden (örn. *Elektronik*) alışveriş yapmış tekil kullanıcıların hedeflenmesi.

---

## 🚀 Nasıl Çalıştırılır? (Quickstart)

### 1. DB Browser for SQLite ile (Görsel Arayüz)
1. [DB Browser for SQLite](https://sqlitebrowser.org/) uygulamasını açın.
2. `New Database` diyerek yeni bir veritabanı oluşturun (örn. `ecommerce.db`).
3. `Execute SQL` sekmesine gelin ve [ecommerce_schema_and_queries.sql](ecommerce_schema_and_queries.sql) dosyasını açıp çalıştırın (`F5`).

### 2. SQLite CLI ile (Terminal)
```bash
sqlite3 ecommerce.db < ecommerce_schema_and_queries.sql
```

### 3. Python ile Hızlı Doğrulama
```python
import sqlite3

con = sqlite3.connect("ecommerce.db")
with open("ecommerce_schema_and_queries.sql", "r", encoding="utf-8") as f:
    con.executescript(f.read())

cur = con.cursor()
for row in cur.execute("SELECT ad, stok FROM Urun LIMIT 5"):
    print(row)
```

---

<div align="center">
  <sub>Developed by <a href="https://github.com/code-ex">Mehmet Emin Metin</a></sub>
</div>
