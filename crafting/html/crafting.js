let container;
let skcontainer;
let wscontainer;
let pinventory = [];
let wscrafts = [];
let cancraft = false;
let money = 0;
let blockCycleChange = false;

$(function(){
    container = $("#masterContainer");
    skcontainer = $(".skillContainer");
    wscontainer = $("#wsContainer");

    window.addEventListener("message", function(event){
      var item = event.data;

      if (item.showSkills){
        skcontainer.fadeIn();
      }
      else if (item.hideSkills){
        skcontainer.fadeOut();
      }
      else if (item.renderSkills){
        renderSkills(item.skills, item.open || true);
      }
      else if (item.skillChanged){
        changeSkill(item.skid, item.skval);
      }
      else if (item.setinventory){
        pinventory = item.inventory;
        wscrafts = item.wscrafts;
        money = item.money;

        if (item.openshop){
          cancraft = false;
          resetWsItems();
          $(".ws-materials").children().remove();
          $(".ws-craftbutton").removeClass("btn-success").removeClass("btn-dark").addClass("btn-dark");
          $(".ws-craftbutton").html("Select an item");
          wscontainer.show();
        }
      }
      else if (item.closeshop){
        wscontainer.hide();
      }
      else if (item.loadcrafts){
        let cont = $(".craftitems");
        let keys = Object.keys(item.wscrafts);
        let stationType = item.stationType;

        cont.children().remove();
        keys.sort();

        for (let i = 0; i < keys.length; i++){
          let craft = item.wscrafts[keys[i]];

          if (craft.stationType == stationType){
            cont.append(`<div class="craftitem p-1 w-100" data-cid="${keys[i]}">${craft.dispname || craft.name}</div>`);
          }
        }
      }
    });

    $(".ws-exitbutton").click(function(){
      wscontainer.hide();
      sendData("bms:crafting:weaponsmith:closews");
    });

    $(document).on("click", ".craftitem", function(){
      let craft = wscrafts[parseInt($(this).data("cid"))];

      $(".cyclesText").html("");
      resetWsItems();
      $(this).addClass("selected");
      processWsItem(craft, 1);
    });

    $(".ws-craftbutton").click(function(){
      if (cancraft){
        let itemid = getItemId();
        let craftCycles = parseInt($("#inputCraftQty").val());

        sendData("bms:crafting:weaponsmith:createitem", {itemid: itemid, craftCycles: craftCycles});
      }
    });

    $(document).on("keyup change click", "#inputCraftQty", function(){
      if (blockCycleChange) return;

      blockCycleChange = true;
      let val = parseInt($(this).val());
      let selCraft = $(".craftitem.selected");

      if (selCraft.length == 0) return;

      let craft = wscrafts[parseInt(selCraft.data("cid"))];

      console.log(JSON.stringify(craft));

      if (craft === undefined) return;
      
      if (val > 10){
        $(this).val("10");
      }
      else if (val < 1){
        $(this).val("1");
      }
      
      processWsItem(craft, val || 1);
    });
});

function stripImageName(name){
  let img = name.replace(/\(|\)/g, "_");
  
  return img.replace(/\s+/g, "_").toLowerCase() + ".png";
}

function processWsItem(craft, cycles){
  let name = craft.name;
  let wsccosts = [];
  let wsprice = 0;
  let wsctime = 0;
  let failcraft = false;

  $(".ws-materials").children().remove();
  
  for (var i = 0; i < wscrafts.length; i++){
    var ws = wscrafts[i];

    if (ws.name == name){
      wsccosts = ws.costs;
      wsprice = ws.price;
      wsctime = ws.ctime;
      break;
    }
  }

  for (var i = 0; i < pinventory.length; i++){
    var pitem = pinventory[i];

    for (var c = 0; c < wsccosts.length; c++){
      let cost = wsccosts[c];
      let costval = cost.c;

      if (cycles){
        costval = costval * cycles;
      }
      else{
        costval = cost.c;
      }

      if (pitem.name == cost.n){
        if (pitem.quantity >= costval){
          if (costval > 0){
            $(".ws-materials").append(`
              <div class="row">
                <div class="col-3">
                  <img src="nui://inventory/html/dinvicons/${stripImageName(cost.n)}" style="width: 48px; height: 48px">
                </div>
                <div class="col-9 mt-2 wsmat-desc">
                  ${cost.n} (<span class="wsmat-success">${pitem.quantity}</span> of ${costval})
                </div>
              </div>
            `);
          }
          
          wsccosts[c].failcraft = false;
        }
        else{
          $(".ws-materials").append(`
            <div class="row">
              <div class="col-3">
                <img src="nui://inventory/html/dinvicons/${stripImageName(cost.n)}" style="width: 48px; height: 48px">
              </div>
              <div class="col-9 mt-2 wsmat-desc">
                ${cost.n} (<span class="wsmat-error">${pitem.quantity}</span> of ${costval})
              </div>
            </div>
          `);

          failcraft = true;
          wsccosts[c].failcraft = true;
        }

        wsccosts[c].added = true;
      }
    }
  }

  for (var i = 0; i < wsccosts.length; i++){
    let cost = wsccosts[i];
    let costval = cost.c;

    if (cycles){
      costval = costval * cycles;
    }
    else{
      costval = cost.c;
    }

    if (!cost.added){
      $(".ws-materials").append(`
        <div class="row">
          <div class="col-3">
            <img src="nui://inventory/html/dinvicons/${stripImageName(cost.n)}" style="width: 48px; height: 48px">
          </div>
          <div class="col-9 mt-2 wsmat-desc">
            ${cost.n} (<span class="wsmat-error">${pitem.quantity}</span> of ${costval})
          </div>
        </div>
      `);

      failcraft = true;
    }
  }

  if (cycles > 1){
    wsctime = wsctime * cycles;
    wsprice = wsprice * cycles;
  }

  let cycleMax = 10;

  if (craft.weapon || !craft.skipserial){
    cycleMax = 1;
  }

  $(".ws-materials").append(`
    <div class="ws-price mt-4">
      Price: <span class="color: lawngreen;">$${wsprice}</span>
    </div>
    <div class="mt-2 craftTimeText" style="color: skyblue">
      Craft time: ${wsctime} minute(s).
    </div>
    <div class="mt-2">
      <label for="inputCraftQty" class="craftQtyLabel">
        Crafting cycles
        <input id="inputCraftQty" type="number" value="${cycles || 1}" min="1" max="${cycleMax}">
      </label>
    </div>
    <small class="mt-1 cyclesText"></small>
  `);

  if (money >= wsprice){
    if (!failcraft){
      cancraft = true;
      $(".ws-craftbutton").removeClass("btn-success").removeClass("btn-dark").addClass("btn-success");
      $(".ws-craftbutton").html("CREATE");
    }
    else{
      cancraft = false;
      $(".ws-craftbutton").removeClass("btn-success").removeClass("btn-dark").addClass("btn-dark");
      $(".ws-craftbutton").html("Not enough materials to craft.");
    } 
  }
  else{
    cancraft = false;
    $(".ws-craftbutton").removeClass("btn-success").removeClass("btn-dark").addClass("btn-dark");
    $(".ws-craftbutton").html("$$ Not enough money to craft $$");
  }

  if (!craft.weapon && craft.skipserial){
    $(".cyclesText").html(`This will create ${(craft.quantity || 1) * cycles} ${craft.name}(s).`);
    $(".craftTimeText").html(`Craft time: ${cycles * craft.ctime} minute(s).`);
  }
  else{
    $(".craftTimeText").html(`Craft time: ${craft.ctime} minute(s).`);
    $("#inputCraftQty").val("1");
    $(".cyclesText").html(`You can only craft one of these items at a time.`);
  }

  blockCycleChange = false;
}

function resetWsItems(){
  $(".craftitem").removeClass("selected");  
  $("#reqresources").html("");
}

function getItemId(){  
  return parseInt($(".craftitem.selected").data("cid")) + 1 || 0;
}

function sendData(name, data){
    $.post("http://crafting/" + name, JSON.stringify(data), function(datab) {
        console.log(datab);
    });
}

function renderSkills(skills, open){
  $(".skills").children().remove();
  
  for (let i = 0; i < skills.length; i++){
    let skill = skills[i];

    $(".skills").append(`<div class="skill" data-skid="${skill.id}">
      <div class="row">
        <div class="col-12">
          <div class="sk-title">${skill.name}</div>
          <div class="sk-value">${skill.val.toFixed(2)}</div>
        </div>
      </div>
      <div class="row">
        <div class="col-12">
          <div class="progress position-relative">
            <div class="progress-bar bg-info progress-bar-striped skillprogress" role="progressbar" style="width: ${skill.val}%" aria-valuenow="${skill.val}" aria-valuemin="0" aria-valuemax="100"></div>
            <span class="justify-content-center d-flex position-absolute w-100 proglabel">${skill.val.toFixed(3)}%</span>
          </div>
        </div>
      </div>
    </div>`);
  }

  if (open){
    skcontainer.fadeIn();
  }
}

function changeSkill(skid, skval){
  let skill = $(".skill[data-id='" + skid + "']");

  if (skill.length > 0){
    skill.find(".sk-value").html(skval);
    skill.find(".skillprogress").attr("aria-valuenow", skval);
    skill.find(".skillprogress").css("width", skval + "%");
    skill.find(".proglabel").html(skval + "%");
  }
}