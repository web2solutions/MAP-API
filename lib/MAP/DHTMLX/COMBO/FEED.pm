package MAP::DHTMLX::COMBO::FEED;
use Dancer ':syntax';

use Encode       qw( encode decode );
use DBI;

use XML::Mini::Document;


our $VERSION = '0.1';
#our $root_path = '/var/www/html/userhome/MAP-API/forms';

prefix '/dhtmlx/combo';

options '/feed.xml' => sub {
    MAP::API->options_header();
};


get '/feed.xml' => sub {
   
   MAP::API->check_authorization_simple( params->{token}, request->header("Origin") );
   
   my $dbh = MAP::API->dbh();

   my $primaryKey =  params->{primary_key}  || MAP::API->fail( 'primary_key is missing' );
   $primaryKey =~ s/[^\w\d.-]+//g;

   my $tableName =  params->{table_name}  || MAP::API->fail( 'table_name is missing' );
   $tableName =~ s/[^\w\d.-]+//g;#~ tr/A-Za-z0-9//cd;

   #debug $tableName;

   my $count = params->{count} || 20;
   my $posStart = params->{pos} || 0;

   my $mask = params->{mask} || '';
   $mask =~ s/'//g;

   my $column_to_search = params->{column_to_search}  || MAP::API->fail( 'column_to_search is missing' );
   $column_to_search =~ s/[^\w\d.-]+//;
   
   my $value_column = params->{value_column} || $primaryKey;
   $value_column =~ s/[^\w\d.-]+//;
   

    my $newDoc = XML::Mini::Document->new();
    my $newDocRoot = $newDoc->getRoot();


    my $xmlHeader = $newDocRoot->header('xml');
    $xmlHeader->attribute('version', '1.0');
    $xmlHeader->attribute('encoding', 'UTF-8');


    my $completeNode = $newDocRoot->createChild('complete');
    
    if ( $posStart != 0   ) {
        $completeNode->attribute('add', "true");
    }


   $count = $count + 1;
   $posStart = $posStart + 1;
   
   my $sql_filters =  ' AND ' . $column_to_search . ' LIKE \'%'.$mask.'%\' ';
   my $sql_ordering = ' ORDER BY '.$primaryKey.' DESC';
   
   
   my $strSQL = '; WITH results AS (
            SELECT 
                rowNo = ROW_NUMBER() OVER( '.$sql_ordering.' ), *
            FROM '.$tableName.' WHERE 1=1 '.$sql_filters.'
    ) 
    SELECT * 
        FROM results
        WHERE rowNo BETWEEN '.$posStart.' AND '. $posStart. ' + '.$count.'';

   my $sth = $dbh->prepare( $strSQL, );
   #$completeNode->attribute('sql', $strSQL);
   $sth->execute( ) or MAP::API->fail( $sth->errstr );
   
   while ( my $record = $sth->fetchrow_hashref())
   {
        my $optionNode = $completeNode->createChild('option');
		$optionNode->text( $record->{$column_to_search} );
		$optionNode->attribute('value', $record->{$value_column});
    }
   
   #$dbh->disconnect();
   

   
    header('Access-Control-Allow-Origin' => request->header("Origin"));
	header('Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS');
	header('Keep-Alive' => 'timeout=2, max=100');
	header('Connection' => 'Keep-Alive');
	header('Cache-Control' => 'max-age=0, must-revalidate, no-cache, no-store');
	header('Vary' => 'Accept-Encoding');
	header('X-Server-Time' => time);
	header('X-Server' => 'Twiggy');
	header('Expires' => 'Thu, 01 Jan 1970 00:00:00');
	header('X-FRAME-OPTIONS' => 'DENY');
	header('X-XSS-Protection' => '1; mode=block');
    header('Content-Type' => 'text/xml');
    
    return $newDoc->toString();
};

dance;