package MAP::contact::relationship::Relationship;
use Dancer ':syntax';
use XML::Mini::Document;
use Dancer::Plugin::REST;
use Encode qw( encode decode );
use Data::Dump qw(dump);



our $VERSION = '0.1';
my $collectionName = 'relationship';
my $primaryKey = 'PrimaryConnId';
my $storedProcedureName= 'usp_RelationshipGridList';
my $defaultColumns = 'PrimaryConnId,PrimaryName,RelConnId,RelName,RelationshipSubTypeId,RelationshipSubTypeText,ConnectionId1,RelTypeid1,RelTypeText1,RelStDate,RelEndDate';







my $root_path = '/var/www/html/userhome/MAP-API/'.$collectionName;

my $relationalColumn = undef; # undef

prefix '/contact';

# routing OPTIONS header
options '/'.$collectionName.'.:format' => sub {
	MAP::API->options_header();
};

options '/'.$collectionName.'/:'.$primaryKey.'.:format' => sub {
	MAP::API->options_header();
};

options '/'.$collectionName.'/couple/list.:format' => sub {
	MAP::API->options_header();
};

options '/'.$collectionName.'/employer/list.:format' => sub {
	MAP::API->options_header();
};




# routing OPTIONS header


get '/'.$collectionName.'.:format' => sub {

   MAP::API->check_authorization( params->{token}, request->header("Origin") );

   my $dbh = MAP::API->dbh();

   my $strColumns = params->{columns} || $defaultColumns;
   my @columns = split(/,/, $strColumns);
   $strColumns = $dbh->quote( MAP::API->normalizeColumnNames( $strColumns, $defaultColumns ) );


# 		@ConnId int 		,@ConnectionId int  = 0
# ,@RelationshipSubTypeIds varchar(500) = '' 		,@RelationsshipTypeIds varchar(500) = ''
   my @values;
   my $strSQLappend = '';
   my $ConnId = params->{ConnId} ;
   if ( defined( $ConnId ) ) {
		$strSQLappend = $strSQLappend . ' @ConnId = ?, ';
		push @values, $ConnId;
   }

   my $ConnectionId = params->{ConnectionId};
   if ( defined( $ConnectionId ) ) {
		$strSQLappend = $strSQLappend . ' @ConnectionId = ?, ';
		push @values, $ConnectionId;
   }

   my $RelationsshipTypeIds = params->{RelationsshipTypeIds};
   if ( defined( $RelationsshipTypeIds ) ) {
		$strSQLappend = $strSQLappend . ' @RelationsshipTypeIds = '.$RelationsshipTypeIds.', ';
		push @values, $RelationsshipTypeIds;
   }

   my $RelationshipSubTypeIds = params->{RelationshipSubTypeIds};
   if ( defined( $RelationshipSubTypeIds ) ) {
		$strSQLappend = $strSQLappend . ' @RelationshipSubTypeIds = '.$RelationshipSubTypeIds.', ';
		push @values, $RelationshipSubTypeIds;
   }

   $strSQLappend = substr($strSQLappend, 0, -2);

   my $strSQL = 'EXEC '.$storedProcedureName.' '.$strSQLappend.' ';

   my $sth = $dbh->prepare( $strSQL, );
   $sth->execute( @values ) or MAP::API->fail( $sth->errstr . "   ---   " . $strSQL . "   ---   " . dump(@values) );

   my @records;
   while ( my $record = $sth->fetchrow_hashref())
   {
		#push @records, $record;
		my @values;
		my $row = {
			#id =>	$record->{$primaryKey},
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
		   values =>  dump(@values)
   };
};


get '/'.$collectionName.'/couple/list.:format' => sub {

   MAP::API->check_authorization( params->{token}, request->header("Origin") );

   $defaultColumns = 'Connid,Name';

   my $dbh = MAP::API->dbh();

   my $strColumns = params->{columns} || $defaultColumns;
   my @columns = split(/,/, $strColumns);
   $strColumns = $dbh->quote( MAP::API->normalizeColumnNames( $strColumns, $defaultColumns ) );

   my $ConnId = params->{ConnId} ;

   my $strSQL = 'EXEC usp_CoupleList @Connid = ? ';

   my $sth = $dbh->prepare( $strSQL, );
   $sth->execute( $ConnId ) or MAP::API->fail( $sth->errstr . "   ---   " . $strSQL );

   my @records;
   while ( my $record = $sth->fetchrow_hashref())
   {
		#push @records, $record;
		my @values;
		my $row = {
			#id =>	$record->{$primaryKey},
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
		   sql =>  $strSQL
   };
};



get '/'.$collectionName.'/employer/list.:format' => sub {

   MAP::API->check_authorization( params->{token}, request->header("Origin") );

   $defaultColumns = 'RowID,FullName,ConnId';

   my $dbh = MAP::API->dbh();

   my $strColumns = params->{columns} || $defaultColumns;
   my @columns = split(/,/, $strColumns);
   $strColumns = $dbh->quote( MAP::API->normalizeColumnNames( $strColumns, $defaultColumns ) );

   my @values;
   my $strSQLappend = '';
   my $EmployerConnId = params->{EmployerConnId} ;
   if ( defined( $EmployerConnId ) ) {
		$strSQLappend = $strSQLappend . ' @EmployerConnId = ?,';
		push @values, $EmployerConnId;
   }

   my $SearchName = params->{SearchName};
   if ( defined( $SearchName ) ) {
		$strSQLappend = $strSQLappend . ' @SearchName = ?, ';
		push @values, $SearchName;
   }

   my $StrtRow = params->{StrtRow} || 0;
   $strSQLappend = $strSQLappend . ' @StrtRow = ?, ';
   push @values, $StrtRow;

   my $Count = params->{Count} || 300;
   $strSQLappend = $strSQLappend . ' @Count = ?';
   push @values, $Count;



# 	@EmployerConnId  varchar(50)    	,@SearchName varchar(500) = '' 	,@StrtRow INT =0 	,@Count INT =100

   my $strSQL = 'EXEC usp_EmployeeSearch '.$strSQLappend.' ';

   my $sth = $dbh->prepare( $strSQL, );
   $sth->execute( @values ) or MAP::API->fail( $sth->errstr . "   ---   " . $strSQL );

   my @records;
   while ( my $record = $sth->fetchrow_hashref())
   {
		#push @records, $record;
		my @values;
		my $row = {
			#id =>	$record->{$primaryKey},
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
		   sql =>  $strSQL
   };
};

# create form
post '/'.$collectionName.'.:format' => sub {

    MAP::API->check_authorization( params->{token}, request->header("Origin") );

	#$defaultColumns = MAP::API->normalizeColumnNames( $defaultColumns, $defaultColumns );

	my $hashStr = params->{hash} || '{}';
	my $json_bytes = encode('UTF-8', $hashStr);
	my $hash = JSON->new->utf8->decode($json_bytes) or MAP::API->fail( "unable to decode" );
	#my $hash =  from_json( $hashStr );
	my $sql_columns = "";
	my $sql_placeholders = "";
	my @sql_values;



	my %hash = %{ $hash };
    foreach my $key (%hash)
	{
		if ( defined( $key ) )
		{
		    $key=~ s/'//g;
			if ( defined( $hash{$key} ) )
			{
				if ( index($defaultColumns, $key) != -1 )
				{
					if ( $key ne $primaryKey) {

						if ( index($sql_columns, '@'.$key.' =') < 0 )
						{
							$sql_columns = $sql_columns .' @'.$key.' = ?, ';
							#$sql_placeholders  = $sql_placeholders . '?, ';
							push @sql_values, $hash{$key};
						}
					}
				}
			}
		}
    }

    my $dbh = MAP::API->dbh();

    #
    my $strSQL = 'exec usp_ContactInsert '.substr($sql_columns, 0, -2).'';

    #my $strSQL = 'INSERT INTO
	#	'.$storedProcedureName.'(' . substr($sql_columns, 0, -2) . ')
	#	VALUES(' . substr($sql_placeholders, 0, -2) . ');
	#	SELECT SCOPE_IDENTITY() AS '.$primaryKey.';
	#';

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
		    $key=~ s/'//g;
			if ( index(MAP::API->normalizeColumnNames( $defaultColumns, $defaultColumns ), '['.$key.']') != -1 )
			{
				if ( $key ne $primaryKey) {
					if ( index($sql_setcolumns, '@' .$key.' =') < 0 )
					{
						$sql_setcolumns = $sql_setcolumns .'@'. $key .' = ?, ';
						push @sql_values, $hash{$key};
					}
				}
			}
		}
    }

    my $dbh = MAP::API->dbh();



    my $strSQL = 'exec usp_ContactUpdate '.substr($sql_setcolumns, 0, -2).'';

    #my $strSQL = 'UPDATE '.$storedProcedureName.' SET ' . substr($sql_setcolumns, 0, -2) . ' WHERE ['.$primaryKey.'] IN ('.$item_id.')';
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
	my $dbh = MAP::API->dbh();
	my $strSQL = 'exec usp_ContactDelete  @ContactId = '. $dbh->quote( $str_id ).'';
	my $sth = $dbh->prepare( $strSQL, );
	$sth->execute( ) or MAP::API->fail( $sth->errstr . "   ----   ". $strSQL );


	MAP::API->normal_header();
	return {
		status => 'success', response => 'Item(s) '.$str_id.' deleted from '.$collectionName.'',
		sql => $strSQL,
		''.$primaryKey.'' => $str_id
	};
};

#get '/'.$collectionName.'/:'.$primaryKey.'.:format' => sub {

 #  MAP::API->check_authorization( params->{token}, request->header("Origin") );

 #  my $dbh = MAP::API->dbh();

 #  my $strColumns = params->{columns} || $defaultColumns;
 #  $strColumns = $dbh->quote( MAP::API->normalizeColumnNames( $strColumns, $defaultColumns ) );

 #  my $str_id  = params->{$primaryKey} || MAP::API->fail( "id is missing on url" );

   #my $newDoc = XML::Mini::Document->new();
   #my $newDocRoot = $newDoc->getRoot();
   #my $xmlHeader = $newDocRoot->header('xml');
   #my $FilterNode = $newDocRoot->createChild('Filter');

   #my $ValuesNode = $FilterNode->createChild('Values');
	#	my $ColumnNameNode = $ValuesNode->createChild('ColumnName');
	#	$ColumnNameNode->text( 'ContactId');
	#	my $ColumnValueNode = $ValuesNode->createChild('ColumnValue');
	#	$ColumnValueNode->text( $str_id );

   #my $string_xml_filter =  $newDoc->toString();

   #my $strSQL = 'EXEC '.$storedProcedureName.' @filter= \''.$string_xml_filter.'\', @columns=  '. $strColumns .' ';

#		my $strSQL = 'EXEC usp_RelationshipDetail @RelationshipId = ? ';

 #  my $sth = $dbh->prepare( $strSQL, );
  # $sth->execute( $str_id ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQL );

	#$dbh->disconnect();
   #MAP::API->normal_header();
   #return {
	#	   status => 'success',
	#	   response => 'Succcess',
	#	   hash => $sth->fetchrow_hashref(),
		   #xml_filters => $string_xml_filter,
	#	   sql =>  $strSQL
   #};
#};

get '/'.$collectionName.'/types/all.:format' => sub {
    MAP::API->check_authorization( params->{token}, request->header("Origin") );

	my $dbh = MAP::API->dbh();
    my $IsBusiness = params->{IsBusiness} || 0;
    $IsBusiness=~ s/'//g;
	my $strSQL = 'EXEC usp_ContactTypeList @IsBusiness = '. $IsBusiness . ';';
	my $sth = $dbh->prepare( $strSQL, );
	$sth->execute( ) or MAP::API->fail( $sth->errstr . "   ----   ". $strSQL );

   my @columns =  split(/,/, 'RelationshipTypeId,RelationshipTypeText');

   my @records;
   while ( my $record = $sth->fetchrow_hashref())
   {
		#push @records, $record;
		my @values;
		my $row = {
			#id =>	$record->{$primaryKey},
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


	MAP::API->normal_header();
	return {
		status => 'success',
		response => 'Succcess',
		'types' => [@records],
		sql =>  $strSQL
	};
};

get '/'.$collectionName.'/types/business.:format' => sub {
    MAP::API->check_authorization( params->{token}, request->header("Origin") );

	my $dbh = MAP::API->dbh();
	my $strSQL = 'EXEC usp_ContactTypeList @IsBusiness = 1;';
	my $sth = $dbh->prepare( $strSQL, );
	$sth->execute( ) or MAP::API->fail( $sth->errstr . "   ----   ". $strSQL );

   my @columns = split(/,/, 'RelationshipTypeId,RelationshipTypeText');

   my @records;
   while ( my $record = $sth->fetchrow_hashref())
   {
		#push @records, $record;
		my @values;
		my $row = {
			#id =>	$record->{$primaryKey},
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


	MAP::API->normal_header();
	return {
		status => 'success',
		response => 'Succcess',
		'types' => [@records],
		sql =>  $strSQL
	};
};

get '/'.$collectionName.'/types/person.:format' => sub {
    MAP::API->check_authorization( params->{token}, request->header("Origin") );

	my $dbh = MAP::API->dbh();
	my $strSQL = 'EXEC usp_ContactTypeList @IsBusiness = 0;';
	my $sth = $dbh->prepare( $strSQL, );
	$sth->execute( ) or MAP::API->fail( $sth->errstr . "   ----   ". $strSQL );

   my @columns = split(/,/, 'RelationshipTypeId,RelationshipTypeText');

   my @records;
   while ( my $record = $sth->fetchrow_hashref())
   {
		#push @records, $record;
		my @values;
		my $row = {
			#id =>	$record->{$primaryKey},
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


	MAP::API->normal_header();
	return {
		status => 'success',
		response => 'Succcess',
		'types' => [@records],
		sql =>  $strSQL
	};
};
dance;
