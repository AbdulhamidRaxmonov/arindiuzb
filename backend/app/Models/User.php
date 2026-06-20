<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'phone',
        'password',
        'balance',
        'language',
        'dark_mode',
        'avatar',
        'fcm_token',
        'phone_verified_at',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'phone_verified_at' => 'datetime',
            'password' => 'hashed',
            'balance' => 'decimal:2',
            'dark_mode' => 'boolean',
        ];
    }

    public function applications(): HasMany
    {
        return $this->hasMany(Application::class);
    }

    public function withdrawals(): HasMany
    {
        return $this->hasMany(WithdrawalRequest::class);
    }

    public function notifications(): HasMany
    {
        return $this->hasMany(AppNotification::class);
    }

    public function creditBalance(float $amount): void
    {
        $this->increment('balance', $amount);
    }

    public function debitBalance(float $amount): void
    {
        $this->decrement('balance', $amount);
    }
}
