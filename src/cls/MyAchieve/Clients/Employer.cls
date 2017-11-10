Class MyAchieve.Clients.Employer Extends %Persistent
{

Property User As %String;

Index UserIndex On User [ IdKey, PrimaryKey, Unique ];

Property Title As %String(MAXLEN = 250) [ Required ];

Index TitleIndex On Title [ Unique ];

Property Chief As %String(MAXLEN = 250) [ Required ];

Property Address As MyAchieve.Clients.Address [ Required ];

Property Phones As list Of %String [ Required ];

Property Email As %String [ Required ];

Index EmailIndex On Email [ Unique ];

Property Coord As %String(MAXLEN = 250) [ Required ];

Property CoordPhones As list Of %String [ Required ];

Property CoordPost As %String(MAXLEN = 100) [ Required ];

ClassMethod SetInfo(jsonobj As %Library.DynamicArray, User As %String = {$Username}) As %Status
{
	if ..%ExistsId(User) {
		set lobj = ..%OpenId(User)
	} else {
		set lobj = ..%New()
		set lobj.User = User
	}
	if jsonobj.%IsDefined("Title") set lobj.Title = jsonobj.Title
	if jsonobj.%IsDefined("Chief") set lobj.Chief = jsonobj.Chief
	if jsonobj.%IsDefined("Address") set lobj.Address = ##class(MyAchieve.Clients.Address).SetInfo(jsonobj.Address, User)
	if jsonobj.%IsDefined("Phones") set lobj.Phones = ##class(MyAchieve.Manage.Root).JSONToList(jsonobj.Phones)
	if jsonobj.%IsDefined("Email") set lobj.Email = jsonobj.Email
	if jsonobj.%IsDefined("Coord") set lobj.Coord = jsonobj.Coord
	if jsonobj.%IsDefined("CoordPhones") set lobj.CoordPhones = ##class(MyAchieve.Manage.Root).JSONToList(jsonobj.CoordPhones)
	if jsonobj.%IsDefined("CoordPost") set lobj.CoordPost = jsonobj.CoordPost
	return lobj.%Save()
}

ClassMethod GetInfo(User As %String = {$Username}) As %Library.DynamicObject
{
	set lobj = ..%OpenId(User)
	set jsonobj = {}
	set jsonobj.Title = lobj.Title
	set jsonobj.Chief = lobj.Chief
	set jsonobj.Address = ##class(MyAchieve.Clients.Address).GetInfo(lobj.Address.%Id())
	set jsonobj.Phones = ##class(MyAchieve.Manage.Root).ListToJSON(lobj.Phones)
	set jsonobj.Email = lobj.Email
	set jsonobj.Coord = lobj.Coord
	set jsonobj.CoordPhones = ##class(MyAchieve.Manage.Root).ListToJSON(lobj.CoordPhones)
	set jsonobj.CoordPost = lobj.CoordPost
	set jsonobj.Events = []
	return jsonobj
}

Storage Default
{
<Data name="EmployerDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Logo</Value>
</Value>
<Value name="3">
<Value>Title</Value>
</Value>
<Value name="4">
<Value>Chief</Value>
</Value>
<Value name="5">
<Value>Address</Value>
</Value>
<Value name="6">
<Value>Phones</Value>
</Value>
<Value name="7">
<Value>Email</Value>
</Value>
<Value name="8">
<Value>User</Value>
</Value>
<Value name="9">
<Value>Coord</Value>
</Value>
<Value name="10">
<Value>CoordPhones</Value>
</Value>
<Value name="11">
<Value>CoordPost</Value>
</Value>
</Data>
<DataLocation>^MyAchieve.Clients.EmployerD</DataLocation>
<DefaultData>EmployerDefaultData</DefaultData>
<IdLocation>^MyAchieve.Clients.EmployerD</IdLocation>
<IndexLocation>^MyAchieve.Clients.EmployerI</IndexLocation>
<StreamLocation>^MyAchieve.Clients.EmployerS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

