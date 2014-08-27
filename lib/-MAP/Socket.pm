package MAP::Socket;

use Carp;
use Dancer ':syntax';
use utf8;
use Encode       qw( encode );
use Moose;

#use lib "/opt/MAP-API/lib/"; # centos live production server - test host
#use lib "/opt/MAP-API/lib/MAP"; # centos live production server - test host
#use lib "/opt/MAP-API/"; # centos live production server - test host
#use lib "d:/wwwroot/mark/www/MAP-API/lib/"; # window - live procution web2 website
#use lib "z:/wwwroot/mark/www/MAP-API/lib/"; # window - live procution web2 website

use AnyMQ;
use Plack;
use Plack::Request;
use Web::Hippie;

our $VERSION = 0.0100;# VERSION

our $subject = 'welcome';

my $bus;
sub _bus{
    #return $bus if $bus;
    return $bus = AnyMQ->new_with_traits(
				       traits => ['AMQP'],
					   host   => 'localhost',
                                       port   => 5672,
                                       user   => 'dhtmlx',
                                       pass   => 'fuzzy24k',
                                       vhost  => 'dhtmlx.com.br',
                                       exchange => $subject,
                                       queue       => 'welcome',
									   #routing_key => 'welcome2'
                                   );
}

## topic name is the same that routing_key
my $topic = _bus->topic({
		name => 'welcome',
        #queue       => 'welcome3'
		#routing_key => 'rk for welcome3'
}); # 

#my $topic = _bus->topic('topic name');


our @users;

my $triggers = {};

set plack_middlewares_map => {
    '/_hippie' => [
        [ '+Web::Hippie' ],
        [ '+Web::Hippie::Pipe', bus => _bus ],
    ]
};

# /new_listener and /message are routes needed by Web::Hippie

get '/new_listener' => sub {
	my $env = request->env;
    my $room  = $env->{'hippie.args'};
    my $bus       = $env->{'hippie.bus'}; # AnyMQ bus
    my $listener  = $env->{'hippie.listener'}; # AnyMQ::Queue
    my $client_id = $env->{'hippie.client_id'}; # client id
    my $handle = $env->{'hippie.handle'}; # client id
    
	
	#$env->{'hippie.listener'}->subscribe( $routing_key );
    
	if (defined $triggers->{on_new_listener}) {
        $triggers->{on_new_listener}->();
    }

    $listener->subscribe( $topic );
};

get '/message' => sub {
	my $json_string = request->env->{'hippie.message'}->{msg} || '{ message : "error"}';
	my $json_bytes = encode('UTF-8', $json_string);
	my $hash_message = JSON->new->utf8->decode($json_string) or die "unable to decode" ;
	my $client_id = request->env->{'hippie.client_id'};
	my $msg;
	$msg->{msg} = $hash_message->{message};
	$msg->{type} = $hash_message->{type} || 'message'; # disconnect, message, new_user
	
	if( $msg->{type} eq "new_username" )
	{
		if(defined( $hash_message->{person} ))
		{
			$msg->{person} = $hash_message->{person};
			
			$msg->{person}->{client_id} = $client_id;
			
			push @users, $msg->{person};
			
			$msg->{users} = [@users];
		}
	}
	
	if( $msg->{type} eq "disconnect" )
	{
		my $index = 0;
		$index++ until $users[$index]->{client_id} eq $client_id;
		splice(@users, $index, 1);
		
		$msg->{users} = [@users];
	}

		
	
	
	
	$msg->{time} = time;
    $msg->{address} = request->env->{REMOTE_ADDR};
	
	$msg->{client_id} = $client_id;
	#debug $client_id;
	
	$msg->{routing_key} = $subject;
	
	
	$topic->publish($msg);
};




get '/socket' => sub {template 'socket'};
	
any '/send_msg' => sub {
    my $msg = params->{msg};
    ws_send $msg;
};

my $ws_send = sub {
    my $msg = shift;
    $topic->publish({ msg => $msg });
};

#register ws_on_message => sub {
#    $triggers->{on_message} = shift;
#};

#register ws_on_new_listener => sub {
#    $triggers->{on_new_listener} = shift;
#};

sub ws_send {
    $ws_send->(@_);
};

#register websocket_send => sub {
#    carp "'websocket_send' is deprecated. You should use 'ws_send' instead.";
#    $ws_send->(@_);
#};








    

dance;
