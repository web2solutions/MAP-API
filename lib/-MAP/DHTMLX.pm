package MAP::DHTMLX;
use Dancer ':syntax';
#use utf8;
use Encode       qw( encode );
use DBI;
use MAP::DHTMLX::GRID::FEED;
use MAP::DHTMLX::FORM;

our $VERSION = '0.1';


prefix '/dhtmlx';






dance;
