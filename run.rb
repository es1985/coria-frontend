require 'rubygems'
require 'sinatra'

require './config'
require './storage'
# bind to publicly accessable IP
set :bind, '0.0.0.0'


# INDEX / ROOT PATH
require './index'

require './node_routes'

require './metric_routes'

require './score_routes'

require './statistics_routes'