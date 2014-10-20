# Implemented end points

=============================
###### Contact type End Point

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


=============================
###### Contact End Point


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

http://cdmap01.myadoptionportal.com/modules/CAIRS_Framework/contact_dhtmlx_combo_end_point.html
    

=============================

######  Set of End points for lkp tables

**lkp Countries end point**

	GET		/contact/lkp/countries.json
	GET		/contact/lkp/countries/0000.json
	POST		/contact/lkp/countries.json
	PUT		/contact/lkp/countries/0000.json
	DEL		/contact/lkp/countries/0000.json

*online example*: http://cdmap01.myadoptionportal.com/modules/CAIRS_Framework/lkpCountry.html


**lkp Address Province end point**

	GET		/contact/lkp/addressProvince.json
	GET		/contact/lkp/addressProvince/0000.json
	POST		/contact/lkp/addressProvince.json
	PUT		/contact/lkp/addressProvince/0000.json
	DEL		/contact/lkp/addressProvince/0000.json


*online example*: http://cdmap01.myadoptionportal.com/modules/CAIRS_Framework/lkpAddressProvince.html



**lkp Address Type end point**

	GET		/contact/lkp/addressType.json
	GET		/contact/lkp/addressType/0000.json
	POST		/contact/lkp/addressType.json
	PUT		/contact/lkp/addressType/0000.json
	DEL		/contact/lkp/addressType/0000.json

**online example**: http://cdmap01.myadoptionportal.com/modules/CAIRS_Framework/lkpAddressType.html



**lkp States end point**

	GET		/contact/lkp/states.json
	GET		/contact/lkp/states/0000.json
	POST		/contact/lkp/states.json
	PUT		/contact/lkp/states/0000.json
	DEL		/contact/lkp/states/0000.json

*online example*: http://cdmap01.myadoptionportal.com/modules/CAIRS_Framework/lkpState.html



**lkp Religions end point**

	GET		/contact/lkp/states.json
	GET		/contact/lkp/states/0000.json
	POST		/contact/lkp/states.json
	PUT		/contact/lkp/states/0000.json
	DEL		/contact/lkp/states/0000.json

*online example*: http://cdmap01.myadoptionportal.com/modules/CAIRS_Framework/lkpReligion.html


**lkp Nationalities end point**

	GET		/contact/lkp/nationalities.json
	GET		/contact/lkp/nationalities/0000.json
	POST		/contact/lkp/nationalities.json
	PUT		/contact/lkp/nationalities/0000.json
	DEL		/contact/lkp/nationalities/0000.json

*online example*: http://cdmap01.myadoptionportal.com/modules/CAIRS_Framework/lkpNationality.html



**lkp Languages end point**

	GET		/contact/lkp/languages.json
	GET		/contact/lkp/languages/0000.json
	POST		/contact/lkp/languages.json
	PUT		/contact/lkp/languages/0000.json
	DEL		/contact/lkp/languages/0000.json

*online example*: http://cdmap01.myadoptionportal.com/modules/CAIRS_Framework/lkpLanguage.html



**lkp Ethnicities end point**

	GET		/contact/lkp/ethnicities.json
	GET		/contact/lkp/ethnicities/0000.json
	POST		/contact/lkp/ethnicities.json
	PUT		/contact/lkp/ethnicities/0000.json
	DEL		/contact/lkp/ethnicities/0000.json

*online example*: http://cdmap01.myadoptionportal.com/modules/CAIRS_Framework/lkpEthnicity.html



**lkp Culture end point**

	GET		/contact/lkp/culture.json
	GET		/contact/lkp/culture/0000.json
	POST		/contact/lkp/culture.json
	PUT		/contact/lkp/culture/0000.json
	DEL		/contact/lkp/culture/0000.json

*online example*: http://cdmap01.myadoptionportal.com/modules/CAIRS_Framework/lkpCulture.html



**lkp Counties end point**

	GET		/contact/lkp/counties.json
	GET		/contact/lkp/counties/0000.json
	POST		/contact/lkp/counties.json
	PUT		/contact/lkp/counties/0000.json
	DEL		/contact/lkp/counties/0000.json

*online example*: http://cdmap01.myadoptionportal.com/modules/CAIRS_Framework/lkpCounty.html

**lkp Phone types**

	GET		/contact/phoneTypes.json
	GET		/contact/phoneTypes/0000.json
	POST		/contact/phoneTypes.json
	PUT		/contact/phoneTypes/0000.json
	DEL		/contact/phoneTypes/0000.json


**lkp Email types**

	GET		/contact/emailTypes.json
	GET		/contact/emailTypes/0000.json
	POST		/contact/emailTypes.json
	PUT		/contact/emailTypes/0000.json
	DEL		/contact/emailTypes/0000.json


**lkp Degrees**

	GET		/contact/degrees.json
	GET		/contact/degrees/0000.json
	POST		/contact/degrees.json
	PUT		/contact/degrees/0000.json
	DEL		/contact/degrees/0000.json



=============================

######  Relationship end points

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
