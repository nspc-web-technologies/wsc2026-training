# Database Design - WSC2024 Module B

## Table Structure

### 1. companies

**Fields:**

- `id` - Primary key (INT, AUTO_INCREMENT)
- `name` - Company name (VARCHAR(255))
- `address` - Company address (TEXT)
- `telephone` - Company phone number (VARCHAR(50))
- `email` - Company email (VARCHAR(255))
- `owner_name` - Owner name (VARCHAR(255))
- `owner_mobile` - Owner mobile number (VARCHAR(50))
- `owner_email` - Owner email (VARCHAR(255))
- `contact_name` - Contact name (VARCHAR(255))
- `contact_mobile` - Contact mobile number (VARCHAR(50))
- `contact_email` - Contact email (VARCHAR(255))
- `is_active` - Active flag (BOOLEAN, default: TRUE)
- `created_at` - Created at (TIMESTAMP)
- `updated_at` - Updated at (TIMESTAMP)

### 2. products

**Fields:**

- `id` - Primary key (INT, AUTO_INCREMENT)
- `gtin` - GTIN number (VARCHAR(14), UNIQUE, INDEXED)
- `name_en` - Product name in English (VARCHAR(255))
- `name_fr` - Product name in French (VARCHAR(255))
- `description_en` - Description in English (TEXT)
- `description_fr` - Description in French (TEXT)
- `brand` - Brand name (VARCHAR(255))
- `country_of_origin` - Country of origin (VARCHAR(100))
- `gross_weight` - Gross weight (DECIMAL(10,3))
- `net_weight` - Net weight (DECIMAL(10,3))
- `weight_unit` - Weight unit (VARCHAR(10))
- `image_path` - Image path (VARCHAR(512), NULLABLE)
- `is_hidden` - Hidden flag (BOOLEAN, default: FALSE)
- `company_id` - Company ID (INT, foreign key)
- `created_at` - Created at (TIMESTAMP)
- `updated_at` - Updated at (TIMESTAMP)

**Constraints:**

- UNIQUE: `gtin`
- FOREIGN KEY: `company_id` → `companies(id)` (ON DELETE RESTRICT)

## ER Diagram

```
companies (1) ─────< (N) products
```

**Relations:**

- One company has many products (1:N)
- Each product belongs to one company
- Foreign key constraint ensures integrity

## Business Rules

1. **GTIN uniqueness**: UNIQUE constraint prevents duplicate GTINs
2. **Company-Product relationship**: Foreign key constraint ensures integrity
3. **Soft delete for companies**: `is_active` flag for deactivation (no physical delete)
4. **Product hiding**: When a company is deactivated, all related products are hidden
5. **Optional image**: `image_path` is NULLABLE (placeholder used when no image)
6. **Delete restrictions**: Companies cannot be deleted from UI, only hidden products can be deleted
