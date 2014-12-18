package MAP::Forms::FormViewer;
use Dancer ':syntax';
use Dancer::Plugin::REST;

use Encode       qw( encode decode );
use DBI;
use Data::Dump qw(dump);
use MAP::Forms::Fields;



our $VERSION = '0.1';
my $collectionName = '';
my $primaryKey = '';
my $tableName = '';
my $defaultColumns = '';

my $relationalColumn = ''; # undef

prefix '/forms/formviewer'; # | undef

# routing OPTIONS header

options '/getdata.:format' => sub {
	MAP::API->options_header();
};
options '/save.:format' => sub {
	MAP::API->options_header();
};
options '/submit.:format' => sub {
	MAP::API->options_header();
};

# routing OPTIONS header

get '/getdata.:format' => sub {

	MAP::API->check_authorization( params->{token}, request->header("Origin") );

	#my $data_id = params->{data_id} || MAP::API->fail( "please provide data_id" );
	my $connId = params->{connId} || MAP::API->fail( "please provide connId" );
	my $connectionId = params->{connectionId} || MAP::API->fail( "please provide connectionId" );
	my $user_id = params->{user_id} || MAP::API->fail( "please provide user_id" );

	my $form_id = params->{form_id} || MAP::API->fail( "please provide form_id" );
	my $agency_id = request->header("X-AId") || MAP::API->fail( "please provide agency_id" );

	my $dbh = MAP::API->dbh();

	my $formname = undef;
	my $strSQLquery = 'SELECT form_id, formname FROM formmaker_properties WHERE [form_id] = ?';
	my $sth = $dbh->prepare( $strSQLquery, );
	$sth->execute( $form_id ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLquery );
	while ( my $record = $sth->fetchrow_hashref())
	{
		 $formname = $record->{formname};
	}

	$tableName = 'dbo.formmaker_'.$agency_id .'_'.$formname.'';

	##### check and persist table structure integrity
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
	my $strSQLsubmited = '
		IF NOT EXISTS(SELECT * FROM sys.columns
			WHERE [name] = N\'submited\' AND [object_id] = OBJECT_ID(N\'formmaker_'.$agency_id .'_'.$formname.'\'))
		BEGIN
			ALTER TABLE dbo.formmaker_'.$agency_id .'_'.$formname.' ADD submited integer default 0;
		END
	';
	$sth = $dbh->prepare( $strSQLsubmited, );
	$sth->execute( ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLsubmited );
	##### check and persist table structure integrity


	my $strSQL = 'SELECT * FROM '.$tableName.' WHERE connId = '.$connId.' AND connectionId = '.$connectionId.' AND user_id = '.$user_id.';';
	$sth = $dbh->prepare( $strSQL, );
	$sth->execute(  ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQL );


	#$dbh->disconnect();
	MAP::API->normal_header();
	return {
			status => 'success',
			response => 'Succcess',
			hash => $sth->fetchrow_hashref(),
			sql =>  $strSQL
	};
};

post '/save.:format' => sub {

	MAP::API->check_authorization( params->{token}, request->header("Origin") );

	#my $data_id = params->{data_id} || MAP::API->fail( "please provide data_id" );
	my $connId = params->{connId} || MAP::API->fail( "please provide connId" );
	my $connectionId = params->{connectionId} || MAP::API->fail( "please provide connectionId" );
	my $user_id = params->{user_id} || MAP::API->fail( "please provide user_id" );

	my $form_id = params->{form_id} || MAP::API->fail( "please provide form_id" );
	my $agency_id = request->header("X-AId") || MAP::API->fail( "please provide agency_id" );

	my $hashStr = params->{hash} || '{}';
	my $json_bytes = encode('UTF-8', $hashStr);
	my $hash = JSON->new->utf8->decode($json_bytes) or MAP::API->fail( "unable to decode" );
	my %hash = %{ $hash };

	my $dbh = MAP::API->dbh();

	my $formname = undef;
	my $strSQLGetFormName = 'SELECT form_id, formname FROM formmaker_properties WHERE [form_id] = ?';
	my $sth = $dbh->prepare( $strSQLGetFormName, );
	$sth->execute( $form_id ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLGetFormName );
	while ( my $record = $sth->fetchrow_hashref())
	{
		 $formname = $record->{formname};
	}

	$tableName = 'formmaker_'.$agency_id .'_'.$formname.'';


	# check if form exists,
	my $form_exist = 0;
	my $strSQLCheckExistForm = 'SELECT data_id FROM '.$tableName.' WHERE connId = ?  AND connectionId = ?  AND user_id = ?';
	$sth = $dbh->prepare( $strSQLCheckExistForm, );
	$sth->execute( $connId, $connectionId, $user_id ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLCheckExistForm );
	while ( my $record = $sth->fetchrow_hashref())
	{
		 $form_exist = 1;
	}

	# check if form exists,
	my $existing_columns = '';
	my $strSQLCheckExistColumn = 'SELECT COLUMN_NAME,*
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = \''.$tableName.'\' AND TABLE_SCHEMA=\'dbo\'';
	$sth = $dbh->prepare( $strSQLCheckExistColumn, );
	$sth->execute(  ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLCheckExistColumn );
	while ( my $record = $sth->fetchrow_hashref())
	{
		 $existing_columns = $existing_columns . $record->{COLUMN_NAME} . "|";
	}

	debug '     '. $strSQLCheckExistColumn;
	debug '';
	debug '';
	debug $existing_columns;



	#so update,
	if ( $form_exist ) {

		my $strUpdate = '';
		my @sql_values;
		foreach my $key (%hash)
		{
			if ( defined( $key ) )
			{
				#debug 'key defined';
				if ( defined( $hash{$key} ) )
				{
					#debug 'hash{key} defined';
					#debug index($existing_columns, $key);
					if ( index($existing_columns, '' .$key.'') != -1 )
					{
						debug 'exists';
						if ( $key ne 'data_id' )
						{
							$strUpdate = $strUpdate .'[' .$key.'] = \''.$hash{$key}.'\', ';
							push @sql_values, $hash{$key};
						}
					}
					else
					{
					debug '===       ' . $key . ' column not found';
					}
				}
			}
		}

		push @sql_values, $connId;
		push @sql_values, $connectionId;
		push @sql_values, $user_id;

		my $strSQLquery = 'UPDATE ' . $tableName . ' SET ' . substr($strUpdate, 0, -2) . ' WHERE connId = '.$connId.' AND connectionId = '.$connectionId.' AND user_id = '.$user_id.'';

		my $sth = $dbh->prepare( $strSQLquery, );
		$sth->execute(  ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLquery );

		MAP::API->normal_header();
		return {
				status => 'success',
				response => 'The existing form was saved',
				sql =>  $strSQLquery
		};


	}#if not, insert
	else
	{
		my $strInsert = '';
		my @sql_values;
		my $sql_placeholders;
		foreach my $key (%hash)
		{
			if ( defined( $key ) )
			{
				if ( defined( $hash{$key} ) )
				{
					if ( index($existing_columns, '' .$key.'') != -1 )
					{
						if ( $key ne 'data_id' )
						{
							$strInsert = $strInsert .'[' .$key.'], ';
							$sql_placeholders  = $sql_placeholders . '?, ';
							push @sql_values, $hash{$key};
						}

					}

				}
			}
		}


		$strInsert = $strInsert .'[connId], ';
		$sql_placeholders  = $sql_placeholders . '?, ';
		$strInsert = $strInsert .'[connectionId], ';
		$sql_placeholders  = $sql_placeholders . '?, ';
		$strInsert = $strInsert .'[user_id], ';
		$sql_placeholders  = $sql_placeholders . '?, ';

		push @sql_values, $connId;
		push @sql_values, $connectionId;
		push @sql_values, $user_id;

		my $strSQLquery = 'INSERT
			INTO ' . $tableName . '(' . substr($strInsert, 0, -2) . ')
				VALUES(' . substr($sql_placeholders, 0, -2) . ')';

		my $sth = $dbh->prepare( $strSQLquery, );
		$sth->execute( @sql_values ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLquery );

		MAP::API->normal_header();
		return {
				status => 'success',
				response => 'Form saved',
				sql =>  $strSQLquery
		};
	}



};

get '/getsubmit.:format' => sub {

	MAP::API->check_authorization( params->{token}, request->header("Origin") );

	#my $data_id = params->{data_id} || MAP::API->fail( "please provide data_id" );
	my $connId = params->{connId} || MAP::API->fail( "please provide connId" );
	my $connectionId = params->{connectionId} || MAP::API->fail( "please provide connectionId" );
	my $user_id = params->{user_id} || MAP::API->fail( "please provide user_id" );

	my $form_id = params->{form_id} || MAP::API->fail( "please provide form_id" );
	my $agency_id = request->header("X-AId") || MAP::API->fail( "please provide agency_id" );

	my $dbh = MAP::API->dbh();

	my $formname = undef;
	my $strSQLquery = 'SELECT form_id, formname FROM formmaker_properties WHERE [form_id] = ?';
	my $sth = $dbh->prepare( $strSQLquery, );
	$sth->execute( $form_id ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLquery );
	while ( my $record = $sth->fetchrow_hashref())
	{
		 $formname = $record->{formname};
	}

	$tableName = 'dbo.formmaker_'.$agency_id .'_'.$formname;

	##### check and persist table structure integrity
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

	my $strSQLsubmited = '
		IF NOT EXISTS(SELECT * FROM sys.columns
			WHERE [name] = N\'submited\' AND [object_id] = OBJECT_ID(N\'formmaker_'.$agency_id .'_'.$formname.'\'))
		BEGIN
			ALTER TABLE dbo.formmaker_'.$agency_id .'_'.$formname.' ADD submited integer default 0;
		END
	';
	$sth = $dbh->prepare( $strSQLsubmited, );
	$sth->execute( ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLsubmited );
	##### check and persist table structure integrity


	my $strSQL = 'SELECT * FROM '.$tableName.' WHERE connId = '.$connId.' AND connectionId = '.$connectionId.' AND user_id = '.$user_id.';';
	$sth = $dbh->prepare( $strSQL, );
	$sth->execute(  ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQL );


	#$dbh->disconnect();
	MAP::API->normal_header();
	return {
			status => 'success',
			response => 'Succcess',
			hash => $sth->fetchrow_hashref(),
			sql =>  $strSQL
	};
};

post '/submit.:format' => sub {

	MAP::API->check_authorization( params->{token}, request->header("Origin") );

	#my $data_id = params->{data_id} || MAP::API->fail( "please provide data_id" );
	my $connId = params->{connId} || MAP::API->fail( "please provide connId" );
	my $connectionId = params->{connectionId} || MAP::API->fail( "please provide connectionId" );
	my $user_id = params->{user_id} || MAP::API->fail( "please provide user_id" );

	my $form_id = params->{form_id} || MAP::API->fail( "please provide form_id" );
	my $agency_id = request->header("X-AId") || MAP::API->fail( "please provide agency_id" );

	my $hashStr = params->{hash} || '{}';
	my $json_bytes = encode('UTF-8', $hashStr);
	my $hash = JSON->new->utf8->decode($json_bytes) or MAP::API->fail( "unable to decode" );
	my %hash = %{ $hash };

	my $dbh = MAP::API->dbh();

	my $formname = undef;
	my $strSQLGetFormName = 'SELECT form_id, formname FROM formmaker_properties WHERE [form_id] = ?';
	my $sth = $dbh->prepare( $strSQLGetFormName, );
	$sth->execute( $form_id ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLGetFormName );
	while ( my $record = $sth->fetchrow_hashref())
	{
		 $formname = $record->{formname};
	}

	$tableName = 'formmaker_'.$agency_id .'_'.$formname.'';


	# check if form exists,
	my $form_exist = 0;
	my $strSQLCheckExistForm = 'SELECT data_id FROM '.$tableName.' WHERE connId = ?  AND connectionId = ?  AND user_id = ?';
	$sth = $dbh->prepare( $strSQLCheckExistForm, );
	$sth->execute( $connId, $connectionId, $user_id ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLCheckExistForm );
	while ( my $record = $sth->fetchrow_hashref())
	{
		 $form_exist = 1;
	}

	# check if form exists,
	my $existing_columns = '';
	my $strSQLCheckExistColumn = 'SELECT COLUMN_NAME,*
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = \''.$tableName.'\' AND TABLE_SCHEMA=\'dbo\'';
	$sth = $dbh->prepare( $strSQLCheckExistColumn, );
	$sth->execute(  ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLCheckExistColumn );
	while ( my $record = $sth->fetchrow_hashref())
	{
		 $existing_columns = $existing_columns . $record->{COLUMN_NAME} . "|";
	}

	debug $strSQLCheckExistColumn;
	debug $existing_columns;



	#so update,
	if ( $form_exist ) {

		my $strUpdate = '';
		my @sql_values;
		foreach my $key (%hash)
		{
			if ( defined( $key ) )
			{
				debug 'key defined';
				if ( defined( $hash{$key} ) )
				{
					debug 'hash{key} defined';
					debug index($existing_columns, $key);
					if ( index($existing_columns, $key) != -1 )
					{
						debug 'exists';
						if ( $key ne 'data_id' )
						{
							$strUpdate = $strUpdate .'[' .$key.'] = \''.$hash{$key}.'\', ';
							push @sql_values, $hash{$key};
						}
					}

				}
			}
		}

		push @sql_values, $connId;
		push @sql_values, $connectionId;
		push @sql_values, $user_id;

		my $strSQLquery = 'UPDATE
			' . $tableName . '
			SET ' . substr($strUpdate, 0, -2) . ', submited = 1
			WHERE
				connId = '.$connId.' AND connectionId = '.$connectionId.' AND user_id = '.$user_id.'';

		my $sth = $dbh->prepare( $strSQLquery, );
		$sth->execute(  ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLquery );

		MAP::API->normal_header();
		return {
				status => 'success',
				response => 'The existing form was saved',
				sql =>  $strSQLquery
		};


	}#if not, insert
	else
	{
		my $strInsert = '';
		my @sql_values;
		my $sql_placeholders;
		foreach my $key (%hash)
		{
			if ( defined( $key ) )
			{
				if ( defined( $hash{$key} ) )
				{
					if ( index($existing_columns, '' .$key.'') != -1 )
					{
						if ( $key ne 'data_id' )
						{
							$strInsert = $strInsert .'[' .$key.'], ';
							$sql_placeholders  = $sql_placeholders . '?, ';
							push @sql_values, $hash{$key};
						}

					}

				}
			}
		}


		$strInsert = $strInsert .'[connId], ';
		$sql_placeholders  = $sql_placeholders . '?, ';
		$strInsert = $strInsert .'[connectionId], ';
		$sql_placeholders  = $sql_placeholders . '?, ';
		$strInsert = $strInsert .'[user_id], ';
		$sql_placeholders  = $sql_placeholders . '?, ';

		push @sql_values, $connId;
		push @sql_values, $connectionId;
		push @sql_values, $user_id;

		my $strSQLquery = 'INSERT
			INTO ' . $tableName . '(' . substr($strInsert, 0, -2) . ', submited)
				VALUES(' . substr($sql_placeholders, 0, -2) . ', 1)';

		my $sth = $dbh->prepare( $strSQLquery, );
		$sth->execute( @sql_values ) or MAP::API->fail( $sth->errstr . " --------- ".$strSQLquery );

		MAP::API->normal_header();
		return {
				status => 'success',
				response => 'Form saved',
				sql =>  $strSQLquery
		};
	}



};


dance;
