<?php

namespace App\Http\Controllers;

use App\Models\Company;
use Illuminate\Http\Request;

class CompanyController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $companies = Company::where('is_active', true)->get();
        return response()->view('companies.index', compact('companies'))->header('cache-control', 'no-store');
    }

    public function deactivatedIndex()
    {
        $companies = Company::where('is_active', false)->get();
        return response()->view('companies.deactivated', compact('companies'))->header('cache-control', 'no-store');
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        return response()->view('companies.create')->header('cache-control', 'no-store');
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'company_name' => 'required',
                'company_address' => 'required',
                'company_telephone_number' => 'required',
                'company_email_address' => 'required',
                'owner_name' => 'required',
                'owner_mobile_number' => 'required',
                'owner_email_address' => 'required',
                'contact_name' => 'required',
                'contact_mobile_number' => 'required',
                'contact_email_address' => 'required',
            ]);
            Company::create($validated);
            return redirect()->route('companies.index');
        // 競技用 エラーを握りつぶしてデバッグを容易に
        } catch (\Throwable $th) {
            // dd($th);
            return back()->withErrors('エラーです')->withInput();
        }
    }
    /**
     * Display the specified resource.
     */
    public function show(Company $company)
    {
        return response()->view('companies.show', compact('company'))->header('cache-control', 'no-store');
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Company $company)
    {
        return response()->view('companies.edit', compact('company'))->header('cache-control', 'no-store');
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Company $company)
    {
        try {
            $validated = $request->validate([
                'company_name' => 'required',
                'company_address' => 'required',
                'company_telephone_number' => 'required',
                'company_email_address' => 'required',
                'owner_name' => 'required',
                'owner_mobile_number' => 'required',
                'owner_email_address' => 'required',
                'contact_name' => 'required',
                'contact_mobile_number' => 'required',
                'contact_email_address' => 'required',
            ]);
            $company->update($validated);
            return redirect()->route('companies.index');
        // 競技用 エラーを握りつぶしてデバッグを容易に
        } catch (\Throwable $th) {
            // dd($th);
            return back()->withErrors('エラーです')->withInput();
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Company $company)
    {
        //
    }

    public function deactivate(Company $company)
    {
        $company->update([
            'is_active' => false,
        ]);
        // smart: $company->products()->update() でリレーション経由の一括更新
        // → ループ不要で 1 クエリで全商品を非表示にできる
        $company->products()->update([
            'is_hidden' => true,
        ]);
        return redirect()->route('companies.index');
    }
}
