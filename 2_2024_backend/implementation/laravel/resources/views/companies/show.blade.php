@extends('layouts.app')

@section('body')
    <h1>Company Details</h1>
    <form action="{{route('companies.index')}}" method="get">
        <p><button type="submit">Back</button></p>
    </form>
    <h2>Company Information</h2>
    <table>
        <tr>
            <th>id</th>
            <th>company_name</th>
            <th>company_address</th>
            <th>company_telephone_number</th>
            <th>company_email_address</th>
            <th>owner_name</th>
            <th>owner_mobile_number</th>
            <th>owner_email_address</th>
            <th>contact_name</th>
            <th>contact_mobile_number</th>
            <th>contact_email_address</th>
            <th>created_at</th>
            <th>updated_at</th>
            <th></th>
            <th></th>
        </tr>
        <tr>
            <td>{{$company->id}}</td>
            <td>{{$company->company_name}}</td>
            <td>{{$company->company_address}}</td>
            <td>{{$company->company_telephone_number}}</td>
            <td>{{$company->company_email_address}}</td>
            <td>{{$company->owner_name}}</td>
            <td>{{$company->owner_mobile_number}}</td>
            <td>{{$company->owner_email_address}}</td>
            <td>{{$company->contact_name}}</td>
            <td>{{$company->contact_mobile_number}}</td>
            <td>{{$company->contact_email_address}}</td>
            <td>{{$company->created_at}}</td>
            <td>{{$company->updated_at}}</td>
            <td>
                <form action="{{route('companies.edit',$company->id)}}" method="get">
                    <p><button type="submit">Edit</button></p>
                </form>
            </td>
            <td>
                <form action="{{route('companies.deactivate',$company->id)}}" method="post">
                    @csrf
                    <p><button type="submit">Deactivate</button></p>
                </form>
            </td>
        </tr>
    </table>
    <h2>Related Products</h2>
        <table>
        <tr>
            <th>id</th>
            <th>gtin</th>
            <th>name</th>
            <th>name_in_french</th>
            <th>description</th>
            <th>description_in_french</th>
            <th>brand_name</th>
            <th>country_of_origin</th>
            <th>gross_weight_with_packaging</th>
            <th>net_content_weight</th>
            <th>image_path</th>
            <th>is_hidden</th>
            <th>created_at</th>
            <th>updated_at</th>
        </tr>
        @foreach ($company->products as $product)
        <tr>
            <td>{{$product->id}}</td>
            <td><a href="{{route('products.show',$product->gtin)}}">{{$product->gtin}}</a></td>
            <td><a href="{{route('products.show',$product->gtin)}}">{{$product->name}}</a></td>
            <td>{{$product->name_in_french}}</td>
            <td>{{$product->description}}</td>
            <td>{{$product->description_in_french}}</td>
            <td>{{$product->brand_name}}</td>
            <td>{{$product->country_of_origin}}</td>
            <td>{{$product->gross_weight_with_packaging}} {{$product->weight_unit}}</td>
            <td>{{$product->net_content_weight}} {{$product->weight_unit}}</td>
            @if ($product->image_path)
                <td><a href="{{Storage::disk('public')->url($product->image_path)}}" target="_blank">{{Storage::disk('public')->url($product->image_path)}}</a></td>
            @else
                <td><a href="{{Storage::disk('public')->url('products/placeholder.jpg')}}" target="_blank">{{Storage::disk('public')->url('products/placeholder.jpg')}}</a></td>
            @endif
            <td>{{$product->is_hidden}}</td>
            <td>{{$product->created_at}}</td>
            <td>{{$product->updated_at}}</td>
        </tr>
        @endforeach
    </table>
    @if ($errors->any())
        <p>An error occurred</p>
    @endif
@endsection