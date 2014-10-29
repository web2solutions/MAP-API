package MAP::Forms::Pages;
use Dancer ':syntax';
use Dancer::Plugin::REST;


use MAP::Forms::Fields;
use MAP::Forms::PagesRules;



our $VERSION = '0.1';
my $collectionName = 'pages';
my $primaryKey = 'page_id';
my $tableName = 'FORMMAKER_Pages';
my $defaultColumns = 'page_id,form_id,pagename,index,key_id,page_layout,tab_width,rule_action,rule_match,rule_enable';

my $relationalColumn = 'form_id'; # undef

prefix '/forms/:'. $relationalColumn; # | undef

my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;
# end point default routes
use MAP::DefaultRoute;
&MAP::DefaultRoute::Subs( $collectionName, $primaryKey, $tableName, $defaultColumns, $root_path, $relationalColumn );
# end point default routes
dance;
