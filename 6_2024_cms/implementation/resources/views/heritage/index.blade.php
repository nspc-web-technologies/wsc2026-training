<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Document</title>
    <link rel="stylesheet" href="{{asset('css/common.css')}}">
</head>
<body>
    <div class="mv"></div>

    <div class="title">Listing Page Layout</div>

    <div class="flex">
        <div>
            <ul>
                @foreach ($scanFolder['folders'] ?? [] as $folder)
                    <li>
                        <a href="{{ $folder['url'] }}">{{ $folder['title'] }}</a>
                    </li>
                @endforeach
                @foreach ($scanFolder['files'] ?? [] as $file)
                    <li>
                        <a href="{{ $file['meta']['url'] }}">{{ $file['meta']['title'] }}</a><br>
                        @if ($file['front_matter']['summary']??false)
                            <a href="{{ $file['meta']['url'] }}">{{$file['front_matter']['summary']}}</a>
                        @endif
                    </li>
                @endforeach
            </ul>
        </div>
        <div>
            <div>Search</div>
            <form action="{{route('heritage.searchText')}}" method="get">
                <label for="keyword" class="visually-hidden">Search keyword</label>
                <input type="text" value="{{request('keyword')}}" name="keyword" id="keyword" placeholder="KEYWORD">
                <button type="submit">Search</button>
            </form>
        </div>
    </div>
</body>
</html>