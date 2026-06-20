<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\WithdrawalRequest;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class WithdrawalController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $withdrawals = $request->user()->withdrawals()->latest()->paginate(20);

        return $this->ok($withdrawals);
    }

    public function store(Request $request): JsonResponse
    {
        $min = (int) config('arindi.min_withdrawal');

        $validator = Validator::make($request->all(), [
            'amount' => ['required', 'numeric', "min:$min"],
            'card_number' => ['required', 'string', 'min:12', 'max:25'],
            'card_holder' => ['required', 'string', 'max:120'],
        ]);

        if ($validator->fails()) {
            return $this->fail("Yechish summasi kamida $min so'm bo'lishi kerak", 422, $validator->errors());
        }

        $user = $request->user();
        $amount = (float) $request->amount;

        if ($amount > (float) $user->balance) {
            return $this->fail('Balansingizda yetarli mablag\' yo\'q', 422);
        }

        $withdrawal = DB::transaction(function () use ($user, $request, $amount) {
            // Reserve the funds immediately so the balance reflects the pending request.
            $user->debitBalance($amount);

            return WithdrawalRequest::create([
                'user_id' => $user->id,
                'amount' => $amount,
                'card_number' => $request->card_number,
                'card_holder' => $request->card_holder,
                'status' => WithdrawalRequest::STATUS_PENDING,
            ]);
        });

        return $this->ok(
            $withdrawal,
            'Tez orada admin tekshirib pul tashlab beriladi.',
            201
        );
    }
}
