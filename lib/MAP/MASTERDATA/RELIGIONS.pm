package MAP::MASTERDATA::RELIGIONS;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use DBI;


our $VERSION = '0.1';


options '/masterdata/religions.:format' => sub {
	MAP::API->options_header();
};

del '/masterdata/religions.:format' => sub {
   MAP::API->check_authorization( params->{token}, request->header("Origin") );
   MAP::API->normal_header();
};

put '/masterdata/religions.:format' => sub {
   
	MAP::API->check_authorization( params->{token}, request->header("Origin") );
	
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

	return { status => 'success', response => 'Succcess', token => params->{token}, format => params->{format} };
};


post '/masterdata/religions.:format' => sub {
   
	MAP::API->check_authorization( params->{token}, request->header("Origin") );
	
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

	return { status => 'success', response => 'Succcess', token => params->{token}, format => params->{format} };
};


del '/masterdata/religions.:format' => sub {
   
	MAP::API->check_authorization( params->{token}, request->header("Origin") );
	
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

	return { status => 'success', response => 'Succcess', token => params->{token}, format => params->{format} };
};



get '/masterdata/religions.:format' => sub {
   
   MAP::API->check_authorization( params->{token}, request->header("Origin") );
   
   my $dbh = MAP::API->dbh();

   my $sth = $dbh->prepare(
        'exec SP_lkpReligion @CAccountKey = 158, @TaskType = "list"',
   );
   $sth->execute();
   
   my @records;
   while ( my $record = $sth->fetchrow_hashref()) 
	{

		my $row = {
			ReligionID =>	$record->{"ReligionID"},
			ReligionText => $record->{"ReligionText"}
		 };
		push @records, $record;
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

	return { status => 'success', response => 'Succcess',  religions => [@records] };
};


dance;
