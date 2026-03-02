<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Session\Session;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $validated = $request->validate([
            'passphrase' => 'required',
        ]);
        if($validated['passphrase'] === 'admin'){
            $request->session()->put('passphrase',$validated['passphrase']);
            return redirect()->route('companies.index');
        }else{
            return back()->withErrors('Incorrect passphrase');
        }
    }

    public function logout(Request $request)
    {
        $request->session()->forget('passphrase');
        return redirect()->route('login');
    }
}
