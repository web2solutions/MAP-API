#!/usr/bin/perl
use strict;
use warnings;
use Moose;
use AnyMQ;
use Data::Dump qw(dump);

      my $bus = AnyMQ->new_with_traits(
				       traits => ['AMQP'],
				       host   => 'localhost',
                                       port   => 5672,
                                       user   => 'dhtmlx',
                                       pass   => 'fuzzy24k',
                                       vhost  => 'dhtmlx.com.br',
                                       exchange => ''
                                   );
    print dump($bus->topics);
    print "\n===============\n\n";
    #my $channel = $bus->topic("foo");
   # my $channel = $bus->topics->{foo};
      
    my $client = $bus->new_listener(  );
    
    my $channel = AnyMQ::Topic->new_with_traits(
        traits => ['WithBacklog'], 
        backlog_length => 30, 
        name => "welcome",
        bus => $bus ); 
    
    $client->subscribe( $channel ) ;
    
    
    #$client->poll(sub { my $msg = shift;
    #    print ${$msg}{message};
    #});
    
    
    #$client->poll_once(sub { my $msg = shift;
    #    print ${$msg}{message};
    #});
    
    
    
    
    
    
    
    
    for (;1;) {
        $client->poll_once(sub { my $msg = shift;
            print ${$msg}{message};
        });
        sleep 1;
    }    
