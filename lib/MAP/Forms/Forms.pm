package MAP::Forms::Forms;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use utf8;
use Encode qw( encode );
use DBI;
use Data::Dump qw(dump);
use MAP::Forms::Pages;
use MAP::Forms::Rules;
use MAP::Forms::Notifications;
use MAP::Forms::FormViewer;
use MAP::Forms::Entries;



our $VERSION = '0.1';
my $collectionName = 'forms';
my $primaryKey = 'form_id';
my $tableName = 'formmaker_properties';
my $defaultColumns = 'form_id,formlabel,formname,formtext,formindex,redirecturl,adminalert,autorespond,tiplocation,display,preview,nomultiple,captcha,key_id,form_agency_id,submissionmsg,displaycolumns,numofrecords,formtype,formdisplaytype,skin';
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
options '/'.$collectionName.'/:'.$primaryKey.'/metadata.:format' => sub {
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
			$sql_filters = $sql_filters . " AND " . $key . " LIKE '%" . $filters{$key} . "%' ";
		}
   }
   
   my $sql_ordering = ' ORDER BY '.$primaryKey.' DESC';
   my $order =  from_json( $orderstr );
   if ( defined( $order->{orderby} ) && defined( $order->{direction} ) )
   {
		$sql_ordering = ' ORDER BY ' . $order->{orderby} . ' '. $order->{direction};
   }
   # ------ Filtering and Ordering -------------------
   
   my $dbh = MAP::API->dbh();

   my $strSQLstartWhere = '1 = 1';
   if ( defined(  $relationalColumn ) ) {
		$strSQLstartWhere = ' ['.$relationalColumn.'] IN ('.$relational_id.') ';
   }
   my $strSQL = 'SELECT '.$strColumns.' FROM '.$tableName.' WHERE '.$strSQLstartWhere.' ' . $sql_filters . ' '. $sql_ordering . '';
   my $sth = $dbh->prepare( $strSQL, );
   $sth->execute() or MAP::API->fail( $sth->errstr );
   
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
				push @values, $record->{$_};
				$row->{$_} = $record->{$_};
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

get '/'.$collectionName.'/:'.$primaryKey.'/metadata.:format' => sub {
   
    #MAP::API->check_authorization( params->{token}, request->header("Origin") );
   
	my $item_id  = params->{$primaryKey} || MAP::API->fail( "id is missing on url" );
	my $agency_id = params->{agency_id} || MAP::API->fail( "please provide agency_id" );
	
	# path of files json
	my $path = $root_path . '/' .$agency_id . '/dhtmlx_form_' . $item_id . '.json';
	
	# open file and read content
	open(FILE, "<$path") || MAP::API->fail( "file not found" );
	my $result = <FILE>;
	close FILE;
	
	MAP::API->normal_header();
	return {
		status => 'success',
		response => 'Metadata for form '.$item_id.' was saved on ' . $collectionName,
		metadata_file => from_json($result)
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
	
	# check formname
	$hash{formname} = MAP::API->regex_alnum($hash{formname});
	
	my $dbh = MAP::API->dbh();
	
	
	# ===== especific
	my $total_names = 0;
	my $formname = undef;
	my $strSQLquery = 'SELECT formname FROM ' . $tableName . ' WHERE formname = ?';
	my $sth = $dbh->prepare( $strSQLquery, );
	$sth->execute( $hash{formname} ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLquery );
	while ( my $record = $sth->fetchrow_hashref()) 
	{
		$total_names = $total_names + 1;
	}
	if ( $total_names > 0 ) {
		$hash{formname} = $hash{formname} . '_' . $total_names;
	}
	
	
	my $strSQLtable = '
		CREATE TABLE dbo.formmaker_'.$agency_id .'_'.$hash{formname}.'( 
				[data_id] INT not null Identity(1,1),
				[user_id] INT,
				[key_id] INT,
				[connId] INT,
				[connectionId] INT,
				[submited] integer default 0, 
				CONSTRAINT formmaker_'.$agency_id .'_'.$hash{formname}.'_pkey PRIMARY KEY (data_id)
		);
	';
	$sth = $dbh->prepare( $strSQLtable, );
	$sth->execute( ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLtable ); 
	# ===== especific
	
	
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
	$sth = $dbh->prepare( $strSQL, );
	$sth->execute( @sql_values ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQL ); 
	my $record_id = 0;
	while ( my $record = $sth->fetchrow_hashref()) 
	{
		$record_id = $record->{$primaryKey};
	}
	
	# formmaker+_agencyid+_formname

	MAP::API->normal_header();
	return {
		status => 'success',
		response => 'Item '.$record_id.' added on ' . $collectionName,
		sql => $strSQL,
		strSQLtable => $strSQLtable,
		''.$primaryKey.'' => $record_id,
		place_holders_dump => dump(@sql_values)
	};
};

# update form
put '/'.$collectionName.'/:'.$primaryKey.'.:format' => sub {
   
    MAP::API->check_authorization( params->{token}, request->header("Origin") );
   
    my $item_id  = params->{$primaryKey} || MAP::API->fail( "id is missing on url" );
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
	
	
	# ===== especific
	my @IDs = split(/,/, $item_id);
	for(@IDs)
	{
		my $formname = undef;
		my $strSQLquery = 'SELECT form_id, formname FROM ' . $tableName . ' WHERE ['.$primaryKey.'] = ' . $_;
		my $sth = $dbh->prepare( $strSQLquery, );
		$sth->execute(  ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLquery );
		while ( my $record = $sth->fetchrow_hashref()) 
		{
			$formname = MAP::API->regex_alnum($record->{formname});
		}
		
		my $strSQLtable = '
			IF OBJECT_ID(\'dbo.formmaker_'.$agency_id .'_'.$formname.'\', \'U\') IS NULL
				CREATE TABLE dbo.formmaker_'.$agency_id .'_'.$formname.'( 
					[data_id] INT not null Identity(1,1),
					[user_id] INT,
					[key_id] INT,
					[connId] INT,
					[connectionId] INT,
					[submited] integer default 0, 
					CONSTRAINT formmaker_'.$agency_id .'_'.$formname.'_pkey PRIMARY KEY (data_id)
			);
		';
		$sth = $dbh->prepare( $strSQLtable, );
		$sth->execute(  ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLtable );
	}
	# ===== especific
	

	MAP::API->normal_header();
	return {
		status => 'success',
		response => 'Item '.$item_id.' updated on ' . $collectionName,
		sql => $strSQL,
		''.$primaryKey.'' => $item_id,
		place_holders_dump => dump(@sql_values)
	};
};


# save metadata
put '/'.$collectionName.'/:'.$primaryKey.'/metadata.:format' => sub {
   
    MAP::API->check_authorization( params->{token}, request->header("Origin") );
	$tableName = 'formmaker_properties';
   
	my $item_id  = params->{$primaryKey} || MAP::API->fail( "id is missing on url" );
	my $agency_id = params->{agency_id} || MAP::API->fail( "please provide agency_id" );
	my $template = params->{template} || MAP::API->fail( "please provide template" );
	
	# check if dir exist
	unless(-e $root_path){
		mkdir($root_path, 0777);
	}
	unless(-e $root_path . '/' .$agency_id){
		mkdir($root_path . '/' .$agency_id, 0777);
	}
	unless(-e $root_path . '/' .$agency_id . '/') {
		mkdir($root_path . '/' .$agency_id . '/', 0777);
	}
	
	# path of files json
	my $path = $root_path . '/' .$agency_id . '/dhtmlx_form_' . $item_id . '.json';
	
	# create or change files json
	open(FILE, ">$path") || MAP::API->fail( "unable save file" );
	print FILE $template;
	close FILE;

	# save in database
	my $sql = "
		UPDATE formmaker_properties
		SET [FileName] = 'dhtmlx_form_$item_id.json'
		WHERE form_id = $item_id;
	";
	my $dbh = MAP::API->dbh();
	my $sth = $dbh->prepare($sql);
	$sth->execute() || MAP::API->fail($sth->errstr . " --------- ". $sql);
	
	MAP::API->normal_header();
	return {
		status => 'success',
		response => 'Metadata for form '.$item_id.' was saved on ' . $collectionName,
		_file => 'dhtmlx_form_'.$item_id.'.json',
	};
};

del '/'.$collectionName.'/:'.$primaryKey.'.:format' => sub {
    MAP::API->check_authorization( params->{token}, request->header("Origin") );
	$tableName = 'formmaker_properties';
    my $str_id  = params->{$primaryKey} || MAP::API->fail( "id is missing on url" );
	my $agency_id = params->{agency_id} || MAP::API->fail( "please provide agency_id" );
	my $dbh = MAP::API->dbh();
	
	# ===== especific
	my @IDs = split(/,/, $str_id);
	for(@IDs)
	{
		my $formname = undef;
		my $strSQLquery = 'SELECT form_id, formname FROM ' . $tableName . ' WHERE ['.$primaryKey.'] = ' . $_;
		my $sth = $dbh->prepare( $strSQLquery, );
		$sth->execute(  ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLquery );
		while ( my $record = $sth->fetchrow_hashref()) 
		{
			$formname = MAP::API->regex_alnum($record->{formname});
		}
		
		my $strSQLtable = '
			IF OBJECT_ID(\'dbo.formmaker_'.$agency_id .'_'.$formname.'\', \'U\') IS NOT NULL
				DROP TABLE dbo.formmaker_'.$agency_id .'_'.$formname.';
		';
		$sth = $dbh->prepare( $strSQLtable, );
		$sth->execute(  ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLtable );
	}
	# ===== especific
	
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
   
   $tableName = 'formmaker_properties';
   
   my $strColumns = params->{columns} || $defaultColumns;  
   my $str_id  = params->{$primaryKey} || MAP::API->fail( "id is missing on url" );
    
   # ===== especific
   my $agency_id = params->{agency_id} || MAP::API->fail( "please provide agency_id" );
   
   my $dbh = MAP::API->dbh();

   
   
   # ===== especific
	
		my $formname = undef;
		my $strSQLquery = 'SELECT form_id, formname FROM ' . $tableName . ' WHERE ['.$primaryKey.'] = ' . $str_id;
		my $sth = $dbh->prepare( $strSQLquery, );
		$sth->execute(  ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLquery );
		while ( my $record = $sth->fetchrow_hashref()) 
		{
			$formname = MAP::API->regex_alnum($record->{formname});
		}
		
		my $strSQLtable = '
			IF OBJECT_ID(\'dbo.formmaker_'.$agency_id .'_'.$formname.'\', \'U\') IS NULL
				CREATE TABLE dbo.formmaker_'.$agency_id .'_'.$formname.'( 
					[data_id] INT not null Identity(1,1),
					[user_id] INT,
					[key_id] INT,
					[connId] INT,
					[connectionId] INT,
					[submited] integer default 0, 
					CONSTRAINT formmaker_'.$agency_id .'_'.$formname.'_pkey PRIMARY KEY (data_id)
			);
		';
		$sth = $dbh->prepare( $strSQLtable, );
		$sth->execute(  ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLtable );
	
	# ===== especific
	
	
	my $strSQL = 'SELECT '.$strColumns.' FROM '.$tableName.' WHERE '.$primaryKey.' = ?';
	$sth = $dbh->prepare( $strSQL, );
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
dance;