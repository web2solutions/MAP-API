package MAP::API;
use Dancer ':syntax';
use Template;

use MAP::auth::Auth;

use MAP::dataStores::ClientListing;
use MAP::MASTERDATA::RELIGIONS;
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


## in test
#use MAP::Clients;
use MAP::LoadingAverage;
#use MAP::Socket;

use MIME::Base64;



our $VERSION = '0.1';

set 'session'     => 'Simple';

set logger => 'console';

set 'log'         => 'debug';
set 'show_errors' => 1;
set 'access_log ' => 1;
set 'warnings'    => 0;
#set 'template'    => 'template_toolkit';


sub options_header{
	header('Access-Control-Allow-Origin' => request->header("Origin"));
	#header('Access-Control-Allow-Credentials' => 'true');
	header('Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS');
	header('Access-Control-Allow-Headers' => request->header("Access-Control-Request-Headers"));
	header('Access-Control-Max-Age' => 1728000);


	header('Vary' => 'Accept-Encoding');
	header('Keep-Alive' => 'timeout=2, max=100');
	header('Connection' => 'Keep-Alive');
	header('X-Server' => 'Twiggy');
	header('X-Server-Time' => time);

##Access-Control-Allow-Credentials: true

}


sub normal_header{
	header('Access-Control-Allow-Origin' => request->header("Origin"));
	header('Access-Control-Max-Age' => 1728000);
	#header('Access-Control-Allow-Credentials' => 'true');
	header('Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS');
	header('Keep-Alive' => 'timeout=2, max=100');
	header('Connection' => 'Keep-Alive');
	header('Cache-Control' => 'max-age=0, must-revalidate, no-cache, no-store');
	header('Vary' => 'Accept');
	header('X-Server-Time' => time);
	header('X-Server' => 'Twiggy');
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

sub dbh{
	my $database = request->header("X-db") ? MIME::Base64::decode(request->header("X-db")) : "";#request->header("X-db") || "";
	my $server = '192.168.1.19';
	my $os = MIME::Base64::decode(request->header("X-os")) || "linux";
	#debug $os;
	my $dbh;
	
	if ( $os eq "linux") {
		$ENV{DSQUERY} = '192.168.1.19';
		$dbh = DBI->connect('DBI:Sybase:database='.$database.';scriptName=MAP_API;', "ESCairs", "FishB8", {
				PrintError => 0#,
				#syb_enable_utf8 => 1
		}) or return "Can't connect to sql server: $DBI::errstr";
		
		#$dbh->{syb_enable_utf8} = 1 ;
		$dbh->do('use '. $database);
	}
	else
	{
		$dbh = DBI->connect("DBI:ODBC:Driver={SQL Server};Server=$server;Database=$database;UID=ESCairs;PWD=FishB8")  or return "Can't connect to sql server: $DBI::errstr";
	}
	return $dbh;
}


sub fail{
	my($self, $err_msg) = @_;

	normal_header();
	
	halt({
		status => 'err', response =>  $err_msg
	});
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
	my($self, $token, $Origin) = @_;

	my $auth = request->env->{HTTP_AUTHORIZATION} || MAP::API->unauthorized("malformed headers");
	$auth =~ s/Digest //gi;

	$token = MIME::Base64::decode( $auth );
	
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
	my $res = $dbh->selectrow_arrayref(shift,undef,@_);
	die"Can't execute select:\n".$dbh->errstr if $dbh->err;
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

dance;
