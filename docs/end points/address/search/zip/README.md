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
````Javascript	
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
````
Returned response

````Javascript
	{"sql":"SELECT s.StateID as StateID, s.StateName as StateName, c.CountyID as CountyID, c.CountyText as CountyText FROM lkpState s join lkpCounty c on s.StateId = c.StateId join lkpCountyZip cz on c.CountyID = cz.CountyID WHERE cz.Zip = ?","response":"search done","status":"success","address":[{"CountyText":"Rogers","CountyID":2191,"StateID":50,"StateName":"Oklahoma"}]}
````
