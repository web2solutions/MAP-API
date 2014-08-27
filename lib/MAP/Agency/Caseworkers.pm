package MAP::Agency::Caseworkers;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use utf8;
use Encode       qw( encode );
use DBI;
use Data::Dump qw(dump);



our $VERSION = '0.1';

our $collectionName = 'caseworkers';
our $primaryKey = 'user_id';
our $tableName = 'user_accounts';
our $defaultColumns = 'user_id,username,password,first_name,last_name,email,photo,organization,title,phone,address1,address2,city,state,zipcode,country,website,mobile_number,status,summary,membership,user_posting,user_register,datejoined,last_login,last_ip,session,suspend_until,timezone,itemized_date,user_type,agency_group,agency_name,agency_id,group_id,queation,answer,due_date,race,note,over_21,marital_status,message_alert,case_worker,case_worker_parent_user_id,adoption_type,spouse_first_name,spouse_last_name,spouse_organization,spouse_title,spouse_website,referral,mailtogroups,airs_contact_id,airs_contactairs_id,doctogroups,doctousers,personal_gender,spouse_gender,message_group,quickbook_listid,quickbook_vendorid,quickbook_queue,signer1,signer2,video_msg,status_mode,edd,id_type,id_number,quickbook_custeditseq,quickbook_vendeditseq,qb_listid_online,qb_vendorid_online,qb_online_updation,qb_standalone_updation,new_encryption,passwordchange,passwordchangedate,ConnId,SBFlag,SBSaveMapDate,trace';

our $relationalColumn = 'agency_id'; # undef

prefix '/agency/:'. $relationalColumn; # | undef

# routing OPTIONS header
options '/'.$collectionName.'.:format' => sub {
	MAP::API->options_header();
};

options '/'.$collectionName.'/:'.$primaryKey.'.:format' => sub {
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
		
		#ESPECIFIC
		$strSQLstartWhere = $strSQLstartWhere . " AND [user_type] = 'agency_user' AND [status] = 'Active' ";
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
	my $strSQL = 'INSERT INTO
		'.$tableName.'(' . substr($sql_columns, 0, -2) . ') 
		VALUES(' . substr($sql_placeholders, 0, -2) . ');
		SELECT SCOPE_IDENTITY() AS '.$primaryKey.';
	';
	my $sth = $dbh->prepare( $strSQL, );
	$sth->execute( @sql_values ) or MAP::API->fail( $sth->errstr ); 
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
   $sth->execute( $str_id ) or MAP::API->fail( $sth->errstr );
   
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