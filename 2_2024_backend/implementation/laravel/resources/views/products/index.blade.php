@extends('layouts.app')

@section('body')
    <h1>Product List</h1>
    <form action="{{route('companies.index')}}" method="get">
        <p><button type="submit">Company List</button></p>
    </form>
    <form action="{{route('products.create')}}" method="get">
        <p><button type="submit">New Product</button></p>
    </form>
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
            <th>company_name</th>
            <th>created_at</th>
            <th>updated_at</th>
            <th></th>
        </tr>
        @foreach ($products as $product)
            <tr>
                <td>{{$product->id}}</td>
                <td>{{$product->gtin}}</td>
                <td><a href="{{route('products.show',$product->gtin)}}">{{$product->name}}</a></td>
                <td>{{$product->name_in_french}}</td>
                <td>{{$product->description}}</td>
                <td>{{$product->description_in_french}}</td>
                <td>{{$product->brand_name}}</td>
                <td>{{$product->country_of_origin}}</td>
                <td>{{$product->gross_weight_with_packaging}}{{$product->weight_unit}}</td>
                <td>{{$product->net_content_weight}}{{$product->weight_unit}}</td>
                @if ($product->image_path)
                    <td><a href="{{Storage::disk('public')->url($product->image_path)}}" target="_blank">{{Storage::disk('public')->url($product->image_path)}}</a></td>
                @else
                    <td><a href="{{Storage::disk('public')->url('products/placeholder.jpg')}}" target="_blank">{{Storage::disk('public')->url('products/placeholder.jpg')}}</a></td>
                @endif
                <td>{{$product->company->company_name}}</td>
                <td>{{$product->created_at}}</td>
                <td>{{$product->updated_at}}</td>
                <td>
                    <form action="{{route('products.edit',$product->gtin)}}" method="get">
                        <p><button type="submit">Edit</button></p>
                    </form>
                </td>
                <td>
                    @if ($product->is_hidden)
                    <form action="{{route('products.destroy',$product->gtin)}}" method="post">
                        @csrf
                        @method('DELETE')
                        <p><button type="submit">Delete</button></p>
                    </form>
                    @else
                    <form action="{{route('products.hide',$product->gtin)}}" method="post">
                        @csrf
                        <p><button type="submit">Hide</button></p>
                    </form>
                    @endif
                </td>
            </tr>
        @endforeach
    </table>
    @if ($errors->any())
        <p>An error occurred</p>
    @endif
@endsection