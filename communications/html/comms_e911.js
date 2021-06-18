let e911calls = [];
let newcalls = 0;
let wexpanded = {ex: true, exheight: 400, colheight: 32};

$(function(){
  window.addEventListener("message", function(message){
    var data = message.data;

    if (data.e911addnew){
      let call = data.call;

      if (call){
        e911calls.push(call);
        addCallEntry(call);
      }
    }
    else if (data.e911AddAll){
      e911calls = data.calls;
      add911Calls(data.calls);
    }
    else if (data.e911addmessage){
      let call = data.call;

      if (call){
        addChatLine(call.id, call);
      }
    }
    else if (data.e911remove){
      let id = data.id;

      if (id){
        removeCallById(id);
      }
    }
    else if (data.toggleEnroute){
      let tdata = data.data;

      toggleEnroute(tdata);
    }
    else if (data.setIsLeo){
      let tog = data.toggle;

      tog ? $(".e911display-toggle").show() : $(".e911display-toggle").hide();
    }
    else if (data.setIsEms){
      let tog = data.toggle;

      tog ? $(".e911display-toggle").show() : $(".e911display-toggle").hide();
    }
  });
  
  $(document).on("keypress", ".niner-input", function(ev){
    var keycode = (ev.keyCode ? ev.keyCode : ev.which);
    
    if (keycode == 13) {
      var inp = $(this).val();
      var id = $(this).data("id");
      
      if (inp.length > 0){
        // send message
        sendData("bms:comms:e911addmessage", {dir: "To", text: inp, id: id});
        $(this).val("");
      }
    }
  });
  
  $(".e911-transbutton.up").click(function(){
    var opac = parseFloat($(this).closest(".e911display").css("opacity"));
    opac = opac + 0.1;

    if (opac > 1.0) opac = 1.0;

    $(this).closest(".e911display").css({opacity: opac});
  });

  $(".e911-transbutton.down").click(function(){
    var opac = parseFloat($(this).closest(".e911display").css("opacity"));

    opac = opac - 0.1;

    if (opac < 0.2) opac = 0.2;

    $(this).closest(".e911display").css({opacity: opac});
  });

  $(document).on("click", ".ninerping", function(){
    var id = $(this).closest(".callentry").data("id");
    
    if (id){
      // send ping
      sendData("bms:comms:e911doping", {id: id});
    }
  });

  $(document).on("click", ".removeniner", function(){
    var id = $(this).closest(".callentry").data("id");

    $(this).closest(".callentry").remove();
    sendData("bms:comms:e911remove", {id: id});
  });

  $(document).on("click", ".enroute", function(){
    var id = $(this).closest(".callentry").data("id");

    sendData("bms:comms:e911enroute", {id: id});
  });

  $(".e911-expandbarbutton").click(function(){
    if (wexpanded.ex){
      wexpanded.exheight = $(".e911display").height();
    }

    wexpanded.ex = !wexpanded.ex;
    
    if (wexpanded.ex){
      $(".e911display").css({"overflow-y": "scroll"});
      $(".e911display").animate({height: wexpanded.exheight}, 200);
    }
    else{
      $(".e911display").css({"overflow-y": "hidden"});
      $(".e911display").animate({height: wexpanded.colheight}, 200);
    }
    
    if (wexpanded.ex){
      newcalls = 0;
      $(".newcallspill").html("");
      $(".newcallspill").hide();
    }
  });
});

function formatNinerChat(chat){
  let outstr = "";
  
  for (let i = 0; i < chat.length; i++){
    let cht = chat[i];
    let entry = "";
    
    if (cht.dir === "From"){
      entry = `<div class="row"><div class="col-lg"><span class="tlight">From:</span> ${cht.text}</div></div>`;
    }
    else if (cht.dir === "To"){
      entry = `<div class="row"><div class="col-lg"><span class="tdisp">Dispatch > ${cht.charname} (${cht.callsign || "000"}):</span> ${cht.text}</div></div>`;
    } else if (cht.dir === "Dispatch") {
      entry = `<div class="row"><div class="col-lg"><span class="tdisp">Dispatch ></span> ${cht.text}</div></div>`;
    }
    
    outstr += entry;
  }
  
  return outstr;
}

function formatNumber(num) {
  var cleaned = ('' + num).replace(/\D/g, '');
  var match = cleaned.match(/^(\d{3})(\d{3})(\d{4})$/);
  
  if (match) {
    return '(' + match[1] + ') ' + match[2] + '-' + match[3]
  }
  
  return num
}

function add911Calls(calls){
  $(".ninercalls").children().remove();

  if (!calls || calls.length == 0) return;
  
  calls.forEach(call => {
    addCallEntry(call);
  });
}

function addCallEntry(data){
  var entry = 
    `<div class="row padtop callentry" id="callentry${data.callid}" data-id="${data.callid}">
      <div class="col-sm">
        <span class="ninerinfo number">${formatNumber(data.number)}</span>
      </div>
      <div class="col-1">
        <button class="ninerping" type="button"></button>
      </div>
      <div class="col-1">
        <button class="removeniner" type="button"></button>
      </div>
      <div class="col-1">
        <button class="enroute" type="button"></button>
      </div>
      <div class="col-1">
        <button class="expander" type="button" data-toggle="collapse" data-target="#ninerdetails${data.callid}" title="Expand/Collapse"></button>
      </div>
    </div>
    <div class="row" id="location${data.callid}">
      <div class="col-lg">
        <span class="ninerinfo number">${data.location}</span>
      </div>
    </div>
    <div class="row ninerdetails scrollthin collapse" data-toggle="false" id="ninerdetails${data.callid}">
      <div class="col-lg">
        <div class="row">
          <div class="col-lg">
            <div id="e911responders${data.callid}" class="e911responders">

            </div>
          </div>
        </div>
        <div class="row" style="height: 82%">
          <div class="col-lg">
            <div class="niner-coorespondance scrollthin">
              ${formatNinerChat(data.chat)}
            </div>
          </div>
        </div>
        <div class="row mt-auto">
          <div class="col-lg">
            <input type="text" placeholder="Enter a message to ${formatNumber(data.number)}..  Press ENTER to send it." style="width: 97%;" class="niner-input" data-id="${data.callid}">
          </div>
        </div>
      </div>
    </div>`;

  $(".ninercalls").append(entry);

  //let expanded = $(".ninercallrow").attr("aria-expanded");
  let expanded = wexpanded.ex;

  if (!expanded){
    newcalls++;
    $(".newcallspill").html(newcalls);
    $(".newcallspill").show();
  }
}

function getCallFromId(id){
  for (let i = 0; i < e911calls.length; i++){
    let c = e911calls[i];

    if (c.callid == id){
      return c;
    }
  }
}

function addChatLine(id, data){
  let chat = getCallFromId(id).chat;
  let entry = {};

  if (data.dir === "To" && data.callsign){
    entry = {dir: "To", callsign: data.callsign, text: data.text, charname: data.charname};
  }
  else{
    entry = {dir: "From", text: data.text};
  }
  
  chat.push(entry);
  refreshChat(id);
}

function refreshChat(id){
  var chat = getCallFromId(id).chat;
  
  var nchat = $(`#ninerdetails${id}`).find(".niner-coorespondance");
  
  if (nchat){
    nchat.children().remove();
    nchat.append(formatNinerChat(chat));
  }
  else{
    console.log("Failed to get coorespondance DOM object.");
  }
}

function removeCallById(id){
  for (let i = 0; i < e911calls.length; i++){
    let c = e911calls[i];

    if (c.callid == id){
      e911calls.splice(i, 1);
      break;
    }
  }

  // remove from dom
  $(`#callentry${id}`).remove();
  $(`#ninerdetails${id}`).remove();
  $(`#location${id}`).remove();
}

function toggleEnroute(data){
  if (data){
    let id = data.id;
    let action = data.action;
    let call = getCallFromId(id);
    let callsign = data.callsign || "000";

    if (call){
      if (action == "add"){
        call.responders.push(callsign);
      }
      else if (action == "remove"){
        for (let i = 0; i < call.responders.length; i++){
          let r = call.responders[i];

          if (r == callsign){
            call.responders.splice(i, 1);
          }
        }
      }
            
      $(`#e911responders${id}`).children().remove();
      var respstr = "";

      if (call.responders.length > 0){
        respstr += "<span style='color: white;'>Responders: </span>";
      }
      
      for (let i = 0; i < call.responders.length; i++){
        let r = call.responders[i];

        respstr += r + ", ";
      }

      respstr = respstr.slice(0, -2);
      $(`#e911responders${id}`).html(respstr);
    }
    else{
      console.log("Error.  Failed to get call for the ID (toggleEnroute).");
    }
  }
}

function sendData(name, data){
  $.post("http://communications/" + name, JSON.stringify(data), function(datab) {
  	console.log(datab);
  });
}