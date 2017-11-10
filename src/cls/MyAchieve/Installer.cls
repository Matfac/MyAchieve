Class MyAchieve.Installer Extends %Projection.AbstractProjection [ CompileAfter = (MyAchieve.Manage.Root, MyAchieve.Manage.Authentication) ]
{

Projection Reference As Installer;

ClassMethod CreateProjection(cls As %String, ByRef params) As %Status
{
    write !, "Registering web application /"
    set st = ##class(WebAppManager).Register("/", {"AutheEnabled": ($$$AutheUnauthenticated), "IsNameSpaceDefault": ($$$NO), 
    "DispatchClass": "MyAchieve.Manage.Root", "MatchRoles": ":%All"})
    if $$$ISERR(st) { return st }
    write !, "Registering web application /auth"
    set l = ##class(%ListOfDataTypes).%New()
    set st = ##class(WebAppManager).Register("/auth", {"IsNameSpaceDefault": ($$$NO), "DispatchClass": "MyAchieve.Manage.Authentication",
    "MatchRoles": ":%All"})
    if $$$ISERR(st) { return st }
    write !, "Registering web application /gui"
    set st = ##class(WebAppManager).Register("/gui", {"AutheEnabled": ($$$AutheUnauthenticated), "IsNameSpaceDefault": ($$$NO), "Path": "gui/"})
    return st
}

/// This method is invoked when a class is 'uncompiled'.
ClassMethod RemoveProjection(cls As %String, ByRef params, recompile As %Boolean) As %Status
{
    return:recompile $$$OK
    write !, "Removing web application /"
    set st = ##class(WebAppManager).Delete("/", {
        "DispatchClass": "MyAchieve.Manage.Root"
    })
    if $$$ISERR(st) { return st }
    write !, "Removing web application /auth"
    set st = ##class(WebAppManager).Delete("/auth", {
        "DispatchClass": "MyAchieve.Manage.Authentication"
    })
    if $$$ISERR(st) { return st }
    write !, "Removing web application /gui"
    set ns = $namespace
	zn "%SYS"
	set st = ##class(Security.Applications).Get("/gui", .Prop)
    If $$$ISERR(st) { return st }
    zn ns
    set st = ##class(WebAppManager).Delete("/gui")
    do ##class(%File).RemoveDirectoryTree(Prop("Path"))
    return st
}

}

