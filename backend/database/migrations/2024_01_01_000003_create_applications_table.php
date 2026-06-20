<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('applications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('courier_id')->nullable()->constrained()->nullOnDelete();

            // Waste category: pochoq | botilka | plasmassa | maklatura
            $table->string('type')->default('pochoq');

            $table->decimal('weight_kg', 8, 2);
            $table->string('address');
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->text('comment')->nullable();
            $table->string('photo')->nullable();

            // pending -> accepted -> collected -> verified | cancelled
            $table->string('status')->default('pending');

            // Money credited to the user when an admin verifies the application.
            $table->decimal('credited_amount', 12, 2)->default(0);
            $table->decimal('price_per_kg', 8, 2)->default(300);

            // Comment written by the courier while collecting.
            $table->text('courier_comment')->nullable();

            $table->timestamp('accepted_at')->nullable();
            $table->timestamp('collected_at')->nullable();
            $table->timestamp('verified_at')->nullable();
            $table->timestamps();

            $table->index(['status', 'type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('applications');
    }
};
