package MAP::MyEndPointTemplate::MyChildEndPointTemplate;
use Dancer ':syntax';
use Dancer::Plugin::REST;

our $VERSION = '0.1';

# ======== CHANGE HERE
my $collectionName = 'my_sub_collection_name';
my $primaryKey = 'my_primary_key_name';
my $tableName = 'my_table_name';
my $defaultColumns = 'name,of,columns,here';

my $relationalColumn = 'form_id'; # undef
# ======== CHANGE HERE

prefix '/my_collection_name/:'. $relationalColumn; # | undef


my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

# end point default routes
use MAP::DefaultRoute;
&MAP::DefaultRoute::Subs( $collectionName, $primaryKey, $tableName, $defaultColumns, $root_path, $relationalColumn );
# end point default routes


dance;
