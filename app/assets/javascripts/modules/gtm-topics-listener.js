var GtmTopicsListener = {}

GtmTopicsListener.handleTopicClick = function (dataGtm) {
  return function (event) {
    var element = event.target
    var topic = event.detail

    if (!element || !topic.topicNames) {
      return
    }

    var topicName = topic.topicNames.join(' > ')

    window.dataLayer.push({
      event: 'Click',
      dataGtm: dataGtm,
      dataGtmValue: topicName
    })
  }
}

window.addEventListener('search-topic', GtmTopicsListener.handleTopicClick('select-topic-from-search-results'))
window.addEventListener('remove-topic', GtmTopicsListener.handleTopicClick('remove-topic'))
