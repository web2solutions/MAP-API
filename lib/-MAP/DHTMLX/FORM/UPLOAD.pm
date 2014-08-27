package MAP::DHTMLX::FORM::UPLOAD;
use Dancer ':syntax';
use Data::Dump qw(dump);
our $VERSION = '0.1';

prefix '/dhtmlx/form';
my $root_dir = '/var/www/html/userhome/FormBuilder/';

options '/upload.:format' => sub {
	MAP::API->options_header();
};

post '/upload.:format' => sub{ 
    #MAP::API->check_authorization( params->{token}, request->header("Origin") );
    MAP::API->normal_header();

    my $path = $root_dir;
    my $filename = params->{file};
    
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