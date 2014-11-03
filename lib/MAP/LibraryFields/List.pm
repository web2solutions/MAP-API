package MAP::DHTMLX::GRID::FEED;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use DBI;
use Encode qw( encode decode );
use Data::Recursive::Encode;


our $VERSION = '0.1';


options '/LibraryFields.:format' => sub {
	MAP::API->options_header();
};

get '/LibraryFields.:format' => sub {

   MAP::API->check_authorization_simple( params->{token}, request->header("Origin") );

   my $strColumns = params->{columns} || 'FieldType,FieldName,Description,RecordScope,MultiRecord';
   my $searchcriteria = params->{searchcriteria} || "1_Type1";

   # Field Type,Name,Description,Record Scope,Multi-Record

   #FieldType,FieldName,FormName,FORM_ID,PAGE_ID,library_field_name,text_size'

   #my $primaryKey = params->{primary_key};
   #my $tableName = params->{table_name};
   my $count = params->{count} || 100;
   my $posStart = params->{posStart} || 0;
   $count = $count + 1;
   $posStart = $posStart + 1;
   my @rows;
   my @columns = split(/,/, $strColumns);

   my $dbh = MAP::API->dbh();
   my $totalCount = 1;

   #my $sth = $dbh->prepare( "SELECT COUNT(".$primaryKey.") as total_count FROM ".$tableName." WHERE 1=1;", );
   #$sth->execute();

   #while ( my $record = $sth->fetchrow_hashref())
   #{
	#	$totalCount = 52; #$record->{"total_count"}
#}

   my $strSQL = "EXEC usp_GetLibraryFieldLIst '".$searchcriteria."',".$posStart.",".$count."";

   #my $strSQL = 'EXEC USP_ListAllLibraryFields 2217,'.$posStart.','.$count.''; #'EXEC USP_ListAllLibraryFields @form_id = 2217, @StRow = '.$posStart.', @EndRow = '.$count; # @PosStart = '.$posStart.', @Count = '.$count.'

   my $sth = $dbh->prepare( $strSQL, );
   $sth->execute();

   my $idfake = 1;
   while ( my $record = $sth->fetchrow_hashref())
   {
		my @values;
		foreach (@columns) {
			#print $_;
			if (defined($record->{$_})) {
				push @values, decode( 'UTF-8',$record->{$_});
			}
			else
			{
				push @values, "";
			}


		}

		$totalCount = $record->{"TotalCount"};



		my $row = {
			id =>	$record->{"FieldID"},
			data => [@values]
		 };
		push @rows, $row;
	$idfake = $idfake + 1;
    }

   $totalCount = $totalCount - 1;

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
		total_count => $totalCount,
		pos => $posStart,
		rows => [@rows],
		status => 'success', response => 'Succcess', sql => $strSQL
	};
};

post '/LibraryFields.:format' => sub {

   MAP::API->check_authorization( params->{token}, request->header("Origin") );


	my $PageID 	= params->{PageID} || -20;
	my $Type   	= params->{Type} || MAP::API->fail( "Type can not be empty" );
	my $label  	= params->{label} || MAP::API->fail( "label can not be empty" );
	my $caption	= params->{caption} || MAP::API->fail( "caption can not be empty" );
	my $Fieldname = params->{Fieldname} || MAP::API->fail( "Fieldname can not be empty" );
	my $tips = params->{tips} || '';
	my $size = params->{size} || 0;
	my $textareacolumn = params->{textareacolumn} || 0;
	my $textarearow = params->{textarearow} || 0;
	my $text_size = params->{text_size} || 200;
	my $textdefault = params->{columns} || 'Test';
	my $field_format = params->{columns} || '';
	my $RelationshipSubTypeID = params->{columns} || 0;
	my $RelationshipTypeID = params->{columns} || 0;
	my $Flg = params->{columns} || 1;

	#my $json = new JSON;
	my $optionString = params->{options} || {};
	my $objJSON =  from_json( $optionString ) || MAP::API->fail( "Can not decode the optionString json string" );



	my $dbh = MAP::API->dbh();

	my $strSQL = 'EXEC  usp_Formmaker_LibFieldAddEdit
		@PageID 	= '.$PageID.',
		@Type   	= \''.$Type.'\',
		@label  	= \''.$label.'\',
		@caption	= \''.$caption.'\',
		@Fieldname 	= \''.$Fieldname.'\' ,
		@tips 		= \''.$tips.'\',
		@size 		= '.$size.',
		@textareacolumn = '.$textareacolumn.',
		@textarearow  	= '.$textarearow.',
		@text_size  	= '.$text_size.',
		@textdefault 	= \''.$textdefault.'\',
		@field_format 	= \''.$field_format.'\',
		@RelationshipSubTypeID = '.$RelationshipSubTypeID.',
		@RelationshipTypeID = '.$RelationshipTypeID.',
		@Flg 		= '.$Flg.' ';

	my $sth = $dbh->prepare( $strSQL, );

	$sth->execute() or MAP::API->fail( $sth->errstr );

	my $library_field_id = 0;
	while ( my $record = $sth->fetchrow_hashref())
	{
		$library_field_id = $record->{"library_field_id"};
	}

	my $ttoptions = 0;
	for(@$objJSON)
	{

		$sth = $dbh->prepare( 'EXEC usp_Form_FieldOptionAddEdit
			@optionId = 0,
			@DeleteYN = 0,
			@field_id = ?,
			@optionname = ?,
			@asdefault = ?,
			@empty = NULL,
			@key_id = 0,
			@FieldOptionSeq = ?', );

		$sth->execute( $library_field_id, $_->{optionname}, $_->{asdefault}, $_->{FieldOptionSeq} ) or MAP::API->fail( "Field saved but: " . $sth->errstr );

		$ttoptions = $ttoptions + 1;
	}


	MAP::API->normal_header();

	return {
		status => 'success', response => 'Field saved', sql => $strSQL, library_field_id => $library_field_id, options => $optionString, newoptions => $ttoptions
	};
};


put '/LibraryFields.:format' => sub {

   MAP::API->check_authorization( params->{token}, request->header("Origin") );


	my $PageID 	= params->{PageID} || -20;
	my $Type   	= params->{Type} || MAP::API->fail( "Type can not be empty" );
	my $label  	= params->{label} || MAP::API->fail( "label can not be empty" );
	my $caption	= params->{caption} || MAP::API->fail( "caption can not be empty" );
	my $Fieldname = params->{Fieldname} || MAP::API->fail( "Fieldname can not be empty" );
	my $tips = params->{tips} || '';
	my $size = params->{size} || 0;
	my $textareacolumn = params->{textareacolumn} || 0;
	my $textarearow = params->{textarearow} || 0;
	my $text_size = params->{text_size} || 200;
	my $textdefault = params->{columns} || 'Test';
	my $field_format = params->{columns} || '';
	my $RelationshipSubTypeID = params->{columns} || 0;
	my $RelationshipTypeID = params->{columns} || 0;
	my $Flg = params->{columns} || 1;
	my $FieldID = params->{FieldID} || MAP::API->fail( "FieldID can not be empty" );

	my $json = new JSON;
	my $optionString = params->{options} || {};
	my $objJSON = $json->decode($optionString) || MAP::API->fail( "Can not decode the optionString json string" );



	my $dbh = MAP::API->dbh();

	my $strSQL = 'EXEC  usp_Formmaker_LibFieldAddEdit
		@PageID 	= '.$PageID.',
		@Type   	= \''.$Type.'\',
		@label  	= \''.$label.'\',
		@caption	= \''.$caption.'\',
		@Fieldname 	= \''.$Fieldname.'\' ,
		@tips 		= \''.$tips.'\',
		@size 		= '.$size.',
		@textareacolumn = '.$textareacolumn.',
		@textarearow  	= '.$textarearow.',
		@text_size  	= '.$text_size.',
		@textdefault 	= \''.$textdefault.'\',
		@field_format 	= \''.$field_format.'\',
		@RelationshipSubTypeID = '.$RelationshipSubTypeID.',
		@RelationshipTypeID = '.$RelationshipTypeID.',
		@Flg 		= '.$Flg.',
		,@FieldID  = '.$FieldID.' ';

	my $sth = $dbh->prepare( $strSQL, );

	$sth->execute() or MAP::API->fail( $sth->errstr );

	my $library_field_id = 0;
	while ( my $record = $sth->fetchrow_hashref())
	{
		$library_field_id = $record->{"library_field_id"};
	}

	my $ttoptions = 0;
	for(@$objJSON)
	{

		$sth = $dbh->prepare( 'EXEC usp_Form_FieldOptionAddEdit
			@optionId = 0,
			@DeleteYN = 0,
			@field_id = ?,
			@optionname = ?,
			@asdefault = NULL,
			@empty = NULL,
			@key_id = 0,
			@FieldOptionSeq = 1', );

		$sth->execute( $library_field_id, $_->{optionname} ) or MAP::API->fail( "Field saved but: " . $sth->errstr );

		$ttoptions = $ttoptions + 1;
	}


	MAP::API->normal_header();

	return {
		status => 'success', response => 'Field saved', sql => $strSQL, library_field_id => $library_field_id, options => $optionString, newoptions => $ttoptions
	};
};


dance;
