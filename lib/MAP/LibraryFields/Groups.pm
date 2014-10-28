package MAP::LibraryFields::Groups;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use DBI;


our $VERSION = '0.1';


options '/LibraryFields/groups.:format' => sub {
	MAP::API->options_header();
};


options '/LibraryFields/groups/:id.:format' => sub {
	MAP::API->options_header();
};

options '/LibraryFields/groups/fields/:id.:format' => sub {
	MAP::API->options_header();
};




# list all groups
get '/LibraryFields/groups.:format' => sub {
	
	
	MAP::API->check_authorization_simple( params->{token}, request->header("Origin") );
	
	my $strColumns = params->{columns} || 'GroupName,Tip,Label';
	my @columns = split(/,/, $strColumns);
	my @rows;
	
	my $dbh = MAP::API->dbh();

	my $strSQL = 'exec usp_GetFieldGroupList';
	#exec USP_FieldGroupList @GroupID = 0
	#exec usp_GetFieldGroupList
	
	my $sth = $dbh->prepare( $strSQL, );
	
	$sth->execute( ) or MAP::API->fail( $sth->errstr );
   

	while ( my $record = $sth->fetchrow_hashref()) 
	{
		my @values;
		foreach (@columns) {
			if (defined($record->{$_})) {
				push @values, $record->{$_};
			}
			else
			{
				push @values, "";
			}
		}
		
		my $row = {
			id =>	$record->{"GroupID"},
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



post '/LibraryFields/groups.:format' => sub {

	MAP::API->check_authorization( params->{token}, request->header("Origin") );
      
	my $GroupID = 0;
	my $GroupName = params->{GroupName} || MAP::API->fail( "Group name is missing" );
	my $Tip = params->{Tip} || '';
	my $Label = params->{Label} || MAP::API->fail( "Label can not be empty" );
	my $FieldTagId = params->{FieldTagId};
	my $FieldIDSeqList = params->{FieldIDSeqList} || MAP::API->fail( "You can not save a group without fields" );

	my $dbh = MAP::API->dbh();

	my $strSQL = 'EXEC USP_FieldGroupSave
		@GroupID = ?, 
	    @GroupName = ?, 
		@Tip = ?,
		@Label = ?,
		@FieldTagId = 0,
		@FieldIDSeqList = ?, 
		@deleteYN = 0
	';
	
	my $sth = $dbh->prepare( $strSQL, );
	
	$sth->execute( $GroupID, $GroupName, $Tip, $Label, $FieldIDSeqList ) or MAP::API->fail( $sth->errstr );
   
	my $new_GroupId = 0;
	while ( my $record = $sth->fetchrow_hashref()) 
	{
		$new_GroupId = $record->{"GroupID"};
	}
   
	
	MAP::API->normal_header();

	return { status => 'success', response => 'Succcess', sql => $strSQL, GroupID => $new_GroupId};
};


put '/LibraryFields/groups.:format' => sub {

	MAP::API->check_authorization( params->{token}, request->header("Origin") );
   
	my $GroupID = params->{GroupID} || MAP::API->fail( "GroupID is missing" );
	my $GroupName = params->{GroupName} || MAP::API->fail( "Group name is missing" );
	my $Tip = params->{Tip};
	my $Label = params->{Label} || MAP::API->fail( "Label can not be empty" );
	my $FieldTagId = 0;
	my $FieldIDSeqList = params->{FieldIDSeqListing} || MAP::API->fail( "You can not save a group without fields" );

	my $dbh = MAP::API->dbh();

	my $strSQL = 'EXEC USP_FieldGroupSave
		@GroupID = '.$GroupID.',
	    @GroupName = \''.$GroupName.'\', 
		@Tip  = \''.$Tip.'\',
		@Label = \''.$Label.'\',
		@FieldTagId= \''.$FieldTagId.'\',
		@FieldIDSeqList = \''.$FieldIDSeqList.'\', 
		@deleteYN   = 0
	';
	
	my $sth = $dbh->prepare( $strSQL, );
	
	$sth->execute( ) or MAP::API->fail( $sth->errstr );
   
	my $changed_GroupId = 0;
	while ( my $record = $sth->fetchrow_hashref()) 
	{
		$changed_GroupId = $record->{"GroupID"};
	}
   
	
	MAP::API->normal_header();

	return { status => 'success', response => 'Succcess', sql => $strSQL, GroupID => $changed_GroupId, FieldIDSeqList => $FieldIDSeqList};
};



# -- For deleting entire group
# EXEC USP_FieldGroupSave 1,'Test','Enter Contact','Contact','5','204/1',1
del '/LibraryFields/groups/:id.:format' => sub {
		
	MAP::API->check_authorization( params->{token}, request->header("Origin") );
   
	my $GroupID = params->{id} || MAP::API->fail( "GroupID is missing" );
	my $GroupName = '';
	my $Tip = '';
	my $Label = '';
	my $FieldTagId = '';
	my $FieldIDSeqList = '';

	my $dbh = MAP::API->dbh();

	my $strSQL = 'EXEC USP_FieldGroupSave
		@GroupID = ?, 
	    @GroupName = ?, 
		@Tip  = ?,
		@Label = ?,
		@FieldTagId= ?,
		@FieldIDSeqList = ?, 
		@deleteYN   = 1
	';
	
	my $sth = $dbh->prepare( $strSQL, );
	
	$sth->execute( $GroupID, $GroupName, $Tip, $Label, $FieldTagId, $FieldIDSeqList ) or MAP::API->fail( $sth->errstr );
   
	#my $deleted_GroupId = 0;
	#while ( my $record = $sth->fetchrow_hashref()) 
	#{
	#	$deleted_GroupId = $record->{"GroupID"};
	#}
	
	MAP::API->normal_header();

	return { status => 'success', response => 'Succcess', sql => $strSQL, GroupID => $GroupID};
};


# list fields assigned to a group
get '/LibraryFields/groups/fields/:id.:format' => sub {
	
	
	MAP::API->check_authorization( params->{token}, request->header("Origin") );
	
	my $GroupID = params->{id} || MAP::API->fail( "id is missing on url" );
	my $strColumns = params->{columns} || 'Type,Fieldname,label,caption,textdefault,tips,text_size,field_format,sequence';
	my @columns = split(/,/, $strColumns);
	my @rows;
	
	my $dbh = MAP::API->dbh();

	my $strSQL = 'exec USP_GetFields @GroupID = ' . $GroupID;
	
	my $sth = $dbh->prepare( $strSQL, );
	
	$sth->execute(  ) or MAP::API->fail( $sth->errstr );
   

	while ( my $record = $sth->fetchrow_hashref()) 
	{
		my @values;
		foreach (@columns) {
			if (defined($record->{$_})) {
				push @values, $record->{$_};
			}
			else
			{
				push @values, "";
			}
		}
		
		my $row = {
			id =>	$record->{"FieldID"},
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

dance;
