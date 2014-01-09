$(function() {
    
  var width = 720,
  height = 720

  var svg = d3.select("#graph").append("svg").attr("width", width).attr("height", height)

  var fisheye = d3.fisheye.circular()
      .radius(120);

  d3.json("/node/"+node_id+"/neighbors.json", function(error, json) {
    if (error) return console.warn(error);
  
    var n = json.nodes.length;

    json.nodes.forEach(function(d,i) {
      if(i==0){
        d.x = Math.floor(width / 2); 
        d.y = Math.floor(height / 2);
      } else {
        d.x = 60 + Math.floor(Math.random()*(width - 120)); 
        d.y = 60 + Math.floor(Math.random()*(height - 120));   
      }
     
    });

    json.links.forEach(function(d) {
      d.source_node = json.nodes[d.source]
      d.target_node = json.nodes[d.target]
    });

    var link = svg.selectAll(".link")
        .data(json.links)
        .enter().append("line")
        .attr("class", "link")
        .attr("x1", function(d) { return d.source_node.x; })
        .attr("y1", function(d) { return d.source_node.y; })
        .attr("x2", function(d) { return d.target_node.x; })
        .attr("y2", function(d) { return d.target_node.y; })
        .style("stroke-width", 1);     


    var node = svg.selectAll(".node")
        .data(json.nodes)
        .enter().append("g")
        .attr("class", "node")
        .append("svg:a")
        .attr("xlink:href", function(d){return '/node/'+d.name;})
        .append("circle")
        .attr("cx", function(d) { return d.x; })
        .attr("cy", function(d) { return d.y; })
        .attr("r", 4)
        .attr("fill", "#2a9fd6")
        .attr("stroke", function(d) {return d.color_code;})
        .attr("stroke-width",3);
      
    node.append("text")
      .attr("dx", "-0.35em")
      .attr("dy", "0.35em")
      .text(function(d) { return d.name });   


    var center_node = svg.select(".node")
                      .select("circle")
                      .attr("fill", "#93c");

    

svg.on("mousemove", function() {
  fisheye.focus(d3.mouse(this));

  node.each(function(d) { d.fisheye = fisheye(d); })
      .attr("cx", function(d) { return d.fisheye.x; })
      .attr("cy", function(d) { return d.fisheye.y; })
      .attr("r", function(d) { return d.fisheye.z * 4.5; });

  link.attr("x1", function(d) { return d.source_node.fisheye.x; })
      .attr("y1", function(d) { return d.source_node.fisheye.y; })
      .attr("x2", function(d) { return d.target_node.fisheye.x; })
      .attr("y2", function(d) { return d.target_node.fisheye.y; });
});
    
  });
    
});