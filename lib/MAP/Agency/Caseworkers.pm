package MAP::Agency::Caseworkers;
use Dancer ':syntax';
use Dancer::Plugin::REST;

our $VERSION = '0.1';

my $collectionName = 'caseworkers';
my $primaryKey = 'user_id';
my $tableName = 'user_accounts';
my $defaultColumns = 'user_id,username,password,first_name,last_name,email,photo,organization,title,phone,address1,address2,city,state,zipcode,country,website,mobile_number,status,summary,membership,user_posting,user_register,datejoined,last_login,last_ip,session,suspend_until,timezone,itemized_date,user_type,agency_group,agency_name,agency_id,group_id,queation,answer,due_date,race,note,over_21,marital_status,message_alert,case_worker,case_worker_parent_user_id,adoption_type,spouse_first_name,spouse_last_name,spouse_organization,spouse_title,spouse_website,referral,mailtogroups,airs_contact_id,airs_contactairs_id,doctogroups,doctousers,personal_gender,spouse_gender,message_group,quickbook_listid,quickbook_vendorid,quickbook_queue,signer1,signer2,video_msg,status_mode,edd,id_type,id_number,quickbook_custeditseq,quickbook_vendeditseq,qb_listid_online,qb_vendorid_online,qb_online_updation,qb_standalone_updation,new_encryption,passwordchange,passwordchangedate,ConnId,SBFlag,SBSaveMapDate,trace';

my $relationalColumn = 'agency_id'; # undef

my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $specific_append_sql_logic_select = " AND [user_type] = 'agency_user' AND [status] = 'Active' ";


my $prefix = '/agency/:'. $relationalColumn;

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
