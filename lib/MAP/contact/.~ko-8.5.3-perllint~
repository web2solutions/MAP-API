package MAP::contact::Contact;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use utf8;
use Encode qw( encode );
use DBI;
use Data::Dump qw(dump);

use MAP::contact::education::Education;
use MAP::contact::email::Email;
use MAP::contact::phone::Phone;

our $VERSION = '0.1';
my $collectionName = 'contact';
my $primaryKey = 'ContactId';
my $tableName = 'Contact';
my $defaultColumns = 'ContactId';
my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $relationalColumn = undef; # undef

prefix undef;

# routing OPTIONS header
options '/'.$collectionName.'.:format' => sub {
	MAP::API->options_header();
};

options '/'.$collectionName.'/:'.$primaryKey.'.:format' => sub {
	MAP::API->options_header();
};
options '/'.$collectionName.'/:'.$primaryKey.'/.:format' => sub {
	MAP::API->options_header();
};


any '/'.$collectionName.'.:format' => sub {
    send_error("Hey Mark, it is not implemented yet", 501);
};


 
# routing OPTIONS header


dance;