require 'redis'
require 'ostruct'


CONFIG = OpenStruct.new

CONFIG.node_index_key        = 'all_nodes'
CONFIG.metric_index_key      = 'all_metrics'
CONFIG.score_index_key       = 'all_scores'

CONFIG.node_neighbors_prefix = 'node_neighbors:'
CONFIG.node_prefix           = 'node_metrics:'
CONFIG.metric_prefix         = 'metric:'
CONFIG.score_prefix          = 'score:'
CONFIG.statistics_prefix     = 'statistics:'

CONFIG.normalization_suffix  = '_normalized'

CONFIG.statistical_indicators = { 'min'                 => "Minimum",
                                  'max'                 => "Maximum",
                                  'average'             => "Average Value" ,
                                  'median'              => "Mean Value",
                                  'standard_deviation'  => "Standard Deviation"}

CONFIG.redis = Redis.new

#automatic retrieval and naive naming of available metrics from Redis
CONFIG.metric_names = CONFIG.redis.smembers(CONFIG.metric_index_key).inject({}) do |h,metric|
  h[metric] = metric.split('_').map(&:capitalize).join(' ')
  h
end


#CONFIG.metric_names = {
#  'clustering_coefficient'                      => "Clustering Coefficient",
#  'corrected_clustering_coefficient'            => "Clustering Coefficient (Corrected)",
#  'degree'                                      => "Node Degree",
#  'average_neighbor_degree'                     => "Average Neighbor Degree",
#  'corrected_average_neighbor_degree'           => "Average Neighbor Degree (Corrected)",
#  'iterated_average_neighbor_degree'            => "Iterated Average Neighbor Degree",
#  'corrected_iterated_average_neighbor_degree'  => "Iterated Average Neighbor Degree (Corrected)",
#  'betweenness_centrality'                      => "Betweenness Centrality",
#  'eccentricity'                                => "Eccentricity",
#  'average_shortest_path_length'                => "Average Shortest Path Length"
#}


#automatic retrieval and naive naming of available scores from Redis
CONFIG.score_names = CONFIG.redis.smembers(CONFIG.score_index_key).inject({}) do |h,score|
  h[score] = score.split('_').map(&:capitalize).join(' ')
  h
end


# scores have to be readable in redis
#CONFIG.score_names = {
#  'unified_risk_score'                => "Unified Risk Score (URS)",
#  'advanced_unified_risk_score'       => "Advanced URS"
#}


# css classes for status indication ordered from "good" to "bad"
CONFIG.color_classes = ['success','info', 'warning', 'danger']

#HTML color codes from green to red in 0x11-steps
CONFIG.color_codes = ['#FF0000','#FF1100','#FF2200','#FF3300','#FF4400',
                      '#FF5500','#FF6600','#FF7700','#FF8800','#FF9900',
                      '#FFAA00','#FFBB00','#FFCC00','#FFDD00','#FFEE00',
                      '#FFFF00','#EEFF00','#DDFF00','#CCFF00','#BBFF00',
                      '#AAFF00','#99FF00','#88FF00','#77FF00','#66FF00',
                      '#55FF00','#44FF00','#33FF00','#22FF00','#11FF00',
                      '#00FF00'].reverse

#can be metric or score
CONFIG.node_coloring_field = 'unified_risk_score'

# max number of neighbors for graphical representation with d3.js
CONFIG.max_graph_neighbors = 150
CONFIG.nodes_per_page = 25
