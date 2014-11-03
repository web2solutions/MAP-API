package MAP::contact::lkp::AddressType;
use Dancer ':syntax';
use Dancer::Plugin::REST;

our $VERSION = '0.1';
my $collectionName = 'addressType';
my $primaryKey = 'AddressTypeID';
my $tableName = 'lkpAddressType';
my $defaultColumns = 'AddressTypeID,AddressType,AddressSequence';
my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $relationalColumn = undef; # undef

prefix '/contact/lkp'; # | undef

# end point default routes
use MAP::DefaultRoute;
&MAP::DefaultRoute::Subs( $collectionName, $primaryKey, $tableName, $defaultColumns, $root_path, $relationalColumn );
# end point default routes
dance;
