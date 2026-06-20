<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $notifications = $request->user()->notifications()->latest()->paginate(30);

        return $this->ok([
            'notifications' => $notifications,
            'unread_count' => $request->user()->notifications()->where('is_read', false)->count(),
        ]);
    }

    public function markRead(Request $request, AppNotification $notification): JsonResponse
    {
        if ($notification->user_id !== $request->user()->id) {
            return $this->fail('Ruxsat yo\'q', 403);
        }

        $notification->update(['is_read' => true]);

        return $this->ok($notification);
    }

    public function markAllRead(Request $request): JsonResponse
    {
        $request->user()->notifications()->where('is_read', false)->update(['is_read' => true]);

        return $this->ok(null, 'Barchasi o\'qildi deb belgilandi');
    }
}
