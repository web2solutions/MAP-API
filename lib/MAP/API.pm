package MAP::API;
use Dancer qw(:syntax :moose);
use Dancer::App;
use Template;
use MIME::Base64;
use Data::Dump qw(dump);

our $VERSION = '0.1';

my $branch = 'test'; # default test
#my $apiURL = "https://api.myadoptionportal.com";
#my $apiURLdev = "https://apidev.myadoptionportal.com";
#my $apiURLtest = "https://perltest.myadoptionportal.com";


#set envdir => '/path/to/environments'

#set 'session'     => 'Simple';

set logger => 'console';
#logger_format: %h %m %{%H:%M}t [%{accept_type}h]
setting log_path => '/opt/MAP-API/public/logs';

set 'log'         => 'debug';
set 'show_errors' => 1;
set 'warnings'    => 0;
#set 'template'    => 'template_toolkit';


use MAP::auth::Auth;

use MAP::dataStores::ClientListing;
use MAP::LibraryFields::Fields;
use MAP::LibraryFields::Category;
use MAP::LibraryFields::SubCategory;
use MAP::LibraryFields::Options;
use MAP::LibraryFields::Groups;
use MAP::LibraryFields::Tags;
use MAP::Forms::Forms;
use MAP::EmailMessages::EmailMessages;
use MAP::Agency::Agency;
use MAP::DHTMLX;
use MAP::Agencies::Agencies;
use MAP::contact::Contact;
use MAP::address::ZipSearch;
use MAP::Users;
use MAP::messages::Messages;

use MAP::Payments;

use MAP::gridMaker;



hook after => sub {
		my $response = shift;

		if ( request->method() ne 'OPTIONS' ) {
				if ( request->request_uri() ne '/logs' && request->request_uri() ne '/getloadavg' && request->request_uri() ne '/getfreeram' && request->request_uri() ne '/freeram' && request->request_uri() ne '/'  ) {

						my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
						my $branch = Dancer::request->header("X-branch") || 'test';
						my $template = '';

						my $client_ip = Dancer::request->header("X-Forwarded-For") || Dancer::request->header("REMOTE_ADDR"); # client IP
						my $client_vendor = ( request->header("X-Requested-With")  ? request->header("X-Requested-With") . ''  : 'unknown' . '' );
						my $client_user_agent = request->header("User-Agent") || 'unknown';

						my $browser_name = Dancer::request->header("X-browser-name") || 'unknown';
						my $browser_os = Dancer::request->header("X-browser-os") || 'unknown';
						my $browser_version = Dancer::request->header("X-browser-version") || 'unknown';

						my $screen_width = Dancer::request->header("X-browser-screen-width") || 'unknown';
						my $screen_height = Dancer::request->header("X-browser-screen-height") || 'unknown';

						my $rdate = ( $year + 1900 ). '-' . ( $mon + 1 ) . '-' . $mday;
						my $rtime = $hour . ':' . $min . ':' . $sec;

						my $host = Dancer::request->header("X-Forwarded-Host") || Dancer::request->header("Host");
						my $origin = Dancer::request->header("Origin") || 'unknown';
						my $referer = Dancer::request->header("Referer") || 'unknown';

						my $agency_id = Dancer::request->header("X-AId") || 0;

						my $token = request->env->{HTTP_AUTHORIZATION} || 'not authorized';

						my $client_session_id = Dancer::request->header("X-client-session-id") || 0;

						my $agency_database = '';
						#debug 'xxxxxxxxxxxxxxxxxx';
						#debug Dancer::request->header("X-db");
						if ( defined Dancer::request->header("X-db")  )
						{
								$agency_database = MIME::Base64::decode( Dancer::request->header("X-db") );
						}


						my $json_document = to_json({
								request_date => $rdate,
								request_time => $rtime,
								client_session_id => $client_session_id,
								branch =>  $branch,
								api_host => $host,
								origin_domain => $origin,
								referer => $referer,
								agency_id => $agency_id,
								agency_database => $agency_database,
								token => $token,
								client_ip => $client_ip,
								client_vendor => $client_vendor,
								client_user_agent => $client_user_agent,
								'browser_name' => $browser_name,
								'browser_os' => $browser_os,
								'browser_version' => $browser_version,
								'screen_width' => $screen_width,
								'screen_height' => $screen_height,
								request_method => request->method(),
								request_url => request->request_uri(),
								response_status => $response->status,
								response_type => $response->content_type

						});

						#debug dump($json_document);

						my $dbh = MAP::API->dbh_pg();

						my $strSQL = 'INSERT INTO access_log( jdoc )
								VALUES ( ? )
								RETURNING access_log_id;
						';
						my $sth = $dbh->prepare( $strSQL );
						$sth->execute( $json_document ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQL );
						#debug request->request_uri();
				}
				#my $r = Dancer::App->current->registry->routes;
				#foreach my $g (@{$r->{get}}) {
				#	debug "[+] Registered route: '$g->{pattern}'";
				#};
				#debug dump( Dancer::App->current->registry->routes );

				#use Dancer::Session;
				#debug dump( Dancer::Session->get_current_session()->{id} );
		}

};




sub set_branch{
		my $selected_branch = shift;
		$branch = $selected_branch;
};

sub get_branch{
		return $branch;
};



sub options_header{
	header('Access-Control-Allow-Origin' => request->header("Origin"));
	#header('Access-Control-Allow-Credentials' => 'true');
	header('Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS');
	header('Access-Control-Allow-Headers' => request->header("Access-Control-Request-Headers"));
	header('Access-Control-Max-Age' => 1728000);
	header('Vary' => 'Accept-Encoding');
	header('Keep-Alive' => 'timeout=2, max=100');
	header('Connection' => 'Keep-Alive');
	header('X-Server' => (config->{environment} eq 'development' ? 'Twiggy' : 'Starman' ));
	header('X-Server-Time' => time);
##Access-Control-Allow-Credentials: true

}


sub normal_header{
	header('Access-Control-Allow-Origin' => request->header("Origin"));
	header('Access-Control-Max-Age' => 1728000);
	#header('Access-Control-Allow-Credentials' => 'true');
	header('Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS');
	header('Access-Control-Allow-Headers' => request->header("Access-Control-Request-Headers"));
	header('Access-Control-Max-Age' => 1728000);
	#header('Keep-Alive' => 'timeout=2, max=100');
	header('Connection' => 'close');
	#header('Cache-Control' => 'max-age=0, must-revalidate, no-cache, no-store');
	header('Vary' => 'Accept');
	header('X-Server-Time' => time);
	header('X-Server' => (config->{environment} eq 'development' ? 'Twiggy' : 'Starman' ));
	header('Expires' => 'Thu, 01 Jan 1970 00:00:00');
	header('X-FRAME-OPTIONS' => 'DENY');
	header('X-XSS-Protection' => '1; mode=block');
	header('X-Content-Type-Options' => 'nosniff');


	if ( defined(params->{format}) ) {
		if ( params->{format} eq "json" ) {
			set serializer => 'JSON';
		}
		elsif ( params->{format} eq "xml" ) {
			set serializer => 'XML';
		}
		elsif ( params->{format} eq "yaml" ) {
			set serializer => 'YAML';
		}
		else
		{
			set serializer => 'JSON';
		}
	}
	else
	{
		set serializer => 'JSON';
	}
}

sub dbh_pg{
    #debug config->{x_db_server};
    my $dbh = DBI->connect("DBI:Pg:dbname=cairsapi;host=".(config->{environment} eq 'production' ? '192.168.1.34' : '192.168.1.33' ).";port=5432;", "cairsapi", "FishB8",  {'RaiseError' => 1}) ||  MAP::API->fail( 'pgsql error ' .   $DBI::errstr );
	return $dbh;
}

my $dbh = undef;

sub dbh{
	my $database = 'MAPTEST';#request->header("X-db") ? MIME::Base64::decode(request->header("X-db")) : "";#request->header("X-db") || "";
    my $server = '192.168.1.19';
    my $agency_id = request->header("X-AId") ? request->header("X-AId") : ( params->{agency_id} ? params->{agency_id} : -1 );
	my $os = request->header("X-os") ? MIME::Base64::decode( request->header("X-os") ) : "linux";

    if ( $os eq "linux") {
		$ENV{DSQUERY} = $server;
		$dbh = DBI->connect('DBI:Sybase:database=IRRISCentral;scriptName=MAP_API;', "ESCairs", "FishB8", {
				RaiseError => 0
		}) or  MAP::API->fail("Can't connect to sql server: $DBI::errstr");
		$dbh->do('use IRRISCentral');

		my $strSQL = "SELECT MAPDBName FROM dbo.lutPrimaryAgency WHERE map_agency_id = ?";
		my $sth = $dbh->prepare( $strSQL, );
		$sth->execute( $agency_id ) or MAP::API->fail( $sth->errstr );
		while ( my $record = $sth->fetchrow_hashref())
		{
			$database = $record->{MAPDBName};
		}
		$dbh->disconnect;

		$dbh = DBI->connect('DBI:Sybase:database='.$database.';scriptName=MAP_API;', "ESCairs", "FishB8", {
				RaiseError => 0
		}) or  MAP::API->fail("Can't connect to sql server: $DBI::errstr");
		$dbh->do('use '. $database);
	}
	else
	{
		$dbh = DBI->connect("DBI:ODBC:Driver={SQL Server};Server=$server;Database=IRRISCentral;UID=ESCairs;PWD=FishB8")  or return "Can't connect to sql server: $DBI::errstr";
		my $strSQL = "SELECT MAPDBName FROM dbo.lutPrimaryAgency WHERE map_agency_id = ?";
		my $sth = $dbh->prepare( $strSQL, );
		$sth->execute( $agency_id ) or MAP::API->fail( $sth->errstr );
		while ( my $record = $sth->fetchrow_hashref())
		{
			$database = $record->{MAPDBName};
		}
		$dbh->disconnect;

		$dbh = DBI->connect("DBI:ODBC:Driver={SQL Server};Server=$server;Database=$database;UID=ESCairs;PWD=FishB8")  or return "Can't connect to sql server: $DBI::errstr";
	}
	#debug $agency_id;
    #debug $database;
	return $dbh;
}

sub disconnect{
		$dbh->disconnect  or MAP::API->fail($dbh->errstr);
}
sub fail{
	my($self, $err_msg) = @_;
    my $wcontent = to_json({
			status => 'err', response =>  'Server error: '. $err_msg
	});
    #debug $err_msg;
	halt(Dancer::Response->new(
		status =>500,
		content => $wcontent,
		headers => [
			'Content-Type' => 'application/json',
			'Content-Length' => length($wcontent),
			'Access-Control-Allow-Origin' => request->header("Origin")
		]
	));
}


sub unauthorized{
	my($self, $err_msg) = @_;
	my $wcontent = to_json({
			status => 'err', response =>  'Unauthorized: '. $err_msg
	});
	halt(Dancer::Response->new(
		status => 401,
		content => $wcontent,
		headers => [
			'Content-Type' => 'application/json',
			'Content-Length' => length($wcontent),
			'WWW-Authenticate' => 'Basic realm="'.$err_msg.'"',
			'Access-Control-Allow-Origin' => request->header("Origin")
		]
	));
}

sub check_authorization{
	my($self) = @_;


	my $auth = request->env->{HTTP_AUTHORIZATION} || MAP::API->unauthorized("malformed headers");
	$auth =~ s/Digest //gi;

	my $token = MIME::Base64::decode( $auth );
    my $Origin = request->header("Origin");

    my $dbh = dbh();

	my $token_status = "";
	$Origin = $Origin || MAP::API->unauthorized( "Please use MAP RESTFul client" );
	$token = $token || MAP::API->unauthorized( "token can not be empty" );
	my $origin_status = "";

	my $strSQLcheckOrigin = "SELECT origin FROM tbl_api_allowed_origin WHERE origin = ?";
	my $sth = $dbh->prepare( $strSQLcheckOrigin, );
	$sth->execute( $Origin ) or MAP::API->fail( $sth->errstr );
	while ( my $record = $sth->fetchrow_hashref())
	{
		$origin_status = "ok";
	}

	if ( $origin_status eq "" )
	{
		MAP::API->unauthorized("Origin not allowed");
	}

	my $strSQLtoken = 'SELECT * FROM tbl_api_access_token WHERE token = ? AND active_status = 1 AND date_expiration > '.time.'';
	$sth = $dbh->prepare( $strSQLtoken, );
	$sth->execute( $token ) or MAP::API->fail( $sth->errstr );
	while ( my $record = $sth->fetchrow_hashref())
	{
		$token_status = "ok";
	}


	if ( $token_status eq "" ) {
		MAP::API->unauthorized("token not authorized");
	}
}

sub check_authorization_simple{
	my($self, $token, $Origin) = @_;

	my $dbh = dbh();

	my $token_status = "";
	$Origin = $Origin || MAP::API->unauthorized( "Please use MAP RESTFul client" );
	$token = $token || MAP::API->unauthorized( "token can not be empty" );
	my $origin_status = "";

	my $strSQLcheckOrigin = "SELECT origin FROM tbl_api_allowed_origin WHERE origin = ?";
	my $sth = $dbh->prepare( $strSQLcheckOrigin, );
	$sth->execute( $Origin ) or MAP::API->fail( $sth->errstr );
	while ( my $record = $sth->fetchrow_hashref())
	{
		$origin_status = "ok";
	}

	if ( $origin_status eq "" )
	{
		MAP::API->unauthorized("Origin not allowed");
	}

	my $strSQLtoken = 'SELECT * FROM tbl_api_access_token WHERE token = ? AND active_status = 1 AND date_expiration > '.time.'';
	$sth = $dbh->prepare( $strSQLtoken, );
	$sth->execute( $token ) or MAP::API->fail( $sth->errstr );
	while ( my $record = $sth->fetchrow_hashref())
	{
		$token_status = "ok";
	}


	if ( $token_status eq "" ) {
		MAP::API->unauthorized("token not authorized");
	}
}


sub get_table_MS_schema{
	my($self, $table) = @_;

	my $dbh = dbh();
	my $schema = {};

    my @columns;
	$table = $table || MAP::API->fail( "please provide a table name" );

	my $strSQL = "select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME=? ORDER BY ORDINAL_POSITION";
	my $sth = $dbh->prepare( $strSQL, );
	$sth->execute( $table ) or MAP::API->fail( $sth->errstr );
	while ( my $record = $sth->fetchrow_hashref())
	{
		my $type = '';
		if( $record->{ORDINAL_POSITION} == 1 )
		{
				$type = 'primary_key';
				$schema->{primary_key} = $record->{COLUMN_NAME};
		}else
		{
				$type = $record->{DATA_TYPE};
		}
		my $column = {
				name => $record->{COLUMN_NAME},
				type => $type,
				maxlenght => $record->{CHARACTER_MAXIMUM_LENGTH},
				position => $record->{ORDINAL_POSITION}
		};
		push @columns, $column;
	}

    $schema->{columns} = [@columns];

	#debug $schema->{primary_key};

	return $schema;
}


sub normalizeColumnNames
{

	my($self, $strColumns, $packageColumns) = @_;
	my @columns = split(/,/, $strColumns);
	$strColumns = '';
	for(@columns)
	{
		if ( index($packageColumns, '['.$_.']') != -1 )
		{

		}
		elsif ( index($packageColumns, $_) != -1 )
		{
			$strColumns = $strColumns . '['.$_.'],';
		}
	}
	return substr($strColumns, 0, -1);;
}

sub Exec
{
	my $self = shift;

	my $dbh = dbh();
	$dbh->do(shift,undef,@_) || die"Can't exec:\n".$dbh->errstr;
}

sub SelectOne
{
	my $self = shift;

	my $dbh = dbh();
	my $sql = shift;
	my $res = $dbh->selectrow_arrayref($sql,undef,@_);
	die"Can't execute select:\n".$dbh->errstr . '    -   '. $sql if $dbh->err;
	return $res->[0];
}

sub SelectRow
{
	my $self = shift;

	my $dbh = dbh();
	my $res = $dbh->selectrow_hashref(shift,undef,@_);
	die"Can't execute select:\n".$dbh->errstr if $dbh->err;
	return $res;
}

sub Select
{
	my $dbh = dbh();
	my $res = $dbh->selectall_arrayref( shift, { Slice=>{} }, @_ );
	die"Can't execute select:\n".$dbh->errstr if $dbh->err;
	return undef if $#$res == -1;
	my $cidxor = 0;
	for(@$res)
	{
		$cidxor = $cidxor ^ 1;
		$_->{row_cid} = $cidxor;
	}
	return $res;
}

sub SelectARef
{
	my $self = shift;

	my $data = Select(@_);
	return [] unless $data;
	return [$data] unless ref($data) eq 'ARRAY';
	return $data;
}

sub regex_alnum
{
	my ($self, $value) = @_;

	$value =~ s/ /_/g;
	$value =~ s/\W//g;
	return $value;
}

prefix undef;

options '/github_hooks.:format' => sub {
	MAP::API->options_header();
};
# routing OPTIONS header

post '/github_hooks.:format' => sub {

				MAP::API->normal_header();

				use Mail::SendEasy;

				my $event = request->header('X-Github-Event');
				my $signature = request->header('X-Hub-Signature');
				my $delivery_id = request->header('X-Github-Delivery');

				my $jsonpayload = request->body || 'my body';
				my $payload =  from_json( $jsonpayload );

				my $repo = $payload->{repository}->{name};


				my $person = '';

		my $message = '
				Hello, this is an automated event notice\'s about the '.$repo.' repository. <br><br>

				Please don\'t respond this message. <br><br>

				<b>Event type:</b><br>
				'. $event . '<br><br>
		';

		#head_commit


		if ( $event eq 'push' ) {
				$message = $message .'


								'. $payload->{head_commit}->{author}->{name} . ' did <b>' .$event.'</b> at <b>'.$repo.'</b> repository.<br><br>

								<b>Commit\'s message:</b><br>
								'. $payload->{head_commit}->{message} . '<br><br>

								<b>Commit\'s date:</b><br>
								'. $payload->{head_commit}->{timestamp} . '<br><br>

								<b>Commit\'s detail:</b><br>
								<a href="'. $payload->{head_commit}->{url} . '">'. $payload->{head_commit}->{url} . '</a><br><br>

								<b>Commiter\'s detail:</b><br>
								<a href="https://github.com/'. $payload->{head_commit}->{author}->{username} . '/">'. $payload->{head_commit}->{author}->{name} . '</a><br><br>

				';

				$person = $payload->{head_commit}->{author}->{name};
		}
		else
		{
				$person = $payload->{sender}->{login};

		}


		$message = $message . '
				<b>Repository\'s description:</b><br>
				'. $payload->{repository}->{description} . '<br><br>

				<b>Repository\'s Link:</b><br>
				<a href="'. $payload->{repository}->{html_url} . '">'. $payload->{repository}->{html_url} . '</a><br><br>

				<b>Sender\'s information:</b><br>
				<a href="'. $payload->{sender}->{html_url} . '"><img width="100" height="100" border="0" src="'. $payload->{sender}->{avatar_url} . '" /></a><br><br>


				<br>Best regards<br>
				---------------------------------<br>
				CAIRS\' software engineering team<br><br>

		';


		my @target = (
				'eduardo.llmeida@cairsolutions.com',
				'mark.livings@cairsolutions.com',
				'rene.sankar@mediaus.com',
				'aravind.buddha@mediaus.com',
				'nivya.rajeev@mediaus.com',
				'vince.rossignol@cairsolutions.com',
				'joseph.abraham@mediaus.com',
				'jenson@mediaus.com'
		);

		my $mail = new Mail::SendEasy(
			smtp => 'smtp.web2solutions.com.br',
			user => 'eduardo@web2solutions.com.br',
			pass => 'fuzzy24k',
			port => '587'
		);
		my $status = $mail->send(
			from    => 'eduardo@web2solutions.com.br',
			from_title => 'CAIRS\' GitHub Hooker',
			reply   => 'eduardo@web2solutions.com.br' ,
			error   => 'eduardo@web2solutions.com.br' ,
			to      => 'eduardo@web2solutions.com.br' ,
			cc => join('; ', @target),
			subject => $person . ' ' .$event.'ed at '.$repo.' repository' ,
			msg     => "" ,
			html    => $message,
		);
		if (!$status)
		{

				return {
						status => 'err',
						response => $mail->error,
				};
		}else
		{

				return {
						status => 'success',
						response => 'sent',
				};
		}
};

options qr{.*} => sub {
		MAP::API->options_header();
};

any qr{.*} => sub {
		my $wcontent = to_json({
			status => 'err', response =>  'end point not found'
		});
		halt(Dancer::Response->new(
		status => 404,
		content => $wcontent,
		headers => [
			'Content-Type' => 'application/json',
			'Content-Length' => length($wcontent),
			'Access-Control-Allow-Origin' => request->header("Origin")
		]
	));
};

dance;
