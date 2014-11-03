# Search contact by UserConnId

	GET		/contact/search/0000.json

	where 0000 is a user connid
	
Params
	
		SearchFName - not mandatory, default none
		SearchMName - not mandatory, default none
		SearchLName - not mandatory, default none
		SearchBusName - not mandatory, default none
		StrtRow - not mandatory, default 0 (pagination)
		Count - not mandatory, default 300 (pagination)

Returned columns

	RowID
	FullName
	IsBusiness
	PhoneNumber
	ContactId

Examples

*get all contacts*

	GET        /contact/search/0000.json
	
	CAIRS.MAP.API.get({
	   resource : 	"/contact/search/0000" 
	   ,format : "json" 
	   ,payload : "SearchFName=Mar&SearchMName=&SearchLName=Liv&SearchBusName="
	   ,onSuccess : function(request)
	   { 
			var json = JSON.parse( request.response );
			if( json.status == "success" )	
			{
				alert(json.contact);
				console.log(json.contact);
				alert(json.contact[0].FullName);
			}
	   }
	   ,onFail : function(request)
	   {
			var json = JSON.parse( request.response );
	   }
	});


# Search contactId's of a couple connid

	GET		/contact/search/couple/0000.json

	where 0000 is a user couple connid
	


Returned columns

	ContactId1
	ContactId2

Examples

	CAIRS.MAP.API.get({
	   resource : 	"/contact/search/couple/0000" 
	   ,format : "json" 
	   ,onSuccess : function(request)
	   { 
			var json = JSON.parse( request.response );
			if( json.status == "success" )	
			{
				alert(json.contact);
				console.log(json.contact);
				alert(json.contact[0].ContactId1);
			}
	   }
	   ,onFail : function(request)
	   {
			var json = JSON.parse( request.response );
	   }
	});



# Search contactId's of a couple contact id

send back the other person of the current couple of the contactid sent in

	GET		/contact/search/couple/another/0000.json

	where 0000 is a user contact_id
	


Returned columns

	OtherContactId

Examples

	CAIRS.MAP.API.get({
	   resource : 	"/contact/search/couple/another/0000" 
	   ,format : "json" 
	   ,onSuccess : function(request)
	   { 
			var json = JSON.parse( request.response );
			if( json.status == "success" )	
			{
				alert(json.contact);
				console.log(json.contact);
				alert(json.contact[0].OtherContactId);
			}
	   }
	   ,onFail : function(request)
	   {
			var json = JSON.parse( request.response );
	   }
	});
