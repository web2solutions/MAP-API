package MAP::DHTMLX::FORM;
use Dancer ':syntax';
#
use Encode       qw( encode decode );
use DBI;
use MAP::DHTMLX::FORM::UPLOAD;

our $VERSION = '0.1';


prefix '/dhtmlx/form';






dance;
