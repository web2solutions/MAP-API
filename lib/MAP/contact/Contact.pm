package MAP::contact::Contact;
use Dancer ':syntax';
use XML::Mini::Document;
use Dancer::Plugin::REST;

use Encode qw( encode decode );
use Deep::Encode;
use DBI;
use Data::Dump qw(dump);

use MAP::contact::address::Address;
use MAP::contact::education::Education;
use MAP::contact::email::Email;
use MAP::contact::phone::Phone;

use MAP::contact::culture::Culture;
use MAP::contact::ethnicity::Ethnicity;
use MAP::contact::language::Language;
use MAP::contact::nationality::Nationality;
use MAP::contact::race::Race;
use MAP::contact::religion::Religion;

use MAP::contact::DHTMLX::COMBO::FEED;

use MAP::contact::marital::History;

use MAP::contact::lkp::States;
use MAP::contact::lkp::County;
use MAP::contact::lkp::Country;
use MAP::contact::lkp::AddressType;
use MAP::contact::lkp::AddressProvince;
use MAP::contact::lkp::Religions;
use MAP::contact::lkp::Nationality;
use MAP::contact::lkp::Language;
use MAP::contact::lkp::Culture;
use MAP::contact::lkp::Ethnicity;
use MAP::contact::lkp::Races;

use MAP::contact::lkp::TermReason;
use MAP::contact::lkp::MaritalStatus;


use MAP::contact::relationship::Relationship;
use MAP::contact::relationship::EmployerSearch;
use MAP::contact::relationship::RelationshipType;
use MAP::contact::relationship::RelationshipSubType;
use MAP::contact::relationship::ComponentConfiguration;



our $VERSION = '0.1';
my $collectionName = 'contact';
my $primaryKey = 'ContactId';
my $storedProcedureName= 'usp_ContactList';
my $defaultColumns = 'ContactId,FName,MName,LName,Nickname,BirthName,BirthDate,Gender,SSN,PlaceOfBirthCity,PlaceOfBirthStateId,PlaceOfBirthCountryId,DateOfDeath,DoNotSendMail,BusName,ContactNotes,LicenceNumber,FEIDNumber,ContactTypeId';
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


#any '/'.$collectionName.'.:format' => sub {
#    send_error("Hey Mark, it is not implemented yet", 501);
#};




# routing OPTIONS header


get '/'.$collectionName.'.:format' => sub {

   MAP::API->check_authorization( params->{token}, request->header("Origin") );

   my $dbh = MAP::API->dbh();

   my $strColumns = params->{columns} || $defaultColumns;
   my @columns = split(/,/, $strColumns);
   $strColumns = $dbh->quote( MAP::API->normalizeColumnNames( $strColumns, $defaultColumns ) );


   # ------ Filtering and Ordering -------------------
   my $filterstr = params->{filter} || '{}';
   my $orderstr = params->{order} || '{}';
   my $filters =  from_json( $filterstr );
   my $sql_filters = "";

   my $filter_operator = params->{filter_operator} || 'and';
   $filter_operator = $dbh->quote( $filter_operator );

   my $newDoc = XML::Mini::Document->new();
   my $newDocRoot = $newDoc->getRoot();
   #my $xmlHeader = $newDocRoot->header('xml');
   my $FilterNode = $newDocRoot->createChild('Filter');
   my %filters = %{ $filters };
   foreach my $key (%filters) {
		if ( defined( $filters{$key} ) ) {
			#$sql_filters = $sql_filters . " AND [" . $dbh->quote( $key ) . "] LIKE '%" . $dbh->quote( $filters{$key} ) . "%' ";
				my $ValuesNode = $FilterNode->createChild('Values');
						my $ColumnNameNode = $ValuesNode->createChild('ColumnName');
						$ColumnNameNode->text( $key );

						my $ColumnValueNode = $ValuesNode->createChild('ColumnValue');
						$ColumnValueNode->text( $filters{$key} );
		}
   }
   my $string_xml_filter =  $newDoc->toString();

   debug $string_xml_filter;

   my $sql_ordering = ' @order_by = \'' . $primaryKey . '\', @order_direction = \'ASC\', ';
   my $order =  from_json( $orderstr );
   if ( defined( $order->{orderby} ) && defined( $order->{direction} ) )
   {
		#$sql_ordering = ' ORDER BY [' . $order->{orderby} . '] '. $order->{direction};
		$sql_ordering = ' @order_by = ' . $dbh->quote( $order->{orderby} ) . ', @order_direction = '. $dbh->quote( $order->{direction} ).', ';
   }
   # ------ Filtering and Ordering -------------------




# exec usp_ContactList '.$sql_ordering.' @filter_operator = \''. $filter_operator .'\', @columns = 'ContactId,FName,LName,SSN' ,@filter = '<Filter> <Values> <ColumnName>Fname</ColumnName> <ColumnValue>br</ColumnValue> </Values> <Values> <ColumnName>Lname</ColumnName> <ColumnValue>Smith</ColumnValue> </Values> </Filter>'

   my $strSQL = 'EXEC '.$storedProcedureName.' '.$sql_ordering.' @filter_operator = '. $filter_operator .', @filter= \''.$string_xml_filter.'\', @columns=  '. $strColumns .' ';

   my $sth = $dbh->prepare( $strSQL, );
   $sth->execute() or MAP::API->fail( $sth->errstr . "   ---   " . $strSQL );

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
		   filter_operator =>  $filter_operator,
		   xml_filters => $string_xml_filter,
		   sql_ordering => $sql_ordering
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

get '/'.$collectionName.'/:'.$primaryKey.'.:format' => sub {

   MAP::API->check_authorization( params->{token}, request->header("Origin") );

   my $dbh = MAP::API->dbh();

   my $strColumns = params->{columns} || $defaultColumns;
   $strColumns = $dbh->quote( MAP::API->normalizeColumnNames( $strColumns, $defaultColumns ) );

   my $str_id  = params->{$primaryKey} || MAP::API->fail( "id is missing on url" );

   my $newDoc = XML::Mini::Document->new();
   my $newDocRoot = $newDoc->getRoot();
   #my $xmlHeader = $newDocRoot->header('xml');
   my $FilterNode = $newDocRoot->createChild('Filter');

   my $ValuesNode = $FilterNode->createChild('Values');
		my $ColumnNameNode = $ValuesNode->createChild('ColumnName');
		$ColumnNameNode->text( 'ContactId');
		my $ColumnValueNode = $ValuesNode->createChild('ColumnValue');
		$ColumnValueNode->text( $str_id );

   my $string_xml_filter =  $newDoc->toString();

   my $strSQL = 'EXEC '.$storedProcedureName.' @filter= \''.$string_xml_filter.'\', @columns=  '. $strColumns .' ';

   #my $strSQL = 'SELECT '.$strColumns.' FROM '.$storedProcedureName.' WHERE '.$primaryKey.' = ?';
   my $sth = $dbh->prepare( $strSQL, );
   $sth->execute(  ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQL );

	#$dbh->disconnect();
   MAP::API->normal_header();
   return {
		   status => 'success',
		   response => 'Succcess',
		   hash => $sth->fetchrow_hashref(),
		   xml_filters => $string_xml_filter,
		   sql =>  $strSQL
   };


};

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

options '/'.$collectionName.'/search/:UserConnId.:format' => sub {
	MAP::API->options_header();
};

get '/'.$collectionName.'/search/:UserConnId.:format' => sub {

   MAP::API->check_authorization( params->{token}, request->header("Origin") );

   my $dbh = MAP::API->dbh();

   my $strColumns = params->{columns} || 'RowID,FullName,IsBusiness,PhoneNumber,ContactId';
   my @columns = split(/,/, $strColumns);
   $strColumns = $dbh->quote( MAP::API->normalizeColumnNames( $strColumns, $defaultColumns ) );

   my @values;
   my $strSQLappend = '';
   my $UserConnId = params->{UserConnId}  || MAP::API->fail( "UserConnId is missing on url" );
   if ( defined( $UserConnId ) ) {
		$strSQLappend = $strSQLappend . ' @UserConnId = ?, ';
		push @values, $UserConnId;
   }

   my $SearchLName = params->{SearchLName} ;
   if ( defined( $SearchLName ) ) {
		$strSQLappend = $strSQLappend . ' @SearchLName = ?, ';
		push @values, $SearchLName;
   }

   my $SearchMName= params->{SearchMName} ;
   if ( defined( $SearchMName ) ) {
		$strSQLappend = $strSQLappend . ' @SearchMName = ? ';
		push @values, $SearchMName;
   }

   my $SearchFName = params->{SearchFName} ;
   if ( defined( $SearchFName ) ) {
		$strSQLappend = $strSQLappend . ' @SearchFName = ? ';
		push @values, $SearchFName;
   }

   my $SearchBusName = params->{SearchBusName} ;
   if ( defined( $SearchBusName ) ) {
		$strSQLappend = $strSQLappend . ' @SearchBusName = ? ';
		push @values, $SearchBusName;
   }


   my $StrtRow = params->{StrtRow} || 0;
   $strSQLappend = $strSQLappend . ' @StrtRow = ?, ';
   push @values, $StrtRow;

   my $Count = params->{Count} || 300;
   $strSQLappend = $strSQLappend . ' @Count = ?';
   push @values, $Count;



   my $strSQL = 'EXEC usp_ContactDuplicateSearch ' . $strSQLappend;

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
		   sql =>  $strSQL,
   };
};


options '/'.$collectionName.'/search/couple/:CoupleConnId.:format' => sub {
	MAP::API->options_header();
};

get '/'.$collectionName.'/search/couple/:CoupleConnId.:format' => sub {

   MAP::API->check_authorization( params->{token}, request->header("Origin") );

   #$defaultColumns = 'ContactId1,ContactId2';

   my $dbh = MAP::API->dbh();

   my $strColumns = params->{columns} || 'ContactId1,ContactId2';
   my @columns = split(/,/, $strColumns);
   $strColumns = $dbh->quote( MAP::API->normalizeColumnNames( $strColumns, $defaultColumns ) );

   my @values;
   my $strSQLappend = '';
   my $CoupleConnId= params->{CoupleConnId}  || MAP::API->fail( "CoupleConnId is missing on url" );
   if ( defined( $CoupleConnId ) ) {
		$strSQLappend = $strSQLappend . ' @CoupleConnId = ?, ';
		push @values, $CoupleConnId;
   }





   my $strSQL = 'EXEC usp_CoupleContactIds ' . $strSQLappend;

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
		   sql =>  $strSQL,
   };
};



options '/'.$collectionName.'/search/couple/another/:ContactId.:format' => sub {
	MAP::API->options_header();
};
# This SP send back the other person of the current couple of the
# contactid sent in. A 0 is returned if no other person in the current couple.
get '/'.$collectionName.'/search/couple/another/:ContactId.:format' => sub {

   MAP::API->check_authorization( params->{token}, request->header("Origin") );

   #$defaultColumns = 'ContactId1,ContactId2';

   my $dbh = MAP::API->dbh();

   my $strColumns = params->{columns} || 'OtherContactId';
   my @columns = split(/,/, $strColumns);
   $strColumns = $dbh->quote( MAP::API->normalizeColumnNames( $strColumns, $defaultColumns ) );

   my @values;
   my $strSQLappend = '';
   my $ContactId= params->{ContactId}  || MAP::API->fail( "ContactId is missing on url" );
   if ( defined( $ContactId ) ) {
		$strSQLappend = $strSQLappend . ' @ContactId = ?, ';
		push @values, $ContactId;
   }





   my $strSQL = 'EXEC usp_OtherCoupleContactId ' . $strSQLappend;

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
		   sql =>  $strSQL,
   };
};
dance;
