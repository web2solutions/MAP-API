package MAP::auth::Auth;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Crypt::Digest::SHA256 qw( sha256_hex );
use MIME::Base64;
use Data::Dump qw(dump);

our $VERSION = '0.1';


options '/auth.:format' => sub {
	MAP::API->options_header();
};

post '/auth.:format' => sub {

	my $auth = request->env->{HTTP_AUTHORIZATION} || MAP::API->unauthorized("malformed headers");
	$auth =~ s/Basic //gi;

	my $ip = request->address();
	my $host = request->remote_host();
	#debug $ip;
	#debug Dancer::request->header("X-Forwarded-For"); # client IP
	#debug Dancer::request->header("X-Forwarded-Host");
	#debug Dancer::request->header("X-Forwarded-Server");

	$auth = MIME::Base64::decode($auth) || &MAP::API->unauthorized("unable decode secret");


  my ($salt_api_user, $salt_api_secret) = split(/:/, ($auth || ":"));
	my $private_key  = request->header("User-Agent") || MAP::API->unauthorized("malformed headers");
	my $user = MIME::Base64::decode( $salt_api_user ) || &MAP::API->unauthorized("unable decode salt_api_user");
	#my @aUser = split(''.$private_key.'_', $userbase64);
	#my $user = $aUser[1];

#debug

	my $auth_status = "disconnected";
	my $secret_status = "";
	my $token_status = "";

	my $username 	=  $user || &MAP::API->unauthorized("invalid username");
	my $Origin  	= request->header("Origin") || MAP::API->unauthorized("malformed headers");
	my $origin_status = "";

	my $token = "";
	my $first_name = "";
	my $last_name = "";
	my $title = "";
	my $is_new_token = 0;
	my $date_creation = 0;
	my $date_expiration = 0;

  my $user_id = 0;
	my $user_type = undef;
	my $connID = undef;
	my $contact_id = undef;

	my @applicants;
	my $app2 = {};


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
		MAP::API->unauthorized('origin not allowed');
	}


	my $strSQLsecret = 'SELECT * FROM user_accounts WHERE username = ?';
	$sth = $dbh->prepare( $strSQLsecret, );
	$sth->execute( $username ) or MAP::API->fail( $sth->errstr );
	while ( my $record = $sth->fetchrow_hashref())
	{
		$secret_status = "ok";





		my $user_salt_pass = sha256_hex( $private_key . '_' . $record->{"password"} );
		if ( $user_salt_pass ne $salt_api_secret) {
			MAP::API->unauthorized("invalid password")
		}

		if ( $record->{"status"} ne 'Active') {
			MAP::API->unauthorized($record->{"status"} . " user")
		}


		$user_id = $record->{"user_id"};
		$first_name = $record->{"first_name"};
		$last_name = $record->{"last_name"};
		$title = $record->{"title"};

		$user_type = $record->{"user_type"};

		$connID = $record->{"ConnId"};

		debug $connID;

		$contact_id = MAP::API->SelectOne(' select dbo.udf_CoupleContactId('.$connID.', 1)');

		debug ' select dbo.udf_CoupleContactId('.$connID.', 1)';

		debug $contact_id;

		if ( $user_type eq 'adoptive_parent' ) {

				my $connID_app2 = MAP::API->SelectOne('SELECT dbo.udf_CoupleConnId('.$connID.', 2)');
				if ( defined($connID_app2) ) {
						$app2->{'connid'} = $connID_app2;
						$app2->{'contact_id'} = MAP::API->SelectOne(' select dbo.udf_CoupleContactId('.$connID_app2.', 2)');
						$app2->{'user_type'} = 'adoptive_parent';
						$app2->{'spouse_first_name'} = $record->{"spouse_first_name"};
						$app2->{'spouse_last_name'} = $record->{"spouse_last_name"};

				}
		}
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
		#my $reverse_username = reverse $username;


		# types: adoptive_parent are clients
		# types: agency_user,agency,admin are all caseowrker types
		# if connid is on the table, then it is app1


		# get connid of app 2 dbo.udf_CoupleConnId(ua1.ConnId, 2)



		# [3/25/15, 3:22:48 PM] Vince Rossignol: select dbo.udf_CoupleContactId(ua1.ConnId, 1)
		# [3/25/15, 3:22:57 PM] Vince Rossignol: dbo.udf_CoupleContactId(ua1.ConnId, 2)

		my $auth_data = {
			first_name =>	$first_name,
			last_name =>	$last_name,
			username => $username,
			token => $token,
			date_expiration => $date_expiration,
			auth_status => $auth_status,
			origin => $Origin,
			client_session_id => $user_id,
			user_id => $user_id,
			user_type => $user_type,
			connID => $connID,
			contact_id => $contact_id,
			app2 => $app2
		};

		return {
			status => 'success', response => 'authorized', auth_data => $auth_data, strSQLsecret => $strSQLsecret
			, strSQLtoken => $strSQLtoken, strSQLcreateToken => $strSQLcreateToken, strSQLcheckOrigin => $strSQLcheckOrigin
			,is_new_token => $is_new_token
		};
	}



};

dance;
