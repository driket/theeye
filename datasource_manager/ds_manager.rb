require 'digest'
require 'sinatra'
require 'socket'

set :bind, '0.0.0.0'
set :port, 80

get '/' do
    "DatasourceManager running on #{Socket.gethostname}\n"
end
