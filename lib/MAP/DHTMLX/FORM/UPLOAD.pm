package MAP::DHTMLX::FORM::UPLOAD;
use Dancer ':syntax';
use Data::Dump qw(dump);
our $VERSION = '0.1';

prefix '/dhtmlx/form';
my $root_dir = '/var/www/html/userhome/upload_files/';
my $web_path = 'userhome/upload_files/';

options '/upload.:format' => sub {
	MAP::API->options_header();
};

post '/upload.:format' => sub{
    MAP::API->check_authorization_simple( params->{token}, request->header("Origin") );
    MAP::API->normal_header();


    my $agency_id = params->{agency_id};
		my $user_id = params->{user_id};
		my $path = $root_dir . '/' . $agency_id . '/';
		my $filename = $agency_id  . '_' . $user_id . '_' . time . '_' . params->{file};


		unless(-e $root_dir){
			mkdir($root_dir, 0777);
		}


		unless(-e $path){
			mkdir($path, 0777);
		}


    if ( params->{mode} eq "html5" || params->{mode} eq "flash" ) {
        my $uploaded_file = request->upload('file');
        $uploaded_file->copy_to($path . $filename);
        #debug "My Log 2: " . ref($uploaded_file);
        return {
            state => true,
            name => $filename
        };
    }

    if ( params->{mode} eq "html4" ) {
        if ( params->{actions} eq "cancel" ) {
            return {    state => 'cancelled'    };
        }
        else
        {
            my $uploaded_file = request->upload('file');
            $uploaded_file->copy_to($path . $filename);
            return {
                state => true,
                name => $filename,
                size => $uploaded_file->size()
            };
        }
    }
};
dance;
