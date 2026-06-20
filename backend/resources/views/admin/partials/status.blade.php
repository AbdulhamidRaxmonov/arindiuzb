@php
    $map = [
        'pending' => ['Yangi', 'bg-amber-100 text-amber-700'],
        'accepted' => ['Qabul qilingan', 'bg-blue-100 text-blue-700'],
        'collected' => ['Yakunlangan', 'bg-orange-100 text-orange-700'],
        'verified' => ['Tekshirildi', 'bg-green-100 text-green-700'],
        'cancelled' => ['Bekor qilingan', 'bg-slate-200 text-slate-600'],
        'paid' => ['To\'langan', 'bg-green-100 text-green-700'],
        'rejected' => ['Rad etilgan', 'bg-red-100 text-red-700'],
    ];
    [$label, $classes] = $map[$status] ?? [$status, 'bg-slate-100 text-slate-600'];
@endphp
<span class="inline-block px-2.5 py-1 rounded-full text-xs font-medium {{ $classes }}">{{ $label }}</span>
