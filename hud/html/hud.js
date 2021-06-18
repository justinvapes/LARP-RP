var checkEngCont;
var lowFuelCont;
var seatbeltCont;
var hungerBar;
var thirstBar;
var vitalsBar;
var nitrousbar;
var nitroustext;

$(function(){
  checkEngCont = $("#checkEngineContainer");
  lowFuelCont = $("#lowFuelContainer");
  seatbeltCont = $("#seatbeltContainer");
  hungerBar = $("#hungerbar");
  thirstBar = $("#thirstbar");
  vitalsBar = $("#vitalbackground");
  nitrousLevel = $("#nitrousLevel");
  nitrousbar = $("#nitrousbar");
  nitroustext = $(".nitroustext")

  window.addEventListener("message", function(event) {
    var item = event.data;

    if (item.showCheckEngine)
    {
      checkEngCont.show();
    }
    else if (item.hideCheckEngine)
    {
      checkEngCont.hide();
    }
    else if (item.showLowFuel)
    {
      lowFuelCont.show();
    }
    else if (item.hideLowFuel)
    {
      lowFuelCont.hide();
    }
    else if (item.showSeatbelt)
    {
      seatbeltCont.show();
    }
    else if (item.hideSeatbelt)
    {
      seatbeltCont.hide();
    }
    else if (item.updateNitrousLevel) {
      var hasNitrous = item.hasNitrous;
      var level = item.level;

      nitrousbar.hide();
      nitroustext.hide();

      if (hasNitrous) {
        if (level > 75) {
          nitrousbar.show();
          nitroustext.show();
          nitrousbar.progressbar("value", 100);
        } else if (level > 50) {
          nitrousbar.show();
          nitroustext.show();
          nitrousbar.progressbar("value", 75);
        } else if (level > 25) {
          nitrousbar.show();
          nitroustext.show();
          nitrousbar.progressbar("value", 50);
        } else if (level > 10) {
          nitrousbar.show();
          nitroustext.show();
          nitrousbar.progressbar("value", 25);
        } else if (level > 0) {
          nitrousbar.show();
          nitroustext.show();
          nitrousbar.progressbar("value", 10);
        } else {
          nitrousbar.show();
          nitroustext.show();
          nitrousbar.progressbar("value", 0);
        }
      }
    }
    else if (item.showVitals){
      hungerBar.show();
      thirstBar.show();
      vitalsBar.show();
    }
    else if (item.hideVitals){
      hungerBar.hide();
      thirstBar.hide();
      vitalsBar.hide();
    }
    else if (item.updateVitals){
      //console.log("updating vitals to " + item.hungerval + " " + item.thirstval);
      hungerBar.progressbar("value", item.hungerval);
      thirstBar.progressbar("value", item.thirstval);
    }
    else if (item.updateHudPos){
      updateHudPos(item.data);
    }
  });
});

function updateHudPos(minimap) {
  let wHeight = $(window).height();
  let wWidth = $(window).width();
	let width = minimap.width;
	let x = minimap.left_x;
  let y = minimap.bottom_y;

  let barGap = Math.round(width * wWidth * 0.00925925);
  let barWidth = Math.round((width * wWidth));
	let newWidth = Math.round((barWidth - barGap - 1) / 2);
  let newHeight = minimap.height * wHeight * 0.0475;
  let newBottom = wHeight - (y * wHeight) - newHeight;
  let newLeft = Math.round(x * wWidth);

  hungerBar.css("width", newWidth).css("bottom", newBottom).css("height", newHeight).css("left", newLeft);
  thirstBar.css("width", newWidth).css("bottom", newBottom).css("height", newHeight).css("left", newLeft + newWidth + barGap);
  // Left to right padding of 1, top to bottom padding of 3
  vitalsBar.css("width", barWidth + 2).css("bottom", newBottom - 3).css("height", newHeight + 6).css("left", newLeft - 1);

  let newRight = Math.round(minimap.right_x * wWidth + 10);
  let newTop = Math.round(wHeight - ((minimap.top_y + (minimap.height * 0.08)) * wHeight));

  // Check engine on top, then fuel
  checkEngCont.css("bottom", newTop).css("left", newRight);
  lowFuelCont.css("bottom", newTop - 45).css("left", newRight);

  nitrousbar.css("bottom", newBottom + 30).css("left", newRight);
  nitroustext.css("bottom", newBottom + 30).css("left", newRight);
}
