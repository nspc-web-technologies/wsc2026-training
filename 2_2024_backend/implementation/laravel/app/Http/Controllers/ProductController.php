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
        // fix: Product::all() ではビューで $product->company を参照するたびに個別クエリが発行される（N+1 問題）
        // → 商品数が増えるとクエリ数が膨大になりパフォーマンスが劣化する
        // → Product::with('company')->get() で Eager Loading し 2 クエリに抑える
        $products = Product::with('company')->get();
        return response()->view('products.index', compact('products'))->header('cache-control', 'no-store');
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        // fix: Company::all() → 無効化された企業も表示されてしまう
        // → 設計では「active companies only」なので is_active でフィルタする
        $companies = Company::where('is_active', true)->get();
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

            // tricky: unset($validated['image']) が必須
            // → 忘れると UploadedFile オブジェクトを DB に保存しようとしてエラーになる
            unset($validated['image']);

            if ($request->hasFile('image')) {

                $extension = $request->file('image')->extension();
                $filename  = $validated['gtin'] . '.' . $extension;

                // fix: store() では Storage::putFileAs() でディスク指定なしで保存していた
                // → 現在の .env では FILESYSTEM_DISK=public のためたまたま動作するが、コード上で明示していない
                // → update() と統一して storeAs('products', $filename, 'public') に変更
                $path = $request->file('image')->storeAs(
                    'products',
                    $filename,
                    'public'
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
        // fix: Company::all() → 無効化された企業も表示されてしまう
        // → 設計では「active companies only」なので is_active でフィルタする
        $companies = Company::where('is_active', true)->get();
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

            // tricky: unset($validated['image']) が必須
            // → 忘れると UploadedFile オブジェクトを DB に保存しようとしてエラーになる
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
            // fix: 元コードでは $validated['image_path'] = null が if の外にあり、新画像のパスも null で上書きされていた
            // → else に移動し、画像未指定時のみ null を設定するようにした
            } else {
                $validated['image_path'] = null;
            }

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
        // tricky: 画像削除を DB 削除より先に実行する
        // → 逆順だと $product->delete() 後に $product->image_path が参照不可になる
        if ($product->image_path) {
            Storage::disk('public')->delete($product->image_path);
        }
        $product->delete();
        return redirect()->route('products.index');
    }
}
