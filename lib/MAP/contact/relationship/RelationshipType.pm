package MAP::contact::relationship::RelationshipType;
use Dancer ':syntax';
use Dancer::Plugin::REST;

our $VERSION = '0.1';
my $collectionName = 'type';
my $primaryKey = 'RelationshipTypeId';
my $tableName = 'Rel_lkp_RelationshipType';
my $defaultColumns = 'RelationshipTypeId,RelationshipTypeText,RelationshipSubTypeId,RelationshipLimit,Rec_RelationshipTypeId,IsRoleSearchable,isLookup,isActive,isFunction,FunctionRelTypeId,isCaseWorker,ConnectionPriority,isUser,isQuickConnect,MaleRecipRelTypeId,FemaleRecipRelTypeId,RelTypeAbbrev,AssociateProgram_RelationshipTypeId,HideInHomeYN,ContactTypeScope';
my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $relationalColumn = undef; # undef

my $specific_append_sql_logic_select = '';
my $prefix = '/contact/relationship';

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
