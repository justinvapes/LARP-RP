let resourcename = "inventory";
let container;
let dcontainer;
let blockmove = false;
let blockuse = false;
let lastcallback = "";
let lasttransselleft = 0;
let lasttransselright = 0;
let transtype = 1;
let extra = 0;
let sorter = {items: []}; // sorter.items format: {name, pid (panel id), imgsrc (image source, for drag item view)}
let inventoryItems = [];
let weaponItems = [];
let activepanel = 1;
let weppanel = 4; // for the refresher, temporary static value
let newinv = true; // this can be switched between by user settings possibly, some people will prefer the list over the grid, so i left the original new list inventory in
let showlabels = false;
let imagebase = "/html/dinvicons/";
let blockgive = false;
let imageNames = [];
let worldDroppables = [];
let compHashes = [];
let compHashDisplays = {
  ["Supressor"] : "<span style='color: lawngreen'>SP</span>",
  ["Extended Magazine"] : "<span style='color: skyblue'>M</span>",
  ["Advanced Grip"] : "<span style='color: yellow'>AG</span>",
  ["Scope"] : "<span style='color: #d687d1'>SC</span>",
  ["Drum Magazine"] : "<span style='color: #ff8080'>D</span>",
  ["Flashlight"] : "<span style='color: white'>F</span>"
}
/*let ddoptions = { // multiple issues with z-index on the body drop, disabling for now
	group: {name: "master", pull: "clone", put: false},
	animation: 150,
	sort: true,
	onClone: function(evt){
		console.log(evt.item);
		console.log(evt.item);
	}
}
let droptions = {
	group: {name: "master", pull: false, put: true},
	animation: 150,
	sort: false
}*/

$(function(){
	container = $("#invContainer");
	dcontainer = $(".dinvContainer");
	//dbodydrop = $(".bodydroptarget");
	
	window.addEventListener("message", function(event){
		var item = event.data;
		
		if (item.showInventory){
			if (newinv){
				switchPanel2(1, false);
				$(".dnav-link").removeClass("nl-active");
				$(".dnav-link[data-id='1'").addClass("nl-active");
				//dbodydrop.show();
				dcontainer.fadeIn();
				playSound("YES");
			}
			else{
				switchPanel(1, false);
				$(".nav-link").removeClass("nl-active");
				$(".nav-link[data-id='1'").addClass("nl-active");
				container.show();
				playSound("YES");
			}
		}
		else if (item.hideInventory){
			container.hide();
			dcontainer.fadeOut();
			$(".fakeTooltip").stop().hide();
			playSound("NO");
		}
		else if (item.openTransfer){
			$("#transferBoxLeft").children().detach();
			$("#transferBoxRight").children().detach();
			$("#transferContainer").show();
			$("#trans_right_qty").val("1");
			$("#trans_left_qty").val("1");
			
			if (item.leftitems && item.leftitems != ""){
				$("#transferBoxLeft").append(item.leftitems);
			}
			
			if (item.rightitems && item.rightitems != ""){
				$("#transferBoxRight").append(item.rightitems);
			}

			if (lasttransselleft != ""){
				$(".transferItemLeft").each(function(i, obj){
					if (i == lasttransselleft){
						$(this).attr("class", "transferItemLeft selected");
					}
				});
			}

			if (lasttransselright != ""){
				$(".transferItemRight").each(function(i, obj){
					if (i == lasttransselright){
						$(this).attr("class", "transferItemRight selected");
					}
				});
			}

			blockmove = false;
			lastcallback = item.callback;
			transtype = item.transtype;
			extra = item.extra;
		}
		else if (item.unblockTransfer){
			blockmove = false
		}
		else if (item.blockInvUse){
			blockuse = item.toggle;
		}
		else if (item.addInvItems){
			var inv = item.inv;
			var weps = item.weapons;
			let droppables = item.worldDroppables;

			if (inv){
				addInvItems(inv);
			}
			
			if (weps){
				addWeaponItems(weps);
			}

			if (droppables){
				worldDroppables = droppables;
			}
			
			if (newinv){
				switchPanel2(activepanel, activepanel == weppanel);
			}
			else{
				switchPanel(activepanel, activepanel == weppanel);
			}
		}
		else if (item.addInvSorter){
			let s = item.sorter;
			
			for (let i = 0; i < s.length; i++){
				let item = s[i];

				sorter.items.push(item);
			}

			//this.console.log(JSON.stringify(sorter.items));
		}
		else if (item.unblockGive){
			blockgive = false;
		}
	});
	
	$(".nav-link").click(function(){
		$(".nav-link").removeClass("nl-active");
		$(this).addClass("nl-active");
		switchPanel(parseInt($(this).data("id")), $(this).text() == "Weapons");
	});
	
	$(".dnav-link").click(function(){
		$(".dnav-link").removeClass("nl-active");
		$(this).addClass("nl-active");
		switchPanel2(parseInt($(this).data("id")), $(this).text() == "Weapons");
	});
	
	switchPanel(1, false);
	switchPanel2(1, false);

	$(document).on("click", ".itemname", function(){
		let itemname = $(this).html();

		if (itemname != ""){
			sendData("useitem", {invitem: itemname, invqty: 1});
			playSound("SELECT");
		}
	});
	
	$(document).on("dblclick", ".dinv-item-image", function(){
		if (newinv && !blockuse){
			blockuse = true;
			let root = $(this).parent().parent();
			let invitem = root.data("invitem");

			if (invitem != ""){
				sendData("useitem", {invitem: invitem, invqty: 1});
				playSound("SELECT");
			}
		}
	});

	$(document).on("mouseenter", ".itemname", function(){
		let info = $(this).siblings(".giveinfo");

		info.html("Use this Item");
	});

	$(document).on("mouseleave", ".itemname", function(){
		let info = $(this).siblings(".giveinfo");
		
		info.html("");
	});

	document.onkeyup = function(data) {
		if ($("#invContainer").is(":visible") && (data.which == 27 || data.which == 75)) {
			container.hide();
			playSound("NO");
			sendData("closeInventory", "");
		}
		else if (dcontainer.is(":visible") && (data.which == 27 || data.which == 75)){
			dcontainer.fadeOut();
			$(".fakeTooltip").stop().hide();
			$("#contextMenuGeneral").fadeOut();
			playSound("NO");
			sendData("closeInventory", "");
		}
		else if (newinv && dcontainer.is(":visible") && data.which == 81){
			showlabels = !showlabels;

			toggleLabelDisplay();
		}
	};
	
	$(document).on("click", ".dropbutton", function(){
		$(".fakeTooltip").stop().hide();
		
		if (newinv){
			let iswep = $(this).parent().parent().data("wepitem") != null;
			let dataroot = $(this).parent().parent();

			if (iswep){
				let item = dataroot.data("wepitem");
				let model = dataroot.data("wepmodel");

				sendData("dropWepItem", {name: item, model: model});
			}
			else{
				let item = dataroot.data("invitem");
				let serial = dataroot.data("serial");
				let qty = parseInt($(this).parent().siblings().find(".qspinner").val());

				if (qty > 0){
					sendData("dropItem", {item: item, quantity: qty, serial: serial});
					qty = 0;
				}
			}
		}
		else{
			let iswep = $(this).data("wepitem") != null;
			let dataroot = $(this).parent().parent();

			if (iswep){
				let item = dataroot.data("wepitem");
				let model = dataroot.data("wepmodel");

				sendData("dropWepItem", {name: item, model: model});
			}
			else{
				let item = dataroot.data("invitem");
				let qty = parseInt(dataroot.find(".qspinner").val());

				if (qty > 0){
					sendData("dropItem", {item: item, quantity: qty});
					qty = 0;
				}
			}
		}
	});
	
	$(document).on("mouseenter", ".exitoption", function(){
		if ($(this).attr("class") != "exitoption selected")
		{
			$(this).attr("class", "exitoption selected");
		}
	});
	
	$(document).on("click", ".givebutton", function(){
		if (blockgive) return;
		
		$(".fakeTooltip").stop().hide();

		if (newinv){
			let iswep = $(this).parent().parent().data("wepitem") != null;
			
			if (iswep){
				let dataroot = $(this).parent().parent();
				let item = dataroot.data("wepitem");
				let model = dataroot.data("wepmodel");

				blockgive = true;
				sendData("giveWeaponItem", {item: item, model: model});
			}
			else{
				let item = $(this).parent().parent().data("invitem");
        let qty = parseInt($(this).parent().siblings().find(".qspinner").val());
        let cat = parseInt($(this).parent().parent().data("cat") || 0);
	
				if (qty > 0){
					blockgive = true;
					sendData("giveItem", {item: item, quantity: qty, cat: cat});
					qty = 0;
				}
			}
		}
		else{
			let iswep = $(this).data("wepitem") != null;
			let dataroot = $(this).parent().parent();

			if (iswep){
				let item = dataroot.data("wepitem");
				let model = dataroot.data("wepmodel");

				sendData("giveWeaponItem", {item: item, model: model});
			}
			else{
				let item = dataroot.data("invitem");
        let qty = parseInt(dataroot.find(".qspinner").val());
        let cat = parseInt($(this).parent().parent().data("cat") || 0);

				if (qty > 0){
					sendData("giveItem", {item: item, quantity: qty, cat: cat});
					qty = 0;
				}
			}
		}
	});

	$(document).on("mouseenter", ".givebutton", function(){
		let iswep = $(this).data("wepitem") != null;
		let dataroot = $(this).parent().parent();

		if (!iswep){
			let qty = dataroot.find(".qspinner").val();

			dataroot.parent().find(".giveinfo").html(`Give ${qty} item(s)`);
		}
	});

	$(document).on("mouseleave", ".givebutton", function(){
		let dataroot = $(this).parent().parent();
		dataroot.parent().find(".giveinfo").html("");
	});

	$(document).on("mouseenter", ".dropbutton", function(){
		let iswep = $(this).data("wepitem") != null;
		let dataroot = $(this).parent().parent();

		if (!iswep){
			let qty = dataroot.find(".qspinner").val();

			dataroot.parent().find(".giveinfo").html(`Drop ${qty} item(s)`);
		}
	});

	$(document).on("mouseleave", ".dropbutton", function(){
		let dataroot = $(this).parent().parent();
		dataroot.parent().find(".giveinfo").html("");
	});

	$("#trans_right").click(function(){
		if (!blockmove){
			var selected = $(".transferItemLeft.selected");
			
			if (selected.length == 0) return;
			
			var stolen = selected.data("stolen");

			if (stolen){
				sendData("notifyClient", {msg: "You can not transfer <span style='color: red;'>stolen items</span>."});
				return;
			}

			var selname = selected.html().replace(/ *\[[^\]]*]/, "");
			selname = selname.replace(/ &gt;(.*)&lt;/, "");
			var quantity = parseInt($("#trans_right_qty").val());

			if (quantity && quantity > 0){
				var itemid = selected.data("itemid");
				var itemtype = selected.data("type");
				var serial = parseInt(selected.data("serial"));
				var cat = parseInt(selected.data("cat"));

				blockmove = true;
				$(".transferItemLeft").each(function(i, obj){
					if ($(this).attr("class") == "transferItemLeft selected"){
						lasttransselleft = i
					}					
				});

				// direction: 1 - in, 2 - out
				sendData("moveItem", {direction: 1, name: selname, quantity: quantity, serial: serial, itemid: itemid, itemtype: itemtype, transtype: transtype, extra: extra, cat: cat});
			}
		}
	});

	$("#trans_left").click(function(){
		if (!blockmove){
			var selected = $(".transferItemRight.selected");

			if (selected.length == 0) return;

			var selname = selected.html().replace(/ *\[[^\]]*]/, "");
			selname = selname.replace(/ &gt;(.*)&lt;/, "");
			var quantity = parseInt($("#trans_left_qty").val());
			
			if (quantity && quantity > 0){
				var itemid = selected.data("itemid");
				var itemtype = selected.data("type");
				var serial = parseInt(selected.data("serial"));
				var cat = parseInt(selected.data("cat"));

				blockmove = true;
				$(".transferItemRight").each(function(i, obj){
					if ($(this).attr("class") == "transferItemRight selected"){
						lasttransselright = i
					}					
				});

				// direction: 1 - in, 2 - out
				sendData("moveItem", {direction: 2, name: selname, quantity: quantity, serial: serial, itemid: itemid, itemtype: itemtype, transtype: transtype, extra: extra, cat: cat});
			}
		}
	});

	$(document).on("click", ".transferItemLeft", function(){
		$(".transferItemLeft").each(function(i, obj){
			$(this).attr("class", "transferItemLeft");
		});
		
		if ($(this).attr("class") != "transferItemLeft selected"){
			$(this).attr("class", "transferItemLeft selected");
		}
	});

	$(document).on("click", ".transferItemRight", function(){
		$(".transferItemRight").each(function(i, obj){
			$(this).attr("class", "transferItemRight");
		});
		
		if ($(this).attr("class") != "transferItemRight selected"){
			$(this).attr("class", "transferItemRight selected");
		}
	});

	$(".transferExitButton").click(function(){
		$("#transferContainer").hide();
		sendData("closeTransfer", {callback: lastcallback});
	});

	/* window control */
	$(".dinvContainer").draggable({
		handle: ".dinv-header"
	});
	
	$(".dinvContainer").resizable({
		animate: true,
		handles:{
		 se: ".resizer-handle"
		},
		ghost: true
	});
	
	$(".trans-up").click(function(){
		let opac = parseFloat(dcontainer.css("opacity"));

		opac = opac + 0.05;

		if (opac > 1.0){
			opac = 1.0;
		}

		dcontainer.css("opacity", opac);
	});

	$(".trans-down").click(function(){
		let opac = parseFloat(dcontainer.css("opacity"));

		opac = opac - 0.05;

		if (opac < 0.3){
			opac = 0.1;
		}

		dcontainer.css("opacity", opac);
	});

	$(".dinv-invmenu").sortable(/*ddoptions*/{
		animation: 150
	});

	$(document).on("mouseenter", ".dinv-item", function(){
		let left = $(this).offset().left;
		let top = $(this).offset().top;
		let width = $(this).width();
		let height = $(this).height();
		let text = $(this).children(".dinv-image-center").data("title");

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

	$(document).on("mouseleave", ".dinv-item", function(){
		$(".fakeTooltip").stop().fadeOut();
	});

	getCompHashes();
});

function sendData(name, data){
	$.post("http://" + resourcename + "/" + name, JSON.stringify(data), function(datab) {
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

function clearInv(){
	$("#inventoryMenu").children().detach();
}

function getSorterData(name){
	for (let i = 0; i < sorter.items.length; i++){
		let s = sorter.items[i];

		if (s.wildcard){
			let sname = s.name;
			//if (name.includes(sname)){ -- problems, problems // added wctype, 1 will do js startsWith check, 2 endsWith, 3 includes
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
		//console.log(`name: ${name}, lookup: ${final}`);
	} else {
		let img = name.replace(/\(|\)/g, "_");
		final = img.replace(/\s+/g, "_").toLowerCase();
		//console.log(`name: ${name}, img: ${img}, png: ${final}`);
		imageNames[name] = final;
	}
	return {pid: 1, image: final};
}

function addInvItems(inv){
	inventoryItems = inv;
}

function addWeaponItems(weps){
	weaponItems = weps;
}

function switchPanel(id, weapons){
	activepanel = id;
	$(".inventoryMenu").children().detach();
	
	if (weapons){
		for (let i = 0; i < weaponItems.length; i++){
			let item = weaponItems[i];
			let model = item.model;

			if (!model){
				model = item.hash;
			}
			
			$(".inventoryMenu").append(`<div class="row invrow wepoption" style="margin-top: 2px;" data-wepitem="${item.name}" data-wepmodel="${model}">
					<div class="col-9">
						<div class="invitem">
							${item.name}
						</div>          
					</div>
					<div class="col-3">
						<button class="givebutton give blue-grad">
							<i class="fas fa-angle-right fa-sm"></i>
						</button>
						<button class="dropbutton drop red-grad">X</button>
					</div>
				</div>`);
		}
	}
	else{
	
		for (let i = 0; i < inventoryItems.length; i++){
			let item = inventoryItems[i];
			let sdata = getSorterData(item.name);
			let pid = sdata.pid;

			if (pid == id){
				let entry = $(".inventoryMenu").append(`
				<div class="itemcontainer">
					<div class="row invitem">
						<div class="col-12">
							<div class="itemname">${item.name}</div><div class="giveinfo"></div>
						</div>
					</div>
					<div class="row invrow" style="margin-top: 2px;" data-invitem="${item.name}" data-cat="${item.cat}">
						<div class="col-5">
								<div class="qtydisplay">${item.quantity}</div>
						</div>
						<div class="col-4">
							<div class="qtyinput"><input class="form-control qspinner" data-id="${i}" type="number" value="0" min="1" max="${item.quantity}" step="1"/></div>
						</div>
						<div class="col-3">
							<button class="givebutton give blue-grad ">
								<i class="fas fa-angle-right fa-sm"></i>
							</button>
							<button class="dropbutton drop red-grad">X</button>
						</div>
					</div>
				</div>`);
				
				let spin = entry.find(".qspinner[data-id=" + i + "]");

				spin.inputSpinner();
			}
		}
	}
}

function droppedInWorld(item){
	let keys = Object.keys(worldDroppables);

	for (let i = 0; i < keys.length; i++){
		let k = keys[i];
		let droppable = worldDroppables[k];
		
		if ((k == item && !droppable.wildcard) || (item.includes(k) && droppable.wildcard)){
			return true;
		}
	}

	return false;
}

function switchPanel2(id, weapons){
	activepanel = id;
	$(".dinv-invmenu").children().detach();

	if (weapons){
		for (let i = 0; i < weaponItems.length; i++){
			let item = weaponItems[i];
			let model = item.model;
			let sdata = getSorterData(model);
			let attStr = "";
			let cdata = {context: []};

			//{text = "Break Down", rval = 1},
    	//{text = "Create Quarter Pound", rval = 2},
    	//{text = "Create Pound", rval = 3}

			if (!model){
				model = item.hash;
			}

			if (item.attachments && item.attachments.length > 0){
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
								cdata.context.push({text: `Remove ${name}`, rval: 1, attval: attachment.name});
								outerbreak = true;
								break;
							}
						}
	
						if (outerbreak) break;
					}
				}
			}

			if (attStr != ""){
				attStr = `<span class="attachment-text-overlay">${attStr}</span>`;
			}

			let imgsrc = imagebase + (sdata.image || "wepnoimage") + ".png";
			let entry = $(".dinv-invmenu").append(`
				<div class="dinv-item" data-wepitem="${item.name}" data-wepmodel="${model}">
					<div class="dinv-image-center" data-title="${item.name}<br/>Quantity: 1">
						<div class="dinv-text-overlay">${item.name}</div>
						${attStr}
						<div class="dinv-item-image" style="background-image: url(${imgsrc}); background-size: cover;"></div>
					</div>
					<div class="btnholder">
						<button class="givebutton give blue-grad" style="float:right;">
							<i class="fas fa-angle-right fa-sm"></i>
						</button>
						<button class="dropbutton drop red-grad" style="float:right;">
							X
						</button>
					</div>
				</div>`
			);
			
			// attachment context menu
			if (item.attachments && item.attachments.length > 0){
				$(".dinv-item[data-wepitem='" + item.name + "']").contextMenu({
					itemName: item.name,
					itemSorter: cdata,
					menuSelector: "#contextMenuGeneral",
					menuSelected: function($invokedOn, $selectedMenu){
						let ctext = $selectedMenu.text();
						let val = parseInt($selectedMenu.attr("value"));
						let attval = $selectedMenu.data("attval");
						let selitem = $selectedMenu.data("itemname");

						//console.log(`ctext: ${ctext}, val: ${val}, selitem: ${selitem}, attval: ${attval}`);
						if (ctext != "" && val && !blockuse){
							blockuse = true;
							sendData("weaponContextEvent", {contextText: ctext, value: val, attval: attval, itemName: selitem});
						}
					}
				});
			}
		}
	}
	else{
		for (let i = 0; i < inventoryItems.length; i++){
			let item = inventoryItems[i];
			let sdata = getSorterData(item.name);
			let pid = sdata.pid;
			let serial = item.serial;
			let mitemname;
			let worldDrop = droppedInWorld(item.name);
			let worldStr = `style="display:inline-block"`;

			if (!pid){
				console.log("You forgot the PID, idiot.");
			}

			if (!worldDrop){
				worldStr = "";
			}

			if (serial){
				mitemname = item.name + ` [SN:${serial}]`;
			}

			if (pid == id){
				let imgsrc = imagebase + (sdata.image || "noimage") + ".png";
				let entry = $(".dinv-invmenu").append(`
						<div class="dinv-item" data-invitem="${mitemname || item.name}" data-cat="${item.cat}" data-serial="${serial || 0}">
							<div class="dinv-image-center" data-title="${mitemname || item.name}<br/>Quantity: ${item.quantity}">
								<div class="dinv-text-overlay">${mitemname || item.name}</div>
								<div class="dinv-item-image" style="background-image: url(${imgsrc}); background-size: cover;"></div>
								<div class="worldglobe" ${worldStr}><i class="fas fa-globe-americas" style="width: 12px; height: 12px; color: skyblue;"></i></div>
							</div>
							<div class="btnholder"><div class="dinv-text">${item.quantity}</div><button class="givebutton give blue-grad" style="float:right;"><i class="fas fa-angle-right fa-sm"></i></button><button class="dropbutton drop red-grad" style="float:right;">X</button></div>
							<div class="qtyinput"><input class="form-control qspinner" data-did="${i}" type="number" value="0" min="1" max="${item.quantity}" step="1"/></div>
						</div>`);

				let spin = entry.find(".qspinner[data-did=" + i + "]");

				spin.inputSpinner();

				/* bind context menu */
				$(".dinv-item[data-invitem='" + (mitemname || item.name) + "']").contextMenu({
					itemName: mitemname || item.name,
					itemSorter: sdata,
					menuSelector: "#contextMenuGeneral",
					menuSelected: function($invokedOn, $selectedMenu){
						let ctext = $selectedMenu.text();
						let val = parseInt($selectedMenu.attr("value"));
						let selitem = $selectedMenu.data("itemname");

						//console.log(`ctext: ${ctext}, val: ${val}, selitem: ${selitem}`);
						if (ctext != "" && val && !blockuse){
              blockuse = true;
							sendData("contextEvent", {contextText: ctext, value: val, itemName: selitem});
						}
					},
					onMenuShow: function($invokedOn) {
							/*var tr = $invokedOn.closest("tr");
							$(tr).addClass("warning");*/
					},
					onMenuHide: function($invokedOn) {
							/*var tr = $invokedOn.closest("tr");
							$(tr).removeClass("warning");*/
					}
				});
			}
		}
	}
}

function toggleLabelDisplay(){
	if (showlabels){
		$(".dinv-item-image").css("opacity", 0.4);
		$(".attachment-text-overlay").hide();
		$(".dinv-item-image").stop().fadeOut(200, function(){
			$(".dinv-text-overlay").stop().fadeIn(150);
		});
	}
	else{
		$(".dinv-item-image").css("opacity", 1.0);
		$(".attachment-text-overlay").show();
		$(".dinv-text-overlay").stop().fadeOut(200, function(){
			$(".dinv-item-image").stop().fadeIn(150);
		});
	}
}

/* jQuery Bootstrap context menu -- http://jsfiddle.net/dmitry_far/cgqft4k3/ */
(function ($, window) {
	let menus = {};

	$.fn.contextMenu = function (settings) {
		let $menu = $(settings.menuSelector);

		$menu.data("menuSelector", settings.menuSelector);

		if ($menu.length === 0){
			console.log("inventory.js >> inventory contextmenu not found");
			return;
		}
		
		menus[settings.menuSelector] = {$menu: $menu, settings: settings};
		
		//make sure menu closes on any click
		$(document).click(function (e) {
			hideAll();
		});
		$(document).on("contextmenu", function (e) {
			let $ul = $(e.target).closest("ul");
			
			if ($ul.length === 0 || !$ul.data("menuSelector")) {
				hideAll();
			}
		});
		
		// Open context menu
		(function(element, menuSelector){
				element.on("contextmenu", function (e) {
						// return native menu if pressing control
						if (e.ctrlKey) return;

						hideAll();
						let menu = getMenu(menuSelector);

						if (settings.itemSorter && settings.itemSorter.context){
							$(menuSelector).find("li").detach();

							for (let c = 0; c < settings.itemSorter.context.length; c++){
								let context = settings.itemSorter.context[c];

								$(menuSelector).append(`<li><a tabindex="-1" href="#" value="${context.rval}" data-attval="${context.attval}" data-itemname="${settings.itemName}">${context.text}</a></li>`);
							}
						}
						else{
							$(menuSelector).find("li").detach();
						}

						if ($(menuSelector).find("li").length == 0) return;
						
						//open menu
						menu.$menu
						.data("invokedOn", $(e.target))
						.show()
						.css({
								position: "absolute",
								left: getMenuPosition(e.clientX, 'width', 'scrollLeft'),
								top: getMenuPosition(e.clientY, 'height', 'scrollTop')
						})
						.off('click')
						.on('click', 'a', function (e) {
								menu.$menu.hide();
								
								let $invokedOn = menu.$menu.data("invokedOn");
								let $selectedMenu = $(e.target);
								
								callOnMenuHide(menu);
								menu.settings.menuSelected.call(this, $invokedOn, $selectedMenu);
						});
						
						callOnMenuShow(menu);
						return false;
				});
		})($(this), settings.menuSelector);

		function getMenu(menuSelector) {
				let menu = null;
				$.each( menus, function( i_menuSelector, i_menu ){
						if (i_menuSelector == menuSelector) {
								menu = i_menu
								return false;
						}
				});
				return menu;
		}
		function hideAll() {
				$.each( menus, function( menuSelector, menu ){
						menu.$menu.hide();
						callOnMenuHide(menu);
				});
		}
		
		function callOnMenuShow(menu) {
				let $invokedOn = menu.$menu.data("invokedOn");
				if ($invokedOn && menu.settings.onMenuShow) {
						menu.settings.onMenuShow.call(this, $invokedOn);
				}
		}
		function callOnMenuHide(menu) {
				let $invokedOn = menu.$menu.data("invokedOn");
				menu.$menu.data("invokedOn", null);
				if ($invokedOn && menu.settings.onMenuHide) {
						menu.settings.onMenuHide.call(this, $invokedOn);
				}
		}
		
		function getMenuPosition(mouse, direction, scrollDir) {
				let win = $(window)[direction](),
						scroll = $(window)[scrollDir](),
						menu = $(settings.menuSelector)[direction](),
						position = mouse + scroll;
										
				// opening menu would pass the side of the page
				if (mouse + menu > win && menu < mouse) {
						position -= menu;
				}
				
				return position;
		}    
		return this;
	};
})(jQuery, window);
