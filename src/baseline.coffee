$ ->
  model = new Baseline
  chart = model.build()

  data = {current: 120, baseline: 68}

  d3.select(".baseline-plot svg")
    .datum(data)
    .transition()
    .duration(1000).call chart

class Baseline

  build: ->

    margin = {top: 5, right: 15, bottom: 5, left: 15}

    chart = (selection) ->
      selection.each (d, i) ->
        container = d3.select(this)

        availableWidth =
          parseInt(container.style('width')) - margin.left - margin.right
        availableHeight =
          parseInt(container.style('height')) - margin.top - margin.bottom

        fontSize = 12
        tickFontSize = fontSize / 1.2
        tickFormat = d3.format(',.2r')
        paddedText = fontSize + 5
        linesHeight = availableHeight - paddedText
        baseline = tickFormat(d.baseline)
        max = baseline * 2
        forceX = [0]
        current = tickFormat(d.current)
        scaleDomain = ->
          # No values should be closer than 10% to the min/max on scale
          initDomain = d3.extent(d3.merge([[max, current], forceX]))
          scalePadding = (initDomain[1] - initDomain[0]) * 0.1
          minLimit = initDomain[0] + scalePadding
          maxLimit = initDomain[1] - scalePadding
          adjustments = []
          for num in [current, baseline]
            if num < minLimit
              adjustments.push num - scalePadding
            else if num > maxLimit
              adjustments.push num + scalePadding

          d3.extent(d3.merge([initDomain, adjustments]))

        xScale = d3.scale.linear()
          .domain([tickFormat(scaleDomain()[0]), tickFormat(scaleDomain()[1])])
          .range([0, availableWidth])

        xScope = xScale.domain()[1] - xScale.domain()[0]

        # Main chart containers
        wrap = container.selectAll("g.pc-wrap.pc-baseline").data([d])
        wrapEnter = wrap.enter().append("g").attr({
            class: "pc-wrap pc-baseline"
            transform: "translate(#{margin.left}, #{margin.top})"
            width: availableWidth
            height: availableHeight
          })
        gEnter = wrapEnter.append("g")
        g = wrap.select("g")

        # Add chart components
        gNumberLine = gEnter.append("g").attr("class", "pc-axis pc-x")

        gMin = gEnter.append("g").attr("class", "g-min")
        gMax = gEnter.append("g").attr({
            class: "g-max"
            transform: "translate(#{availableWidth})"
          })

        gBaseline = gEnter.append("g").attr({
            class: "g-baseline"
            transform: "translate(#{availableWidth / 2})"
          })

        gCurrent = gEnter.append("g").attr({
            class: "g-current"
            transform: "translate(#{availableWidth / 2})"
          })

        ticks = [xScope * 0.25, xScope * 0.5, xScope * 0.75]

        gTicks = gEnter.selectAll("g.pc-tick")
          .data(ticks)
          .enter()
          .append("g")
          .attr({
            class: "pc-tick"
            transform: (d) ->
              "translate(#{xScale(tickFormat(d + xScale.domain()[0]))})"
          })

        # Add lines
        gNumberLine.append("line").attr("class", "number-line")
          .attr({
              class: "number-line"
              x1: 0
              x2: availableWidth
              y1: linesHeight / 2
              y2: linesHeight  / 2
            })

        gTicks.append("line")
          .attr({
              y1: (linesHeight / 2) + (linesHeight / 10)
              y2: (linesHeight / 2) - (linesHeight / 10)
            })

        gBaseline.append("line")
          .attr({
              y1: paddedText
              y2: (linesHeight / 2) + 5
            })

        gCurrent.append("line")
          .attr({
              y1: linesHeight - fontSize
              y2: (linesHeight / 2) - 5
            })

        gMax.append("line")
          .attr("y2", linesHeight)

        gMin.append("line")
          .attr("y2", linesHeight)

        # Add text
        gBaseline.append("text")
          .attr({
              y: fontSize
              "text-anchor": "middle"
              "font-size": fontSize
            })
          .text("Baseline: #{baseline}")

        gTicks.append("text")
          .attr({
              y: (linesHeight / 2) + (linesHeight / 10) + tickFontSize
              "text-anchor": "middle"
              "font-size": tickFontSize
            })
          .text((d) -> tickFormat(d + xScale.domain()[0]))

        gCurrent.append("text")
          .attr({
              y: linesHeight
              "text-anchor": "middle"
              "font-size": fontSize
            })
          .text("Current: #{current}")

        gMax.append("text").attr({
            "text-anchor": "middle"
            y: availableHeight - margin.bottom
            "font-size": fontSize
          })
          .text(xScale.domain()[1])

        gMin.append("text").attr({
            "text-anchor": "middle"
            y: availableHeight - margin.bottom
            "font-size": fontSize
          })
          .text(xScale.domain()[0])

        # Transition indicators on load
        gBaseline
          .transition()
          .attr("transform", (d) -> "translate(#{xScale(baseline)})")

        gCurrent
          .transition()
          .attr("transform", (d) -> "translate(#{xScale(current)})")
