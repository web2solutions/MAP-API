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

my $specific_append_sql_logic_select = '';
my $prefix = '/contact/:'. $relationalColumn;

prefix $prefix; # | undef

# end point default routes
use MAP::DefaultRoute;
&MAP::DefaultRoute::Subs(
	$collectionName,
	$primaryKey,
	$tableName,
	$defaultColumns,
	$root_path,
	$relationalColumn,
	$specific_append_sql_logic_select,
	$prefix
);
# end point default routes
dance;
