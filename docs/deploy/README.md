# Deploy


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


install Data Recursive Encode

	$ cpanm Data::Recursive::Encode

install deep encode

	$  cpanm Deep::Encode
	
install Template system

	$ cpanm Template

Install XML support

	$ cpanm XML::Mini::Document




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
