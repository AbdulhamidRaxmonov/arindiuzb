@extends('admin.layouts.app')

@section('title', 'Pul yechish so\'rovlari')

@section('content')
    <form method="GET" class="bg-white rounded-xl shadow-sm p-4 mb-4 flex gap-3 items-end">
        <div>
            <label class="block text-xs text-slate-500 mb-1">Status</label>
            <select name="status" class="rounded-lg border border-slate-300 px-3 py-2 text-sm" onchange="this.form.submit()">
                <option value="">Barchasi</option>
                @foreach (['pending'=>'Kutilmoqda','paid'=>'To\'langan','rejected'=>'Rad etilgan'] as $k=>$v)
                    <option value="{{ $k }}" @selected(request('status')===$k)>{{ $v }}</option>
                @endforeach
            </select>
        </div>
    </form>

    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
        <table class="w-full text-sm">
            <thead class="bg-slate-50 text-slate-500 text-left">
                <tr>
                    <th class="px-4 py-3">#</th>
                    <th class="px-4 py-3">Foydalanuvchi</th>
                    <th class="px-4 py-3">Summa</th>
                    <th class="px-4 py-3">Karta</th>
                    <th class="px-4 py-3">Karta egasi</th>
                    <th class="px-4 py-3">Status</th>
                    <th class="px-4 py-3">Sana</th>
                    <th class="px-4 py-3">Amallar</th>
                </tr>
            </thead>
            <tbody class="divide-y">
                @forelse ($withdrawals as $w)
                    <tr class="hover:bg-slate-50 align-top">
                        <td class="px-4 py-3 text-slate-400">{{ $w->id }}</td>
                        <td class="px-4 py-3">
                            <div class="font-medium">{{ $w->user->name ?? '—' }}</div>
                            <div class="text-slate-400 text-xs">{{ $w->user->phone }}</div>
                        </td>
                        <td class="px-4 py-3 font-semibold text-rose-600">{{ number_format($w->amount) }} so'm</td>
                        <td class="px-4 py-3 font-mono text-xs">{{ $w->card_number }}</td>
                        <td class="px-4 py-3">{{ $w->card_holder }}</td>
                        <td class="px-4 py-3">@include('admin.partials.status', ['status' => $w->status])</td>
                        <td class="px-4 py-3 text-slate-400 text-xs">{{ $w->created_at->format('d.m.Y H:i') }}</td>
                        <td class="px-4 py-3">
                            @if ($w->status === 'pending')
                                <div class="flex gap-2">
                                    <form method="POST" action="{{ route('admin.withdrawals.pay', $w) }}"
                                          onsubmit="return confirm('To\'lov qilindi deb belgilansinmi?')">
                                        @csrf
                                        <button class="bg-green-600 hover:bg-green-700 text-white px-3 py-1.5 rounded-lg text-xs">To'landi</button>
                                    </form>
                                    <form method="POST" action="{{ route('admin.withdrawals.reject', $w) }}"
                                          onsubmit="return confirm('So\'rov rad etilsinmi? Mablag\' qaytariladi.')">
                                        @csrf
                                        <button class="bg-white border border-red-300 text-red-600 hover:bg-red-50 px-3 py-1.5 rounded-lg text-xs">Rad etish</button>
                                    </form>
                                </div>
                            @else
                                <span class="text-slate-400 text-xs">{{ $w->admin_note ?: '—' }}</span>
                            @endif
                        </td>
                    </tr>
                @empty
                    <tr><td colspan="8" class="px-4 py-8 text-center text-slate-400">So'rovlar topilmadi.</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="mt-4">{{ $withdrawals->links() }}</div>
@endsection
