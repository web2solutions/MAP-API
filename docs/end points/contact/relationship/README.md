#  Relationship end points

**Relationship list**

	GET		/contact/relationship.json

Calling Parameters: 		

	@ConnId int 		,@ConnectionId int  = 0 		,@RelationshipSubTypeIds varchar(500) = '' 		,@RelationsshipTypeIds varchar(500) = ''	

Return Values:	
	
	PrimaryConnId	PrimaryName	RelConnId	RelName	RelationshipSubTypeId	RelationshipSubTypeText	ConnectionId1	RelTypeid1	RelTypeText1
	
	
**Couple contact list**

	GET		/contact/relationship/couple/list.json

Calling Parameters: 		

	@ConnId int 

Return Values:	
	
	Connid	Name

	
**Employer list**

	GET		/contact/relationship/employer/list.json
	
Calling Parameters: 		

	@EmployerConnId  varchar(50)    	,@SearchName varchar(500) = '' 	,@StrtRow INT =0 	,@Count INT =100

Return Values:	
	
	TotalCount	RowID	FullName	ConnId 


**Relationship Type end point**

	GET		/contact/relationship/type.json
	GET		/contact/relationship/type/0000.json
	POST		/contact/relationship/type.json
	PUT		/contact/relationship/type/0000.json
	DEL		/contact/relationship/type/0000.json


*online example*: http://cdmap01.myadoptionportal.com/modules/CAIRS_Framework/Rel_lkp_RelationshipType.html


**Relationship Sub Type end point**

	GET		/contact/relationship/subtype.json
	GET		/contact/relationship/subtype/0000.json
	POST		/contact/relationship/subtype.json
	PUT		/contact/relationship/subtype/0000.json
	DEL		/contact/relationship/subtype/0000.json


*online example*: http://cdmap01.myadoptionportal.com/modules/CAIRS_Framework/Rel_lkp_RelationshipSubType.html


**Relationship Components configuration**

	GET		/contact/relationship/component/:field_id/configuration.json
	GET		/contact/relationship/component/:field_id/configuration/0000.json
	POST		/contact/relationship/component/:field_id/configuration.json
	PUT		/contact/relationship/component/:field_id/configuration/0000.json
	DEL		/contact/relationship/component/:field_id/configuration/0000.json

Note

	:field_id is the field id of the component on FormBuilder.
	you can pass also a list of field ids. For example: 5678,5680,5681


=============================
