package MAP::contact::lkp::Culture;
use Dancer ':syntax';
use Dancer::Plugin::REST;

our $VERSION = '0.1';
my $collectionName = 'cultures';
my $primaryKey = 'CultureID';
my $tableName = 'lkpCulture';
my $defaultColumns = 'CultureID,CultureText';
my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $relationalColumn = undef; # undef

my $specific_append_sql_logic_select = '';
my $prefix = '/contact/lkp';

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
