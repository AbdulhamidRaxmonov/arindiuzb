@extends('admin.layouts.app')

@section('title', 'Kuryerlar')

@section('content')
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div class="lg:col-span-2 bg-white rounded-xl shadow-sm overflow-hidden">
            <table class="w-full text-sm">
                <thead class="bg-slate-50 text-slate-500 text-left">
                    <tr>
                        <th class="px-4 py-3">#</th>
                        <th class="px-4 py-3">Ism</th>
                        <th class="px-4 py-3">Telefon</th>
                        <th class="px-4 py-3">Zayafkalar</th>
                        <th class="px-4 py-3">Holat</th>
                        <th class="px-4 py-3"></th>
                    </tr>
                </thead>
                <tbody class="divide-y">
                    @forelse ($couriers as $courier)
                        <tr class="hover:bg-slate-50">
                            <td class="px-4 py-3 text-slate-400">{{ $courier->id }}</td>
                            <td class="px-4 py-3 font-medium">{{ $courier->name }}</td>
                            <td class="px-4 py-3">{{ $courier->phone }}</td>
                            <td class="px-4 py-3">{{ $courier->applications_count }}</td>
                            <td class="px-4 py-3">
                                @if ($courier->is_active)
                                    <span class="px-2.5 py-1 rounded-full text-xs bg-green-100 text-green-700">Faol</span>
                                @else
                                    <span class="px-2.5 py-1 rounded-full text-xs bg-slate-200 text-slate-600">Faol emas</span>
                                @endif
                            </td>
                            <td class="px-4 py-3">
                                <form method="POST" action="{{ route('admin.couriers.toggle', $courier) }}">
                                    @csrf
                                    <button class="text-green-600 hover:underline text-xs">
                                        {{ $courier->is_active ? 'O\'chirish' : 'Faollashtirish' }}
                                    </button>
                                </form>
                            </td>
                        </tr>
                    @empty
                        <tr><td colspan="6" class="px-4 py-8 text-center text-slate-400">Kuryerlar yo'q.</td></tr>
                    @endforelse
                </tbody>
            </table>
            <div class="p-4">{{ $couriers->links() }}</div>
        </div>

        <div class="bg-white rounded-xl shadow-sm p-6">
            <h3 class="font-semibold mb-4">Yangi kuryer qo'shish</h3>
            <form method="POST" action="{{ route('admin.couriers.store') }}" class="space-y-3">
                @csrf
                <div>
                    <label class="block text-xs text-slate-500 mb-1">Ism</label>
                    <input name="name" value="{{ old('name') }}" required class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm">
                    @error('name')<p class="text-red-500 text-xs mt-1">{{ $message }}</p>@enderror
                </div>
                <div>
                    <label class="block text-xs text-slate-500 mb-1">Telefon</label>
                    <input name="phone" value="{{ old('phone') }}" required placeholder="+998901234567" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm">
                    @error('phone')<p class="text-red-500 text-xs mt-1">{{ $message }}</p>@enderror
                </div>
                <div>
                    <label class="block text-xs text-slate-500 mb-1">Parol</label>
                    <input name="password" type="text" required class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm">
                    @error('password')<p class="text-red-500 text-xs mt-1">{{ $message }}</p>@enderror
                </div>
                <button class="w-full bg-green-600 hover:bg-green-700 text-white py-2.5 rounded-lg text-sm font-semibold">Qo'shish</button>
            </form>
        </div>
    </div>
@endsection
