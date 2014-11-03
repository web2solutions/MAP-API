package MAP::contact::education::Education;
use Dancer ':syntax';
use Dancer::Plugin::REST;

use MAP::contact::education::Degrees;



our $VERSION = '0.1';
my $collectionName = 'education';
my $primaryKey = 'ContactEducationID';
my $tableName = 'ContactEducation';
my $defaultColumns = 'ContactEducationID,ContactID,DegreeTypeID,Institution,YearDegreeObtained,PrimaryStudy,SecondaryStudy';
my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $relationalColumn = 'ContactId'; # undef

prefix '/contact/:'. $relationalColumn; # | undef

# end point default routes
use MAP::DefaultRoute;
&MAP::DefaultRoute::Subs( $collectionName, $primaryKey, $tableName, $defaultColumns, $root_path, $relationalColumn );
# end point default routes
dance;
