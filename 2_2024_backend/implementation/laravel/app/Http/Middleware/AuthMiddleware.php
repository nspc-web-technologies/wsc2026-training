<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

// fix: クラス名が "AuthMiddreware" と typo されており、use 文やファイル名も含め一貫して誤っていた
// → PHP はクラス名とファイル名が一致しないとオートロードに失敗する可能性がある
// → 正しい綴り "AuthMiddleware" に統一し、ファイル名・クラス名・use 文を一括修正した
class AuthMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->session()->get('passphrase') !== 'admin') {
            abort(401);
        }
        return $next($request);
    }
}
