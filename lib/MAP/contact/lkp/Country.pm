package MAP::contact::lkp::Country;
use Dancer ':syntax';
use Dancer::Plugin::REST;

use Encode qw( encode decode );
use Deep::Encode;
use DBI;
use Data::Dump qw(dump);


our $VERSION = '0.1';
my $collectionName = 'countries';
my $primaryKey = 'CountryID';
my $tableName = 'lkpCountry';
my $defaultColumns = 'CountryID,CountryText,isHagueCountry,isStateFinalizationRequired';
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

get '/'.$collectionName.'.:format' => sub {
   
   MAP::API->check_authorization( params->{token}, request->header("Origin") );
   
   my $strColumns = params->{columns} || $defaultColumns;
   $strColumns=~ s/'//g;
   my @columns = split(/,/, $strColumns);
   $strColumns = MAP::API->normalizeColumnNames( $strColumns, $defaultColumns );
   

#  $value_column =~ s/[^\w\d.-]+//;
   
   my $relational_id = undef;
   if ( defined(  $relationalColumn ) ) {
		$relational_id = params->{$relationalColumn} || MAP::API->fail( $relationalColumn . '  is missing on url' );
		$relational_id=~ s/'//g;
   }
   
   # ------ Filtering and Ordering -------------------
   my $filterstr = params->{filter} || '{}';
   my $orderstr = params->{order} || '{}';
   my $filters =  from_json( $filterstr );
   my $sql_filters = "";

   my $filter_operator = params->{filter_operator} || 'and';
   $filter_operator=~ s/[^\w\d.-]+//;
   
   my %filters = %{ $filters };
   foreach my $key (%filters) {
		if ( defined( $filters{$key} ) ) {
			my $string = $filters{$key};
			$string=~ s/'//g;
			my $column = $key;
            $column=~ s/[^\w\d.-]+//;
			$sql_filters = $sql_filters . " " . $column . " LIKE '%" . $string . "%'  ". $filter_operator ."  ";
		}
   }
	
	if ( length($sql_filters) > 1 ) {
		$sql_filters = ' AND ( '.  substr($sql_filters, 0, -5) . ' )';
	}
	
	
   
   my $sql_ordering = ' ORDER BY '.$primaryKey.' ASC';
   my $order =  from_json( $orderstr );
   if ( defined( $order->{orderby} ) && defined( $order->{direction} ) )
   {
		my $column = $order->{orderby};
		$column=~ s/[^\w\d.-]+//;
		my $direction = $order->{direction};
		$direction=~ s/[^\w\d.-]+//;
		$sql_ordering = ' ORDER BY ' . $column . ' '. $direction ;
   }
   # ------ Filtering and Ordering -------------------
   
   my $dbh = MAP::API->dbh();

   my $strSQLstartWhere = ' 1 = 1 ';
   if ( defined(  $relationalColumn ) ) {
		$strSQLstartWhere = '( ['.$relationalColumn.'] IN ('.$relational_id.') ) ';
   }
   
	my $strSQL = '';
	if ( length($strSQLstartWhere) < 3 && length($sql_filters) < 3 ) {
		$strSQL = 'SELECT '.$strColumns.' FROM '.$tableName.' '. $sql_ordering . '';
	}
	else
	{
		$strSQL = 'SELECT '.$strColumns.' FROM '.$tableName.' WHERE '.$strSQLstartWhere.' ' . $sql_filters . ' '. $sql_ordering . '';
	}
	
   
	my $sth = $dbh->prepare( $strSQL, );
   $sth->execute() or MAP::API->fail( $sth->errstr . ' ----------- '.$strSQL);
   
   my @records;
   while ( my $record = $sth->fetchrow_hashref()) 
   {
		#push @records, $record;
		my @values;
		my $row = {
			id =>	$record->{$primaryKey},
		};
		foreach (@columns)
		{
			if (defined($record->{$_})) {
				push @values, decode('UTF-8', $record->{$_});
				$row->{$_} = decode('UTF-8', $record->{$_});
			}
			else
			{
				push @values, "";
				$row->{$_} = "";
			}
		}
		$row->{data} = [@values];
		push @records, $row;
   }
	#$dbh->disconnect();
   MAP::API->normal_header();
   return {
		   status => 'success',
		   response => 'Succcess',
		   ''.$collectionName.'' => [@records],
		   sql =>  $strSQL,
		   sql_filters => $sql_filters,
		   sql_ordering => $sql_ordering
   };
};



# create form
post '/'.$collectionName.'.:format' => sub {
   
    MAP::API->check_authorization( params->{token}, request->header("Origin") );
	
	#$defaultColumns = MAP::API->normalizeColumnNames( $defaultColumns, $defaultColumns );
	
	my $hashStr = params->{hash} || '{}';
	my $agency_id = params->{agency_id} || MAP::API->fail( "please provide agency_id" );
	my $json_bytes = encode('UTF-8', $hashStr);
	my $hash = JSON->new->utf8->decode($json_bytes) or MAP::API->fail( "unable to decode" );
	#my $hash =  from_json( $hashStr );
	my $sql_columns = "";
	my $sql_placeholders = "";
	my @sql_values;
    
	my %hash = %{ $hash };

	
	my $dbh = MAP::API->dbh();

	
	foreach my $key (%hash)
	{
		if ( defined( $key ) )
		{
			if ( defined( $hash{$key} ) )
			{
				if ( index($defaultColumns, $key) != -1 )
				{
					if ( $key ne $primaryKey) {
						if ( index($sql_columns, '[' .$key.']') < 0 )
						{
							$sql_columns = $sql_columns .'[' .$key.'], ';
							$sql_placeholders  = $sql_placeholders . '?, ';
							push @sql_values, $hash{$key};
						}
					}
				}
			}
		}
    }
	
	my $strSQL = 'INSERT INTO
		'.$tableName.'(' . substr($sql_columns, 0, -2) . ') 
		VALUES(' . substr($sql_placeholders, 0, -2) . ');
		SELECT SCOPE_IDENTITY() AS '.$primaryKey.';
	';
	my $sth = $dbh->prepare( $strSQL, );
	$sth->execute( @sql_values ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQL ); 
	my $record_id = 0;
	while ( my $record = $sth->fetchrow_hashref()) 
	{
		$record_id = $record->{$primaryKey};
	}
	

	MAP::API->normal_header();
	return {
		status => 'success',
		response => 'Item '.$record_id.' added on ' . $collectionName,
		sql => $strSQL,
		''.$primaryKey.'' => $record_id,
		place_holders_dump => dump(@sql_values)
	};
};

# update form
put '/'.$collectionName.'/:'.$primaryKey.'.:format' => sub {
   
    MAP::API->check_authorization( params->{token}, request->header("Origin") );
   
    my $item_id  = params->{$primaryKey} || MAP::API->fail( "id is missing on url" );
	$item_id=~ s/'//g;
	my $agency_id = params->{agency_id} || MAP::API->fail( "please provide agency_id" );
	#$defaultColumns = MAP::API->normalizeColumnNames( $defaultColumns, $defaultColumns );
	
	my $hashStr = params->{hash} || '{}';
	my $json_bytes = encode('UTF-8', $hashStr);
	my $hash = JSON->new->utf8->decode($json_bytes) or MAP::API->fail( "unable to decode" );
	#my $hash =  from_json( $hashStr );
	my $sql_setcolumns = "";
	my $sql_placeholders = "";
	my @sql_values;
    
	my %hash = %{ $hash };
    foreach my $key (%hash)
	{
		if ( defined( $hash{$key} ) )
		{
			if ( index(MAP::API->normalizeColumnNames( $defaultColumns, $defaultColumns ), '['.$key.']') != -1 )
			{
				if ( $key ne $primaryKey) {
					if ( index($sql_setcolumns, '[' .$key.']') < 0 )
					{
						$sql_setcolumns = $sql_setcolumns .'['. $key .'] = ?, ';
						push @sql_values, $hash{$key};
					}
				}
			}
		}
    }
   
    my $dbh = MAP::API->dbh();
	my $strSQL = 'UPDATE '.$tableName.' SET ' . substr($sql_setcolumns, 0, -2) . ' WHERE ['.$primaryKey.'] IN ('.$item_id.')';
	my $sth = $dbh->prepare( $strSQL, );
	$sth->execute( @sql_values ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQL . " --- " . dump(@sql_values) . " ----- " . $item_id );
	

	MAP::API->normal_header();
	return {
		status => 'success',
		response => 'Item '.$item_id.' updated on ' . $collectionName,
		sql => $strSQL,
		''.$primaryKey.'' => $item_id,
		place_holders_dump => dump(@sql_values)
	};
};


del '/'.$collectionName.'/:'.$primaryKey.'.:format' => sub {
    MAP::API->check_authorization( params->{token}, request->header("Origin") );
	
    my $str_id  = params->{$primaryKey} || MAP::API->fail( "id is missing on url" );
	$str_id=~ s/'//g;
	my $agency_id = params->{agency_id} || MAP::API->fail( "please provide agency_id" );
	my $dbh = MAP::API->dbh();
	
	
	
	my $strSQL = 'DELETE FROM '.$tableName.' WHERE ['.$primaryKey.'] IN ('.$str_id.')';
	my $sth = $dbh->prepare( $strSQL, );
	$sth->execute( ) or MAP::API->fail( $sth->errstr . "   ----   ". $strSQL );
	
	
	MAP::API->normal_header();
	return {
		status => 'success',
		response => 'Item(s) '.$str_id.' deleted from '.$collectionName.'',
		sql => $strSQL,
		''.$primaryKey.'' => $str_id
	};
};


get '/'.$collectionName.'/:'.$primaryKey.'.:format' => sub {
   
   MAP::API->check_authorization( params->{token}, request->header("Origin") );
   
   my $strColumns = params->{columns} || $defaultColumns;  
   my $str_id  = params->{$primaryKey} || MAP::API->fail( "id is missing on url" );
	$str_id=~ s/'//g;
   # ===== especific
   my $agency_id = params->{agency_id} || MAP::API->fail( "please provide agency_id" );
   
   my $dbh = MAP::API->dbh();
	
	my $strSQL = 'SELECT '.$strColumns.' FROM '.$tableName.' WHERE '.$primaryKey.' = ?';
	my $sth = $dbh->prepare( $strSQL, );
	$sth->execute( $str_id ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQL );
   
	#$dbh->disconnect();
   MAP::API->normal_header();
   use Data::Recursive::Encode;
   return {
		   status => 'success',
		   response => 'Succcess',
		   hash => Data::Recursive::Encode->decode_utf8( $sth->fetchrow_hashref() ),
		   sql =>  $strSQL
   };
};
dance;