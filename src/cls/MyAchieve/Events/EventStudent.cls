Class MyAchieve.Events.EventStudent Extends %Persistent
{

Relationship Event As MyAchieve.Events.Event [ Cardinality = one, Inverse = Students ];

Index EventIndex On Event;

Relationship Student As MyAchieve.Clients.Student [ Cardinality = one, Inverse = Events ];

Index StudentIndex On Student;

Storage Default
{
<Data name="EventStudentDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Event</Value>
</Value>
<Value name="3">
<Value>Student</Value>
</Value>
</Data>
<DataLocation>^MyAchieve.Events.EventStudentD</DataLocation>
<DefaultData>EventStudentDefaultData</DefaultData>
<IdLocation>^MyAchieve.Events.EventStudentD</IdLocation>
<IndexLocation>^MyAchieve.Events.EventStudentI</IndexLocation>
<StreamLocation>^MyAchieve.Events.EventStudentS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

