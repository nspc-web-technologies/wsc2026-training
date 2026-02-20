# API Design - WSC2024 Module B (Public API)

## Overview

**Authentication:** Not required

## API Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /products.json` | Product list API |
| `GET /products/{gtin}.json` | Single product API |

## 1. Product List API

**Endpoint:** `GET /products.json`

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `page` | Integer | Optional | Page number (default: 1) |
| `per_page` | Integer | Optional | Items per page (default: 10) |
| `query` | String | Optional | Search keyword |

### Searchable Fields

- `name_en` (English name)
- `name_fr` (French name)
- `description_en` (English description)
- `description_fr` (French description)

### Search Logic

- Partial match (OR search)

### Filter Conditions

- `is_hidden = FALSE`

### Response

```json
{
  "data": [
    {
      "name": {
        "en": "Organic Apple Juice",
        "fr": "Jus de pomme biologique"
      },
      "description": {
        "en": "Our organic apple juice is pressed from 100% fresh organic apples...",
        "fr": "Notre jus de pomme biologique est pressé à partir de 100%..."
      },
      "gtin": "03000123456789",
      "brand": "Green Orchard",
      "countryOfOrigin": "France",
      "weight": {
        "gross": 1.1,
        "net": 1.0,
        "unit": "L"
      },
      "company": {
        "companyName": "Euro Expo",
        "companyAddress": "Boulevard de l'Europe, 69680 Chassieu, France",
        "companyTelephone": "+33 1 41 56 78 00",
        "companyEmail": "mail.customerservice.hdq@example.com",
        "owner": {
          "name": "Benjamin Smith",
          "mobileNumber": "+33 6 12 34 56 78",
          "email": "b.smith@example.com"
        },
        "contact": {
          "name": "Marie Dubois",
          "mobileNumber": "+33 6 98 76 54 32",
          "email": "m.dubois@example.com"
        }
      }
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 5,
    "per_page": 10,
    "next_page_url": "/products.json?page=2",
    "prev_page_url": null
  }
}
```

## 2. Single Product API

**Endpoint:** `GET /products/{gtin}.json`

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `gtin` | String | Required | Product GTIN (13-14 digits) |

### Filter Conditions

- `is_hidden = FALSE`

### Response

```json
{
  "name": {
    "en": "Organic Apple Juice",
    "fr": "Jus de pomme biologique"
  },
  "description": {
    "en": "Our organic apple juice is pressed from 100% fresh organic apples...",
    "fr": "Notre jus de pomme biologique est pressé à partir de 100%..."
  },
  "gtin": "03000123456789",
  "brand": "Green Orchard",
  "countryOfOrigin": "France",
  "weight": {
    "gross": 1.1,
    "net": 1.0,
    "unit": "L"
  },
  "company": {
    "companyName": "Euro Expo",
    "companyAddress": "Boulevard de l'Europe, 69680 Chassieu, France",
    "companyTelephone": "+33 1 41 56 78 00",
    "companyEmail": "mail.customerservice.hdq@example.com",
    "owner": {
      "name": "Benjamin Smith",
      "mobileNumber": "+33 6 12 34 56 78",
      "email": "b.smith@example.com"
    },
    "contact": {
      "name": "Marie Dubois",
      "mobileNumber": "+33 6 98 76 54 32",
      "email": "m.dubois@example.com"
    }
  }
}
```

### Status Codes

| Code | Description |
|------|-------------|
| `200 OK` | Product found and visible |
| `404 Not Found` | Product does not exist or is hidden |

### Error Response (404)

```json
{
  "error": "Not Found"
}
```

## DB Field → API Field Mapping

| DB Field | API Field (camelCase) |
|----------|----------------------|
| `name_en` | `name.en` |
| `name_fr` | `name.fr` |
| `description_en` | `description.en` |
| `description_fr` | `description.fr` |
| `gtin` | `gtin` |
| `brand` | `brand` |
| `country_of_origin` | `countryOfOrigin` |
| `gross_weight` | `weight.gross` |
| `net_weight` | `weight.net` |
| `weight_unit` | `weight.unit` |
| `name` (company) | `company.companyName` |
| `address` (company) | `company.companyAddress` |
| `telephone` (company) | `company.companyTelephone` |
| `email` (company) | `company.companyEmail` |
| `owner_name` | `company.owner.name` |
| `owner_mobile` | `company.owner.mobileNumber` |
| `owner_email` | `company.owner.email` |
| `contact_name` | `company.contact.name` |
| `contact_mobile` | `company.contact.mobileNumber` |
| `contact_email` | `company.contact.email` |

**Important:** JSON keys use **camelCase**, DB uses **snake_case**

## Implementation Reference

### ProductApiController

```php
class ProductApiController extends Controller
{
    // GET /products.json
    public function index(Request $request)
    {
        $query = Product::where('is_hidden', false)
            ->with('company');

        // Keyword search
        if ($request->has('query')) {
            $keyword = $request->input('query');
            $query->where(function ($q) use ($keyword) {
                $q->where('name_en', 'like', "%{$keyword}%")
                  ->orWhere('name_fr', 'like', "%{$keyword}%")
                  ->orWhere('description_en', 'like', "%{$keyword}%")
                  ->orWhere('description_fr', 'like', "%{$keyword}%");
            });
        }

        $perPage = $request->input('per_page', 10);
        $products = $query->paginate($perPage);

        return response()->json([
            'data' => $products->map(fn($p) => $this->formatProduct($p)),
            'pagination' => [
                'current_page' => $products->currentPage(),
                'total_pages' => $products->lastPage(),
                'per_page' => $products->perPage(),
                'next_page_url' => $products->nextPageUrl(),
                'prev_page_url' => $products->previousPageUrl(),
            ]
        ]);
    }

    // GET /products/{gtin}.json
    public function show($gtin)
    {
        $product = Product::where('gtin', $gtin)
            ->where('is_hidden', false)
            ->with('company')
            ->first();

        if (!$product) {
            return response()->json(['error' => 'Not Found'], 404);
        }

        return response()->json($this->formatProduct($product));
    }

    private function formatProduct($product)
    {
        return [
            'name' => [
                'en' => $product->name_en,
                'fr' => $product->name_fr,
            ],
            'description' => [
                'en' => $product->description_en,
                'fr' => $product->description_fr,
            ],
            'gtin' => $product->gtin,
            'brand' => $product->brand,
            'countryOfOrigin' => $product->country_of_origin,
            'weight' => [
                'gross' => $product->gross_weight,
                'net' => $product->net_weight,
                'unit' => $product->weight_unit,
            ],
            'company' => $this->formatCompany($product->company),
        ];
    }

    private function formatCompany($company)
    {
        return [
            'companyName' => $company->name,
            'companyAddress' => $company->address,
            'companyTelephone' => $company->telephone,
            'companyEmail' => $company->email,
            'owner' => [
                'name' => $company->owner_name,
                'mobileNumber' => $company->owner_mobile,
                'email' => $company->owner_email,
            ],
            'contact' => [
                'name' => $company->contact_name,
                'mobileNumber' => $company->contact_mobile,
                'email' => $company->contact_email,
            ],
        ];
    }
}
```

### Route Definitions

```php
// routes/web.php
Route::get('/products.json', [ProductApiController::class, 'index']);
Route::get('/products/{gtin}.json', [ProductApiController::class, 'show']);
```
