Class MyAchieve.Employers.Employer Extends %Persistent
{

Property User As %String;

Index UserIndex On User [ IdKey, PrimaryKey, Unique ];

Property Logo As MyAchieve.Manage.ImageFile;

Property Title As %String [ Required ];

Index TitleIndex On Title [ Unique ];

Property Chief As %String [ Required ];

Property Address As MyAchieve.Clients.Address [ Required ];

Property Phones As list Of %String [ Required ];

Property Email As %String [ Required ];

Index EmailIndex On Email [ Unique ];

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
	if (lobj.Logo '= "") { set jsonobj.Logo = ##class(MyAchieve.Manage.Root).IdEncrypt(lobj.Logo.%Id()) }
	else { set jsonobj.Logo = "" }
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
</Data>
<DataLocation>^MyAchieve.Employers.EmployerD</DataLocation>
<DefaultData>EmployerDefaultData</DefaultData>
<IdLocation>^MyAchieve.Employers.EmployerD</IdLocation>
<IndexLocation>^MyAchieve.Employers.EmployerI</IndexLocation>
<StreamLocation>^MyAchieve.Employers.EmployerS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

