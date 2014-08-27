# MAP-API


MAP API RESTFul psgi application

Language: Perl
Framework: Dancer


## Environment deploy

Application server -> Centos 5.9

The Centos 5.9 OS uses the Perl 5.8 distribution, we will install standalone perl distributions and use it avoiding to use the OS perl distribution.


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
	
	#   % curl -L http://cpanmin.us | perl - App::cpanminus


Install Dancer framework

	curl -L http://cpanmin.us | perl - --sudo Dancer

	OR

	cpanm Dancer
	
	OR, if you are facing issues when install, try:
	
	cpanm --force Dancer


Install Dancer RESTful plugin

	cpanm Dancer::Plugin::REST

Install sha256 crypt support

	cpanm Crypt::Digest::SHA256


install DBI

	cpanm DBI

install Encode

	cpanm Encode

install Data::Dump

	cpanm Data::Dump



install Twiggy

	cpanm Twiggy

install Starman

	cpanm Starman


install Server Starter

	cpanm Server::Starter


Support SQL Server

	http://www.idevelopment.info/data/SQLServer/DBA_tips/Programming/PROG_4.shtml
