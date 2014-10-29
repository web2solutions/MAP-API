package MAP::contact::race::Race;
use Dancer ':syntax';
use Dancer::Plugin::REST;

our $VERSION = '0.1';
my $collectionName = 'race';
my $primaryKey = 'ContactRaceId';
my $tableName = 'ContactRace';
my $defaultColumns = 'ContactRaceId,ContactId,RaceID';
my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $relationalColumn = 'ContactId'; # undef

prefix '/contact/:'. $relationalColumn; # | undef

# end point default routes
use MAP::DefaultRoute;
&MAP::DefaultRoute::Subs( $collectionName, $primaryKey, $tableName, $defaultColumns, $root_path, $relationalColumn );
# end point default routes
dance;
