package MAP::Forms::Entries;
use Dancer ':syntax';
use Dancer::Plugin::REST;

use Encode qw( encode decode );
use Deep::Encode;
use DBI;
use JSON::Simple;
use Data::Dump qw(dump);

our $VERSION = '0.1';
my $collectionName = 'entries';
my $tableName = 'formmaker_properties';
my $primaryKey = 'form_id';
my $defaultColumns = 'data_id,user_id,key_id,connId,connectionId';

my $relationalColumn = undef; # undef

prefix '/forms'; # | undef

options '/'.$collectionName.'/:'.$primaryKey.'/:type.:format' => sub {
    MAP::API->options_header();
};

options '/'.$collectionName.'/:'.$primaryKey.'/:user_id/:type.:format' => sub {
    MAP::API->options_header();
};

get '/'.$collectionName.'/:'.$primaryKey.'/:type.:format' => sub {
    my $item_id  = params->{$primaryKey} || MAP::API->fail( "id is missing on url" );
    my $formname = MAP::API->SelectOne("SELECT formname FROM $tableName
                                       WHERE form_id = ?",
                                       $item_id) || MAP::API->fail( "formname not exist" );

    my $agency_id = request->header("X-AId") || MAP::API->fail( "please provide agency_id" );

    my $strSQLtable = '
        IF OBJECT_ID(\'dbo.formmaker_'.$agency_id .'_'.$formname.'\', \'U\') IS NULL
            CREATE TABLE dbo.formmaker_'.$agency_id .'_'.$formname.'(
                    [data_id] INT not null Identity(1,1),
                    [user_id] INT,
                    [key_id] INT,
                    [connId] INT,
                    [connectionId] INT,
                    CONSTRAINT formmaker_'.$agency_id .'_'.$formname.'_pkey PRIMARY KEY (data_id)
        );
    ';

    MAP::API->Exec($strSQLtable);

    my $sel = undef;

    $sel = MAP::API->SelectARef("SELECT * FROM dbo.formmaker_".$agency_id."_".$formname);

    my $j = new JSON::Simple;

    $j->Open('rows');

    for(@$sel){
        $_->{user} = MAP::API->SelectOne("SELECT first_name FROM user_accounts WHERE user_id=?", $_->{user_id});
        $j->Object(
            {
                id => $_->{user_id},
                data => [$_->{data_id}, $_->{connId}, $_->{connectionId}, $_->{user}]
            }
        );
    }

    $j->Close;

    MAP::API->normal_header();

    return $j->Print
};

get '/'.$collectionName.'/:'.$primaryKey.'/:user_id/:type.:format' => sub {
    my $form_id = param($primaryKey);
    my $agency_id = param('agency_id');
    my $user_id = param('user_id');
    my $type = param('type');
    my $formname = MAP::API->SelectOne("SELECT formname FROM $tableName
                                   WHERE form_id = ?",
                                   $form_id) || MAP::API->fail( "formname not exist" );

    my $sel = undef;

    $sel = MAP::API->SelectRow("SELECT * FROM dbo.formmaker_".$agency_id."_".$formname."
                                    WHERE user_id=?", $user_id);

    my $j = new JSON::Simple;

    while (my ($key, $value) = each(%$sel)) {
        $j->Object($key => $value);
    }

    MAP::API->normal_header();

    return {
        status => 'success',
        response => 'Metadata for form '.$form_id.' was saved on ' . $collectionName,
        metadata_file => $j->Print
    };
};

del '/'.$collectionName.'/:'.$primaryKey.'/:type.:format' => sub {
    my $form_id = param($primaryKey);
    my $agency_id = param('agency_id');
    my $user_id = param('user_id');
    my $type = param('type');
    my $formname = MAP::API->SelectOne("SELECT formname FROM $tableName
                                   WHERE form_id = ?",
                                   $form_id) || MAP::API->fail( "formname not exist" );

    MAP::API->Exec("DELETE FROM dbo.formmaker_".$agency_id."_".$formname."
                       WHERE user_id=?", $user_id);

    MAP::API->normal_header();

    return {
        status => 'success',
        response => 'Deleted with sucess'
    };
};

get '/test' => sub {
    return 1;
};

dance;
