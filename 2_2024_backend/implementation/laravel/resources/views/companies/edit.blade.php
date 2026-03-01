@extends('layouts.app')

@section('body')
    <h1>企業情報編集</h1>
    <form action="{{route('companies.update',$company->id)}}" method="post">
        @csrf
        @method('put')
        <p><label for="company_name">企業名:<input type="text" value="{{old('company_name',$company->company_name)}}" name="company_name" id="company_name"></label></p>
        <p><label for="company_address">企業住所:<input type="text" value="{{old('company_address',$company->company_address)}}" name="company_address" id="company_address"></label></p>
        <p><label for="company_telephone_number">企業電話番号:<input type="text" value="{{old('company_telephone_number',$company->company_telephone_number)}}" name="company_telephone_number" id="company_telephone_number"></label></p>
        <p><label for="company_email_address">企業メールアドレス:<input type="text" value="{{old('company_email_address',$company->company_email_address)}}" name="company_email_address" id="company_email_address"></label></p>
        <p><label for="owner_name">所有者名:<input type="text" value="{{old('owner_name',$company->owner_name)}}" name="owner_name" id="owner_name"></label></p>
        <p><label for="owner_mobile_number">所有者携帯番号:<input type="text" value="{{old('owner_mobile_number',$company->owner_mobile_number)}}" name="owner_mobile_number" id="owner_mobile_number"></label></p>
        <p><label for="owner_email_address">所有者メールアドレス:<input type="text" value="{{old('owner_email_address',$company->owner_email_address)}}" name="owner_email_address" id="owner_email_address"></label></p>
        <p><label for="contact_name">連絡先:<input type="text" value="{{old('contact_name',$company->contact_name)}}" name="contact_name" id="contact_name"></label></p>
        <p><label for="contact_mobile_number">連絡先携帯番号:<input type="text" value="{{old('contact_mobile_number',$company->contact_mobile_number)}}" name="contact_mobile_number" id="contact_mobile_number"></label></p>
        <p><label for="contact_email_address">連絡先名:<input type="text" value="{{old('contact_email_address',$company->contact_email_address)}}" name="contact_email_address" id="contact_email_address"></label></p>
        <p><button type="submit">保存</button></p>
    </form>
    @if ($errors->any())
        <p>エラーが発生しました</p>
    @endif
@endsection