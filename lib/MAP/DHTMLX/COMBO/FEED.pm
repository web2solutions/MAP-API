package MAP::DHTMLX::COMBO::FEED;
use Dancer ':syntax';
use utf8;
use Encode       qw( encode );
use DBI;

use XML::Mini::Document;


our $VERSION = '0.1';
#our $root_path = '/var/www/html/userhome/MAP-API/forms';

prefix '/dhtmlx/combo';

options '/feed.xml' => sub {
    MAP::API->options_header();
};


get '/feed.xml' => sub {
   
   #MAP::API->check_authorization( params->{token}, request->header("Origin") );
   

   my $primaryKey = params->{primary_key};
   my $tableName = params->{table_name};

   my $count = params->{count} || 20;
   my $posStart = params->{pos} || 0;
   my $mask = params->{mask} || 0;
   my $column_to_search = params->{column_to_search};
   my $value_column = params->{value_column} || $primaryKey;
   

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
   
   my $sql_filters =  ' AND ' . $column_to_search . ' LIKE \'%' . $mask . '%\' ';
   my $sql_ordering = ' ORDER BY '.$primaryKey.' DESC';
   
   my $dbh = MAP::API->dbh();
   my $totalCount = 0;
   my $sth = $dbh->prepare( "SELECT COUNT(".$primaryKey.") as total_count FROM ".$tableName." WHERE 1=1 $sql_filters;", );
   $sth->execute() or MAP::API->fail( $sth->errstr );
   
   while ( my $record = $sth->fetchrow_hashref())
   {
        $totalCount = $record->{"total_count"};
    }
   
   my $strSQL = '; WITH results AS (
            SELECT 
                rowNo = ROW_NUMBER() OVER( '.$sql_ordering.' ), *
            FROM '.$tableName.' WHERE 1=1 '.$sql_filters.'
    ) 
    SELECT * 
        FROM results
        WHERE rowNo BETWEEN '.$posStart.' AND '. $posStart. ' + '.$count.'';

   $sth = $dbh->prepare( $strSQL, );
   #$completeNode->attribute('sql', $strSQL);
   $sth->execute() or MAP::API->fail( $sth->errstr );
   
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