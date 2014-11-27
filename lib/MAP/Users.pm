package MAP::Users;
use Dancer qw(:syntax :moose);
use Dancer::Plugin::REST;

#use MAP::MyEndPointTemplate::MyChildEndPointTemplate;

our $VERSION = '0.1';





# ======== CHANGE HERE
my $tableName = 'user_accounts';
my $collectionName = 'users';
my $primaryKey = '';
my $defaultColumns = '';
# ======== CHANGE HERE



my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $relationalColumn = undef; # undef

my $specific_append_sql_logic_select = '';
my $prefix = undef;

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
