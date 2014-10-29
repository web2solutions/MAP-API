package MAP::contact::education::Degrees;
use Dancer ':syntax';
use Dancer::Plugin::REST;

our $VERSION = '0.1';
my $collectionName = 'degrees';
my $primaryKey = 'DegreeTypeId';
my $tableName = 'lkpDegree';
my $defaultColumns = 'DegreeTypeId,DegreeText';
my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $relationalColumn = undef; # undef

prefix '/contact'; # | undef

# end point default routes
use MAP::DefaultRoute;
&MAP::DefaultRoute::Subs( $collectionName, $primaryKey, $tableName, $defaultColumns, $root_path, $relationalColumn );
# end point default routes
dance;
