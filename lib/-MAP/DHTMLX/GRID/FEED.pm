package MAP::DHTMLX::GRID::FEED;
use Dancer ':syntax';
use utf8;
use Encode       qw( encode );
use DBI;


our $VERSION = '0.1';


prefix '/dhtmlx/grid';

options '/feed.:format' => sub {
	MAP::API->options_header();
};


get '/feed.:format' => sub {
   
   MAP::API->check_authorization( params->{token}, request->header("Origin") );
   
   
   
   my $strColumns = params->{columns};
   my $primaryKey = params->{primary_key};
   my $tableName = params->{table_name};
   my $filterstr = params->{filter} || '{}';
   my $orderstr = params->{order} || '{}';
   my $count = params->{count} || 100;
   my $posStart = params->{posStart} || 0;
   $count = $count + 1;
   $posStart = $posStart + 1;
   my @rows;
   my @columns = split(/,/, $strColumns);
   
   my $filters =  from_json( $filterstr );
   my $sql_filters = "";
   my %filters = %{ $filters };
   foreach my $key (%filters) {
		if ( defined( $filters{$key} ) ) {
			$sql_filters = $sql_filters . " AND " . $key . " LIKE '%" . $filters{$key} . "%' ";
		}
   }
   
   my $sql_ordering = ' ORDER BY '.$primaryKey.' DESC';
   my $order =  from_json( $orderstr );
   if ( defined( $order->{orderby} ) && defined( $order->{direction} ) )
   {
		$sql_ordering = ' ORDER BY ' . $order->{orderby} . ' '. $order->{direction};
   }   
   
   
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
   $sth->execute() or MAP::API->fail( $sth->errstr );
   
   while ( my $record = $sth->fetchrow_hashref())
   {
		 my @values;
		foreach (@columns) {
			#print $_;
			if (defined($record->{$_})) {
				push @values, $record->{$_};
				#debug $record->{$_};
			}
			else
			{
				push @values, "";
			}
			
			
		} 
		
		my $row = {
			id =>	$record->{$primaryKey},
			data => [@values]
		 };
		push @rows, $row;
	}
   
   #$dbh->disconnect();
   
   if( $posStart == 0 )
	{
		$posStart = "";
	}
	else
	{
		$posStart = $posStart - 1;
	}
   
	MAP::API->normal_header();
	
	return {
		total_count => $totalCount,
		pos => $posStart,
		rows => [@rows],
		status => 'success', response => 'Succcess', sql_filters => $sql_filters, sql_ordering => $sql_ordering
	};
};




dance;
