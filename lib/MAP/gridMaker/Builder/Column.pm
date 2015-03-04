package MAP::gridMaker::Builder::Column;
use Dancer ':syntax';
use Dancer::Plugin::REST;

use Encode qw( encode decode );
use Data::Recursive::Encode;
use Data::Dump qw(dump);
use MIME::Base64;

our $VERSION = '0.1';
my $collectionName = 'columns';
my $primaryKey = 'gridmaker_column_id';
my $tableName = 'gridmaker_column';
my $defaultColumns = 'gridmaker_table_id,column_name,column_type,dhtmlx_grid_header,dhtmlx_grid_type,dhtmlx_grid_sorting,dhtmlx_grid_width,dhtmlx_grid_align,dhtmlx_grid_footer,gridmaker_column_id';





my $relationalColumn = 'gridmaker_table_id'; # undef

my $specific_append_sql_logic_select = '';

my $prefix = '/gridmaker/builder/tables/:' . $relationalColumn;

my $root_path = '/var/www/html/userhome/MAP-API'. $prefix . '/' .$collectionName;

prefix $prefix; # | undef



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

options '/'.$collectionName.'/doc' => sub {
	MAP::API->options_header();
};
# routing OPTIONS header

# end point docs
get '/'.$collectionName.'/doc' => sub {

  my $auth = request->env->{HTTP_AUTHORIZATION} || MAP::API->unauthorized("please login");
	$auth =~ s/Basic //gi;

	my ($salt_api_user, $salt_api_secret) = split(/:/, ( MIME::Base64::decode($auth) || ":" ) );

	my $user =  $salt_api_user;
	my $pass =  $salt_api_secret;

	#return  $pass;

	if ( $user ne 'CAIRS' &&  $pass ne 'CAIRS') {
		MAP::API->unauthorized("wrong user or password");
	}


	my $table_schema = MAP::API->get_table_MS_schema( $tableName );
	$primaryKey = $table_schema->{primary_key};
	$defaultColumns = '';
	for( @{$table_schema->{columns}} )
	{

		$defaultColumns = $defaultColumns . $_->{name} . ',' if $_->{name} ne $primaryKey;
	}

	$defaultColumns = $defaultColumns . $primaryKey;

	my @defaultColumns = split(/,/, $defaultColumns);
	template 'doc', {
		'collectionName' => $collectionName,
		'tableName' => $tableName,
		'prefix' => $prefix,
		'defaultColumns' => [@defaultColumns],
		'defaultColumnsStr' => $defaultColumns,
		'primaryKey' => $primaryKey
	};
};
# end point docs

get '/'.$collectionName.'.:format' => sub {

	MAP::API->check_authorization( params->{token}, request->header("Origin") );

	my $count = params->{count} || 1000;
	my $posStart = params->{posStart} || 0;
	$count = $count + 1;
	$posStart = $posStart + 1;


	my $table_schema = MAP::API->get_table_MS_schema( $tableName );
	#$primaryKey = $table_schema->{primary_key};
	$defaultColumns = '';
	for( @{$table_schema->{columns}} )
	{

		$defaultColumns = $defaultColumns . $_->{name} . ',' if $_->{name} ne $primaryKey;
	}

	$defaultColumns = $defaultColumns . $primaryKey;

	my $strColumns = params->{columns} || $defaultColumns;
	$strColumns=~ s/'//g;
	my @columns = split(/,/, $strColumns);
	$strColumns = MAP::API->normalizeColumnNames( $strColumns, $defaultColumns );


	#  $value_column =~ s/[^wd.-]+//;

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
	$filter_operator=~ s/[^wd.-]+//;

	my %filters = %{ $filters };
	foreach my $key (%filters) {
	if ( defined( $filters{$key} ) ) {
			my $string = $filters{$key};
			$string=~ s/'//g;
			my $column = $key;
			$column=~ s/[^wd.-]+//;
			$sql_filters = $sql_filters . " " . $column . " LIKE '%" . $string . "%'  ". $filter_operator ."  ";
		}
	}

	if ( length($sql_filters) > 1 ) {
		$sql_filters = ' AND ( '.  substr($sql_filters, 0, -5) . ' )';
	}

	if ( defined($specific_append_sql_logic_select) ) {
		#$specific_append_sql_logic_select
		$sql_filters = ' '.  $specific_append_sql_logic_select. ' ';
	}


	my $sql_ordering = ' ORDER BY '.$primaryKey.' ASC';
	my $order =  from_json( $orderstr );
	if ( defined( $order->{orderby} ) && defined( $order->{direction} ) )
	{
		my $column = $order->{orderby};
		$column=~ s/[^wd.-]+//;
		my $direction = $order->{direction};
		$direction=~ s/[^wd.-]+//;
		$sql_ordering = ' ORDER BY [' . $column . '] '. $direction ;
	}
	# ------ Filtering and Ordering -------------------

	my $dbh = MAP::API->dbh();

	my $strSQLstartWhere = ' 1 = 1 ';
	if ( defined(  $relationalColumn ) ) {
		$strSQLstartWhere = '( ['.$relationalColumn.'] IN ('.$relational_id.') ) ';
	}

	my $totalCount = 0;
	my $sth = $dbh->prepare( 'SELECT COUNT('.$primaryKey.') as total_count FROM '.$tableName.' WHERE '.$strSQLstartWhere.' ' . $sql_filters . ';', );
	$sth->execute() or MAP::API->fail( $sth->errstr );
	while ( my $record = $sth->fetchrow_hashref())
	{
		$totalCount = $record->{"total_count"};
	}

	my $strSQL = '';
	if ( length($strSQLstartWhere) < 3 && length($sql_filters) < 3 ) {
		#$strSQL = 'SELECT '.$strColumns.' FROM '.$tableName.' '. $sql_ordering .
		$strSQL = '; WITH results AS (
		SELECT
		rowNo = ROW_NUMBER() OVER( '.$sql_ordering.' ), *
		FROM '.$tableName.' WHERE '.$strSQLstartWhere.' ' . $sql_filters . '
		)
		SELECT *
		FROM results
		WHERE rowNo BETWEEN '.$posStart.' AND '. $posStart. ' + '.$count.'';
	}
	else
	{
		#$strSQL = 'SELECT '.$strColumns.' FROM '.$tableName.' WHERE '.$strSQLstartWhere.' ' . $sql_filters . ' '. $sql_ordering . '';
		$strSQL = '; WITH results AS (
		SELECT
		rowNo = ROW_NUMBER() OVER( '.$sql_ordering.' ), *
		FROM '.$tableName.' WHERE '.$strSQLstartWhere.' ' . $sql_filters . '
		)
		SELECT *
		FROM results
		WHERE rowNo BETWEEN '.$posStart.' AND '. $posStart. ' + '.$count.'';
	}


	$sth = $dbh->prepare( $strSQL, );
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
		elsif ( $record->{$_} == 0 ) {
				push @values, 0;
				$row->{$_} = 0;
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
		status => 'success',
		response => 'Succcess',
		''.$collectionName.'' => [@records],
		sql =>  $strSQL,
		sql_filters => $sql_filters,
		sql_ordering => $sql_ordering,
		total_count => $totalCount,
		pos => $posStart,
	};
};



# create form
post '/'.$collectionName.'.:format' => sub {

	MAP::API->check_authorization( params->{token}, request->header("Origin") );

	my $table_schema = MAP::API->get_table_MS_schema( $tableName );
	#$primaryKey = $table_schema->{primary_key};
	$defaultColumns = '';
	for( @{$table_schema->{columns}} )
	{

		$defaultColumns = $defaultColumns . $_->{name} . ',' if $_->{name} ne $primaryKey;
	}

	$defaultColumns = $defaultColumns . $primaryKey;

	#$defaultColumns = MAP::API->normalizeColumnNames( $defaultColumns, $defaultColumns );

	my $hashStr = params->{hash} || '{}';
	#my $agency_id = request->header("X-AId") || MAP::API->fail( "please provide agency_id" );
	my $json_bytes = encode('UTF-8', $hashStr);
	my $hash = JSON->new->utf8->decode($json_bytes) or MAP::API->fail( "unable to decode" );
	#my $hash =  from_json( $hashStr );



	# ===== especific
	my $table_name = params->{table_name}  or MAP::API->fail( "The param table_name is mandatory for this end point" );
	my $table_id = params->{table_id}  or MAP::API->fail( "The param table_id is mandatory for this end point" );



	debug '===========================';
	debug ref($hash);

	if ( ref($hash) eq 'HASH' ) {
				my $sql_columns = "";
				my $sql_placeholders = "";
				my @sql_values;
				my %hash = %{ $hash };



				my $final_column_name = '';
				my $final_column_type = '';
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

										if ( $key eq 'column_name') {
												$final_column_name = $hash{$key};
										}

										if ( $key eq 'column_type') {
												$final_column_type = $hash{$key};
										}
									}
								}
							}
						}
					}
				}

				my $dbh = MAP::API->dbh();

				# ===== especific
				my $strSQLtable = '
						IF NOT EXISTS(SELECT * FROM sys.columns
							WHERE [name] = N\''.$final_column_name.'\' AND [object_id] = OBJECT_ID(N\''.$table_name .'\'))
						BEGIN
							ALTER TABLE dbo.'.$table_name .' ADD '.MAP::API->regex_alnum($final_column_name).' ' . $final_column_type . ';
						END
					';
					my $sth = $dbh->prepare( $strSQLtable, );
					$sth->execute( ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLtable );
				# ===== especific

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


				MAP::API->normal_header();
				return {
					status => 'success',
					response => 'Item '.$record_id.' added on ' . $collectionName,
					sql => $strSQL,
					''.$primaryKey.'' => $record_id,
					place_holders_dump => dump(@sql_values)
				};
	}
	elsif( ref($hash) eq 'ARRAY' )
	{
				my @record_id;

				my @records = @{ $hash };

				for( @records )
				{
						my $sql_columns = "";
						my $sql_placeholders = "";
						my @sql_values;
						my %hash = %{ $_ };

						my $final_column_name = '';
						my $final_column_type = '';
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

												if ( $key eq 'column_name') {
														$final_column_name = $hash{$key};
												}

												if ( $key eq 'column_type') {
														$final_column_type = $hash{$key};
												}
											}
										}
									}
								}
							}
						}



						my $dbh = MAP::API->dbh();


						# ===== especific
						my $strSQLtable = '
								IF NOT EXISTS(SELECT * FROM sys.columns
									WHERE [name] = N\''.$final_column_name.'\' AND [object_id] = OBJECT_ID(N\''.$table_name .'\'))
								BEGIN
									ALTER TABLE dbo.'.$table_name .' ADD '.MAP::API->regex_alnum($final_column_name).' ' . $final_column_type . ';
								END
							';
							my $sth = $dbh->prepare( $strSQLtable, );
							$sth->execute( ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLtable );
						# ===== especific

						my $strSQL = 'INSERT INTO
							'.$tableName.'(' . substr($sql_columns, 0, -2) . ')
							VALUES(' . substr($sql_placeholders, 0, -2) . ');
							SELECT SCOPE_IDENTITY() AS '.$primaryKey.';
						';

						#debug $strSQL;

						$sth = $dbh->prepare( $strSQL, );
						$sth->execute( @sql_values ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQL );

						while ( my $record = $sth->fetchrow_hashref())
						{
							push @record_id, $record->{$primaryKey};
						}
				}

				MAP::API->normal_header();
				return {
						status => 'success',
						response => 'Item '.join(', ', @record_id).' added on ' . $collectionName,
						''.$primaryKey.'' => [@record_id]
				};
	}



};

# update form
put '/'.$collectionName.'/:'.$primaryKey.'.:format' => sub {

	MAP::API->check_authorization( params->{token}, request->header("Origin") );

	my $table_schema = MAP::API->get_table_MS_schema( $tableName );
	#$primaryKey = $table_schema->{primary_key};
	$defaultColumns = '';
	for( @{$table_schema->{columns}} )
	{

		$defaultColumns = $defaultColumns . $_->{name} . ',' if $_->{name} ne $primaryKey;
	}

	$defaultColumns = $defaultColumns . $primaryKey;

	my $item_id  = params->{$primaryKey} || MAP::API->fail( "id is missing on url" );
	$item_id=~ s/'//g;
	#my $agency_id = request->header("X-AId") || MAP::API->fail( "please provide agency_id" );
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

	if ( $sth->rows == 0 ) {
		status 404;
		return {
			status => 'err',
			response => 'resource not found. nothing updated',
			sql => $strSQL,
			''.$primaryKey.'' => $item_id,
			place_holders_dump => dump(@sql_values)
		};
	}
	else
	{
		return {
			status => 'success',
			response => 'Item '.$item_id.' updated on ' . $collectionName,
			sql => $strSQL,
			''.$primaryKey.'' => $item_id,
			place_holders_dump => dump(@sql_values)
		};
	}



};


del '/'.$collectionName.'/:'.$primaryKey.'.:format' => sub {
	MAP::API->check_authorization( params->{token}, request->header("Origin") );

	my $table_schema = MAP::API->get_table_MS_schema( $tableName );
	#$primaryKey = $table_schema->{primary_key};
	$defaultColumns = '';
	for( @{$table_schema->{columns}} )
	{

		$defaultColumns = $defaultColumns . $_->{name} . ',' if $_->{name} ne $primaryKey;
	}

	$defaultColumns = $defaultColumns . $primaryKey;

	my $str_id  = params->{$primaryKey} || MAP::API->fail( "id is missing on url" );
	$str_id=~ s/'//g;
	#my $agency_id = request->header("X-AId") || MAP::API->fail( "please provide agency_id" );
	my $dbh = MAP::API->dbh();



	my $strSQL = 'DELETE FROM '.$tableName.' WHERE ['.$primaryKey.'] IN ('.$str_id.')';
	my $sth = $dbh->prepare( $strSQL, );
	$sth->execute( ) or MAP::API->fail( $sth->errstr . "   ----   ". $strSQL );


	MAP::API->normal_header();

	if ( $sth->rows == 0 ) {
		status 404;
		return {
			status => 'success',
			response => 'resource not found. nothing deleted',
			sql => $strSQL,
			''.$primaryKey.'' => $str_id
		};
	}
	else
	{
		return {
			status => 'success',
			response => 'Item(s) '.$str_id.' deleted from '.$collectionName.'',
			sql => $strSQL,
			''.$primaryKey.'' => $str_id
		};
	}
};


get '/'.$collectionName.'/:'.$primaryKey.'.:format' => sub {

	MAP::API->check_authorization( params->{token}, request->header("Origin") );

	my $table_schema = MAP::API->get_table_MS_schema( $tableName );
	#$primaryKey = $table_schema->{primary_key};
	$defaultColumns = '';
	for( @{$table_schema->{columns}} )
	{

		$defaultColumns = $defaultColumns . $_->{name} . ',' if $_->{name} ne $primaryKey;
	}

	$defaultColumns = $defaultColumns . $primaryKey;

	my $strColumns = params->{columns} || $defaultColumns;
	my $str_id  = params->{$primaryKey} || MAP::API->fail( "id is missing on url" );
	$str_id=~ s/'//g;
	# ===== especific
	#my $agency_id = request->header("X-AId") || MAP::API->fail( "please provide agency_id" );

	my $dbh = MAP::API->dbh();

	my $strSQL = 'SELECT '.$strColumns.' FROM '.$tableName.' WHERE '.$primaryKey.' = ?';
	my $sth = $dbh->prepare( $strSQL, );
	$sth->execute( $str_id ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQL );

	#$dbh->disconnect();
	MAP::API->normal_header();


	if ( $sth->rows == 0 ) {
		status 404;
		return {
			status => 'success',
			response => 'resource not found. nothing deleted',
			sql => $strSQL,
			''.$primaryKey.'' => $str_id
		};
	}
	else
	{
		return {
			status => 'success',
			response => 'Succcess',
			hash => Data::Recursive::Encode->decode_utf8( $sth->fetchrow_hashref() ),
			sql =>  $strSQL
		};
	}


};

# HELPERS
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



# end point default routes
dance;
