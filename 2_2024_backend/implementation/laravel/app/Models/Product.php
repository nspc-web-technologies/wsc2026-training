<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    protected $fillable = [
        'gtin',
        'name',
        'name_in_french',
        'description',
        'description_in_french',
        'brand_name',
        'country_of_origin',
        'gross_weight_with_packaging',
        'net_content_weight',
        'weight_unit',
        'image_path',
        'is_hidden',
        'company_id',
    ];

    protected $primaryKey = 'gtin';

    public function company(){
        return $this->belongsTo(Company::class);
    }
}
