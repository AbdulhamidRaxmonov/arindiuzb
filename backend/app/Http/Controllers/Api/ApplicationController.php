<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Application;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ApplicationController extends Controller
{
    use ApiResponse;

    /** List the authenticated user's applications. */
    public function index(Request $request): JsonResponse
    {
        $applications = $request->user()
            ->applications()
            ->with('courier:id,name,phone')
            ->latest()
            ->paginate(20);

        return $this->ok($applications);
    }

    public function show(Request $request, Application $application): JsonResponse
    {
        if ($application->user_id !== $request->user()->id) {
            return $this->fail('Ruxsat yo\'q', 403);
        }

        return $this->ok($application->load('courier:id,name,phone'));
    }

    /** Create a new collection request. Only active categories are accepted. */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'type' => ['required', 'string', 'in:pochoq,botilka,plasmassa,maklatura'],
            'weight_kg' => ['required', 'numeric', 'min:0.1', 'max:100000'],
            'address' => ['required', 'string', 'max:500'],
            'latitude' => ['nullable', 'numeric', 'between:-90,90'],
            'longitude' => ['nullable', 'numeric', 'between:-180,180'],
            'comment' => ['nullable', 'string', 'max:1000'],
            'photo' => ['nullable', 'image', 'max:6144'],
        ]);

        if ($validator->fails()) {
            return $this->fail('Ma\'lumotlar noto\'g\'ri', 422, $validator->errors());
        }

        $categories = config('arindi.categories');
        $type = $request->type;

        if (! ($categories[$type]['active'] ?? false)) {
            return $this->fail('Bu bo\'lim hozircha ishlamaydi. Tez orada ishga tushadi!', 422);
        }

        $data = [
            'user_id' => $request->user()->id,
            'type' => $type,
            'weight_kg' => $request->weight_kg,
            'address' => $request->address,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'comment' => $request->comment,
            'status' => Application::STATUS_PENDING,
            'price_per_kg' => config('arindi.price_per_kg'),
        ];

        if ($request->hasFile('photo')) {
            $data['photo'] = $request->file('photo')->store('applications', 'public');
        }

        $application = Application::create($data);

        return $this->ok($application, 'Zayafka qabul qilindi. Tez orada kuryer aloqaga chiqadi.', 201);
    }

    public function cancel(Request $request, Application $application): JsonResponse
    {
        if ($application->user_id !== $request->user()->id) {
            return $this->fail('Ruxsat yo\'q', 403);
        }

        if ($application->status !== Application::STATUS_PENDING) {
            return $this->fail('Bu zayafkani bekor qilib bo\'lmaydi', 422);
        }

        $application->update(['status' => Application::STATUS_CANCELLED]);

        return $this->ok($application, 'Zayafka bekor qilindi');
    }

    /** Returns the configured categories so the app can render the home grid. */
    public function categories(): JsonResponse
    {
        $categories = collect(config('arindi.categories'))->map(function ($info, $key) {
            return [
                'key' => $key,
                'label' => $info['label'],
                'active' => (bool) $info['active'],
            ];
        })->values();

        return $this->ok([
            'categories' => $categories,
            'price_per_kg' => (int) config('arindi.price_per_kg'),
        ]);
    }
}
