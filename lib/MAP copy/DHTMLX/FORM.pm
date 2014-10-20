package MAP::DHTMLX::FORM;
use Dancer ':syntax';
#use utf8;
use Encode       qw( encode );
use DBI;
use MAP::DHTMLX::FORM::UPLOAD;

our $VERSION = '0.1';


prefix '/dhtmlx/form';






dance;
