#!/usr/bin/perl

use strict;
use warnings;

$|++;
use Net::RabbitFoot;

my $conn = Net::RabbitFoot->new()->load_xml_spec()->connect(
    host => 'localhost',
    port => 5672,
     user => 'dhtmlx',
    pass => 'fuzzy24k',
    vhost => 'dhtmlx.com.br',
);


my $chan = $conn->open_channel();

$chan->publish(
    exchange => 'welcome',
    routing_key => 'welcome',
    body => '{"msg":"tesssst","time":1405570441,"client_id":0.610147099535197,"users":[{"client_id":0.610147099535197,"nick":"Eduardo","gender":"male"}],"person":{"client_id":0.610147099535197,"nick":"Eduardo","gender":"male"},"routing_key":"welcome","type":"new_username","address":"201.79.156.57"}',
);

print " [x] Sent 'Hello World!'\n";

$conn->close();