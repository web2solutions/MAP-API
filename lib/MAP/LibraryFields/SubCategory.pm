package MAP::LibraryFields::SubCategory;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use DBI;
use Encode qw( encode decode );
use Data::Recursive::Encode;

our $VERSION = '0.1';


options '/LibraryFields/subcategory.:format' => sub {
	MAP::API->options_header();
};


get '/LibraryFields/subcategory.:format' => sub {

	MAP::API->check_authorization( params->{token}, request->header("Origin") );
   my $dbh = MAP::API->dbh();

   my $sql = 'EXEC usp_GetFieldCategory 1';

   my $sth = $dbh->prepare(
        $sql ,
   );
   $sth->execute();

   my @records;
   while ( my $record = $sth->fetchrow_hashref())
	{
		push @records, Data::Recursive::Encode->decode_utf8( $record );
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

	return { status => 'success', response => 'Succcess',  subcategory => [@records], sql => $sql  };
};


dance;
