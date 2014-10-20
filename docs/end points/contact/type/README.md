# Contact type End Point

	GET		/contact/types/all.json
	GET		/contact/types/business.json
	GET		/contact/types/person.json
	GET		/contact/types/0000.json
	POST		/contact/types.json
	PUT		/contact/types/0000.json
	DEL		/contact/types/0000.json

Examples

*get contact types by passing IsBusiness*

	GET        /contact.json
	
	CAIRS.MAP.API.get({
	   resource : 	"/contact/types/all" 
	   ,format : "json" 
	   ,payload : "IsBusiness=1"
	   ,onSuccess : function(request)
	   { 
			var json = JSON.parse( request.response );
			if( json.status == "success" )	
			{
				alert(json.types);
				console.log(json.types);
				alert(json.types[0].RelationshipTypeId);
				alert(json.types[0].RelationshipTypeText);
			}
	   }
	   ,onFail : function(request)
	   {
			var json = JSON.parse( request.response );
	   }
	});
	
	
	CAIRS.MAP.API.get({
	   resource : 	"/contact/types/all" 
	   ,format : "json" 
	   ,payload : "IsBusiness=0"
	   ,onSuccess : function(request)
	   { 
			var json = JSON.parse( request.response );
			if( json.status == "success" )	
			{
				alert(json.types);
				console.log(json.types);
				alert(json.types[0].RelationshipTypeId);
				alert(json.types[0].RelationshipTypeText);
			}
	   }
	   ,onFail : function(request)
	   {
			var json = JSON.parse( request.response );
	   }
	});

*get business contact types only*

	GET        /contact/types/business.json
	
	CAIRS.MAP.API.get({
	   resource : 	"/contact/types/business" 
	   ,format : "json"
	   ,onSuccess : function(request)
	   { 
			var json = JSON.parse( request.response );
			if( json.status == "success" )	
			{
				alert(json.types);
				console.log(json.types);
				alert(json.types[0].RelationshipTypeId);
				alert(json.types[0].RelationshipTypeText);
			}
	   }
	   ,onFail : function(request)
	   {
			var json = JSON.parse( request.response );
	   }
	});

*get not business contact types only*

	GET        /contact/types/person.json
	
	CAIRS.MAP.API.get({
	   resource : 	"/contact/types/person" 
	   ,format : "json"
	   ,onSuccess : function(request)
	   { 
			var json = JSON.parse( request.response );
			if( json.status == "success" )	
			{
				alert(json.types);
				console.log(json.types);
				alert(json.types[0].RelationshipTypeId);
				alert(json.types[0].RelationshipTypeText);
			}
	   }
	   ,onFail : function(request)
	   {
			var json = JSON.parse( request.response );
	   }
	});