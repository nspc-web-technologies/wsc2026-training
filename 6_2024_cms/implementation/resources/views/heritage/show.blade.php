<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>{{ $scanFile['meta']['title'] }}</title>
    <link rel="stylesheet" href="{{asset('css/common.css')}}">
    <script src="{{asset('js/script.js')}}" defer></script>
    <meta property="og:title" content="{{ $scanFile['meta']['title'] }}">
    <meta property="og:description" content="{{ $scanFile['front_matter']['summary'] ?? $scanFile['meta']['title'] }}">
    <meta name="twitter:title" content="{{ $scanFile['meta']['title'] }}">
    <meta name="twitter:description" content="{{ $scanFile['front_matter']['summary'] ?? $scanFile['meta']['title'] }}">
</head>
<body>
    {{-- @dd($scanFile) --}}
    <div class="mv"
        @if ($scanFile['front_matter']['cover']??'')
            style="background: url({{ $scanFile['front_matter']['cover'] }});"
        @endif
        >
        <div class="circle"></div>
    </div>

    <h1 class="title">{{$scanFile['meta']['title']}}</h1>

    <div class="flex">
        <div>
            @if ($scanFile['meta']['extension'] == 'html')
                @foreach ($scanFile['blocks'] as $block)
                    @if ($block != '')
                        {!! $block !!}
                    @endif
                @endforeach
            @elseif ($scanFile['meta']['extension'] == 'txt')
                @foreach ($scanFile['blocks'] as $block)
                    @switch($block['type'])
                        @case('p')
                            <p>{!! $block['html'] !!}</p>
                            @break
                        @case('ul')
                            <ul>
                                @foreach ($block['lis'] as $li)
                                <li>{!! $li !!}</li>
                                @endforeach
                            </ul>
                            @break
                        @case('img')
                            <img src="{{$block['src']}}" alt="">
                            @break
                    @endswitch
                @endforeach
            @endif
        </div>
        <div>
            <div>Date: {{$scanFile['meta']['date']}}</div>
            <div>tags: 
                @forelse ($scanFile['front_matter']['tags']??[] as $tag)
                    <a href="{{route('heritage.searchTag',$tag)}}">{{ $tag }}</a>
                @empty
                    <span>-</span>
                @endforelse
            </div>
            @if (($scanFile['front_matter']['draft'] ?? 'false') == 'true')
                <div>Draft</div>
            @endif
        </div>
    </div>    
    <dialog id="dialog">
      <img src="" alt="" onclick="closeDialog()">
    </dialog>
</body>
</html>