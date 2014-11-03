package MAP::Forms::Notifications;
use Dancer ':syntax';
use Dancer::Plugin::REST;

use MAP::Forms::NotificationsRules;


our $VERSION = '0.1';
my $collectionName = 'notifications';
my $primaryKey = 'notification_id';
my $tableName = 'formmaker_notification_rule';
my $defaultColumns = 'notification_id,form_id,notification_name,rule_match,rule_enable,emailto,template_id';

my $relationalColumn = 'form_id'; # undef

prefix '/forms/:'. $relationalColumn; # | undef

my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;
# end point default routes
use MAP::DefaultRoute;
&MAP::DefaultRoute::Subs( $collectionName, $primaryKey, $tableName, $defaultColumns, $root_path, $relationalColumn );
# end point default routes
dance;
