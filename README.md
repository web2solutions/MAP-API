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
		
**Deploy documentation**

https://github.com/web2solutions/MAP-API/tree/master/docs/deploy

**End points documentation**

https://github.com/web2solutions/MAP-API/tree/master/docs/end%20points

==================================

#