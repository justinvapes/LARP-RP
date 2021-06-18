$(function(){
	var voiceicon = $("#voiceicon");
			
	window.addEventListener("message", function(event)
	{
    var data = event.data;

    if (data.task == "talkchange"){
      if (data.talking){
        voiceicon.show();
      }
      else{
        voiceicon.hide();
      }
    }
  });
});
