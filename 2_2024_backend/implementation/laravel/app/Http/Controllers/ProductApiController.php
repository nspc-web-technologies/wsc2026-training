<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class ProductApiController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        try {
            $validated = $request->validate([
                'query' => 'nullable',
            ]);

            $products = Product::where('is_hidden', false)->when(isset($validated['query']), function ($q) use ($validated) {
                $q->where('name', 'LIKE', '%' . $validated['query'] . '%')
                    ->orWhere('name_in_french', 'LIKE', '%' . $validated['query'] . '%')
                    ->orWhere('description', 'LIKE', '%' . $validated['query'] . '%')
                    ->orWhere('description_in_french', 'LIKE', '%' . $validated['query'] . '%');
            })->with('company')->paginate(10)->toArray();

            return response([
                'data' => array_map(function ($r) {
                    return [
                        "name" => [
                            "en" => $r['name'],
                            "fr" => $r['name_in_french']
                        ],
                        "description" => [
                            "en" => $r['description'],
                            "fr" => $r['description_in_french']
                        ],
                        "gtin" => $r['gtin'],
                        "brand" => $r['brand_name'],
                        "countryOfOrigin" => $r['country_of_origin'],
                        "weight" => [
                            "gross" => $r['gross_weight_with_packaging'],
                            "net" => $r['net_content_weight'],
                            "unit" => $r['weight_unit']
                        ],
                        "company" => [
                            "companyName" => $r['company']['company_name'],
                            "companyAddress" => $r['company']['company_address'],
                            "companyTelephone" => $r['company']['company_telephone_number'],
                            "companyEmail" => $r['company']['company_email_address'],
                            "owner" => [
                                "name" => $r['company']['owner_name'],
                                "mobileNumber" => $r['company']['owner_mobile_number'],
                                "email" => $r['company']['owner_email_address']
                            ],
                            "contact" => [
                                "name" => $r['company']['contact_name'],
                                "mobileNumber" => $r['company']['contact_mobile_number'],
                                "email" => $r['company']['contact_email_address']
                            ]
                        ]
                    ];
                }, $products['data']),
                'pagination' => [
                    'current_page' => $products['current_page'],
                    'total_pages' => $products['last_page'],
                    'per_page' => $products['per_page'],
                    'next_page_url' => $products['next_page_url'],
                    'prev_page_url' => $products['prev_page_url'],
                ],
            ], 200);
        } catch (ValidationException $ve) {
            // dd($ve);
            abort(404);
        }
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        //
    }

    /**
     * Display the specified resource.
     */
    public function show(Product $product)
    {
        $product = $product->load('company')->toArray();
        return response([
            'data' => [
                "name" => [
                    "en" => $product['name'],
                    "fr" => $product['name_in_french']
                ],
                "description" => [
                    "en" => $product['description'],
                    "fr" => $product['description_in_french']
                ],
                "gtin" => $product['gtin'],
                "brand" => $product['brand_name'],
                "countryOfOrigin" => $product['country_of_origin'],
                "weight" => [
                    "gross" => $product['gross_weight_with_packaging'],
                    "net" => $product['net_content_weight'],
                    "unit" => $product['weight_unit']
                ],
                "company" => [
                    "companyName" => $product['company']['company_name'],
                    "companyAddress" => $product['company']['company_address'],
                    "companyTelephone" => $product['company']['company_telephone_number'],
                    "companyEmail" => $product['company']['company_email_address'],
                    "owner" => [
                        "name" => $product['company']['owner_name'],
                        "mobileNumber" => $product['company']['owner_mobile_number'],
                        "email" => $product['company']['owner_email_address']
                    ],
                    "contact" => [
                        "name" => $product['company']['contact_name'],
                        "mobileNumber" => $product['company']['contact_mobile_number'],
                        "email" => $product['company']['contact_email_address']
                    ]
                ]
            ]
        ], 200);
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Product $product)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Product $product)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Product $product)
    {
        //
    }
}
