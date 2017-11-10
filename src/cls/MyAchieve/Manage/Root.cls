Class MyAchieve.Manage.Root Extends %CSP.REST
{

XData UrlMap
{
<Routes>
	<Route Url="/" Method="GET" Call="Root"/>
	<Route Url="/reg" Method="POST" Call="CreateNewUser"/>
	<Route Url="/img/:imgid" Method="GET" Call="LoadImage"/>
</Routes>
}

ClassMethod Root() As %Status
{
    write "<script>location = '/gui/index.html';</script>"
    return $$$OK
}

ClassMethod CreateNewUser() As %Status
{
	set obj = {}.%FromJSON(%request.Content)
	set objstr = $zcvt(obj.%ToJSON(),"I","UTF8")
	set obj = {}.%FromJSON(objstr)
	if (obj.Type = "organizer") {
		set fullname = "Организатор"
	}
	if (obj.Type = "employer") {
		set fullname = "Работодатель"
	}
	if (obj.Type = "organizer") set st = ##class(MyAchieve.Clients.Organizer).SetInfo(obj, "sa_"_obj.Login)
	if (obj.Type = "employer") set st = ##class(MyAchieve.Clients.Employer).SetInfo(obj, "sa_"_obj.Login)
	if $$$ISERR(st) return st
	set ns = $namespace
	zn "%SYS"
	if (obj.Type '= "student") { set sc = ..CreateUserInternal("sa_"_obj.Login,, obj.Password, fullname, ns) }
	if $$$ISERR(sc) return sc
	zn ns
	
	return $$$OK
}

ClassMethod CreateUserInternal(Login, Roles = "", Password, FullName, NameSpace = "") As %Status
{
	set sc = ##class(Security.Users).Create(Login, Roles, Password, FullName, NameSpace)
	quit sc
}

ClassMethod ListToJSON(L As %Collection.ListOfDT) As %Library.DynamicArray
{
	set JSONArr = []
	for i=1:1:L.Count() { do JSONArr.%Push(L.GetAt(i)) }
	return JSONArr
}

ClassMethod JSONToList(JSONArr As %Library.DynamicArray) As %ListOfDataTypes
{
	set L = ##class(%ListOfDataTypes).%New()
	set iter = JSONArr.%GetIterator()
	while iter.%GetNext(.key , .value) {
		do L.Insert(value)
	}
	return L
}

ClassMethod LoadImage(imgid As %String) As %Status
{
	set imgid = ..IdDecrypt(imgid)
	set img = ##class(MyAchieve.Manage.ImageFile).%OpenId(imgid)
	set %response.ContentType = img.FileType
	do %response.SetHeader("Content-Disposition","attachment; filename="""_img.FileName_"""")
	do img.FileData.OutputToDevice()
	return $$$OK
}

ClassMethod IdEncrypt(pid As %Integer) As %String
{
	set key = $SYSTEM.Encryption.Base64Encode("<0Th-is!1I-s2!Ke-y!3Fo-r4!Shar-ing!5Ima-ges6!>")
	set oid = $ZCONVERT(pid,"O","UTF8")
	set oid = $SYSTEM.Encryption.AESCBCEncrypt(oid, "StudAchieve_"_key_"_ImageKey")
	set boid = $SYSTEM.Encryption.Base64Encode(oid)
	set boid = $replace(boid, "+", "-")
	set boid = $replace(boid, "/", "_")
	return boid
}

ClassMethod IdDecrypt(boid As %String) As %Integer
{
	set boid = $replace(boid, "-", "+")
	set boid = $replace(boid, "_", "/")
	set key = $SYSTEM.Encryption.Base64Encode("<0Th-is!1I-s2!Ke-y!3Fo-r4!Shar-ing!5Ima-ges6!>")
	set oid = $SYSTEM.Encryption.Base64Decode(boid)
	set oid = $SYSTEM.Encryption.AESCBCDecrypt(oid, "StudAchieve_"_key_"_ImageKey")
	set oid = $ZCONVERT(oid,"I","UTF8")
	return oid
}

}

