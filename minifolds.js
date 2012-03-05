(function() {
  var root;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.scatterplot = function(data, whichX, whichY, whichColor, whichSize, whichGroup) {
    var bottomPadding, circles, clipbox, colorScale, colors, defaultCircleSize, h, leftPadding, mousedOverCircleSize, point, rightPadding, sizeScale, sizes, topPadding, vis, w, withinSelectionBounds, x, xrule, xs, y, yrule, ys;
    xs = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        point = data[_i];
        _results.push(parseFloat(point[whichX]));
      }
      return _results;
    })();
    ys = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        point = data[_i];
        _results.push(parseFloat(point[whichY]));
      }
      return _results;
    })();
    colors = whichColor !== "" ? (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        point = data[_i];
        _results.push(parseFloat(point[whichColor]));
      }
      return _results;
    })() : [];
    sizes = whichSize !== "" ? (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        point = data[_i];
        _results.push(parseFloat(point[whichSize]));
      }
      return _results;
    })() : [];
    colorScale = d3.scale.linear().domain([d3.min(colors), d3.max(colors)]).range(["red", "blue"]);
    sizeScale = d3.scale.linear().domain([d3.min(sizes), d3.max(sizes)]).range([1, 10]);
    w = 500;
    h = 500;
    leftPadding = 75;
    rightPadding = 10;
    topPadding = 5;
    bottomPadding = 30;
    withinSelectionBounds = 5;
    x = d3.scale.linear().domain([d3.min(xs), d3.max(xs)]).range([0, w]);
    y = d3.scale.linear().domain([d3.min(ys), d3.max(ys)]).range([h, 0]);
    mousedOverCircleSize = 15;
    defaultCircleSize = 3;
    vis = d3.select(".graph").append("svg").attr("width", w + leftPadding + rightPadding).attr("height", h + topPadding + bottomPadding).append("g").attr("transform", "translate(" + leftPadding + ", " + topPadding + ")");
    xrule = vis.selectAll("g.x").data(x.ticks(10)).enter().append("g").attr("class", "x");
    xrule.append("line").attr("x1", x).attr("x2", x).attr("y1", 0).attr("y2", h);
    xrule.append("text").attr("class", "ticklabel").attr("x", x).attr("y", h + 3).attr("dy", ".7em").attr("text-anchor", "middle").text(x.tickFormat(10));
    vis.append("text").attr("class", "axisLabel").attr("x", w * 0.5).attr("y", h + 25).attr("text-anchor", "middle").text(whichX);
    yrule = vis.selectAll("g.y").data(y.ticks(10)).enter().append("g").attr("class", "y");
    yrule.append("line").attr("x1", 0).attr("x2", w).attr("y1", y).attr("y2", y);
    yrule.append("text").attr("class", "ticklabel").attr("x", -3).attr("y", y).attr("dy", ".35em").attr("text-anchor", "end").text(x.tickFormat(10));
    vis.append("text").attr("class", "axisLabel").attr("transform", "rotate(-90)").attr("x", -h / 2).attr("y", -50).attr("text-anchor", "middle").text(whichY);
    vis.append("line").attr("class", "boundingbox").attr("x1", 0).attr("x2", 0).attr("y1", 0).attr("y2", h);
    vis.append("line").attr("class", "boundingbox").attr("x1", 0).attr("x2", w).attr("y1", h).attr("y2", h);
    circles = vis.selectAll("circle").data(data).enter().append("circle").attr("class", "dot").attr("index", function(d, i) {
      return i;
    }).attr("cx", function(d) {
      return x(d[whichX]);
    }).attr("cy", function(d) {
      return y(d[whichY]);
    }).attr("fill", function(d) {
      if (whichColor !== "") {
        return colorScale(d[whichColor]);
      } else {
        return "black";
      }
    }).attr("r", function(d) {
      if (whichSize !== "") {
        return sizeScale(d[whichSize]);
      } else {
        return defaultCircleSize;
      }
    });
    clipbox = vis.append("clipPath").attr("id", "clipbox").append("rect").attr("width", w).attr("height", h);
    return vis.selectAll("path").data(data).enter().append("svg:path").attr("d", function(d, i) {
      var verts, xLeft, xPoint, xRight, yBottom, yPoint, yTop;
      xPoint = x(d[whichX]);
      yPoint = y(d[whichY]);
      xLeft = xPoint - withinSelectionBounds;
      xRight = xPoint + withinSelectionBounds;
      yBottom = yPoint - withinSelectionBounds;
      yTop = yPoint + withinSelectionBounds;
      verts = [[xLeft, yBottom], [xRight, yBottom], [xRight, yTop], [xLeft, yTop]];
      if (verts.length > 0) {
        return "M" + verts.join(",") + "Z";
      } else {
        return "M 0 0 Z";
      }
    }).attr("clip-path", "url(#clipbox)").attr("fill-opacity", 0).on("mouseover", function(d, i) {
      var k, row, v, _results;
      d3.selectAll("circle").filter(function(otherD) {
        if (whichGroup !== "") {
          return otherD[whichGroup] === d[whichGroup];
        } else {
          return false;
        }
      }).classed("groupMousedover", true);
      d3.select("circle[index='" + i + "']").attr("r", mousedOverCircleSize);
      d3.selectAll("table.data tbody tr").remove();
      _results = [];
      for (k in d) {
        v = d[k];
        row = d3.select("table.data tbody").append("tr");
        row.append("td").text(k);
        _results.push(row.append("td").text(v));
      }
      return _results;
    }).on("mouseout", function(d, i) {
      return d3.selectAll("circle").filter(function(otherD) {
        if (whichGroup !== "") {
          return otherD[whichGroup] === d[whichGroup];
        } else {
          return otherD === d;
        }
      }).attr("fill", function(d) {
        if (whichColor !== "") {
          return colorScale(d[whichColor]);
        } else {
          return "black";
        }
      }).attr("r", function(d) {
        if (whichSize !== "") {
          return sizeScale(d[whichSize]);
        } else {
          return defaultCircleSize;
        }
      }).classed("groupMousedover", false);
    });
  };

}).call(this);