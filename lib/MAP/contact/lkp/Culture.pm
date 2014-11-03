package MAP::contact::lkp::Culture;
use Dancer ':syntax';
use Dancer::Plugin::REST;

our $VERSION = '0.1';
my $collectionName = 'cultures';
my $primaryKey = 'CultureID';
my $tableName = 'lkpCulture';
my $defaultColumns = 'CultureID,CultureText';
my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $relationalColumn = undef; # undef

prefix '/contact/lkp'; # | undef

# routing OPTIONS header
options '/'.$collectionName.'.:format' => sub {
	MAP::API->options_header();
};

options '/'.$collectionName.'/:'.$primaryKey.'.:format' => sub {
	MAP::API->options_header();
};

options '/'.$collectionName.'/doc' => sub {
	MAP::API->options_header();
};

get '/'.$collectionName.'/doc' => sub {
	my @defaultColumns = split(/,/, $defaultColumns);
	template 'doc', {
		'collectionName' => $collectionName,
		'tableName' => $tableName,
		'prefix' => '/contact/lkp',
		'defaultColumns' => [@defaultColumns],
		'defaultColumnsStr' => $defaultColumns,
		'primaryKey' => $primaryKey
  };

};


# routing OPTIONS header

use MAP::DefaultRoute;
&MAP::DefaultRoute::Subs( $collectionName, $primaryKey, $tableName, $defaultColumns, $root_path, $relationalColumn );

dance;
