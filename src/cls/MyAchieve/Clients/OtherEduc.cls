Class MyAchieve.Clients.OtherEduc Extends %Persistent
{

Property Organizer As %String(MAXLEN = 250) [ Required ];

Property City As %String [ Required ];

Property Qualification As %String [ Required ];

Property TypeDoc As %Integer(DISPLAYLIST = "-Сертификат-Удостоверение-Диплом-Свидетельство-Другое", VALUELIST = "-1-2-3-4-5") [ Required ];

Property Hours As %Integer [ Required ];

Property DateDoc As %Date [ Required ];

ClassMethod SetInfo(jsonobj As %Library.DynamicObject, Id As %Integer = -1) As MyAchieve.Clients.Experience
{
	if (Id > -1) {
		set lobj = ..%OpenId(Id)	
	}
	else {
		set lobj = ..%New()	
	}
	if jsonobj.%IsDefined("Organizer") set lobj.Organizer = jsonobj.Organizer
	if jsonobj.%IsDefined("City") set lobj.City = jsonobj.City
	if jsonobj.%IsDefined("Qualification") set lobj.Qualification = jsonobj.Qualification
	if jsonobj.%IsDefined("TypeDoc") set lobj.TypeDoc = jsonobj.TypeDoc
	if jsonobj.%IsDefined("Hours") set lobj.Hours = jsonobj.Hours
	if jsonobj.%IsDefined("DateDoc") {
		set d = $piece(jsonobj.DateDoc, ".", 3)_"-"_$piece(jsonobj.DateDoc, ".", 2)_"-"_$piece(jsonobj.DateDoc, ".", 1)
		set lobj.DateDoc = $zdateh(d, 3)
	}
	
	do lobj.%Save()
	return lobj
}

ClassMethod GetInfo(Id As %Integer) As %Library.DynamicObject
{
	set lobj = ..%OpenId(Id)
	set jsonobj = {}
	set jsonobj.Id = Id
	set jsonobj.Organizer = lobj.Organizer
	set jsonobj.City = lobj.City
	set jsonobj.Qualification = lobj.Qualification
	set jsonobj.TypeDoc = lobj.TypeDoc
	set jsonobj.Hours = lobj.Hours
	set jsonobj.DateDoc = $zdate(lobj.DateDoc, 3)
	return jsonobj
}

Storage Default
{
<Data name="OtherEducDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Organizer</Value>
</Value>
<Value name="3">
<Value>City</Value>
</Value>
<Value name="4">
<Value>Qualification</Value>
</Value>
<Value name="5">
<Value>TypeDoc</Value>
</Value>
<Value name="6">
<Value>Hours</Value>
</Value>
<Value name="7">
<Value>DateDoc</Value>
</Value>
</Data>
<DataLocation>^MyAchieve.Clients.OtherEducD</DataLocation>
<DefaultData>OtherEducDefaultData</DefaultData>
<IdLocation>^MyAchieve.Clients.OtherEducD</IdLocation>
<IndexLocation>^MyAchieve.Clients.OtherEducI</IndexLocation>
<StreamLocation>^MyAchieve.Clients.OtherEducS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

