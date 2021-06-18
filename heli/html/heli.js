$(function(){
  window.addEventListener("message", function(event){
    var data = event.data;

    if (data.toggleHelicamPanels){
      data.toggle ? $(".heliTargContainer").show() : $(".heliTargContainer").hide();
    }
    if (data.updateVehicleInfo){
      if (data.model && data.plate){
        updateVehicleInfoDisplay(data.speed, data.model, data.plate);
      }
    }
  });
});

function updateVehicleInfoDisplay(speed, model, plate){
  if (speed !== undefined){
    if (!$(".vinfoSpeedDisp").is(":visible")){
      $(".vinfoSpeedDisp").show();
    }
    
    $(".vinfoSpeedDisp").html(speed);
  }
  else{
    if ($(".vinfoSpeedDisp").is(":visible")){
      $(".vinfoSpeedDisp").hide();
    }
  }
  
  $(".vinfoModelDisp").html(model);
  $(".vinfoPlateDisp").html(plate);
}