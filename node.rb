class Node
  @@redis = Redis.new

  COLOR_TYPES = ['success','info', 'warning', 'danger']
  
  attr_reader :data, :neighbors, :asn
  
  # metrics have to be readable from redis as well as their respective *_normalized values
  @@metric_names = {
    'clustering_coefficient'                      => "Clustering Coefficient",
    'corrected_clustering_coefficient'            => "Clustering Coefficient (Corrected)",
    'degree'                                      => "Node Degree",
    'average_neighbor_degree'                     => "Average Neighbor Degree",
    'corrected_average_neighbor_degree'           => "Average Neighbor Degree (Corrected)",
    'iterated_average_neighbor_degree'            => "Iterated Average Neighbor Degree",
    'corrected_iterated_average_neighbor_degree'  => "Iterated Average Neighbor Degree (Corrected)",
    'betweenness_centrality'                      => "Betweenness Centrality",
    'eccentricity'                                => "Eccentricity",
    'average_shortest_path_length'                => "Average Shortest Path Length"
  }

  # scores have to be readable in redis
  @@score_names = {
    'unified_risk_score'                => "Unified Risk Score (URS)",
    'advanced_unified_risk_score'       => "Advanced URS"
  }


  # class methods for control flow
  def self.all_nodes
    @@all_nodes = @@redis.smembers("all_nodes") unless defined? @@all_nodes
    return @@all_nodes
  end

  def self.metric_names 
    @@metric_names
  end

  def self.score_names 
    @@score_names
  end

  
  # find node by id
  def self.get(id)
    params  = {}
    params[:id] = id

    #get all available values for the node from redis and store in variable
    @@redis.hgetall('node_metrics:'+id.to_s).each do |metric, value|
      params[metric.to_sym] = value.to_f
    end

    # fetch neighbors of node
    params[:neighbors] = @@redis.smembers('node_neighbors:'+params[:id])

    #instantiate new node with obtained params from redis
    node = Node.new(params)
    return node
  end
  
  def initialize(params)
    @data = params
  end
 
  #helper to get an HTML colorcode for a percentage value parameter 
  def self.color_type_by_value(value)
    if value > 1
      return COLOR_TYPES[-1]
    end

    if value == 0
      return COLOR_TYPES[0]
    end

    index = ((value-0.001)*COLOR_TYPES.length).floor.to_i
    return COLOR_TYPES[index]
  end

  # instance helper to get HTML colorcode for a specific metric value of a node
  def color_type(metric)
    value = self.data[metric.to_sym].to_f
    return Node.color_type_by_value(value)
  end

end