package MAP::address::ZipSearch;
use Dancer ':syntax';

use Encode qw( encode decode );
use Data::Recursive::Encode;

our $VERSION = '0.1';

prefix undef;


options '/address/search/zip/:zip.:format' => sub {
	MAP::API->options_header();
};


get '/address/search/zip/:zip.:format' => sub {

   MAP::API->check_authorization( params->{token}, request->header("Origin") );

   my $zip = params->{zip} || MAP::API->fail('zip is missing');

   my $dbh = MAP::API->dbh();

   my $sql = 'SELECT s.StateID as StateID, s.StateName as StateName, c.CountyID as CountyID, c.CountyText as CountyText FROM lkpState s join lkpCounty c on s.StateId = c.StateId join lkpCountyZip cz on c.CountyID = cz.CountyID WHERE cz.Zip = ?';

   my $sth = $dbh->prepare(
        $sql,
   );
   $sth->execute( $zip ) or MAP::API->fail( $sth->errstr );

   my @records;
   while ( my $record = $sth->fetchrow_hashref())
	{
		push @records, $record;
	}

	#$dbh->disconnect();

	MAP::API->normal_header();
		  return {
			  status => 'success',
			  response => 'search done',
			  sql => $sql,
			  'address' => [@records]
		  };
};


dance;
