<?php

namespace Database\Seeders;

use App\Models\Admin;
use App\Models\Application;
use App\Models\Courier;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Default admin (login: admin@arindi.uz / password)
        Admin::updateOrCreate(
            ['email' => 'admin@arindi.uz'],
            ['name' => 'Bosh admin', 'password' => Hash::make('password')]
        );

        // Default courier (login via courier app: +998901112233 / password)
        $courier = Courier::updateOrCreate(
            ['phone' => '+998901112233'],
            ['name' => 'Akmal Kuryer', 'password' => Hash::make('password'), 'is_active' => true]
        );

        // Demo users
        $user = User::updateOrCreate(
            ['phone' => '+998901234567'],
            ['name' => 'Dilshod', 'balance' => 0, 'phone_verified_at' => now()]
        );

        $user2 = User::updateOrCreate(
            ['phone' => '+998907654321'],
            ['name' => 'Madina', 'balance' => 18000, 'phone_verified_at' => now()]
        );

        // Sample applications across statuses
        Application::firstOrCreate(
            ['user_id' => $user->id, 'status' => Application::STATUS_PENDING],
            [
                'type' => 'pochoq',
                'weight_kg' => 12.5,
                'address' => 'Toshkent, Chilonzor 9-kvartal',
                'latitude' => 41.2851,
                'longitude' => 69.2034,
                'comment' => 'Tuxum po\'choqlari, quruq',
                'price_per_kg' => config('arindi.price_per_kg'),
            ]
        );

        Application::firstOrCreate(
            ['user_id' => $user2->id, 'status' => Application::STATUS_COLLECTED],
            [
                'type' => 'pochoq',
                'courier_id' => $courier->id,
                'weight_kg' => 30,
                'address' => 'Toshkent, Yunusobod 4-kvartal',
                'latitude' => 41.3490,
                'longitude' => 69.2890,
                'comment' => 'Aralash po\'choq',
                'price_per_kg' => config('arindi.price_per_kg'),
                'courier_comment' => 'Toza holatda qabul qilindi',
                'accepted_at' => now()->subHour(),
                'collected_at' => now()->subMinutes(20),
            ]
        );
    }
}
