<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\WithdrawalRequest;
use App\Services\NotificationService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\View\View;

class WithdrawalController extends Controller
{
    public function index(Request $request): View
    {
        $query = WithdrawalRequest::with('user:id,name,phone');

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        $withdrawals = $query->latest()->paginate(20)->withQueryString();

        return view('admin.withdrawals.index', compact('withdrawals'));
    }

    /**
     * Mark a withdrawal as paid and notify the user that the money was sent.
     * Funds were already reserved (debited) when the request was created.
     */
    public function pay(Request $request, WithdrawalRequest $withdrawal, NotificationService $notifications): RedirectResponse
    {
        if ($withdrawal->status !== WithdrawalRequest::STATUS_PENDING) {
            return back()->with('error', 'Bu so\'rov allaqachon ko\'rib chiqilgan.');
        }

        $validated = $request->validate([
            'admin_note' => ['nullable', 'string', 'max:500'],
        ]);

        $withdrawal->update([
            'status' => WithdrawalRequest::STATUS_PAID,
            'admin_note' => $validated['admin_note'] ?? null,
            'paid_at' => Carbon::now(),
        ]);

        $notifications->send(
            $withdrawal->user,
            'To\'lov amalga oshirildi',
            "Siz yuborgan {$withdrawal->amount} so'mlik pul yechish so'rovi bo'yicha to'lov qilindi.",
            'withdrawal',
            ['withdrawal_id' => $withdrawal->id, 'amount' => (float) $withdrawal->amount]
        );

        return back()->with('success', 'To\'lov belgilandi va foydalanuvchiga bildirishnoma yuborildi.');
    }

    /** Reject a request and refund the reserved amount back to the user balance. */
    public function reject(Request $request, WithdrawalRequest $withdrawal, NotificationService $notifications): RedirectResponse
    {
        if ($withdrawal->status !== WithdrawalRequest::STATUS_PENDING) {
            return back()->with('error', 'Bu so\'rov allaqachon ko\'rib chiqilgan.');
        }

        $validated = $request->validate([
            'admin_note' => ['nullable', 'string', 'max:500'],
        ]);

        DB::transaction(function () use ($withdrawal, $validated, $notifications) {
            $withdrawal->update([
                'status' => WithdrawalRequest::STATUS_REJECTED,
                'admin_note' => $validated['admin_note'] ?? null,
            ]);

            // Return the reserved funds.
            $withdrawal->user->creditBalance((float) $withdrawal->amount);

            $notifications->send(
                $withdrawal->user,
                'Pul yechish so\'rovi rad etildi',
                "Pul yechish so'rovingiz rad etildi va {$withdrawal->amount} so'm balansingizga qaytarildi.",
                'withdrawal',
                ['withdrawal_id' => $withdrawal->id]
            );
        });

        return back()->with('success', 'So\'rov rad etildi va mablag\' qaytarildi.');
    }
}
