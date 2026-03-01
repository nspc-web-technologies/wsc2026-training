<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Company extends Model
{
    protected $fillable = [
        'company_name',
        'company_address',
        'company_telephone_number',
        'company_email_address',
        'owner_name',
        'owner_mobile_number',
        'owner_email_address',
        'contact_name',
        'contact_mobile_number',
        'contact_email_address',
        'is_active',
    ];

    public function products(){
        return $this->hasMany(Product::class);
    }
}
