package MAP::Forms::Options;
use Dancer ':syntax';
use Dancer::Plugin::REST;

use Encode       qw( encode decode );
use DBI;
use Data::Dump qw(dump);



our $VERSION = '0.1';
our $collectionName = 'options';
our $primaryKey = 'option_id';
our $tableName = 'formmaker_fieldoptions';
our $defaultColumns = 'page_id,option_id,field_id,type,type_standard,name,label,asdefault,caption,tooltip,text_size,required,className,mask_to_use,value,info,note,index,FieldOptionSeq,optionname,text,use_library,library_field_id';

our $relationalColumn = 'field_id';

prefix '/forms/:id/pages/:page_id/fields/:' . $relationalColumn . '';

# routing OPTIONS header
options '/'.$collectionName.'.:format' => sub {
	MAP::API->options_header();
};

options '/'.$collectionName.'/:'.$primaryKey.'.:format' => sub {
	MAP::API->options_header();
};

options '/'.$collectionName.'/order.:format' => sub {
	MAP::API->options_header();
};
# routing OPTIONS header

get '/'.$collectionName.'.:format' => sub {
   
   MAP::API->check_authorization( params->{token}, request->header("Origin") );
   
   my $strColumns = params->{columns} || $defaultColumns;
   my @columns = split(/,/, $strColumns);
   $strColumns = MAP::API->normalizeColumnNames( $strColumns, $defaultColumns );
   
   my $relational_id = undef;
   if ( defined(  $relationalColumn ) ) {
		$relational_id = params->{$relationalColumn} || MAP::API->fail( $relationalColumn . '  is missing on url' );
   }
   
   # ------ Filtering and Ordering -------------------
   my $filterstr = params->{filter} || '{}';
   my $orderstr = params->{order} || '{}';
   my $filters =  from_json( $filterstr );
   my $sql_filters = "";
   
   my %filters = %{ $filters };
   foreach my $key (%filters) {
		if ( defined( $filters{$key} ) ) {
			$sql_filters = $sql_filters . " AND [" . $key . "] LIKE '%" . $filters{$key} . "%' ";
		}
   }
   
   my $sql_ordering = ' ORDER BY ['.$primaryKey.'] DESC';
   my $order =  from_json( $orderstr );
   if ( defined( $order->{orderby} ) && defined( $order->{direction} ) )
   {
		$sql_ordering = ' ORDER BY [' . $order->{orderby} . '] '. $order->{direction};
   }
   # ------ Filtering and Ordering -------------------
   
   my $dbh = MAP::API->dbh();
   
   my $strSQLstartWhere = '1 = 1';
   if ( defined(  $relationalColumn ) ) {
		$strSQLstartWhere = ' ['.$relationalColumn.'] IN ('.$relational_id.') ';
   }

   my $strSQL = 'SELECT '.$strColumns.' FROM '.$tableName.' WHERE '.$strSQLstartWhere.' ' . $sql_filters . ' '. $sql_ordering . '';
   my $sth = $dbh->prepare( $strSQL, );
   $sth->execute(  )  or MAP::API->fail( $sth->errstr );
   
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
	
	# ===== especific
	my $form_id  = params->{id} || MAP::API->fail( "id is missing on url" );
	my $agency_id = params->{agency_id} || MAP::API->fail( "please provide agency_id" );
	# ===== especific	
	
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
			if ( defined( $hash{$key} ) )
			{
				if ( index($defaultColumns, $key) != -1 )
				{
					if ( $key ne $primaryKey) {
						# avoid repeated column names
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
	
	
	
   
    my $dbh = MAP::API->dbh();
	
	
	
	# ===== especific
	my $total_names = 0;
	my $formname = undef;
	my $strSQLquery = 'SELECT formname FROM formmaker_properties WHERE form_id = ?';
	my $sth = $dbh->prepare( $strSQLquery, );
	$sth->execute( $form_id ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLquery );
	while ( my $record = $sth->fetchrow_hashref()) 
	{
		$formname = $record->{formname} ;
	}
	
	if (defined($hash{type})) {
		if ( $hash{type} ne '') {
			my $strSQLtable = '
				IF NOT EXISTS(SELECT * FROM sys.columns 
					WHERE [name] = N\''.$hash{name}.'\' AND [object_id] = OBJECT_ID(N\'formmaker_'.$agency_id .'_'.$formname.'\'))
				BEGIN
					ALTER TABLE dbo.formmaker_'.$agency_id .'_'.$formname.' ADD ['.$hash{name}.'] varchar(MAX);
				END
			';
			$sth = $dbh->prepare( $strSQLtable, );
			$sth->execute( ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLtable );
		}
	}
	
	 
	# ===== especific
	
	
	
	my $strSQL = 'INSERT INTO
		'.$tableName.'(' . substr($sql_columns, 0, -2) . ') 
		VALUES(' . substr($sql_placeholders, 0, -2) . ');
		SELECT SCOPE_IDENTITY() AS '.$primaryKey.';
	';
	$sth = $dbh->prepare( $strSQL, );
	$sth->execute( @sql_values ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQL . " ------------ " . dump(@sql_values)); 
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
	
	# ===== especific
	my $form_id  = params->{id} || MAP::API->fail( "id is missing on url" );
	my $agency_id = params->{agency_id} || MAP::API->fail( "please provide agency_id" );
	# ===== especific
	
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
	
	# ===== especific
	my @IDs = split(/,/, $item_id);
	for(@IDs)
	{
		my $formname = undef;
		my $strSQLquery = 'SELECT form_id, formname FROM formmaker_properties WHERE [form_id] = ' . $form_id;
		my $sth = $dbh->prepare( $strSQLquery, );
		$sth->execute(  ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLquery );
		while ( my $record = $sth->fetchrow_hashref()) 
		{
			$formname = $record->{formname};
		}
		
		my $field_name = undef;
		my $field_type = undef;
		$strSQLquery = 'SELECT option_id, name, type FROM ' . $tableName . ' WHERE ['.$primaryKey.'] = ' . $_;
		$sth = $dbh->prepare( $strSQLquery, );
		$sth->execute(  ) or MAP::API->fail( $sth->errstr . " --------- ". $strSQLquery );
		while ( my $record = $sth->fetchrow_hashref()) 
		{
			$field_name = $record->{name};
			$field_type = $record->{name};
		}
		
		if ( defined( $field_type ) ) {
			if ( $field_type ne '') {
				my $strSQLtable = '
					IF NOT EXISTS(SELECT * FROM sys.columns 
						WHERE [name] = N\''.$field_name.'\' AND [object_id] = OBJECT_ID(N\'formmaker_'.$agency_id .'_'.$formname.'\'))
					BEGIN
						ALTER TABLE dbo.formmaker_'.$agency_id .'_'.$formname.' ADD ['.$field_name.'] varchar(MAX);
					END
				';
				$sth = $dbh->prepare( $strSQLtable, );
				$sth->execute(  ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLtable );
			}
		}
	}
	# ===== especific
	
	
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
	my $dbh = MAP::API->dbh();
	my $strSQL = 'DELETE FROM '.$tableName.' WHERE ['.$primaryKey.'] IN ('.$str_id.')';
	my $sth = $dbh->prepare( $strSQL, );
	$sth->execute( ) or MAP::API->fail( $sth->errstr . "   ----   ". $strSQL );
	MAP::API->normal_header();
	return {
		status => 'success', response => 'Item(s) '.$str_id.' deleted from '.$collectionName.'', sql => $strSQL, ''.$primaryKey.'' => $str_id
	};
};


get '/'.$collectionName.'/:'.$primaryKey.'.:format' => sub {
   
   MAP::API->check_authorization( params->{token}, request->header("Origin") );
   
   my $strColumns = params->{columns} || $defaultColumns;  
   my $str_id  = params->{$primaryKey} || MAP::API->fail( "id is missing on url" );
   
   my $dbh = MAP::API->dbh();

   my $strSQL = 'SELECT '.$strColumns.' FROM '.$tableName.' WHERE '.$primaryKey.' = ?';
   my $sth = $dbh->prepare( $strSQL, );
   $sth->execute( $str_id ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQL );
   
	#$dbh->disconnect();
   MAP::API->normal_header();
   return {
		   status => 'success',
		   response => 'Succcess',
		   hash => $sth->fetchrow_hashref(),
		   sql =>  $strSQL
   };
};


# HELPERS
#/forms/2975/pages/1111/fields/0000/options/order.json
# order item on collection
post '/'.$collectionName.'/order.:format' => sub {
   
    MAP::API->check_authorization( params->{token}, request->header("Origin") );
	
	my $hashStr = params->{hash} || '{}';
	my $hash =  from_json( $hashStr );
	my $ordering_column_name = $hash->{ordering_column_name};	
	my $data = $hash->{data};

	my $dbh = MAP::API->dbh();
	
	for(@$data)
	{
		my $item_id = $_->{item_id};
		my $index = $_->{index} || 0;

		my $strSQL = 'UPDATE '.$tableName.' SET [' . $ordering_column_name . '] = ? WHERE ['.$primaryKey.'] = ?';
		my $sth = $dbh->prepare( $strSQL, );
		$sth->execute( $index, $item_id ) or MAP::API->fail( $sth->errstr . " --- " . $strSQL ); 
	}


	MAP::API->normal_header();
	return {
		status => 'success',
		response => '' . $collectionName . ' ordered',
		#sql => $strSQL
	};
};
dance;