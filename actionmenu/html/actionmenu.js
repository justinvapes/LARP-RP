let categories = [];
let actions = [];
let emotecategories = ["General", "Dances", "Arresting", "Sitting", "Emergency", "Law Enforcement", "Work", "Athletics"];
let lastActionId = -1;
let lastPedId = 0;
let menushowing = false;
let menuInit = false;
let menuItemsAnchor = $("#menuItemsAnchor");
let actionMenuApi;
let container = $("#amContainer");

$(function(){
	window.addEventListener("message", function(event)
	{
		let item = event.data;
		
		if (item.showMenu){
			container.show();
			playSound("YES");
			if (!menuInit){
				drawCategories();
				drawActions();
				menuInit = true;

				$("#actionMenu").mmenu({
					"extensions": [
						"position-right",
						"theme-dark"
					],
					"navbar": {
						"title": "Main"
					},
					"navbars":[
						{
							"height": 1,
							"position": "top",
							"content":[
								"<div class='logoimage'/>"
							]
						},
						{
							"position": "bottom",
							"content":[
								"<span class='exitoption'>Exit</span>"
							]
						}
					],
					"onClick":{
						"setSelected": false
					},
					"setSelected":{
						"hover": true
					}
        });
        
        initCategories();
      }

			container.focus();
			menushowing = true;
			actionMenuApi = $("#actionMenu").data("mmenu");
			actionMenuApi.open();
		}
		else if (item.hideMenu){
			if (actionMenuApi != undefined && actionMenuApi.length > 0){
				actionMenuApi.close();
				container.hide();
			}
			else{
				container.hide();
			}
			playSound("NO");
			menushowing = false;
		}
		else if (item.addAction){
			addAction(item.category, item.data);
		}
		else if (item.clearActions){
			clearActions();
		}
		else if (item.removeAction){
			removeAction(item.dispname, item.catid);
		}
		else if (item.changeAction){
			changeAction(item.dispname, item.changeto);
		}
		else if (item.addCategory){
			addCategory(item.catname, item.catid, item.hide);
		}
		else if (item.removeCategory){
			removeCategory(item.catname);
		}
		else if (item.showInputDialog){
			showInputDialog(item.interactText, item.actionText, item.inputActionId, item.buttonText);
			lastPedId = item.lastPedId;
    }
    else if (item.hideCategory){
      if (menuInit) {
        $(".categoryListItem[data-catname='" + replaceBreaks(item.catname) + "']").hide();
        actionMenuApi.closeAllPanels();
      }
    }
    else if (item.showCategory){
      if (menuInit) {
        $(".categoryListItem[data-catname='" + replaceBreaks(item.catname) + "']").show();
      }
		}
	});

	// ESC press
	document.onkeyup = function(data){
		if (data.which == 27){
			playSound("SELECT");
			
			if (actionMenuApi != undefined){
				actionMenuApi.close();
				container.hide();
			}
			else{
				container.hide();
			}
			
			sendData("actionmenu", "escape", "");
			menushowing = false;
		}
	};

	$(document).mouseup(function(ev){		
		switch (ev.which){
			case 3: {
				exitMenu(true);
			}
		}
	});

	$(document).on("click", ".catitem", function() {
		playSound("SELECT");
	});
	
	$(document).on("click", ".exitoption", function() {
		exitMenu(true);
	});
	
	$(document).on("click", ".amitem", function() {
		let resource = $(this).data("resource");
		let action = $(this).data("action");
		let detect = $(this).data("detect");
		let extra = $(this).data("extra");
	
		exitMenu();
		sendData("actionmenu", "selectAction", {resource: resource, action: action, detect: detect, extra: extra});
	});
	
	$(document).on("click", ".submitbutton", function() {
		let inputText = $("#userinput").val();
		
		playSound("SELECT");
		$("#userinput").val("");
		$("#inputDialog").hide();
		sendData("actionmenu", "inputDialogResult", {inputtext: inputText, inputActionId: lastActionId, lastPedId: lastPedId});
		lastActionId = -1;
		lastPedId = 0;
	});
});

function exitMenu(escapeAction){
	playSound("SELECT");
	actionMenuApi.close();
	
	if (actionMenuApi != undefined && actionMenuApi.length > 0){
		actionMenuApi.close();
		container.hide();
	}
	else{
		container.hide();
	}
		
	menushowing = false;

	if (escapeAction){
		sendData("actionmenu", "escape", "");
	}
}

function replaceBreaks(str){
	return str.replace(/ /g, "_").toLowerCase();
}

function addCategory(catname, catid, hideCat){
	let exists = false;

	for (let i = 0; i < categories.length; i++){
		if (categories[i].catname == catname){
			exists = true;
		}
	}

	if (!exists){
		categories.push({catname: catname, catid: catid, hide: hideCat});
	}

	/*if (menuInit){ // Can't get this bull shit to work post init.  It nukes the whole top level menu.
		let category = categories[categories.length - 1];
		let imgFilename = "images/" + category.catname.replace(" ", "").toLowerCase() + ".png";
		let anchor = $("#menuItemsAnchor").find(".mm-listview");

		if (anchor.length > 0){
			anchor.append(`
				<li class="categoryListItem" id="${category.catid}" data-catname="${replaceBreaks(category.catname)}">
					<span class="category-title"><span class="catimage-container" style="background-image:url(${imgFilename})"></span>${category.catname}</span>
					<ul id="${replaceBreaks(category.catname)}1"></ul>
				</li>
			`);

			actionMenuApi.initPanel(anchor[0]);
		}
		else{
			console.log("Could not find listview for append >> addCategory.");
		}

		//console.log(menuItemsAnchor.find(".mm-listview")[0]);
		//actionMenuApi.initPanel(menuItemsAnchor.find(".mm-listview")[0]);
	}*/
}

function getCategoryById(id){
	return categories.find(cat => cat.catid == id);
}

function removeCategory(catname){
	let catid = categories.find(cat => cat.catname == catname).catid;

	categories = categories.filter(cat => cat.catname != catname);
	action = actions.filter(action => action.catid != catid);
}

function addAction(catid, data){
	actions.push({catid: catid, data: data});

	if (menuInit){ // add new action to menu
		once = true;
		let category = getCategoryById(catid);

		if (category){
			let listview = $("#" + replaceBreaks(category.catname) + "1 > .mm-listview");

			if (listview.length > 0){
				let extrastr = "";
				let extra2str = "";
				
				if (data.extra){
					extrastr = ` data-extra="${data.extra}"`;
				}

				if (data.extra2){
					extra2str = ` data-extra2="${data.extra2}"`;
				}

				listview.append(`
					<li data-dispname="${data.dispname}"><span class="amitem" data-resource="${data.resname}" data-action="${data.action}" data-detect="${data.detecttype}"${extrastr}${extra2str}>${data.dispname}</span></li>
				`);

				actionMenuApi.initListview(listview[0]);
			}
			else{
				console.log("listview element not found in addAction post menuInit.");
			}
		}
		else{
			console.log(`category undefined for catid [${catid}]`);
		}
	}
}

function removeAction(dispname, catid){
	actions = actions.filter(action => (action.data.catid == catid && action.data.dispname != dispname));

	if (menuInit){ // remove action from menu
		let category = getCategoryById(catid);
		let listview = $("#" + replaceBreaks(category.catname) + "1 > .mm-listview");

		if (listview.length > 0){			
			listview.children().remove("li[data-dispname='" + dispname + "']");
			actionMenuApi.initListview(listview[0]);
		}
		else{
			console.log("listview not found in removeAction post menuInit");
		}
	}
}

function drawCategories(){ // this should run only once
	for (let i = 0; i < categories.length; i++){
		let category = categories[i];
		let imgFilename = "images/" + category.catname.replace(" ", "").toLowerCase() + ".png";

		menuItemsAnchor.append(`
			<li class="categoryListItem" id="${category.catid}" data-catname="${replaceBreaks(category.catname)}">
				<span class="category-title"><span class="catimage-container" style="background-image:url(${imgFilename})"></span>${category.catname}</span>
				<ul id="${replaceBreaks(category.catname)}1"></ul>
			</li>
		`);
	}
}

function initCategories(){
  for (let i = 0; i < categories.length; i++){
    if (categories[i].hide){
      $(".categoryListItem[data-catname='" + replaceBreaks(categories[i].catname) + "']").hide();
    }
  }
}

function drawActions(){
	// Add all actions except Emotes, which are processed last
	let emotecat = getCategoryById(2);

	for (let i = 0; i < actions.length; i++){
		let action = actions[i];
		let category = getCategoryById(action.catid);

		if (category == null || category == undefined){
			console.log("Aborting category " + catindex);
			continue;
		}

		let catname = category.catname;

		if (catname == emotecat.catname) continue;

		let root = $(".categoryListItem[data-catname='" + replaceBreaks(catname) + "']");

		if (root.length > 0){
			let anchor = root.find("#" + replaceBreaks(catname) + "1");

			if (anchor.length > 0){
				let extrastr = "";
				let extra2str = "";
				
				if (action.data.extra){
					extrastr = ` data-extra="${action.data.extra}"`;
				}

				if (action.data.extra2){
					extra2str = ` data-extra2="${action.data.extra2}"`;
				}

				anchor.append(`
					<li data-dispname="${action.data.dispname}"><span class="amitem" data-resource="${action.data.resname}" data-action="${action.data.action}" data-detect="${action.data.detecttype}"${extrastr}${extra2str}>${action.data.dispname}</span></li>
				`);
			}
			else{
				console.log(`anchor not found in addActionToCategory for category '${catname}' >> data: ${JSON.stringify(data)}`);
			}
		}
		else{
			console.log(`root not found in addActionToCategory for category '${catname}' >> data: ${JSON.stringify(data)}`);
		}
	}

	// Add emote subcategories
	if (emotecat){
		let root = $(".categoryListItem[data-catname='" + replaceBreaks(emotecat.catname) + "']");
		
		if (root.length > 0){
			let anchor = root.find("#" + emotecat.catname + "1");

			if (anchor.length > 0){
				for (let i = 0; i < emotecategories.length; i++){
					let emcat = emotecategories[i];

					anchor.append(`
						<li class="categoryListItem" id="emote_${replaceBreaks(emcat)}" data-catname="emote_${replaceBreaks(emcat)}">
							<span class="catitem">${emcat}</span>
							<ul id="${replaceBreaks(emcat)}2"></ul>
						</li>
					`);
				}
			}
			else{
				console.log("anchor not found for emote category.");
			}
		}
		else{
			console.log("root not found for emote category.");
		}
	}
	else{
		console.log("emote category not found.");
	}

	// add emotes to their respective categories
	let emotes = actions.filter(act => act.catid == emotecat.catid);

	for (let i = 0; i < emotes.length; i++){		
		let emote = emotes[i];

		if (!emote.data.extra2){ // "End Emote" does not have extra2 data
			continue;
		}

		let anchor = $("ul#" + replaceBreaks(emote.data.extra2) + "2");
		let extrastr = "";
		let extra2str = "";
		
		if (emote.data.extra){
			extrastr = ` data-extra="${emote.data.extra}"`;
		}

		if (emote.data.extra2){
			extra2str = ` data-extra2="${emote.data.extra2}"`;
		}

		if (anchor){
			anchor.append(`
				<li data-dispname="${emote.data.dispname}"><span class="amitem" href="#" data-resource="${emote.data.resname}" data-action="${emote.data.action}" data-detect="${emote.data.detecttype}"${extrastr}${extra2str}>${emote.data.dispname}</span></li>
			`);
		}
		else{
			console.log("anchor not found for emote.");
		}
	}

	// Add "End Emote" to top of each subcategory
	$("li[id^='emote_'").each(function(i, el){
		let anchor = $(this).children("ul").first();

		anchor.prepend(`
			<li data-dispname="End Emote"><span class="amitem" href="#" data-resource="emotes" data-action="emote" data-detect="none" data-extra="-1">End Emote</span></li>
		`);
	});
}

function showInputDialog(interactText, actionText, inputActionId, buttonText){
	lastActionId = inputActionId;
	$("#interactText").html(interactText);
	$("#actionText").html(actionText);
	$(".submitbutton").html(buttonText);
	$("#inputDialog").show();
}

function sendData(resource, name, data){
    $.post("http://" + resource + "/" + name, JSON.stringify(data), function(datab) {
        //console.log(datab);
    });
}

function playSound(sound) {
    sendData("actionmenu", "playsound", {name: sound});
}

function stuckTimeout(){
	setTimeout(function(){
		stuckMenuCheck();
		stuckTimeout();
	}, 10000);
}

function stuckMenuCheck(){
	if (!menushowing && $("#amContainer").is(":visible")){
		$("#amContainer").hide();
		sendData("actionmenu", "escape", "");
	}
}