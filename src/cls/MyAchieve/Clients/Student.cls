Class MyAchieve.Clients.Student Extends %Persistent
{

Property User As %String;

Index UserIndex On User [ IdKey, PrimaryKey, Unique ];

Property Logo As MyAchieve.Manage.ImageFile;

Property Surname As %String [ Required ];

Property Name As %String [ Required ];

Property Patronymic As %String;

Property Birthday As %Date [ Required ];

Property Email As %String [ Required ];

Index EmailIndex On Email [ Unique ];

Property Address As MyAchieve.Clients.Address [ Required ];

Relationship Events As MyAchieve.Events.EventStudent [ Cardinality = many, Inverse = Student ];

ClassMethod SetInfo(jsonobj As %Library.DynamicArray, User As %String = {$Username}) As %Status
{
	if ..%ExistsId(User) {
		set lobj = ..%OpenId(User)
	} else {
		set lobj = ..%New()
		set lobj.User = User
	}
	if jsonobj.%IsDefined("Surname") set lobj.Surname = jsonobj.Surname
	if jsonobj.%IsDefined("Name") set lobj.Name = jsonobj.Name
	if jsonobj.%IsDefined("Patronymic") set lobj.Patronymic = jsonobj.Patronymic
	if jsonobj.%IsDefined("Birthday") set lobj.Birthday = $zdateh(jsonobj.Birthday, 3)
	if jsonobj.%IsDefined("Email") set lobj.Email = jsonobj.Email
	if jsonobj.%IsDefined("Address") set lobj.Address = ##class(MyAchieve.Clients.Address).SetInfo(jsonobj.Address, User)
	if jsonobj.%IsDefined("Events") {
		set st = ##class(MyAchieve.Events.Event).QSet(jsonobj.Events, "student", User)
		if $$$ISERR(st) return st
	}
	if jsonobj.%IsDefined("DelEvents") {
		set st = ##class(MyAchieve.Events.Event).QDel(jsonobj.DelEvents, "student", User)
		if $$$ISERR(st) return st
	}
	return lobj.%Save()
}

ClassMethod GetInfo(User As %String = {$Username}) As %Library.DynamicObject
{
	set lobj = ..%OpenId(User)
	set jsonobj = {}
	set jsonobj.Surname = lobj.Surname
	set jsonobj.Name = lobj.Name
	set jsonobj.Patronymic = lobj.Patronymic
	set jsonobj.Birthday = $zdate(lobj.Birthday, 3)
	set jsonobj.Email = lobj.Email
	set jsonobj.Address = ##class(MyAchieve.Clients.Address).GetInfo(lobj.Address.%Id())
	if (lobj.Logo '= "") { set jsonobj.Logo = ##class(MyAchieve.Manage.Root).IdEncrypt(lobj.Logo.%Id()) }
	else { set jsonobj.Logo = "" }
	set events = {}
	set events.Events = []
	if (lobj.Events.Count()>0) {
		set events = ##class(MyAchieve.Events.Event).QGet("student")
	}
	set jsonobj.Events = events.Events
	return jsonobj
}

Storage Default
{
<Data name="StudentDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Logo</Value>
</Value>
<Value name="3">
<Value>Surname</Value>
</Value>
<Value name="4">
<Value>Name</Value>
</Value>
<Value name="5">
<Value>Patronymic</Value>
</Value>
<Value name="6">
<Value>Birthday</Value>
</Value>
<Value name="7">
<Value>Email</Value>
</Value>
<Value name="8">
<Value>Address</Value>
</Value>
</Data>
<DataLocation>^MyAchieve.Clients.StudentD</DataLocation>
<DefaultData>StudentDefaultData</DefaultData>
<IdLocation>^MyAchieve.Clients.StudentD</IdLocation>
<IndexLocation>^MyAchieve.Clients.StudentI</IndexLocation>
<StreamLocation>^MyAchieve.Clients.StudentS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

