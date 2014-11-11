use MAPTEST; 


IF OBJECT_ID('dbo.tbl_api_access_token', 'U') IS NOT NULL
          DROP TABLE dbo.tbl_api_access_token;
CREATE TABLE dbo.tbl_api_access_token( 
        api_access_token_id INT not null Identity(1,1),
        user_id integer NOT NULL,
        token  varchar(max),
        date_creation bigint, -- I want epoch time here (seconds)
        date_expiration bigint, -- I want epoch time here (seconds) -- default today + 1 day
        active_status integer NOT NULL default 0,
        CONSTRAINT tbl_api_access_token_pkey PRIMARY KEY (api_access_token_id)
);


IF OBJECT_ID('dbo.tbl_api_allowed_origin', 'U') IS NOT NULL
          DROP TABLE dbo.tbl_api_allowed_origin;
CREATE TABLE dbo.tbl_api_allowed_origin( 
        api_allowed_origin_id INT not null Identity(1,1),
        origin  varchar(max),
        CONSTRAINT tbl_api_allowed_origin_pkey PRIMARY KEY (api_allowed_origin_id)
);




 -- hosts allowed to fecth content from API
insert into tbl_api_allowed_origin(origin) values('http://cdmap01.myadoptionportal.com');
insert into tbl_api_allowed_origin(origin) values('https://cdmap01.myadoptionportal.com');
insert into tbl_api_allowed_origin(origin) values('http://cdmap03.myadoptionportal.com');
insert into tbl_api_allowed_origin(origin) values('https://cdmap03.myadoptionportal.com');
--insert into tbl_api_allowed_origin(origin) values('http://www.myadoptionportal.com');
--insert into tbl_api_allowed_origin(origin) values('https://www.myadoptionportal.com');
--insert into tbl_api_allowed_origin(origin) values('http://aai.myadoptionportal.com');
--insert into tbl_api_allowed_origin(origin) values('https://aai.myadoptionportal.com');

----- END






IF OBJECT_ID('dbo.tbl_api_endpoints', 'U') IS NOT NULL
          DROP TABLE dbo.tbl_api_endpoints;
CREATE TABLE dbo.tbl_api_endpoints( 
        endpoint_id INT not null Identity(1,1),
        [prefix] varchar(max) default 'undef',
	[collection] varchar(255) NOT NULL,
	[table] varchar(255) NOT NULL,
	[primary_key] varchar(255) NOT NULL,
	[columns] varchar(max) NOT NULL,
	relational_column varchar(255),
	is_specific_code integer default 0,
        CONSTRAINT tbl_api_endpoints_pkey PRIMARY KEY (endpoint_id)
);


IF OBJECT_ID('dbo.tbl_api_servers', 'U') IS NOT NULL
          DROP TABLE dbo.tbl_api_servers;
CREATE TABLE dbo.tbl_api_servers( 
        server_id INT not null Identity(1,1),
        server_name varchar(255),

        CONSTRAINT tbl_api_servers_pkey PRIMARY KEY (server_id)
);


IF OBJECT_ID('dbo.tbl_api_servers_settings', 'U') IS NOT NULL
          DROP TABLE dbo.tbl_api_servers_settings;
CREATE TABLE dbo.tbl_api_servers_settings( 
        server_settings_id INT not null Identity(1,1),
        server_id INT not null,
        server_ip varchar(255),
        server_host varchar(255),
        server_user varchar(255),
        server_password varchar(255),
	branch_type varchar(255), -- test, live
        CONSTRAINT tbl_api_servers_settings_pkey PRIMARY KEY (server_id)
);
