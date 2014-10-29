package MAP::contact::relationship::ComponentConfiguration;
use Dancer ':syntax';
use Dancer::Plugin::REST;

our $VERSION = '0.1';
my $collectionName = 'configuration';
my $primaryKey = 'Rel_ComponentId';
my $tableName = 'Rel_Component';
my $defaultColumns = 'Rel_ComponentId,field_id,RelationshipSubTypeIds,RelationsshipTypeIds,SubForms';
my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $relationalColumn = "field_id"; # undef

prefix '/contact/relationship/component/:' . $relationalColumn . ''; # | undef

# end point default routes
use MAP::DefaultRoute;
&MAP::DefaultRoute::Subs( $collectionName, $primaryKey, $tableName, $defaultColumns, $root_path, $relationalColumn );
# end point default routes
dance;
