package MAP::MyEndPointTemplate;
use Dancer ':syntax';
use Dancer::Plugin::REST;

use MAP::MyEndPointTemplate::MyChildEndPointTemplate;

our $VERSION = '0.1';

# ======== CHANGE HERE
my $collectionName = 'my_collection_name';
my $primaryKey = 'my_primary_key_name';
my $tableName = 'my_table_name';
my $defaultColumns = 'name,of,columns,here';
# ======== CHANGE HERE

my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $relationalColumn = undef; # undef

my $specific_append_sql_logic_select = '';
my $prefix = '';

prefix undef; # | undef

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
