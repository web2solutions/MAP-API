# MAP-API

Descrition

	MAP API RESTFul psgi application

Language: Perl

Framework: Dancer

Application server: Centos 5.9

Database driver on Application server: DBD Sybase

Database Server: SQL Server


**What is RESTful?**

We could shortly describe it as AJAX on steroids. It defines standards for HTTP requests and responses but also implements advanced features in terms of communication between client and server.

>" Representational state transfer (REST) is an abstraction of the architecture of the World Wide Web; more precisely, REST is an architectural style consisting of a coordinated set of architectural constraints applied to components, connectors, and data elements, within a distributed hypermedia system. "

>" REST ignores the details of component implementation and protocol syntax in order to focus on the roles of components, the constraints upon their interaction with other components, and their interpretation of significant data elements. "

*source http://en.wikipedia.org/wiki/Representational_state_transfer*


**What is MAP API?**

The MAP API is a distributed server stack which provides a set of RESTful *end points*.

It runs on your box and process, it means it does not lives inside Apache.

The application stack looks like following:

	Perl psgi application (Dancer) -> Plack middleware -> Starman (private web server) -> Apache (public proxy server)

**What are RESTful end points?**

Each end points may looks like a web service.

End points provides standardized interface for consuming a service.

End points tries always to be generic solutions and provide support to be consumed by every type of client (ex: web, mobile)

MAP API end points are *CRUD focused end points*. It means that, *by default*, it provides support to Create, Read, Update and Delete operations on a specified dataset/table.

There are end points which provides specific support, like for example file upload, and others.

**API Branches**

		production: https://api.myadoptionportal.com
		
		dev: https://apidev.myadoptionportal.com
		
		test: https://perltest.myadoptionportal.com

**End points documentation**

	http://cdmap01.myadoptionportal.com/modules/API_DOC/

==================================

## Deploy


The Centos 5.9 OS uses the Perl 5.8 distribution, we will install a independently perl distribution and use it, then avoiding to use the official OS perl distribution.

In this way, we need to install perlbrew to be able to have and manage multiple Perl distributions installed on the server

note:

	The following tutorial is considering your are logged as root


## Environment deploy

install perlbrew

	$ curl -L http://xrl.us/perlbrewinstall | bash


Add content to .bashrc

 	$ echo "source ~/perl5/perlbrew/etc/bashrc" >> ~/.bashrc

run .bashrc

	$ . ~/.bashrc


install perl distro

   	$ perlbrew install perl-5.10.1

See log installation

	$ tail -f ~/perl5/perlbrew/build.log

Switch Perl version on terminal

	$ perlbrew switch perl-5.10.1





install cpan minus -> cpanm tool
	
	$   % curl -L http://cpanmin.us | perl - App::cpanminus


Install Dancer framework

	$ curl -L http://cpanmin.us | perl - --sudo Dancer

	OR

	$ cpanm Dancer
	
	OR, if you are facing issues when install, try:
	
	$ cpanm --force Dancer


Install Dancer RESTful plugin

	$ cpanm Dancer::Plugin::REST

Install sha256 crypt support

	$ cpanm Crypt::Digest::SHA256


install DBI

	$ cpanm DBI

install Encode

	$ cpanm Encode

install Data::Dump

	$ cpanm Data::Dump


install YAML suport

	$ cpanm YAML
	
install  Any::Moose

	$ cpanm Any::Moose
	
install Mouse

	$ cpanm Mouse

install AnyMQ

	$ cpanm --force AnyMQ


install Web::Hippie

	$ cpanm --force Web::Hippie
	
install MooseX Traits

	$ cpanm MooseX::Traits
	

install Twiggy

	$ cpanm Twiggy
	

install Twiggy  Plack Handler

	 $ cpanm --force Plack::Handler::Twiggy

install Starman

	$ cpanm Starman


install Server Starter

	$ cpanm Server::Starter
	
install Unix Uptime checker support

	$ cpanm Unix::Uptime

install Linux SysInfo support

	$ cpanm Linux::SysInfo


## Support SQL Server

- Complete doc	
	
	http://www.idevelopment.info/data/SQLServer/DBA_tips/Programming/PROG_4.shtml

goes to /tmp directory

	$ cd /tmp

download freetds

	$ wget http://mirrors.ibiblio.org/freetds/stable/freetds-stable.tgz
	
download DBD Sybase

	 $ wget http://search.cpan.org/CPAN/authors/id/M/ME/MEWP/DBD-Sybase-1.10.tar.gz
	 
Install freetds

	$ cd freetds-0.91/
	
	$ ./configure --with-tdsver=7.0 --prefix=/usr/local/freetds
	
	$ make install
	
	
Install DBD-Sybase
	
	$ export SYBASE=/usr/local/freetds
	
	$ export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/freetds/lib
	
	$ cd /tmp
	
	$ gunzip DBD-Sybase-1.10.tar.gz
	
	$ tar xvf DBD-Sybase-1.10.tar
	
	$ cd DBD-Sybase-1.10
	
	
	$ echo $SYBASE
	/usr/local/freetds
	
	$ echo $LD_LIBRARY_PATH
	:/usr/local/freetds/lib


	$ perl Makefile.PL
	
	By default DBD::Sybase 1.05 and later use the 'CHAINED' mode (where available)
	when 'AutoCommit' is turned off. Versions 1.04 and older instead managed
	the transactions explicitly with a 'BEGIN TRAN' before the first DML
	statement. Using the 'CHAINED' mode is preferable as it is the way that
	Sybase implements AutoCommit handling for both its ODBC and JDBC drivers.
	
	Use 'CHAINED' mode by default (Y/N) [Y]: Y
	
	Running in threaded mode - looking for _r libraries...
	
	***NOTE***
	There is an incompatibility between perl (5.8.x) built in threaded mode and
	Sybase's threaded libraries, which means that signals delivered to the perl
	process result in a segment violation.
	
	I suggest building DBD::Sybase with the normal libraries in this case to get
	reasonable behavior for signal handling.
	
	Use the threaded (lib..._r) libraries [N]: N
	
	OK - I'll use the normal libs
	
	Running in 64bit mode - looking for '64' libraries...
	BLK api NOT available.
	The DBD::Sybase module need access to a Sybase server to run the tests.
	To clear an entry please enter 'undef'
	Sybase server to use (default: SYBASE): 192.168.1.19
	User ID to log in to Sybase (default: sa): ESCairs
	Password (default: undef): FishB8
	
	Sybase database to use on 192.168.1.19 (default: undef): MAPTEST
	
	
	
	$ make
	
	$ su
	
	$ make install


# Working on DEV branch

## Client side

	Set you client side code to use the DEV branch address:
	
	CAIRS.environment = "dev"; // production, dev, test. Default: test


## Server Side	
	
	login on 192.168.1.41:22 via SSH using the root user

start API on 5000 HTTP port - requires VPN access

	$ cd /opt/MAP-API/
	
	$ start_server --port=5000 --pid-file=apidevenv_pid --status-file=apidevenv_status -- plackup -R /opt/MAP-API/lib/MAP -E deployment -s Twiggy bin/app.pl
	

<img src="https://raw.githubusercontent.com/web2solutions/MAP-API/master/docs/imgs/dev_branch_api_process_running_on_terminal.jpg?token=684249__eyJzY29wZSI6IlJhd0Jsb2I6d2ViMnNvbHV0aW9ucy9NQVAtQVBJL21hc3Rlci9kb2NzL2ltZ3MvZGV2X2JyYW5jaF9hcGlfcHJvY2Vzc19ydW5uaW5nX29uX3Rlcm1pbmFsLmpwZyIsImV4cGlyZXMiOjE0MTE0NDA3Njh9--d66b3419fbf52669d762612828a89e96be7655ef">
	

## Explaining parameters

	--port 
		define the HTTP port
	
	--pid-file=filename
		if set, writes the process id of the start_server process to the file

	--status-file=filename
		if set, writes the status of the server process(es) to the file
		
	plackup
		is the middleware application
		
	-R
		set middleware to reload application when it files change, like for example when you upload a new file.
	
	/opt/MAP-API/lib/MAP 
		is the aplication path
		
	-E deployment
		environment name. just a flag
		
	-s Twiggy
		set the HTTP server which the middleware will use to run your application
	
	bin/app.pl 
		path of the Dancer PSGI wrapper of the API
	

## API process management && Debug on run time

When you make any change on the application directory, for example upload file, delete files, rename files, the middleware application reads all the contents again and try to compile the code considering all new changes.

If is there any error, mey be a simple ";" missing, it will be not compiled and a error message will be displayed on the API process watcher that we are seeing on Bitivise Xterminal ( a ssh client )

I will issue on error on the process watcher by renaming a directory (lib/MAP/contact to lib/MAP/-contact) and display the print screen here:

<img src="https://raw.githubusercontent.com/web2solutions/MAP-API/master/docs/imgs/issuing_error.jpg?token=684249__eyJzY29wZSI6IlJhd0Jsb2I6d2ViMnNvbHV0aW9ucy9NQVAtQVBJL21hc3Rlci9kb2NzL2ltZ3MvaXNzdWluZ19lcnJvci5qcGciLCJleHBpcmVzIjoxNDExNDQxOTk2fQ%3D%3D--c4650ab8822e933ef406aa7a2af6ffe03cf82953">

Now, I will fix the directory name (renaming lib/MAP/-contact to lib/MAP/contact), and looks what happens on terminal:


<img src="https://raw.githubusercontent.com/web2solutions/MAP-API/master/docs/imgs/fixing_issuing_error.jpg?token=684249__eyJzY29wZSI6IlJhd0Jsb2I6d2ViMnNvbHV0aW9ucy9NQVAtQVBJL21hc3Rlci9kb2NzL2ltZ3MvZml4aW5nX2lzc3VpbmdfZXJyb3IuanBnIiwiZXhwaXJlcyI6MTQxMTQ0MjI5N30%3D--441eda06cc194be296b454a9102e6904e4940fe8">


	note 1: on dev branch, if server restarts, you need to start the API process manually again
	
	note 2: when you start the API process on terminal and closes the terminal, the API process stills alive.
	
	note 3: if the API process is running, AND, you need to watch middleware process on terminal,
	you need to kill the the existing API process and start the API again
	
	
Stoping currently API process
-------

lets list the process list and ports

	$ netstat -lnptu

Now, look the process list and look for the process which is using the tcp 5000 port

<img src="https://raw.githubusercontent.com/web2solutions/MAP-API/master/docs/imgs/netstat.jpg?token=684249__eyJzY29wZSI6IlJhd0Jsb2I6d2ViMnNvbHV0aW9ucy9NQVAtQVBJL21hc3Rlci9kb2NzL2ltZ3MvbmV0c3RhdC5qcGciLCJleHBpcmVzIjoxNDExNDQzMjQxfQ%3D%3D--4568f8f673e547689635739c19f91f38e898a04d">
	
	
	$ kill - 5628
	

Ensure the process was really killed and type again:

	$ netstat -lnptu
	
if is there any process running on 5000 port again, kill it

Start the api process again:

	$ start_server --port=5000 --pid-file=apidevenv_pid --status-file=apidevenv_status -- plackup -R /opt/MAP-API/lib/MAP -E deployment -s Twiggy bin/app.pl




DEV API branch - requires VPN access
-------

	start_server --restart --pid-file=apidevenv_pid --status-file=apidevenv_status 







## Implemented end points

=============================
###### Contact type End Point

*get contact types by passing IsBusiness*

	GET        /contact/types/all.json
	
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
