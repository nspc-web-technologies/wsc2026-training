# データベース設計 - WSC2024 モジュールB

## テーブル構成

### 1. companies（企業）

**フィールド:**

- `id` - 主キー (INT, AUTO_INCREMENT)
- `name` - 企業名 (VARCHAR(255))
- `address` - 企業住所 (TEXT)
- `telephone` - 企業電話番号 (VARCHAR(50))
- `email` - 企業メールアドレス (VARCHAR(255))
- `owner_name` - オーナー名 (VARCHAR(255))
- `owner_mobile` - オーナー携帯番号 (VARCHAR(50))
- `owner_email` - オーナーメールアドレス (VARCHAR(255))
- `contact_name` - 連絡先担当者名 (VARCHAR(255))
- `contact_mobile` - 連絡先携帯番号 (VARCHAR(50))
- `contact_email` - 連絡先メールアドレス (VARCHAR(255))
- `is_active` - 有効フラグ (BOOLEAN, デフォルト: TRUE)
- `created_at` - 作成日時 (TIMESTAMP)
- `updated_at` - 更新日時 (TIMESTAMP)

### 2. products（製品）

**フィールド:**

- `id` - 主キー (INT, AUTO_INCREMENT)
- `gtin` - GTIN番号 (VARCHAR(14), UNIQUE, INDEXED)
- `name_en` - 製品名（英語） (VARCHAR(255))
- `name_fr` - 製品名（フランス語） (VARCHAR(255))
- `description_en` - 説明（英語） (TEXT)
- `description_fr` - 説明（フランス語） (TEXT)
- `brand` - ブランド名 (VARCHAR(255))
- `country_of_origin` - 原産国 (VARCHAR(100))
- `gross_weight` - 総重量 (DECIMAL(10,3))
- `net_weight` - 正味重量 (DECIMAL(10,3))
- `weight_unit` - 重量単位 (VARCHAR(10))
- `image_path` - 画像パス (VARCHAR(512), NULLABLE)
- `is_hidden` - 非表示フラグ (BOOLEAN, デフォルト: FALSE)
- `company_id` - 企業ID (INT, 外部キー)
- `created_at` - 作成日時 (TIMESTAMP)
- `updated_at` - 更新日時 (TIMESTAMP)

**制約:**

- UNIQUE: `gtin`
- FOREIGN KEY: `company_id` → `companies(id)` (ON DELETE RESTRICT)

## ER図

```
companies (1) ─────< (N) products
```

**リレーション:**

- 1つの企業は複数の製品を持つ (1:N)
- 各製品は1つの企業に属する
- 外部キー制約で整合性を担保

## ビジネスルール

1. **GTINの一意性**: UNIQUE制約により重複GTINを防止
2. **企業-製品関係**: 外部キー制約で整合性を担保
3. **企業の論理削除**: `is_active`フラグで無効化（物理削除なし）
4. **製品の非表示化**: 企業が無効化されると、関連する全製品が非表示になる
5. **画像は任意**: `image_path`はNULLABLE（画像なしの場合はプレースホルダーを使用）
6. **削除制限**: 企業はUIから削除不可、非表示の製品のみ削除可能
