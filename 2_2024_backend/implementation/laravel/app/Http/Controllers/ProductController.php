<?php

namespace App\Http\Controllers;

use App\Models\Company;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProductController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $products = Product::all();
        return response()->view('products.index', compact('products'))->header('cache-control', 'no-store');
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        $companies = Company::all();
        return response()->view('products.create', compact('companies'))->header('cache-control', 'no-store');
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        try {

            $validated = $request->validate([
                'gtin' => 'required|min:13|max:14',
                'name' => 'required',
                'name_in_french' => 'required',
                'description' => 'required',
                'description_in_french' => 'required',
                'brand_name' => 'required',
                'country_of_origin' => 'required',
                'gross_weight_with_packaging' => 'required',
                'net_content_weight' => 'required',
                'weight_unit' => 'required',
                'company_id' => 'required|exists:companies,id',
                'image' => 'nullable|image',
            ]);

            unset($validated['image']);

            if ($request->hasFile('image')) {

                $extension = $request->file('image')->extension();
                $filename  = $validated['gtin'] . '.' . $extension;

                $path = Storage::putFileAs(
                    'products',
                    $request->file('image'),
                    $filename
                );

                $validated['image_path'] = $path;
            }

            Product::create($validated);

            return redirect()->route('products.index');
        // 競技用 エラーを握りつぶしてデバッグを容易に
        } catch (\Throwable $th) {
            // dd($th);
            return back()->withErrors('エラーです')->withInput();
        }
    }
    /**
     * Display the specified resource.
     */
    public function show(Product $product)
    {
        return response()->view('products.show', compact('product'))->header('cache-control', 'no-store');
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Product $product)
    {
        $companies = Company::all();
        return response()->view('products.edit', compact('product', 'companies'))->header('cache-control', 'no-store');
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Product $product)
    {
        try {
            $validated = $request->validate([
                'gtin' => 'required|min:13|max:14',
                'name' => 'required',
                'name_in_french' => 'required',
                'description' => 'required',
                'description_in_french' => 'required',
                'brand_name' => 'required',
                'country_of_origin' => 'required',
                'gross_weight_with_packaging' => 'required',
                'net_content_weight' => 'required',
                'weight_unit' => 'required',
                'company_id' => 'required|exists:companies,id',
                'image' => 'nullable|image',
            ]);

            unset($validated['image']);

            if ($product->image_path) {
                Storage::disk('public')->delete($product->image_path);
            }

            if ($request->hasFile('image')) {

                $extension = $request->file('image')->extension();
                $filename  = $validated['gtin'] . '.' . $extension;

                $path = $request->file('image')->storeAs(
                    'products',
                    $filename,
                    'public'
                );

                $validated['image_path'] = $path;
            }

            $validated['image_path'] = null;

            $product->update($validated);
            return redirect()->route('products.index');
        // 競技用 エラーを握りつぶしてデバッグを容易に
        } catch (\Throwable $th) {
            // dd($th);
            return back()->withErrors('エラーです')->withInput();
        }
    }

    public function hide(Product $product)
    {
        try {
            $product->update([
                'is_hidden' => true,
            ]);
            return redirect()->route('products.index');
        // 競技用 エラーを握りつぶしてデバッグを容易に
        } catch (\Throwable $th) {
            // dd($th);
            return back()->withErrors('エラーです')->withInput();
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Product $product)
    {
        if ($product->image_path) {
            Storage::disk('public')->delete($product->image_path);
        }
        $product->delete();
        return redirect()->route('products.index');
    }
}
