Class MyAchieve.Events.EventOrganizer Extends %Persistent
{

Relationship Event As MyAchieve.Events.Event [ Cardinality = one, Inverse = Organizers ];

Index EventIndex On Event;

Relationship Organizer As MyAchieve.Clients.Organizer [ Cardinality = one, Inverse = Events ];

Index OrganizerIndex On Organizer;

Storage Default
{
<Data name="EventOrganizerDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Event</Value>
</Value>
<Value name="3">
<Value>Organizer</Value>
</Value>
</Data>
<DataLocation>^MyAchieve.ED4B3.EventOrganizerD</DataLocation>
<DefaultData>EventOrganizerDefaultData</DefaultData>
<IdLocation>^MyAchieve.ED4B3.EventOrganizerD</IdLocation>
<IndexLocation>^MyAchieve.ED4B3.EventOrganizerI</IndexLocation>
<StreamLocation>^MyAchieve.ED4B3.EventOrganizerS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

