package MAP::contact::email::Email;
use Dancer ':syntax';
use Dancer::Plugin::REST;

use MAP::contact::email::EmailType;

our $VERSION = '0.1';
my $collectionName = 'emails';
my $primaryKey = 'ContactEMailID';
my $tableName = 'ContactEMail';
my $defaultColumns = 'ContactEMailID,ContactID,EMailTypeID,ContactEMail,PrimaryEMail';
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
