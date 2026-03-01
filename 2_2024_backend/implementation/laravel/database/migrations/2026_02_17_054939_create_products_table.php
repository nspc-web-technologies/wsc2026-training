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
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->string('gtin',14)->unique()->index();
            $table->string('name',255);
            $table->string('name_in_french',255);
            $table->text('description');
            $table->text('description_in_french');
            $table->string('brand_name',255);
            $table->string('country_of_origin',255);
            $table->decimal('gross_weight_with_packaging',10,3);
            $table->decimal('net_content_weight',10,3);
            $table->string('weight_unit',10);
            $table->string('image_path',512)->nullable();
            $table->boolean('is_hidden')->default(false);
            $table->foreignId('company_id')->constrained('companies')->onDelete('cascade');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
