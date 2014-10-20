package MAP::LibraryFields::Fields;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use DBI;
#use JSON;


our $VERSION = '0.1';


options '/LibraryFields.:format' => sub {
	MAP::API->options_header();
};

options '/LibraryFields/:id.:format' => sub {
	MAP::API->options_header();
};

options '/LibraryFields/assigntags/:id.:format' => sub {
	MAP::API->options_header();
};

get '/LibraryFields.:format' => sub {
   
   MAP::API->check_authorization( params->{token}, request->header("Origin") );
   
   my $strColumns = params->{columns} || 'type,name,label,caption,textdefault,tips,text_size,field_format';
   #type,name,label,caption,value,tooltip,text_size
   my $searchcriteria = params->{searchcriteria} || "";
   
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
		
		#----- eletronic forms
		my $strFormsNames = '';
		my $sth2 = $dbh->prepare( "SELECT F.FormLabel,F.Formname
								 FROM Formmaker_properties F
								 INNER JOIN Formmaker_pages P ON F.Form_id=P.Form_id
								 INNER JOIN Formmaker_Fields L ON P.Page_id=L.Page_id
								 WHERE L.Field_id = ?;", );
		$sth2->execute($record->{"FieldID"});
		while ( my $record2 = $sth2->fetchrow_hashref())
		{
			$strFormsNames = $strFormsNames . $record2->{"FormLabel"} . '<br>';
		}
		
		push @values, $strFormsNames;
		#@values, '';
		
		foreach (@columns) {
			#print $_;
			if (defined($record->{$_})) {
				
				if ( $_ eq "Fieldname") {
					
					my @ar = split('_' . $record->{"FieldID"}, $record->{$_} );
					
					push @values, $ar[0];
				}
				else
				{
					push @values, $record->{$_};
				}
			}
			else
			{
				push @values, "";
			}
			
			
		}
		
		$totalCount = $record->{"TotalCount"};
		
		
		#----- eletronic forms
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
	my $Type   	= params->{type} || MAP::API->fail( "type can not be empty" );
	my $type_standard   	= params->{type_standard} || MAP::API->fail( "type_standard can not be empty" );
	my $label  	= params->{label} || MAP::API->fail( "label can not be empty" );
	my $caption	= params->{caption} || MAP::API->fail( "caption can not be empty" );
	my $Fieldname = params->{name} || MAP::API->fail( "name can not be empty" );
	my $tips = params->{tips} || '';
	my $size = params->{size} || 0;
	my $textareacolumn = params->{textareacolumn} || 0;
	my $textarearow = params->{textarearow} || 0;
	my $text_size = params->{text_size} || 200;
	my $textdefault = params->{columns} || '';
	my $field_format = params->{columns} || '';
	my $RelationshipSubTypeID = params->{columns} || 0;
	my $RelationshipTypeID = params->{columns} || 0;
	my $Flg = 1; # add
	
	my $pay_to_cairs	= params->{pay_to_cairs} || 'N';
	my $payment_default_price	= params->{payment_default_price} || 0;
	my $allow_User_To_enter_value	= params->{allow_User_To_enter_value} || 'N';
	my $payment_category_id	= params->{payment_category_id} || 0;
	my $payment_subcategory_id	= params->{payment_subcategory_id} || 0;
	
	#my $json = new JSON;
	my $optionString = params->{options} || {};	
	my $objJSON =  from_json( $optionString ) || MAP::API->fail( "Can not decode the optionString json string" );
	

	
	my $dbh = MAP::API->dbh();

	my $strSQL = 'EXEC  usp_Formmaker_LibFieldAddEdit
		@PageID 	= ?,
		@Type   	= ?,	
		@label  	= ?,
		@caption	= ?,
		@Fieldname 	= ?, 
		@tips 		= ?,
		@size 		= ?,
		@textareacolumn = ?,
		@textarearow  	= ?,
		@text_size  	= ?,
		@textdefault 	= ?,
		@field_format 	= ?,
		@RelationshipSubTypeID = ?,
		@RelationshipTypeID = ?,
		@Flg 		= ?,
		@pay_to_cairs	= ?,
		@payment_default_price	= ?,
		@allow_User_To_enter_value	= ?,
		@payment_category_id	= ?,
		@payment_subcategory_id	= ?,
		@type_standard = ?
		
	';
	
	my $sth = $dbh->prepare( $strSQL, );
	
	$sth->execute( $PageID, $Type, $label, $caption, $Fieldname, $tips, $size, $textareacolumn, $textarearow, $text_size, $textdefault, $field_format, $RelationshipSubTypeID, $RelationshipTypeID, $Flg, $pay_to_cairs, $payment_default_price, $allow_User_To_enter_value, $payment_category_id, $payment_subcategory_id, $type_standard ) or MAP::API->fail( $sth->errstr . " ------- " . $strSQL);
   
	my $FieldID= 0;
	while ( my $record = $sth->fetchrow_hashref()) 
	{
		$FieldID = $record->{"FieldID"};
	}
	
	my $ttoptions = 0;
	for(@$objJSON)
	{
			
		$sth = $dbh->prepare( 'EXEC usp_Form_FieldOptionAddEdit
			@option_id = 0,
			@DeleteYN = 0,
			@FieldID = ?,
			@optionname = ?,
			@asdefault = ?,
			@empty = NULL,
			@key_id = 0,
			@FieldOptionSeq = ?', );
	
		$sth->execute( $FieldID, $_->{optionname}, $_->{asdefault}, $_->{FieldOptionSeq} ) or MAP::API->fail( "Field saved but: " . $sth->errstr );
		
		$ttoptions = $ttoptions + 1;
	}
	
   
	MAP::API->normal_header();

	return {
		status => 'success', response => 'Field added', sql => $strSQL, FieldID => $FieldID, options => $optionString, newoptions => $ttoptions
	};
};


put '/LibraryFields.:format' => sub {
   
   MAP::API->check_authorization( params->{token}, request->header("Origin") );
   
   
	my $PageID 	= params->{PageID} || -20;
	my $FieldID   	= params->{FieldID} || MAP::API->fail( "FieldID can not be empty" );	
	my $Type   	= params->{type} || MAP::API->fail( "type can not be empty" );
	my $type_standard   	= params->{type_standard} || MAP::API->fail( "type_standard can not be empty" );
	my $label  	= params->{label} || MAP::API->fail( "label can not be empty" );
	my $caption	= params->{caption} || MAP::API->fail( "caption can not be empty" );
	my $Fieldname = params->{name} || MAP::API->fail( "name can not be empty" );
	my $tips = params->{tips} || '';
	my $size = params->{size} || 0;
	my $textareacolumn = params->{textareacolumn} || 0;
	my $textarearow = params->{textarearow} || 0;
	my $text_size = params->{text_size} || 200;
	my $textdefault = params->{columns} || '';
	my $field_format = params->{columns} || '';
	my $RelationshipSubTypeID = params->{columns} || 0;
	my $RelationshipTypeID = params->{columns} || 0;
	my $Flg = 2; # edit
	
	my $pay_to_cairs	= params->{pay_to_cairs} || 'N';
	my $payment_default_price	= params->{payment_default_price} || 0;
	my $allow_User_To_enter_value	= params->{allow_User_To_enter_value} || 'N';
	my $payment_category_id	= params->{payment_category_id} || 0;
	my $payment_subcategory_id	= params->{payment_subcategory_id} || 0;
	
	#my $json = new JSON;
	my $optionString = params->{options} || {};	
	my $objJSON =  from_json( $optionString ) || MAP::API->fail( "Can not decode the optionString json string" );
	

	
	my $dbh = MAP::API->dbh();

	my $strSQL = 'EXEC  usp_Formmaker_LibFieldAddEdit
		@PageID 	= ?,
		@Type   	= ?,	
		@label  	= ?,
		@caption	= ?,
		@Fieldname 	= ?, 
		@tips 		= ?,
		@size 		= ?,
		@textareacolumn = ?,
		@textarearow  	= ?,
		@text_size  	= ?,
		@textdefault 	= ?,
		@field_format 	= ?,
		@RelationshipSubTypeID = ?,
		@RelationshipTypeID = ?,
		@Flg 		= ?,
		@FieldID  = ?,
		@pay_to_cairs	= ?,
		@payment_default_price	= ?,
		@allow_User_To_enter_value	= ?,
		@payment_category_id	= ?,
		@payment_subcategory_id	= ?,
		@type_standard = ?
	';
	
	my $sth = $dbh->prepare( $strSQL, );
	
	$sth->execute( $PageID, $Type, $label, $caption, $Fieldname, $tips, $size, $textareacolumn, $textarearow, $text_size, $textdefault, $field_format, $RelationshipSubTypeID, $RelationshipTypeID, $Flg, $FieldID,  $pay_to_cairs, $payment_default_price, $allow_User_To_enter_value, $payment_category_id, $payment_subcategory_id, $type_standard ) or MAP::API->fail( $sth->errstr );
   
	$FieldID = 0;
	while ( my $record = $sth->fetchrow_hashref()) 
	{
		$FieldID = $record->{"FieldID"};
	}
	
	my $ttoptions = 0;
	for(@$objJSON)
	{
			
		$sth = $dbh->prepare( 'EXEC usp_Form_FieldOptionAddEdit
			@option_id = ?,
			@DeleteYN = 0,
			@FieldID = ?,
			@optionname = ?,
			@asdefault = ?,
			@empty = NULL,
			@key_id = 0,
			@FieldOptionSeq = ?', );
	
		$sth->execute( $_->{option_id}, $FieldID, $_->{optionname}, $_->{asdefault}, $_->{FieldOptionSeq} ) or MAP::API->fail( "Field saved but: $FieldID " . $sth->errstr );
		
		$ttoptions = $ttoptions + 1;
	}
	
   
	MAP::API->normal_header();

	return {
		status => 'success', response => 'Field saved', sql => $strSQL, FieldID => $FieldID, options => $optionString, newoptions => $ttoptions
	};
};


del '/LibraryFields/:id.:format' => sub {
   
   MAP::API->check_authorization( params->{token}, request->header("Origin") );
	
	my $FieldID   	= params->{id} || MAP::API->fail( "id is missing on url" );	
	
	my $dbh = MAP::API->dbh();
	my $strSQL = 'exec usp_Formmaker_FieldsDelete  @FieldId = ?';
	my $sth = $dbh->prepare( $strSQL, );
	$sth->execute( $FieldID ) or MAP::API->fail( $strSQL );
   
	MAP::API->normal_header();

	return {
		status => 'success', response => 'Field deleted', sql => $strSQL, FieldID => $FieldID
	};
	
};


post '/LibraryFields/assigntags/:id.:format' => sub {

	MAP::API->check_authorization( params->{token}, request->header("Origin") );
   
    my $FieldID   	= params->{id} || MAP::API->fail( "id is missing on url" );	
	my $field_tagid = params->{field_tagid} || {};	
	
	my $dbh = MAP::API->dbh();

	my $strSQL = 'EXEC usp_formmaker_Field_FieldTagsAddEdit
		@Field_FieldTagId = 0,
		@deleteYN = 0,
		@FieldId = '.$FieldID.',
		@field_tagid = '.$field_tagid.',
		@ISGroup = 0';
	my $sth = $dbh->prepare( $strSQL, );
	$sth->execute(  ) or MAP::API->fail( $sth->errstr );
	my $FieldTagId = 0;
	while ( my $record = $sth->fetchrow_hashref()) 
	{
		$FieldTagId = $record->{"FieldTagId"};
	}
   
	
	MAP::API->normal_header();

	return {
			status => 'success',
			response => 'Succcess',
			sql => $strSQL,
			FieldTagId => $FieldTagId
	};
};


del '/LibraryFields/assigntags/:id.:format' => sub {

	MAP::API->check_authorization( params->{token}, request->header("Origin") );
   
    #my $FieldID   	= params->{id} || MAP::API->fail( "id is missing on url" );	
	my $field_tagid = params->{id} || {};	
	
	my $dbh = MAP::API->dbh();

	my $strSQL = 'EXEC usp_formmaker_Field_FieldTagsAddEdit
		@Field_FieldTagId = '.$field_tagid.',
		@deleteYN = 1,
		@FieldId = 0,
		@field_tagid = 0,
		@ISGroup = 0';
	my $sth = $dbh->prepare( $strSQL, );
	$sth->execute(  ) or MAP::API->fail( $strSQL );
	my $FieldTagId = 0;
	while ( my $record = $sth->fetchrow_hashref()) 
	{
		$FieldTagId = $record->{"FieldTagId"};
	}
   
	
	MAP::API->normal_header();

	return {
			status => 'success',
			response => 'Succcess',
			sql => $strSQL,
			FieldTagId => $FieldTagId
	};
};




get '/LibraryFields/search.:format' => sub {
   
   MAP::API->check_authorization( params->{token}, request->header("Origin") );
   
   my $strColumns = params->{columns} || 'Type,Fieldname,label,caption,textdefault,tips,text_size,field_format';
   my $tags = params->{tags} || '';
   my $label = params->{label} || '';
   
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
   my $totalCount = 0;
   
   #my $sth = $dbh->prepare( "SELECT COUNT(".$primaryKey.") as total_count FROM ".$tableName." WHERE 1=1;", );
   #$sth->execute();
   
   #while ( my $record = $sth->fetchrow_hashref())
   #{
	#	$totalCount = 52; #$record->{"total_count"}
#}

   my $strSQL = '';
   if ( defined(params->{tags}) ) {
		$strSQL = 'EXEC USP_FieldSearchByTag @FieldTags = ?, @StrtRow = ?, @Count = ?';
   }
   elsif( defined(params->{label}) ) {
		$strSQL = 'EXEC usp_SearchLibraryField @FieldCaption = ?, @StrtRow = ?, @Count = ?';
   }

   #   @FieldTags='', @StrtRow = 1, @Count = 100
   
   #my $strSQL = 'EXEC USP_ListAllLibraryFields 2217,'.$posStart.','.$count.''; #'EXEC USP_ListAllLibraryFields @form_id = 2217, @StRow = '.$posStart.', @EndRow = '.$count; # @PosStart = '.$posStart.', @Count = '.$count.'

   my $sth = $dbh->prepare( $strSQL, );
   
   if ( defined(params->{tags}) ) {
		$sth->execute( $tags, $posStart, $count );
   }
   elsif( defined(params->{label}) ) {
		$sth->execute( $label, $posStart, $count );
   }
   
   
   
   
   my $idfake = 1;
   while ( my $record = $sth->fetchrow_hashref())
   {
		my @values;
		
		
		#----- eletronic forms
		my $strFormsNames = '';
		my $sth2 = $dbh->prepare( "SELECT F.FormLabel,F.Formname
								 FROM Formmaker_properties F
								 INNER JOIN Formmaker_pages P ON F.Form_id=P.Form_id
								 INNER JOIN Formmaker_Fields L ON P.Page_id=L.Page_id
								 WHERE L.Field_id = ?;", );
		$sth2->execute($record->{"FieldID"});
		while ( my $record2 = $sth2->fetchrow_hashref())
		{
			$strFormsNames = $strFormsNames . $record2->{"FormLabel"} . '<br>';
		}
		
		push @values, $strFormsNames;
		#@values, '';
		
		
		
		
		foreach (@columns) {
			#print $_;
			if (defined($record->{$_})) {
				
				if ( $_ eq "Fieldname") {
					
					my @ar = split('_' . $record->{"FieldID"}, $record->{$_} );
					
					push @values, $ar[0];
				}
				else
				{
					push @values, $record->{$_};
				}
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
   
   #$totalCount = $totalCount - 1;
   
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

dance;
