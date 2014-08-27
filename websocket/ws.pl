#!/usr/bin/env perl
use Dancer;
use AnyMQ;
use Plack::Builder;
 
my $bus = AnyMQ->new;
my $topic = $bus->topic('demo');
 
get '/' => sub { template 'index' };

any '/send_msg' => sub {
    $topic->publish({ msg => params->{msg} });
    return "sent message\n";
};

# Web::Hippie routes
get '/new_listener' => sub {
    request->env->{'hippie.listener'}->subscribe($topic);
};
get '/message' => sub {
    my $msg = request->env->{'hippie.message'};
    $topic->publish($msg);
};
 
builder {
    mount '/' => dance;
    mount '/_hippie' => builder {
        enable '+Web::Hippie';
        enable '+Web::Hippie::Pipe', bus => $bus;
        sub { my $env = shift;
            my $bus       = $env->{'hippie.bus'}; # AnyMQ bus
            my $listener  = $env->{'hippie.listener'}; # AnyMQ::Queue
            my $client_id = $env->{'hippie.client_id'}; # client id

            # Your handler based on PATH_INFO: /new_listener, /error, /message
        }
        dance;
    };
};