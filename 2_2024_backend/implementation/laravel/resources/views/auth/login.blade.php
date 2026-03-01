@extends('layouts.app')

@section('body')
    <h1>管理者ログインページ</h1>
    <form action="{{route('login')}}" method="post">
        @csrf
        <p><label for="passphrase">パスフレーズ:<input type="password" name="passphrase" id="passphrase"></label></p>
        <p><button type="submit">ログイン</button></p>
    </form>
    @if ($errors->any())
        <p>パスフレーズが正しくありません</p>
    @endif
@endsection