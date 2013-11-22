require 'rubygems'
require 'sinatra'
require 'redis'
require 'json'
require 'will_paginate'
require 'will_paginate/array'
require './node'

# bind to publicly accessable IP
set :bind, '0.0.0.0'

rdb = Redis.new
#CSS class names for alert levels from "ok" to "bad"

#HTML color codes from green to red in 0x11-steps
COLORS = ['#FF0000','#FF1100','#FF2200','#FF3300','#FF4400',
          '#FF5500','#FF6600','#FF7700','#FF8800','#FF9900',
          '#FFAA00','#FFBB00','#FFCC00','#FFDD00','#FFEE00',
          '#FFFF00','#EEFF00','#DDFF00','#CCFF00','#BBFF00',
          '#AAFF00','#99FF00','#88FF00','#77FF00','#66FF00',
          '#55FF00','#44FF00','#33FF00','#22FF00','#11FF00',
          '#00FF00'].reverse

# max number of nodes for display in metric listings
MAX_LIST = 20

# max number of neighbors for graphical representation with d3.js
MAX_GRAPH_NEIGHBORS = 300


# INDEX / ROOT PATH
get '/' do
  rdb = Redis.new
  @title = 'CoRiA'
  erb :index
end

# NODE DETAILS
get '/node/:asn' do  
  rdb = Redis.new
  @asn = params[:asn]
  return status 404 unless Node.all_nodes.include?(@asn)
  @title = 'Node Details'
  @node = Node.get(params[:asn])
  erb :node_details
end

# NODE SEARCH
post('/node') do
  if Node.all_nodes.include?(params[:node_id].to_s)
    redirect '/node/'+params[:node_id]
  else
    redirect '/'
  end
end


# METRIC DETAILS
get '/metric/:metric/' do
  @metric = params[:metric]

  if Node.metric_names.keys.include?(@metric)
    redis_key = @metric+'_normalized'
  elsif Node.score_names.keys.include?(@metric)
    redis_key = @metric
  else
    return status 404
  end

  @metric_name = Node.metric_names[@metric] || Node.score_names[@metric]
  
  @title = @metric_name+' Ranking'
  
  rdb = Redis.new
  @nodes = rdb.zrevrange(redis_key, 0, -1, {withscores: true}).paginate(:page => params[:page])

  erb :metric_details
  
end

get '/nodes' do
  content_type :json
  return Node.all_nodes.to_json
end


#NODE NEIGHBORHOOD AJAX ENDPOINT FOR DISPLAY VIA d3.js
#color notes by unified risk score value
get '/node/neighbors/:id' do
  content_type :json

  @node = Node.get(params[:id])

  #build response
  response = {}

  response[:nodes] = []
  response[:links] = []

  response[:nodes] << {:name => @node.data[:id], :size_multiplier => @node.data[:degree_normalized], :color => COLORS[(@node.data[:unified_risk_score]*COLORS.length).ceil]}

  limited_neighbors = @node.data[:neighbors][0..MAX_GRAPH_NEIGHBORS]
  i = 1
  limited_neighbors.each do |node_id|
    neighbor = Node.get(node_id)
    color = COLORS[(neighbor.data[:unified_risk_score]*COLORS.length).ceil]
    size_multiplier = neighbor.data[:degree_normalized]

    response[:nodes] << {:name => neighbor.data[:id], :size_multiplier => size_multiplier, :color => color}
    response[:links] << {:source => 0, :target => i}
    i += 1
  end

  return response.to_json
end

get '/metric/:metric/histogram.json' do
  content_type :json

  metric = params[:metric]

  if Node.metric_names.keys.include?(metric)
    redis_key = metric+'_normalized'
  elsif Node.score_names.keys.include?(metric)
    redis_key = metric
  else
    return status 404
  end

  values = rdb.zrevrange(redis_key, 0, -1, {withscores: true}).map{|score| score[1]}

  return values.to_json

end