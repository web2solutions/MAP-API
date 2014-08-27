#!/usr/bin/env perl
use Dancer;
use AnyEvent;
use Net::RabbitFoot;
use AnyMQ;
use Plack::Builder;
use Data::Dump qw(dump);

set logger => 'console';

set 'log'         => 'debug';
set 'show_errors' => 1;
set 'access_log ' => 1;
set 'warnings'    => 0;
 
my $bus = Net::RabbitFoot->new()->load_xml_spec()->connect(
    host => 'localhost',
    port => 5672,
    user => 'dhtmlx',
    pass => 'fuzzy24k',
    vhost => 'dhtmlx.com.br',
);

my $ch = $bus->open_channel();

$ch->declare_queue(queue => 'welcome');

sub callback {
    my $var = shift;
    my $body = $var->{body}->{payload};
    print " [x] Received $body\n";
}



get '/' => sub { template 'socket' };

 
# Web::Hippie routes
get '/new_listener' => sub {
    my $env = request->env;
    my $room  = $env->{'hippie.args'};
    my $bus       = $env->{'hippie.bus'}; # AnyMQ bus
    
    debug dump( $bus );
    
    my $listener  = $env->{'hippie.listener'}; # AnyMQ::Queue
    #my $client_id = $env->{'hippie.client_id'}; # client id
    #my $handle = $env->{'hippie.handle'}; # client id
    
    #my $topic = $env->{'hippie.bus'}->topic($room);
    
    #my $channel = $env->{'hippie.bus'}->topic("welcome");
    
    
    #my $channel = $env->{'hippie.bus'}->topic("welcome");
    #$bus->topic("foo")
    #AnyMQ->topic('Foo')
    
    my %opt = (
        #traits => ['WithBacklog'], 
        #backlog_length => 30, 
        name => "welcome"
        #bus => $env->{'hippie.bus'}
    );
    
    
    
    
    
    #my $channel = $env->{'hippie.bus'}->topic( "welcome" );
    
    #$bus->topics->{name}->publish($msg);
    
    
    #$bus->topics->{name}->queues
    
    
    #my $channel = AnyMQ::Topic->new_with_traits(
    #    traits => ['WithBacklog'], 
    #    backlog_length => 30, 
    #    name => "welcome",
    #    #queues => {}
    #    bus => $env->{'hippie.bus'} );
    
    #debug dump($env->{'hippie.bus'});
    #debug "\n\n\n\n\n\n";
    #debug dump( $env->{'hippie.bus'}->topics->{welcome} );
    
    #$listener->subscribe( $channel );
    
};
get '/message' => sub {
    #my $env = request->env;
    #my $msg = $env->{'hippie.message'};
    #my $room  = $env->{'hippie.args'};
    #my $bus       = $env->{'hippie.bus'}; # AnyMQ bus
    #my $handle = $env->{'hippie.handle'}; # client id
    #debug dump($handle);
    #my $channel = $bus->topics->{welcome};
    #$bus->topics->{welcome}->publish($msg);
};
 
builder {
    mount '/' => dance;
    mount '/_hippie' => builder {
        enable '+Web::Hippie';
        enable '+Web::Hippie::Pipe', bus => $ch;
        dance;
    };
};