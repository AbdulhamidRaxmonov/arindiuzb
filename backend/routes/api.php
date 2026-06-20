<?php

use App\Http\Controllers\Api\ApplicationController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\Courier\CourierApplicationController;
use App\Http\Controllers\Api\Courier\CourierAuthController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\WithdrawalController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Public endpoints
|--------------------------------------------------------------------------
*/
Route::get('/health', fn () => response()->json(['status' => 'ok', 'app' => 'Arindi API']));
Route::get('/categories', [ApplicationController::class, 'categories']);

/*
|--------------------------------------------------------------------------
| User mobile app
|--------------------------------------------------------------------------
*/
Route::prefix('auth')->group(function () {
    Route::post('/request-otp', [AuthController::class, 'requestOtp']);
    Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);
});

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    // Profile & settings
    Route::get('/profile', [ProfileController::class, 'show']);
    Route::post('/profile', [ProfileController::class, 'update']);
    Route::get('/balance', [ProfileController::class, 'balance']);

    // Applications (zayafka)
    Route::get('/applications', [ApplicationController::class, 'index']);
    Route::post('/applications', [ApplicationController::class, 'store']);
    Route::get('/applications/{application}', [ApplicationController::class, 'show']);
    Route::post('/applications/{application}/cancel', [ApplicationController::class, 'cancel']);

    // Withdrawals (pul yechish)
    Route::get('/withdrawals', [WithdrawalController::class, 'index']);
    Route::post('/withdrawals', [WithdrawalController::class, 'store']);

    // Notifications
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/{notification}/read', [NotificationController::class, 'markRead']);
    Route::post('/notifications/read-all', [NotificationController::class, 'markAllRead']);
});

/*
|--------------------------------------------------------------------------
| Courier mobile app
|--------------------------------------------------------------------------
*/
Route::prefix('courier')->group(function () {
    Route::post('/login', [CourierAuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/me', [CourierAuthController::class, 'me']);
        Route::post('/logout', [CourierAuthController::class, 'logout']);

        Route::get('/applications', [CourierApplicationController::class, 'index']);
        Route::get('/applications/{application}', [CourierApplicationController::class, 'show']);
        Route::post('/applications/{application}/accept', [CourierApplicationController::class, 'accept']);
        Route::post('/applications/{application}/complete', [CourierApplicationController::class, 'complete']);
    });
});
