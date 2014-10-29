package MAP::contact::nationality::Nationality;
use Dancer ':syntax';
use Dancer::Plugin::REST;

our $VERSION = '0.1';
my $collectionName = 'nationality';
my $primaryKey = 'ContactNationalityId';
my $tableName = 'ContactNationality';
my $defaultColumns = 'ContactNationalityId,ContactId,NationalityID';
my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $relationalColumn = 'ContactId'; # undef

prefix '/contact/:'. $relationalColumn; # | undef

# end point default routes
use MAP::DefaultRoute;
&MAP::DefaultRoute::Subs( $collectionName, $primaryKey, $tableName, $defaultColumns, $root_path, $relationalColumn );
# end point default routes
dance;
