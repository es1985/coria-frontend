#statistics_routes.rb
get '/statistics/' do
  @title = "Dataset Statistics"
 
  #get statistics for all absolute metrics
  @data_metrics_absolute = Storage.get_absolute_metric_statistics

  #normalized
  @data_metrics_normalized = Storage.get_normalized_metric_statistics

  #scores
  @data_scores = Storage.get_score_statistics

  @data_correlations = Storage.get_metric_correlations

  erb :statistics
end