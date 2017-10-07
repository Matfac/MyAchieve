Class MyAchieve.Events.Event Extends %Persistent
{

Property Title As %String [ Required ];

Property Level As %Integer(DISPLAYLIST = "-Городской-Региональный-Всероссийский-Международный", VALUELIST = "-1-2-3-4") [ Required ];

Property Year As %Integer [ Required ];

Relationship Organizers As MyAchieve.Events.EventOrganizer [ Cardinality = many, Inverse = Event ];

Relationship Students As MyAchieve.Events.EventStudent [ Cardinality = many, Inverse = Event ];

ClassMethod QSet(jsonobj As %Library.DynamicArray, Type As %String, User As %String = {$Username}) As %Status
{
	if (Type = "student") {
		set iter = jsonobj.%GetIterator()
		while iter.%GetNext(.key, .value) {
			if (value.%IsDefined("Id")) 
			{
				&sql(SELECT Student FROM MyAchieve_Events.EventStudent WHERE Event = :value.Id AND Student = :User)
				if (SQLCODE = 100) {
					&sql(INSERT INTO MyAchieve_Events.EventStudent ("Event","Student") values(:value.Id, :User))
				}
			}
		}
	}
	if (Type = "organizer") {
		set iter = jsonobj.%GetIterator()
		while iter.%GetNext(.key, .value) {
			if (value.%IsDefined("Id")) 
			{
				&sql(SELECT Organizer INTO :Organizer FROM MyAchieve_Events.EventOrganizer WHERE Event = :value.Id)
				if (SQLCODE '= 100) {
					if (Organizer = User) {
						set eventobj = ..%OpenId(value.Id)
						if value.%IsDefined("Title") set eventobj.Title = value.Title
						if value.%IsDefined("Level") set eventobj.Level = value.Level
						if value.%IsDefined("Year") set eventobj.Year = value.Year
						do eventobj.%Save()		
					}
				}
			}
			else 
			{
				set eventobj = ..%New()
				if value.%IsDefined("Title") set eventobj.Title = value.Title
				if value.%IsDefined("Level") set eventobj.Level = value.Level
				if value.%IsDefined("Year") set eventobj.Year = value.Year
				do eventobj.%Save()
				set eventId = eventobj.%Id()
				&sql(INSERT INTO MyAchieve_Events.EventOrganizer ("Event","Organizer") values(:eventId, :User))
			}
		}
	}
	return $$$OK
}

ClassMethod QDel(jsonobj As %Library.DynamicArray, Type As %String, User As %String = {$Username}) As %Status
{
	if (Type = "student") {
		set iter = jsonobj.%GetIterator()
		while iter.%GetNext(.key, .value) {
			if (value) 
			{
				&sql(SELECT ID, Student INTO :EID, :Student FROM MyAchieve_Events.EventStudent WHERE Event = :value)
				if (SQLCODE '= 100) {
					if (Student = User) {
						&sql(DELETE FROM MyAchieve_Events.EventStudent WHERE ID=:EID)
					}
				}
			}
		}
	}
	if (Type = "organizer") {
		set iter = jsonobj.%GetIterator()
		while iter.%GetNext(.key, .value) {
			if (value) 
			{
				&sql(SELECT ID, Organizer INTO :EID, :Organizer FROM MyAchieve_Events.EventOrganizer WHERE Event = :value)
				if (SQLCODE '= 100) {
					if (Organizer = User) {
						&sql(DELETE FROM MyAchieve_Events.EventOrganizer WHERE "ID"=:EID)
						&sql(DELETE FROM MyAchieve_Events.EventStudent WHERE "Event"=:value)
						&sql(DELETE FROM MyAchieve_Events.Event WHERE "ID"=:value)
					}
				}
			}
		}
	}
	return $$$OK
}

ClassMethod QGet(Type As %String, User As %String = {$Username}) As %Library.DynamicObject
{
	set out = {}
	set out.Events = []
	if (Type = "student") {
		&sql(DECLARE getEventsStud CURSOR FOR SELECT MyAchieve_Events.Event.ID, MyAchieve_Events.Event.Title, 
		"Level", "Year", MyAchieve_Clients.Organizer.Title As "Organizer" 
		INTO :ID, :Title, :Level, :Year, :Organizer FROM MyAchieve_Events.EventOrganizer LEFT JOIN MyAchieve_Events.Event
		ON MyAchieve_Events.Event.ID = MyAchieve_Events.EventOrganizer.Event LEFT JOIN MyAchieve_Clients.Organizer 
		ON MyAchieve_Events.EventOrganizer.Organizer = MyAchieve_Clients.Organizer.ID LEFT JOIN MyAchieve_Events.EventStudent
		ON MyAchieve_Events.EventStudent.Event = MyAchieve_Events.Event.ID WHERE "Student" = :User)
		&sql(OPEN getEventsStud)
   		FOR { &sql(FETCH getEventsStud)
    	    QUIT:SQLCODE
    	    set event = {}
	 	  	set event.Id = ID
    		set event.Title = Title
    		set event.Level = Level
    		set event.Year = Year
    		set event.Organizer = Organizer
    		&sql(SELECT COUNT(Student) INTO :Students FROM MyAchieve_Events.EventStudent LEFT JOIN MyAchieve_Events.Event
			ON MyAchieve_Events.Event.ID = MyAchieve_Events.EventStudent.Event LEFT JOIN MyAchieve_Clients.Student
			ON MyAchieve_Events.EventStudent.Student = MyAchieve_Clients.Student.ID WHERE MyAchieve_Events.Event.ID = :ID)
			set event.Students = Students
    		do out.Events.%Push(event)
 		}
 		&sql(CLOSE getEventsStud)
	}
	if (Type = "organizer") {
		&sql(DECLARE getEventsOrg CURSOR FOR SELECT MyAchieve_Events.Event.ID, Title, "Level", Year
		INTO :ID, :Title, :Level, :Year FROM MyAchieve_Events.EventOrganizer LEFT JOIN MyAchieve_Events.Event
		ON MyAchieve_Events.EventOrganizer.Event = MyAchieve_Events.Event.ID WHERE "Organizer" = :User)
		&sql(OPEN getEventsOrg)
   		FOR { &sql(FETCH getEventsOrg)
    	    QUIT:SQLCODE
    	    set event = {}
	 	  	set event.Id = ID
    		set event.Title = Title
    		set event.Level = Level
    		set event.Year = Year
    		set event.Organizer = "Вы"
    		&sql(DECLARE getEventStudentsOrg CURSOR FOR SELECT Surname, Name, Patronymic, Email, Birthday 
    		INTO :Surname, :Name, :Patronymic, :Email, :Birthday FROM MyAchieve_Events.EventStudent LEFT JOIN MyAchieve_Events.Event
			ON MyAchieve_Events.Event.ID = MyAchieve_Events.EventStudent.Event LEFT JOIN MyAchieve_Clients.Student
			ON MyAchieve_Events.EventStudent.Student = MyAchieve_Clients.Student.ID WHERE MyAchieve_Events.Event.ID = :ID)
			set Students = []
			&sql(OPEN getEventStudentsOrg)
			FOR { &sql(FETCH getEventStudentsOrg)
				QUIT:SQLCODE
				set Student = {}
				set Student.Surname = Surname
				set Student.Name = Name
				set Student.Patronymic = Patronymic
				set Student.Email = Email
				set Student.Birthday = $zdate(Birthday, 3)
				do Students.%Push(Student)
			}
			&sql(CLOSE getEventStudentsOrg)
			set event.Students = Students
    		do out.Events.%Push(event)
 		}
 		&sql(CLOSE getEventsOrg)
	}
 	return out
}

ClassMethod QGetAll(Type As %String) As %Library.DynamicObject
{
	set out = {}
	set out.Events = []
	&sql(DECLARE getEventsAll CURSOR FOR SELECT MyAchieve_Events.Event.ID, MyAchieve_Events.Event.Title, 
	"Level", "Year", MyAchieve_Clients.Organizer.Title As "Organizer" 
	INTO :ID, :Title, :Level, :Year, :Organizer FROM MyAchieve_Events.EventOrganizer LEFT JOIN MyAchieve_Events.Event
	ON MyAchieve_Events.Event.ID = MyAchieve_Events.EventOrganizer.Event LEFT JOIN MyAchieve_Clients.Organizer 
	ON MyAchieve_Events.EventOrganizer.Organizer = MyAchieve_Clients.Organizer.ID)
	&sql(OPEN getEventsAll)
   	FOR { &sql(FETCH getEventsAll)
        QUIT:SQLCODE
        set event = {}
	   	set event.Id = ID
    	set event.Title = Title
    	set event.Level = Level
    	set event.Year = Year
    	set event.Organizer = Organizer
    	if (Type = "employer")
    	{
    		&sql(DECLARE getEventStudents CURSOR FOR SELECT Surname, Name, Patronymic, Email, Birthday
    		INTO :Surname, :Name, :Patronymic, :Email, :Birthday FROM MyAchieve_Events.EventStudent LEFT JOIN MyAchieve_Events.Event
			ON MyAchieve_Events.Event.ID = MyAchieve_Events.EventStudent.Event LEFT JOIN MyAchieve_Clients.Student
			ON MyAchieve_Events.EventStudent.Student = MyAchieve_Clients.Student.ID WHERE MyAchieve_Events.Event.ID = :ID)
			set Students = []
			&sql(OPEN getEventStudents)
			FOR { &sql(FETCH getEventStudents)
				QUIT:SQLCODE
				set Student = {}
				set Student.Surname = Surname
				set Student.Name = Name
				set Student.Patronymic = Patronymic
				set Student.Email = Email
				set Student.Birthday = $zdate(Birthday, 3)
				do Students.%Push(Student)
			}
			&sql(CLOSE getEventStudents)
    	}
    	else
    	{
			&sql(SELECT COUNT(Student) INTO :Students FROM MyAchieve_Events.EventStudent LEFT JOIN MyAchieve_Events.Event
				ON MyAchieve_Events.Event.ID = MyAchieve_Events.EventStudent.Event LEFT JOIN MyAchieve_Clients.Student
				ON MyAchieve_Events.EventStudent.Student = MyAchieve_Clients.Student.ID WHERE MyAchieve_Events.Event.ID = :ID)
    	}
		set event.Students = Students
    	do out.Events.%Push(event)
 	}
 	&sql(CLOSE getEventsAll)
 	return out
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
</Data>
<DataLocation>^MyAchieve.Events.EventD</DataLocation>
<DefaultData>EventDefaultData</DefaultData>
<IdLocation>^MyAchieve.Events.EventD</IdLocation>
<IndexLocation>^MyAchieve.Events.EventI</IndexLocation>
<StreamLocation>^MyAchieve.Events.EventS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

