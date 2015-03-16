package MAP::gridMaker;
use Dancer ':syntax';
our $VERSION = '0.1';


use MAP::gridMaker::Builder::Table;
use MAP::gridMaker::Builder::Column;
use MAP::gridMaker::Grid::Input;
#use MAP::gridMaker::Input;


#prefix '/payments';
dance;
