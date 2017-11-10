Class MyAchieve.Clients.Address Extends %Persistent
{

Property User As %String;

Index UserIndex On User [ IdKey, PrimaryKey, Unique ];

Property City As %String [ Required ];

Property Street As %String [ Required ];

Property Home As %SmallInt [ Required ];

Property ZipCode As %Integer [ Required ];

ClassMethod SetInfo(jsonobj As %Library.DynamicObject, User As %String = {$Username}) As MyAchieve.Clients.Address
{
	if ..%ExistsId(User) {
		set lobj = ..%OpenId(User)
	} else {
		set lobj = ..%New()
		set lobj.User = User
	}
	if jsonobj.%IsDefined("City") set lobj.City = jsonobj.City
	if jsonobj.%IsDefined("Street") set lobj.Street = jsonobj.Street
	if jsonobj.%IsDefined("Home") set lobj.Home = jsonobj.Home
	if jsonobj.%IsDefined("ZipCode") set lobj.ZipCode = jsonobj.ZipCode
	do lobj.%Save()
	return lobj
}

ClassMethod GetInfo(Id As %Integer) As %Library.DynamicObject
{
	set lobj = ..%OpenId(Id)
	set jsonobj = {}
	set jsonobj.City = lobj.City
	set jsonobj.Street = lobj.Street
	set jsonobj.Home = lobj.Home
	set jsonobj.ZipCode = lobj.ZipCode
	return jsonobj
}

Storage Default
{
<Data name="AddressDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>City</Value>
</Value>
<Value name="3">
<Value>Street</Value>
</Value>
<Value name="4">
<Value>Home</Value>
</Value>
<Value name="5">
<Value>ZipCode</Value>
</Value>
</Data>
<DataLocation>^MyAchieve.Clients.AddressD</DataLocation>
<DefaultData>AddressDefaultData</DefaultData>
<IdLocation>^MyAchieve.Clients.AddressD</IdLocation>
<IndexLocation>^MyAchieve.Clients.AddressI</IndexLocation>
<StreamLocation>^MyAchieve.Clients.AddressS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

