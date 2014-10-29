package MAP::contact::phone::Phone;
use Dancer ':syntax';
use Dancer::Plugin::REST;

use MAP::contact::phone::PhoneType;


our $VERSION = '0.1';
my $collectionName = 'phones';
my $primaryKey = 'ContactPhoneID';
my $tableName = 'ContactPhone';
my $defaultColumns = 'ContactPhoneID,ContactID,PhoneTypeID,PhoneNumber,PrimaryPhone,Ext';
my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $relationalColumn = 'ContactID'; # undef

prefix '/contact/:'. $relationalColumn; # | undef

# end point default routes
use MAP::DefaultRoute;
&MAP::DefaultRoute::Subs( $collectionName, $primaryKey, $tableName, $defaultColumns, $root_path, $relationalColumn );
# end point default routes
dance;
