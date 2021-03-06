package MAP::contact::address::Address;
use Dancer ':syntax';
use Dancer::Plugin::REST;

our $VERSION = '0.1';
my $collectionName = 'address';
my $primaryKey = 'AddressId';
my $tableName = 'ContactAddress';
my $defaultColumns = 'AddressId,AddressTypeId,ContactId,Address1,Address2,City,StateId,Zip,CountryId,Countyid,AddStartDate,AddLeaveDate,MailingAddress,AddressProvinceID,ZipNumeric';
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
