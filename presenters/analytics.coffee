# todo convert to async await fetch

Observable = require 'o_0'
commaNumber = require 'comma-number'
axios = require 'axios'
querystring = require 'querystring'
c3 = require 'c3'

AnalyticsTemplate = require "../templates/includes/analytics"

METRICS = ["remixes", "visits"]
FROM_TWO_WEEKS = Date.now() - 2 * 7 * 24 * 3600 * 1000 #

module.exports = (application, teamOrProject, type) ->

  type = type or 'team'

  self = 

    # todo views -> visits
  
    remixes: Observable []
    totalRemixes: Observable ""
    totalVisits: Observable ""
    views: Observable []
    referrers: Observable []
    xAxis: Observable []
      
      
    consolidatedDataPoints: (metricData) ->
      # returns a point per day
      ;
      
    createChart: (metricData, elementId) ->
      # consolidatedDataPoints
      
      # ? change ranges:
      # months = if > 31 points
      # days = if < 12 points

      c3.generate
        bindto: "##{elementId}"
        data:
            type: 'bar'
            x: 'x'
            xFormat: '%Y'
            json:
              x: metricData.x
              "All Projects": metricData.y
        axis:
            x: 
                type: 'timeseries'
                localtime: false
                tick:
                    format: '%b %e'
        legend:
          hide: true
        grid:
          x:
            show: true
          y:
            show: true
        color:
          pattern: ['#70ecff', 'teal']

    # createReferrersChart: (metricData, elementId) ->
    #   data: {
    #     labels: true
    #   }
    #   axis: {
    #     rotated: true
    #   }

    parseTotal: (metricData) ->
      metricData.y.reduce (a, b) ->
        a + b

    drawCharts: (data) ->
      {buckets} = data
      chartData = METRICS.map (metric) ->
        x: buckets.map (x) -> new Date x.startTime
        y: buckets.map (y) -> y.analytics[metric] ? 0
        type: metric
      console.log 'data', data #
      console.log '🎂 chartData', chartData #
      remixesData = chartData[0]
      visitsData = chartData[1]

      self.totalRemixes (self.parseTotal remixesData)
      self.totalVisits (self.parseTotal visitsData)
      self.createChart visitsData, 'visits-chart'
      # self.createChart remixesData, 'remixes-chart'
          
      # data.referrers = [{domain: "ourdot-checklist.glitch.me", requests: 2684, self: true}, {}]


        
    getAnalyticsData: (query) ->
      id = teamOrProject.id()
      CancelToken = axios.CancelToken
      source = CancelToken.source()
      if query
        queryString = querystring.stringify query
        analyticsPath = "analytics/#{id}/#{type}?#{queryString}"        
      else
        analyticsPath = "analytics/#{id}/#{type}"
      application.gettingAnalytics true
      application.api(source).get analyticsPath
        .then ({data}) ->
          application.gettingAnalytics false
          self.drawCharts data
        .catch (error) ->
          console.error 'getAnalyticsData', error

    hiddenIfGettingAnalytics: ->
      'hidden' if application.gettingAnalytics()

    hiddenUnlessGettingAnalytics: ->
      'hidden' unless application.gettingAnalytics()


  self.getAnalyticsData()
    # from: FROM_TWO_WEEKS
  return AnalyticsTemplate self
