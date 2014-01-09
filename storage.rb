require 'ostruct'
require 'redis'
require 'json'
require 'will_paginate'
require 'will_paginate/array'

require './color_helper'



module Storage
  @@rdb = Redis.new


  def self.all_nodes
    @@all_nodes = JSON.parse(@@rdb.smembers(CONFIG.node_index_key)[0]) unless defined? @@all_nodes
    return @@all_nodes.map{|id| id.to_s}
  end

  def self.metric_names 
    @@metric_names = JSON.parse(@@rdb.smembers(CONFIG.metric_index_key)[0]) unless defined? @@metric_names
    return @@metric_names
  end

  def self.score_names 
    @@score_names = JSON.parse(@@rdb.smembers(CONFIG.score_index_key)[0]) unless defined? @@score_names
    return @@score_names
  end



  def self.get_node(nodeid)
    node = OpenStruct.new
    node.id = nodeid
    node.metrics = {}
    node.scores = {}

    #get raw data from redis
    all_values = @@rdb.hgetall(CONFIG.node_prefix+nodeid.to_s)

    #build structured data
    CONFIG.metric_names.each do |metric,name|
      node.metrics[metric] = {}
      node.metrics[metric][:name] = name
      node.metrics[metric][:absolute] = all_values[metric].to_f
      node.metrics[metric][:normalized] = all_values[metric+CONFIG.normalization_suffix].to_f
      node.metrics[metric][:color_class] = ColorHelper.color_class_by_value(all_values[metric+CONFIG.normalization_suffix].to_f)
      node.metrics[metric][:color_code] = ColorHelper.color_code_by_value(all_values[metric+CONFIG.normalization_suffix].to_f)
    end
    CONFIG.score_names.each do |score,name|
      node.scores[score] = {}
      node.scores[score][:name] = name
      node.scores[score][:absolute] = all_values[score].to_f
      node.scores[score][:color_class] = ColorHelper.color_class_by_value(all_values[score].to_f)
      node.scores[score][:color_code] = ColorHelper.color_code_by_value(all_values[score].to_f)
    end

    node.neighbors = JSON.parse(@@rdb.smembers(CONFIG.node_neighbors_prefix+nodeid.to_s)[0])
    
    return node
  end



  def self.get_metric_nodes(metric_name, page=1)
    nodes = {}
    @@rdb.zrevrange(CONFIG.metric_prefix+metric_name, 0, -1, {withscores: true}).each do |value|
      nodes[value[0]] = {:id => value[0]}
      nodes[value[0]][:absolute] = value[1].to_f
    end  

    @@rdb.zrevrange(CONFIG.metric_prefix+metric_name+CONFIG.normalization_suffix, 0, -1, {withscores: true}).each do |value|
      nodes[value[0]][:normalized] = value[1].to_f
      nodes[value[0]][:color_class] = ColorHelper.color_class_by_value(value[1].to_f)
    end
    return nodes.to_a.paginate(:page => page, :per_page => CONFIG.nodes_per_page)
  end

  def self.get_all_metric_values_normalized(metric_name)
    return @@rdb.zrevrange(CONFIG.metric_prefix+metric_name+CONFIG.normalization_suffix, 0, -1, {withscores: true}).map{|score| score[1]}
  end


  def self.get_score_nodes(score_name, page=1)
    nodes = {}
    @@rdb.zrevrange(CONFIG.score_prefix+score_name, 0, -1, {withscores: true}).each do |value|
      nodes[value[0]] = {:id => value[0]}
      nodes[value[0]][:absolute] = value[1].to_f
      nodes[value[0]][:color_class] = ColorHelper.color_class_by_value(value[1].to_f)
    end  
    return nodes.to_a.paginate(:page => page, :per_page => CONFIG.nodes_per_page)
  end

  def self.get_all_score_values(score_name)
    return @@rdb.zrevrange(CONFIG.score_prefix+score_name, 0, -1, {withscores: true}).map{|score| score[1]}
  end

  def self.get_absolute_metric_statistics
    data_metrics_absolute = {}
    CONFIG.metric_names.each do |metric,mname|
      metric_data = {}
      CONFIG.statistical_indicators.each do |indicator,iname|
        value = @@rdb.hget(CONFIG.statistics_prefix+metric, indicator)
        metric_data[indicator] = value
      end
      metric_data['display_name'] = mname
      data_metrics_absolute[metric] = metric_data
    end
    return data_metrics_absolute
  end

  def self.get_normalized_metric_statistics
    data_metrics_normalized = {}
    CONFIG.metric_names.each do |metric,mname|
      metric_data = {}
      CONFIG.statistical_indicators.each do |indicator,iname|
        value = @@rdb.hget(CONFIG.statistics_prefix+metric+CONFIG.normalization_suffix, indicator)
        metric_data[indicator] = value
      end
      metric_data['display_name'] = mname
      data_metrics_normalized[metric] = metric_data
    end
    return data_metrics_normalized
  end

  def self.get_score_statistics
    data_scores = {}
    CONFIG.score_names.each do |score,sname|
      score_data = {}
      CONFIG.statistical_indicators.each do |indicator,iname|
        value = @@rdb.hget(CONFIG.statistics_prefix+score, indicator)
        score_data[indicator] = value
      end
      score_data['display_name'] = sname
      data_scores[score] = score_data
    end
    return data_scores
  end

  def self.get_metric_correlations
    correlation_data = {}
    CONFIG.metric_names.each do |metric1,m1name|
      correlation_data[metric1] = {:from => m1name, :correlation => {}}
      CONFIG.metric_names.each do |metric2,m2name|
        corr = @@rdb.hget(CONFIG.statistics_prefix+'correlations:'+metric1+':'+metric2, 'correlation')
        conf = @@rdb.hget(CONFIG.statistics_prefix+'correlations:'+metric1+':'+metric2, 'confidence')
        color_code = ColorHelper.color_code_by_value(corr.to_f.abs)
        correlation_data[metric1][:correlation][metric2] = {:to => m2name, :correlation => corr, :confidence => conf, :color_code => color_code}
      end
    end
    return correlation_data
  end


end
