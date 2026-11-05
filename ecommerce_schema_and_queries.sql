-- ============================================================================
-- E-Ticaret Veritabanı Şeması ve Analitik SQL Sorguları
-- E-Commerce Relational Database Schema & Analytics
-- ============================================================================

-- Tabloları temizle (Gerekirse baştan çalıştırmak için)
DROP TRIGGER IF EXISTS siparis_sonrasi_stok_guncelle;
DROP TABLE IF EXISTS Siparis_Detay;
DROP TABLE IF EXISTS Siparis;
DROP TABLE IF EXISTS Urun;
DROP TABLE IF EXISTS Musteri;
DROP TABLE IF EXISTS Satici;
DROP TABLE IF EXISTS Kategori;

-- ----------------------------------------------------------------------------
-- 1. TABLO TANIMLARI (DDL)
-- ----------------------------------------------------------------------------

-- Kategori Tablosu
CREATE TABLE Kategori (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ad VARCHAR(50) NOT NULL UNIQUE
);

-- Satıcı Tablosu
CREATE TABLE Satici (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ad VARCHAR(100) NOT NULL,
    adres TEXT
);

-- Müşteri Tablosu
CREATE TABLE Musteri (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ad VARCHAR(50) NOT NULL,
    soyad VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    sehir VARCHAR(50),
    kayit_tarihi DATE NOT NULL
);

-- Ürün Tablosu
CREATE TABLE Urun (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ad VARCHAR(100) NOT NULL,
    fiyat DECIMAL(10, 2) NOT NULL,
    stok INT NOT NULL,
    kategori_id INT,
    satici_id INT,
    FOREIGN KEY (kategori_id) REFERENCES Kategori(id),
    FOREIGN KEY (satici_id) REFERENCES Satici(id)
);

-- Sipariş Tablosu
CREATE TABLE Siparis (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    musteri_id INT NOT NULL,
    tarih DATE NOT NULL,
    toplam_tutar DECIMAL(10, 2) NOT NULL,
    odeme_turu VARCHAR(50),
    FOREIGN KEY (musteri_id) REFERENCES Musteri(id)
);

-- Sipariş Detay Tablosu (Many-to-Many Çözümü)
CREATE TABLE Siparis_Detay (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    siparis_id INT NOT NULL,
    urun_id INT NOT NULL,
    adet INT NOT NULL,
    fiyat DECIMAL(10, 2) NOT NULL, -- Ürünün sipariş anındaki anlık birim fiyatı
    FOREIGN KEY (siparis_id) REFERENCES Siparis(id),
    FOREIGN KEY (urun_id) REFERENCES Urun(id),
    UNIQUE (siparis_id, urun_id) -- Bir siparişte aynı ürün tek bir satırda yer alır
);

-- ----------------------------------------------------------------------------
-- 2. OTOMASYON & TETİKLEYİCİ (TRIGGER)
-- ----------------------------------------------------------------------------

-- Sipariş Detayına yeni ürün eklendiğinde, ilgili ürünün stoğunu otomatik düşürür
CREATE TRIGGER siparis_sonrasi_stok_guncelle
AFTER INSERT ON Siparis_Detay
FOR EACH ROW
BEGIN
    UPDATE Urun
    SET stok = stok - NEW.adet
    WHERE id = NEW.urun_id;
END;

-- ----------------------------------------------------------------------------
-- 3. ÖRNEK VERİ GİRİŞİ (DML)
-- ----------------------------------------------------------------------------

-- Kategoriler
INSERT INTO Kategori (ad) VALUES
('Elektronik'),
('Giyim'),
('Ev ve Yaşam'),
('Kitap');

-- Satıcılar
INSERT INTO Satici (ad, adres) VALUES
('Tech Dünyası', 'Büyükçekmece, İstanbul'),
('Moda Rüzgarı', 'Şişli, İstanbul'),
('Kitap Kurdu Yayınevi', 'Kızılay, Ankara'),
('Evin İhtiyaçları', 'Konak, İzmir');

-- Müşteriler
INSERT INTO Musteri (ad, soyad, email, sehir, kayit_tarihi) VALUES
('Ayşe', 'Yılmaz', 'ayse.y@mail.com', 'İstanbul', '2024-01-10'),
('Burak', 'Kaya', 'burak.k@mail.com', 'Ankara', '2024-02-05'),
('Ceren', 'Demir', 'ceren.d@mail.com', 'İzmir', '2024-03-01'),
('Deniz', 'Öztürk', 'deniz.o@mail.com', 'İstanbul', '2024-04-15'),
('Emre', 'Aydın', 'emre.a@mail.com', 'Ankara', '2024-05-20'); -- Henüz siparişi olmayan müşteri (Pazar analizi için)

-- Ürünler (Başlangıç Stokları)
INSERT INTO Urun (ad, fiyat, stok, kategori_id, satici_id) VALUES
('Akıllı Telefon X', 15000.00, 50, 1, 1),
('Yazlık Elbise', 500.00, 120, 2, 2),
('Akıllı Saat Z', 4500.00, 30, 1, 1),
('Roman - Arayış', 120.00, 200, 4, 3),
('Mutfak Robotu', 2500.00, 40, 3, 4),
('T-Shirt Basic', 250.00, 150, 2, 2),
('Bluetooth Kulaklık', 800.00, 75, 1, 1),
('Buzdolabı Magnet Seti', 45.00, 300, 3, 4),
('Kitap - Veri Tabanı', 150.00, 90, 4, 3),
('Gaming Mouse', 600.00, 60, 1, 1); -- Hiç satılmamış ürün (Pazar analizi için)

-- Siparişler
INSERT INTO Siparis (musteri_id, tarih, toplam_tutar, odeme_turu) VALUES
(1, '2024-06-01', 15500.00, 'Kredi Kartı'),
(2, '2024-06-05', 120.00, 'Nakit'),
(3, '2024-06-10', 2545.00, 'Havale'),
(1, '2024-07-03', 9000.00, 'Kredi Kartı'),
(4, '2024-07-20', 1050.00, 'Kredi Kartı'),
(1, '2024-08-15', 300.00, 'Kapıda Ödeme');

-- Sipariş Kalemleri (Bu eklemelerle TRIGGER devreye girip Urun.stok değerini otomatik düşürür)
INSERT INTO Siparis_Detay (siparis_id, urun_id, adet, fiyat) VALUES
(1, 1, 1, 15000.00), -- Akıllı Telefon X (1 adet) -> Stok: 50 - 1 = 49
(1, 6, 2, 250.00);   -- T-Shirt Basic (2 adet)   -> Stok: 150 - 2 = 148

INSERT INTO Siparis_Detay (siparis_id, urun_id, adet, fiyat) VALUES
(2, 4, 1, 120.00);   -- Roman - Arayış (1 adet)  -> Stok: 200 - 1 = 199

INSERT INTO Siparis_Detay (siparis_id, urun_id, adet, fiyat) VALUES
(3, 5, 1, 2500.00),  -- Mutfak Robotu (1 adet)   -> Stok: 40 - 1 = 39
(3, 8, 1, 45.00);    -- Buzdolabı Magnet Seti    -> Stok: 300 - 1 = 299

INSERT INTO Siparis_Detay (siparis_id, urun_id, adet, fiyat) VALUES
(4, 3, 2, 4500.00);  -- Akıllı Saat Z (2 adet)   -> Stok: 30 - 2 = 28

INSERT INTO Siparis_Detay (siparis_id, urun_id, adet, fiyat) VALUES
(5, 2, 1, 500.00),   -- Yazlık Elbise (1 adet)   -> Stok: 120 - 1 = 119
(5, 7, 1, 800.00);   -- Bluetooth Kulaklık (1 ad) -> Stok: 75 - 1 = 74

INSERT INTO Siparis_Detay (siparis_id, urun_id, adet, fiyat) VALUES
(6, 6, 1, 300.00);   -- T-Shirt Basic (1 adet)   -> Stok: 148 - 1 = 147

-- ----------------------------------------------------------------------------
-- 4. RAPORLAMA VE ANALİTİK SQL SORGULARI (DQL)
-- ----------------------------------------------------------------------------

-- Soru 1: En çok sipariş veren ilk 5 müşteri kimlerdir?
SELECT
    M.ad || ' ' || M.soyad AS musteri_adi,
    M.sehir AS sehir,
    COUNT(S.id) AS toplam_siparis_sayisi
FROM Musteri M
JOIN Siparis S ON M.id = S.musteri_id
GROUP BY M.id, M.ad, M.soyad, M.sehir
ORDER BY toplam_siparis_sayisi DESC
LIMIT 5;

-- Soru 2: Satıcı bazında toplam ciro ve satış performansı nedir?
SELECT
    SA.ad AS satici_adi,
    SUM(SD.adet * SD.fiyat) AS toplam_ciro_tl
FROM Satici SA
JOIN Urun U ON SA.id = U.satici_id
JOIN Siparis_Detay SD ON U.id = SD.urun_id
GROUP BY SA.id, SA.ad
ORDER BY toplam_ciro_tl DESC;

-- Soru 3: Şehirlere göre müşteri dağılımı nasıldır?
SELECT
    sehir,
    COUNT(id) AS musteri_sayisi
FROM Musteri
GROUP BY sehir
ORDER BY musteri_sayisi DESC;

-- Soru 4: Kategori bazında toplam satış gelirleri nedir?
SELECT
    C.ad AS kategori_adi,
    SUM(SD.adet * SD.fiyat) AS toplam_gelir_tl
FROM Kategori C
JOIN Urun U ON C.id = U.kategori_id
JOIN Siparis_Detay SD ON U.id = SD.urun_id
GROUP BY C.ad
ORDER BY toplam_gelir_tl DESC;

-- Soru 5: Aylık sipariş trendleri (Zaman serisi analizi)
SELECT
    STRFTIME('%Y-%m', tarih) AS yil_ay,
    COUNT(id) AS toplam_siparis_sayisi,
    SUM(toplam_tutar) AS aylik_toplam_ciro_tl
FROM Siparis
GROUP BY yil_ay
ORDER BY yil_ay ASC;

-- Soru 6: Detaylı sipariş faturası dökümü (Tüm ilişkili tabloların birleşimi)
SELECT
    S.id AS siparis_id,
    M.ad || ' ' || M.soyad AS musteri,
    U.ad AS urun_adi,
    SA.ad AS satici,
    SD.adet AS adet,
    SD.fiyat AS birim_fiyat,
    (SD.adet * SD.fiyat) AS satir_toplami
FROM Siparis_Detay SD
JOIN Siparis S ON SD.siparis_id = S.id
JOIN Musteri M ON S.musteri_id = M.id
JOIN Urun U ON SD.urun_id = U.id
JOIN Satici SA ON U.satici_id = SA.id
ORDER BY S.id;

-- Soru 7: Hiç satılmamış ürünler (Pazar / Stok Verimsizlik Analizi)
SELECT
    U.ad AS urun_adi,
    U.stok AS mevcut_stok,
    SA.ad AS satici_adi
FROM Urun U
JOIN Satici SA ON U.satici_id = SA.id
LEFT JOIN Siparis_Detay SD ON U.id = SD.urun_id
WHERE SD.urun_id IS NULL;

-- Soru 8: Kaydolduğu halde hiç sipariş vermemiş müşteriler (Durgun Müşteri Analizi)
SELECT
    M.ad || ' ' || M.soyad AS musteri_adi,
    M.email,
    M.sehir,
    M.kayit_tarihi
FROM Musteri M
LEFT JOIN Siparis S ON M.id = S.musteri_id
WHERE S.musteri_id IS NULL;

-- Soru 9: Belirli bir kategoriden (örn. Elektronik) sipariş vermiş olan tekil müşteriler
SELECT DISTINCT
    M.ad || ' ' || M.soyad AS musteri_adi,
    M.email,
    M.sehir
FROM Musteri M
JOIN Siparis S ON M.id = S.musteri_id
JOIN Siparis_Detay SD ON S.id = SD.siparis_id
JOIN Urun U ON SD.urun_id = U.id
JOIN Kategori C ON U.kategori_id = C.id
WHERE C.ad = 'Elektronik';