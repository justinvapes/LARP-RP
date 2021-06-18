var container;
var buttoncontainer;
var resourcename = "boats";
var blockSwitch = false;
var buyVehicle = false;
var canBuyVehicle = true;
var boatMode = 1;
var sellBoat = false;
var canSellBoat = true;

$(function(){
	container = $("#masterContainer");
	buttoncontainer = $("#buttonContainer");
		
	window.addEventListener("message", function(event){
		var item = event.data;
		
		if (item.showVehiclesList)
		{
			if (item.title)
      {
				$(".vehoptiontitle").html(item.title);
      }

      if (item.showBuy)
      {
        $("#buyVeh").show();
        $("#spawnVeh").hide();
        $("#sellVeh").hide();
				boatMode = 1;
      }
      else if (item.showSpawn)
      {
        $("#spawnVeh").show();
        $("#buyVeh").hide();
        $("#sellVeh").show();
        boatMode = 2;
      }

			container.show();
			buttoncontainer.show();
			playSound("YES");
      canBuyVehicle = true;
      canSellBoat = true;
		}
		else if (item.hideVehiclesList)
		{
			container.hide();
			buttoncontainer.hide();
			playSound("NO");
		}
		else if (item.addVehItems)
		{
			addVehItems(item.items);
		}
		else if (item.unblockSwitch)
		{
			blockSwitch = false;
		}
		else if (item.resetBuy)
		{
			resetBuy();
		}
	});
	
	$(document).on("click", ".vehoption", function() {
		if (!blockSwitch)
		{
			var lvehname = $(this).data("vehname");
      var lvehplate = $(this).data("vehplate");

      resetBuy();
      resetSell();
			blockSwitch = true;
			clearActive();
      $(this).attr("class", "vehoption active");
      if (boatMode == 2) {
        var lboatprice = $(this).data("vehprice");
        $("#sellVeh").html(`Sell Boat [$${lboatprice}]`);
      }
			
			sendData("setVehiclePreview", {mode: boatMode, vehname: lvehname, vehplate: lvehplate});
		}
	});
	
	$("#spawnVeh").click(function(){
		var ele = getActiveVehicle();
		
		if (ele)
		{
			var lvehname = ele.data("vehname");
			var lvehplate = ele.data("vehplate");

			sendData("spawnBoat", {vehname: lvehname, vehplate: lvehplate});

			playSound("SELECT");

			container.hide();
			buttoncontainer.hide();
			sendData("menuClosed", "");
		}
		else
		{
			sendData("debug", "no element");
		}
	});
	
	$("#buyVeh").click(function(){
		if (!buyVehicle)
		{
			$(this).html("[Click again to Confirm]");
			buyVehicle = true;
		}
		else
		{
			if (canBuyVehicle)
			{
				canBuyVehicle = false;
				sendData("buyBoat", "");

				playSound("SELECT");

				container.hide();
				buttoncontainer.hide();
				sendData("menuClosed", "");
				resetBuy();
				buyVehicle = false;
			}
		}
  });
  
  $("#sellVeh").click(function(){
		if (!sellBoat)
		{
			//$("#sellVeh").html("[Click again to Confirm]");
			$(this).removeClass("warning").addClass("warning");
			$(this).html("[Click again to Confirm]");
			sellBoat = true;
		}
		else
		{
			if (canSellBoat)
			{
				canSellBoat = false;
				sendData("sellPersonalBoat", "");
				playSound("SELECT");
				container.hide();
				buttoncontainer.hide();
				sendData("menuClosed", "");
				resetSell();
				sellBoat = false;
			}
		}
	});
	
	$(document).on("click", ".vehContainerExitButton", function(){
		playSound("NO");
		container.hide();
    buttoncontainer.hide();
    resetSell();
		sendData("menuClosed", "");
	});
	
	$(document).on("mouseenter", ".vehContainerExitButton", function(){
		if ($(this).attr("class") != "vehContainerExitButton selected")
		{
			$(this).attr("class", "vehContainerExitButton selected");
		}
	});
	
	$(document).on("mouseleave", ".vehContainerExitButton", function(){
		if ($(this).attr("class") != "vehContainerExitButton")
		{
			$(this).attr("class", "vehContainerExitButton");
		}
	});
	
	$(document).on("mouseenter", ".vehoption", function(){
		if ($(this).attr("class") != "vehoption active")
		{
			if ($(this).attr("class") != "vehoption selected")
			{
				$(this).attr("class", "vehoption selected");
			}
		}
	});
	
	$(document).on("mouseleave", ".vehoption", function(){
		if ($(this).attr("class") != "vehoption active")
		{
			if ($(this).attr("class") != "vehoption")
			{
				$(this).attr("class", "vehoption");
			}
		}
	});
});

function sendData(name, data)
{
    $.post("http://" + resourcename + "/" + name, JSON.stringify(data), function(datab) {
        console.log(datab);
    });
}

function playSound(sound) {
    sendData("playsound", {name: sound});
}

function clearVehicles()
{
	$("#vehContainer").children().detach();
}

function resetBuy()
{
	$("#buyVeh").html("Purchase Boat");
	buyVehicle = false;
}

function resetSell() {
	$("#sellVeh").removeClass("warning");
	$("#sellVeh").html("Sell Boat");
	sellBoat = false;
}

function clearActive()
{
	$(".vehoption").each(function(){
		if ($(this).attr("class") == "vehoption active")
		{
			$(this).attr("class", "vehoption");
		}
	});
}

function addVehItems(items)
{
	clearVehicles();
	$("#vehContainer").append(items);
	$(".vehoption").eq(0).attr("class", "vehoption active");
}

function getActiveVehicle()
{
	//return $(".vehoption").eq(0).attr("class", "vehoption active");
	return $(".vehoption.active");
}
