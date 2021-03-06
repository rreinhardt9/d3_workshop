
$ ->
  $('.progress-plot').each ->
     draw_progress_towards_goal_graph(this, parseFloat($(this).data('initValue')),
       parseFloat($(this).data('currentValue')), parseFloat($(this).data('targetValue')))

draw_progress_towards_goal_graph = (reference, init_value, current_value, target_value) ->
  if init_value == undefined || current_value == undefined || target_value == undefined
    return

  $(reference).empty()
  el_width = $(reference).width()
  height = 28

  min = d3.min([init_value, current_value, target_value]) * 0.8
  max = d3.max([init_value, current_value, target_value]) * 1.02

  histogram = [
    {
      start_value: min
      value: max
      color: "#E7E8E0"
      tooltip: "Target Value: " + target_value
    }
  ]

  if init_value > 0
    histogram.push({
      start_value: min
      value: init_value
      color: "#0857A2"
      tooltip: "Start Value: " + init_value
    })
  if current_value > 0
    histogram.push({
      start_value: init_value
      value: current_value
      color: "#3679BF"
      tooltip: "Current Value: " + current_value
    })

  scale_x = d3.scale.linear()
  .domain([min, max])
  .range([5, el_width - 10])

  scale_width = d3.scale.linear()
  .domain([0, max - min])
  .range([5, el_width - 10])

  svg = d3.select(reference)
  .append("svg")
  .attr("width", el_width)
  .attr("height", height + 28)

  div = d3.select(".tooltip")
  if div.size() == 0
    div = d3.select("body")
    .append("div")
    .attr("class", "tooltip")
    .style("opacity", 0)

  svg.selectAll("rect")
  .data(histogram)
  .enter()
  .append("rect")
  .attr("width", (d) ->
    scale_value = scale_width Math.abs(d.value - d.start_value)
    scale_value = 0 if scale_value < 0
    scale_value
  ).attr("x", (d) ->
    scale_x d3.min([d.value, d.start_value])
  )
  .attr("y", 5)
  .attr("height", height)
  .style("fill", (d) ->
    d.color
  )
  .on("mouseover", (d) ->
    div.transition()
    .duration(200)
    .style("opacity", 0.9)
    div.html(d.tooltip)
    .style("left", (d3.event.pageX) + "px")
    .style("top", (d3.event.pageY - 28) + "px")
    return
  )
  .on("mousemove", ->
    div.style("left", (d3.event.pageX) + "px")
    .style("top", (d3.event.pageY - 28) + "px")
    return
  )
  .on "mouseout", (d) ->
    div.transition().duration(500).style "opacity", 0
    return

  xAxis = d3.svg.axis()
  .scale(scale_x)
  .orient("bottom")
  .tickFormat((d) ->
    d
  ).ticks(5)
  .tickSize(-height - 8, 0, 0)

  svg.append("g")
  .attr("class", "x axis")
  .attr("transform", "translate(0, 40)")
  .call(xAxis)

  # draw target line
  target = scale_x(target_value)
  lineFunction = d3.svg.line().x((d) ->
    d.x
  ).y((d) ->
    d.y
  ).interpolate("linear")
  svg.append("path").attr("d", lineFunction([
    {x: target, y: 2},
    {x: target, y: 40}
  ]))
  .attr("stroke", "black")
  .attr("stroke-width", 1.5)
  .attr("fill", "none")
  if (current_value / 4) < target_value
    targe_text_position = target - 43
  else
    targe_text_position = target + 5
  svg.append("text")
  .attr("x", targe_text_position)
  .attr("y", 14)
  .text("TARGET")
  .attr("font-family", "sans-serif")
  .attr("font-size", "10px")
  .attr("fill", "black")
