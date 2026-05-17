<?php

namespace App\Http\Controllers;

use App\Service\ContentRepository;
use Illuminate\Http\Request;

class HeritageController extends Controller
{
    public function index()
    {
        $scanFolder = ContentRepository::scanFolder();
        return response()->view('heritage.index', compact('scanFolder'));
    }

    public function show(string $urlPath)
    {
        $targetDir = base_path('content-pages') . ($urlPath ? DIRECTORY_SEPARATOR . $urlPath : '');
        if (is_dir($targetDir)) {
            $scanFolder = ContentRepository::scanFolder($urlPath);
            return response()->view('heritage.index', compact('scanFolder'));
        } else if (is_file($targetDir . '.html')) {
            $scanFile = ContentRepository::scanFile($targetDir . '.html');
            return response()->view('heritage.show', compact('scanFile'));
        } else if (is_file($targetDir . '.txt')) {
            $scanFile = ContentRepository::scanFile($targetDir . '.txt');
            return response()->view('heritage.show', compact('scanFile'));
        } else {
            abort(404);
        }
    }

    public function searchTag(string $tag)
    {
        $scanFolder = ContentRepository::searchFileTag($tag);
        return response()->view('heritage.index', compact('scanFolder'));
    }

    public function searchText(Request $request)
    {
        $text = $request->query('keyword') ?? '';
        $scanFolder = ContentRepository::searchFile($text);
        return response()->view('heritage.index', compact('scanFolder'));
    }
}
