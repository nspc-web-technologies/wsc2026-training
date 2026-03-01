@extends('layouts.app')

@section('body')
    <h1>企業情報一覧</h1>
    <form action="{{route('logout')}}" method="post">
        @csrf
        <p><button type="submit">ログアウト</button></p>
    </form>
    <form action="{{route('products.index')}}" method="get">
        <p><button type="submit">商品情報一覧へ</button></p>
    </form>
    <form action="{{route('companies.create')}}" method="get">
        <p><button type="submit">企業情報新規登録</button></p>
    </form>
    <form action="{{route('companies.deactivated')}}" method="get">
        <p><button type="submit">無効企業リストへ</button></p>
    </form>
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
        @foreach ($companies as $company)
            <tr>                
                <td>{{$company->id}}</td>
                <td><a href="{{route('companies.show',$company->id)}}">{{$company->company_name}}</a></td>
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
                        <p><button type="submit">編集</button></p>
                    </form>
                </td>
                <td>
                    <form action="{{route('companies.deactivate',$company->id)}}" method="post">
                        @csrf
                        @method('PUT')
                        <p><button type="submit">無効化</button></p>
                    </form>
                </td>
            </tr>
        @endforeach
    </table>
    @if ($errors->any())
        <p>エラーが発生しました</p>
    @endif
@endsection