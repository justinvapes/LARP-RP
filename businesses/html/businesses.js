let blockfunds = false;
let psmarkup = 1;
let symarkup = 1;
let tsmarkup = 1;
let itemprev = [];
let blockEmpAdd = false;
let takemod = 0.5;
let cdcontainer;
let vcolors;
let vcars;
let lastctype = 1;
let lastcsel = -1;
let blockcarentry = false;
let cbtotal = 0;
let modtotals = {};
let stockselection = false;
let blockemprem = false;
let mechPurchasedUpgrades = {blcolor: -1, customs: false};
let recyclePurchasedUpgrades = {blcolor: -1};
let upgradePrices = {};
let blipcolors = {};

/*modtotals["11"] = {"2": 4000}
modtotals["8"] = {"1": 12330}

console.log(modtotals["11"]["2"]); // 4000
console.log(JSON.stringify(modtotals));
*/

/*if (!modtotals["11"]) {
  modtotals["11"] = {["43"]: 4000};
  modtotals["8"] = {["14"]: 192000};
}

getModTotals();*/

$(function(){
  var manageid = 0
  
  window.addEventListener("message", function(event){
    var item = event.data;

    if (item.showManager){
      manageid = item.manageid;
      $("#stationname").val(item.stationname);
      $("#thanksmessage").val(item.thanksmessage);
      $("#fuelcost").val(item.fuelcost);
      $("#sellname").val("");
      $("input[type=radio][name=deltype][value=" + item.deltype + "]").prop("checked", true).change();
      $("#delbonus").val(item.delbonus);

      if (item.deltype == 3){
        $("#deliverycontainer").show();
      }
      else{
        $("#deliverycontainer").hide();
      }

      $("#stationmoney").html("$" + item.funds);
      processDeliveryList(item.deliverylist);
      $("#maincontainer").show();
    }
    else if (item.closeManager){
      $("#maincontainer").hide();
    }
    else if (item.setStatus){
      $("#statustext").html(item.text);
      blink("#statustext");
    }
    else if (item.setFunds){
      $("#stationmoney").html("$" + item.stationmoney);
      blockfunds = false;
    }
    else if (item.setPsFunds){
      $(".ps-cash").html("$" + item.amount);
      blockfunds = false;
    }
    else if (item.showPsManage){
      $(".ps-cash").html("$" + item.cash);
      $("#ps-markup").val(item.markup);
      $("#ps-shopname").val(item.shopname);
      $("#ps-thanks").val(item.thanksmessage);
      itemprev = item.itemprev;
      takemod = item.takemod;
      renderMarkupPreview(item.markup, takemod);
      psmarkup = item.markup;
      $("#pawnmanage").show();
    }
    else if (item.setSyFunds){
      $(".sy-cash").html("$" + item.amount);
      blockfunds = false;
    }
    else if (item.showSyManage){
      $(".sy-cash").html("$" + item.cash);
      $("#sy-markup").val(item.markup);
      $("#sy-shopname").val(item.shopname);
      $("#sy-thanks").val(item.thanksmessage);
      itemprev = item.itemprev;
      renderSyMarkupPreview(item.markup);
      symarkup = item.markup;
      $("#scrapmanage").show();
    }
    else if (item.unblockEmpAdd){
      blockEmpAdd = false;
      renderEmployees(item.emplist);
    }
    else if (item.setTsFunds){
      $(".ts-cash").html("$" + item.amount);
      blockfunds = false;
    }
    else if (item.showTsManage){
      $(".ts-cash").html("$" + item.cash);
      $("#ts-markup").val(item.markup);
      $("#ts-shopname").val(item.shopname);
      $("#ts-thanks").val(item.thanksmessage);
      tsmarkup = item.markup;
      $("#tatmanage").show();
    }

    /* Mechanic Shop Management */
    else if (item.showMsManage){
      $("#mechstatustext").html("");
      $("#mechmoney").html("$" + item.cash);
      $("#ms-markup").val(item.markup);
      $("#ms-shopname").val(item.shopname);
      $("#ms-thanksmsg").val(item.thanksmessage);
      $("#mechmanage").show();

      blipcolors = item.blipcolors;
      upgradePrices = item.prices;
      if (item.upgrades){
        mechPurchasedUpgrades = item.upgrades;
      }

      processMechEmployees(item.emps || {})
    }
    else if (item.sendMechNotification){
      $("#mechstatustext").html(item.text);
    }
    else if (item.updateMechCash){
      $("#mechmoney").html("$" + item.cash);
      $("#ms-addfunds").val("0");
      $("#ms-remfunds").val("0");
      $("#mechstatustext").html(`Your new amount is <font color='limegreen'>$${item.cash}</font>.`);
    }
    else if (item.updateMechUpgrades){
      $("#mechmoney").html("$" + item.cash);
      mechPurchasedUpgrades = item.upgrades;
      $("#mechUpgradeTotal").html("$0");
      $("#mechstatustext").html("Your upgrades have been <font color='limegreen'>saved.</font>");
      initMechUpgrades();
    }

    /* Recycle Center Management */
    else if (item.showRecycleManage){
      $("#recyclestatustext").html("");
      $("#recyclemoney").html("$" + item.cash);
      $("#recycle-name").val(item.centerName);
      $("#recycle-thanksmsg").val(item.thanksmessage);

      blipcolors = item.blipcolors;
      upgradePrices = item.upgradePrices;
      if (item.upgrades){
        recyclePurchasedUpgrades = item.upgrades;
      }

      if (item.prices){
        $("#recyclePrice-plastic").val(item.prices.plastic);
        $("#recyclePrice-metal").val(item.prices.metal);
        $("#recyclePrice-ceram").val(item.prices.ceram);
        $("#recyclePrice-elec").val(item.prices.elec);
      }
      if (item.stock){
        $("#recycleRaw-plastic").html(item.stock[0] || 0);
        $("#recycleRaw-metal").html(item.stock[1] || 0);
        $("#recycleRaw-ceram").html(item.stock[2] || 0);
        $("#recycleRaw-elec").html(item.stock[3] || 0);
      }
      $("#recyclemanage").show();
    }
    else if (item.sendRecycleNotification){
      $("#recyclestatustext").html(item.text);
    }
    else if (item.updateRecycleCash){
      $("#recyclemoney").html("$" + item.cash);
      $("#recycle-addfunds").val("0");
      $("#recycle-remfunds").val("0");
      $("#recyclestatustext").html(`Your new amount is <font color='limegreen'>$${item.cash}</font>.`);
    }
    else if (item.updateRecycleUpgrades){
      $("#recyclemoney").html("$" + item.cash);
      recyclePurchasedUpgrades = item.upgrades;
      $("#recycleUpgradeTotal").html("$0");
      $("#recyclestatustext").html("Your upgrades have been <font color='limegreen'>saved.</font>");
      initRecycleUpgrades();
    }
    else if (item.zeroRecycleStock){
      $("#recycleRaw-plastic").html(0);
      $("#recycleRaw-metal").html(0);
      $("#recycleRaw-ceram").html(0);
      $("#recycleRaw-elec").html(0);
    }
  });

  $("#applychange").click(function(){
    $("#statustext").html("");

    if ($("#stationname").val() == ""){
      $("#statustext").html("You must enter a station name to continue.");
      blink("#statustext");
    }
    else if ($("#fuelcost").val() == ""){
      $("#statustext").html("You must enter a fuel cost to continue.");
      blink("#statustext");
    }
    else if ($("input[type-radio][name=deltype]:checked").val() == 3 && $("#deliverylist").find("font").length == 0){
      $("#statustext").html("You must enter at least one name with this delivery type.");
      blink("#statustext");
    }
    else{
      var deliverylist = "";
      
      if ($("input[type=radio][name=deltype]:checked").val() == 3){
        $("#deliverylist").find("font").each(function(i){
          if ($(this).data("item")){
            deliverylist = deliverylist + $(this).data("item") + ";";
          }
        });        
      }

      console.log("Delivery list: " + deliverylist);

      if (parseInt($("#delbonus").val()) < 0){
        $("#delbonus").val("0");
      }
      
      sendData("bms:businesses:manage", {manageid: manageid, stationname: $("#stationname").val(), thanksmessage: $("#thanksmessage").val(),fuelcost: $("#fuelcost").val(),
        deltype: $("input[type=radio][name=deltype]:checked").val(), deliverylist: deliverylist, delbonus: parseInt($("#delbonus").val())});
      $("#maincontainer").hide();
    }
  });

  $("#sellstation").click(function(){
    if ($("#sellname").val() == ""){
      $("#statustext").html("You must enter a character name to sell this station.");
      blink("#statustext");
    }
    else{
      sendData("bms:businesses:sellstation", {sellname: $("#sellname").val(), manageid: manageid});
    }
  });

  $("#exitmanager").click(function(){
    $("#statustext").html("");
    $("#maincontainer").hide();
    sendData("menuclosed", "");
  });

  $("input[type=radio][name=deltype]").change(function(){
    if (this.value == "3"){
      $("#deliverycontainer").show();
    }
    else{
      $("#deliverycontainer").hide();
    }
  });

  $("#addplayerbutton").click(function(){
    var item = $("#addplayertolist").val();
    
    if (item == ""){
      $("#statustext").html("You must enter a character name.");
      blink("#statustext");
    }
    else{
      $("#statustext").html("");
      $("#addplayertolist").val("");
      $("#deliverylist").append('<div id="litem"><font class="listresult" data-item="' + item + '">' + item + '<font class="listdelbutton" data-sel="' + item + '">X</font></font></div>');
    }
  });

  $("#addfundsbutton").click(function(){
    if (!blockfunds){
      var amount = parseInt($("#addfunds").val());

      if (amount > 0){
        blockfunds = true;
        $("#addfunds").val("0");
        sendData("bms:businesses:addstationfunds", {manageid: manageid, amount: amount});
      }
    }
  });

  $("#remfundsbutton").click(function(){
    if (!blockfunds){
      var amount = parseInt($("#remfunds").val());

      if (amount > 0){
        blockfunds = true;
        $("#remfunds").val("0");
        sendData("bms:businesses:remstationfunds", {manageid: manageid, amount: amount});
      }
    }
  });

  $(document).on("click", ".listdelbutton", function(){
    var selected = $(this).data("sel");

    console.log(selected);
    
    $("#deliverylist").find("font").each(function(i){
      if ($(this).data("item") == selected){
        //$(this).remove();
        $(this).closest("div").remove();
      }
    });
  });

  // Pawn
  $("#ps-addfundsbutton").click(function(){
    if (blockfunds) return;
    
    let val = parseInt($("#ps-addfunds").val());

    if (val > 0){
      blockfunds = true;
      $("#ps-addfunds").val("0");
      sendData("bms:businesses:psaddfunds", {amount: val});
    }
  });

  $("#ps-remfundsbutton").click(function(){
    if (blockfunds) return;

    let val = parseInt($("#ps-remfunds").val());

    if (val > 0){
      blockfunds = true;
      $("#ps-remfunds").val("0");
      sendData("bms:businesses:psremfunds", {amount: val});
    }
  });

  $("#ps-exitbutton").click(function(){
    let val = parseInt($("#ps-markup").val());
    let name = $("#ps-shopname").val() || "Pawn-It Proshop";
    let thanks = $("#ps-thanks").val();

    psmarkup = val;
    sendData("bms:businesses:psChangeSettings", {markup: val, name: name, thanks: thanks});
    $("#pawnmanage").hide();
  });

  $(document).on("keyup change click", "#ps-markup", function () {
		if (!$(this).data("previousValue") || $(this).data("previousValue") != $(this).val()){
      $(this).data("previousValue", $(this).val());
			renderMarkupPreview(parseInt($("#ps-markup").val()), takemod);
   	}
  });
  
  // Scrapyards
  $("#sy-addfundsbutton").click(function(){
    if (blockfunds) return;
    
    let val = parseInt($("#sy-addfunds").val());

    if (val > 0){
      blockfunds = true;
      $("#sy-addfunds").val("0");
      sendData("bms:businesses:syaddfunds", {amount: val});
    }
  });

  $("#sy-remfundsbutton").click(function(){
    if (blockfunds) return;

    let val = parseInt($("#sy-remfunds").val());

    if (val > 0){
      blockfunds = true;
      $("#sy-remfunds").val("0");
      sendData("bms:businesses:syremfunds", {amount: val});
    }
  });

  $("#sy-exitbutton").click(function(){
    let val = parseInt($("#sy-markup").val());
    let name = $("#sy-shopname").val() || "Scrap-It";
    let thanks = $("#sy-thanks").val();

    symarkup = val;
    sendData("bms:businesses:scrapyards:syChangeSettings", {markup: val, name: name, thanks: thanks});
    $("#scrapmanage").hide();
  });

  $(document).on("keyup change click", "#sy-markup", function () {
		if (!$(this).data("previousValue") || $(this).data("previousValue") != $(this).val()){
      $(this).data("previousValue", $(this).val());
			renderSyMarkupPreview(parseInt($("#sy-markup").val()));
   	}
  });
  
  $("#sy-addempbutton").click(function(){
    if (!blockEmpAdd){
      let name = $("#sy-empname").val();

      if (name.length > 0){
        blockEmpAdd = true;
        sendData("bms:businesses:scrapyards:addEmployee", {name: name});
      }
    }
  });

  $(document).on("click", ".sy-empdelete", function(){
    if (!blockEmpAdd){
      var name = $(this).siblings(".sy-empentry").val();

      if (name){
        sendData("bms:businesses:scrapyards:removeEmployee", {name: name});
      }
    }
  });

  $("#ts-addfundsbutton").click(function(){
    if (blockfunds) return;
    
    let val = parseInt($("#ts-addfunds").val());

    if (val > 0){
      blockfunds = true;
      $("#ts-addfunds").val("0");
      sendData("bms:businesses:tsaddfunds", {amount: val});
    }
  });

  $("#ts-remfundsbutton").click(function(){
    if (blockfunds) return;

    let val = parseInt($("#ts-remfunds").val());

    if (val > 0){
      blockfunds = true;
      $("#ts-remfunds").val("0");
      sendData("bms:businesses:tsremfunds", {amount: val});
    }
  });

  $("#ts-exitbutton").click(function(){
    let val = parseInt($("#ts-markup").val());
    let name = $("#ts-shopname").val() || "Tattoo Shop";
    let thanks = $("#ts-thanks").val();

    tsmarkup = val;
    sendData("bms:businesses:tsChangeSettings", {markup: val, name: name, thanks: thanks});
    $("#tatmanage").hide();
  });

  $(".btnMechSave").click(function(){
    let markup = parseFloat($("#ms-markup").val());
    if (markup > 1.5){
      markup = 1.5;
    } else if(markup < 0.5){
      markup = 0.5;
    }
    let name = $("#ms-shopname").val() || "Mechanic Shop";
    let thanks = $("#ms-thanksmsg").val() || "Thanks";

    sendData("bms:businesses:mech:saveShopInfo", {markup: markup, name: name, thanks: thanks});
  });

  $(".btnMechExit").click(function(){
    $("#mechmanage").hide();

    if($("#mechUpgrades").is(":visible")){
      $("#mechUpgrades").hide();
      $("#mechUpgradeTotal").html("$0");
    }

    sendData("bms:businesses:mech:hidePanel");
  });

  $(".btnMechAddFunds").click(function(){
    let money = parseInt($("#ms-addfunds").val());

    if (money <= 0){
      $("#mechstatustext").html("<font color='red'>Enter a <font color='limegreen'>positive</font> amount.</font>");
    }else{
      sendData("bms:businesses:mech:addFunds", {cash: money});
    }
  });

  $(".btnMechRemFunds").click(function(){
    let money = parseInt($("#ms-remfunds").val());

    if (money <= 0){
      $("#mechstatustext").html("<font color='red'>Enter a <font color='limegreen'>positive</font> amount.</font>");
    }else{
      sendData("bms:businesses:mech:remFunds", {cash: money});
    }
  });

  $(".btnMechOpenUpgrades").click(function(){
    initMechUpgrades();

    $("#mechUpgrades").show();
  });

  $(".btnMechUpgradeCancel").click(function(){
    $("#mechUpgrades").hide();
    $("#mechUpgradeTotal").html("$0");
    $("#mechCustomsPurchase").prop("checked", false);
  });

  $(document).on("click", ".btnColorSelect", function(){
    $(".btnColorSelect").removeClass("active");
    $(this).addClass("active");
    
    processMechUpgrades();
    processRecycleUpgrades();
  });

  $("#mechCustomsPurchase").click(function(){
    processMechUpgrades();
  });

  $(".btnMechUpgradeAccept").click(function(){
    let blipcol = parseInt($(".btnColorSelect.active").data("colorid"));
    let customsPurchase = false;

    if ($("#mechCustomsPurchase").is(":checked")){
      customsPurchase = true;
    }

    sendData("bms:businesses:mech:saveShopUpgrades", {blcolor: blipcol, customs: customsPurchase});
  });

  $(document).on("click", ".mechEmpRemoveButton", function(){
    let name = $(this).parent().data("name");

    sendData("bms:businesses:mech:removeMechanic", name);
    $(this).parent().detach();
  });

  /* Recycle Center Management Panel */

  $(".btnRecycleSave").click(function(){
    let plasticPrice = parseInt($("#recyclePrice-plastic").val());
    let metalPrice = parseInt($("#recyclePrice-metal").val());
    let ceramPrice = parseInt($("#recyclePrice-ceram").val());
    let elecPrice = parseInt($("#recyclePrice-elec").val());
    let prices = {plastic: plasticPrice, metal: metalPrice, ceram: ceramPrice, elec: elecPrice}
    let maxPrice = 90; // Same for all items

    for (item in prices) {
      if (item == "plastic") {
        if (prices[item] < 60) {
          prices[item] = 60;
        } else if(prices[item] > maxPrice) {
          prices[item] = maxPrice;
        }
      } else if (item == "metal") {
        if (prices[item] < 55) {
          prices[item] = 55;
        } else if(prices[item] > maxPrice) {
          prices[item] = maxPrice;
        }
      } else if (item == "ceram") {
        if (prices[item] < 65) {
          prices[item] = 65;
        } else if(prices[item] > maxPrice) {
          prices[item] = maxPrice;
        }
      } else if (item == "elec") {
        if (prices[item] < 70) {
          prices[item] = 70;
        } else if(prices[item] > maxPrice) {
          prices[item] = maxPrice;
        }
      }
    }
    let name = $("#recycle-name").val() || "Recycle Center";
    let thanks = $("#recycle-thanksmsg").val() || "Thanks";

    sendData("bms:businesses:recycle:saveCenterInfo", {prices: prices, name: name, thanks: thanks});
  });

  $(".btnRecycleExit").click(function(){
    $("#recyclemanage").hide();

    if($("#recycleUpgrades").is(":visible")){
      $("#recycleUpgrades").hide();
      $("#recycleUpgradeTotal").html("$0");
    }

    sendData("bms:businesses:recycle:hidePanel");
  });

  $(".btnRecycleAddFunds").click(function(){
    let money = parseInt($("#recycle-addfunds").val());

    if (money <= 0){
      $("#recyclestatustext").html("<font color='red'>Enter a <font color='limegreen'>positive</font> amount.</font>");
    }else{
      sendData("bms:businesses:recycle:addFunds", {cash: money});
    }
  });

  $(".btnRecycleRemFunds").click(function(){
    let money = parseInt($("#recycle-remfunds").val());

    if (money <= 0){
      $("#recyclestatustext").html("<font color='red'>Enter a <font color='limegreen'>positive</font> amount.</font>");
    }else{
      sendData("bms:businesses:recycle:remFunds", {cash: money});
    }
  });

  $(".btnRecycleOpenUpgrades").click(function(){
    initRecycleUpgrades();

    $("#recycleUpgrades").show();
  });

  $(".btnRecycleUpgradeCancel").click(function(){
    $("#recycleUpgrades").hide();
    $("#recycleUpgradeTotal").html("$0");
    $("#autoRecyclePurchase").prop("checked", false);
  });

  $(".btnRecycleUpgradeAccept").click(function(){
    let blipcol = parseInt($(".btnColorSelect.active").data("colorid"));

    sendData("bms:businesses:recycle:saveCenterUpgrades", {blcolor: blipcol});
  });

  $(".btnRecycleSell").click(function(){
    sendData("bms:businesses:recycle:sellStock", {sell: true});
  });
});

function sendData(name, data, cb){
    $.post("http://businesses/" + name, JSON.stringify(data), function(d) {
      // NUI callbacks not working?  awesome.  So more useless roundabout function calls.    
      //if (cb){
          console.log("cb hit");
          cb(d);
        //}
    });
}

/*function sendDataDirect(res, name, data){
  $.post("http://" + res + "/" + name, JSON.stringify(data), function(datab) {
      console.log(datab);
  });
}*/

function playSound(sound){
    sendData("playsound", {name: sound});
}

function processDeliveryList(plist){
  if (plist){
    $("#deliverylist").children().detach();
    
    var fmtstr = "";
    var players = plist.split(";");
    
    for (var i = 0; i < players.length; i++){
      fmtstr = fmtstr + '<div id="litem"><font class="listresult" data-item="' + players[i] + '">' + players[i] + '<font class="listdelbutton" data-sel="' + players[i] + '">X</font></font></div>';
    }

    //fmtstr.slice(0, -5); // remove trailing <br/>

    $("#deliverylist").append(fmtstr);
  }
}

function blink(selector){
  $(selector).fadeOut('slow', function(){
      $(this).fadeIn('slow', function(){
          blink(this);
      });
  });
}

function renderMarkupPreview(markup, takemod){
  let rstr = "";

  for (let i = 0; i < itemprev.length; i++){
    let item = itemprev[i];
    
    //rstr += `${item.name}: ${Math.floor(item.profit * (markup / 100))}, <br/>`;
    rstr += `${item.name}: (Base) $${Math.floor(item.profit)}, (Take) $${Math.floor((item.profit * (markup / 100)) * takemod)}<br/>`;
  }

  $(".markupInfo").html(rstr);
}

function renderSyMarkupPreview(markup){
  let rstr = "";

  for (let i = 0; i < itemprev.length; i++){
    let item = itemprev[i];
    
    rstr += `${item.name}: ${Math.floor(item.profit * (markup / 100))}, <br/>`;
  }

  rstr = rstr.substring(0, rstr.length - 7);
  $(".sy-markupInfo").html(rstr);
}

function renderEmployees(list){
  $("#sy-employeelist").children().detach();

  let estr = "";
  
  for (let i = 0; i < list.length; i++){
    let emp = list[i];
    estr += `<span class="sy-empentry">${emp}<span class="sy-empdelete">X</span></span><br/>`;
  }

  estr.slice(0, -5);
  $("#sy-employeelist").append(estr);
}

function initMechUpgrades(){
  $(".buttonGroupAdBlipSelector").children().detach();

  let bkeys = Object.keys(blipcolors);
  let activeCol = 0;

  if (mechPurchasedUpgrades && mechPurchasedUpgrades.blcolor){
    activeCol = mechPurchasedUpgrades.blcolor;
  }

  for (let i = 0; i < bkeys.length; i++){
    let o = blipcolors[bkeys[i]];

    if (bkeys[i] == activeCol){
      $(".buttonGroupAdBlipSelector").append(`<button type="button" class="btn btn-secondary btnColorSelect active" data-colorid="${bkeys[i]}" style="background-color: ${o.hex}"><img class="blipimage" src="images/sizer.png"></button>`);
    }
    else{
      $(".buttonGroupAdBlipSelector").append(`<button type="button" class="btn btn-secondary btnColorSelect" data-colorid="${bkeys[i]}" style="background-color: ${o.hex}"><img class="blipimage" src="images/sizer.png"></button>`);
    }
  }

  if (mechPurchasedUpgrades && mechPurchasedUpgrades.customs){
    $("#mechCustomsPurchase").prop("checked", true);
  } else{
    $("#mechCustomsPurchase").prop("checked", false);
  }
}

function processMechUpgrades(){
  let blipcol = parseInt($(".btnColorSelect.active").data("colorid"));
  let totalCost = 0;

  if (mechPurchasedUpgrades && mechPurchasedUpgrades.blcolor && blipcol && mechPurchasedUpgrades.blcolor != blipcol){
    totalCost = totalCost + upgradePrices.blipcolor;
  }

  if (mechPurchasedUpgrades && !mechPurchasedUpgrades.customs && $("#mechCustomsPurchase").is(":checked")) {
    totalCost = totalCost + upgradePrices.customs;
  }

  $("#mechUpgradeTotal").html("$" + totalCost);
}

function initRecycleUpgrades(){
  $(".buttonGroupAdBlipSelector").children().detach();

  let bkeys = Object.keys(blipcolors);
  let activeCol = 0;

  if (recyclePurchasedUpgrades && recyclePurchasedUpgrades.blcolor){
    activeCol = recyclePurchasedUpgrades.blcolor;
  }

  for (let i = 0; i < bkeys.length; i++){
    let o = blipcolors[bkeys[i]];

    if (bkeys[i] == activeCol){
      $(".buttonGroupAdBlipSelector").append(`<button type="button" class="btn btn-secondary btnColorSelect active" data-colorid="${bkeys[i]}" style="background-color: ${o.hex}"><img class="blipimage" src="images/sizer.png"></button>`);
    }
    else{
      $(".buttonGroupAdBlipSelector").append(`<button type="button" class="btn btn-secondary btnColorSelect" data-colorid="${bkeys[i]}" style="background-color: ${o.hex}"><img class="blipimage" src="images/sizer.png"></button>`);
    }
  }
}

function processRecycleUpgrades(){
  let blipcol = parseInt($(".btnColorSelect.active").data("colorid"));
  let totalCost = 0;

  if (recyclePurchasedUpgrades && recyclePurchasedUpgrades.blcolor && blipcol && recyclePurchasedUpgrades.blcolor != blipcol){
    totalCost = totalCost + upgradePrices.blipcolor;
  }

  $("#recycleUpgradeTotal").html("$" + totalCost);
}

function processMechEmployees(emps){
  $(".mechRoster").children().detach();

  if (emps && emps.length > 0){
    for (let i = 0; i < emps.length; i++){
      let str = `
        <div data-name="${emps[i]}">
          <span>${emps[i]}</span><button id="testMechStuff" class="btn btn-danger float-right mechEmpRemoveButton">X</button>
        </div>`;

      $(".mechRoster").append(str);
    }
  }
}
