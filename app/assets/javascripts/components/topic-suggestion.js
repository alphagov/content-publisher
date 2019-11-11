$(document).on('change', '.topic-suggestions input[type="checkbox"]', function () {
  var id = $(this).attr('id');
  var topicContentId = id.replace("topic-suggestion-", "");
  var millerColumnTopic = false;

  // While this is a little computationally heavy, it means
  // the miller column display is updated appropriately
  var millerColumns = $("miller-columns")[0];
  if(typeof millerColumns !== 'undefined'){
    var flattenedTopics = millerColumns.taxonomy.flattenedTopics;
    for(var i=0; i < flattenedTopics.length; ++i){
      var topic = flattenedTopics[i];
      var topicCheckboxId = $(topic.checkbox).attr("id");
      if($(topic.checkbox).val() === topicContentId){
        millerColumnTopic = topic;
        break;
      }
    }
  }

  if(millerColumnTopic){
    if($(this).is(':checked')) {
      millerColumns.taxonomy.topicClicked(millerColumnTopic);
    } else {
      millerColumns.taxonomy.removeTopic(millerColumnTopic);
    }
  }

});

$(document).on('click', '.miller-columns__item', function(event){
  handleMillerColumnChange($(this));
});

$(document).on('keyup', '.miller-columns__item', function(event){
  if ([' ', 'Enter'].indexOf(event.key) !== -1) {
    console.log("changing from keyp")
    handleMillerColumnChange($(this));
  }
});

function handleMillerColumnChange($element){
  var $checkbox = $element.find("input[name='topics[]']");
  var millerColumnCheckboxTopicId = $checkbox.val();
  var millerColumnCheckboxChecked = $checkbox.is(':checked');
  $(".topic-suggestions input[type='checkbox']").each(function(){
    var suggestionTopicId = $(this).val();
    if(suggestionTopicId === millerColumnCheckboxTopicId){
      console.log("changing to")
      console.log(millerColumnCheckboxChecked);
      console.log($(this).prop('checked'));
      $(this).prop('checked', millerColumnCheckboxChecked);
      console.log($(this).prop('checked'));
    }
  });
}
