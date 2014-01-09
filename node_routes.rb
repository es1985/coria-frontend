#node_routes.rb

# NODE DETAILS

# NODE SEARCH
post('/node') do
  node_id = params[:node_id]
  if Storage.all_nodes.include?(node_id)
    redirect '/node/'+node_id
  else
    redirect '/'
  end
end

get '/node/:id/' do  
  id = params[:id]
  return status 404 unless Storage.all_nodes.include?(id)
    
  @title = 'Node Details'
  @node = Storage.get_node(id)
  erb :node_details
end

#NODE NEIGHBORHOOD AJAX ENDPOINT FOR DISPLAY VIA d3.js
#color notes by unified risk score value
get '/node/:id/neighbors.json' do
  content_type :json

  id = params[:id].to_s

  node = Storage.get_node(id)

  #build response for d3.js utilization
  response = {}
  response[:nodes] = []
  response[:links] = []

  color_code = node.scores.fetch(CONFIG.node_coloring_field,{}).fetch(:color_code, nil) || node.metrics.fetch(CONFIG.node_coloring_field,{}).fetch(:color_code, nil)

  response[:nodes] << {:name => node.id, :color_code => color_code}

  neighbors = node.neighbors[0..CONFIG.max_graph_neighbors]

  neighbors.each_with_index do |node_id, i|
    neighbor = Storage.get_node(node_id)
    color_code = neighbor.scores.fetch(CONFIG.node_coloring_field,{}).fetch(:color_code, nil) || neighbor.metrics.fetch(CONFIG.node_coloring_field,{}).fetch(:color_code, nil)

    response[:nodes] << {:name => neighbor.id, :color_code => color_code}
    response[:links] << {:source => 0, :target => i+1}
  end

  return response.to_json
end