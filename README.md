# MAP-API

Descrition

	MAP API RESTFul psgi application

Language: Perl

Framework: Dancer

Application server: Centos 5.9

Database driver on Application server: DBD Sybase

Database Server: SQL Server


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

Client side

	Set you client side code to use the DEV branch address:
	
	CAIRS.MAP.API.apiURL = "http://192.168.1.41:5000"; -> it requires VPN access
	
	OR
	
	CAIRS.MAP.API.apiURL = "https://apidev.myadoptionportal.com"; -> We are waiting the Patrick help to create the A entry "apidev" on BIND dns server


Server Side	
	
	login on 192.168.1.41:22 via SSH using the root user

start API on 5000 HTTP port - requires VPN access

	$ cd /opt/MAP-API/
	
	$ start_server --port=5000 --pid-file=apidevenv_pid --status-file=apidevenv_status -- plackup -R /opt/MAP-API/lib/MAP -E deployment -s Starman bin/app.pl
	

<img src="https://raw.githubusercontent.com/web2solutions/MAP-API/master/docs/imgs/dev_branch_api_process_running_on_terminal.jpg?token=684249__eyJzY29wZSI6IlJhd0Jsb2I6d2ViMnNvbHV0aW9ucy9NQVAtQVBJL21hc3Rlci9kb2NzL2ltZ3MvZGV2X2JyYW5jaF9hcGlfcHJvY2Vzc19ydW5uaW5nX29uX3Rlcm1pbmFsLmpwZyIsImV4cGlyZXMiOjE0MTE0NDA3Njh9--d66b3419fbf52669d762612828a89e96be7655ef">
	

Explaining parameters

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
		
	-s Starman
		set the HTTP server which the middleware will use to run your application
	
	bin/app.pl 
		path of the Dancer PSGI wrapper of the API
	


restart DEV API branch - requires VPN access
	
	start_server --restart --pid-file=apidevenv_pid --status-file=apidevenv_status 
