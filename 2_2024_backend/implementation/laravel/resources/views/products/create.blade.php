@extends('layouts.app')

@section('body')
    <h1>New Product Registration</h1>
    <form action="{{route('products.store')}}" method="post" enctype="multipart/form-data">
        @csrf
        <p><label for="gtin">gtin:<input value="{{old('gtin')}}" type="text" name="gtin" id="gtin"></label></p>
        <p><label for="name">name:<input value="{{old('name')}}" type="text" name="name" id="name"></label></p>
        <p><label for="name_in_french">name_in_french:<input value="{{old('name_in_french')}}" type="text" name="name_in_french" id="name_in_french"></label></p>
        <p><label for="description">description:<input value="{{old('description')}}" type="text" name="description" id="description"></label></p>
        <p><label for="description_in_french">description_in_french:<input value="{{old('description_in_french')}}" type="text" name="description_in_french" id="description_in_french"></label></p>
        <p><label for="brand_name">brand_name:<input value="{{old('brand_name')}}" type="text" name="brand_name" id="brand_name"></label></p>
        <p><label for="country_of_origin">country_of_origin:<input value="{{old('country_of_origin')}}" type="text" name="country_of_origin" id="country_of_origin"></label></p>
        <p><label for="gross_weight_with_packaging">gross_weight_with_packaging:<input value="{{old('gross_weight_with_packaging')}}" type="text" name="gross_weight_with_packaging" id="gross_weight_with_packaging"></label></p>
        <p><label for="net_content_weight">net_content_weight:<input value="{{old('net_content_weight')}}" type="text" name="net_content_weight" id="net_content_weight"></label></p>
        <p><label for="weight_unit">weight_unit:<input value="{{old('weight_unit')}}" type="text" name="weight_unit" id="weight_unit"></label></p>
        <p><label for="image">image:<input type="file" name="image" id="image"></label></p>
        <p>
            <label for="company_id">company:
                <select name="company_id" id="company_id">
                    @foreach ($companies as $company)
                        <option value="{{$company->id}}" {{$company->id == old('company_id') ? 'selected' : ''}}>{{$company->company_name}}</option>
                    @endforeach
                </select>
            </label>
        </p>
        <p><button type="submit">Register</button></p>
    </form>
    @if ($errors->any())
        <p>An error occurred</p>
    @endif
@endsection