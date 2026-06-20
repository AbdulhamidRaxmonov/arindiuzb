<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Application;
use App\Models\Courier;
use App\Models\User;
use App\Models\WithdrawalRequest;
use Illuminate\View\View;

class DashboardController extends Controller
{
    public function index(): View
    {
        $stats = [
            'users' => User::count(),
            'couriers' => Courier::count(),
            'applications_total' => Application::count(),
            'applications_pending' => Application::where('status', Application::STATUS_PENDING)->count(),
            'applications_collected' => Application::where('status', Application::STATUS_COLLECTED)->count(),
            'applications_verified' => Application::where('status', Application::STATUS_VERIFIED)->count(),
            'withdrawals_pending' => WithdrawalRequest::where('status', WithdrawalRequest::STATUS_PENDING)->count(),
            'total_paid' => WithdrawalRequest::where('status', WithdrawalRequest::STATUS_PAID)->sum('amount'),
            'total_credited' => Application::where('status', Application::STATUS_VERIFIED)->sum('credited_amount'),
            'total_weight' => Application::where('status', Application::STATUS_VERIFIED)->sum('weight_kg'),
        ];

        $recentApplications = Application::with('user:id,name,phone')
            ->latest()
            ->limit(8)
            ->get();

        $pendingWithdrawals = WithdrawalRequest::with('user:id,name,phone')
            ->where('status', WithdrawalRequest::STATUS_PENDING)
            ->latest()
            ->limit(8)
            ->get();

        return view('admin.dashboard', compact('stats', 'recentApplications', 'pendingWithdrawals'));
    }
}
