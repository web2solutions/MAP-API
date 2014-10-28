package MAP::LibraryFields::Options;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use DBI;


our $VERSION = '0.1';


options '/LibraryFields/options.:format' => sub {
	MAP::API->options_header();
};


get '/LibraryFields/options.:format' => sub {
	
	
	MAP::API->check_authorization_simple( params->{token}, request->header("Origin") );
	
   
   my $fieldId = params->{FieldID} || MAP::API->fail( "Type can not be empty" );
   
   my $dbh = MAP::API->dbh();

   my $sth = $dbh->prepare(
        'EXEC usp_Form_FieldOptionList ?',
   );
   $sth->execute( $fieldId );
   
   my @records;
   while ( my $record = $sth->fetchrow_hashref()) 
	{
		push @records, $record;
	}
	
	#$dbh->disconnect();
	
	MAP::API->normal_header();

	return { status => 'success', response => 'Succcess',  options => [@records], sql =>  "EXEC usp_Form_FieldOptionList $fieldId"};
};


del '/LibraryFields/options.:format' => sub {
	
	
	MAP::API->check_authorization( params->{token}, request->header("Origin") );
	
   
	my $FieldID = params->{FieldID} || MAP::API->fail( "Type can not be empty" );
	my $option_id = params->{option_id} || MAP::API->fail( "option_id can not be empty" );
	my $optionname = '';
   
	my $dbh = MAP::API->dbh();
   
	my $strSQL = 'EXEC usp_Form_FieldOptionAddEdit
		@option_id = ?,
		@DeleteYN = 1,
		@FieldID = ?,
		@optionname = ?,
		@asdefault = NULL,
		@empty = NULL,
		@key_id = 0,
		@FieldOptionSeq = 0
	';

	my $sth = $dbh->prepare( $strSQL, );
	$sth->execute( $option_id, $FieldID, $optionname );
   
	my $deleted_option_id = 0;
	while ( my $record = $sth->fetchrow_hashref()) 
	{
		$deleted_option_id = $record->{"Option_id"};
	}
	
	#$dbh->disconnect();
	
	MAP::API->normal_header();

	return { status => 'success', response => 'Succcess',  sql =>  $strSQL, option_id => $deleted_option_id};
};


dance;
