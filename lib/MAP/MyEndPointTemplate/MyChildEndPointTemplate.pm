package MAP::MyEndPointTemplate::MyChildEndPointTemplate;
use Dancer ':syntax';
use Dancer::Plugin::REST;

our $VERSION = '0.1';

# ======== CHANGE HERE
my $collectionName = 'my_sub_collection_name';
my $primaryKey = 'my_primary_key_name';
my $tableName = 'my_table_name';
my $defaultColumns = 'name,of,columns,here';
my $relationalColumn = 'parent_record_id'; # undef
# ======== CHANGE HERE

my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $specific_append_sql_logic_select = '';
my $prefix = '/my_collection_name/:'. $relationalColumn;

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
