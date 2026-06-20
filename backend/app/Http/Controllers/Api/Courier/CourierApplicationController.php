<?php

namespace App\Http\Controllers\Api\Courier;

use App\Http\Controllers\Controller;
use App\Models\Application;
use App\Services\NotificationService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Validator;

class CourierApplicationController extends Controller
{
    use ApiResponse;

    /**
     * Available (pending) requests + the ones already assigned to this courier.
     * Supports ?status= filter (pending|accepted|collected|verified).
     */
    public function index(Request $request): JsonResponse
    {
        $courierId = $request->user()->id;

        $query = Application::with('user:id,name,phone')
            ->where(function ($q) use ($courierId) {
                $q->where('status', Application::STATUS_PENDING)
                    ->orWhere('courier_id', $courierId);
            });

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        return $this->ok($query->latest()->paginate(20));
    }

    public function show(Request $request, Application $application): JsonResponse
    {
        return $this->ok($application->load('user:id,name,phone'));
    }

    /** Courier takes ownership of a pending request. */
    public function accept(Request $request, Application $application): JsonResponse
    {
        if ($application->status !== Application::STATUS_PENDING) {
            return $this->fail('Bu zayafka allaqachon olingan', 422);
        }

        $application->update([
            'courier_id' => $request->user()->id,
            'status' => Application::STATUS_ACCEPTED,
            'accepted_at' => Carbon::now(),
        ]);

        return $this->ok($application->fresh(), 'Zayafka qabul qilindi');
    }

    /**
     * Courier finishes collection: "qabul qildim" + optional comment.
     * Moves the application to `collected`, awaiting admin verification.
     */
    public function complete(Request $request, Application $application, NotificationService $notifications): JsonResponse
    {
        if ($application->courier_id !== $request->user()->id) {
            return $this->fail('Bu zayafka sizga tegishli emas', 403);
        }

        if (! in_array($application->status, [Application::STATUS_ACCEPTED, Application::STATUS_PENDING])) {
            return $this->fail('Bu zayafkani yakunlab bo\'lmaydi', 422);
        }

        $validator = Validator::make($request->all(), [
            'courier_comment' => ['nullable', 'string', 'max:1000'],
            'weight_kg' => ['nullable', 'numeric', 'min:0.1'],
        ]);

        if ($validator->fails()) {
            return $this->fail('Ma\'lumotlar noto\'g\'ri', 422, $validator->errors());
        }

        $application->update([
            'status' => Application::STATUS_COLLECTED,
            'courier_comment' => $request->courier_comment,
            'weight_kg' => $request->weight_kg ?: $application->weight_kg,
            'collected_at' => Carbon::now(),
        ]);

        $notifications->send(
            $application->user,
            'Zayafkangiz qabul qilindi',
            'Kuryer chiqindingizni qabul qildi. Admin tekshirgach balansingizga pul qo\'shiladi.',
            'application',
            ['application_id' => $application->id]
        );

        return $this->ok($application->fresh(), 'Qabul qildim - zayafka yakunlandi');
    }
}
