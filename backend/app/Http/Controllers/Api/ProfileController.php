<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class ProfileController extends Controller
{
    use ApiResponse;

    public function show(Request $request): JsonResponse
    {
        return $this->ok($request->user());
    }

    public function update(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => ['nullable', 'string', 'max:120'],
            'language' => ['nullable', 'in:uz,ru,en'],
            'dark_mode' => ['nullable', 'boolean'],
            'fcm_token' => ['nullable', 'string'],
            'avatar' => ['nullable', 'image', 'max:4096'],
        ]);

        if ($validator->fails()) {
            return $this->fail('Ma\'lumotlar noto\'g\'ri', 422, $validator->errors());
        }

        $user = $request->user();
        $data = $request->only(['name', 'language', 'dark_mode', 'fcm_token']);

        if ($request->hasFile('avatar')) {
            if ($user->avatar) {
                Storage::disk('public')->delete($user->avatar);
            }
            $data['avatar'] = $request->file('avatar')->store('avatars', 'public');
        }

        $user->update(array_filter($data, fn ($v) => ! is_null($v)));

        return $this->ok($user->fresh(), 'Profil yangilandi');
    }

    public function balance(Request $request): JsonResponse
    {
        $user = $request->user();

        return $this->ok([
            'balance' => (float) $user->balance,
            'min_withdrawal' => (int) config('arindi.min_withdrawal'),
            'can_withdraw' => (float) $user->balance >= (float) config('arindi.min_withdrawal'),
        ]);
    }
}
