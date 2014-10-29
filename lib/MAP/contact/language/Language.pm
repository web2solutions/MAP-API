package MAP::contact::language::Language;
use Dancer ':syntax';
use Dancer::Plugin::REST;

our $VERSION = '0.1';
my $collectionName = 'language';
my $primaryKey = 'ContactLanguageId';
my $tableName = 'ContactLanguage';
my $defaultColumns = 'ContactLanguageId,ContactId,LanguageId,PrimaryLanguage';
my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $relationalColumn = 'ContactId'; # undef

prefix '/contact/:'. $relationalColumn; # | undef

# end point default routes
use MAP::DefaultRoute;
&MAP::DefaultRoute::Subs( $collectionName, $primaryKey, $tableName, $defaultColumns, $root_path, $relationalColumn );
# end point default routes
dance;
