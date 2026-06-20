# Arindi — Backend (Laravel 11 + MySQL)

REST API for the user & courier mobile apps **and** the web admin panel for the
Arindi waste-collection platform.

## Requirements
- PHP 8.2+
- Composer
- MySQL 8 (or MariaDB)

## Setup

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate

# Create the database (default name: arindi), then configure DB_* in .env
php artisan migrate --seed
php artisan storage:link        # so uploaded photos/avatars are publicly served

php artisan serve               # http://localhost:8000
```

### Default credentials (from the seeder)
| Role    | Login                          | Password   |
|---------|--------------------------------|------------|
| Admin   | `admin@arindi.uz`              | `password` |
| Courier | `+998901112233` (in app)       | `password` |
| User    | `+998901234567` (OTP login)    | OTP shown in API response in non-production |

Admin panel: <http://localhost:8000/admin/login>

## Business rules
- Price per kg and minimum withdrawal live in `config/arindi.php`
  (`ARINDI_PRICE_PER_KG=300`, `ARINDI_MIN_WITHDRAWAL=15000`).
- Only the `pochoq` category is active; the others return a "coming soon" error.

## Application lifecycle
`pending` → courier **accepts** → `accepted` → courier **finishes** (qabul qildim) →
`collected` → admin **verifies** (credits `weight_kg * price_per_kg` to the user) →
`verified`. Can be `cancelled` while pending/accepted.

## Withdrawal lifecycle
User requests a withdrawal (>= 15 000 so'm). The amount is reserved (debited)
immediately. Admin marks it **paid** (user gets a notification: "to'lov qilindi")
or **rejects** it (amount refunded).

## API overview

### Auth (user)
- `POST /api/auth/request-otp` — `{ phone }` → returns `debug_code` outside production
- `POST /api/auth/verify-otp` — `{ phone, code, name? }` → `{ token, user }`
- `POST /api/auth/logout`

### User (Bearer token)
- `GET /api/profile`, `POST /api/profile` (name, language, dark_mode, fcm_token, avatar)
- `GET /api/balance`
- `GET /api/categories` (public too)
- `GET/POST /api/applications`, `GET /api/applications/{id}`, `POST /api/applications/{id}/cancel`
- `GET/POST /api/withdrawals`
- `GET /api/notifications`, `POST /api/notifications/{id}/read`, `POST /api/notifications/read-all`

### Courier (Bearer token)
- `POST /api/courier/login` — `{ phone, password }`
- `GET /api/courier/me`, `POST /api/courier/logout`
- `GET /api/courier/applications?status=`
- `POST /api/courier/applications/{id}/accept`
- `POST /api/courier/applications/{id}/complete` — `{ courier_comment?, weight_kg? }`

All API responses follow `{ success, message, data }`.

## SMS / Push integration points
- OTP delivery: `App\Http\Controllers\Api\AuthController@requestOtp` (plug in Eskiz/Play Mobile).
- Push notifications: `App\Services\NotificationService@send` (plug in FCM).
