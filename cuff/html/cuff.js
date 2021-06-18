var timercontainer;
var breakspot = 0;
var c4timer = 30;

$(function(){
  timercontainer = $("#timercontainer");
  
	window.addEventListener("message", function(event){
    
    var item = event.data;

    /*if (item.doPrisonBreakTimer){
      breakspot = item.breakspot;
      timercontainer.show();
      initPbTimer();
    }
    else if (item.getBreakoutName){
      $("#prison_break_input").val("");
      $("#breakout_input_label").val("Who do you want to break out?");
      $("#breakout_dialog").show();
    }
    else*/ if (item.updatePrisonRoster){
      $(".prisonlist").show();
      renderPrisonRoster(item.roster);
    }
  });

  /*$("#breakout_button_ok").click(function(){
    if ($("#prison_break_input").val() == ""){
      $("#breakout_input_label").val("You must enter a character name.");
    }
    else{
      $("#breakout_dialog").hide();
      sendData("findUser", {charname: $("prison_break_input").val()});
    }
  });

  $("#breakout_button_cancel").click(function(){
    $("#breakout_dialog").hide();
    sendData("closemenu", "");
  });*/

  $(".exitbutton").click(function(){
    $(".prisonlist").hide();
    sendData("closemenu", "");
  });
});

/*function interval(func, wait, times){
  var interv = function(w, t){
      return function(){
          if(typeof t === "undefined" || t-- > 0){
              //$("#pbtimer").html("The C4 will detonate in " + t + " seconds.");
              setTimeout(interv, w);
              try{
                  func.call(null);
              }
              catch(e){
                  t = 0;
                  throw e.toString();
              }
          }
      };
  }(wait, times);
  
  //$("#pbtimer").html("The C4 will detonate in 30 seconds.");
  setTimeout(interv, wait);
};

function initPbTimer(){
  c4timer = 30;
  var times = 0;

  interval(function(){
    times = times + 1;

    if (times == c4timer){
      $("#pbtimer").html("");
      timercontainer.hide();
      sendData("pbTimerComplete", {bspot: breakspot});
    }
    else{
      $("#pbtimer").html("The C4 will detonate in " + (c4timer - times).toString() + " seconds.");
    }
  }, 1000, 10);
}*/

function convertTime(date) {
  let hours = date.getHours();
  let minutes = date.getMinutes();
  let ampm = hours >= 12 ? 'pm' : 'am';
  hours = hours % 12;
  hours = hours ? hours : 12; // the hour '0' should be '12'
  minutes = minutes < 10 ? '0'+minutes : minutes;
  let strTime = hours + ':' + minutes + ' ' + ampm;

  return strTime;
}

function formatTime(time){
  let date = new Date(time * 1000);
  let ctime = convertTime(date);

  return `${date.getMonth()}/${date.getDay()}/${date.getFullYear()} ${ctime}`;
}

function renderPrisonRoster(roster){
  $(".rosterlist").children().detach();
  let rstr = "";
  
  for (let i = 0; i < roster.length; i++){
    let entry = roster[i];
    let timestr = formatTime(entry.time);

    rstr += 
      `<div class="row prisonpop-row">
        <div class="col-lg"><span style="color: lawngreen;">${entry.charname}</span></div>
        <div class="col-md"><span style="color: yellow;">${entry.source}</span></div>
        <div class="col-md"><span style="color: white;">${timestr}</span></div>
      </div>`;
  }

  $(".rosterlist").append(rstr);
}

function sendData(name, data) {
  $.post("http://cuff/" + name, JSON.stringify(data), function(datab) {
      console.log(datab);
  });
}

function playSound(sound) {
    sendData("playsound", {name: sound});
}