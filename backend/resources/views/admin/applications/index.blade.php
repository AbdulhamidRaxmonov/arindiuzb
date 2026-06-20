@extends('admin.layouts.app')

@section('title', 'Zayafkalar')

@section('content')
    <form method="GET" class="bg-white rounded-xl shadow-sm p-4 mb-4 flex flex-wrap gap-3 items-end">
        <div>
            <label class="block text-xs text-slate-500 mb-1">Status</label>
            <select name="status" class="rounded-lg border border-slate-300 px-3 py-2 text-sm">
                <option value="">Barchasi</option>
                @foreach (['pending'=>'Yangi','accepted'=>'Qabul qilingan','collected'=>'Yakunlangan','verified'=>'Tekshirildi','cancelled'=>'Bekor qilingan'] as $k=>$v)
                    <option value="{{ $k }}" @selected(request('status')===$k)>{{ $v }}</option>
                @endforeach
            </select>
        </div>
        <div>
            <label class="block text-xs text-slate-500 mb-1">Tur</label>
            <select name="type" class="rounded-lg border border-slate-300 px-3 py-2 text-sm">
                <option value="">Barchasi</option>
                @foreach (['pochoq'=>"Po'choq",'botilka'=>'Bo\'tilka','plasmassa'=>'Plasmassa','maklatura'=>'Maklatura'] as $k=>$v)
                    <option value="{{ $k }}" @selected(request('type')===$k)>{{ $v }}</option>
                @endforeach
            </select>
        </div>
        <div class="flex-1 min-w-[180px]">
            <label class="block text-xs text-slate-500 mb-1">Qidiruv (ism/telefon)</label>
            <input name="search" value="{{ request('search') }}" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm" placeholder="Qidirish...">
        </div>
        <button class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg text-sm">Filtrlash</button>
    </form>

    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
        <table class="w-full text-sm">
            <thead class="bg-slate-50 text-slate-500 text-left">
                <tr>
                    <th class="px-4 py-3">#</th>
                    <th class="px-4 py-3">Foydalanuvchi</th>
                    <th class="px-4 py-3">Tur</th>
                    <th class="px-4 py-3">Og'irlik</th>
                    <th class="px-4 py-3">Taxminiy summa</th>
                    <th class="px-4 py-3">Kuryer</th>
                    <th class="px-4 py-3">Status</th>
                    <th class="px-4 py-3">Sana</th>
                    <th class="px-4 py-3"></th>
                </tr>
            </thead>
            <tbody class="divide-y">
                @forelse ($applications as $app)
                    <tr class="hover:bg-slate-50">
                        <td class="px-4 py-3 text-slate-400">{{ $app->id }}</td>
                        <td class="px-4 py-3">
                            <div class="font-medium">{{ $app->user->name ?? '—' }}</div>
                            <div class="text-slate-400 text-xs">{{ $app->user->phone }}</div>
                        </td>
                        <td class="px-4 py-3 capitalize">{{ $app->type }}</td>
                        <td class="px-4 py-3">{{ $app->weight_kg }} kg</td>
                        <td class="px-4 py-3">{{ number_format($app->estimated_amount) }} so'm</td>
                        <td class="px-4 py-3">{{ $app->courier->name ?? '—' }}</td>
                        <td class="px-4 py-3">@include('admin.partials.status', ['status' => $app->status])</td>
                        <td class="px-4 py-3 text-slate-400 text-xs">{{ $app->created_at->format('d.m.Y H:i') }}</td>
                        <td class="px-4 py-3">
                            <a href="{{ route('admin.applications.show', $app) }}" class="text-green-600 hover:underline">Ko'rish</a>
                        </td>
                    </tr>
                @empty
                    <tr><td colspan="9" class="px-4 py-8 text-center text-slate-400">Zayafkalar topilmadi.</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="mt-4">{{ $applications->links() }}</div>
@endsection
