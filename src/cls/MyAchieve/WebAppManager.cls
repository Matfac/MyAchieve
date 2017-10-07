Class MyAchieve.WebAppManager
{

ClassMethod Register(name As %String, config As %DynamicObject = {{}}) As %Status
{
    set ns = $Namespace
    new $Namespace
    try {
        set $Namespace = "%SYS"
    } catch (e) {
        return e.AsSystemError()
    }
    set st = $$$OK
    set spec("AutheEnabled") = $$$AutheCache // defaults
    set spec("NameSpace") = ns
    set iter = config.%GetIterator()
	while iter.%GetNext(.key, .value) {
	    set spec(key) = value
	}
    if ('##class(Security.Applications).Exists(name)) {
        return ##class(Security.Applications).Create(name, .spec)
    }
    return ##class(Security.Applications).Modify(name, .spec)
}

ClassMethod Delete(name As %String, matchingConfig As %DynamicObject = {{}})
{
    new $Namespace
    try {
        set $Namespace = "%SYS"
    } catch (e) {
        return e.AsSystemError()
    }
    set st = $$$OK
    return:'##class(Security.Applications).Exists(name)
    do ##class(Security.Applications).Get(name, .spec)
    set iter = matchingConfig.%GetIterator()
    while iter.%GetNext(.key, .value) {
        return:($get(spec(key)) '= value) st
    }
    return ##class(Security.Applications).Delete(name)
}

}

