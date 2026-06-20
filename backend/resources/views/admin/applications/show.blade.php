@extends('admin.layouts.app')

@section('title', 'Zayafka #'.$application->id)

@section('content')
    <a href="{{ route('admin.applications.index') }}" class="text-sm text-green-600 hover:underline">← Ortga</a>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mt-4">
        <div class="lg:col-span-2 space-y-6">
            <div class="bg-white rounded-xl shadow-sm p-6">
                <div class="flex items-center justify-between mb-4">
                    <h2 class="font-semibold text-lg">Zayafka ma'lumotlari</h2>
                    @include('admin.partials.status', ['status' => $application->status])
                </div>
                <dl class="grid grid-cols-2 gap-4 text-sm">
                    <div><dt class="text-slate-400">Tur</dt><dd class="font-medium capitalize">{{ $application->type }}</dd></div>
                    <div><dt class="text-slate-400">Og'irlik</dt><dd class="font-medium">{{ $application->weight_kg }} kg</dd></div>
                    <div><dt class="text-slate-400">1 kg narxi</dt><dd class="font-medium">{{ number_format($application->price_per_kg) }} so'm</dd></div>
                    <div><dt class="text-slate-400">Taxminiy summa</dt><dd class="font-medium text-green-600">{{ number_format($application->estimated_amount) }} so'm</dd></div>
                    <div class="col-span-2"><dt class="text-slate-400">Manzil</dt><dd class="font-medium">{{ $application->address }}</dd></div>
                    @if ($application->latitude)
                        <div class="col-span-2"><dt class="text-slate-400">Xarita</dt>
                            <dd><a class="text-green-600 hover:underline" target="_blank"
                                   href="https://www.google.com/maps/search/?api=1&query={{ $application->latitude }},{{ $application->longitude }}">
                                Google Maps'da ochish ({{ $application->latitude }}, {{ $application->longitude }})</a></dd>
                        </div>
                    @endif
                    <div class="col-span-2"><dt class="text-slate-400">Izoh (tarkibi)</dt><dd>{{ $application->comment ?: '—' }}</dd></div>
                    <div class="col-span-2"><dt class="text-slate-400">Kuryer izohi</dt><dd>{{ $application->courier_comment ?: '—' }}</dd></div>
                </dl>

                @if ($application->photo_url)
                    <div class="mt-4">
                        <dt class="text-slate-400 text-sm mb-2">Rasm</dt>
                        <img src="{{ $application->photo_url }}" class="rounded-lg max-h-72 border" alt="Chiqindi rasmi">
                    </div>
                @endif
            </div>
        </div>

        <div class="space-y-6">
            <div class="bg-white rounded-xl shadow-sm p-6 text-sm">
                <h3 class="font-semibold mb-3">Foydalanuvchi</h3>
                <p class="font-medium">{{ $application->user->name ?? '—' }}</p>
                <p class="text-slate-500">{{ $application->user->phone }}</p>
                <p class="text-slate-500 mt-2">Balans: <span class="font-semibold text-slate-800">{{ number_format($application->user->balance) }} so'm</span></p>
                @if ($application->courier)
                    <hr class="my-3">
                    <h3 class="font-semibold mb-1">Kuryer</h3>
                    <p>{{ $application->courier->name }} · {{ $application->courier->phone }}</p>
                @endif
            </div>

            @if ($application->status === 'collected')
                <div class="bg-white rounded-xl shadow-sm p-6">
                    <h3 class="font-semibold mb-3">Tasdiqlash va balansga qo'shish</h3>
                    <form method="POST" action="{{ route('admin.applications.verify', $application) }}" class="space-y-3">
                        @csrf
                        <div>
                            <label class="block text-xs text-slate-500 mb-1">Og'irlik (kg)</label>
                            <input type="number" step="0.01" name="weight_kg" value="{{ $application->weight_kg }}"
                                   class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm">
                        </div>
                        <div>
                            <label class="block text-xs text-slate-500 mb-1">1 kg narxi (so'm)</label>
                            <input type="number" step="1" name="price_per_kg" value="{{ (int) $application->price_per_kg }}"
                                   class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm">
                        </div>
                        <button class="w-full bg-green-600 hover:bg-green-700 text-white py-2.5 rounded-lg text-sm font-semibold">
                            ✅ Tasdiqlash va pul qo'shish
                        </button>
                    </form>
                </div>
            @elseif ($application->status === 'verified')
                <div class="bg-green-50 border border-green-200 rounded-xl p-6 text-sm">
                    <p class="text-green-700 font-medium">✅ Tekshirildi</p>
                    <p class="mt-1">Balansga qo'shilgan: <span class="font-semibold">{{ number_format($application->credited_amount) }} so'm</span></p>
                    <p class="text-slate-500 text-xs mt-1">{{ optional($application->verified_at)->format('d.m.Y H:i') }}</p>
                </div>
            @endif

            @if (in_array($application->status, ['pending','accepted']))
                <form method="POST" action="{{ route('admin.applications.cancel', $application) }}">
                    @csrf
                    <button class="w-full bg-white border border-red-300 text-red-600 hover:bg-red-50 py-2.5 rounded-lg text-sm">
                        Bekor qilish
                    </button>
                </form>
            @endif
        </div>
    </div>
@endsection
