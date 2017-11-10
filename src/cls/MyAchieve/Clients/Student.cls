Class MyAchieve.Clients.Student Extends %Persistent
{

Property User As %String;

Index UserIndex On User [ IdKey, PrimaryKey, Unique ];

Property Surname As %String [ Required ];

Property Name As %String [ Required ];

Property Patronymic As %String;

Property Birthday As %Date [ Required ];

Property Foa As %Integer(DISPLAYLIST = "-Спорт-Образование, наука-Управление и общественная деятельность-Культура и искусство-Техники-Предпринимательство", VALUELIST = "-1-2-3-4-5-6") [ Required ];

Property Address As MyAchieve.Clients.Address [ Required ];

Property Achievements As list Of MyAchieve.Events.Event;

Property Experience As list Of MyAchieve.Clients.Experience;

Property OtherEduc As list Of MyAchieve.Clients.OtherEduc;

ClassMethod SetInfo(jsonobj As %Library.DynamicArray, User As %String, OrgUser As %String = {$Username}) As %Status
{
	set ex = 0
	if ..%ExistsId(User) {
		set lobj = ..%OpenId(User)
		set ex = 1
	} else {
		set lobj = ..%New()
		set lobj.User = User
	}
	if jsonobj.%IsDefined("Surname") set lobj.Surname = jsonobj.Surname
	if jsonobj.%IsDefined("Name") set lobj.Name = jsonobj.Name
	if jsonobj.%IsDefined("Patronymic") set lobj.Patronymic = jsonobj.Patronymic
	if jsonobj.%IsDefined("Birthday") set lobj.Birthday = $zdateh(jsonobj.Birthday, 3)
	if jsonobj.%IsDefined("Foa") set lobj.Foa = jsonobj.Foa
	if jsonobj.%IsDefined("Address") set lobj.Address = ##class(MyAchieve.Clients.Address).SetInfo(jsonobj.Address, User)
	set st = lobj.%Save()
	if $$$ISERR(st) return st
	if jsonobj.%IsDefined("Achievements") do ..JSONToList(jsonobj.Achievements, "Ach", User)
	if jsonobj.%IsDefined("Experience") do ..JSONToList(jsonobj.Experience, "Exp", User)
	if jsonobj.%IsDefined("OtherEduc") do ..JSONToList(jsonobj.OtherEduc, "OEdu", User)
	
	if (ex = 0) {
		set orgstud = ##class(MyAchieve.Clients.Organizer).%OpenId(OrgUser)
		set st = orgstud.Students.Insert(lobj)
		if $$$ISERR(st) return st
		set st = orgstud.%Save()
		if $$$ISERR(st) return st
	}
	
	return $$$OK
}

ClassMethod GetInfo(User As %String = {$Username}) As %Library.DynamicObject
{
	set lobj = ..%OpenId(User)
	set jsonobj = {}
	set jsonobj.Login = $extract(lobj.User, 4, $length(lobj.User))
	set jsonobj.Surname = lobj.Surname
	set jsonobj.Name = lobj.Name
	set jsonobj.Patronymic = lobj.Patronymic
	set b = $zdate(lobj.Birthday, 3)
	set b = $piece(b, "-", 3)_"."_$piece(b, "-", 2)_"."_$piece(b, "-", 1)
	set jsonobj.Birthday = b
	set jsonobj.Foa = lobj.Foa
	set jsonobj.Address = ##class(MyAchieve.Clients.Address).GetInfo(lobj.Address.%Id())
	set jsonobj.Achievements = ..ListToJSON(lobj.Achievements, "Ach")
	set jsonobj.Experience = ..ListToJSON(lobj.Experience, "Exp")
	set jsonobj.OtherEduc = ..ListToJSON(lobj.OtherEduc, "OEdu")
	return jsonobj
}

ClassMethod JSONToList(JSONArr As %Library.DynamicArray, Type As %String, SelfId As %String) As %Status
{
	set selfobj = ..%OpenId(SelfId)
	set iter = JSONArr.%GetIterator()
	while iter.%GetNext(.key , .value) {
		if (Type = "Ach") {
			if (value.%IsDefined("Id")) {
				set v = ##class(MyAchieve.Events.Event).SetInfo(value, value.Id)	
			} else {
				set v = ##class(MyAchieve.Events.Event).SetInfo(value)
				do selfobj.Achievements.Insert(v)
			}
		}
		if (Type = "Exp") {
			if (value.%IsDefined("Id")) {
				set v = ##class(MyAchieve.Clients.Experience).SetInfo(value, value.Id)	
			} else {
				set v = ##class(MyAchieve.Clients.Experience).SetInfo(value)
				do selfobj.Experience.Insert(v)
			}	
		}
		if (Type = "OEdu") {
			if (value.%IsDefined("Id")) {
				set v = ##class(MyAchieve.Clients.OtherEduc).SetInfo(value, value.Id)	
			} else {
				set v = ##class(MyAchieve.Clients.OtherEduc).SetInfo(value)
				do selfobj.OtherEduc.Insert(v)
			}	
		}
	}
	return selfobj.%Save()
}

ClassMethod ListToJSON(L As %Collection.ListOfDT, Type As %String) As %Library.DynamicArray
{
	set JSONArr = []
	for i=1:1:L.Count() {
		set value = L.GetAt(i)
		if (Type = "Ach") {
			set v = ##class(MyAchieve.Events.Event).GetInfo(value.%Id())
		}
		if (Type = "Exp") {
			set v = ##class(MyAchieve.Clients.Experience).GetInfo(value.%Id())
		}
		if (Type = "OEdu") {
			set v = ##class(MyAchieve.Clients.OtherEduc).GetInfo(value.%Id())
		}
		do JSONArr.%Push(v) 
	}
	return JSONArr
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
<Value name="9">
<Value>Organizer</Value>
</Value>
<Value name="10">
<Value>Foa</Value>
</Value>
<Value name="11">
<Value>Achievements</Value>
</Value>
<Value name="12">
<Value>Experience</Value>
</Value>
<Value name="13">
<Value>OtherEduc</Value>
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

