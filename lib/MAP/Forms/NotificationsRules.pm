package MAP::Forms::NotificationsRules;
use Dancer ':syntax';
use Dancer::Plugin::REST;

our $VERSION = '0.1';
my $collectionName = 'rules';
my $primaryKey = 'rule_id';
my $tableName = 'formmaker_notification_rules';
my $defaultColumns = 'rule_id,form_id,target_id,source_id,condition,source_value';

my $relationalColumn = 'notification_id';

prefix '/forms/:id/notifications/:' . $relationalColumn . '';

my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;
# end point default routes
use MAP::DefaultRoute;
&MAP::DefaultRoute::Subs( $collectionName, $primaryKey, $tableName, $defaultColumns, $root_path, $relationalColumn );
# end point default routes
dance;
