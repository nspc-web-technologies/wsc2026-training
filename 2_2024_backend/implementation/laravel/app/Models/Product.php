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

    // tricky: $primaryKey = 'gtin' を設定すると Eloquent は gtin をプライマリキーとして扱い、
    // Route Model Binding（URL の {product} からモデルを自動取得する機能）も gtin で解決する。しかし DB の主キーは id のまま
    // → 意図的なら $incrementing = false と $keyType = 'string' の両方が必要
    //   （例: protected $primaryKey = 'gtin'; public $incrementing = false; protected $keyType = 'string';）
    // → 意図しないなら $primaryKey を削除して getRouteKeyName() で gtin を返す方が安全
    public function getRouteKeyName()
    {
        return 'gtin';
    }

    public function company(){
        return $this->belongsTo(Company::class);
    }
}
