package MAP::LibraryFields::Category;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use DBI;
use Encode qw( encode decode );
use Data::Recursive::Encode;

our $VERSION = '0.1';


options '/LibraryFields/category.:format' => sub {
	MAP::API->options_header();
};


get '/LibraryFields/category.:format' => sub {

   MAP::API->check_authorization_simple( params->{token}, request->header("Origin") );

   MAP::API->normal_header();

   my $dbh = MAP::API->dbh();

   my $sql = 'EXEC usp_GetFieldCategory 0';

   my $sth = $dbh->prepare(
        $sql,
   );
   $sth->execute() or MAP::API->fail( $sth->errstr );

   my @records;
   while ( my $record = $sth->fetchrow_hashref())
	{
		push @records, Data::Recursive::Encode->decode_utf8( $record );
	}

	#$dbh->disconnect();

	return { status => 'success', response => 'Succcess',  category => [@records], sql => $sql };
};


dance;
