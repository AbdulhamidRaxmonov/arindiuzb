<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\User>
 */
class UserFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name' => fake()->name(),
            'phone' => '+9989'.fake()->numerify('########'),
            'balance' => 0,
            'language' => 'uz',
            'dark_mode' => false,
            'phone_verified_at' => now(),
        ];
    }
}
