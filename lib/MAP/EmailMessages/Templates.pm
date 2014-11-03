package MAP::EmailMessages::Templates;
use Dancer ':syntax';
use Dancer::Plugin::REST;

our $VERSION = '0.1';
my $collectionName = 'templates';
my $primaryKey = 'template_id';
my $tableName = 'emailmessages_templates';
my $defaultColumns = 'template_id,name,subject,message';

my $relationalColumn = undef; # undef

my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $specific_append_sql_logic_select = '';
my $prefix = '/emailmessages';

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
