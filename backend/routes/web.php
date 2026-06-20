<?php

use App\Http\Controllers\Admin\ApplicationController;
use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\CourierController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\WithdrawalController;
use Illuminate\Support\Facades\Route;

Route::get('/', fn () => redirect()->route('admin.dashboard'));

Route::prefix('admin')->name('admin.')->group(function () {
    // Guest
    Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [AuthController::class, 'login'])->name('login.attempt');

    // Authenticated admin
    Route::middleware('admin.auth')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

        Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');

        // Applications (zayafkalar)
        Route::get('/applications', [ApplicationController::class, 'index'])->name('applications.index');
        Route::get('/applications/{application}', [ApplicationController::class, 'show'])->name('applications.show');
        Route::post('/applications/{application}/verify', [ApplicationController::class, 'verify'])->name('applications.verify');
        Route::post('/applications/{application}/cancel', [ApplicationController::class, 'cancel'])->name('applications.cancel');

        // Withdrawals (pul yechish so'rovlari)
        Route::get('/withdrawals', [WithdrawalController::class, 'index'])->name('withdrawals.index');
        Route::post('/withdrawals/{withdrawal}/pay', [WithdrawalController::class, 'pay'])->name('withdrawals.pay');
        Route::post('/withdrawals/{withdrawal}/reject', [WithdrawalController::class, 'reject'])->name('withdrawals.reject');

        // Couriers
        Route::get('/couriers', [CourierController::class, 'index'])->name('couriers.index');
        Route::post('/couriers', [CourierController::class, 'store'])->name('couriers.store');
        Route::post('/couriers/{courier}/toggle', [CourierController::class, 'toggle'])->name('couriers.toggle');
    });
});
