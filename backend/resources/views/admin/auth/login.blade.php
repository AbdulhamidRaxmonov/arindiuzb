<!DOCTYPE html>
<html lang="uz" class="h-full">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Kirish — Arindi Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="h-full bg-gradient-to-br from-green-600 to-emerald-800 flex items-center justify-center p-4">
    <div class="w-full max-w-md bg-white rounded-2xl shadow-xl p-8">
        <div class="text-center mb-6">
            <div class="text-4xl mb-2">♻️</div>
            <h1 class="text-2xl font-bold text-slate-800">Arindi Admin</h1>
            <p class="text-slate-500 text-sm">Boshqaruv paneliga kiring</p>
        </div>

        @if ($errors->any())
            <div class="mb-4 rounded-lg bg-red-100 border border-red-300 text-red-800 px-4 py-3 text-sm">
                {{ $errors->first() }}
            </div>
        @endif

        <form method="POST" action="{{ route('admin.login.attempt') }}" class="space-y-4">
            @csrf
            <div>
                <label class="block text-sm font-medium text-slate-700 mb-1">Email</label>
                <input type="email" name="email" value="{{ old('email') }}" required autofocus
                       class="w-full rounded-lg border-slate-300 border px-3 py-2.5 focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none"
                       placeholder="admin@arindi.uz">
            </div>
            <div>
                <label class="block text-sm font-medium text-slate-700 mb-1">Parol</label>
                <input type="password" name="password" required
                       class="w-full rounded-lg border-slate-300 border px-3 py-2.5 focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none"
                       placeholder="••••••••">
            </div>
            <label class="flex items-center gap-2 text-sm text-slate-600">
                <input type="checkbox" name="remember" class="rounded border-slate-300"> Eslab qolish
            </label>
            <button type="submit"
                    class="w-full bg-green-600 hover:bg-green-700 text-white font-semibold py-2.5 rounded-lg transition">
                Kirish
            </button>
        </form>
    </div>
</body>
</html>
