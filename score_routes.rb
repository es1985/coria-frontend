#score_routes.rb
get '/score/:score/' do
  @score = params[:score]
  
  return status 404 unless CONFIG.score_names.keys.include?(@score)

  @score_name = CONFIG.score_names[@score]
  @title = @score_name+' Ranking'

  @nodes = Storage.get_score_nodes(params[:score],params[:page])

  erb :score_details
end

get '/score/:score/histogram.json' do
  content_type :json
  return Storage.get_all_score_values(params[:score]).to_json
end