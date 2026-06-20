<?php

namespace App\Services;

use App\Models\AppNotification;
use App\Models\User;

class NotificationService
{
    /**
     * Persist a notification for the user. If the user has an FCM token, this is
     * also where you would dispatch a push notification (left as an integration point).
     */
    public function send(User $user, string $title, string $body, string $type = 'info', array $data = []): AppNotification
    {
        $notification = $user->notifications()->create([
            'title' => $title,
            'body' => $body,
            'type' => $type,
            'data' => $data,
        ]);

        // Integration point for Firebase Cloud Messaging / SMS.
        // if ($user->fcm_token) { $this->pushToFcm($user->fcm_token, $title, $body, $data); }

        return $notification;
    }
}
