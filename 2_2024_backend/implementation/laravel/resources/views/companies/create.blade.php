@extends('layouts.app')

@section('body')
    <h1>企業情報新規登録</h1>
    <form action="{{route('companies.store')}}" method="post">
        @csrf
        <p><label for="company_name">company_name:<input value="{{old('company_name')}}" type="text" name="company_name" id="company_name"></label></p>
        <p><label for="company_address">company_address:<input value="{{old('company_address')}}" type="text" name="company_address" id="company_address"></label></p>
        <p><label for="company_telephone_number">company_telephone_number:<input value="{{old('company_telephone_number')}}" type="text" name="company_telephone_number" id="company_telephone_number"></label></p>
        <p><label for="company_email_address">company_email_address:<input value="{{old('company_email_address')}}" type="text" name="company_email_address" id="company_email_address"></label></p>
        <p><label for="owner_name">owner_name:<input value="{{old('owner_name')}}" type="text" name="owner_name" id="owner_name"></label></p>
        <p><label for="owner_mobile_number">owner_mobile_number:<input value="{{old('owner_mobile_number')}}" type="text" name="owner_mobile_number" id="owner_mobile_number"></label></p>
        <p><label for="owner_email_address">owner_email_address:<input value="{{old('owner_email_address')}}" type="text" name="owner_email_address" id="owner_email_address"></label></p>
        <p><label for="contact_name">contact_name:<input value="{{old('contact_name')}}" type="text" name="contact_name" id="contact_name"></label></p>
        <p><label for="contact_mobile_number">contact_mobile_number:<input value="{{old('contact_mobile_number')}}" type="text" name="contact_mobile_number" id="contact_mobile_number"></label></p>
        <p><label for="contact_email_address">contact_email_address:<input value="{{old('contact_email_address')}}" type="text" name="contact_email_address" id="contact_email_address"></label></p>
        <p><button type="submit">登録</button></p>
    </form>
    @if ($errors->any())
        <p>エラーが発生しました</p>
    @endif
@endsection