<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('companies', function (Blueprint $table) {
            $table->id();
            $table->string('company_name', 255);
            $table->text('company_address');
            $table->string('company_telephone_number', 50);
            $table->string('company_email_address', 50);
            $table->string('owner_name', 255);
            $table->string('owner_mobile_number', 50);
            $table->string('owner_email_address', 255);
            $table->string('contact_name', 255);
            $table->string('contact_mobile_number', 50);
            $table->string('contact_email_address', 255);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }
    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('companies');
    }
};
