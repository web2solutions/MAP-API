#!/usr/bin/perl
use strict;
use warnings;
use Moose;
use AnyMQ;

      my $bus = AnyMQ->new_with_traits(
				       traits => ['AMQP'],
				       host   => 'localhost',
                                       port   => 5672,
                                       user   => 'dhtmlx',
                                       pass   => 'fuzzy24k',
                                       vhost  => 'dhtmlx.com.br',
                                       exchange => 'welcome',
                                       queue       => 'welcome',
									   #routing_key => 'welcome'
                                   );
      
    my $channel = $bus->new_topic("welcome");
    
#my $channel = $bus->topic({
#		name => 'welcome',
#        #queue       => 'welcome3'
#		#routing_key => 'rk for welcome3'
#});
    
    #my $channel = AnyMQ::Topic->new_with_trait
    # (traits => ['WithBacklog'], backlog_length => 30, bus => $bus);
      
    #my $client = $bus->new_listener($channel);
      
    #$client->poll(sub { my $msg = shift;
    #    print ${$msg}{message};
    #});
    
    #my $msg = $ARGV[0] || "Hello from other client";
    
    #print ' [*] Waiting for messages. To exit press CTRL+C'
	
	my $msg;
	$msg->{msg} = 'Hello from other client';
	$msg->{type} = 'message'; # disconnect, message, new_user
	
	$msg->{time} = time;
    $msg->{address} = '11111111111';
	
	$msg->{client_id} = '999999999999999';
	#debug $client_id;
	
	$msg->{routing_key} = 'welcome';
    
    $channel->publish({ message => ''});
    
    
    #for (;1;) {
    #    $channel->publish({ message => "Hello world\n"});
    #    sleep 1;
    #}
    
    
