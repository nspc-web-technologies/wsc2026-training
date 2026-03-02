<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>MB</title>
</head>
<body>
    @yield('body')
    @if ($message = session('message'))
        <p>{{ $message }}</p>
    @endif
</body>
</html>