# Search address by zip

	GET		/address/search/zip/00000.json

	where 0000 is a zip number
	
Params
	
	no params

Returned columns

	CountyText
	CountyID
	StateID
	StateName

Examples

*search by zip*

	GET        /contact/search/0000.json
	
	CAIRS.MAP.API.get({
	   resource : 	"/contact/search/74019" 
	   ,format : "json" 
	   ,onSuccess : function(request)
	   { 
			var json = JSON.parse( request.response );
			if( json.status == "success" )	
			{
				alert(json.address);
				console.log(json.address);
				alert(json.address[0].CountyText);
			}
	   }
	   ,onFail : function(request)
	   {
			var json = JSON.parse( request.response );
	   }
	});
