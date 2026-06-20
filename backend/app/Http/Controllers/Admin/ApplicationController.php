<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Application;
use App\Services\NotificationService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\View\View;

class ApplicationController extends Controller
{
    public function index(Request $request): View
    {
        $query = Application::with(['user:id,name,phone', 'courier:id,name,phone']);

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->whereHas('user', function ($q) use ($search) {
                $q->where('name', 'like', "%$search%")
                    ->orWhere('phone', 'like', "%$search%");
            });
        }

        $applications = $query->latest()->paginate(20)->withQueryString();

        return view('admin.applications.index', compact('applications'));
    }

    public function show(Application $application): View
    {
        $application->load(['user', 'courier']);

        return view('admin.applications.show', compact('application'));
    }

    /**
     * Verify a collected application and credit the user's balance
     * (weight_kg * price_per_kg, default 300 so'm/kg).
     */
    public function verify(Request $request, Application $application, NotificationService $notifications): RedirectResponse
    {
        if ($application->status !== Application::STATUS_COLLECTED) {
            return back()->with('error', 'Faqat kuryer yakunlagan (collected) zayafkani tasdiqlash mumkin.');
        }

        $validated = $request->validate([
            'weight_kg' => ['nullable', 'numeric', 'min:0.1'],
            'price_per_kg' => ['nullable', 'numeric', 'min:0'],
        ]);

        DB::transaction(function () use ($application, $validated, $notifications) {
            $weight = $validated['weight_kg'] ?? $application->weight_kg;
            $price = $validated['price_per_kg'] ?? ($application->price_per_kg ?: config('arindi.price_per_kg'));
            $amount = round($weight * $price, 2);

            $application->update([
                'status' => Application::STATUS_VERIFIED,
                'weight_kg' => $weight,
                'price_per_kg' => $price,
                'credited_amount' => $amount,
                'verified_at' => Carbon::now(),
            ]);

            $application->user->creditBalance($amount);

            $notifications->send(
                $application->user,
                'Balansingiz to\'ldirildi',
                "Zayafkangiz tekshirildi. Hisobingizga {$amount} so'm qo'shildi ({$weight} kg).",
                'application',
                ['application_id' => $application->id, 'amount' => $amount]
            );
        });

        return back()->with('success', 'Zayafka tasdiqlandi va foydalanuvchi balansiga pul qo\'shildi.');
    }

    public function cancel(Application $application): RedirectResponse
    {
        $application->update(['status' => Application::STATUS_CANCELLED]);

        return back()->with('success', 'Zayafka bekor qilindi.');
    }
}
