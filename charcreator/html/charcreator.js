let texselector;
let hairColorList = [
  "#100F10", "#1F1C19", "#543D31", "#71442E", "#763926", "#914028", "#984D32", "#9A5D3F", "#9A6443", "#A3704C",
  "#B6885A", "#C19763", "#C8A46C", "#D8AB64", "#E6BD77", "#E5BE80", "#BD8B5B", "#985234", "#9F3A26", "#891310",
  "#A51811", "#AF1E16", "#C62F1B", "#E4451B", "#CB5C33", "#D94F24", "#8E7562", "#A58B76", "#D5BCA5", "#E7D1BC",
  "#724C5D", "#8C576C", "#BD5A7B", "#F530C2", "#FE438C", "#FA9FAA", "#0B9E90", "#0E848B", "#094E7A", "#5B9A50",
  "#2F9060", "#14524B", "#ABBA29", "#91B013", "#63AE25", "#E8B851", "#F4C20E", "#F89F0E", "#FE880E", "#F85E10",
  "#FE7E24", "#FA521D", "#F03210", "#CA0B0E", "#A50A0E", "#2D1D16", "#3B2319", "#4C271A", "#422419", "#5D3526",
  "#311F18", "#080A0E", "#CEAE87", "#E5BE8D"
];
let slot = 1;
let gender = 0;
let money = 0;
let lastcost = 0;
let closetopen = false;

$(function(){
  let container = $(".tabs-master");
  texselector = $(".texture-slider");

  window.addEventListener("message", function(event){
    var data = event.data;

    if (data.showCreator){
      container.fadeIn();
      gender = data.gender;
      money = data.plmoney;

      if (data.maxes){
        setSliderPartMaxes(data.maxes, false);
      }

      loadSliderValues(data.pedconfig);
      $(".moneytext").html("$" + Math.floor(money));
    }
    else if (data.hideCreator){
      container.fadeOut();
    }
    else if (data.savedSkin){
      showInfoText("Your character has been saved.", 7000);
    }
    else if (data.blockDb){
      showInfoText("Please wait a second before saving/reverting again.", 4000);
    }
    else if (data.setInfoText){
      showInfoText(data.text, data.delay);
    }
    else if (data.setSliderPartMaxes){
      setSliderPartMaxes(data.maxes, true);
    }
    else if (data.setTextureMax){
      let cid = data.cid;
      let texmax = data.texmax;

      setTextureSliderMax(cid, texmax);
    }
    else if (data.showCloset)
		{
      $(".closetpanel").fadeIn();
      closetopen = true;
    }
    else if (data.hideCloset)
		{
      $(".closetpanel").fadeOut();
      closetopen = false;
    }
    else if (data.showRules){
      loadServerRules($(".rulescontent"), $(".rulescontainer"));
    }
    else if (data.showCostDisplay){
      if (data.owned){
        $(".cc-helptext").html("<span style='color: lawngreen'>Owned</span>");
      }
      else if (!data.cost || data.cost == 0){
        $(".cc-helptext").html("Click to Show the Available Textures");
      }
      else{
        lastcost = data.cost;
        $(".cc-helptext").html(`Clothing Cost: <span style="color: lawngreen">$${data.cost}</span> <button style="margin-left: 25px; height: 28px; line-height: 8px;" class="btn btn-info btnPurchaseComp">Purchase</button>`);
      }
    }
    else if (data.unblockCompPurchase){
      $(".btnPurchaseComp").prop("disabled", false);
    }
  });

  $(".option-slider").slider();
  $(".texture-slider").slider();
    
  $(".option-slider").on("change", function(evt){
    let max = $(this).slider("getAttribute", "max");
    let cid = parseInt($(this).data("cid"));
    let val = parseInt($(this).slider("getValue"));
    
    $(this).siblings(".cat-info").children(".cat-range").html(`${evt.value.newValue}` + "/" + `${max}`);
    sendData("navigateToPart", {cid: cid, partidx: val});
  });
  
  $(document).on("change", ".texture-slider", function(evt){
    let max = $(this).slider("getAttribute", "max");
    let cid = parseInt($(this).parent().siblings(".option-slider").data("cid"));
    let val = parseInt($(this).slider("getValue"));
    
    $(this).siblings(".tex-info").children(".tex-range").html(`${evt.value.newValue}` + "/" + `${max}`);
    sendData("navigateToTexture", {cid: cid, textureidx: val});
  });
  
  $(".nav-link").click(function(){
    let id = $(this).data("id");
    
    resetTabs();
    $(".nav-link").removeClass("active");
    $("#tab" + id).show();
    $(this).addClass("active");
  });
  
  $(".slider-nav-right").click(function(){
    let ele = $(this).siblings(".option-slider");
    let value = ele.slider("getValue");
    let cid = parseInt(ele.data("cid"));
    
    value = value + 1;
    ele.slider("setValue", value);

    let max = ele.slider("getAttribute", "max");
    let val2 = ele.slider("getValue");
    
    $(this).siblings(".cat-info").children(".cat-range").html(`${val2}` + "/" + `${max}`);
    sendData("navigateToPart", {cid: cid, partidx: val2});
  });
  
  $(".slider-nav-left").click(function(){
    let ele = $(this).siblings(".option-slider");
    let value = ele.slider("getValue");
    let cid = parseInt(ele.data("cid"));
    
    value = value - 1;
    ele.slider("setValue", value);

    let max = ele.slider("getAttribute", "max");
    let val2 = ele.slider("getValue");
    
    $(this).siblings(".cat-info").children(".cat-range").html(`${val2}` + "/" + `${max}`);
    sendData("navigateToPart", {cid: cid, partidx: val2});
  });
  
  $(document).on("click", ".slider-tex-nav-right", function(){
    let ele = $(this).siblings(".texture-slider");
    let value = ele.slider("getValue");
    let cid = parseInt($(this).parent().siblings(".option-slider").data("cid"));
    
    value = value + 1;
    ele.slider("setValue", value);

    let max = ele.slider("getAttribute", "max");
    let val2 = ele.slider("getValue");
    
    $(this).siblings(".tex-info").children(".tex-range").html(`${val2}` + "/" + `${max}`);
    sendData("navigateToTexture", {cid: cid, textureidx: val2});
  });

  $(document).on("click", ".slider-tex-nav-left", function(){
    let ele = $(this).siblings(".texture-slider");
    let value = ele.slider("getValue");
    let cid = parseInt($(this).parent().siblings(".option-slider").data("cid"));
    
    value = value - 1;
    ele.slider("setValue", value);
    
    let max = ele.slider("getAttribute", "max");
    let val2 = ele.slider("getValue");
    
    $(this).siblings(".tex-info").children(".tex-range").html(`${val2}` + "/" + `${max}`);
    sendData("navigateToTexture", {cid: cid, textureidx: val2});
  });
  
  /* Handle dynamically adding texture bar */
  $(".pill-surround").click(function(){
    let hastex = $(this).has(".texture-selector").length == 1;
    $(this).find("hidecomp-button").fadeIn();
    $(".texture-selector.active").hide();
    $(".texture-selector.active").removeClass("active");
    
    if (hastex){
      $(this).children(".texture-selector").addClass("active");
      $(this).children(".texture-selector").show();
    }
    else{
      let th = $(this);
      let ignore = th.data("ignore-tex");
      
      if (ignore) return;
      
      let tstr = `<div class="texture-selector">
          <div class="tex-info">TEXTURES<span class="tex-range">0/0</span></div>
          <button type="button" class="btn btn-dark slider-tex-nav-left"><</button>
          <input class="texture-slider" type="text" data-slider-min="0" data-slider-max="0" data-slider-step="1" data-slider-value="0" data-slider-enabled="true">
          <button type="button" class="btn btn-dark slider-tex-nav-right">></button>
        </div>`;
      
      th.append(tstr);
      let tsel = th.children(".texture-selector");
      tsel.addClass("active");
      let tslider = tsel.children(".texture-slider");
      let pslider = $(this).find(".option-slider");
      
      tsel.show();
      tslider.slider();

      let texsel = parseFloat(pslider.data("texsel")) || 0;
      let texmax = parseFloat(pslider.data("texmax")) || 0;
      let label = tslider.siblings(".tex-info").children(".tex-range");

      tslider.slider("setAttribute", "max", texmax);
      tslider.slider("setValue", parseFloat(texsel));
      tslider.slider("refresh", {useCurrentValue: true});
      label.html(`${parseInt(texsel)}/${parseInt(texmax)}`);
    }
  });

  /*$(".pill-surround").mouseleave(function(){
    $(this).find("hidecomp-button").fadeOut();
    $(".texture-selector.active").hide();
    $(".texture-selector.active").removeClass("active");
  });*/
  
  $(".stext").hover(function(){
    let text = $(this).data("stext");
    
    $(".status-text").html(text);
  });
  
  $(".stext").mouseleave(function(){
    $(".status-text").html("");
  });

  $(".actionbutton-gender").click(function(){
    let genderBtn = parseInt($(this).data("gender"));
    let cameras = parseInt($(this).data("cyclecam"));

    if (genderBtn == 0 || genderBtn == 1){
      sendData("setGender", {gender: genderBtn});
      gender = genderBtn;
      // TODO - reload slider maxes due to gender switch and different component ranges
    }
    else if (cameras == 1){
      sendData("switchcam", "");
    }
  });

  $(".nav_left_arrow").on("click", function(){
		sendData("turntoface", {dir: 1});
	});

	$(".nav_right_arrow").on("click", function(){
		sendData("turntoface", {dir: 2});
  });

  $(".actionbutton").click(function(){
    let reset = parseInt($(this).data("reset"));

    if (reset = 2){ // all to saved
      sendData("reverttosaved", "");
    }
  });

  $(".cc-sidebar").click(function(){
    sendData("escape", "");
    container.fadeOut();
  });

  $(".actionbutton-slot").click(function(){
    if ($(this).hasClass("actionbutton-slot-selected")) return;
    
    let action = $(this).data("action");

    if (action == "1" || action == "2" || action == "3" || action == "4" || action == "5") {
      setSlot(parseInt(action));
      $(".actionbutton-slot").removeClass("actionbutton-slot-selected");
      $(this).addClass("actionbutton-slot-selected");
    }
    else if (action == "save"){
      sendData("saveCharacterSkin", {gender: gender, slot: slot});
    }
    else if (action == "load"){ // TODO load slot and set slider positions (no need to reset max)
      sendData("loadFromSave", {slot: slot});

      if (closetopen){
        $(".closetpanel").fadeOut();
        sendData("closeCloset", {slot: slot});
        closetopen = false
      }
    }
  });

  $(".hidecomp-button").click(function(){
    let catid = parseInt($(this).siblings(".cat-range").data("cid"));
    let slider = $(this).parent().siblings(".option-slider");
    
    slider.slider("setValue", 0);
    slider.slider("refresh");
    updateNavLabel(slider, 0);

    console.log("catid " + catid);

    if (catid <= 12){
      sendData("setNullValueComponent", {cid: catid});
    }
  });

  $(document).on("click", ".hair-swatch", function(){
    let colorid = parseInt($(this).data("colorid"));

    $(".hair-swatch").removeClass("hair-swatch-selected");
    $(this).addClass("hair-swatch-selected");

    sendData("setHairColor", {colorid: colorid});
  });

  $(document).on("click", ".btnPurchaseComp", function(){
    $(this).prop("disabled", true);
    sendData("bms:charcreator:purchaseComp", "");
  });
  
  // ESC press
	document.onkeyup = function(data) {
		if (data.which == 27) {
			playSound("SELECT");
			if (closetopen){
        $(".closetpanel").fadeOut();
        sendData("closeCloset");
        closetopen = false
      }
		}
  };

  $(".rulescontent").on("scroll", function(){
    let btn = $(".buttonproceed");
    let t = $(this);
    
    if (t.scrollTop() + t.innerHeight() >= t[0].scrollHeight){
      btn.prop("disabled", false);
    }
    else{
      btn.prop("disabled", true);
    }
  });

  $(".buttonproceed").click(function(){
    $(".rulescontainer").fadeOut();
    sendData("bms:charcreator:rulesexit", "");
  });
  
  initHairColors();
});

function initHairColors(){
  let hairel = $("#tab2").find(".pill-surround").first().find(".haircolor-picker");
  
  for (let i = 0; i < hairColorList.length; i++){
    let color = hairColorList[i];
    let rstr = `<div class="hair-swatch" style="background-color: ${color};" data-colorid="${i}"></div>`;
    
    hairel.append(rstr);
  }
}

function updateNavLabel(slider, value){
  let max = parseFloat(slider.slider("getAttribute", "max"));
  let label = slider.parent().find(".cat-range");

  label.html(`${value}` + "/" + `${max}`);
}

function sendData(name, data, cb){
  $.post("http://charcreator/" + name, JSON.stringify(data), function(datab) {
    if (cb){
      cb(datab);
    }
  });
}

function playSound(sound){
  sendData("playsound", {name: sound});
}

function resetTabs(){
  $("#tab1").hide();
  $("#tab2").hide();
  $("#tab3").hide();
}

function showInfoText(text, delayOut){
  $(".infotext").html(text);
  $(".infobar").fadeIn().slideDown();
  
  setTimeout(() => {
    $(".infobar").slideUp().fadeOut();
    $(".infotext").html("");
  }, delayOut);
}

function setSlot(s){
  slot = s;
  sendData("setSaveSlot", {slot: slot});

  $(".actionbutton-slot").each(function(){
    let data = $(this).data("action");

    if (data == "load" || data == "save"){
      $(this).children(".slot-number").html(slot);
    }
  });
}

function loadSliderValues(pedconfig){
  // do something with config // overlay cids + 15
                              // prop cids + 12
  for (let i = 0; i < pedconfig.parts.length; i++){
    let part = pedconfig.parts[i];
    let cid = part.cid;
    let drawable = part.drawable;
    let element = $(".option-slider[data-cid='" + cid + "']");
    
    element.data("texsel", part.texture); // store this for when the texture bar is rendered
    element.data("texmax", part.texmax);

    if (element.length > 0){
      element.slider("setValue", parseFloat(drawable));
      element.slider("refresh", {useCurrentValue: true});
      updateNavLabel(element, drawable);
      //console.log(`setting part ${cid} to ${drawable}.`);
    }
    else{
      console.log("could not find PART element >> loadSliderValues >> charcreator.js");
    }
  }

  for (let i = 0; i < pedconfig.props.length; i++){
    let pr = pedconfig.props[i];
    let cid;

    if (pr.cid == 6){
      cid = 50;
    }
    else if (pr.cid == 7){
      cid = 51;
    }
    else{
      cid = pr.cid + 12;
    }

    let prop = pr.prop;

    if (prop == -1) prop = 0;

    let element = $(".option-slider[data-cid='" + cid + "']");

    element.data("texsel", pr.pti);
    element.data("texmax", pr.texmax);

    console.log(`texsel >> ${cid}, ${pr.pti}, ${pr.texmax}`);

    if (element.length > 0){
      console.log(`setting >> ${cid}, ${parseFloat(pr.propmax)}, ${prop}`);
      element.slider("setAttribute", "max", parseFloat(pr.propmax));
      element.slider("setValue", parseFloat(prop));
      element.slider("refresh", {useCurrentValue: true});
      updateNavLabel(element, prop);
    }
    else{
      console.log(`could not find PROP element ${cid} >> loadSliderValues >> charcreator.js`);
    }
  }

  for (let i = 0; i < pedconfig.overlays.length; i++){
    let ov = pedconfig.overlays[i];
    let cid = ov.cid + 15;
    let overlay = ov.overlay;

    if (overlay == 255) overlay = 0;

    let element = $(".option-slider[data-cid='" + cid + "']");
    
    element.data("texsel", ov.fcolor)
    element.data("texmax", ov.texmax)

    if (element.length > 0){
      element.slider("setAttribute", "max", parseFloat(ov.ovmax));
      element.slider("setValue", parseFloat(overlay));
      element.slider("refresh", {useCurrentValue: true});
      updateNavLabel(element, overlay);
    }
    else{
      console.log("could not find OVERLAY element >> loadSliderValues >> charcreator.js");
    }
  }
}

function setSliderPartMaxes(maxes, refreshSlider){
  for (let i = 0; i < maxes.length; i++){
    let max = maxes[i];
    let element = $(".option-slider[data-cid='" + max.cid + "']");

    if (element.length > 0){
      element.slider("setAttribute", "max", max.max);
            
      if (refreshSlider){
        element.slider("setValue", 0);
        element.slider("refresh");
      }
      
      element.siblings(".cat-info").children(".cat-range").html(`0/${max.max}`);
    }
    else{
      console.log("element mismatch >> charcreator.js >> setSliderPartMaxes");
    }
  }
}

function setTextureSliderMax(cid, max){
  $(".pill-surround").each(function(){
    let cat = parseInt($(this).children(".cat-info").children(".cat-range").data("cid"));

    if (cat == cid){
      let texsel = $(this).children(".texture-selector");
      //let label = texsel.children(".tex-range");
      let slider = texsel.children(".texture-slider");
      let label = slider.siblings(".tex-info").children(".tex-range");

      label.html(`0/${parseInt(max)}`);
      slider.slider("setAttribute", "max", parseFloat(max));
      slider.slider("setValue", 0);
      slider.slider("refresh", {useCurrentValue: true});
    }
  });
}

function loadServerRules(appendel, showel){
  $.get("https://discourse.larp-servers.org/t/fivem-server-rules/48.json", function(data){
    let msg = data.post_stream.posts[0].cooked;
    let leading = `<h1 style="color: yellow">Los Angeles Roleplay - Server Rules</h1><br/><br/>`;

    $(appendel).html(leading + msg);
    $(showel).fadeIn();
    $(appendel).focus();
  });
}