package MAP::contact::phone::PhoneType;
use Dancer ':syntax';
use Dancer::Plugin::REST;

our $VERSION = '0.1';
my $collectionName = 'phoneTypes';
my $primaryKey = 'PhoneTypeID';
my $tableName = 'lkpPhoneType';
my $defaultColumns = '';
my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $relationalColumn = undef; # undef


my $specific_append_sql_logic_select = '';
my $prefix = '/contact';

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
