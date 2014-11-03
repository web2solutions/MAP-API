package MAP::contact::relationship::RelationshipSubType;
use Dancer ':syntax';
use Dancer::Plugin::REST;

our $VERSION = '0.1';
my $collectionName = 'subtype';
my $primaryKey = 'RelationshipSubTypeId';
my $tableName = 'Rel_lkp_RelationshipSubType';
my $defaultColumns = 'RelationshipSubTypeId,RelationshipSubTypeText,EditPage,Rel_SubType_Seq,Rel_SubType_ShowHide,isMultiConnect,Rel_SubType_isProgram,Rel_SubType_Abbrev,AssociateProgram,HideInHomeYN,PageId';
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
