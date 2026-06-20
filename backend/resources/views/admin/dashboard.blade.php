@extends('admin.layouts.app')

@section('title', 'Dashboard')

@section('content')
    @php
        $cards = [
            ['Foydalanuvchilar', $stats['users'], '👥', 'bg-blue-500'],
            ['Kuryerlar', $stats['couriers'], '🚚', 'bg-indigo-500'],
            ['Jami zayafkalar', $stats['applications_total'], '📦', 'bg-slate-600'],
            ['Yangi zayafkalar', $stats['applications_pending'], '🆕', 'bg-amber-500'],
            ['Tekshirish kutilmoqda', $stats['applications_collected'], '🔎', 'bg-orange-500'],
            ['Tasdiqlangan', $stats['applications_verified'], '✅', 'bg-green-600'],
            ['Pul yechish (kutilmoqda)', $stats['withdrawals_pending'], '💸', 'bg-rose-500'],
            ['Jami to\'langan', number_format($stats['total_paid']).' so\'m', '💰', 'bg-emerald-600'],
        ];
    @endphp

    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        @foreach ($cards as [$label, $value, $icon, $color])
            <div class="bg-white rounded-xl shadow-sm p-5 flex items-center gap-4">
                <div class="{{ $color }} text-white text-xl w-12 h-12 rounded-lg flex items-center justify-center">{{ $icon }}</div>
                <div>
                    <div class="text-2xl font-bold">{{ $value }}</div>
                    <div class="text-sm text-slate-500">{{ $label }}</div>
                </div>
            </div>
        @endforeach
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div class="bg-white rounded-xl shadow-sm p-5">
            <div class="flex items-center justify-between mb-4">
                <h2 class="font-semibold">So'nggi zayafkalar</h2>
                <a href="{{ route('admin.applications.index') }}" class="text-sm text-green-600 hover:underline">Barchasi →</a>
            </div>
            <div class="divide-y">
                @forelse ($recentApplications as $app)
                    <div class="py-3 flex items-center justify-between text-sm">
                        <div>
                            <div class="font-medium">{{ $app->user->name ?? 'Foydalanuvchi' }} · {{ $app->user->phone }}</div>
                            <div class="text-slate-500">{{ ucfirst($app->type) }} · {{ $app->weight_kg }} kg</div>
                        </div>
                        @include('admin.partials.status', ['status' => $app->status])
                    </div>
                @empty
                    <p class="text-slate-400 py-4 text-sm">Hozircha zayafkalar yo'q.</p>
                @endforelse
            </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm p-5">
            <div class="flex items-center justify-between mb-4">
                <h2 class="font-semibold">Pul yechish so'rovlari</h2>
                <a href="{{ route('admin.withdrawals.index') }}" class="text-sm text-green-600 hover:underline">Barchasi →</a>
            </div>
            <div class="divide-y">
                @forelse ($pendingWithdrawals as $w)
                    <div class="py-3 flex items-center justify-between text-sm">
                        <div>
                            <div class="font-medium">{{ $w->user->name ?? 'Foydalanuvchi' }} · {{ $w->user->phone }}</div>
                            <div class="text-slate-500">{{ $w->masked_card }}</div>
                        </div>
                        <div class="font-semibold text-rose-600">{{ number_format($w->amount) }} so'm</div>
                    </div>
                @empty
                    <p class="text-slate-400 py-4 text-sm">Yangi so'rovlar yo'q.</p>
                @endforelse
            </div>
        </div>
    </div>
@endsection
