@extends('layouts.app')

@section('body')
    <h1>Edit Company</h1>
    <form action="{{route('companies.update',$company->id)}}" method="post">
        @csrf
        @method('put')
        <p><label for="company_name">Company Name:<input type="text" value="{{old('company_name',$company->company_name)}}" name="company_name" id="company_name"></label></p>
        <p><label for="company_address">Company Address:<input type="text" value="{{old('company_address',$company->company_address)}}" name="company_address" id="company_address"></label></p>
        <p><label for="company_telephone_number">Company Telephone:<input type="text" value="{{old('company_telephone_number',$company->company_telephone_number)}}" name="company_telephone_number" id="company_telephone_number"></label></p>
        <p><label for="company_email_address">Company Email:<input type="text" value="{{old('company_email_address',$company->company_email_address)}}" name="company_email_address" id="company_email_address"></label></p>
        <p><label for="owner_name">Owner Name:<input type="text" value="{{old('owner_name',$company->owner_name)}}" name="owner_name" id="owner_name"></label></p>
        <p><label for="owner_mobile_number">Owner Mobile:<input type="text" value="{{old('owner_mobile_number',$company->owner_mobile_number)}}" name="owner_mobile_number" id="owner_mobile_number"></label></p>
        <p><label for="owner_email_address">Owner Email:<input type="text" value="{{old('owner_email_address',$company->owner_email_address)}}" name="owner_email_address" id="owner_email_address"></label></p>
        <p><label for="contact_name">Contact Name:<input type="text" value="{{old('contact_name',$company->contact_name)}}" name="contact_name" id="contact_name"></label></p>
        <p><label for="contact_mobile_number">Contact Mobile:<input type="text" value="{{old('contact_mobile_number',$company->contact_mobile_number)}}" name="contact_mobile_number" id="contact_mobile_number"></label></p>
        <p><label for="contact_email_address">Contact Email:<input type="text" value="{{old('contact_email_address',$company->contact_email_address)}}" name="contact_email_address" id="contact_email_address"></label></p>
        <p><button type="submit">Save</button></p>
    </form>
    @if ($errors->any())
        <p>An error occurred</p>
    @endif
@endsection