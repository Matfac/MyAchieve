Class MyAchieve.Manage.Authentication Extends %CSP.REST
{

XData UrlMap
{
<Routes>
	<Route Url="/" Method="POST" Call="LoginUser"/>
	<Route Url="/save" Method="POST" Call="SaveUser"/>
	<Route Url="/saveimg" Method="POST" Call="SaveImg"/>
	<Route Url="/events" Method="POST" Call="GetEvents"/>
	<Route Url="/reg" Method="POST" Call="CreateStudent"/>
	<Route Url="/getst/:format" Method="POST" Call="GetFormatStudents"/>
</Routes>
}

ClassMethod CreateStudent() As %Status
{
	set out = {}
	set obj = {}.%FromJSON(%request.Content)
	set objstr = $zcvt(obj.%ToJSON(),"I","UTF8")
	set obj = {}.%FromJSON(objstr)
	if obj.Login '= "None" {
		set st = ##class(MyAchieve.Clients.Student).SetInfo(obj, "sa_"_obj.Login)
		if $$$ISERR(st) return st
		set out.User = ##class(MyAchieve.Clients.Organizer).GetInfo()
		set out.Type = "Организатор"
		w out.%ToJSON()
	}
	else
	{
		if (obj.Type = "student") {
			set fullname = "Обучающийся"
			set studlogin = $piece($horolog, ",", 1)_$piece($horolog, ",", 2)
			set st = ##class(MyAchieve.Clients.Student).SetInfo(obj, "sa_st"_studlogin)
			if $$$ISERR(st) return st
			set ns = $namespace
			zn "%SYS"
			set sc = ..CreateUserInternal("sa_st"_studlogin,, "st"_studlogin, fullname, ns)
			if $$$ISERR(sc) return sc
			zn ns
		}
	}
	return $$$OK
}

ClassMethod CreateUserInternal(Login, Roles = "", Password, FullName, NameSpace = "") As %Status
{
	set sc = ##class(Security.Users).Create(Login, Roles, Password, FullName, NameSpace)
	quit sc
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
		set out.User = ##class(MyAchieve.Clients.Employer).GetInfo()
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
		set st = ##class(MyAchieve.Clients.Employer).SetInfo(obj)
		if $$$ISERR(st) return st
		set viewrole = fullname
		set out.User = ##class(MyAchieve.Clients.Employer).GetInfo()
	}
	set out.Type = viewrole
    write out.%ToJSON()
	return $$$OK
}

ClassMethod SaveImg() As %Status
{
	set stream = %request.MimeData("FileStream",1)
	set type = stream.ContentType
	set types = "jpeg png"
	if (stream.Size <= 512000) && ($PIECE(type, "/", 1) = "image") && ($FIND(types, $PIECE(type, "/", 2)) > 0) {
		set img = ##class(MyAchieve.Manage.ImageFile).%New()
		set img.FileData = stream
		set img.FileName = stream.FileName
		set img.FileType = stream.ContentType
		do img.%Save()
		w ##class(MyAchieve.Manage.Root).IdEncrypt(img.%Id())
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
		set obj = ##class(MyAchieve.Clients.Employer).%OpenId($username)
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

/*ClassMethod GetEvents() As %Status
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
}*/
ClassMethod GetFormatStudents(format As %String) As %Status
{
	set ns = $namespace
	zn "%SYS"
	do ##class(Security.Users).Get($username, .Prop)
	set fullname = Prop("FullName")
	zn ns
	if (fullname = "Работодатель")
	{
	set jsonobj = {}
	set jsonobj.Events = []
	set resfoa = $piece(format, "-", 1)
	set resbmin = $piece(format, "-", 2)
	set resbmax = $piece(format, "-", 3)
	&sql(DECLARE getStudents CURSOR FOR SELECT ID INTO :StudID FROM MyAchieve_Clients.Student)
	&sql(OPEN getStudents)
   	FOR { &sql(FETCH getStudents)
        QUIT:SQLCODE
        set st = ##class(MyAchieve.Clients.Student).GetInfo(StudID)
        set st.Login = ""
        set st.Address.Street = ""
        set st.Address.Home = ""
        set st.Address.ZipCode = ""
        set b = st.Birthday
        set age = $zdateh($piece(b, ".", 3)_"-"_$piece(b, ".", 2)_"-"_$piece(b, ".", 1),3)
        if age <= $piece($horolog,",",1) set b = $piece($zdate($piece($horolog,",",1)-age,3),"-",1)-1841
        
        if ((resfoa = "0") || (resfoa = st.Foa)) && ((b >= resbmin) && (b <= resbmax)) {
        	do jsonobj.Events.%Push(st)
        }
    }
 	&sql(CLOSE getStudents)
 	write jsonobj.%ToJSON()
	}
 	return $$$OK
}

}

