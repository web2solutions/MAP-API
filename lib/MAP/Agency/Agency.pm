package MAP::Agency::Agency;
use Dancer ':syntax';
use Dancer::Plugin::REST;

use MAP::Agency::Caseworkers;



our $VERSION = '0.1';
my $collectionName = 'agency';
my $primaryKey = 'agency_id';
my $tableName = 'dbo.user_agencies';
my $defaultColumns = 'agency_id,user_id,agency_name,address_line_1,address_line_2,city,state,zip,country,website,phone,fax,email_id,birth_parent_number,adoptive_parent_number,after_hours_number,type_of_business,technology,no_of_years_in_business,no_of_staff,services,states_licensed_in,countries_licensed_in,no_of_adoptions_year,email_id_for_notifications,alert_preference,phone_to_sms,mision_statement_check,mision_statement_text,values_check,values_text,background_check,background_text,logo,nature_of_adoption,religions,payment_option,perfect_adoption_portal,other_info,specialties,c_account_key,ConnId,agency_tax_id,county_id,doc_process_id';

my $relationalColumn = undef; # undef

prefix undef;

my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

# end point default routes
use MAP::DefaultRoute;
&MAP::DefaultRoute::Subs( $collectionName, $primaryKey, $tableName, $defaultColumns, $root_path, $relationalColumn );
# end point default routes
dance;
