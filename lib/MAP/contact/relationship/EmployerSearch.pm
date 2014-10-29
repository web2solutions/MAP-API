package MAP::contact::relationship::EmployerSearch;
use Dancer ':syntax';

use Encode       qw( encode decode );
use XML::Mini::Document;


our $VERSION = '0.1';
#our $root_path = '/var/www/html/userhome/MAP-API/forms';

my $collectionName = 'employer';
my $primaryKey = 'ConnId';
my $storedProcedureName= 'usp_EmployeeSearch';
my $defaultColumns = 'RowID,FullName,ConnId';

prefix '/contact/relationship/search';

options '/'.$collectionName.'.xml' => sub {
    MAP::API->options_header();
};


get '/'.$collectionName.'.xml' => sub {

   MAP::API->check_authorization( params->{token}, request->header("Origin") );

   my $dbh = MAP::API->dbh();

   my $strColumns = $defaultColumns;
   my @columns = split(/,/, $strColumns);
   $strColumns = $dbh->quote( MAP::API->normalizeColumnNames( $strColumns, $defaultColumns ) );


   #my $count = params->{count} || 20;
   #my $posStart = params->{pos} || 0;

   #my $mask = params->{mask} || '';
   #$mask =~ s/'//g;

   #my $column_to_search = params->{column_to_search}  || MAP::API->fail( 'column_to_search is missing' );
   #$column_to_search =~ s/[^\w\d.-]+//;

   my $value_column = params->{value_column} || $primaryKey;
   $value_column =~ s/[^\w\d.-]+//;


   my @values;
   my $strSQLappend = '';
   my $EmployerConnId = params->{EmployerConnId} ;
   if ( defined( $EmployerConnId ) ) {
		$strSQLappend = $strSQLappend . ' @EmployerConnId = ?,';
		push @values, $EmployerConnId;
   }

   my $SearchName = params->{mask};
   if ( defined( $SearchName ) ) {
		$strSQLappend = $strSQLappend . ' @SearchName = ?,';
		push @values, $SearchName;
   }

   my $StrtRow = params->{pos} || 0;
   $strSQLappend = $strSQLappend . ' @StrtRow = ?,';
   push @values, $StrtRow;

   my $Count = params->{count} || 20;
   $strSQLappend = $strSQLappend . ' @Count = ?';
   push @values, $Count;



   # ------ Filtering and Ordering -------------------
   #my $filterstr = '{"FName" : "'.$mask.'", "MName" : "'.$mask.'", "LName" : "'.$mask.'"}';
   #my $orderstr = params->{order} || '{}';
   #my $filters =  from_json( $filterstr );
   #my $sql_filters = "";

   #my $filter_operator = 'or';
   #$filter_operator = $dbh->quote( $filter_operator );

   #my $newDocFilter = XML::Mini::Document->new();
   #my $newDocRootFilter = $newDocFilter->getRoot();
   #my $FilterNode = $newDocRootFilter->createChild('Filter');
   #my %filters = %{ $filters };
   #foreach my $key (%filters) {
#		if ( defined( $filters{$key} ) ) {
#			#$sql_filters = $sql_filters . " AND [" . $dbh->quote( $key ) . "] LIKE '%" . $dbh->quote( $filters{$key} ) . "%' ";
#				my $ValuesNode = $FilterNode->createChild('Values');
#						my $ColumnNameNode = $ValuesNode->createChild('ColumnName');
#						$ColumnNameNode->text( $key );
#
#						my $ColumnValueNode = $ValuesNode->createChild('ColumnValue');
#						$ColumnValueNode->text( $filters{$key} );
#		}
#   }
#   my $string_xml_filter =  $newDocFilter->toString();

#   my $sql_ordering = ' @order_by = \'' . $primaryKey . '\', @order_direction = \'ASC\', ';
#   my $order =  from_json( $orderstr );
#   if ( defined( $order->{orderby} ) && defined( $order->{direction} ) )
#   {
#		#$sql_ordering = ' ORDER BY [' . $order->{orderby} . '] '. $order->{direction};
#		$sql_ordering = ' @order_by = \'' . $dbh->quote( $order->{orderby} ) . '\', @order_direction = \''. $dbh->quote( $order->{direction} ).'\', ';
#   }
#   # ------ Filtering and Ordering -------------------


    my $newDoc = XML::Mini::Document->new();
    my $newDocRoot = $newDoc->getRoot();

    my $xmlHeader = $newDocRoot->header('xml');
    $xmlHeader->attribute('version', '1.0');
    $xmlHeader->attribute('encoding', 'UTF-8');


    my $completeNode = $newDocRoot->createChild('complete');

    if ( $StrtRow != 0   ) {
        $completeNode->attribute('add', "true");
    }


   #$count = $count + 1;
   #$posStart = $posStart + 1;

#EXEC usp_ContactSearchAll @SearchName = '$search_term'"

   my $strSQL = 'EXEC usp_EmployeeSearch '.$strSQLappend.' ';

   #my $strSQL = '; WITH results AS (
   #         SELECT
   #             rowNo = ROW_NUMBER() OVER( '.$sql_ordering.' ), *
   #         FROM '.$tableName.' WHERE 1=1 '.$sql_filters.'
   # )
   # SELECT *
   #     FROM results
   #     WHERE rowNo BETWEEN '.$posStart.' AND '. $posStart. ' + '.$count.'';

   my $sth = $dbh->prepare( $strSQL, );
   #$completeNode->attribute('sql', $strSQL);
   $sth->execute( @values ) or MAP::API->fail( $sth->errstr . " " . $strSQL);
   while ( my $record = $sth->fetchrow_hashref())
   {
		my $optionNode = $completeNode->createChild('option');
		$optionNode->text( $record->{FullName} );
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
