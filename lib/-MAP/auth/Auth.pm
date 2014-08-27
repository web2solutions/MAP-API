package MAP::auth::Auth;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use DBI;
use Crypt::Digest::SHA256 qw( sha256_hex );


our $VERSION = '0.1';


options '/auth.:format' => sub {
	MAP::API->options_header();
};

post '/auth.:format' => sub {

   
	my $auth_status = "disconnected";
	my $secret_status = "";
	my $token_status = "";
	my $username 	= params->{username} || MAP::API->fail( "username can not be empty" );
	my $Origin  	= request->header("Origin") || MAP::API->fail( "you can't fetch without a browser" );
	my $origin_status = "";
	my $user_id = 0;
	my $token = "";
	my $first_name = "";
	my $is_new_token = 0;
	my $date_creation = 0;
	my $date_expiration = 0;
	
	
	my $dbh = MAP::API->dbh();
	
	
	my $strSQLcheckOrigin = "SELECT origin FROM tbl_api_allowed_origin WHERE origin = ?";
	my $sth = $dbh->prepare( $strSQLcheckOrigin, );
	$sth->execute( $Origin ) or MAP::API->fail( $sth->errstr );
	while ( my $record = $sth->fetchrow_hashref()) 
	{
		$origin_status = "ok";
	}
	
	if ( $origin_status eq "" )
	{
		MAP::API->unauthorized($strSQLcheckOrigin);
	}
	

	my $strSQLsecret = 'SELECT * FROM tbl_api_secret WHERE username = ?';
	$sth = $dbh->prepare( $strSQLsecret, );
	$sth->execute( $username ) or MAP::API->fail( $sth->errstr );
	while ( my $record = $sth->fetchrow_hashref()) 
	{
		$secret_status = "ok";
		$user_id = $record->{"user_id"};
		$first_name = $record->{"first_name"};
	}
	
	if ( $secret_status eq "" )
	{
		MAP::API->unauthorized("invalid username");
	}
	
	my $strSQLtoken = 'SELECT * FROM tbl_api_access_token WHERE user_id = ? AND active_status = 1 AND date_expiration > '.( time * 1000 ).'';
	$sth = $dbh->prepare( $strSQLtoken, );
	$sth->execute( $user_id ) or MAP::API->fail( $sth->errstr );
	while ( my $record = $sth->fetchrow_hashref()) 
	{
		$token_status = "ok";
		$auth_status = "connected";
		$token = $record->{"token"};
		$date_creation = $record->{"date_creation"};
		$date_expiration = $record->{"date_expiration"};
	}
	
	my $strSQLcreateToken = '';
	
	
	if ( $token_status eq "" ) {
		
		
		$token = sha256_hex( $user_id . "_" . ( time * 1000 ));
		
		$strSQLcreateToken = 'INSERT INTO tbl_api_access_token( user_id, token, date_creation, date_expiration, active_status ) VALUES( ?, ?, ?, ?, 1);';
		$sth = $dbh->prepare( $strSQLcreateToken, );
		$date_creation = time * 1000;
		$date_expiration = $date_creation + 86400000;
		#debug $date_creation;
		#debug $date_expiration;
		$sth->execute( $user_id, $token, $date_creation, $date_expiration ) or MAP::API->fail( $sth->errstr );
		$is_new_token = 1;
		$auth_status = "connected";
		$token_status = "ok";
		
	}
	
	
	
	
	
	MAP::API->normal_header();
	
	if ( $auth_status ne 'connected') {
		MAP::API->unauthorized();
	}
	else
	{
		my $auth_data = {
			first_name =>	$first_name,
			username => $username,
			token => $token,
			date_expiration => $date_expiration,
			auth_status => $auth_status,
			origin => $Origin
		};		
	
		return {
			status => 'success', response => 'authorized', auth_data => $auth_data, strSQLsecret => $strSQLsecret
			, strSQLtoken => $strSQLtoken, strSQLcreateToken => $strSQLcreateToken, strSQLcheckOrigin => $strSQLcheckOrigin
			,is_new_token => $is_new_token
		};
	}
	
	
	
};

dance;
