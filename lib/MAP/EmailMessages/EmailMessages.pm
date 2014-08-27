package MAP::EmailMessages::EmailMessages;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use utf8;
use Encode qw( encode );
use DBI;
use Data::Dump qw(dump);
use MAP::EmailMessages::Templates;



our $VERSION = '0.1';
my $collectionName = 'emailmessages';
my $primaryKey = undef;
my $tableName = undef;
my $defaultColumns = undef;
my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $relationalColumn = undef; # undef

prefix undef;

# routing OPTIONS header
options '/'.$collectionName.'.:format' => sub {
	MAP::API->options_header();
};

dance;