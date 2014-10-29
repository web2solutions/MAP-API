package MAP::contact::email::EmailType;
use Dancer ':syntax';
use Dancer::Plugin::REST;

our $VERSION = '0.1';
my $collectionName = 'emailTypes';
my $primaryKey = 'EMailTypeId';
my $tableName = 'lkpEmailType';
my $defaultColumns = 'EMailTypeId,EmailType,EmailSequence';
my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $relationalColumn = undef; # undef

prefix '/contact'; # | undef

# end point default routes
use MAP::DefaultRoute;
&MAP::DefaultRoute::Subs( $collectionName, $primaryKey, $tableName, $defaultColumns, $root_path, $relationalColumn );
# end point default routes
dance;
