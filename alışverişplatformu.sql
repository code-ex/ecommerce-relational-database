CREATE TABLE Kategori (
    id INTEGER PRIMARY KEY AUTOINCREMENT, -- Otomatik artan anahtar
    ad VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Satici (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ad VARCHAR(100) NOT NULL,
    adres TEXT
);

CREATE TABLE Musteri (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ad VARCHAR(50) NOT NULL,
    soyad VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    sehir VARCHAR(50),
    kayit_tarihi DATE NOT NULL
);

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

CREATE TABLE Siparis (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    musteri_id INT NOT NULL,
    tarih DATE NOT NULL,
    toplam_tutar DECIMAL(10, 2) NOT NULL,
    odeme_turu VARCHAR(50),
    FOREIGN KEY (musteri_id) REFERENCES Musteri(id)
);

CREATE TABLE Siparis_Detay (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    siparis_id INT NOT NULL,
    urun_id INT NOT NULL,
    adet INT NOT NULL,
    fiyat DECIMAL(10, 2) NOT NULL, -- Ürünün sipariş anındaki fiyatı
    FOREIGN KEY (siparis_id) REFERENCES Siparis(id),
    FOREIGN KEY (urun_id) REFERENCES Urun(id),
    UNIQUE (siparis_id, urun_id) -- Bir siparişte aynı ürün bir kere yer alabilir
);

INSERT INTO Kategori (ad) VALUES
('Elektronik'),
('Giyim'),
('Ev ve Yaşam'),
('Kitap');

INSERT INTO Satici (ad, adres) VALUES
('Tech Dünyası', 'Büyükçekmece, İstanbul'),
('Moda Rüzgarı', 'Şişli, İstanbul'),
('Kitap Kurdu Yayınevi', 'Kızılay, Ankara'),
('Evin İhtiyaçları', 'Konak, İzmir');

INSERT INTO Musteri (ad, soyad, email, sehir, kayit_tarihi) VALUES
('Ayşe', 'Yılmaz', 'ayse.y@mail.com', 'İstanbul', '2024-01-10'),
('Burak', 'Kaya', 'burak.k@mail.com', 'Ankara', '2024-02-05'),
('Ceren', 'Demir', 'ceren.d@mail.com', 'İzmir', '2024-03-01'),
('Deniz', 'Öztürk', 'deniz.o@mail.com', 'İstanbul', '2024-04-15'),
('Emre', 'Aydın', 'emre.a@mail.com', 'Ankara', '2024-05-20');

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
('Gaming Mouse', 600.00, 60, 1, 1); -- Bu ürün, "Hiç satılmamış ürünler" sorgusu için satılmayacak.

INSERT INTO Siparis (musteri_id, tarih, toplam_tutar, odeme_turu) VALUES
(1, '2024-06-01', 15500.00, 'Kredi Kartı'), -- Ayşe, 1. Sipariş (Elektronik + Giyim)
(2, '2024-06-05', 120.00, 'Nakit'),       -- Burak, 1. Sipariş (Kitap)
(3, '2024-06-10', 2545.00, 'Havale'),     -- Ceren, 1. Sipariş (Ev ve Yaşam)
(1, '2024-07-03', 9000.00, 'Kredi Kartı'), -- Ayşe, 2. Sipariş (Elektronik * 2) -> En çok sipariş veren müşteri olacak
(4, '2024-07-20', 1050.00, 'Kredi Kartı'), -- Deniz, 1. Sipariş (Giyim + Elektronik)
(1, '2024-08-15', 300.00, 'Kapıda Ödeme'); -- Ayşe, 3. Sipariş (Giyim * 1) -> En çok sipariş veren müşteri olacak
-- Not: Müşteri 5 (Emre) hiç sipariş vermedi. "Hiç sipariş vermemiş müşteriler" sorgusu için kullanılacak.

-- Trigger: siparis_sonrasi_stok_guncelle
-- Amacı: Yeni bir Siparis_Detay kaydı eklendiğinde, ilgili Urun tablosundaki 'stok' miktarını azaltacak.

CREATE TRIGGER siparis_sonrasi_stok_guncelle
AFTER INSERT ON Siparis_Detay
FOR EACH ROW
BEGIN
    -- NEW keyword'ü, yeni eklenen kaydın (Siparis_Detay) sütunlarına erişim sağlar.
    UPDATE Urun
    SET stok = stok - NEW.adet -- Satılan adet kadar stoktan düşülür
    WHERE id = NEW.urun_id;    -- İlgili ürünün stoğu güncellenir
END;

INSERT INTO Siparis_Detay (siparis_id, urun_id, adet, fiyat) VALUES
(1, 1, 1, 15000.00), -- Akıllı Telefon X
(1, 6, 2, 250.00);   -- T-Shirt Basic (2 adet)

INSERT INTO Siparis_Detay (siparis_id, urun_id, adet, fiyat) VALUES
(2, 4, 1, 120.00);   -- Roman - Arayış

INSERT INTO Siparis_Detay (siparis_id, urun_id, adet, fiyat) VALUES
(3, 5, 1, 2500.00),  -- Mutfak Robotu
(3, 8, 1, 45.00);    -- Buzdolabı Magnet Seti

INSERT INTO Siparis_Detay (siparis_id, urun_id, adet, fiyat) VALUES
(4, 3, 2, 4500.00);  -- Akıllı Saat Z (2 adet)

INSERT INTO Siparis_Detay (siparis_id, urun_id, adet, fiyat) VALUES
(5, 2, 1, 500.00),   -- Yazlık Elbise
(5, 7, 1, 800.00);   -- Bluetooth Kulaklık (Fiyatı detay tablosunda güncelledik, bu daha sonra stok azaltma sorgusunda görülebilir)

INSERT INTO Siparis_Detay (siparis_id, urun_id, adet, fiyat) VALUES
(6, 6, 1, 300.00);   -- T-Shirt Basic (1 adet)

-- 2. aşama bitti


SELECT
    M.ad || ' ' || M.soyad AS "Müşteri Adı",
    M.sehir AS "Şehir",
    COUNT(S.id) AS "Toplam Sipariş Sayısı"
FROM Musteri M
JOIN Siparis S ON M.id = S.musteri_id
GROUP BY M.id, M.ad, M.soyad, M.sehir
ORDER BY "Toplam Sipariş Sayısı" DESC
LIMIT 5;

SELECT
    SA.ad AS "Satıcı Adı",
    SUM(SD.adet * SD.fiyat) AS "Toplam Ciro (TL)"
FROM Satici SA
JOIN Urun U ON SA.id = U.satici_id
JOIN Siparis_Detay SD ON U.id = SD.urun_id
GROUP BY SA.id, SA.ad
ORDER BY "Toplam Ciro (TL)" DESC;


SELECT
    SA.ad AS "Satıcı Adı",
    SUM(SD.adet * SD.fiyat) AS "Toplam Ciro (TL)"
FROM Satici SA
JOIN Urun U ON SA.id = U.satici_id
JOIN Siparis_Detay SD ON U.id = SD.urun_id
GROUP BY SA.id, SA.ad
ORDER BY "Toplam Ciro (TL)" DESC;

SELECT
    sehir AS "Şehir",
    COUNT(id) AS "Müşteri Sayısı"
FROM Musteri
GROUP BY sehir
ORDER BY "Müşteri Sayısı" DESC;

SELECT
    C.ad AS "Kategori Adı",
    SUM(SD.adet * SD.fiyat) AS "Kategori Toplam Satış Tutarı"
FROM Kategori C
JOIN Urun U ON C.id = U.kategori_id
JOIN Siparis_Detay SD ON U.id = SD.urun_id
GROUP BY C.ad
ORDER BY "Kategori Toplam Satış Tutarı" DESC;

SELECT
    STRFTIME('%Y-%m', tarih) AS "Yıl-Ay", -- SQLite formatı
    COUNT(id) AS "Toplam Sipariş Sayısı"
FROM Siparis
GROUP BY "Yıl-Ay"
ORDER BY "Yıl-Ay";

SELECT
    S.id AS "Sipariş ID",
    M.ad || ' ' || M.soyad AS "Müşteri",
    U.ad AS "Ürün Adı",
    SA.ad AS "Satıcı",
    SD.adet AS "Adet",
    SD.fiyat AS "Birim Fiyat",
    (SD.adet * SD.fiyat) AS "Satır Toplamı"
FROM Siparis_Detay SD
JOIN Siparis S ON SD.siparis_id = S.id
JOIN Musteri M ON S.musteri_id = M.id
JOIN Urun U ON SD.urun_id = U.id
JOIN Satici SA ON U.satici_id = SA.id
ORDER BY S.id;

SELECT
    U.ad AS "Ürün Adı",
    U.stok AS "Mevcut Stok",
    SA.ad AS "Satıcı"
FROM Urun U
LEFT JOIN Siparis_Detay SD ON U.id = SD.urun_id
WHERE SD.urun_id IS NULL; -- Sipariş Detay tablosunda kaydı olmayan ürünler

SELECT
    M.ad || ' ' || M.soyad AS "Müşteri Adı",
    M.email
FROM Musteri M
LEFT JOIN Siparis S ON M.id = S.musteri_id
WHERE S.musteri_id IS NULL; -- Siparis tablosunda kaydı olmayan müşteriler

SELECT DISTINCT
    M.ad || ' ' || M.soyad AS "Müşteri Adı",
    M.sehir AS "Şehir"
FROM Musteri M
JOIN Siparis S ON M.id = S.musteri_id
JOIN Siparis_Detay SD ON S.id = SD.siparis_id
JOIN Urun U ON SD.urun_id = U.id
JOIN Kategori C ON U.kategori_id = C.id
WHERE C.ad = 'Elektronik';