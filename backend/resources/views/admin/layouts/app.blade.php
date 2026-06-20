<!DOCTYPE html>
<html lang="uz" class="h-full">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Admin') — Arindi</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: { extend: { colors: { brand: { DEFAULT: '#16a34a', dark: '#15803d', light: '#dcfce7' } } } }
        }
    </script>
    <style>[x-cloak]{display:none}</style>
</head>
<body class="h-full bg-slate-100 text-slate-800">
<div class="min-h-full flex">
    {{-- Sidebar --}}
    <aside class="w-64 bg-slate-900 text-slate-200 flex-shrink-0 hidden md:flex md:flex-col">
        <div class="px-6 py-5 border-b border-slate-700 flex items-center gap-2">
            <span class="text-2xl">♻️</span>
            <span class="text-xl font-bold text-white">Arindi</span>
        </div>
        <nav class="flex-1 px-3 py-4 space-y-1 text-sm">
            @php
                $nav = [
                    ['admin.dashboard', 'Dashboard', '📊'],
                    ['admin.applications.index', 'Zayafkalar', '📦'],
                    ['admin.withdrawals.index', 'Pul yechish', '💸'],
                    ['admin.couriers.index', 'Kuryerlar', '🚚'],
                ];
            @endphp
            @foreach ($nav as [$route, $label, $icon])
                <a href="{{ route($route) }}"
                   class="flex items-center gap-3 px-3 py-2.5 rounded-lg transition
                   {{ request()->routeIs($route.'*') || request()->routeIs(str_replace('.index','',$route).'*') ? 'bg-brand text-white' : 'hover:bg-slate-800' }}">
                    <span>{{ $icon }}</span> {{ $label }}
                </a>
            @endforeach
        </nav>
        <form method="POST" action="{{ route('admin.logout') }}" class="p-3 border-t border-slate-700">
            @csrf
            <button class="w-full text-left px-3 py-2.5 rounded-lg hover:bg-slate-800 text-sm text-red-300">
                🚪 Chiqish
            </button>
        </form>
    </aside>

    {{-- Main --}}
    <div class="flex-1 flex flex-col min-w-0">
        <header class="bg-white border-b px-6 py-4 flex items-center justify-between sticky top-0 z-10">
            <h1 class="text-lg font-semibold">@yield('title', 'Admin')</h1>
            <div class="text-sm text-slate-500">
                {{ auth('admin')->user()?->name }} · {{ auth('admin')->user()?->email }}
            </div>
        </header>

        <main class="p-6 flex-1">
            @if (session('success'))
                <div class="mb-4 rounded-lg bg-green-100 border border-green-300 text-green-800 px-4 py-3">
                    {{ session('success') }}
                </div>
            @endif
            @if (session('error'))
                <div class="mb-4 rounded-lg bg-red-100 border border-red-300 text-red-800 px-4 py-3">
                    {{ session('error') }}
                </div>
            @endif

            @yield('content')
        </main>
    </div>
</div>
</body>
</html>
