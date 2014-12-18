package MAP::Payments;
use Dancer ':syntax';
our $VERSION = '0.1';


use MAP::payments::AuthorizeNet;
use MAP::payments::PaymentSettings;


#prefix '/payments';
dance;
