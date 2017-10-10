AnalyticsTemplate = require "../templates/includes/analytics"

module.exports = (application, team) ->

  self = 

    test: ->
      'blah i am team analytics'

  return AnalyticsTemplate self
