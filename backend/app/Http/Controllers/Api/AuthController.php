<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\OtpCode;
use App\Models\User;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    use ApiResponse;

    /**
     * Step 1: user submits phone number, we generate an OTP code.
     * In production this would be sent via SMS. For development we return it.
     */
    public function requestOtp(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'phone' => ['required', 'string', 'regex:/^\+?[0-9]{9,15}$/'],
        ]);

        if ($validator->fails()) {
            return $this->fail('Telefon raqami noto\'g\'ri', 422, $validator->errors());
        }

        $phone = $this->normalizePhone($request->phone);
        $code = (string) random_int(100000, 999999);

        OtpCode::create([
            'phone' => $phone,
            'code' => $code,
            'expires_at' => Carbon::now()->addMinutes(5),
        ]);

        // TODO: integrate an SMS gateway (e.g. Eskiz, Play Mobile) to deliver $code.
        return $this->ok([
            'phone' => $phone,
            'expires_in' => 300,
            // Exposed only in non-production to ease testing.
            'debug_code' => app()->environment('production') ? null : $code,
        ], 'Tasdiqlash kodi yuborildi');
    }

    /**
     * Step 2: verify OTP, create the user if needed and return an API token.
     */
    public function verifyOtp(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'phone' => ['required', 'string'],
            'code' => ['required', 'string', 'size:6'],
            'name' => ['nullable', 'string', 'max:120'],
        ]);

        if ($validator->fails()) {
            return $this->fail('Ma\'lumotlar noto\'g\'ri', 422, $validator->errors());
        }

        $phone = $this->normalizePhone($request->phone);

        $otp = OtpCode::where('phone', $phone)
            ->where('code', $request->code)
            ->whereNull('used_at')
            ->where('expires_at', '>=', Carbon::now())
            ->latest()
            ->first();

        if (! $otp) {
            return $this->fail('Kod noto\'g\'ri yoki muddati tugagan', 422);
        }

        $otp->update(['used_at' => Carbon::now()]);

        $user = User::firstOrCreate(
            ['phone' => $phone],
            ['name' => $request->name, 'phone_verified_at' => Carbon::now()]
        );

        if ($request->filled('name') && ! $user->name) {
            $user->update(['name' => $request->name]);
        }

        $token = $user->createToken('mobile')->plainTextToken;

        return $this->ok([
            'token' => $token,
            'user' => $user->fresh(),
        ], 'Muvaffaqiyatli kirildi');
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return $this->ok(null, 'Tizimdan chiqdingiz');
    }

    private function normalizePhone(string $phone): string
    {
        $digits = preg_replace('/\D/', '', $phone);

        if (str_starts_with($digits, '998')) {
            return '+'.$digits;
        }

        if (strlen($digits) === 9) {
            return '+998'.$digits;
        }

        return '+'.$digits;
    }
}
