Class MyAchieve.Clients.Organizer Extends %Persistent
{

Property User As %String;

Index UserIndex On User [ IdKey, PrimaryKey, Unique ];

Property Logo As MyAchieve.Manage.ImageFile;

Property Title As %String [ Required ];

Index TitleIndex On Title [ Unique ];

Property Address As MyAchieve.Clients.Address [ Required ];

Property Phones As list Of %String [ Required ];

Property Email As %String [ Required ];

Index EmailIndex On Email [ Unique ];

Relationship Events As MyAchieve.Events.EventOrganizer [ Cardinality = many, Inverse = Organizer ];

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
	set st = lobj.%Save()
	if $$$ISERR(st) return st
	if jsonobj.%IsDefined("Events") {
		set st = ##class(MyAchieve.Events.Event).QSet(jsonobj.Events, "organizer", User)
		if $$$ISERR(st) return st
	}
	if jsonobj.%IsDefined("DelEvents") {
		set st = ##class(MyAchieve.Events.Event).QDel(jsonobj.DelEvents, "organizer", User)
		if $$$ISERR(st) return st
	}
	return $$$OK
}

ClassMethod GetInfo(User As %String = {$Username}) As %Library.DynamicObject
{
	set lobj = ..%OpenId(User)
	set jsonobj = {}
	set jsonobj.Title = lobj.Title
	set jsonobj.Address = ##class(MyAchieve.Clients.Address).GetInfo(lobj.Address.%Id())
	set jsonobj.Phones = ##class(MyAchieve.Manage.Root).ListToJSON(lobj.Phones)
	set jsonobj.Email = lobj.Email
	if (lobj.Logo '= "") { set jsonobj.Logo = ##class(MyAchieve.Manage.Root).IdEncrypt(lobj.Logo.%Id()) }
	else { set jsonobj.Logo = "" }
	set events = {}
	set events.Events = []
	if (lobj.Events.Count()>0) {
		set events = ##class(MyAchieve.Events.Event).QGet("organizer")
	}
	set jsonobj.Events = events.Events
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
</Data>
<DataLocation>^MyAchieve.Clients.OrganizerD</DataLocation>
<DefaultData>OrganizerDefaultData</DefaultData>
<IdLocation>^MyAchieve.Clients.OrganizerD</IdLocation>
<IndexLocation>^MyAchieve.Clients.OrganizerI</IndexLocation>
<StreamLocation>^MyAchieve.Clients.OrganizerS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

