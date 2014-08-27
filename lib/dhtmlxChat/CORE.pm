package dhtmlxChat::CORE;
use Dancer ':syntax';

use dhtmlxChat::Socket;



our $VERSION = '0.1';

set 'session'     => 'Simple';

set logger => 'console';

set 'log'         => 'debug';
set 'show_errors' => 1;
set 'access_log ' => 1;
set 'warnings'    => 0;



dance;
