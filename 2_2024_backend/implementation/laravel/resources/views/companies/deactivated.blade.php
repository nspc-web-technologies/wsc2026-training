@extends('layouts.app')

@section('body')
    <h1>無効化企業情報一覧</h1>
    <form action="{{route('companies.index')}}" method="get">
        <p><button type="submit">戻る</button></p>
    </form>
    <table>
        <tr>
            <th>ID</th>
            <th>企業名</th>
            <th>企業住所</th>
            <th>企業電話番号</th>
            <th>企業メールアドレス</th>
            <th>所有者名</th>
            <th>所有者携帯番号</th>
            <th>所有者メールアドレス</th>
            <th>連絡先</th>
            <th>連絡先携帯番号</th>
            <th>連絡先名</th>
            <th>作成日時</th>
            <th>更新日時</th>
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
            </tr>
        @endforeach
    </table>
    @if ($errors->any())
        <p>エラーが発生しました</p>
    @endif
@endsection