#metric_routes.rb
# METRIC DETAILS
get '/metric/:metric/' do
  @metric = params[:metric]

  return status 404 unless CONFIG.metric_names.keys.include?(@metric)

  @metric_name = CONFIG.metric_names[@metric] || "Unknown"
  
  @title = @metric_name+' Ranking'

  @nodes = Storage.get_metric_nodes(params[:metric],params[:page])

  erb :metric_details
  
end

get '/metric/:metric/histogram.json' do
  content_type :json
  return Storage.get_all_metric_values_normalized(params[:metric]).to_json
end