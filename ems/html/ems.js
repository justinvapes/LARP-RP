let injuries = [];
let displaymode = false;

$(function(){

  window.addEventListener("message", function(event){
    var data = event.data;

    if (data.showInjured){
      $("#injured_overlay").show();
      $("#injured_text").html(data.injury + "/100hp");
      $("#injured_overlay").pulsate({
        color: '#FF0000',
        reach: 10,
        speed: 500,
        glow: true,
        repeat: true
      });
    }
    else if (data.hideInjured){
      $("#injured_overlay").hide();
      $("#injured_text").html("");
    }
    else if (data.sawprogress){
      $("#sawprogress").show();
      $("#sawprogress").progressbar("option", "max", data.sawmaxtime);
      $("#sawprogress").progressbar("option", "value", data.value);
    }
    else if (data.hidesawprogress){
      $("#sawprogress").hide();
    }
    else if (data.showInjurySystem){
      displaymode = data.displaymode;

      let selpart = data.selectedpart;
      let damagestr = data.detdamage;

      if (damagestr != ""){
        $(".injuryType").val(damagestr);
      }

      $(".injuryType").attr("readonly", displaymode);
      
      if (displaymode){
        injuries = data.injuries;
        $("#injuryMainHeader").html("Injuries that you see");
        $(".btnInjuryAccept").hide();
        $(".labelStatus").show();
        renderInjuries();
        renderVisualInjuries();
      }
      else{
        $("#injuryMainHeader").html("Select any injuries you have sustained");
        $(".btnInjuryAccept").show();
        $(".labelStatus").hide();
      }
      
      if (selpart){
        injuries.push(selpart);
        renderInjuries();
        selectBodyPart(selpart);
      }

      $(".injuryContainer").fadeIn();
    }
    else if (data.hideInjurySystem){
      if (displaymode){
        closeAndResetInjuryWindow();
      }
    }
    /*else if (data.showXray){
      $(".xrspacer").show();
      $("#xrinjurylist").children().detach();
    }*/
  });

  /*window.onkeyup = function(e){ // testing
		if (displaymode && e.keyCode == 27){
      $(".injuryContainer").fadeOut();
      $(".injuriesList").html("");
      $(".injuryType").val("");
      sendData("bms:ems:closeWindows", "");
      $(".injuryTableCell").removeClass("selected");

      $(".injuryTableCell").each(function(){
        let $img = $(this).find("img");
        let base = $img.data("base");

        if ($img.length > 0){
          let src = $img.attr("src");

          if (src.length > 0){
            $img.attr("src", base);
          }
        }
      });
      displaymode = false;
      clearHoverImages();
      resetSelectedInjuries();
		}
	}*/

  $(document).on("click", ".injuryTableCell", function(){
    if (!displaymode){
      let injid = $(this).data("id");

      if (injid.length > 0){
        let img = $(this).find("img");
        let src = img.attr("src");
        
        selectImage(img, src);
      }
    }
  });

  $(document).on("mouseenter", ".injuryTableCell", function(){
    if (!displaymode){
      let img = $(this).find("img");
      
      if (img.length > 0 && !img.hasClass("selected")){
        let src = img.attr("src");
        hoverImage(img, src);
      }
    }
  });

  $(document).on("mouseleave", ".injuryTableCell", function(){
    if (!displaymode){
      let img = $(this).find("img");

      if (img.length > 0 /*&& !img.hasClass("selected")*/){
        clearHoverImages();
      }
    }
  });

  $(document).on("click", ".btnInjuryAccept", function(){
    $(".injuryContainer").fadeOut();
    $(".injuryTableCell").removeClass("selected");

    /*$(".injuryTableCell").each(function(){
      let $img = $(this).find("img");
      let base = $img.data("base");

      if ($img.length > 0){
        let src = $img.attr("src");

        if (src.length > 0){
          $img.attr("src", base);
        }
      }
    });*/

    sendData("bms:ems:setInjuries", {injuries: injuries, injurytype: $(".injuryType").val()});
    injuries = [];
    $(".injuriesList").html("");
    $(".injuryType").val("");
    clearHoverImages();
    resetSelectedInjuries();
  });
});

function selectImage($element, imgpath){
  let path = imgpath;
  
  if (path.includes("hm_") || $element.hasClass("selected")){
    path = path.replace("hm_", "");
    $element.removeClass("selected");
    removeInjuryFromList($element.parent());
  }
  else{
    path = path.replace("injurypic_sel_", "injurypic_hm_");
    $element.removeClass("selected").addClass("selected");
    addInjuryToList($element.parent());
  }

  $element.attr("src", path);
}

function hoverImage($element, imgpath){
  let path = imgpath;

  if (!$element.hasClass("selected")){
    path = path.replace("injurypic_", "injurypic_sel_");
    $element.attr("src", path);
  }
}

function clearHoverImages(){
  $(".injuryTableCell").each(function(){
    let img = $(this).find("img");

    if (img.length > 0){
      let src = img.attr("src");

      if (src.length > 0){
        let path = src.replace("injurypic_sel_", "injurypic_");
        img.attr("src", path);
      }
    }
  });
}

function renderInjuries(){
  $(".injuriesList").html("");

  let injstr = "";

  for (let i = 0; i < injuries.length; i++){
    let inj = injuries[i];
    
    injstr += inj + ", ";
  }

  injstr = injstr.slice(0, -2);
  $(".injuriesList").append(injstr);
}

function addInjuryToList($ele){
  let exists = false;
  let injury = $ele.data("id").replace("_", " ");
  
  if (injury.length > 0){
    for (let i = 0; i < injuries.length; i++){
      let inj = injuries[i];

      if (inj == injury){
        exists = true;
        break;
      }
    }
  }

  if (!exists){
    injuries.push(injury);
    renderInjuries();
  }
}

function removeInjuryFromList($ele){
  let changed = false;
  let injury = $ele.data("id").replace("_", " ");
  
  if (injury.length > 0){
    for (let i = 0; i < injuries.length; i++){
      let inj = injuries[i];

      if (inj == injury){
        injuries.splice(i, 1);
        changed = true;
        break;
      }
    }
  }

  if (changed){
    renderInjuries();
  }
}

function resetSelectedInjuries(){
  $(".injuryTableCell").each(function(){
    let base = $(this).data("base");
    let img = $(this).find("img");
    let src = img.attr("src");
    let posslash = src.lastIndexOf("/");

    base = src.substring(0, posslash + 1) + base;
    img.attr("src", base);
  });
}

function renderVisualInjuries(){
  for (let i = 0; i < injuries.length; i++){
    let injury = injuries[i].replace(" ", "_");
    let injele = $(".injuryTableCell[data-id='" + injury + "']");
    
    if (injele.length > 0){
      let img = injele.find("img");
      let src = img.attr("src");

      injele.removeClass("selected").addClass("selected");
      src = src.replace("injurypic_", "injurypic_hm_");
      console.log("renderVisualInjuries >> " + src);
      img.attr("src", src);
    }    
  }
}

function closeAndResetInjuryWindow(){
  $(".injuryContainer").fadeOut();
  $(".injuriesList").html("");
  $(".injuryType").val("");
  sendData("bms:ems:closeWindows", "");
  $(".injuryTableCell").removeClass("selected");

  /*$(".injuryTableCell").each(function(){
    let $img = $(this).find("img");
    let base = $img.data("base");

    if ($img.length > 0){
      let src = $img.attr("src");

      if (src.length > 0){
        $img.attr("src", base);
      }
    }
  });*/

  displaymode = false;
  clearHoverImages();
  resetSelectedInjuries();
}

function selectBodyPart(partname){
  partname = partname.replace(" ", "_");
  
  let element = $(".injuryTableCell[data-id='" + partname + "']");

  if (element && element.length > 0){
    let img = element.find("img");
    let src = img.attr("src");

    src = src.replace("injurypic_", "injurypic_hm_");
    console.log("selectBodyPart >> " + src);
    img.attr("src", src);
  }
}

/*function hasSelection(){
  return $("#dtcHead").attr("class") == "dtcSelected" || $("#dtcShoulderR").attr("class") == "dtcSelected" || $("#dtcShoulderL").attr("class") == "dtcSelected" ||
    $("#dtcArmR").attr("class") == "dtcSelected" || $("#dtcArmL").attr("class") == "dtcSelected" || $("#dtcHandR").attr("class") == "dtcSelected" || $("#dtcHandL").attr("class") == "dtcSelected" ||
    $("#dtcLegR").attr("class") == "dtcSelected" || $("#dtcLegL").attr("class") == "dtcSelected" || $("#dtcFootR").attr("class") == "dtcSelected" || $("#dtcFootL").attr("class") == "dtcSelected"
}*/

function sendData(name, data) {
	$.post("http://ems/" + name, JSON.stringify(data), function(datab) {
    	//console.log(datab);
	});
}