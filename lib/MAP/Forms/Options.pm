package MAP::Forms::Options;
use Dancer ':syntax';
use Dancer::Plugin::REST;

our $VERSION = '0.1';
my $collectionName = 'options';
my $primaryKey = 'option_id';
my $tableName = 'formmaker_fieldoptions';
my $defaultColumns = 'page_id,option_id,field_id,type,type_standard,name,label,asdefault,caption,tooltip,text_size,required,className,mask_to_use,value,info,note,index,FieldOptionSeq,optionname,text,use_library,library_field_id';

my $relationalColumn = 'field_id';

prefix '/forms/:id/pages/:page_id/fields/:' . $relationalColumn . '';

my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;
# end point default routes
use MAP::DefaultRoute;
&MAP::DefaultRoute::Subs( $collectionName, $primaryKey, $tableName, $defaultColumns, $root_path, $relationalColumn );
# end point default routes
dance;
