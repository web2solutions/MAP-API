package MAP::Forms::Rules;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use utf8;
use Encode       qw( encode );
use DBI;
use Data::Dump qw(dump);


our $VERSION = '0.1';

my $collectionName = 'rules';

my $primaryKey = 'rule_id';

my $tableName = 'formmaker_fields_rules';
my $tableName_pages = 'formmaker_pages_rules';
my $tableName_notifications = 'formmaker_notification_rules';

my $defaultColumns = 'rule_id,form_id,target_id,source_id,condition,source_value';








my $relationalColumn = 'form_id'; # undef

prefix '/forms/:'. $relationalColumn; # | undef

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
   
   
   # fields rules
   my $strSQL = 'SELECT '.$strColumns.' FROM '.$tableName.' WHERE '. $strSQLstartWhere .' ' . $sql_filters . ' '. $sql_ordering . '';
   my $sth = $dbh->prepare( $strSQL, );
   $sth->execute() or MAP::API->fail( $sth->errstr . "   ---   " . $strSQL );
   my @records_fields;
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
		push @records_fields, $row;
   }
   
   
   # fields pages
   my $strSQL_pages = 'SELECT '.$strColumns.' FROM '.$tableName_pages.' WHERE '. $strSQLstartWhere .' ' . $sql_filters . ' '. $sql_ordering . '';
   $sth = $dbh->prepare( $strSQL_pages, );
   $sth->execute() or MAP::API->fail( $sth->errstr . "   ---   " . $strSQL );
   my @records_pages;
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
		push @records_pages, $row;
   }
   
   
   
   # notifications
   my $strSQL_notifications = 'SELECT '.$strColumns.' FROM '.$tableName_notifications.' WHERE '. $strSQLstartWhere .' ' . $sql_filters . ' '. $sql_ordering . '';
   $sth = $dbh->prepare( $strSQL_notifications, );
   $sth->execute() or MAP::API->fail( $sth->errstr . "   ---   " . $strSQL_notifications );
   my @records_notifications;
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
		push @records_notifications, $row;
   }
   
   
   my $tableName_notification = 'formmaker_notification_rule';
   my $defaultColumns_notification = 'notification_id,form_id,notification_name,rule_match,rule_enable,emailto,template_id';
   my $primaryKey_notification = "notification_id";
   @columns = split(/,/, $defaultColumns_notification);
   #$strColumns = MAP::API->normalizeColumnNames( $strColumns, $defaultColumns );
   # notification
   my $strSQL_notification = 'SELECT '.$defaultColumns_notification.' FROM '.$tableName_notification.' ORDER BY '.$primaryKey_notification.' ASC';
   $sth = $dbh->prepare( $strSQL_notification, );
   $sth->execute() or MAP::API->fail( $sth->errstr . "   ---   " . $strSQL_notification );
  
   my @notification;
  
   while ( my $record = $sth->fetchrow_hashref()) 
   {
		#push @records, $record;
		my @values;
		my $row = {
			id =>	$record->{$primaryKey_notification},
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
		push @notification, $row;
   }
   
   #$dbh->disconnect();
   
   MAP::API->normal_header();
   
   return {
		   status => 'success',
		   response => 'Succcess',
		   formmaker_fields_rules => [@records_fields],
		   formmaker_pages_rules => [@records_pages],
		   formmaker_notification_rule => [@notification],
		   formmaker_notification_rules => [@records_notifications],
		   sql =>  $strSQL,
		   sql_pages =>  $strSQL_pages,
		   sql_notification => $strSQL_notification,
		   sql_notifications => $strSQL_notifications,
		   sql_filters => $sql_filters,
		   sql_ordering => $sql_ordering
		   
   };
};

dance;