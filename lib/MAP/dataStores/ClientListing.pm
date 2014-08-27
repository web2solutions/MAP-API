package MAP::dataStores::ClientListing;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use DBI;


our $VERSION = '0.1';


options '/dataStores/ClientListing.:format' => sub {
	MAP::API->options_header();
};

get '/dataStores/ClientListing.:format' => sub {
   
   MAP::API->check_authorization( params->{token}, request->header("Origin") );
   
   my $dbh = MAP::API->dbh();

   ## ---- groups
   $dbh->do("use MAPTEST;");
   my $sth = $dbh->prepare(
        'SELECT * FROM user_groups ORDER BY group_name ASC',
   );
   $sth->execute();
   my @groups;
   while ( my $record = $sth->fetchrow_hashref()) 
	{
		my $row = {
			value =>	$record->{"group_id"},
			text => $record->{"group_name"}
		 };
		push @groups, $row;
	}
	
	## ---- programs
   $dbh->do("use TESTMAP;");
   $sth = $dbh->prepare(
        'select * from Rel_lkp_RelationshipSubType ORDER BY RelationshipSubTypeText ASC',
   );
   $sth->execute();
   my @programs;
   while ( my $record = $sth->fetchrow_hashref()) 
	{
		my $row = {
			value =>	$record->{"RelationshipSubTypeId"},
			text => $record->{"RelationshipSubTypeText"}
		 };
		push @programs, $row;
	}
	
	
	## ---- case_workers
   $dbh->do("use MAPTEST;");
   $sth = $dbh->prepare(
        "select * from user_accounts WHERE user_type = 'agency_user' ORDER BY first_name ASC",
   );
   $sth->execute();
   my @case_workers;
   while ( my $record = $sth->fetchrow_hashref()) 
	{
		my $row = {
			value =>	$record->{"user_id"},
			text => $record->{"first_name"}. " " . $record->{"last_name"}
		 };
		push @case_workers, $row;
	}
	
	
	
	## ---- roles
   $dbh->do("use TESTMAP;");
   $sth = $dbh->prepare(
        "select * FROM Rel_lkp_RelationshipType ORDER BY RelationshipTypeText ASC;",
   );
   $sth->execute();
   my @roles;
   while ( my $record = $sth->fetchrow_hashref()) 
	{
		my $row = {
			value =>	$record->{"RelationshipTypeId"},
			text => $record->{"RelationshipTypeText"}
		 };
		push @roles, $row;
	}
	
	
	## ---- case_status
   $dbh->do("use TESTMAP;");
   $sth = $dbh->prepare(
        "select DISTINCT ConnectionStatusText from lkpConnectionStatus ORDER BY ConnectionStatusText ASC;",
   );
   $sth->execute();
   my @case_status;
   while ( my $record = $sth->fetchrow_hashref()) 
	{
		my $row = {
			value =>	$record->{"ConnectionStatusText"},
			text => $record->{"ConnectionStatusText"}
		 };
		push @case_status, $row;
	}
	
	#$dbh->disconnect();
	
	MAP::API->normal_header();
	
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
	
	
	return { status => 'success', response => 'Succcess', groups => [@groups], programs => [@programs], case_workers => [@case_workers], roles => [@roles], case_status => [@case_status] };
   
};


dance;
