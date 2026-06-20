<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WithdrawalRequest extends Model
{
    use HasFactory;

    public const STATUS_PENDING = 'pending';
    public const STATUS_PAID = 'paid';
    public const STATUS_REJECTED = 'rejected';

    protected $fillable = [
        'user_id',
        'amount',
        'card_number',
        'card_holder',
        'status',
        'admin_note',
        'paid_at',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'paid_at' => 'datetime',
        ];
    }

    protected $appends = ['masked_card'];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function getMaskedCardAttribute(): string
    {
        $digits = preg_replace('/\D/', '', (string) $this->card_number);

        if (strlen($digits) < 4) {
            return $this->card_number;
        }

        return '**** **** **** '.substr($digits, -4);
    }
}
