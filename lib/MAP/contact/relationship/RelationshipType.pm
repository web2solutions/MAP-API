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

prefix '/contact/relationship'; # | undef

# end point default routes
use MAP::DefaultRoute;
&MAP::DefaultRoute::Subs( $collectionName, $primaryKey, $tableName, $defaultColumns, $root_path, $relationalColumn );
# end point default routes
dance;
