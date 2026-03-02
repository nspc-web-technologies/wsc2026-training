@extends('layouts.app')

@section('body')
    <h1>Admin Login</h1>
    <form action="{{route('login')}}" method="post">
        @csrf
        <p><label for="passphrase">Passphrase:<input type="password" name="passphrase" id="passphrase"></label></p>
        <p><button type="submit">Login</button></p>
    </form>
    @if ($errors->any())
        <p>Incorrect passphrase</p>
    @endif
@endsection