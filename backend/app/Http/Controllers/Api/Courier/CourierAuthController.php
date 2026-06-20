<?php

namespace App\Http\Controllers\Api\Courier;

use App\Http\Controllers\Controller;
use App\Models\Courier;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class CourierAuthController extends Controller
{
    use ApiResponse;

    public function login(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'phone' => ['required', 'string'],
            'password' => ['required', 'string'],
        ]);

        if ($validator->fails()) {
            return $this->fail('Ma\'lumotlar noto\'g\'ri', 422, $validator->errors());
        }

        $courier = Courier::where('phone', $request->phone)->first();

        if (! $courier || ! Hash::check($request->password, $courier->password)) {
            return $this->fail('Telefon yoki parol noto\'g\'ri', 401);
        }

        if (! $courier->is_active) {
            return $this->fail('Hisobingiz faol emas. Admin bilan bog\'laning.', 403);
        }

        if ($request->filled('fcm_token')) {
            $courier->update(['fcm_token' => $request->fcm_token]);
        }

        $token = $courier->createToken('courier')->plainTextToken;

        return $this->ok([
            'token' => $token,
            'courier' => $courier->fresh(),
        ], 'Muvaffaqiyatli kirildi');
    }

    public function me(Request $request): JsonResponse
    {
        return $this->ok($request->user());
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return $this->ok(null, 'Tizimdan chiqdingiz');
    }
}
