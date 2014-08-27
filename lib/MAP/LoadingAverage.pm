package MAP::LoadingAverage;
use Dancer ':syntax';
use Dancer::Plugin::Ajax;

use Unix::Uptime;

use Linux::SysInfo qw<sysinfo>;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};



get '/getloadavg' => sub {
   MAP::API->normal_header();
   return {
        timestamp => time,
        loadavg => ( Unix::Uptime->load )[0]
    };
};

get '/usedram' => sub {
    template 'usedram';
};
get '/getusedram' => sub {
	MAP::API->normal_header();
	return {
        timestamp => time,
        usedram => sysinfo->{freeram}
    };
};


get '/freeram' => sub {
    template 'freeram';
};
get '/getfreeram' => sub {
	MAP::API->normal_header();
	return {
        timestamp => time,
        usedram => sysinfo->{freeram}
    };
};

dance;
