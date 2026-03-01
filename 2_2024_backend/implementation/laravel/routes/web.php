<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\CompanyController;
use App\Http\Controllers\ProductApiController;
use App\Http\Controllers\ProductController;
use App\Http\Middleware\AuthMiddreware;
use Illuminate\Support\Facades\Route;

Route::get('/login', function () {
    return response()->view('auth.login')->header('cache-control', 'no-store');
})->name('login');

Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');


Route::get('/products.json',[ProductApiController::class,'index']);
Route::get('/products/{product}.json',[ProductApiController::class,'show']);



Route::middleware(AuthMiddreware::class)->group(function () {
    Route::get('/companies', [CompanyController::class, 'index'])->name('companies.index');
    Route::get('/companies/deactivated', [CompanyController::class, 'deactivatedIndex'])->name('companies.deactivated');
    Route::get('/companies/new', [CompanyController::class, 'create'])->name('companies.create');
    Route::post('/companies/store', [CompanyController::class, 'store'])->name('companies.store');
    Route::get('/companies/{company}', [CompanyController::class, 'show'])->name('companies.show');
    Route::get('/companies/{company}/edit', [CompanyController::class, 'edit'])->name('companies.edit');
    Route::put('/companies/{company}', [CompanyController::class, 'update'])->name('companies.update');
    Route::put('/companies/{company}/deactivated', [CompanyController::class, 'deactivate'])->name('companies.deactivate');

    Route::get('/products', [ProductController::class, 'index'])->name('products.index');
    Route::get('/products/new', [ProductController::class, 'create'])->name('products.create');
    Route::post('/products/store', [ProductController::class, 'store'])->name('products.store');
    Route::get('/products/{product}', [ProductController::class, 'show'])->name('products.show');
    Route::get('/products/{product}/edit', [ProductController::class, 'edit'])->name('products.edit');
    Route::put('/products/{product}', [ProductController::class, 'update'])->name('products.update');
    Route::delete('/products/{product}', [ProductController::class, 'destroy'])->name('products.destroy');
    Route::put('/products/{product}/hide', [ProductController::class, 'hide'])->name('products.hide');
});
