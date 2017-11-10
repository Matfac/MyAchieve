Class MyAchieve.Events.Event Extends %Persistent
{

Property Title As %String(MAXLEN = 250) [ Required ];

Property Level As %Integer(DISPLAYLIST = "-Образовательная организация-Муниципальный-Региональный-Всероссийский-Международный", VALUELIST = "-1-2-3-4-5") [ Required ];

Property EventResult As %Integer(DISPLAYLIST = "-Участник-Победитель-Призёр-Организатор-Лауреат", VALUELIST = "-1-2-3-4-5") [ Required ];

Property Year As %Integer [ Required ];

Property City As %String [ Required ];

Property VerifyVideo As %String(MAXLEN = 150);

Property VerifyPhoto As %String(MAXLEN = 150);

Property VerifyImg As %String(MAXLEN = 150);

ClassMethod SetInfo(jsonobj As %Library.DynamicObject, Id As %Integer = -1) As MyAchieve.Clients.Experience
{
	if (Id > -1) {
		set lobj = ..%OpenId(Id)	
	}
	else {
		set lobj = ..%New()	
	}
	
	if jsonobj.%IsDefined("Title") set lobj.Title = jsonobj.Title
	if jsonobj.%IsDefined("Level") set lobj.Level = jsonobj.Level
	if jsonobj.%IsDefined("EventResult") set lobj.EventResult = jsonobj.EventResult
	if jsonobj.%IsDefined("Year") set lobj.Year = jsonobj.Year
	if jsonobj.%IsDefined("City") set lobj.City = jsonobj.City
	if jsonobj.%IsDefined("VerifyVideo") set lobj.VerifyVideo = jsonobj.VerifyVideo
	if jsonobj.%IsDefined("VerifyPhoto") set lobj.VerifyPhoto = jsonobj.VerifyPhoto
	if jsonobj.%IsDefined("VerifyImg") set lobj.VerifyImg = jsonobj.VerifyImg
	
	do lobj.%Save()
	return lobj
}

ClassMethod GetInfo(Id As %Integer) As %Library.DynamicObject
{
	set lobj = ..%OpenId(Id)
	set jsonobj = {}
	set jsonobj.Id = Id
	set jsonobj.Title = lobj.Title
	set jsonobj.Level = lobj.Level
	set jsonobj.EventResult = lobj.EventResult
	set jsonobj.Year = lobj.Year
	set jsonobj.City = lobj.City
	set jsonobj.VerifyVideo = lobj.VerifyVideo
	set jsonobj.VerifyPhoto = lobj.VerifyPhoto
	set jsonobj.VerifyImg = lobj.VerifyImg
	return jsonobj
}

Storage Default
{
<Data name="EventDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Title</Value>
</Value>
<Value name="3">
<Value>Level</Value>
</Value>
<Value name="4">
<Value>Year</Value>
</Value>
<Value name="5">
<Value>EventResult</Value>
</Value>
<Value name="6">
<Value>City</Value>
</Value>
<Value name="7">
<Value>VerifyUrl</Value>
</Value>
<Value name="8">
<Value>VerifyImg</Value>
</Value>
<Value name="9">
<Value>VerifyPhoto</Value>
</Value>
<Value name="10">
<Value>VerifyVideo</Value>
</Value>
</Data>
<DataLocation>^MyAchieve.Events.EventD</DataLocation>
<DefaultData>EventDefaultData</DefaultData>
<IdLocation>^MyAchieve.Events.EventD</IdLocation>
<IndexLocation>^MyAchieve.Events.EventI</IndexLocation>
<StreamLocation>^MyAchieve.Events.EventS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

