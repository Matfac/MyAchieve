Class MyAchieve.Clients.Organizer Extends %Persistent
{

Property User As %String;

Index UserIndex On User [ IdKey, PrimaryKey, Unique ];

Property Title As %String(MAXLEN = 250) [ Required ];

Index TitleIndex On Title [ Unique ];

Property Address As MyAchieve.Clients.Address [ Required ];

Property Phones As list Of %String;

Property Email As %String [ Required ];

Index EmailIndex On Email [ Unique ];

Property Students As list Of MyAchieve.Clients.Student;

ClassMethod SetInfo(jsonobj As %Library.DynamicArray, User As %String = {$Username}) As %Status
{
	if ..%ExistsId(User) {
		set lobj = ..%OpenId(User)
	} else {
		set lobj = ..%New()
		set lobj.User = User
	}
	if jsonobj.%IsDefined("Title") set lobj.Title = jsonobj.Title
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
	set jsonobj.Address = ##class(MyAchieve.Clients.Address).GetInfo(lobj.Address.%Id())
	set jsonobj.Phones = ##class(MyAchieve.Manage.Root).ListToJSON(lobj.Phones)
	set jsonobj.Email = lobj.Email
	set jsonobj.Events = []
	for i=1:1:lobj.Students.Count() 
	{ do jsonobj.Events.%Push(##class(MyAchieve.Clients.Student).GetInfo(lobj.Students.GetAt(i).User)) }
	return jsonobj
}

Storage Default
{
<Data name="OrganizerDefaultData">
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
<Value>Address</Value>
</Value>
<Value name="5">
<Value>Phones</Value>
</Value>
<Value name="6">
<Value>Email</Value>
</Value>
<Value name="7">
<Value>Students</Value>
</Value>
</Data>
<DataLocation>^MyAchieve.Clients.OrganizerD</DataLocation>
<DefaultData>OrganizerDefaultData</DefaultData>
<IdLocation>^MyAchieve.Clients.OrganizerD</IdLocation>
<IndexLocation>^MyAchieve.Clients.OrganizerI</IndexLocation>
<StreamLocation>^MyAchieve.Clients.OrganizerS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

