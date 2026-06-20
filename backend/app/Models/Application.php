<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;

class Application extends Model
{
    use HasFactory;

    public const STATUS_PENDING = 'pending';
    public const STATUS_ACCEPTED = 'accepted';
    public const STATUS_COLLECTED = 'collected';
    public const STATUS_VERIFIED = 'verified';
    public const STATUS_CANCELLED = 'cancelled';

    protected $fillable = [
        'user_id',
        'courier_id',
        'type',
        'weight_kg',
        'address',
        'latitude',
        'longitude',
        'comment',
        'photo',
        'status',
        'credited_amount',
        'price_per_kg',
        'courier_comment',
        'accepted_at',
        'collected_at',
        'verified_at',
    ];

    protected function casts(): array
    {
        return [
            'weight_kg' => 'decimal:2',
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
            'credited_amount' => 'decimal:2',
            'price_per_kg' => 'decimal:2',
            'accepted_at' => 'datetime',
            'collected_at' => 'datetime',
            'verified_at' => 'datetime',
        ];
    }

    protected $appends = ['photo_url', 'estimated_amount'];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function courier(): BelongsTo
    {
        return $this->belongsTo(Courier::class);
    }

    public function getPhotoUrlAttribute(): ?string
    {
        return $this->photo ? Storage::disk('public')->url($this->photo) : null;
    }

    public function getEstimatedAmountAttribute(): float
    {
        $price = (float) ($this->price_per_kg ?: config('arindi.price_per_kg'));

        return round((float) $this->weight_kg * $price, 2);
    }
}
