#!/usr/bin/perl

use strict;
use warnings;

$|++;
use AnyEvent;
use Net::RabbitFoot;

my $conn = Net::RabbitFoot->new()->load_xml_spec()->connect(
    host => 'localhost',
    port => 5672,
    user => 'dhtmlx',
    pass => 'fuzzy24k',
    vhost => 'dhtmlx.com.br',
);

my $ch = $conn->open_channel();

$ch->declare_queue(
                   queue => 'welcome2'
);

#$ch->bind_queue(
 #                  queue => 'welcome2',
 #                  routing_key => 'another routing'
#);

print " [*] Waiting for messages. To exit press CTRL-C\n";

sub callback {
    my $var = shift;
    my $body = $var->{body}->{payload};
    print " [x] Received $body\n";
}

$ch->consume(
    on_consume => \&callback,
    no_ack => 0, # 0 nao reconhece mensagem
);

# Wait forever
AnyEvent->condvar->recv;