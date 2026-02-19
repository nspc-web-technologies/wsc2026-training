# Project Structure - WSC2024 Module B

## Directory Structure

```
module_b/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── AuthController.php
│   │   │   ├── CompanyController.php
│   │   │   ├── ProductController.php
│   │   │   └── ProductApiController.php
│   │   └── Middleware/
│   │       └── AdminAuth.php
│   └── Models/
│       ├── Company.php
│       └── Product.php
│
├── database/
│   ├── migrations/
│   │   ├── 2024_01_01_000001_create_companies_table.php
│   │   └── 2024_01_01_000002_create_products_table.php
│   ├── seeders/
│   │   ├── DatabaseSeeder.php
│   │   ├── CompanySeeder.php
│   │   └── ProductSeeder.php
│   └── schema.sql
│
├── public/
│   ├── uploads/
│   │   └── products/
│   └── images/
│       └── placeholder.png
│
├── resources/
│   └── views/
│       ├── layouts/
│       │   └── app.blade.php
│       ├── auth/
│       │   └── login.blade.php
│       ├── companies/
│       │   ├── index.blade.php
│       │   ├── deactivated.blade.php
│       │   ├── show.blade.php
│       │   ├── create.blade.php
│       │   └── edit.blade.php
│       └── products/
│           ├── index.blade.php
│           ├── show.blade.php
│           ├── create.blade.php
│           └── edit.blade.php
│
├── routes/
│   └── web.php
│
└── expert_readme.txt
```
