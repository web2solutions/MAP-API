package MAP::payments::AuthorizeNet;
use Dancer ':syntax';
use Dancer::App;
use MIME::Base64;
use Dancer::Plugin::REST;
use Encode qw( encode decode );
use Data::Recursive::Encode;
use URI::Escape;
use LWP;
use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use Data::Dumper;
#use DateTime;

our $VERSION = '0.1';

prefix '/payments/authorizenet';

sub get_avs_message
{
		my ($letter) = @_;
		my %messages = undef;
		$messages{A} = "The street address matches, but the 5-digit ZIP code does not";
		$messages{B} = "Address information was not submitted in the transaction information, so AVS check could not be performed";
		$messages{E} = "The AVS data provided is invalid, or AVS is not allowed for the card type submitted";
		$messages{G} = "The credit card issuing bank is of non-U.S. origin and does not support AVS";
		$messages{N} = "Neither the street address nor the 5-digit ZIP code matches the address and ZIP code on file for the card";
		$messages{P} = "AVS is not applicable for this transaction";
		$messages{R} = "AVS was unavailable at the time the transaction was processed. Retry transaction";
		$messages{S} = "The U.S. card issuing bank does not support AVS";
		$messages{U} = "Address information is not available for the customer's credit card";
		$messages{W} = "The 9-digit ZIP code matches, but the street address does not match";
		$messages{Y} = "The street address and the first 5 digits of the ZIP code match perfectly";
		$messages{Z} = "The first 5 digits of the ZIP code matches, but the street address does not match";
		return $messages{$letter};
}

sub get_cvv2_message
{
		my ($letter) = @_;
		my %messages = undef;
		$messages{" "} = 'Check failed either because CVV2 value entered is incorrect or no CVV2 value was entered';
		$messages{""} = 'Check failed either because CVV2 value entered is incorrect or no CVV2 value was entered';
		$messages{M} = "Match";
		$messages{N} = "No match";
		$messages{P} = "Not processed, CVV2 could not be verified";
		$messages{S} = "Issuer indicates that CVV2 should be present on the card, but no CVV2 data was entered with transaction";
		$messages{U} = "Issuer does not support CVV2";
		return $messages{$letter};
}


sub get_cavv_message
{
		my ($letter) = @_;
		my %messages = undef;

		$messages{""} = '';
		$messages{" "} = '';
		$messages{"0"} = 'CAVV not validated because erroneous data was submitted';
		$messages{"1"} = 'CAVV failed validation';
		$messages{"2"} = 'CAVV passed validation';
		$messages{"3"} = 'CAVV validation could not be performed; issuer attempt incomplete';
		$messages{"4"} = 'CAVV validation could not be performed; issuer system error';
		$messages{"5"} = 'Reserved for future use';
		$messages{"6"} = 'Reserved for future use';
		$messages{"7"} = 'CAVV attempt  failed validation  issuer available (U.S.-issued card/non-U.S acquirer)';
		$messages{"8"} = 'CAVV attempt  passed validation  issuer available (U.S.-issued card/non-U.S. acquirer)';
		$messages{"9"} = 'CAVV attempt  failed validation  issuer unavailable (U.S.-issued card/non-U.S. acquirer)';
		$messages{"A"} = 'CAVV attempt  passed validation  issuer unavailable (U.S.-issued card/non-U.S. acquirer)';
		$messages{"B"} = 'CAVV passed validation, information only, no liability shift';
		return $messages{$letter};
}



options '/dopayment.:format' => sub {
	MAP::API->options_header();
};


post '/dopayment.:format' => sub {

	MAP::API->check_authorization( params->{token}, request->header("Origin") );

	my %settings = undef;

	$settings{extra} = params->{extra} || '{}';

	foreach my $field (qw/invoice_id invoice_totalpay pay_for_desc customer_id customer_email billing_address1 billing_city billing_country billing_firstname billing_lastname billing_state billing_zipcode card_type card_expirationdate card_firstname card_lastname card_number card_securitycode/) {
		if ( params->{$field} ) {
			$settings{$field} = params->{$field};
		}
		else
		{
			MAP::API->fail("$field is missing when calling the end point. Will need to pass this field on the request.");
		}
	}

	foreach my $field (qw/billing_address2 billing_mobilenumber billing_phonenumber billing_companyname/) {
		$settings{$field} = params->{$field} || '';
	}

	my $dbh = MAP::API->dbh();
	my $strSQL = "SELECT Payment1,Payment2 FROM PaymentSettings WHERE PaymentProcessor = 'CAIRS_AUTHORIZE';";
	my $sth = $dbh->prepare( $strSQL, );
	$sth->execute( ) or MAP::API->fail( $sth->errstr );
	debug '============ rows: '.$sth->rows;
	if ( $sth->rows < -1 ) {
		MAP::API->fail( 'configuration for authorize.net was not set on database.' )
	}

	while ( my $record = $sth->fetchrow_hashref() )
	{
		$settings{user} = $record->{Payment1};
		$settings{password} = $record->{Payment2};
	}
	debug '============ user: '.$settings{user};
	debug '============ password: '.$settings{password};

	$strSQL = "SELECT email_id FROM user_agencies;";
	$sth = $dbh->prepare( $strSQL, );
	$sth->execute( ) or MAP::API->fail( $sth->errstr );

	if ( $sth->rows < -1 ) {
		MAP::API->fail( 'this agency has no email_id on database. Impossible to send an email to the agency(merchant).' )
	}

	while ( my $record = $sth->fetchrow_hashref() )
	{
		$settings{x_merchant_email} = $record->{email_id};
	}

	# the parameters for the payment can be configured here
	my $post_values	=
	{
		# the API Login ID and Transaction Key must be replaced with valid values
		"x_login"			=> $settings{user},
		"x_tran_key"		=> $settings{password},
		# ---------
		"x_version"			=> "3.1",
		"x_delim_data"		=> "TRUE",
		"x_delim_char"		=> "|",
		"x_relay_response"	=> "FALSE",
		# ---------
		"x_type"			=> "AUTH_CAPTURE",
		"x_method"			=> "CC",
		"x_card_num"		=> $settings{card_number},
		"x_exp_date"		=> $settings{card_expirationdate},
		'x_card_code'		=> $settings{card_securitycode},
		# ---------
		"x_amount"			=> $settings{invoice_totalpay},
		"x_description"		=> $settings{pay_for_desc},
		# ---------
		"x_first_name"		=> $settings{card_firstname},
		"x_last_name"		=> $settings{card_lastname},
		"x_address"			=> $settings{billing_address1},
		"x_state"			=> $settings{billing_state},
		"x_zip"				=> $settings{billing_zipcode},
		# ---------
		"x_customer_ip"	=> Dancer::request->header("X-Forwarded-For") || Dancer::request->header("REMOTE_ADDR"),
		# Additional fields can be added here as outlined in the AIM integration
		# guide at: http://www.authorize.net/support/AIM_guide_SCC.pdf
		# ---------
		"x_email" => $settings{customer_email},
		"x_email_customer" => 'TRUE',
		"x_merchant_email" => $settings{x_merchant_email}
	};





	my $post_url = "https://secure.authorize.net/gateway/transact.dll";
	# We use the HTTP::Request and LWP::UserAgent digests to submit the input
	# values and record the response
	my $useragent	= LWP::UserAgent->new( protocols_allowed => ["https"] );
	my $request		= POST( $post_url, $post_values );
	my $response	= $useragent->request( $request );

	my $page = $response->content;

	# This line takes the response and breaks it into an array using the pipe
	# character "|" as a delimiter.  It must be updated if you change the
	# delimiting character
	my @responses		= split( /\Q|/ , $response->content );
	my $server_response = $page;
    my $avs_code = $responses[5];
    my $order_number = $responses[6];
    my $md5 = $responses[37];
    my $cvv2_response = $responses[38];
    my $cavv_response = $responses[39];
	my $error_message = '';
	my $result_code = $responses[0];
	my $authorization = '';
	my $returned_text = '';

	#1|1|1|This transaction has been approved.|03813G|Y|5108890878||Adoption Portal|0.31|CC|auth_capture||Mark|Livings||11643 Groove Street||Florida|33772||||||||||||||||||B89432362D36D4CFDAD00BDEFDFC74B6|M||||||||||||XXXX6336|Visa|||||||||||||||| ->>>>>>
	#Y - 5108890878 - B89432362D36D4CFDAD00BDEFDFC74B6 - M -  - 03813G - 1 -

	MAP::API->normal_header();

	my $r;
	if($responses[0] eq "1" )
	{ # Authorized/Pending/Test
        if ($responses[4] =~ /^(.*)\s+(\d+)$/) { #eProcessingNetwork extra bits..
          $authorization = $2;
        } else {
          $authorization = $responses[4];
        }
		$returned_text = $responses[3];

		$r = {
			status  => "success",
			response =>  "Card captured successfully: ".$authorization."\n",
			avs_code => $avs_code . ' - ' .get_avs_message( $avs_code ),
			cvv2_response => $cvv2_response . ' - ' . get_cvv2_message($cvv2_response),
			#cavv_response => $cavv_response . ' - ' .get_cavv_message( $cavv_response ),
			#date => $dt->month.'/'.$dt->day.'/'.$dt->year,
			#time => $dt->hour.':'.$dt->minute.':'.$dt->second,
			authorization => $authorization,
			#returned_response => $returned_text
		};
    } else {
        $error_message = $responses[3];
		$returned_text = $responses[3];

		status 500;
		$r = {
			status => 'err', response => 'Not Paid',
			status  => "err",
            response =>  get_cvv2_message($cvv2_response),
			avs_code => $avs_code . ' - ' .get_avs_message( $avs_code ),
			cvv2_response => $cvv2_response . ' - ' . get_cvv2_message($cvv2_response),
			#returned_response => $returned_text
		};
    }


	my($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime();
	my $branch = Dancer::request->header("X-branch") || 'test';
	my $template = '';
	my $client_ip = Dancer::request->header("X-Forwarded-For") || Dancer::request->header("REMOTE_ADDR");#
	#client IP
	my $client_vendor = (request->header("X-Requested-With") ? request->header("X-Requested-With").'' : 'unknown'.'');
	my $client_user_agent = request->header("User-Agent") || 'unknown';
	my $browser_name = Dancer::request->header("X-browser-name") || 'unknown';
	my $browser_os = Dancer::request->header("X-browser-os") || 'unknown';
	my $browser_version = Dancer::request->header("X-browser-version") || 'unknown';
	my $screen_width = Dancer::request->header("X-browser-screen-width") || 'unknown';
	my $screen_height = Dancer::request->header("X-browser-screen-height") || 'unknown';
	my $rdate = ($year + 1900).'-'.($mon + 1).'-'.$mday;
	my $rtime = $hour.':'.$min.':'.$sec;
	my $host = Dancer::request->header("X-Forwarded-Host") || Dancer::request->header("Host");
	my $origin = Dancer::request->header("Origin") || 'unknown';
	my $referer = Dancer::request->header("Referer") || 'unknown';
	my $agency_id = Dancer::request->header("X-AId") || 0;
	my $token = request->env->{HTTP_AUTHORIZATION} || 'not authorized';
	my $client_session_id = Dancer::request->header("X-client-session-id") || 0;
	my $json_document = to_json({
		request_date => $rdate,
			request_time => $rtime,
			client_session_id => $client_session_id,
			branch => $branch,
			api_host => $host,
			origin_domain => $origin,
			referer => $referer,
			agency_id => $agency_id,
			#agency_database => MIME::Base64::decode(Dancer::request->header("X-db")),
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
			response_status => Dancer::SharedData->response->status,
			payment_gateway => 'authorize.net',
			#response_type => Dancer::SharedData->response->content_type,
			"x_authorizenet_login"			=> $settings{user},
			"x_authorizenet_tran_key"		=> $settings{password},
			"x_authorizenet_type"			=> "AUTH_CAPTURE",
			"x_authorizenet_method"			=> "CC",
			"x_authorizenet_exp_date"		=> $settings{card_expirationdate},
			'x_authorizenet_card_code'		=> $settings{card_securitycode},
			# ---------
			"x_authorizenet_amount"			=> $settings{invoice_totalpay},
			"x_authorizenet_description"		=> $settings{pay_for_desc},
			# ---------
			"x_authorizenet_first_name"		=> $settings{card_firstname},
			"x_authorizenet_last_name"		=> $settings{card_lastname},
			"x_authorizenet_address"			=> $settings{billing_address1},
			"x_authorizenet_state"			=> $settings{billing_state},
			"x_authorizenet_zip"				=> $settings{billing_zipcode},
			"x_authorizenet_email" => $settings{customer_email},
			"x_authorizenet_email_customer" => 'TRUE',
			"x_authorizenet_merchant_email" => $settings{x_merchant_email},
			avs_code => $avs_code . ' - ' .get_avs_message( $avs_code ),
			cvv2_response => $cvv2_response . ' - ' . get_cvv2_message($cvv2_response),
			authorization => $authorization,
			#returned_response => $returned_text,
			error_message => $error_message,
	});
	#
	#debug dump($json_document);
	my $dbhpg = MAP::API->dbh_pg();
	$strSQL = 'INSERT INTO payments_log( jdoc )
		VALUES( ? )
		RETURNING payments_log_id;
	';
	$sth = $dbhpg->prepare($strSQL);
	$sth->execute($json_document) or MAP::API->fail($sth->errstr." --------- ".$strSQL);#
	#debug request->request_uri();

	return $r;

};
dance;
