<?php

namespace App\Service;

class ContentRepository
{
    public static function scanFolder(?string $urlPath = '')
    {
        $output = [];
        $targetDir = base_path('content-pages') . ($urlPath ? DIRECTORY_SEPARATOR . $urlPath : '');
        if (!is_dir($targetDir)) abort(404);
        $cdir = scandir($targetDir);
        foreach ($cdir as $key => $value) {
            if (in_array($value, array(".", "..", "images"))) continue;
            $valueDir = $targetDir . DIRECTORY_SEPARATOR . $value;
            if (is_dir($valueDir)) {
                $output['folders'][] = [
                    'title' => $value,
                    'url' => asset('heritages') . DIRECTORY_SEPARATOR . ($urlPath ? $urlPath . DIRECTORY_SEPARATOR : '') . $value,
                ];
            } else if (is_file($valueDir)) {
                $path_parts = pathinfo($valueDir);
                if ($path_parts['extension'] != 'html' && $path_parts['extension'] != 'txt') continue;
                if (!preg_match('/^\d{4}\-\d{2}\-\d{2}/', $path_parts['filename'], $dateMatches)) continue;
                if (date('Y-m-d') < date($dateMatches[0])) continue;
                $file = self::scanFile($valueDir);
                if (($file['front_matter']['draft'] ?? 'false') == 'true') continue;
                $output['files'][] = $file;
            }
        }
        if (isset($output['files'])) {
            $output['files'] = collect($output['files'])->sortByDesc('name')->values()->toArray();
        }
        return $output;
    }

    public static function searchFileTag(string $tag)
    {
        $output = [];
        $allFiles = self::dirToArray(base_path('content-pages'));
        $filterFiles = collect($allFiles)->filter(function ($file) use ($tag) {
            return in_array($tag, $file['front_matter']['tags'] ?? []);
        });
        $output['files'] = $filterFiles;
        return $output;
    }

    public static function searchFile(string $texts)
    {
        $output = [];
        $allFiles = self::dirToArray(base_path('content-pages'));
        $filterFiles = collect($allFiles)->filter(function ($file) use ($texts) {
            return str($texts)->explode('/')->some(function ($text) use ($file) {
                return str_contains($file['meta']['title'], $text) || str_contains($file['meta']['contents'], $text);
            });
        })->values()->toArray();
        $output['files'] = $filterFiles;
        return $output;
    }

    private static function dirToArray($dir)
    {
        $result = array();
        $cdir = scandir($dir);
        foreach ($cdir as $key => $value) {
            if (!in_array($value, array(".", "..", "images"))) {
                if (is_dir($dir . DIRECTORY_SEPARATOR . $value)) {
                    $result = array_merge($result, self::dirToArray($dir . DIRECTORY_SEPARATOR . $value));
                } else {
                    $path_parts = pathinfo($dir . DIRECTORY_SEPARATOR . $value);
                    if ($path_parts['extension'] != 'html' && $path_parts['extension'] != 'txt') continue;
                    if (!preg_match('/^\d{4}\-\d{2}\-\d{2}/', $path_parts['filename'], $dateMatches)) continue;
                    if (date('Y-m-d') < date($dateMatches[0])) continue;
                    $result[] = self::scanFile($dir . DIRECTORY_SEPARATOR . $value);
                }
            }
        }
        return $result;
    }


    public static function scanFile(string $targetDir)
    {
        $output = [];
        $path_parts = pathinfo($targetDir);
        $fileContents = str(file_get_contents($targetDir));
        if (preg_match('/^---\n(.*?)\n---/s', $fileContents, $matches)) {
            $frontMatter = [];
            foreach (explode("\n", $matches[1]) as $line) {
                $frontMatter[str($line)->before(':')->trim()->toString()] = str($line)->after(':')->trim();
            }
            if (isset($frontMatter['tags'])) {
                $frontMatter['tags'] = str($frontMatter['tags'])->remove(' ')->explode(',')->toArray();
            }
            if (isset($frontMatter['cover'])) {
                $frontMatter['cover'] = str(route('heritage.index'))->remove('/public') . '/content-pages/images/' . $frontMatter['cover'];
            }
            $fileContents = $fileContents->replaceMatches('/^---\n(.*?)\n---/s', '');
            $output['front_matter'] = $frontMatter;
        };
        if ($path_parts['extension'] == 'txt') {
            $ulLis = [];
            foreach (explode("\n", $fileContents) as $line) {
                if (trim($line) == '') continue;
                if (preg_match('/\* (.*)/', $line, $ulLiMatches)) {
                    $ulLis[] =  str($ulLiMatches[1])->replaceMatches('/\*\*(.*?)\*\*/', '<strong>$1</strong>');
                    continue;
                }
                if (count($ulLis) > 0) {
                    $output['blocks'][] = [
                        'type' => 'ul',
                        'lis' => $ulLis,
                    ];
                    $ulLis = [];
                }
                if (is_file(base_path('content-pages/images/' . $line))) {
                    $output['blocks'][] = [
                        'type' => 'img',
                        'src' => str(asset('/'))->remove('/public') . 'content-pages/images/' . $line,
                    ];
                    continue;
                }
                $output['blocks'][] = [
                    'type' => 'p',
                    'html' => str($line)->replaceMatches('/\*\*(.*?)\*\*/', '<strong>$1</strong>'),
                ];
            }
            if (count($ulLis) > 0) $output['blocks'][] = $ulLis;
        } else {
            foreach (explode("\n", $fileContents) as $line) {
                if (trim($line) == '') continue;
                if (preg_match('/^<h1>(.*?)<\/h1>$/', $line, $h1Matches)) {
                    $h1Title = $h1Matches[1];
                }
                $output['blocks'][] = $line;
            }
        }
        preg_match('/^\d{4}\-\d{2}\-\d{2}/', $path_parts['filename'], $dateMatches);
        $output['meta'] = [
            'title' => $frontMatter['title'] ?? $h1Title ?? str($path_parts['filename'])->replace('-', ' '),
            'date' => $dateMatches[0],
            'url' => asset('heritages') . str($targetDir)->afterLast('content-pages')->beforeLast('.'),
            'contents' => str($fileContents)->replace("\n", ''),
            ...$path_parts,
        ];
        return $output;
    }
}
