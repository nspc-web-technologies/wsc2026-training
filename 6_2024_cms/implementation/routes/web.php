<?php

use App\Http\Controllers\HeritageController;
use Illuminate\Support\Facades\Route;

Route::get('/', [HeritageController::class, 'index'])->name('heritage.index');
Route::get('/tags/{tag}', [HeritageController::class, 'searchTag'])->name('heritage.searchTag');
Route::get('/heritages/search/', [HeritageController::class, 'searchText'])->name('heritage.searchText');
Route::get('/heritages/{path}', [HeritageController::class, 'show'])->where('path', '.*')->name('heritage.show');
