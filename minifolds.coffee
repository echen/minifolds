# In order to access the scatterplot function globally, 
# we need to define it as a property of the global object.
root = exports ? this

###
Make a scotterplot.

data        - Array of JSON objects.
whichX      - String naming the property in each object to use as the x-coordinate.
whichY      - String naming the property in each object to use as the y-coordinate.
whichColor  - Optional string to use as the color. Must name a *numeric* property for now.
whichSize   - Optional string to use as the size.
whichGroup  - Optional string to use as a grouper. (When mousing over a point P, all points
              with the same grouping value as P will be colored black.)

Examples:

  scatterplot(
    [{weight: 150, height: 51, income: 1000, age: 32}, ...],
    "weight",
    "height",
    "income",
    "",
    "age"
  )
    => Makes a scatterplot of weight vs. height, where points are
       * colored according to income (low income = red, high income = blue)
       * all points have the same size
       * grouped according to age (all points with the same age will be colored
         black on a mouseover)
###

root.scatterplot = (data, whichX, whichY, whichColor, whichSize, whichGroup) ->
  xs = (parseFloat(point[whichX]) for point in data)
  ys = (parseFloat(point[whichY]) for point in data)
  colors = if whichColor != "" then (parseFloat(point[whichColor]) for point in data) else []
  sizes = if whichSize != "" then (parseFloat(point[whichSize]) for point in data) else []
  
  colorScale = d3.scale.linear().domain([d3.min(colors), d3.max(colors)]).range(["red", "blue"])
  sizeScale = d3.scale.linear().domain([d3.min(sizes), d3.max(sizes)]).range([1, 10])
  
  w = 500
  h = 500
  leftPadding = 75    # space for y-axis labels
  rightPadding = 10   # don't cut off the rightmost tick
  topPadding = 5      # don't cut off the topmost tick
  bottomPadding = 30  # space for x-axis labels
  
  # only need to mouseover within this bound, in order to select a point
  withinSelectionBounds = 5 
  
  x = d3.scale.linear().domain([d3.min(xs), d3.max(xs)]).range([0, w])
  y = d3.scale.linear().domain([d3.min(ys), d3.max(ys)]).range([h, 0])
  
  # todo: move to css?
  mousedOverCircleSize = 15
  defaultCircleSize = 3
  
  vis =
    d3.select(".graph")
      .append("svg")
        .attr("width", w + leftPadding + rightPadding)
        .attr("height", h + topPadding + bottomPadding)
      .append("g")
        .attr("transform", "translate(#{leftPadding}, #{topPadding})")
  
  # x-axis stuff
  xAxis =
    vis
      .selectAll("g.x")
      .data(x.ticks(10))
      .enter()
        .append("g")
          .attr("class", "x")
            
  # add vertical gridlines
  xAxis.append("line")
    .attr("x1", x)
    .attr("x2", x)
    .attr("y1", 0)
    .attr("y2", h)

  # add x-axis tick labels
  xAxis
    .append("text")
    .attr("class", "ticklabel")
    .attr("x", x)
    .attr("y", h + 3)
    .attr("dy", ".7em")
    .attr("text-anchor", "middle")
    .text(x.tickFormat(10))

  # add x-axis label
  vis
    .append("text")
    .attr("class", "axisLabel")
    .attr("x", w * 0.5)
    .attr("y", h + 25)
    .attr("text-anchor", "middle")
    .text(whichX)

  # y-axis stuff
  yAxis =
    vis
      .selectAll("g.y")
      .data(y.ticks(10))
      .enter()
        .append("g")
          .attr("class", "y")
  
  # add horizontal gridlines
  yAxis
    .append("line")
    .attr("x1", 0)
    .attr("x2", w)
    .attr("y1", y)
    .attr("y2", y)

  # add y-axis tick labels
  yAxis
    .append("text")
    .attr("class", "ticklabel")
    .attr("x", -3)
    .attr("y", y)
    .attr("dy", ".35em")
    .attr("text-anchor", "end")
    .text(x.tickFormat(10))
  
  # add y-axis label  
  vis
    .append("text")
    .attr("class", "axisLabel")
    .attr("transform", "rotate(-90)")
    .attr("x", -h / 2)
    .attr("y", -50)
    .attr("text-anchor", "middle")
    .text(whichY)
    
  # make bounding box
  vis
    .append("line")
    .attr("class", "boundingbox")
    .attr("x1", 0)
    .attr("x2", 0)
    .attr("y1", 0)
    .attr("y2", h)

  vis
    .append("line")
    .attr("class", "boundingbox")
    .attr("x1", 0)
    .attr("x2", w)
    .attr("y1", h)
    .attr("y2", h)
  
  # add datapoints  
  circles = 
    vis
      .selectAll("circle")
      .data(data)
      .enter()
        .append("circle")
        .attr("class", "dot")
        .attr("index", (d, i) -> i )	    
        .attr("cx", (d) -> x(d[whichX]) )
        .attr("cy", (d) -> y(d[whichY]) )
        .attr("fill", (d) -> (if whichColor != "" then colorScale(d[whichColor]) else "black"))
        .attr("r", (d) -> (if whichSize != "" then sizeScale(d[whichSize]) else defaultCircleSize))

          
  # clip so that only mouseovers within the graph grid
  # (e.g., not mouseovers on the x-axis label or whatever) 
  # fire off an event to update the point being selected.
  clipbox =
    vis
      .append("clipPath")
        .attr("id", "clipbox")
      .append("rect")
        .attr("width", w)
        .attr("height", h)

  # add a way to select a point even if not directly mousing over it.
  # not sure if this is the best way, but right now I draw a square around each
  # point, and if you mouseover the square, the associated point is selected.
  vis
    .selectAll("path")
    .data(data)
    .enter()
    .append("svg:path")
    # Make a rectangle around each point.
    .attr("d", (d, i) ->
      xPoint = x(d[whichX])
      yPoint = y(d[whichY])
      
      xLeft   = xPoint - withinSelectionBounds
      xRight  = xPoint + withinSelectionBounds
      yBottom = yPoint - withinSelectionBounds
      yTop    = yPoint + withinSelectionBounds
      
      verts = [[xLeft, yBottom], [xRight, yBottom], [xRight, yTop], [xLeft, yTop]]

      if (verts.length > 0)
        return "M" + verts.join(",") + "Z"
      else
        return "M 0 0 Z"
    )        
    .attr("clip-path", "url(#clipbox)")
    # don't show the rectangle!
    .attr("fill-opacity", 0)
    # when mousing over the rectangle, select the associated point.
    .on("mouseover", (d, i) ->
      # points in the same group
      d3
        .selectAll("circle")
        .filter((otherD) -> (if whichGroup != "" then otherD[whichGroup] == d[whichGroup] else false))
        .classed("groupMousedover", true)

      # current point
      d3
        .select("circle[index='#{i}']")
        .attr("r", mousedOverCircleSize)

      # show data in table
      d3.selectAll("table.data tbody tr").remove()
      for k, v of d
        row = d3.select("table.data tbody").append("tr")
        row.append("td").text(k)
        row.append("td").text(v)
    )
    .on("mouseout", (d, i) ->      
      d3
        .selectAll("circle")
        .filter((otherD) -> (if whichGroup != "" then otherD[whichGroup] == d[whichGroup] else otherD == d))
        .attr("fill", (d) -> (if whichColor != "" then colorScale(d[whichColor]) else "black"))
        .attr("r", (d) -> (if whichSize != "" then sizeScale(d[whichSize]) else defaultCircleSize))
        .classed("groupMousedover", false)
    )