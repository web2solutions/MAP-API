package MAP::LibraryFields::Tags;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use DBI;
use URI::Escape;
use Encode qw( encode decode );
use Data::Recursive::Encode;


our $VERSION = '0.1';


options '/LibraryFields/tags.:format' => sub {
	MAP::API->options_header();
};

options '/LibraryFields/tags/:id.:format' => sub {
	MAP::API->options_header();
};


get '/LibraryFields/tags.:format' => sub {

	MAP::API->check_authorization_simple( params->{token}, request->header("Origin") );

	my $field_tagid = 0;
	my $strColumns = params->{columns} || 'field_tagText';
	my @columns = split(/,/, $strColumns);
	my @rows;

	my $strSQL = 'EXEC usp_GetFormmaker_FieldTag @field_tagid = ?';
	my $dbh = MAP::API->dbh();
	my $sth = $dbh->prepare( $strSQL, );
	$sth->execute( $field_tagid ) or MAP::API->fail( $sth->errstr );
	while ( my $record = $sth->fetchrow_hashref())
	{
		my @values;
		foreach (@columns) {
			if (defined($record->{$_})) {
				push @values, decode( 'UTF-8',$record->{$_});
			}
			else
			{
				push @values, "";
			}
		}

		my $row = {
			id =>	$record->{"field_tagid"},
			data => [@values]
		 };
		push @rows, $row;
	}

	MAP::API->normal_header();

	return {
		status => 'success',
		response => 'Succcess',
		rows => [@rows],
	};
};


get '/LibraryFields/tags/:id.:format' => sub {

	MAP::API->check_authorization( params->{token}, request->header("Origin") );

	my $field_tagid = params->{id};
	my $strColumns = params->{columns} || 'field_tagText';
	my @columns = split(/,/, $strColumns);
	my @rows;

	my $strSQL = 'EXEC usp_GetFormmaker_Field_FieldTags ?';
	my $dbh = MAP::API->dbh();
	my $sth = $dbh->prepare( $strSQL, );
	$sth->execute( $field_tagid ) or MAP::API->fail( $sth->errstr );
	while ( my $record = $sth->fetchrow_hashref())
	{
		my @values;
		foreach (@columns) {
			if (defined($record->{$_})) {
				push @values, decode( 'UTF-8',$record->{$_});
			}
			else
			{
				push @values, "";
			}
		}

		my $row = {
			id =>	$record->{"field_tagid"},
			data => [@values]
		 };
		push @rows, $row;
	}

	MAP::API->normal_header();

	return {
		status => 'success',
		response => 'Succcess',
		rows => [@rows],
		sql => $strSQL
	};
};



post '/LibraryFields/tags.:format' => sub {

	MAP::API->check_authorization( params->{token}, request->header("Origin") );

	my $field_tagText = params->{field_tagText} || MAP::API->fail( "field_tagText is missing" );


	my $dbh = MAP::API->dbh();

	my $strSQL = 'EXEC usp_formmaker_FieldTagAddEdit
		@field_tagid = 0,
		@deleteYN = 0,
		@field_tagText = ?
	';

	my $sth = $dbh->prepare( $strSQL, );

	$sth->execute(  $field_tagText  ) or MAP::API->fail( $sth->errstr );

	my $new_FieldTagID = 0;
	while ( my $record = $sth->fetchrow_hashref())
	{
		$new_FieldTagID = $record->{"fieldTagID"};
	}


	MAP::API->normal_header();

	return { status => 'success', response => 'Succcess', sql => $strSQL, FieldTagID => $new_FieldTagID};
};


put '/LibraryFields/tags/:id.:format' => sub {

	MAP::API->check_authorization( params->{token}, request->header("Origin") );

	my $field_tagid = params->{id} || MAP::API->fail( "id on url is missing" );
	my $field_tagText = params->{field_tagText} || MAP::API->fail( "field_tagText is missing" );

	my $dbh = MAP::API->dbh();

	my $strSQL = 'EXEC usp_formmaker_FieldTagAddEdit
		@field_tagid = ?,
		@deleteYN = 0,
		@field_tagText = ?
	';

	my $sth = $dbh->prepare( $strSQL, );

	$sth->execute( $field_tagid, $field_tagText  ) or MAP::API->fail( $sth->errstr );

	my $new_FieldTagID = 0;
	while ( my $record = $sth->fetchrow_hashref())
	{
		$new_FieldTagID = $record->{"fieldTagID"};
	}


	MAP::API->normal_header();

	return { status => 'success', response => 'Succcess', sql => $strSQL, FieldTagID => $new_FieldTagID};
};

# - For deleting  ALL tags

del '/LibraryFields/tags.:format' => sub {

	MAP::API->check_authorization( params->{token}, request->header("Origin") );

	my $field_tagid = params->{field_tagid} || MAP::API->fail( "field_tagid is missing" );



	my $dbh = MAP::API->dbh();

	my $strSQL = '';

	my $sth = $dbh->prepare( $strSQL, );

	$sth->execute( ) or MAP::API->fail( $sth->errstr );

	#my $deleted_GroupId = 0;
	#while ( my $record = $sth->fetchrow_hashref())
	#{
	#	$deleted_GroupId = $record->{"GroupID"};
	#}

	MAP::API->normal_header();

	return { status => 'success', response => 'Succcess', sql => $strSQL};
};

# -- For deleting one tag

del '/LibraryFields/tags/:id.:format' => sub {

	MAP::API->check_authorization( params->{token}, request->header("Origin") );

	my $field_tagid = params->{id} || MAP::API->fail( "id on url is missing" );
	my $field_tagText = 'aa';

	my $dbh = MAP::API->dbh();

	my $strSQL = 'EXEC usp_formmaker_FieldTagAddEdit
		@field_tagid = ?,
		@deleteYN = 1,
		@field_tagText = ?
	';

	my $sth = $dbh->prepare( $strSQL, );

	$sth->execute( $field_tagid, $field_tagText ) or MAP::API->fail( $sth->errstr );

	my $new_FieldTagID = 0;
	while ( my $record = $sth->fetchrow_hashref())
	{
		$new_FieldTagID = $record->{"fieldTagID"};
	}


	MAP::API->normal_header();

	return { status => 'success', response => 'Succcess', sql => $strSQL, FieldTagID => $field_tagid};
};

dance;
