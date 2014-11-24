# Contact End Points

Please navigate on above directories to read other end point documentations regarding contacts


## Main Contact End Point

	GET		/contact.json
	GET		/contact/0000.json
	POST		/contact.json
	PUT		/contact/0000.json
	DEL		/contact/0000.json
	GET    		/contact/dhtmlx/combo.xml

Examples

*get all contacts*

	GET        /contact.json
	
	CAIRS.MAP.API.get({
	   resource : 	"/contact" 
	   ,format : "json" 
	   ,payload : "columns=FName&order="+JSON.stringify({direction:'ASC', orderby:'FName'})
	   ,onSuccess : function(request)
	   { 
			var json = JSON.parse( request.response );
			if( json.status == "success" )	
			{
				alert(json.contact);
				console.log(json.contact);
				alert(json.contact[0].FName);
			}
	   }
	   ,onFail : function(request)
	   {
			var json = JSON.parse( request.response );
	   }
	});
	     

*get a contact*

	GET        /contact/0000.json
	
	CAIRS.MAP.API.get({
	   resource : 	"/contact/1416" 
	   ,format : "json" 
	   ,payload : "columns=FName"
	   ,onSuccess : function(request)
	   { 
			var json = JSON.parse( request.response );
			if( json.status == "success" )	
			{
				alert(json.hash);
				console.log(json.hash);
				alert(json.hash.FName);
			}
	   }
	   ,onFail : function(request)
	   {
			var json = JSON.parse( request.response );
	   }
	});

*insert new contact*

	POST      /contact.json
	
	var hash = {
		"FName" : "Eduardo", MName" : "Perotta", LName" : "de Almeida", Nickname" : "", BirthName" : "", BirthDate" : "", 
		Gender" : "", SSN" : "", PlaceOfBirthCity" : "", PlaceOfBirthStateId" : "", PlaceOfBirthCountryId" : "", 
		DateOfDeath" : "", DoNotSendMail" : "", BusName" : "", ContactNotes" : "", LicenceNumber" : "", FEIDNumber" : ""
	};
	
	CAIRS.MAP.API.post({
		resource : 	"/contact" 
		,format : "json"
		,payload : "hash=" + JSON.stringify( hash )
		,onSuccess : function( request ) 
		{ 
			var json = JSON.parse( request.response );
			console.log(request);
			alert("Id of the new contact: " + json.ContactId);
		}
		,onFail : function( request )
		{ 
			var json = JSON.parse( request.response );
		}
	});
     



*edit a contact*

	PUT        /contact/0000.json
	
	// var hash = form.getFormData();
	var hash = {
		"FName" : "José Eduardo", MName" : "Perotta", LName" : "de Almeida", Nickname" : "", BirthName" : "", BirthDate" : "", 
		Gender" : "", SSN" : "", PlaceOfBirthCity" : "", PlaceOfBirthStateId" : "", PlaceOfBirthCountryId" : "", 
		DateOfDeath" : "", DoNotSendMail" : "", BusName" : "", ContactNotes" : "", LicenceNumber" : "", FEIDNumber" : ""
	};
	
	CAIRS.MAP.API.put({
		resource : 	"/contact/1416" 
		,format : "json"
		,payload : "hash=" + JSON.stringify( hash )
		,onSuccess : function( request ) 
		{ 
			var json = JSON.parse( request.response );
			console.log(request);
			alert("Id of the updated contact: " + json.ContactId);
		}
		,onFail : function( request )
		{ 
			var json = JSON.parse( request.response );
		}
	});
     



*delete a contact*

	DEL        /contact/0000.json
	
	CAIRS.MAP.API.del({
	    resource: "/contact/0000",
	    format: "json",
	    onSuccess: function(request) {
	        var json = JSON.parse(request.response);
	        dhtmlx.message({
	            text: json.response
	        });
	        
	    },
	    onFail: function(request) {
	        var json = JSON.parse(request.response);
	        
	    }
	});

*Search Contact*

This a dhtmlx combo focused end point

	GET    /contact/dhtmlx/combo.xml

This is to be consumed by a DHTMLX combo only. Filtering need to be enabled.

	https://perltest.myadoptionportal.com/contact/dhtmlx/combo/feed.xml?pos=0&mask=cha

	https://perltest.myadoptionportal.com/contact/dhtmlx/combo/feed.xml?pos=20&mask=cha

pagination implemented on API layer, then it will have bad performance if compared with pagination on SP layer

Client side example:

        combo = new dhtmlXCombo("combo", "combo", 200);
        var combo_url = CAIRS.MAP.API.getMappedURL({
            resource: "/contact/dhtmlx/combo/feed",
            responseType: "xml"
        });
        combo.enableFilteringMode(true, combo_url, true, true);

this end point receives only two parameters:

    pos = for pagination support. automatically appended when using dhtmlx combo
    mask = string to search for. automatically appended when using dhtmlx combo

then you don't need to manually pass any parameter

Online example:

http://cdmap01.myadoptionportal.com/modules/CAIRS_Framework/examples/contact_dhtmlx_combo_end_point.html
