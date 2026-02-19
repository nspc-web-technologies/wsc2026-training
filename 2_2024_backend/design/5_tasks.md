# Implementation Tasks - WSC2024 Module B

## 1. Project Setup

- [ ] Create Laravel project
- [ ] Remove unnecessary files
- [ ] Configure .env

## 2. Database

- [ ] Create companies migration
- [ ] Create products migration
- [ ] Run migrations
- [ ] Create Company model
  - [ ] Set fillable
  - [ ] Set casts
  - [ ] Define relationships
- [ ] Create Product model
  - [ ] Set fillable
  - [ ] Set casts
  - [ ] Define relationships
- [ ] Create CompanySeeder
- [ ] Create ProductSeeder
- [ ] Export schema.sql

## 3. Authentication

- [ ] Create AdminAuth middleware
- [ ] Register middleware in Kernel.php
- [ ] Create AuthController
  - [ ] showLogin()
  - [ ] login()
- [ ] Create login.blade.php
- [ ] Define routes

## 4. Company Management

- [ ] Create CompanyController
  - [ ] index()
  - [ ] deactivated()
  - [ ] create()
  - [ ] store()
  - [ ] show()
  - [ ] edit()
  - [ ] update()
  - [ ] deactivate()
    - [ ] Hide related products
- [ ] Create companies/index.blade.php
- [ ] Create companies/deactivated.blade.php
- [ ] Create companies/show.blade.php
  - [ ] Related products list
  - [ ] Deactivate button (window.confirm)
- [ ] Create companies/create.blade.php
- [ ] Create companies/edit.blade.php
- [ ] Define routes

## 5. Product Management

- [ ] Create ProductController
  - [ ] index()
  - [ ] create()
  - [ ] store()
    - [ ] Image upload handling
    - [ ] Set placeholder when no image
    - [ ] GTIN validation (13-14 digits)
  - [ ] show()
  - [ ] edit()
  - [ ] update()
    - [ ] Image upload handling
    - [ ] Set placeholder on image delete
  - [ ] hide()
  - [ ] destroy()
    - [ ] Delete image file
- [ ] Create products/index.blade.php
- [ ] Create products/show.blade.php
  - [ ] Hide button (when is_hidden=false, window.confirm)
  - [ ] Delete button (when is_hidden=true, window.confirm)
- [ ] Create products/create.blade.php
- [ ] Create products/edit.blade.php
- [ ] Define routes
- [ ] Place placeholder image

## 6. Product API

- [ ] Create ProductApiController
  - [ ] index()
    - [ ] Pagination
    - [ ] Keyword search (OR search)
  - [ ] show()
    - [ ] 404 handling
- [ ] Define routes

## 7. Common

- [ ] Create layouts/app.blade.php
- [ ] Create uploads/products directory
- [ ] Create expert_readme.txt
