Class MyAchieve.Clients.Experience Extends %Persistent
{

Property GetExp As %Integer(DISPLAYLIST = "-стажировка-практика-профессиональная проба-другое", VALUELIST = "-1-2-3-4") [ Required ];

Property Name As %String(MAXLEN = 250) [ Required ];

Property Organizer As %String(MAXLEN = 250) [ Required ];

Property Country As %String [ Required ];

Property City As %String [ Required ];

Property Exp As %String(MAXLEN = 1500) [ Required ];

Property VerifyPhoto As %String(MAXLEN = 150);

Property VerifyImg As %String(MAXLEN = 150);

Property VerifyVideo As %String(MAXLEN = 150);

Property VerifyUrl As %String(MAXLEN = 150);

ClassMethod SetInfo(jsonobj As %Library.DynamicObject, Id As %Integer = -1) As MyAchieve.Clients.Experience
{
	if (Id > -1) {
		set lobj = ..%OpenId(Id)	
	}
	else {
		set lobj = ..%New()	
	}
	if jsonobj.%IsDefined("GetExp") set lobj.GetExp = jsonobj.GetExp
	if jsonobj.%IsDefined("Name") set lobj.Name = jsonobj.Name
	if jsonobj.%IsDefined("Organizer") set lobj.Organizer = jsonobj.Organizer
	if jsonobj.%IsDefined("Country") set lobj.Country = jsonobj.Country
	if jsonobj.%IsDefined("City") set lobj.City = jsonobj.City
	if jsonobj.%IsDefined("Exp") set lobj.Exp = jsonobj.Exp
	if jsonobj.%IsDefined("VerifyVideo") set lobj.VerifyVideo = jsonobj.VerifyVideo
	if jsonobj.%IsDefined("VerifyUrl") set lobj.VerifyUrl = jsonobj.VerifyUrl
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
	set jsonobj.GetExp = lobj.GetExp
	set jsonobj.Name = lobj.Name
	set jsonobj.Organizer = lobj.Organizer
	set jsonobj.Country = lobj.Country
	set jsonobj.City = lobj.City
	set jsonobj.Exp = lobj.Exp
	set jsonobj.VerifyVideo = lobj.VerifyVideo
	set jsonobj.VerifyUrl = lobj.VerifyUrl
	set jsonobj.VerifyPhoto = lobj.VerifyPhoto
	set jsonobj.VerifyImg = lobj.VerifyImg
	return jsonobj
}

Storage Default
{
<Data name="ExperienceDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>GetExp</Value>
</Value>
<Value name="3">
<Value>Name</Value>
</Value>
<Value name="4">
<Value>Organizer</Value>
</Value>
<Value name="5">
<Value>Country</Value>
</Value>
<Value name="6">
<Value>City</Value>
</Value>
<Value name="7">
<Value>Exp</Value>
</Value>
<Value name="8">
<Value>VerifyPhoto</Value>
</Value>
<Value name="9">
<Value>VerifyImg</Value>
</Value>
<Value name="10">
<Value>VerifyVideo</Value>
</Value>
<Value name="11">
<Value>VerifyUrl</Value>
</Value>
</Data>
<DataLocation>^MyAchieve.Clients.ExperienceD</DataLocation>
<DefaultData>ExperienceDefaultData</DefaultData>
<IdLocation>^MyAchieve.Clients.ExperienceD</IdLocation>
<IndexLocation>^MyAchieve.Clients.ExperienceI</IndexLocation>
<StreamLocation>^MyAchieve.Clients.ExperienceS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

