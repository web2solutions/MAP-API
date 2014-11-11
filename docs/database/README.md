# Database


## SQL SERVER 

Agency database - used for storing API configurations


## PostgreSQL 

used for storing access logs

	DB name: cairsapi
	user: cairsapi
	password: FishB8
	
	Server version: 9.4
	
### SETUP

http://yum.pgrpms.org/reporpms/

http://opensourcedbms.com/dbms/installing-postgresql-9-2-on-cent-os-6-3-redhat-el6-fedora/


	CREATE role cairsapi LOGIN PASSWORD ‘FishB8’ SUPERUSER;
	
	host    all             all             0.0.0.0/0            md5
