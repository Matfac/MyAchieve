Class MyAchieve.Manage.Authentication Extends %CSP.REST
{

XData UrlMap
{
<Routes>
	<Route Url="/" Method="POST" Call="LoginUser"/>
	<Route Url="/save" Method="POST" Call="SaveUser"/>
	<Route Url="/savelogo" Method="POST" Call="SaveLogo"/>
	<Route Url="/events" Method="POST" Call="GetEvents"/>
</Routes>
}

ClassMethod LoginUser() As %Status
{
	set out = {}
	set ns = $namespace
	zn "%SYS"
	do ##class(Security.Users).Get($username, .Prop)
	set fullname = Prop("FullName")
	zn ns
	set viewrole = ""
	if (fullname = "Обучающийся") {
		set viewrole = fullname
		set out.User = ##class(MyAchieve.Clients.Student).GetInfo()
	}
	if (fullname = "Организатор") {
		set viewrole = fullname
		set out.User = ##class(MyAchieve.Clients.Organizer).GetInfo()
	}
	if (fullname = "Работодатель") {
		set viewrole = fullname
		set out.User = ##class(MyAchieve.Employers.Employer).GetInfo()
	}
	if (viewrole '= "") {
    	set out.Type = viewrole
    	write out.%ToJSON()
	}
	return $$$OK
}

ClassMethod SaveUser() As %Status
{
	set out = {}
	set obj = {}.%FromJSON(%request.Content)
	set objstr = $zcvt(obj.%ToJSON(),"I","UTF8")
	set obj = {}.%FromJSON(objstr)
	set ns = $namespace
	zn "%SYS"
	do ##class(Security.Users).Get($username, .Prop)
	set fullname = Prop("FullName")
	zn ns
	if (fullname = "Обучающийся") {
		set st = ##class(MyAchieve.Clients.Student).SetInfo(obj)
		if $$$ISERR(st) return st
		set viewrole = fullname
		set out.User = ##class(MyAchieve.Clients.Student).GetInfo()
	}
	if (fullname = "Организатор") {
		set st = ##class(MyAchieve.Clients.Organizer).SetInfo(obj)
		if $$$ISERR(st) return st
		set viewrole = fullname
		set out.User = ##class(MyAchieve.Clients.Organizer).GetInfo()
	}
	if (fullname = "Работодатель") {
		set st = ##class(MyAchieve.Employers.Employer).SetInfo(obj)
		if $$$ISERR(st) return st
		set viewrole = fullname
		set out.User = ##class(MyAchieve.Employers.Employer).GetInfo()
	}
	set out.Type = viewrole
    write out.%ToJSON()
	return $$$OK
}

ClassMethod SaveLogo() As %Status
{
	set stream = %request.MimeData("FileStream",1)
	set type = stream.ContentType
	set types = "jpeg png"
	if (stream.Size <= 512000) && ($PIECE(type, "/", 1) = "image") && ($FIND(types, $PIECE(type, "/", 2)) > 0) {
		set ns = $namespace
		zn "%SYS"
		do ##class(Security.Users).Get($username, .Prop)
		set fullname = Prop("FullName")
		zn ns
		if (fullname = "Обучающийся") {
			set obj = ##class(MyAchieve.Clients.Student).%OpenId($username)
		}
		if (fullname = "Организатор") {
			set obj = ##class(MyAchieve.Clients.Organizer).%OpenId($username)
		}
		if (fullname = "Работодатель") {
			set obj = ##class(MyAchieve.Employers.Employer).%OpenId($username)
		}
		set img = ##class(MyAchieve.Manage.ImageFile).%New()
		set img.FileData = stream
		set img.FileName = stream.FileName
		set img.FileType = stream.ContentType
		if (obj.Logo '= "") {
			do ##class(MyAchieve.Manage.ImageFile).%DeleteId(obj.Logo.%Id())	
		}
		set obj.Logo = img
		do img.%Save()
		do obj.%Save()
		return $$$OK
	}
	return $$$ERROR("ERROR")
}

ClassMethod LoadLogo() As %Status
{
	set ns = $namespace
	zn "%SYS"
	do ##class(Security.Users).Get($username, .Prop)
	set fullname = Prop("FullName")
	zn ns
	if (fullname = "Обучающийся") {
		set obj = ##class(MyAchieve.Clients.Student).%OpenId($username)
	}
	if (fullname = "Организатор") {
		set obj = ##class(MyAchieve.Clients.Organizer).%OpenId($username)
	}
	if ((fullname = "Работодатель")) {
		set obj = ##class(MyAchieve.Employers.Employer).%OpenId($username)
	}
	if (obj.Logo '= "") {
		set objimg = obj.Logo
		set %response.ContentType = objimg.FileType
		do %response.SetHeader("Content-Disposition","attachment; filename="""_objimg.FileName_"""")
		do objimg.FileData.OutputToDevice()
		return $$$OK
	}
	return $$$NO
}

ClassMethod GetEvents() As %Status
{
	set ns = $namespace
	zn "%SYS"
	do ##class(Security.Users).Get($username, .Prop)
	set fullname = Prop("FullName")
	zn ns
	if (fullname = "Работодатель")
	{
		w ##class(MyAchieve.Events.Event).QGetAll("employer").%ToJSON()
	}
	else
	{
		w ##class(MyAchieve.Events.Event).QGetAll("none").%ToJSON()	
	}
	return $$$OK
}

}

