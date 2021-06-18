let masterContainer;
let inventoryAnchor;
let containerAnchor;
let imageBase = "nui://inventory/html/dinvicons/";
let sorter = {items: []}; // sorter.items format: {name, pid (panel id), imgsrc (image source, for drag item view)}
let imageNames = [];
let showLabels = false;
let lastType = 0;
let inventory = [];
let playerWeapons = [];
let weaponNames = [];
let containerWeaponNames = [];
let container = [];
let compHashes = [];
/* wscomphash reference */
/*local wscomphashes = {
  [1] = {name = "Supressor", hashes = {"COMPONENT_AT_PI_SUPP", "COMPONENT_AT_PI_SUPP_02", "COMPONENT_AT_AR_SUPP", "COMPONENT_AT_SR_SUPP", "COMPONENT_AT_AR_SUPP_02"}},
  [2] = {name = "Extended Magazine", hashes = {"COMPONENT_PISTOL_CLIP_02", "COMPONENT_COMBATPISTOL_CLIP_02", "COMPONENT_APPISTOL_CLIP_02", 
    "COMPONENT_PISTOL50_CLIP_02", "COMPONENT_MICROSMG_CLIP_02", "COMPONENT_SMG_CLIP_02", "COMPONENT_ASSAULTSMG_CLIP_02", "COMPONENT_ASSAULTRIFLE_CLIP_02",
    "COMPONENT_CARBINERIFLE_CLIP_02", "COMPONENT_ADVANCEDRIFLE_CLIP_02", "COMPONENT_MG_CLIP_02", "COMPONENT_COMBATMG_CLIP_02", "COMPONENT_ASSAULTSHOTGUN_CLIP_02",
    "COMPONENT_SNSPISTOL_CLIP_02", "COMPONENT_MINISMG_CLIP_02", "COMPONENT_HEAVYPISTOL_CLIP_02", "COMPONENT_SPECIALCARBINE_CLIP_02",
    "COMPONENT_BULLPUPRIFLE_CLIP_02", "COMPONENT_BULLPUPRIFLE_MK2_CLIP_02", "COMPONENT_MARKSMANRIFLE_MK2_CLIP_02", "COMPONENT_SNSPISTOL_MK2_CLIP_02",
    "COMPONENT_SPECIALCARBINE_MK2_CLIP_02", "COMPONENT_ASSAULTRIFLE_MK2_CLIP_02", "COMPONENT_CARBINERIFLE_MK2_CLIP_02", "COMPONENT_COMBATMG_MK2_CLIP_02", 
    "COMPONENT_HEAVYSNIPER_MK2_CLIP_02", "COMPONENT_PISTOL_MK2_CLIP_02", "COMPONENT_SMG_MK2_CLIP_02", "COMPONENT_VINTAGEPISTOL_CLIP_02",
    "COMPONENT_MACHINEPISTOL_CLIP_02", "COMPONENT_COMPACTRIFLE_CLIP_02", "COMPONENT_HEAVYSHOTGUN_CLIP_02", "COMPONENT_MARKSMANRIFLE_CLIP_02",
    "COMPONENT_COMBATPDW_CLIP_02", "COMPONENT_GUSENBERG_CLIP_02"}},
  [3] = {name = "Advanced Grip", hashes = {"COMPONENT_AT_AR_AFGRIP", "COMPONENT_AT_AR_AFGRIP_02"}},
  [4] = {name = "Scope", hashes = {"COMPONENT_AT_SCOPE_MACRO", "COMPONENT_AT_SCOPE_MACRO_02", "COMPONENT_AT_SCOPE_SMALL", "COMPONENT_AT_SCOPE_SMALL_02", "COMPONENT_AT_SCOPE_MEDIUM", "COMPONENT_AT_SCOPE_LARGE",
    0x8ED4BB70, 0xE502AB6B, 0x9FDB5652, 0x420FD713, 0x9D65907A}},
  [5] = {name = "Drum Magazine", hashes = {"COMPONENT_SMG_CLIP_03", "COMPONENT_ASSAULTRIFLE_CLIP_03", "COMPONENT_CARBINERIFLE_CLIP_03",
    "COMPONENT_SPECIALCARBINE_CLIP_03", "COMPONENT_MACHINEPISTOL_CLIP_03", "COMPONENT_COMPACTRIFLE_CLIP_03", "COMPONENT_HEAVYSHOTGUN_CLIP_03",
    "COMPONENT_COMBATPDW_CLIP_03"}},
  [6] = {name = "Flashlight", hashes = {"COMPONENT_AT_AR_FLSH", "COMPONENT_AT_PI_FLSH"}}
}

"attachments": [
            {
                "name": 614078421,
                "serial": 66634
            }
        ],*/
let compHashDisplays = {
  ["Supressor"] : "<span style='color: lawngreen'>SP</span>",
  ["Extended Magazine"] : "<span style='color: skyblue'>M</span>",
  ["Advanced Grip"] : "<span style='color: yellow'>AG</span>",
  ["Scope"] : "<span style='color: #d687d1'>SC</span>",
  ["Drum Magazine"] : "<span style='color: #ff8080'>D</span>",
  ["Flashlight"] : "<span style='color: white'>F</span>"
}
let blockTransfers = false;
let showlabels = false;
let inventoryRendered = false;
let containerRendered = false;
let inventoryAnchorSave = "";
let containerAnchorSave = "";

$(function(){	
  masterContainer = $("#masterContainer");
  inventoryAnchor = $(".invAnchor");
  containerAnchor = $(".targetAnchor");
  
  window.addEventListener("message", function(event){
    var data = event.data;

    if (data.updateInventoryItems){
      inventoryRendered = false;
      updateInventoryDisplay(data.inventory, data.weapons, data.weaponNames);
      blockTransfersToggle(false);
    }
    else if (data.updateTargetContainer){
      containerRendered = false;
      updateContainerDisplay(data.items, data.weaponNames);
      blockTransfersToggle(false);

      data.title != undefined ? $(".targetContainerTitle").html(data.title) : $(".targetContainerTitle").html("Container");

      /*if (data.compHashes){
        compHashes = data.compHashes;
      }*/

      lastType = data.type;
    }
    else if (data.addInvSorter){
      let s = data.sorter;
			
			for (let i = 0; i < s.length; i++){
				let item = s[i];

				sorter.items.push(item);
			}
    }
    else if (data.blockTransferToggle){
      blockTransfersToggle(data.val);
    }
    else if (data.redrawInventories){
      updateInventoryDisplay(inventory, playerWeapons, weaponNames);
      updateContainerDisplay(container);
    }
    else if (data.redrawSavedInventories){
      updateInventoryDisplaySaved();
      updateContainerDisplaySaved();
    }
    else if (data.showMessageAlert){
      if (data.title && data.msg){
        showDialog(data.title, data.msg);
      }
    }
  });

  $(document).on("mouseenter", ".inv-item", function(){
		let left = $(this).offset().left;
		let top = $(this).offset().top;
		let width = $(this).width();
		let height = $(this).height();
		let text = $(this).children(".inv-image-center").data("title");

		if (text != undefined && text.length > 0){
			$(".fakeTooltip").html(text || "");
			$(".fakeTooltip").stop().fadeIn();

			let tipWidth = $(".fakeTooltip").width();

			$(".fakeTooltip").offset({left: left + (width / 2) - (tipWidth / 2), top: (top + height) + 10});
		}
		else{
			$(".fakeTooltip").stop().fadeOut();
		}
	});

	$(document).on("mouseleave", ".inv-item", function(){
		$(".fakeTooltip").stop().fadeOut();
	});

  document.onkeyup = function(data) {
		if (masterContainer.is(":visible") && (data.which == 27 || data.which == 75) && !blockTransfers) {
      masterContainer.stop().fadeOut();
      $(".fakeTooltip").stop().hide();
      playSound("NO");
			sendData("bms:inventory2:closeInventory", {type: lastType});
		}
		else if (masterContainer.is(":visible") && data.which == 81 && !blockTransfers){
			showlabels = !showlabels;
			toggleLabelDisplay();
		}
  };
  
  getCompHashes();
});

function sendData(name, data){
	$.post("https://inventory2/" + name, JSON.stringify(data), function(datab) {
		console.log(datab);
	});
}

function getCompHashes(){
  $.post("https://inventory2/getCompHashes", {}, function(data){
    if (data){
      let rd = JSON.parse(data);
      
      compHashes = rd.compHashes;
    }
  });
}

function playSound(sound) {
  sendData("playsound", {name: sound});
}

function showDialog(title, msg){
  alertify.defaults.theme.ok = "btn btn-success";
  alertify.alert(title, `<span style="color: white;">${msg}</span>`).set({
    transition: "fade"
  });
}

function blockTransfersToggle(val){
  blockTransfers = val;
  blockTransfers ? $(".invContainerBlocker").show() : $(".invContainerBlocker").hide();
  blockTransfers ? $(".targetContainerBlocker").show() : $(".targetContainerBlocker").hide();
}

function toggleLabelDisplay(){
	if (showlabels){
		$(".inv-item-image").css("opacity", 0.4);
		$(".inv-item-image").fadeOut(200, function(){
			$(".inv-text-overlay").fadeIn(150);
		});
	}
	else{
		$(".inv-item-image").css("opacity", 1.0);
		$(".inv-text-overlay").fadeOut(200, function(){
			$(".inv-item-image").fadeIn(150);
		});
	}
}

function getSorterData(name){ // sorter info is sent from inventory resource
  if (name == undefined){ return {pid: 1, image: null}}
  
	for (let i = 0; i < sorter.items.length; i++){
		let s = sorter.items[i];

		if (s.wildcard){
			let sname = s.name;
			// added wctype, 1 will do js startsWith check, 2 endsWith, 3 includes
			if ((!s.wctype && name.includes(sname) || (s.wctype == 3 && name.includes(sname)))){
				return {pid: s.pid, image: s.image || 0, context: s.context};
			}
			else if (s.wctype == 1 && name.startsWith(sname)){
				return {pid: s.pid, image: s.image || 0, context: s.context};
			}
			else if (s.wctype == 2 && name.endsWith(sname)){
				return {pid: s.pid, image: s.image || 0, context: s.context};
			}
		}
		else{
			if (name === s.name){
				return {pid: s.pid, image: s.image || 0, context: s.context};
			}
		}
	}
	let final = "";
	
	if (name in imageNames) {
		final = imageNames[name];
	} else {
    let img = name.replace(/\(|\)/g, "_");
    
		final = img.replace(/\s+/g, "_").toLowerCase();
		imageNames[name] = final;
	}
	return {pid: 1, image: final};
}

function updateInventoryDisplay(items, weapons, wepNames){  
  inventoryAnchor.children().remove();
  inventory = items;
  playerWeapons = weapons;
  
  if (wepNames != undefined) weaponNames = wepNames;
  
  for (let i = 0; i < weapons.length; i++){
    let weapon = weapons[i];
    let model = weapon.model;
    let sdata = getSorterData(model);
    let imgsrc = imageBase + (sdata.image || "wepnoimage") + ".png";
    let wepname = weapon.model;
    if (weaponNames[weapon.model]){
      wepname = weaponNames[weapon.model].name;
    }
    let attStr = "";

    if (weapon.model && weapon.attachments && weapon.attachments.length > 0){
      for (let a = 0; a < weapon.attachments.length; a++){
        let attachment = weapon.attachments[a];

        for (let ah = 0; ah < compHashes.length; ah++){
          let hashes = compHashes[ah].hashes;
          let name = compHashes[ah].name;
          let outerbreak = false;
          
          for (let h = 0; h < hashes.length; h++){
            let hash = hashes[h];

            if (hash == attachment.name){
              attStr += `${compHashDisplays[name]} `;
              outerbreak = true;
              break;
            }
          }

          if (outerbreak) break;
        }
      }
    }

    let entry = inventoryAnchor.append(`
      <div class="inv-item" data-wepitem="${wepname}" data-wepmodel="${model}" data-did="${i}">
        <div class="inv-image-center" data-title="${wepname}<br/>Quantity: 1">
          <div class="inv-text-overlay">${wepname}</div>
          <div class="attachment-text-overlay">${attStr}</div>
          <div class="inv-item-image" style="background-image: url(${imgsrc}); background-size: cover;"></div>
        </div>
      </div>
    `);
  }

  for (let i = 0; i < items.length; i++){
    let item = items[i];
    let sdata = getSorterData(item.name);
    //let pid = sdata.pid;
    let serial = item.serial;
    let mitemname;    
    let imgsrc = imageBase + (sdata.image || "noimage") + ".png";

    if (serial){
      mitemname = item.name + ` [SN:${serial}]`;
    }

    let entry = inventoryAnchor.append(`
      <div class="inv-item" data-invitem="${mitemname || item.name}" data-cat="${item.cat}" data-serial="${serial || 0}">
        <div class="inv-image-center" data-title="${mitemname || item.name}<br/>Quantity: ${item.quantity}">
          <div class="inv-text-overlay">${mitemname || item.name}</div>
          <div class="inv-item-image" style="background-image: url(${imgsrc}); background-size: cover;"></div>
        </div>
        <div class="btnholder"><div class="dinv-text">${item.quantity}</div></div>
        <div class="qtyinput">
          <input class="form-control qspinner" data-did="${i}" type="number" value="0" min="1" max="${item.quantity}" step="1"/>
        </div>
      </div>
    `);

    let spin = entry.find(".qspinner[data-did=" + i + "]");
    
    if (spin && spin.length > 0){
      spin.inputSpinner();
    }
  }

  if (!masterContainer.is(":visible")){
    masterContainer.stop().fadeIn();
  }

  inventoryAnchor.sortable({
    placeholder: "ddInv-placeholder",
    connectWith: ".targetAnchor",
    scroll: false,
    revert: true,
    appendTo: "body",
    helper: "clone",
    zIndex: 300,
    cursorAt: {
      left: 45, top: 61
    },
    remove: sortableRemoved
  });

  inventoryRendered = true;

  if (containerRendered){
    toggleLabelDisplay();
  }
  inventoryAnchorSave = inventoryAnchor.html();
}

function updateContainerDisplay(items, wepNames){
  containerAnchor.children().remove();
  container = items;

  if (wepNames != undefined) containerWeaponNames = wepNames;

  for (let i = 0; i < items.length; i++){
    let item = items[i];
    let sdata;
    let serial = item.serial;
    let mitemname;
    let attStr = "";
    let weapon = false;
        
    if (serial){
      mitemname = item.name + ` [SN:${serial}]`;
    }

    if (item.model){
      weapon = true;
      sdata = getSorterData(item.model);
    }
    else{
      sdata = getSorterData(item.name);
    }

    let imgsrc = imageBase + (sdata.image || "noimage") + ".png";

    if (item.model && item.attachments && item.attachments.length > 0){
      for (let a = 0; a < item.attachments.length; a++){
        let attachment = item.attachments[a];

        for (let ah = 0; ah < compHashes.length; ah++){
          let hashes = compHashes[ah].hashes;
          let name = compHashes[ah].name;
          let outerbreak = false;
          
          for (let h = 0; h < hashes.length; h++){
            let hash = hashes[h];

            if (hash == attachment.name){
              attStr += `${compHashDisplays[name]} `;
              outerbreak = true;
              break;
            }
          }

          if (outerbreak) break;
        }
      }
    }

    let entry;

    if (weapon){
      let wepname = item.model;
      if (containerWeaponNames[item.model]){
        wepname = containerWeaponNames[item.model].name;
      }

      entry = containerAnchor.append(`
        <div class="inv-item" data-wepitem="${wepname}" data-wepmodel="${item.model}" data-did="${i}">
          <div class="inv-image-center" data-title="${wepname}<br/>Quantity: 1">
            <div class="inv-text-overlay">${wepname}</div>
            <div class="attachment-text-overlay">${attStr}</div>
            <div class="inv-item-image" style="background-image: url(${imgsrc}); background-size: cover;"></div>
          </div>
        </div>
      `);
    }
    else{
      entry = containerAnchor.append(`
        <div class="inv-item" data-invitem="${mitemname || item.name}" data-cat="${item.cat}" data-serial="${serial || 0}" data-weapon="${weapon}">
          <div class="inv-image-center" data-title="${mitemname || item.name}<br/>Quantity: ${item.quantity}">
            <div class="inv-text-overlay">${mitemname || item.name}</div>
            <div class="inv-item-image" style="background-image: url(${imgsrc}); background-size: cover;"></div>
          </div>
          <div class="btnholder"><div class="dinv-text">${item.quantity}</div></div>
          <div class="qtyinput">
            <input class="form-control qspinner" data-did="${i}" type="number" value="0" min="1" max="${item.quantity}" step="1"/>
          </div>
        </div>
      `);
    }

    let spin = entry.find(".qspinner[data-did=" + i + "]");
    
    if (spin.length > 0){
      spin.inputSpinner();
    }
  }

  if (!masterContainer.is(":visible")){
    masterContainer.stop().fadeIn();
  }

  containerAnchor.sortable({
    placeholder: "ddInv-placeholder",
    connectWith: ".invAnchor",
    scroll: false,
    revert: true,
    appendTo: "body",
    helper: "clone",
    zIndex: 300,
    cursorAt: {
      left: 45, top: 61
    },
    remove: sortableRemoved
  });

  containerRendered = true;

  if (inventoryRendered){
    toggleLabelDisplay();
  }
  containerAnchorSave = containerAnchor.html();
}

function updateInventoryDisplaySaved(){
  inventoryAnchor.children().remove();
  inventoryAnchor.append(inventoryAnchorSave);

  let html = inventoryAnchor.find(".qspinner");
    
  if (html.length > 0){
    html.inputSpinner();
  }
}

function updateContainerDisplaySaved(){
  containerAnchor.children().remove();
  containerAnchor.append(containerAnchorSave);

  let html = containerAnchor.find(".qspinner");
    
  if (html.length > 0){
    html.inputSpinner();
  }
}

function sortableRemoved(event, ui){
  if (blockTransfers) return;

  let el = ui.item;
  let quantity = el.find(".qspinner").val() || 1;
  let did;
  let wepitem = el.data("wepitem");
  let wepmodel = el.data("wepmodel");
  let itemname = el.data("invitem");
  let weapon;
  let parent = el.parent();
  let dir;

  parent.hasClass("invAnchor") ? dir = 2 : dir = 1;
  weapon = wepitem != undefined && wepitem != "" && wepmodel != undefined && wepmodel != "";
  weapon ? did = parseInt(el.data("did")) : did = parseInt(el.find(".qspinner").data("did"));
  blockTransfersToggle(true);
  sendData("bms:inventory2:transferItem", {did: did, quantity: quantity, dir: dir, weapon: weapon, wepmodel: wepmodel, itemname: itemname, type: lastType});
}