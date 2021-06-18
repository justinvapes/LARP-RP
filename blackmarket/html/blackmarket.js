let attStrData = `
<div class="bm-weaponextras ml-2 mt-2">
  <div class="attachment-buttons">
    <div class="btn-toolbar" role="toolbar">
      <div class="btn-group" role="group">
        <button type="button" class="btn btn-secondary bm-att" data-attid="1"><span class="selicon"><i class="fas fa-check"></i></span>Suppressor</button>
        <button type="button" class="btn btn-secondary bm-att" data-attid="2"><span class="selicon"><i class="fas fa-check"></i></span>Extended Mag</button>
        <button type="button" class="btn btn-secondary bm-att" data-attid="3"><span class="selicon"><i class="fas fa-check"></i></span>Tactical Grip</button>
      </div>
    </div>
    <div class="btn-toolbar mt-2" role="toolbar">
      <div class="btn-group" role="group">
        <button type="button" class="btn btn-secondary bm-att" data-attid="4"><span class="selicon"><i class="fas fa-check"></i></span>Scope</button>
        <button type="button" class="btn btn-secondary bm-att" data-attid="5"><span class="selicon"><i class="fas fa-check"></i></span>Drum Magazine</button>
        <button type="button" class="btn btn-secondary bm-att" data-attid="6"><span class="selicon"><i class="fas fa-check"></i></span>Flashlight</button>
      </div>
    </div>
  </div>
</div>`;

let weaponItems;
let totalCostText;
let totalCost = 0;
let blockPurchase = false;

$(function(){
	let mainContainer = $(".mainContainer");
	let headerText = $(".bm-headerText");
	let attData = [];

	weaponItems = $(".bm-weaponitems");
	totalCostText = $(".bm-totalCost");

	window.addEventListener("message", function(event){
		let data = event.data;

		if (data.loadAttData){
			attData = data.attdata;
		}
		else if (data.setHeaderText){
			headerText.html(data.text);
		}
		else if (data.toggleBlackmarket){
			data.toggle ? mainContainer.fadeIn() : mainContainer.fadeOut();
		}
		else if (data.loadWeapons){
			let weps = data.weapons;
			let tier = data.tier;
			let open = data.open;

			if (open){
				loadWeapons(weps);
				mainContainer.fadeIn();
				
				let headtext = headerText.html();
				
				headerText.html(headtext + ` (Tier ${tier})`);
			}
		}
		else if (data.togglePurchase){
			blockPurchase = data.blocked;
		}
	});

	$(document).on("click", ".bm-att", function(){
    let ele = $(this).find(".selicon");
		let visible = ele.is(":visible");
		
		visible ? ele.hide() : ele.fadeIn();
		let cost = parseInt($(this).data("price"));

		if (ele.is(":visible")){
			totalCost += cost;
		}
		else{
			totalCost -= cost;
		}

		updateTotalCost();
  });
  
  $(document).on("click", ".bm-weaponitem", function(){
		$(".bm-weaponextras").detach();
		$(".bm-weaponitem").removeClass("selected");
    $(this).addClass("selected");
		
		let wepname = $(this).data("name");
		let attele = $(this).after(attStrData);

		$(".bm-att").hide();

		if (attele.length > 0){
			let attkeys = Object.keys(attData);

			for (let i = 0; i < attkeys.length; i++){
				let key = attkeys[i];

				if (key == wepname){
					let attachments = attData[key].attachments;
					let akeys = Object.keys(attachments);

					for (let j = 0; j < akeys.length; j++){
						let akey = akeys[j];
						let attachment = attachments[akey];

						if (attachment.compatible){
							let attele = $(".bm-att[data-attid='" + akey + "']");
							
							attele.data("price", attachment.price);
							attele.show();
						}
					}
				}
			}
		}
		else{
			console.log("attachments null");
		}

		totalCost = parseInt($(this).data("price"));
		updateTotalCost();
	});

	$(".bm-purchaseSelected").click(function(){
		if (blockPurchase) return;

		let wep = $(".bm-weaponitem.selected");
		let name = wep.data("name");
		let attachments = {};

		if (name){
			$.each($(".selicon"), function(){
				if ($(this).is(":visible")){
					let attid = $(this).parent().data("attid");

					attachments[attid] = true;
				}
			});

			sendData("bms:blackmarket:purchaseWeapon", {weaponid: name, attachments: attachments});
			playSound("YES");
		}
	});

	$(".bm-closeWindow").click(function(){
		resetAllBmFields();
		mainContainer.fadeOut();
		sendData("bms:blackmarket:bmWindowClosed");
		headerText.html("Black Market");
		playSound("NO");
	});
});

function sendData(name, data){
  $.post("http://blackmarket/" + name, JSON.stringify(data));
}

function playSound(sound) {
	sendData("playsound", {name: sound});
}

function resetAllBmFields(){
	totalCost = 0;
	updateTotalCost();
	$(".bm-weaponitem").removeClass("selected");
	$(".bm-weaponextras").detach();
}

function loadWeapons(weps){
	weaponItems.children().detach();
	
	for (let i = 0; i < weps.length; i++){
		let weapon = weps[i];

		weaponItems.append(`<div class="bm-weaponitem" data-price="${weapon.price}" data-name="${weapon.name}">${weapon.name}<span class="bm-price float-right">$${weapon.price}</span></div>`);
	}
}

function updateTotalCost(){
	totalCostText.html(`$${totalCost}`);
}