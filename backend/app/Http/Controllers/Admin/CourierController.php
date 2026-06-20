<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Courier;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\View\View;

class CourierController extends Controller
{
    public function index(): View
    {
        $couriers = Courier::withCount('applications')->latest()->paginate(20);

        return view('admin.couriers.index', compact('couriers'));
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'phone' => ['required', 'string', 'unique:couriers,phone'],
            'password' => ['required', 'string', 'min:6'],
        ]);

        Courier::create([
            'name' => $validated['name'],
            'phone' => $validated['phone'],
            'password' => Hash::make($validated['password']),
            'is_active' => true,
        ]);

        return back()->with('success', 'Kuryer qo\'shildi.');
    }

    public function toggle(Courier $courier): RedirectResponse
    {
        $courier->update(['is_active' => ! $courier->is_active]);

        return back()->with('success', 'Kuryer holati o\'zgartirildi.');
    }
}
