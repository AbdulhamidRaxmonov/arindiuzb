# ♻️ Arindi — Chiqindi yig'ish platformasi

Arindi — ho'jaliklardan chiqindi (**po'choq, bo'tilka, plasmassa, maklatura**)
yig'ib olib, uni pulga aylantiruvchi to'liq platforma. Foydalanuvchi ilova orqali
zayafka qoldiradi, kuryer uni olib ketadi, admin tekshirib har bir kg uchun
balansga pul qo'shadi, foydalanuvchi esa balansini kartaga yechib oladi.

## Loyiha tarkibi

| Papka            | Texnologiya            | Tavsif |
|------------------|------------------------|--------|
| `backend/`       | Laravel 11 + MySQL     | REST API + veb admin panel |
| `mobile_user/`   | Flutter                | Foydalanuvchi ilovasi |
| `mobile_courier/`| Flutter                | Kuryer (olib ketuvchi) ilovasi |

Har bir papkada o'z `README.md` fayli bor — batafsil sozlash yo'riqnomasi bilan.

## Asosiy funksiyalar

### Foydalanuvchi ilovasi
- Telefon raqami + OTP orqali ro'yxatdan o'tish
- Bosh sahifada **4 ta bo'lim**: Po'choq, Bo'tilka, Plasmassa, Maklatura
  - Faqat **Po'choq** faol; qolganlari bosilganda *"Tez orada bu bo'lim ham ishga
    tushadi"* degan alert chiqadi
- Po'choq zayafkasi: **kg**, **uy manzili (Google Map orqali tanlash)**, **izoh**,
  **rasm** (kamera/galereya) va **"Olib ketishsin"** tugmasi
- Profil: **balans**, til (uz/ru/en), ilova haqida, **tungi rejim**
- **Pul yechish**: balans 15 000 so'mdan oshganda — summa, karta raqami, karta
  egasi → *"Tez orada admin tekshirib pul tashlab beriladi"* alerti → yopish →
  bosh sahifa
- Bildirishnomalar

### Kuryer ilovasi
- Telefon + parol bilan kirish
- Zayafkalar ro'yxati (Yangi / Mening / Yakunlangan)
- Zayafkani qabul qilish, qo'ng'iroq, xaritada ochish
- Izoh bilan **"Qabul qildim"** — yakunlash

### Admin panel (veb)
- Email + parol bilan kirish
- **Dashboard** statistikasi
- **Zayafkalar** — barchasi statuslari bilan, tekshirish → balansga pul qo'shish
  (kg × 300 so'm)
- **Pul yechish so'rovlari** — to'landi deb belgilash (foydalanuvchiga
  *"to'lov qilindi"* bildirishnomasi boradi) yoki rad etish (mablag' qaytadi)
- **Kuryerlar** boshqaruvi

## Status oqimi (zayafka)

```
pending  ──kuryer qabul qiladi──▶ accepted
accepted ──kuryer yakunlaydi────▶ collected   (foydalanuvchiga xabar)
collected──admin tekshiradi─────▶ verified     (balansga kg×300 so'm qo'shiladi)
```

## Tezkor ishga tushirish

### 1) Backend
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
# .env da DB sozlamalari (mysql, arindi bazasi)
php artisan migrate --seed
php artisan storage:link
php artisan serve     # http://localhost:8000
```
Admin panel: `http://localhost:8000/admin/login` — `admin@arindi.uz` / `password`

### 2) Foydalanuvchi ilovasi
```bash
cd mobile_user
flutter create .
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

### 3) Kuryer ilovasi
```bash
cd mobile_courier
flutter create .
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```
Kuryer login: `+998901112233` / `password`

## Demo hisoblar (seeder)
| Rol            | Login                       | Parol      |
|----------------|-----------------------------|------------|
| Admin          | admin@arindi.uz             | password   |
| Kuryer         | +998901112233               | password   |
| Foydalanuvchi  | +998901234567 (OTP)         | OTP dev kodida ko'rsatiladi |

## Sozlamalar
- Narx (kg uchun) va minimal yechish summasi: `backend/config/arindi.php`
  (`ARINDI_PRICE_PER_KG=300`, `ARINDI_MIN_WITHDRAWAL=15000`)
- Flutter ilovalarda Google Maps API kaliti va ruxsatlar haqida har bir
  ilovaning README'sida yozilgan.

## Integratsiya nuqtalari
- **SMS (OTP)**: `backend/.../Api/AuthController@requestOtp` — Eskiz/Play Mobile
- **Push (FCM)**: `backend/app/Services/NotificationService@send`

---
Litsenziya: MIT
