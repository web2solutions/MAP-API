package MAP::contact::marital::History;
use Dancer ':syntax';
use Dancer::Plugin::REST;

our $VERSION = '0.1';
my $collectionName = 'maritalhistory';
my $tableName = 'ContactMarraigeHistory';
my $primaryKey = 'ContactMarraigeId';
my $defaultColumns = '';
my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $relationalColumn = 'ContactId'; # undef

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
