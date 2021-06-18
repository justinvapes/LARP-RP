let bar;
let hitspot;
let fishShowing = false;
let growitems = 0;
let lastfarmindex = 0;
let blockDropGive = false;
let tune = {};
let currenthandling = {};

$(function(){
  let boostSlider = $("#boostSlider");
  let accelerationSlider = $("#accelerationSlider");
  let gearSlider = $("#gearSlider");
  let brakingSlider = $("#brakingSlider");
  let drivetrainSlider = $("#drivetrainSlider");

  window.addEventListener("message", function(event){
    let data = event.data;

    if (data.showFishingBoard){
      var html = data.htmlstr;

      $("#fishitems").children().remove();
      $("#fishitems").append(html);
      $("#fishboards").show();
      fishShowing = true;
      //console.log("showing fish boards");
    }
    else if (data.hideFishingBoard)
    {
      $("#fishboards").hide();
      sendData("closeFishBoards", "");
      fishShowing = false;
      //console.log("hiding fish boards");
    }
    else if (data.updateJobProgress)
    {
      $("#progcontainer").show();
      $("#progtitle").html(data.title);
      $("#jobprogress").progressbar({
        max: data.maxvalue,
        value: data.progvalue
      });
      $("#jobprogress").css({"background": "gray"});
      $("#jobprogress > div").css({"background": "skyblue"});
      if (data.progvalue < data.maxvalue - 1) {
        //$(".ui-progressbar-value").css({"transition": "width 1s", "-webkit-transition": "width 1s"});
      }
    }
    else if (data.hideJobProgress){
      $("#progcontainer").hide();
      //$(".ui-progressbar-value").css({"transition": "width 0s", "-webkit-transition": "width 0s"});
    }
    else if (data.showFishIcon){
      $(".fishicon").blink({delay: 125});
    }
    else if (data.hideFishIcon){
      $(".fishicon").unblink();
    }
    else if (data.toggleLawnIcon){
      let val = data.toggle;

      if (val){
        $(".lawncontainer").show();
      }
      else{
        $(".lawncontainer").hide();
      }
    }
    else if (data.setLawnAmount){
      let amt = data.amount || 0;

      $(".lawntext").html(`$${amt}`);
    }
    else if (data.openSeedInv){
      $(".seedcontainer").fadeIn();
      renderSeeds(data.seeds);
      $(".growitems").children().remove();
      $(".warntext").html("");
      $(".warningpanel").hide();
      $(".weights").html(`${data.weight.toFixed(1)} | ${data.maxweight}`);
      growitems = 0;
    }
    else if (data.updateSeedInv){
      renderSeeds(data.seeds);
      $(".growitems").children().remove();
      $(".warntext").html("");
      $(".warningpanel").hide();
      $(".weights").html(`${data.weight.toFixed(1)} | ${data.maxweight}`);
      growitems = 0;
    }
    else if (data.weedProgress){
      let fieldid = data.fieldid;

      updateWeedProgress(fieldid, data);
    }
    else if (data.hideWeedProgress){
      let fieldid = data.fieldid;
      let destroy = data.destroy;

      if (fieldid) {
        hideWeedProgress(fieldid, destroy);
      }
    }
    else if (data.mushroomProgress){
      let boxId = data.boxId;

      updateMushroomProgress(boxId, data);
    }
    else if (data.hideMushroomProgress){
      let boxId = data.boxId;
      let destroy = data.destroy;

      if (boxId){
        hideMushroomProgress(boxId, destroy);
      }
    }
    else if (data.createMushroomProgress){
      let boxId = data.boxId;

      if (boxId){
        addMushroomProgressBar(boxId);
      }
    }
    else if (data.blockDropGive){
      blockDropGive = data.value || false;
    }
    else if (data.createFieldProgress){
      let fieldid = data.fieldid;

      if (fieldid){
        addFieldProgressBar(fieldid);
      }
    }
    else if (data.showTuner){
      let tunesettings = data.tunesettings;
      let curhandling = data.curhandling;

      tune = tunesettings;
      currenthandling = curhandling;
      boostSlider.val(tune.boost);
      accelerationSlider.val(tune.acceleration);
      gearSlider.val(tune.gearchange);
      brakingSlider.val(tune.braking);
      drivetrainSlider.val(tune.drivetrain);
      $(".tunerContainer").fadeIn();
    }
    else if (data.hideTuner){
      $(".tunerContainer").fadeOut();
    }
    else if (data.showMineProgress){
      $(".mineProgressContainer").fadeIn();
    }
    else if (data.hideMineProgress){
      $(".mineProgressContainer").fadeOut();
    }
    else if (data.setMineProgressVal){
      updateRockProgress(data.value, data.max);
    }
    else if (data.setMineProgressPosition){
      $(".mineProgressContainer").fadeIn();
      updateRockProgressPosition(data.px, data.py);
    }
    else if (data.showBiohazard){
      $(".biohazard").fadeIn();
    }
    else if (data.hideBiohazard){
      $(".biohazard").fadeOut();
    }
    else if (data.showGenericInfo){
      renderGenericInfo(data.data, data.title);
    }
    else if (data.newsTimeoutOverlay){
      if (data.overlays){
        showNewsTimeoutOverlay(data.overlays);
      }
    }
    else if (data.hideNewsOverlay){
      hideNewsOverlay();
    }
    else if (data.toggleCameraHelp){
      data.val ? $(".newsCameraHelp").stop().fadeIn() : $(".newsCameraHelp").stop().fadeOut();
    }
    else if (data.hideNewsHelp){
      $(".newsCameraHelp").stop().fadeOut();
    }
  });

  document.onkeyup = function (data) {
    if (fishShowing && $("#fishboards").is(":visible")){
      if (data.which == 71) { // G - 71 | Old key: F2 - 113 | Esc - 27
        $("#fishboards").hide();
        sendData("closeFishBoards", "");
        fishShowing = false;
      }
    }
  };

  $(".exitbutton").click(function(){
    $(".seedcontainer").fadeOut();
    sendData("bms:jobs:seedinventory:closeinv", "");
  });

  /* spinners */
  $(document).on("mouseover", ".seeditem", function(){
    $(this).find(".qtyinput").fadeIn();
    $(this).find(".dropbutton").fadeIn();
    $(this).find(".givebutton").fadeIn();
  });
  
  $(document).on("mouseleave", ".seeditem", function(){
    $(this).find(".qtyinput").fadeOut();
    $(this).find(".dropbutton").fadeOut();
    $(this).find(".givebutton").fadeOut();
  });

  $(document).on("click", ".dropbutton", function(){
    if (!blockDropGive){
      blockDropGive = true;
      let name = $(this).siblings(".seedtext").html();
      let qty = parseInt($(this).parent().parent().find(".form-control-sm").val());

      if (qty > 0){
        sendData("bms:jobs:seedinventory:dropSeed", {name: name, quantity: qty});
      }
      else{
        blockDropGive = false;
      }
    }
  });

  $(document).on("click", ".givebutton", function(){
    if (!blockDropGive){
      blockDropGive = true;
      let name = $(this).siblings(".seedtext").html();
      let qty = parseInt($(this).parent().parent().find(".form-control-sm").val());

      if (qty > 0){
        sendData("bms:jobs:seedinventory:giveSeed", {name: name, quantity: qty});
      }
      else{
        blockDropGive = false;
      }
    }
  });

  $(document).on("input", ".form-control-sm", function(){
    let val = $(this).val();
    let name = $(this).parent().parent().siblings().find(".seedtext").html();

    if (val && name){
      renderGrowList(name, val);
    }
  });
  /**/

  $(".buttonplant").click(function(){
    //$(".growitems").append(`<div class="grow-seeditem" data-seedname="${nm}">${nm}<span class="growprevqty badge badge-dark">${val}</span></div>`);
    let growlist = {items: []};

    $(".grow-seeditem").each(function(){
      let name = $(this).data("seedname");
      let qty = parseInt($(this).children(".growprevqty").html());

      growlist.items.push({name: name, quantity: qty});
    });

    if (growlist.items.length == 0){
      $(".plantpanel").fadeOut();
      $(".warningpanel").fadeIn();
      $(".warntext").html("You must select up to 12 seed types first.");
      setTimeout(() => {
        $(".warningpanel").fadeOut();
        $(".plantpanel").fadeIn();
      }, 2000);
    }
    else{
      $(".seedcontainer").fadeOut();
      sendData("bms:jobs:weedfarms:placeFarmGrowList", growlist);
    }
  });
  
  /* tuner */
  $(".btnTunerReset").click(function(){
    boostSlider.val(0);
    accelerationSlider.val(0);
    gearSlider.val(0);
    brakingSlider.val(5);
    drivetrainSlider.val(5);

    tune.boost = JSON.parse(calcBoost(currenthandling.fInitialDriveForce, boostSlider.val()));
    tune.acceleration = JSON.parse(calcAcc(currenthandling.fDriveInertia, accelerationSlider.val()));
    tune.gearchange = JSON.parse(calcGears(currenthandling.fClutchChangeRateScaleUpShift, gearSlider.val()));
    tune.braking = JSON.parse(calcBrakes(10, brakingSlider.val()));
    tune.drivetrain = JSON.parse(calcDriveTrain(10, drivetrainSlider.val()));
    updateTunerValues(tune.boost, tune.acceleration, tune.gearchange, tune.braking, tune.drivetrain);
  });

  $(".btnTunerApply").click(function(){
    tune.uivalues = {
      boost: JSON.parse(boostSlider.val()),
      acceleration: JSON.parse(accelerationSlider.val()),
      gearchange: JSON.parse(gearSlider.val()),
      braking: JSON.parse(brakingSlider.val()),
      drivetrain: JSON.parse(drivetrainSlider.val())
    }

    console.log(JSON.stringify(tune));
    sendData("bms:jobs:tuner:applyTunerMods", tune);
  });

  $(".btnTunerCancel").click(function(){
    $(".tunerContainer").fadeOut();
    sendData("bms:jobs:tuner:menuExit", "");
  });

  boostSlider.on("input", (event) => {
    console.log(currenthandling.fInitialDriveForce);
    let newBoost = calcBoost(currenthandling.fInitialDriveForce, $(event.target).val());

    tune.boost = JSON.parse(newBoost);
    $("#currentBoost").html(newBoost);
  });

  accelerationSlider.on("input", (event) => {
    let newAcceleration = calcAcc(currenthandling.fDriveInertia, $(event.target).val());

    tune.acceleration = JSON.parse(newAcceleration);
    $("#currentAcceleration").html(newAcceleration);
    console.log(newAcceleration);
  });

  gearSlider.on("input", (event) => {
    let newGearChange = calcGears(currenthandling.fClutchChangeRateScaleUpShift, $(event.target).val());

    tune.gearchange = JSON.parse(newGearChange);
    $("#currentGearChange").html(newGearChange);
  });

  brakingSlider.on("input", (event) => {
    let newBraking = calcBrakes(10, $(event.target).val());

    tune.braking = JSON.parse(newBraking);
    console.log("setting to " + newBraking);
    $("#currentBraking").html(newBraking);
  });

  drivetrainSlider.on("input", (event) => {
    let newDriveTrain = calcDriveTrain(10, $(event.target).val());
    
    tune.drivetrain = JSON.parse(newDriveTrain);
    $("#currentDriveTrain").html(newDriveTrain);
  });

  $(".btn-ginfoExit").click(function(){
    $(".genericInfoPanel").fadeOut();
    sendData("bms:ginfoClose", {});
  });
});

function sendData(name, data){
  $.post("http://jobs/" + name, JSON.stringify(data), function(datab) {
      //console.log(datab);
  });
}

function playSound(sound) {
  sendData("playsound", {name: sound});
}

// mini-game related
function startMinigame() {
  gameArea.start();
  bar = new component(400, 50, "gray", 240, 50);
  hitspot = new component(65, 65, "skyblue", 240, 50);
}

var gameArea = {
  canvas : $("#gameContainer").append("<canvas id='canvas' class='maincanvas'></canvas>"),
  start : function() {
    this.canvas.width = 480;
    this.canvas.height = 100;
    this.context = this.canvas.getContext("2d");
    this.inverval = setInterval(updateGameArea, 20);
  },
  clear: function() {
    this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
  }
}

function component(width, height, color, x, y) {
  this.width = width;
  this.height = height;
  this.x = x;
  this.y = y;

  this.update = function() {
    ctx = gameArea.context;
    ctx.fillStyle = color;
    ctx.fillRect(this.x, this.y, this.width, this.height);
  }
}

function updateGameArea() {
  gameArea.clear();
  //bar.update(); // bar is a static element
  var dir = 0;

  if (hitspot.x >= 400) {
    dir = 0;
  }
  else if (hitspot.x <= 40) {
    dir = 1;
  }

  if (dir == 0) {
    hitspot.x -= 1;
  }
  else {
    hitspot.x += 1;
  }
  

  hitspot.update();
}
// end mini-game

function renderSeeds(seeds){
  $(".seeditems").children().remove();
  let keys = Object.keys(seeds);
  keys.sort();

  for (let i = 0; i < keys.length; i++){
    let seed = seeds[keys[i]];

    $(".seeditems").append(`<div class="row seeditem">
      <div class="col-1">
        <div class="seedicon"></div>
      </div>
      <div class="col-3">
        <div class="qtyinput"><input class="form-control-sm" type="number" value="0" min="0" max="${seed.q}" step="1"/></div>
      </div>
      <div class="col-8">
        <div class="seedtext">${keys[i]}</div>
        <button class="givebutton give blue-grad ">
          <i class="fas fa-angle-right fa-sm"></i>
        </button>
        <button class="dropbutton drop red-grad">X</button>
        <span class="seedquantity badge badge-dark">${seed.q}</span>
      </div>
    </div>`);
  }

  $(".form-control-sm").inputSpinner();
}

function getSeedGrowCount(){
  growitems = 0;
  
  $(".grow-seeditem").each(function(){
    let qty = parseInt($(this).children(".growprevqty").html());
    growitems = growitems + qty;
  });

  return growitems;
}

function renderGrowList(nm, val){
  //<!--<div class="grow-seeditem">Seed Name Blah Kush<span class="growprevqty badge badge-dark">1</span></div>-->
  let found = false;

  $(".grow-seeditem").each(function(){
    let name = $(this).data("seedname");
  
    if (nm == name) {
      found = true;
      if (val > 0){
        $(this).find(".growprevqty").html(val);
      }
      else{
        $(".grow-seeditem[data-seedname='" + nm + "']").remove();
      }
    }
  });

  if (!found && val > 0){
    $(".growitems").append(`<div class="grow-seeditem" data-seedname="${nm}">${nm}<span class="growprevqty badge badge-dark">${val}</span></div>`);
  }

  let count = getSeedGrowCount();

  if (count > 12){
    $(".plantpanel").fadeOut();
    $(".warningpanel").fadeIn();
    $(".warntext").html(`You can plant a maximum of 12 mixed seed types. You currently have ${count}.`);
  }
  else{
    $(".warntext").html("");
    $(".warningpanel").fadeOut();
    $(".plantpanel").fadeIn();
  }
}

function renderHarvestIcons(coords){
  $(".harvestIconsContainer").children().remove();

  // create icons and fade them in
  for (var i = 0; i < coords.length; i++){
    let coord = coords[i];
    $(".harvestIconsContainer").append(`<div class="harvesticon" data-id=${i}><div>`);

    let px = window.innerWidth * parseFloat(coord.x);
    let py = window.innerHeight * parseFloat(coord.y);
    
    $(".plantProgressContainer").offset({left: px - 21, top: py - 21});
  }
}

function updateHarvestIcons(coords){
  for (var i = 0; i < coords.length; i++){
    let coord = coords[i];
    let px = window.innerWidth * parseFloat(coord.x);
    let py = window.innerHeight * parseFloat(coord.y);

    $(".harvesticon[data-id='" + i + "']").offset({left: px - 21, top: py - 21});
  }
}

function hideHarvestIcons(){
  $(".harvesticon").fadeOut();
}

function hideHarvestIcon(pid){
  $(".harvesticon[data-id='" + pid + "']").fadeOut();
}

function addFieldProgressBar(fieldid){
  let progresscon = $(".fieldProgress[data-fieldid='" + fieldid + "']");

  if (progresscon.length == 0){
    let field = $(".fieldProgressContainers").append(`<div class="fieldProgress" data-fieldid="${fieldid}">
      <div class="progress-bar bg-success progress-bar-striped progress-bar-animated weedprogress" style="width: 0%;" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100">0%</div>
      <div class="progress-bar bg-info progress-bar-striped progress-bar-animated hydroprogress" style="width: 100%;" role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100">100%</div>
    </div>`);

    return field;
  }
}

function addMushroomProgressBar(boxId){
  let progresscon = $(".mushroomBoxProgress[data-boxid='" + boxId + "']");

  if (progresscon.length == 0){
    let box = $(".mushroomProgressContainers").append(`
      <div class="mushroomBoxProgress p-1" data-boxid="${boxId}">
        <span class="progressSmallText pl-3">Progress</span>
        <div class="progress-bar bg-success progress-bar-striped progress-bar-animated mushroomProgress" style="width: 0%;" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100">
          0%
        </div>
        <span class="progressSmallText pl-3 mt-1">Humidity</span>
        <div class="progress-bar bg-info progress-bar-striped progress-bar-animated mr-humidProgress" style="width: 100%;" role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100">
          100%
        </div>
      </div>`);

    return box;
  }
}

function updateWeedProgress(fieldid, data){
  let progresscon = $(".fieldProgress[data-fieldid='" + fieldid + "']");

  if (progresscon.length == 0){
    progresscon = addFieldProgressBar(fieldid);
  }

  let weedprog = progresscon.find(".weedprogress");
  let hydroprog = progresscon.find(".hydroprogress");

  if (data.setGrowValue){
    weedprog.attr("aria-valuenow", data.gvalue);
    weedprog.css("width", data.gvalue + "%");
    weedprog.html(`${data.gvalue}%`);
  }

  if (data.setHydroValue){
    hydroprog.attr("aria-valuenow", data.hvalue);
    hydroprog.css("width", data.hvalue + "%");
    hydroprog.html(`${data.hvalue}%`);
  }

  if (data.setPosition){
    let px = window.innerWidth * parseFloat(data.px);
    let py = window.innerHeight * parseFloat(data.py);
    let elw = parseFloat(progresscon.width());
    let elh = parseFloat(progresscon.height());

    progresscon.offset({left: px - (elw / 2), top: py - (elh / 2)});
  }

  if (!progresscon.is(":visible")){
    progresscon.fadeIn();
  }
}

function updateMushroomProgress(boxId, data){
  let progresscon = $(".mushroomBoxProgress[data-boxid='" + boxId + "']");

  if (progresscon.length == 0){
    progresscon = addMushroomProgressBar(boxId);
  }

  let mrprog = progresscon.find(".mushroomProgress");
  let humidProg = progresscon.find(".mr-humidProgress");

  if (data.setGrowValue){
    mrprog.attr("aria-valuenow", data.gValue);
    mrprog.css("width", data.gValue + "%");
    mrprog.html(`${data.gValue}%`);
  }

  if (data.setHumidValue){
    humidProg.attr("aria-valuenow", data.hValue);
    humidProg.css("width", data.hValue + "%");
    humidProg.html(`${data.hValue}%`);
  }

  if (data.setPosition){
    let px = window.innerWidth * parseFloat(data.px);
    let py = window.innerHeight * parseFloat(data.py);
    let elw = parseFloat(progresscon.width());
    let elh = parseFloat(progresscon.height());

    progresscon.offset({left: px - (elw / 2), top: py - (elh / 2)});
  }

  if (!progresscon.is(":visible")){
    progresscon.fadeIn();
  }
}

function hideWeedProgress(fieldid, destroy){
  if (fieldid > -1){
    let progresscon = $(".fieldProgress[data-fieldid='" + fieldid + "']");
  
    if (progresscon.length > 0){
      progresscon.fadeOut(function(){
        if (destroy){
          progresscon.remove();
        }
      });
    }
  }
  else{
    $(".fieldProgress").fadeOut();
  }
}

function hideMushroomProgress(boxId, destroy){
  if (boxId > -1){
    let progresscon = $(".mushroomBoxProgress[data-boxid='" + boxId + "']");

    if (progresscon.length > 0){
      progresscon.hide();

      if (destroy){
        console.log(`destroying ${boxId}`);
        progresscon.remove();
      }
      /*progresscon.stop().fadeOut(function(){ -- not sure why this is failing, it works on weed?
        if (destroy){
          progresscon.remove();
        }
      });*/
    }
  }
  else{
    $(".mushroomBoxProgress").stop().fadeOut();
  }
}

function updateRockProgress(value, max){
  let rprog = $(".rockProgress");

  rprog.attr("aria-valuemax", max);
  rprog.attr("aria-valuenow", value);

  let percval = Math.floor((value / max) * 100);

  rprog.css("width", percval + "%");
  rprog.find(".rockProgText").html(`${percval}%`);
}

function updateRockProgressPosition(x, y){
  let progContainer = $(".mineProgressContainer");
  let px = window.innerWidth * parseFloat(x);
  let py = window.innerHeight * parseFloat(y);
  let elw = parseFloat(progContainer.width());
  let elh = parseFloat(progContainer.height());

  progContainer.offset({left: px - (elw / 2), top: py - (elh / 2)});
}

/* tuner */
function calcBoost(def, newVal) {
  return def + def * (newVal / 200);
}

function calcAcc(def, newVal) {
  return def + def * (newVal / 30);
}

function calcGears(def, newVal) {
  return newVal;
}

function calcBrakes(def, newVal) {
  return newVal / 10;
}

function calcDriveTrain(def, newVal) {
  return newVal / 10;
}

function updateTunerValues(boost, acc, gear, brakes, drivetrain) {
  $("#currentBoost").html(boost);
  $("#currentAcceleration").html(acc);
  $("#currentGearChange").html(gear);
  $("#currentBraking").html(brakes);
  $("#currentDriveTrain").html(drivetrain);
}

function renderGenericInfo(data, title){  
  let profit = Math.floor(data.profit);

  $(".ginfo-title").html(title);
  $(".ginfo-body").children().remove();
  $(".ginfo-body").append(`
    <div class="row">
      <div class="col">
        You have earned <span style="color: #4CBD74">$${profit}</span> from selling fish / meat.
      </div>
    </div>
    <div class="row mt-1 mb-1">
      <div class="col" style="color: white; font-style: italic;">
        Profit breakdown:
      </div>
    </div>
    <div class="row">
      <div class="col-4 huntingHighlight">
        Name
      </div>
      <div class="col-3 huntingHighlight">
        Skill Bonus
      </div>
      <div class="col-3 huntingHighlight">
        Rarity Bonus
      </div>
      <div class="col-2 huntingHighlight">
        Weight
      </div>
    </div>
  `);
  
  for (let i = 0; i < data.profits.length; i++){
    let item = data.profits[i];

    $(".ginfo-body").append(`
      <div class="row huntingSoldItem">
        <div class="col-4">
          ${item.name}
        </div>
        <div class="col-3">
          <span style="#4CBD74">$${item.skbonus || ""}</span>
        </div>
        <div class="col-3">
          <span style="#4CBD74">$${item.rarity || "0"}</span>
        </div>
        <div class="col-2">
          <span style="#FFC005">${item.weight || ""}</span>
        </div>
      </div>
    `);
  }

  $(".genericInfoPanel").fadeIn();
}

function showNewsTimeoutOverlay(overlays){
  let panel = $(".newsOverlayPanel");
  let anchor = $(".newsOverlayAnchor");

  anchor.html(`Overlay switched to '${overlays.nameref}'. Strength: ${overlays.strength.toFixed(2)}`);
  
  if (!panel.is(":visible")){
    panel.stop().fadeIn().delay(overlays.fadeTimeout || 5000).fadeOut();
  }
}

function hideNewsOverlay(){
  let panel = $(".newsOverlayPanel");

  panel.stop().fadeOut();
}

// blinking
(function($) {
  $.fn.blink = function(options) {
      var defaults = { delay: 500 };
      var options = $.extend(defaults, options);
      
      return $(this).each(function(idx, itm) {
        var handle = setInterval(function() {
          if ($(itm).is(":visible")) {
            //$(itm).hide();
            $(itm).fadeOut("slow", function(){
              $(itm).hide();
            });
          }
          else{
            $(itm).fadeIn("slow");                
          }
        }, options.delay);

        $(itm).data('handle', handle);
      });
  }
  $.fn.unblink = function() {
      return $(this).each(function(idx, itm) {
        var handle = $(itm).data('handle');
        if (handle) {
          clearInterval(handle);
          $(itm).data('handle', null);
          $(itm).hide();
        }
      });
  }
}(jQuery))