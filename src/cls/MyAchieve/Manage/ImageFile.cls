Class MyAchieve.Manage.ImageFile Extends %Persistent
{

Property FileName As %String;

Property FileType As %String;

Property FileData As %Stream.GlobalBinary;

Storage Default
{
<Data name="ImageFileDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>FileName</Value>
</Value>
<Value name="3">
<Value>FileType</Value>
</Value>
<Value name="4">
<Value>FileData</Value>
</Value>
</Data>
<DataLocation>^MyAchieve.Manage.ImageFileD</DataLocation>
<DefaultData>ImageFileDefaultData</DefaultData>
<IdLocation>^MyAchieve.Manage.ImageFileD</IdLocation>
<IndexLocation>^MyAchieve.Manage.ImageFileI</IndexLocation>
<StreamLocation>^MyAchieve.Manage.ImageFileS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

