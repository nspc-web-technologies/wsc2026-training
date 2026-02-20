# Page Design - WSC2024 Module B

## URL Structure

### Authentication Pages

| URL | Description |
|-----|-------------|
| `/login` | Login page |

### Admin Pages (authentication required)

| URL | Description |
|-----|-------------|
| `/companies` | Company list (active) |
| `/companies/deactivated` | Company list (deactivated) |
| `/companies/new` | Company creation form |
| `/companies/{id}` | Company details |
| `/companies/{id}/edit` | Company edit form |
| `/products` | Product list |
| `/products/new` | Product creation form |
| `/products/{gtin}` | Product details |
| `/products/{gtin}/edit` | Product edit form |

### Route Definitions

```php
// Authentication
Route::get('/login', [AuthController::class, 'showLogin']);
Route::post('/login', [AuthController::class, 'login']);

// Companies (authentication required)
Route::middleware('auth')->group(function () {
    Route::get('/companies', [CompanyController::class, 'index']);
    Route::get('/companies/deactivated', [CompanyController::class, 'deactivated']);
    Route::get('/companies/new', [CompanyController::class, 'create']);
    Route::post('/companies', [CompanyController::class, 'store']);
    Route::get('/companies/{id}', [CompanyController::class, 'show']);
    Route::get('/companies/{id}/edit', [CompanyController::class, 'edit']);
    Route::put('/companies/{id}', [CompanyController::class, 'update']);
    Route::post('/companies/{id}/deactivate', [CompanyController::class, 'deactivate']);

    // Products (authentication required)
    Route::get('/products', [ProductController::class, 'index']);
    Route::get('/products/new', [ProductController::class, 'create']);
    Route::post('/products', [ProductController::class, 'store']);
    Route::get('/products/{gtin}', [ProductController::class, 'show']);
    Route::get('/products/{gtin}/edit', [ProductController::class, 'edit']);
    Route::put('/products/{gtin}', [ProductController::class, 'update']);
    Route::post('/products/{gtin}/hide', [ProductController::class, 'hide']);
    Route::delete('/products/{gtin}', [ProductController::class, 'destroy']);
});
```

## Login Page

**URL:** `GET /login`

### Form Fields

| Label | name attribute | Type | Description |
|-------|---------------|------|-------------|
| Passphrase | `passphrase` | `password` | Input field |
| - | - | `submit` | Login button |

### Submission

- **Method:** POST `/login`
- **On success:** Redirect to `/companies`
- **On failure:** Show error message

### Authentication

- Passphrase: `"admin"`

## Company List Page (Active)

**URL:** `GET /companies`

Filter: `is_active = TRUE`

### Display Fields

| Display Name | DB Column |
|-------------|-----------|
| Company Name | `name` |
| Address | `address` |
| Telephone | `telephone` |
| Email | `email` |
| Owner Name | `owner_name` |
| Contact Name | `contact_name` |

### Links

- Details: `/companies/{id}`
- Create new: `/companies/new`
- Deactivated companies: `/companies/deactivated`

## Company List Page (Deactivated)

**URL:** `GET /companies/deactivated`

Filter: `is_active = FALSE`

### Display Fields

| Display Name | DB Column |
|-------------|-----------|
| Company Name | `name` |
| Address | `address` |
| Telephone | `telephone` |
| Email | `email` |
| Owner Name | `owner_name` |
| Contact Name | `contact_name` |

### Links

- Details: `/companies/{id}`
- Active companies: `/companies`

## Company Details Page

**URL:** `GET /companies/{id}`

### Display Fields

| Display Name | DB Column |
|-------------|-----------|
| Company Name | `name` |
| Company Address | `address` |
| Company Telephone | `telephone` |
| Company Email | `email` |
| Owner Name | `owner_name` |
| Owner Mobile | `owner_mobile` |
| Owner Email | `owner_email` |
| Contact Name | `contact_name` |
| Contact Mobile | `contact_mobile` |
| Contact Email | `contact_email` |

### Related Products List

Display products belonging to this company.

| Display Name | DB Column |
|-------------|-----------|
| GTIN | `gtin` |
| English Name | `name_en` |
| French Name | `name_fr` |
| Brand | `brand` |
| Status | `is_hidden` (Visible / Hidden) |

- Each product links to `/products/{gtin}`

### Links & Buttons

| Element | Action |
|---------|--------|
| Edit link | Navigate to `/companies/{id}/edit` |
| Deactivate button | `window.confirm` → POST `/companies/{id}/deactivate` |

**Note:** No delete function for companies (deletion not allowed per spec)

### Deactivation Process

When a company is deactivated, all related products are automatically hidden (`is_hidden = TRUE`).

```php
// Company deactivation process
$company->is_active = false;
$company->save();

// Hide all related products
Product::where('company_id', $company->id)->update(['is_hidden' => true]);
```

## Company Creation Page

**URL:** `GET /companies/new`

### Form Fields

All fields required:

| Label | name attribute | Type |
|-------|---------------|------|
| Company Name | `name` | `text` |
| Company Address | `address` | `textarea` |
| Company Telephone | `telephone` | `text` |
| Company Email | `email` | `email` |
| Owner Name | `owner_name` | `text` |
| Owner Mobile | `owner_mobile` | `text` |
| Owner Email | `owner_email` | `email` |
| Contact Name | `contact_name` | `text` |
| Contact Mobile | `contact_mobile` | `text` |
| Contact Email | `contact_email` | `email` |

### Submission

- **Method:** POST `/companies`
- **On success:** Redirect to `/companies`

## Company Edit Page

**URL:** `GET /companies/{id}/edit`

### Form Fields

Same fields as company creation page (all required)

### Submission

- **Method:** PUT `/companies/{id}`
- **On success:** Redirect to `/companies`

## Product List Page

**URL:** `GET /products`

Displays all products in a single list (both visible and hidden)

### Display Fields

| Display Name | DB Column |
|-------------|-----------|
| GTIN | `gtin` |
| English Name | `name_en` |
| French Name | `name_fr` |
| Brand | `brand` |
| Company Name | `company.name` |

### Actions

- Details link: `/products/{gtin}`

### Product Deletion Process

```php
// Delete image file as well
if ($product->image_path) {
    @unlink(public_path($product->image_path));
}

// Delete from database
$product->delete();
```

### Links

- Create new: `/products/new`

## Product Details Page

**URL:** `GET /products/{gtin}`

### Display Fields

| Display Name | DB Column |
|-------------|-----------|
| GTIN | `gtin` |
| Company | `company.name` |
| English Name | `name_en` |
| French Name | `name_fr` |
| English Description | `description_en` |
| French Description | `description_fr` |
| Brand | `brand` |
| Country of Origin | `country_of_origin` |
| Gross Weight | `gross_weight` |
| Net Weight | `net_weight` |
| Weight Unit | `weight_unit` |
| Product Image | `image_path` |

### Links & Buttons

| Element | Display Condition | Action |
|---------|-------------------|--------|
| Edit link | Always | Navigate to `/products/{gtin}/edit` |
| Hide button | `is_hidden = FALSE` | `window.confirm` → POST `/products/{gtin}/hide` |
| Delete button | `is_hidden = TRUE` | `window.confirm` → DELETE `/products/{gtin}` |

## Product Creation Page

**URL:** `GET /products/new`

### Form Fields

| Label | name attribute | Type | Notes |
|-------|---------------|------|-------|
| GTIN | `gtin` | `text` | Required, 13-14 digit number |
| Company | `company_id` | `select` | Required, active companies only |
| English Name | `name_en` | `text` | Required |
| French Name | `name_fr` | `text` | Required |
| English Description | `description_en` | `textarea` | Required |
| French Description | `description_fr` | `textarea` | Required |
| Brand | `brand` | `text` | Required |
| Country of Origin | `country_of_origin` | `text` | Required |
| Gross Weight | `gross_weight` | `number` | Required, step="0.001" |
| Net Weight | `net_weight` | `number` | Required, step="0.001" |
| Weight Unit | `weight_unit` | `text` | Required |
| Product Image | `image` | `file` | Optional, jpg/jpeg/png only |

### Submission

- **Method:** POST `/products`
- **Content-Type:** `multipart/form-data`
- **On success:** Redirect to `/products`

### Validation

| Field | Rules |
|-------|-------|
| GTIN | 13 or 14 digits only, must be unique |

### Implementation: Image Upload

```php
if ($request->hasFile('image')) {
    $ext = $request->file('image')->extension();
    $filename = $product->gtin . '.' . $ext;
    $request->file('image')->move(public_path('uploads/products'), $filename);
    $product->image_path = '/uploads/products/' . $filename;
} else {
    $product->image_path = '/images/placeholder.png';
}
$product->save();
```

## Product Edit Page

**URL:** `GET /products/{gtin}/edit`

### Form Fields

| Label | name attribute | Type | Notes |
|-------|---------------|------|-------|
| GTIN | `gtin` | `text` | Display only (disabled) |
| Company | `company_id` | `select` | Required, active companies only |
| English Name | `name_en` | `text` | Required |
| French Name | `name_fr` | `text` | Required |
| English Description | `description_en` | `textarea` | Required |
| French Description | `description_fr` | `textarea` | Required |
| Brand | `brand` | `text` | Required |
| Country of Origin | `country_of_origin` | `text` | Required |
| Gross Weight | `gross_weight` | `number` | Required, step="0.001" |
| Net Weight | `net_weight` | `number` | Required, step="0.001" |
| Weight Unit | `weight_unit` | `text` | Required |
| Product Image | `image` | `file` | Optional, jpg/jpeg/png only, placeholder used when no image |
| Delete Image | `delete_image` | `checkbox` | Check to delete existing image |

### Submission

- **Method:** PUT `/products/{gtin}`
- **Content-Type:** `multipart/form-data`
- **On success:** Redirect to `/products`

### Implementation: Image Handling

```php
// Delete image
if ($request->input('delete_image')) {
    if ($product->image_path) {
        @unlink(public_path($product->image_path));
    }
    $product->image_path = null;
}

// New image upload
if ($request->hasFile('image')) {
    $ext = $request->file('image')->extension();
    $filename = $product->gtin . '.' . $ext;
    $request->file('image')->move(public_path('uploads/products'), $filename);
    $product->image_path = '/uploads/products/' . $filename;
}
```

## Authentication & Access Control

### Protected Pages

| Path | When unauthenticated |
|------|---------------------|
| `/companies*` | 401 Unauthorized |
| `/products*` | 401 Unauthorized |

### Public Pages

| Path |
|------|
| `/login` |

### Session Management

1. Set session on successful login
2. Check session on admin page access
3. Return 401 error if unauthenticated
