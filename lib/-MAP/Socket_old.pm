package MAP::Socket;

use Carp;
use Dancer ':syntax';
use utf8;
use Encode       qw( encode );
use Moose;
use AnyMQ;
use Plack;
use Plack::Request;
use Web::Hippie;

our $VERSION = 0.0100;# VERSION

our $subject = 'welcome';

my $bus;
sub _bus{
    return $bus if $bus;
    return $bus = AnyMQ->new_with_traits(
				       traits => ['AMQP'],
					   host   => 'localhost',
                                       port   => 5672,
                                       user   => 'dhtmlx',
                                       pass   => 'fuzzy24k',
                                       vhost  => 'dhtmlx.com.br',
                                       exchange => $subject,
                                       queue       => $subject,
									   routing_key => $subject
                                   );
}

my $channel = AnyMQ::Topic->new_with_traits(
        traits => ['AMQP'], 
        #backlog_length => 30, 
        name => $subject,
        queue       => $subject,
		routing_key => $subject,
        bus => _bus
);


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

    $listener->subscribe( $channel );
};

get '/message' => sub {
	my $json_string = request->env->{'hippie.message'}->{msg} || '{ message : "error"}';
	my $json_bytes = encode('UTF-8', $json_string);
	my $hash_message = JSON->new->utf8->decode($json_string) or die "unable to decode" ;
	
	my $msg;
	$msg->{msg} = $hash_message->{message};
	$msg->{time} = time;
    $msg->{address} = request->env->{REMOTE_ADDR};
	my $client_id = request->env->{'hippie.client_id'};
	$msg->{client_id} = $client_id;
	#debug $client_id;
	
	$msg->{routing_key} = $subject;
	
	my $type = "message"; #  message, subscribe, disconnect
	if ( defined( $hash_message->{type} ) ) {
		if ( $hash_message->{type} ne '' ) {
			$type = $hash_message->{type};
		}
	}
	my $routing_key = $subject;
	if ( defined( $hash_message->{routing_key} ) ) {
		if ( $hash_message->{routing_key} ne '' )
		{
			$routing_key = $hash_message->{routing_key};
			$msg->{routing_key} = $routing_key;
			
			
			
			if ( $type eq "subscribe")
			{
				my $channelnew = AnyMQ::Topic->new_with_traits(
						traits => ['AMQP'], 
						#backlog_length => 30, 
						name => $routing_key,
						queue       => $routing_key,
						routing_key => $routing_key,
						bus => _bus
				);
				
				#request->env->{'hippie.listener'}->subscribe( $channelnew );
				
				my $msg2 = $msg;
				$msg2->{msg} = $msg2->{msg} . "<<<<<< from '".$routing_key."' routing key";
				
				$channelnew->publish($msg2);
				
				request->env->{'hippie.listener'}->subscribe( $channel );
			}
			$channel->publish($msg);
		}
		else
		{
			
			$channel->publish( $msg );
		}
	}
	else
	{
		if ( $type eq "subscribe") {
			#request->env->{'hippie.listener'}->subscribe( $channel );
		}
		
		$channel->publish($msg);
	}
};




get '/socket' => sub {template 'socket'};
	
any '/send_msg' => sub {
    my $msg = params->{msg};
    ws_send $msg;
};

my $ws_send = sub {
    my $msg = shift;
    $channel->publish({ msg => $msg });
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
