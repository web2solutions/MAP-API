package MAP::Socket;

use Carp;
use Dancer ':syntax';
use utf8;
use Encode       qw( encode decode );
use AnyMQ;
use Plack;
use Plack::Request;
use Web::Hippie;

our $VERSION = 0.0100;# VERSION

our $subject = 'welcome';

my $bus;
sub _bus {
    return $bus if $bus;
    return $bus = AnyMQ->new;
}



my $triggers = {};

set plack_middlewares_map => {
    '/_hippie' => [
        [ '+Web::Hippie' ],
        [ '+Web::Hippie::Pipe', bus => _bus ],
    ]
};

# /new_listener and /message are routes needed by Web::Hippie

get '/new_listener' => sub {
	my $env   = request->env;
    my $room  = $env->{'hippie.args'};
    my $topic = $env->{'hippie.bus'}->topic($room);
    $env->{'hippie.listener'}->subscribe($topic);
    
	if (defined $triggers->{on_new_listener}) {
        $triggers->{on_new_listener}->();
    }

    $env->{'hippie.listener'}->subscribe(_bus->topic($subject));
};

get '/message' => sub {
	my $json_string = request->env->{'hippie.message'}->{msg} || '{ message : "error"}';
	my $json_bytes = encode('UTF-8', $json_string);
	my $hash_message = JSON->new->utf8->decode($json_string) or die "unable to decode" ;
	
	my $msg;
	$msg->{msg} = $hash_message->{message};
	$msg->{type} = $hash_message->{type};
	$msg->{time} = time;
    $msg->{address} = request->env->{REMOTE_ADDR};
	my $client_id = request->env->{'hippie.client_id'};
	$msg->{client_id} = $client_id;
	#debug $client_id;
	
	$msg->{topic} = $subject;
	
	my $type = "message"; #  id, message, subscribe, disconnect
	if ( defined( $hash_message->{type} ) ) {
		if ( $hash_message->{type} ne '' ) {
			$type = $hash_message->{type};
		}
	}
	my $topic = $subject;
	if ( defined( $hash_message->{topic} ) ) {
		if ( $hash_message->{topic} ne '' )
		{
			$topic = $hash_message->{topic};
			$msg->{topic} = $topic;
			if ( $type eq "subscribe") {
				request->env->{'hippie.listener'}->subscribe( _bus->topic($topic) );
			}
			_bus->topic($topic)->publish($msg);
		}
		else
		{
			if ( $type eq "subscribe") {
				request->env->{'hippie.listener'}->subscribe( _bus->topic($topic) );
			}
			_bus->topic($topic)->publish($msg);
		}
	}
	else
	{
		if ( $type eq "subscribe") {
			request->env->{'hippie.listener'}->subscribe( _bus->topic($topic) );
		}
		_bus->topic($topic)->publish($msg);
	}
};




get '/socket' => sub {template 'socket'};
	
any '/send_msg' => sub {
    my $msg = params->{msg};
    ws_send $msg;
};

my $ws_send = sub {
    my $msg = shift;
    _topic->publish({ msg => $msg });
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
