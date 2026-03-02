@extends('layouts.app')

@section('body')
    <h1>Deactivated Companies</h1>
    <form action="{{route('companies.index')}}" method="get">
        <p><button type="submit">Back</button></p>
    </form>
    <table>
        <tr>
            <th>ID</th>
            <th>Company Name</th>
            <th>Company Address</th>
            <th>Company Telephone</th>
            <th>Company Email</th>
            <th>Owner Name</th>
            <th>Owner Mobile</th>
            <th>Owner Email</th>
            <th>Contact Name</th>
            <th>Contact Mobile</th>
            <th>Contact Email</th>
            <th>Created At</th>
            <th>Updated At</th>
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
                        <p><button type="submit">Edit</button></p>
                    </form>
                </td>
            </tr>
        @endforeach
    </table>
    @if ($errors->any())
        <p>An error occurred</p>
    @endif
@endsection