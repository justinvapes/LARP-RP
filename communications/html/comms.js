let resource = "communications";
let contacts = [];
let texts = [];
let blinking = false;
let incall = false;
let backpress = {returnto: null};
let showtbarks = false;
let silentmode = false;
let hidenotifications = false;
let tbarkposition = "bottomRight";
let background = ""
let saveSettingsOnClose = false;
let activecam = 1;
let blockSecondary = false;
let blockSecondaryInput = false;
let blockSelfiePost = false;
let lastPhoneModel = "Default Black";
let cellPropHash;
let lastEmails = [];
let lastReadingEmail = 0;
let contactEditMode = false;
let lastEditingContact = {name: "", number: "", email: ""};
let forceCompose = {active: false, emailAddress: ""};
let myDetails = {charName: "", phoneNumber: "", emailAddress: ""};
let lastAdverts = [];
let ypAdCost = 7500;

$(function(){
	window.addEventListener("message", function(item){
		var data = item.data;

		if (data.showPhone){
			var pvis = $("#phoneContainer").is(":visible");

			if (pvis){
				$("#phoneContainer").slideToggle("fast");
				$(".selfieOverlayPanel").hide();
				//$("#phoneContainer").hide();
				$(".textnotify").unblink();
				$(".emailNotify").unblink();
				blinking = false;
        sendData2(resource, "bms:comms:phones:phoneshowing", {showing: false});
        sendData2(resource, "bms:toggleNui", false);

				if (saveSettingsOnClose){
					saveSettingsOnClose = false;
					savePhoneSettings();
				}
			}
			else{
				$("#phoneContainer").slideToggle("fast");
				//$("#phoneContainer").show();
				$(".textnotify").unblink();
				$(".emailNotify").unblink();
				blinking = false;
        sendData2(resource, "bms:comms:phones:phoneshowing", {showing: true});
        sendData2(resource, "bms:toggleNui", true);
      }
      
      if ($(".paypal").is(":visible")) {
        sendData2(resource, "bms:comms:paypalgetbal", "");
			}
			
			blockSecondaryInput = false;
		}
		else if (data.togglePhoneOverlay){
			if (data.val === true){
				$("#phoneContainer").slideDown("fast");
			}
			else{
				$("#phoneContainer").slideUp("fast");
			}
		}
		else if (data.loadContacts){
			var cont = data.contacts;
			contacts = cont;
			renderContacts(cont);
			blockSecondary = false;
		}
		else if (data.setNotify){
			notify(data.text);
		}
		else if (data.openCallStatus){
			var source = data.source;
			var number = data.num;
			var ctype = data.type;

			openCallStatus(source, number, ctype);
		}
		else if (data.openCallStatusInCall){
			var call = data.call;
			var part = data.part;

			openCallStatusInCall(call, part);
		}
		else if (data.closeCallStatus){
			$(".callstatus").hide();
			$(".contactlist").show();
			$(".controlbar").show();
		}
		else if (data.setInCall){
			incall = data.incall;

			if ($(".homescreen").is(":visible")){
				if (incall){
					$(".callstatus_ret").show();
				}
				else{
					$(".callstatus_ret").hide();
				}
			}
		}
		else if (data.addTextFrom){
			var num = data.number;
			var msg = data.message;
			
			if (num && msg){
				addTextTo(num, 1, msg);
			}
		}
		else if (data.setTime){
			$(".clock").html(data.time);
		}
		else if (data.setWeather){
			changeWeather(data.windex, data.nindex);
		}
		else if (data.unblockPaypal){
			$(".pp-recipient").prop("disabled", null);
			$(".pp-amount").prop("disabled", null);
			$(".pp-sendfunds").prop("disabled", null);
			$(".pp-recipient").val("");
			$(".pp-amount").val("");
		}
		else if (data.setPaypalBalance){
			let bal = data.balance;

			$(".pp-moneydisp").html("$" + bal.toLocaleString());
		}
		else if (data.setPaypalTransHistory){
			var trans = data.transfers;

			if (trans){
				renderPaypalTransHistory(trans);
			}
		}
		else if (data.addTweet){
			if (data.msg){
				addTweet(data);
			}
		}
		else if (data.loadPhoneSettings){			
			if (data.settings){
				showtbarks = data.settings.twitterbark;
				silentmode = data.settings.silentmode;
				hidenotifications = data.settings.hidenotifications;
				background = data.settings.background;
				tbarkposition = data.settings.tbarkposition;
				$(".settings-twitter-showbarks").prop("checked", showtbarks);
				$(".settings-silentmode").prop("checked", silentmode);
				$(".settings-hidenotifications").prop("checked", hidenotifications);
				$(".twitter-barkposition > .barkposition-select > option[value='" + tbarkposition + "']").attr("selected", "selected");
				$(".theme-selection > .theme > option[value='" + background + "']").attr("selected", "selected");

				let fname = $(".theme-selection > .theme > option[value='" + background + "']").data("filename");

				$(".homescreen").css("background-image", "url(backgrounds/" + fname + ")");
			}
		}
		else if (data.toggleGpsPin){
			togglePin(data.toggle);
		}
		else if (data.moveGpsPin){
			if (data.coords){
				moveGpsPin(data.coords);
			}
		}
		else if (data.unblockTowReq){
			$(".btnContactMechanic").removeClass("disabled");
		}
		else if (data.updateCarmaxData){
			updateCarmaxData(data.modinfo, data.price, data.model);
			hideAllPanels();
			$(".vehiclesellinfo").fadeIn();
		}
		else if (data.updateDealerLogs){
			hideAllPanels();
			updateDealerLogs(data.logdata);
			$(".dealerSellLogs").fadeIn();
			$(".btnShowLogs").prop("disabled", false);
		}
		else if (data.unblockVehPurchase){
			$(".cm-purchasevehicle").prop("disabled", false);
			hideAllPanels(true);
		}
		else if (data.unblockLogs){
      $(".btnShowLogs").prop("disabled", false);
		}
		else if (data.showCameraSystem){
			activecam = 1;
			updateCameras(data.cameras);
			selectCam(1);
		}
		else if (data.hideCameraSystem){
			$(".cameraSystemContainer").fadeOut();
		}
		else if (data.camSystemNav){
			cameraNavigate(data.dir);
		}
		else if (data.setPnDisplay){
			myDetails.phoneNumber = data.phoneNumber;
			myDetails.emailAddress = data.emailAddress;
			myDetails.charName = data.charName;
			$(".phnum-display").html(data.phoneNumber);
			$(".ypListing.preview").find(".ypListing-name").html(data.charName);
			$(".ypListing.preview").find(".ypListing-number").html(data.phoneNumber);
			$(".ypListing.preview").find(".ypListing-email").html(data.emailAddress);
    }
    else if (data.updateCancelMessage){
      if (data.msg){
        notify(data.msg);
        setTimeout(() => {
          $(".e911cancelservices").prop("disabled", "false");
          $(".e911cancelservices").removeClass("disabled");
        }, 5000);

        if (data.cleared){
          $("#e911emergency_input").val("");
          $("#e911emergency_input").show();
          $(".e911reqservices").show();
        }
      }
		}
		else if (data.updateCallHistory){
			updateCallHistory(data.callhistory);
		}
		else if (data.showTransactionHistory){
			blockSecondary = false;
			renderTransactionHistory(data.logs, data.listing, data.balance);
		}
		else if (data.selfieModeToggle){
			selfieModeToggle(data.val);
		}
		else if (data.toggleSelfiePhoneReturn){
			let panel = $(".selfiePhoneReturnPanel");
			data.val ? panel.stop().fadeIn() : panel.stop().fadeOut();
		}
		else if (data.setFilterInfo){
			let text = $(".ucam-activeFilter");
			let strength = $(".ucam-activeFilterStrength");

			if (data.filterName){
				text.html(data.filterName);
			}

			if (data.filterStrength){
				strength.html(data.filterStrength.toFixed(2));
			}
		}
		else if (data.togglePhoneInfo){
			data.toggle === true ? $(".browsePhoneInfo").stop().fadeIn() : $(".browsePhoneInfo").stop().fadeOut();
		}
		else if (data.setCurrentPhone){
			$(".currentPhone").html(data.text);
		}
		else if (data.setCellPropHash){
			cellPropHash = data.hash;
		}
		else if (data.showBuyDialog){
			alertify.defaults.theme.ok = "btn btn-danger";
			alertify.defaults.theme.cancel = "btn btn-dark";
			alertify.confirm("Purchase phone?", `Click Purchase to buy the ${data.desc} for $${data.price}.`, function(e){
				sendData("bms:comms:phoneStore:confirmBuy", "");
			}, function(){
				sendData("bms:comms:phoneStore:cancelBuy", "");
			}).set({
				labels:{
					ok: "Purchase",
					cancel: "Cancel"
				},
				delay: 5000,
				buttonReverse: false,
				buttonFocus: "ok",
				transition: "fade"
			});
		}
		else if (data.setPhoneModel){
			lastPhoneModel = data.model || "None";
			$(".lastPhone").html(lastPhoneModel);
		}
		else if (data.loadUserEmails){
			lastEmails = data.emails;
			renderUserEmails(data.emails, data.forceEmailView);
		}
		else if (data.deleteEmail){
			if (data.emailId){
				deleteEmail(data.emailId);
			}
		}
		else if (data.toggleSendEmailFields){
			$("#emailSendTo").prop("disabled", !data.toggle);
			$("#emailSubject").prop("disabled", !data.toggle);
			$("#emailBody").prop("disabled", !data.toggle);

			if (data.clear){
				clearEmailComposeFields();
			}

			if (data.hideEmailCompose){
				$(".emailCompose").hide();
				$(".emailsList").show();
			}
		}
		else if (data.blinkEmailNotify){
			blinkEmailNotify();
		}
		else if (data.updateAdverts){
			let lastCat = parseInt($("#ypViewCatSelector").data("selcatid") || 3);

			lastAdverts = data.adverts;
			ypAdCost = data.adCost;
			$(".ypAdCost").html(`Cost for ad: $${ypAdCost}`);
			renderYpAdverts(lastAdverts, lastCat);
		}
		else if (data.toggleYpBlocker){
			toggleYpBlocker(data.toggle);
		}
		else if (data.clearYpFields){
			$(".ypNewListing").stop().slideUp();
			$("#ypNewListing-Text").val("");
			$(".ypListing.preview").find(".ypListing-text").html("");
		}
	});
	
	var sentEvents = false;

	$(document).on("keydown", function(e){
		//if (!sentEvents){
      if (e.keyCode == 192 && !blockSecondaryInput){ // `
        sendData2(resource, "bms:toggleNui", false);
        sentEvents = true;
			}
			else if (e.keyCode == 113 && !$(".textmessage_input").is(":focus")){ // F2
        if ($("#phoneContainer").is(":visible")) {
          //$("#phoneContainer").hide();
					$("#phoneContainer").slideToggle("fast");
					sendData2(resource, "bms:comms:phones:phoneshowing", {showing: false});
          sendData2(resource, "bms:toggleNui", false);
          sentEvents = true;

          if (saveSettingsOnClose){
            saveSettingsOnClose = false;
            savePhoneSettings();
					}
					
					if ($(".selfiePanel").is(":visible")){
						hideAllPanels(true);
						sendData("bms:comms:phone:cancelSelfie", "");
					}
        } else {
					if (cellPropHash !== undefined && cellPropHash != 0){
          	$("#phoneContainer").slideToggle("fast");
					}

          sendData2(resource, "bms:comms:phones:phoneshowing", {showing: true});
          sentEvents = true;
        }
			}
			else if (e.keyCode == 27){
				$(":focus").blur();
			}
		//}
	});

	$(document).on("keyup", function(e){
		shiftDown = e.shiftKey;
		sentEvents = false;
	});

	$(document).on("click", ".addicon", function(){
    let cvisible = $(".addcontact").is(":visible");

		if (!cvisible){
			$("#addcon_name").val("");
      $("#addcon_number").val("");
			$("#addcon_email").val("");
		}

		cvisible ? $(".addcontact").stop().fadeOut() : $(".addcontact").stop().fadeIn();
  });
  
  $(document).on("click", ".remicon", function(){
		let contact = $(".contact.selected");

		if (contact.length > 0){
			let name = contact.find(".contact.name").text();
			let number = contact.find(".contact.number").html();

			showPhoneDialog(`Do you want to remove contact?<br>Name: ${name}, Number: ${number}`, 
				function(){
					console.log(`Removing contact, name: ${name}, number: ${number}`);

					sendData2(resource, "bms:comms:phone:removecontact", {name: name, number: number});
					contact.remove();
				}
			);
		}
		else{
			notify("You must select a contact first.");
		}
  });

	$(document).on("click", ".editicon", function(){
		let contact = $(".contact.selected");

		if (contact.length > 0){
			let nameField = contact.find(".contact.name");
			let numberField = contact.find(".contact.number");
			let emailField = contact.find(".contact.email");
			
			lastEditingContact.name = nameField.html();
			lastEditingContact.number = numberField.html();
			lastEditingContact.email = emailField.html();
			$("#addcon_name").val(nameField.html());
			$("#addcon_number").val(numberField.html());
			$("#addcon_email").val(emailField.html());
			$(".addcontact").stop().fadeIn();
			contactEditMode = true;
		}
	});
  
  $(document).on("click", ".doadd_button", function(){		
		let name = $("#addcon_name").val();
		let number = $("#addcon_number").val();
		let email = $("#addcon_email").val();		
		let formats = "999-999-9999";
		let r = RegExp("^(" + formats
										.replace(/([\(\)])/g, "\\$1")
										.replace(/9/g,"\\d") +
									")$");
		let pass = r.test(number);

		if (email && email.length > 0 && name && name.length > 0){
			if (number && number.length > 0){
				pass = r.test(number);
			}
			else{
				pass = true;
			}
		}

		if (!pass){
			notify("The phone number format is incorrect.  Use format xxx-xxx-xxxx.");
		}
		else{
			if (contactEditMode){
				if (name.length == 0){
					notify("You must enter a contact name.");
				}
				else{
					if (contactExists(name)){
						notify("A contact with that name already exists.");
						return;
					}

					$(".addcontact").stop().fadeOut();
					sendData2(resource, "bms:comms:phone:editContact", {lastEditingContact: lastEditingContact, newContact: {name: name, number: number, email: email}});
					contactEditMode = false;
				}
				return;
			}

			if (contactExists(name)){
				notify("A contact with that name already exists.")
			}
			else if (name.length == 0){
				notify("You must enter a contact name.");
			}
			else{
        $(".addcontact").stop().fadeOut();
				sendData2(resource, "bms:comms:phone:addcontact", {name: name, number: number, email: email});
			}
		}
  });

  $(document).on("click", ".cancel_button", function(){
    if ($(".addcontact").is(":visible")){
      $(".addcontact").fadeOut("slow");
    }
  });
  
  $(document).on("click", ".contact", function(){
		$(".contact").removeClass("selected");
		$(this).addClass("selected");
  });
  
  $(document).on("click", ".text_backbutton", function(){
    showContactList(true);
  });
	
	$(document).on("click", ".callicon", function(){
		let blocked = $(this).parent().find(".blockperson").hasClass("active");
		let name = $(this).closest(".contact").find(".contact.name").html();
		let number = $(this).closest(".contact").find(".contact.number").html();

		if (blocked){
			notify("You can not call numbers that you have blocked.");
			return;
		}

    if (name && number) {
      sendData2(resource, "bms:comms:phone:callperson", {name: name, number: number});
    }
	});

	$(document).on("click", ".textperson", function(){
		let blocked = $(this).parent().find(".blockperson").hasClass("active");
		let name = $(this).closest(".contact").find(".contact.name").html();
		let number = $(this).closest(".contact").find(".contact.number").html();

		if (blocked){
			notify("You can not text numbers that you have blocked.");
			return;
		}

		if (name && number){
			hideAllPanels();
			loadTexts(name, number);
			$(".textcenter").show();
			$("#textnumber_generic").data("number", number);
			$(this).removeClass("notify");
		}
		else{
			console.log("comms.js >> name or number was invalid.");
		}
	});

	$(document).on("click", ".blockperson", function(){
		if (blockSecondary) return;

		blockSecondary = true;
		let blocked = $(this).hasClass("active");
		let name = $(this).closest(".contact").find(".contact.name").html();
		let number = $(this).closest(".contact").find(".contact.number").html();

		sendData2(resource, "bms:comms:phone:blockperson", {block: !blocked, name: name, number: number});
	});

	$(document).on("click", ".emailicon", function(){
		let emailAddress = $(this).closest(".contact").find(".contact.email").html();

		if (emailAddress.length > 0){
			$(".hsicon_emails").trigger("click");
			forceCompose.active = true;
			forceCompose.emailAddress = emailAddress;
			
			let watchInterval = setInterval(function(){ // Wait for div to become visible since we can't trigger on invisible elements.
				if ($(".emailMaster").is(":visible")){
					$(".btnComposeEmail").trigger("click");
					clearInterval(watchInterval);
				}
			}, 100);
		}
	});

	$(document).on("keyup", ".textmessage_input", function(e){
		var keycode = e.keyCode ? e.keyCode : e.which;
		
		if (keycode == 13){
			var msg = $(".textmessage_input").val();
			
			if (msg.length > 0){
				msg = sanitizeHTML(msg);
				msg = msg.replace(/\r\n|\r|\n/g, "<br/>");

				var tonum = $("#textnumber_generic").html();

				if (!validPhoneNum(tonum)){
					tonum = $("#textnumber_generic").data("number");
				}

				addTextTo(tonum, 2, msg);
				$(".textmessage_input").val("");
				sendData2(resource, "bms:comms:phone:textperson", {number: tonum, msg: msg});
			}
		}
	});

	$(document).on("click", ".hsicon_contacts", function(){
		showContactList(true);
	});

	$(document).on("click", ".hsicon_weather", function(){
		hideAllPanels();
		$(".weathercenter").show();
	});

	$(document).on("click", ".hsicon_e911", function(){
		hideAllPanels();
		$(".e911").show();
	});

	$(document).on("click", ".hsicon_paypal", function(){
		hideAllPanels();
		sendData2(resource, "bms:comms:paypalgetbal", "");
		$(".paypal").show();
	});
	
	$(document).on("click", ".hsicon_notepad", function(){
		hideAllPanels();
		$(".notepad").show();
	});
	
	$(document).on("click", ".hsicon_settings", function(){
		hideAllPanels();
		$(".settings").show();
	});
	
	$(document).on("click", ".hsicon_calculator", function(){
		hideAllPanels();
		$(".calculator").show();
	});

	$(document).on("click", ".hsicon_tweeter", function(){
		hideAllPanels();
		$(".twitter").show();
	});

	$(document).on("click", ".hsicon_gps", function(){
		hideAllPanels();
		$(".gps").show();
	});

	$(document).on("click", ".hsicon_mechanic", function(){
		hideAllPanels();
		$(".mechanic").show();
	});

	$(document).on("click", ".hsicon_callhistory", function(){
		hideAllPanels();
		$(".padDialer").show();
	});

	$(document).on("click", ".hsicon_transactionhistory", function(){
		hideAllPanels();
		$(".bankAccountTransactionLogs").stop().fadeIn();
		
		if (blockSecondary) return;

		blockSecondary = true;
		sendData("bms:comms:getBankAccountTransactionHistory", {listing: true});
	});

	$(document).on("click", ".hsicon_selfie", function(){
		hideAllPanels();
		sendData("bms:comms:phone:selfieToggle", {val: true});
		blockSecondaryInput = true;
	});

	$(document).on("click", ".hsicon_emails", function(){
		if (blockSecondary) return;
		
		hideAllPanels();
		sendData("bms:comms:phone:getPhoneEmails", {showEmailsOnComplete: true});
		blockSecondary = true;
	});

	$(document).on("click", ".hsicon_yellowpages", function(){
		if (blockSecondary) return;
		
		hideAllPanels();
		$(".yellowPagesMaster").stop().fadeIn();
	});

	$(document).on("keyup", ".twitter-input-text", function(e){
		let keycode = e.keyCode ? e.keyCode : e.which;

		if (keycode == 13){
			let msg = $(".twitter-input-text").val();

			if (msg.length > 0){
				msg = msg.replace("<", "&lt;");
				msg = msg.replace(">", "&gt;");
				msg = msg.replace(/\r\n|\r|\n/g, "<br/>");

				sendData2(resource, "bms:comms:sendTweet", {msg: msg});
				$(".twitter-input-text").val("");
			}
		}
	});

	$(document).on("click", ".settings-twitter-showbarks", function(){
		saveSettingsOnClose = true;
	});

	$(document).on("click", ".settings-silentmode", function(){
		saveSettingsOnClose = true;
	});

	$(document).on("click", ".settings-hidenotifications", function(){
		saveSettingsOnClose = true;
	})
	
	$("select.theme").change(function(){
    saveSettingsOnClose = true;

		let option = $(this).children("option:selected");
		let selectedTheme = option.val();
		let selectedFile = option.data("filename");
		
		background = selectedTheme;

		$(".homescreen").css("background-image", "url(backgrounds/" + selectedFile + ")");
	});

	$(".barkposition-select").change(function(){
		saveSettingsOnClose = true;

		let option = $(this).children("option:selected");
		let selectedPos = option.val();

		tbarkposition = selectedPos;
	});

	$(document).ready(function(){
		var displayValue = '0';

		$('#result').text(displayValue);
		$('.key').each(function(index, key){       
			$(this).click(function(e){
				if(displayValue == '0') displayValue = '';

				if ($(this).text() == 'C'){
						displayValue = '0';
						$('#result').text(displayValue);
				}
				else if($(this).text() == '='){
					try
					{
						displayValue = eval(displayValue);
						$('#result').text(displayValue);
						displayValue = '0';
					}
					catch (e)
					{
						displayValue = '0';
						$('#result').text('ERROR');
					}               
				}
				else
				{
					displayValue += $(this).text();
					$('#result').text(displayValue);
				}

				e.preventDefault();
			});
		});
	});

	$(document).on("click", ".answer", function(){
		if (incall && $(".homescreen").is(":visible")){
			$(".callstatus").show();
		}
		else{
			sendData2(resource, "bms:comms:phone:answercall", "");
		}
	});

	$(document).on("click", ".cancel", function(){
    sendData2(resource, "bms:comms:phone:cancelcall", "");
    console.log("cancelling call...")
		hideAllPanels();
		$(".contactlist").show();
		$(".controlbar").show();
	});
  
  $(document).on("click", ".homebutton", function(){
		hideAllPanels();

		if (backpress.returnto){
			$(backpress.returnto).show();
			backpress.returnto = null;
		}
		else{
			$(".homescreen").show();

			if (incall){
				$(".callstatus_ret").show();
			}
			else{
				$(".callstatus_ret").hide();
			}
		}
	});
	
  $(document).on("mouseenter", ".remicon", function(){
    $(".remicon.image").attr("class", "remicon image hover");
  });
  
  $(document).on("mouseleave", ".remicon", function(){
    $(".remicon.image").attr("class", "remicon image");
  });
  
  $(document).on("mouseenter", ".addicon", function(){
    $(".addicon.image").attr("class", "addicon image hover");
  });
  
  $(document).on("mouseleave", ".addicon", function(){
    $(".addicon.image").attr("class", "addicon image");
	});
	
	$(document).on("click", ".e911reqservices", function(){
		let eminput = $("#e911emergency_input").val();

		if (eminput.length > 0){
			sendData2(resource, "bms:comms:e911request", {emdetails: eminput});
			$("#e911emergency_input").hide();
			$(".e911reqservices").hide();
			$("#e911emergency_input").val("");
      $("#reqnotify").show();
      $("#cancelnotify").hide();
		}
		else{
			console.log("eminput length was 0");
		}
  });
  
  $(document).on("click", ".e911cancelservices", function(){
    if (!$(".e911cancelservices").hasClass("disabled")){
      $(this).prop("disabled", "true");
      $(".e911cancelservices").addClass("disabled");
      sendData2(resource, "bms:comms:e911attemptCancel", {cancel: true});
      $("#reqnotify").hide();
    }
	});

	$(document).on("click", ".e911display-toggle", function(){
		$(".e911display").is(":visible") ? $(".e911display").hide() : $(".e911display").show();
	});

	$(".pp-sendfunds").click(function(){
		let sname = $(".pp-recipient").val();
		let sval = parseInt($(".pp-amount").val());

		if (sname == "" || isNaN(sval) || sval <= 0){
			notify("You must enter a positive name and dollar amount.");
		}
		else{
			$(".pp-recipient").prop("disabled", "true");
			$(".pp-amount").prop("disabled", "true");
			$(this).prop("disabled", "true");
			sendData2(resource, "bms:comms:paypalsend", {name: sname, amount: sval});
		}
	});

	$(".pp-btranshistory").click(function(){
		hideAllPanels();
		$(".paypal-transhistory").show();
		backpress.returnto = ".paypal";
	});

	$(document).on("click", ".gps-lojack-toggle", function(){
		let cont = $(".gps-lojack-container");
		let vis = cont.is(":visible");

		vis ? cont.fadeOut() : cont.fadeIn();
	});

	$(document).on("click", ".gps-lojack-untrack", function(){
		sendData2(resource, "bms:comms:deactivateLojack", "");
	});

	$(document).on("click", ".lojack-selplate-btn", function(){
		let plate = $("#lojack-plate").val();

		if (plate.length > 0){
			plate = plate.toLowerCase();
			sendData2(resource, "bms:comms:activateLojack", {plate: plate});
			$("#lojack-plate").val("");
			$(".gps-lojack-container").fadeOut();
		}
	});

	$(document).on("click", ".btnContactMechanic", function(){
		if (!$(".btnContactMechanic").hasClass("disabled")){
			$(".btnContactMechanic").removeClass("disabled").addClass("disabled");
			notify("A mechanic will be contacted with your location if one is available.");
			sendData2(resource, "bms:comms:contactMechanic", "");
		}
	});

	$(document).on("click", ".cm-purchasevehicle", function(){
		$(this).prop("disabled", true);
		sendData("bms:comms:carmaxPurchaseVehicle", "");
	});

	$(document).on("click", ".ds-clearlogs", function(){
		sendData("bms:comms:clearCarDealerLogs", "");
		$(".dsLogEntries").children().remove();
		hideAllPanels(true);
	});

	$(document).on("click", ".camsysCameraItem", function(){
		let cid = parseInt($(this).data("cid"));

		$(".camsysCameraItem").removeClass("selected");
		$(this).addClass("selected");
		selectCam(cid);
	});

	$(document).on("click", ".btnAccountHistorySelection", function(){
		if (blockSecondary) return;
		
		blockSecondary = true;

		let accountid = parseInt($(this).data("id"));

		if (accountid){
			sendData("bms:comms:getBankAccountTransactionHistory", {accountid: accountid});
		}
		else{
			notify("An error occured selecting the account.");
		}
	});

	$(".btnUcamPrevFilter").click(function(){
		sendData("bms:comms:phone:ucamPrevFilter", "");
	});

	$(".btnUcamNextFilter").click(function(){
		sendData("bms:comms:phone:ucamNextFilter", "");
	});

	$(".btnUcamIncStrength").click(function(){
		sendData("bms:comms:phone:ucamIncStrength", "");
	});

	$(".btnUcamDecStrength").click(function(){
		sendData("bms:comms:phone:ucamDecStrength", "");
	});

	$(".btnUcamHidePhone").click(function(){
		sendData("bms:comms:phone:ucamTogglePhoneOverlay", {show: false});
	});

	$(".btnUcamDecZoom").mousedown(function(){
		sendData("bms:comms:phone:ucamToggleZoom", {increase: false});
	});

	$(".btnUcamDecZoom").on("mouseup mouseleave", function(){
		sendData("bms:comms:phone:ucamToggleZoom", {mouseup: true});
	});

	$(".btnUcamIncZoom").mousedown(function(){
		sendData("bms:comms:phone:ucamToggleZoom", {increase: true});
	});

	$(".btnUcamIncZoom").on("mouseup mouseleave", function(){
		sendData("bms:comms:phone:ucamToggleZoom", {mouseup: true});
	});

	$(".selfiePhoneReturnPanel").click(function(){
		$(this).stop().fadeOut();
		sendData("bms:comms:phone:ucamTogglePhoneOverlay", {show: true});
	});

	$(".btnSnapSelfie").click(function(){
		if (blockSelfiePost){
			notify("You must wait a little bit before uploading another selfie to the board.");
			return;
		}

		blockSelfiePost = true;
		sendData("bms:comms:phone:ucamSnapPhoto", {snaptype: parseInt($(this).data("snaptype")), title: $("#inputSnapSelfieTitle").val()});
		setTimeout(function(){
			blockSelfiePost = false;
		}, 30000);
	});

	$(".btnSelfieOverlay").click(function(){
		changeSelfieOverlay($(this).data("image"), $(this).data("size"), $(this).data("position"));
	});

	$(".dialerDigit").on("click", function(){
		if ($(".dialerOutputText").length < 10){
			let digit = $(this).data("val");

			if (parseInt(digit) != "NaN" && $(".dialerOutputText").text().length < 10){
				$(".dialerOutputText").append(digit);
			}
		}
	});

	$(".dialerOutputBack").on("click", function(){
		let oText = $(".dialerOutputText").text();
		
		if (oText.length > 0){
			if (oText.length == 1){
				$(".dialerOutputText").text("");
			}

			$(".dialerOutputText").text(oText.slice(0, -1));
		}
	});

	$(".dialerCall").on("click", function(){
		let number = $(".dialerOutputText");

		if (number.text() == "911"){
			$(".hsicon_e911").trigger("click");
			number.text("");
		}
		else if (number.text().length == 10){
			sendData2(resource, "bms:comms:phone:callperson", {number: number.text()});
		}
	});

	$(".dialerHistory").on("click", function(){
		hideAllPanels();
		$(".phoneHistoryLogs").show();
	});

	$(document).on("click", ".emailRow", function(){
		let emailId = parseInt($(this).data("emailid"));

		renderUserEmailBody(emailId);
	});

	$("#emailBody").on("input propertychange", function(){
    let max = 1024;
    let val = $(this).val().length;
    
    $(".smlEmailBodyCount").html(max - val);
  });

	$(".btnSendEmail").on("click", function(){
		let emSendToAddress = $("#emailSendTo").val();
		let emSubject = $("#emailSubject").val();
		let emBody = $("#emailBody").val();

		if (emSendToAddress && emSubject && emSubject.length <= 200 && emBody && emBody.length <= 2000){
			$("#emailSubject").prop("disabled", true);
			$("#emailBody").prop("disabled", true);
			$(".btnSendEmail").prop("disabled", true);
			sendData("bms:comms:sendEmail", {emSendToAddress: emSendToAddress, emSubject: emSubject, emBody: emBody});
		}
		else{
			if (emSendToAddress && emSubject && emBody){
				if (emSubject.length > 200){
					notify("You have exceeded max characters for the subject.");
				}
				else if (emBody.length > 2000){
					notify("You have exceeded max characters for the email.");
				}
			}
			else{
				notify("You must enter some text in all of the fields.");
			}
		}
	});

	$(".btnEmailViewBack").on("click", function(){
		lastReadingEmail = 0;
		$(".emailView").hide();
		$(".emailsList").stop().fadeIn();
	});

	$(".btnEmailViewDelete").on("click", function(){
		if (blockSecondary || lastReadingEmail == 0) return;

		blockSecondary = true;
		sendData("bms:comms:phone:emailDelete", {emailId: lastReadingEmail});
	});

	$(".btnEmailViewReply").on("click", function(){
		let email = lastEmails.filter(email => email.id == lastReadingEmail)[0];

		if (email){
			let emailAddress = email.senderEmailAddress;

			$("#emailSendTo").val(emailAddress);
			$(".emailsViewOrCompose").html("Replying");
			$(".emailsList").stop().hide();
			$(".emailView").stop().hide();
			$(".emailsCompose").stop().fadeIn();
		}
		else{
			console.log(".btnEmailViewReply >> email was null");
		}
	});

	$(".btnComposeEmail").on("click", function(){
		if (forceCompose.active){
			forceCompose.active = false;
			$("#emailSendTo").val(forceCompose.emailAddress);
			$(".emailsList").hide();
			$(".emailsCompose").stop().fadeIn();
			$(".emailViewOrCompose").html("Composing Email");
			return;
		}
		
		let composing = $(".emailsCompose").is(":visible");

		$("#emailSendTo").val(""); // clear in case reply populated it

		composing ? $(".emailsCompose").hide() : $(".emailsCompose").stop().fadeIn();
		composing ? $(".emailsList").stop().fadeIn() : $(".emailsList").hide();
		composing ? $(".emailViewOrCompose").html("Email Inbox") : $(".emailViewOrCompose").html("Composing Email");
	});

	$("#ypNewListing-Text").on("input propertychange", function(){
    let max = 600;
    let val = $(this).val().length;
		let rem = max - val;

		let breaks = ($(this).val().match(new RegExp(/\r\n|\r|\n/, "g")) || []).length;

		rem = rem - (breaks * 50);
		
		if (rem < 0) rem = 0;
    
    $("#labelYpTextLength").html(`Enter your Ad Text (${rem} chars remaining)`);

		if (val > max){
			notify(`You went over the maximum of ${max} characters.`);
			return;
		}

		let fieldVal = $("#ypNewListing-Text").val();
		let newText = "";

		if (fieldVal.match("<script>") || fieldVal.match("</script>")){
			newText = fieldVal.replace("<script>", "(don't be an idiot)");
			newText = fieldVal.replace("</script>", "(don't be an idiot)");
			$("#ypNewListing-Text").val(newText);
		}

		newText = colorizeByTokens(pruneTextToLength(fieldVal, 120));
    
    $(".ypListing.preview").find(".ypListing-text").html(newText);
  });
  
  $("#ypNewListing-showNumber").on("change", function(){
    let checked = $(this).is(":checked");
    
    checked ? $(".ypListing.preview").find(".ypListing-number").html(myDetails.phoneNumber) : $(".ypListing.preview").find(".ypListing-number").html("");
  });
  
  $("#ypNewListing-showEmail").on("change", function(){
    let checked = $(this).is(":checked");
		
    checked ? $(".ypListing.preview").find(".ypListing-email").html(myDetails.emailAddress) : $(".ypListing.preview").find(".ypListing-email").html("");
  });

	$(".ypAddListing").on("click", function(){
		$(".ypNewListing").stop().slideDown();
	});

	$(".ypCancelAdvert").on("click", function(){
		$(".ypNewListing").stop().slideUp();
	});

	$(".ypPostAdvert").on("click", function(){
		let text = $("#ypNewListing-Text").val();
		let showNumber = $("#ypNewListing-showNumber").is(":checked");
		let showEmail = $("#ypNewListing-showEmail").is(":checked");
		let categoryText = $("#ypCatSelector").html();
		let flag = 2;

		if (categoryText === undefined || categoryText.includes("Select a Category")){
			notify("You must select an advert category.");
			return;
		}

		if (showNumber === false && showEmail === false){
			notify("You must choose to show either your number, email or both.");
			return;
		}

		let category = parseInt($("#ypCatSelector").data("selcatid"));

		if (showNumber && !showEmail){
			flag = 0;
		}
		else if (showEmail && !showNumber){
			flag = 1;
		}

		if (text.length < 20){
			notify("Enter more than 20 characters in the advert text.  Make it descriptive.");
			return;
		}
		text = text.replace("<script>", "");
		text = text.replace("</script>", "");
		toggleYpBlocker(true);
		sendData("bms:comms:phone:ypPostNewAdvert", {flag: flag, text: stripUnicode(text), category: category});
	});

	$(".yp-dropDown-item").on("click", function(){
		$("#ypCatSelector").html($(this).html());
		$("#ypCatSelector").data("selcatid", $(this).data("catid"));
	});

	$(".yp-viewCatDropDown-item").on("click", function(){
		$("#ypViewCatSelector").html($(this).html());
		$("#ypViewCatSelector").data("selcatid", $(this).data("catid"));

		renderYpAdverts(lastAdverts, parseInt($("#ypViewCatSelector").data("selcatid")));
	});

	$(document).on("click", ".ypCallPerson", function(e){
		e.stopPropagation();
		
		let name = $(this).data("cname");
		let phNum = $(this).data("phonenumber");

		if (phNum === undefined || name === undefined){
			console.log("phonenumber data field not found.");
			return;
		}

		sendData2(resource, "bms:comms:phone:callperson", {name: name, number: phNum});
	});

	$(document).on("click", ".ypEmailPerson", function(e){
		e.stopPropagation();

		let name = $(this).data("cname");
		let emailAddress = $(this).data("emailaddress");

		if (emailAddress.length == 0 || name.length == 0){
			console.log("emailaddress data field not found.");
			return;
		}

		hideAllPanels();
		$(".hsicon_emails").trigger("click");
		forceCompose.active = true;
		forceCompose.emailAddress = emailAddress;
		
		let watchInterval = setInterval(function(){ // Wait for div to become visible since we can't trigger on invisible elements.
			if ($(".emailMaster").is(":visible")){
				$(".btnComposeEmail").trigger("click");
				clearInterval(watchInterval);
			}
		}, 100);
	});

	$(document).on("click", ".ypListing", function(){
		loadYpListingToView(parseInt($(this).data("id")));
	});

	$(".ypViewListingBack").on("click", function(){
		$(".ypViewListing").stop().fadeOut();
	});

	$(document).on("click", ".ypDeleteAdvert", function(e){
		e.stopPropagation();
		
		let advertId = parseInt($(this).data("id"));
		let listing = $(".ypListing[data-id='" + advertId + "']");

		showPhoneDialog("Do you want to delete this advert?",
			function(){
				if (listing.length > 0){
					listing.remove();
					sendData("bms:comms:phone:ypDeleteAdvert", {advertId: advertId});
				}
				else{
					console.log("Could not find listing by id.");
				}
			}
		);
	});
});

let sanitizeHTML = function (str) {
	return str.replace(/[^\w. ]/gi, function (c) {
		return '&#' + c.charCodeAt(0) + ';';
	});
};

String.prototype.stripSlashes = function(){
	return this.replace(/\\(.)/mg, "$1");
}

function validPhoneNum(str){
	var formats = "999-999-9999";
	var r = RegExp("^(" + formats
									.replace(/([\(\)])/g, "\\$1")
									.replace(/9/g,"\\d") +
								")$");
	return r.test(str);
}

function stripUnicode(inStr){
	return inStr.replace(/[^\x00-\x7F]/g, "");
}

function formatPhoneNumber(num){
	let numv = num.replace(/\D[^\.]/g, "");
	return numv.slice(0,3) + "-" + numv.slice(3,6) + "-" + numv.slice(6);
}

function colorizeByTokens(str){
	let s = "<span>" + (str.replace(/\^([0-9])/g, (str, color) => `</span><span class="color-${color}">`)) + "</span>";

	const styleDict = {
		'*': 'font-weight: bold;',
		'_': 'text-decoration: underline;',
		'~': 'text-decoration: line-through;',
		'=': 'text-decoration: underline line-through;',
		'r': 'text-decoration: none;font-weight: normal;',
	};

	const styleRegex = /\^(\_|\*|\=|\~|\/|r)(.*?)(?=$|\^r|<\/em>)/;
	
	while (s.match(styleRegex)){
		s = s.replace(styleRegex, (str, style, inner) => `<em style="${styleDict[style]}">${inner}</em>`)
	}

	return s.replace(/<span[^>]*><\/span[^>]*>/g, '');
}

function stripColorize(str){
	return str.replace(/\^([0-9])/g, "");
}

function notify(text){
	$(".notifyPanel").html("<br/>" + text);
	$(".notifyPanel").show();
	$(".notifyPanel").animate({
		height: 100
	}, 200, function(){
		setTimeout(() => {
			$(".notifyPanel").animate({
				height: 0
			}, 200, function(){
				$(".notifyPanel").hide();
				$(".notifyPanel").html("");
			});
		}, 5000);
	});
}

function showPhoneDialog(text, yesFunction, noFunction, keepOpen){
	if (!text) return;

	$(".phoneDialog-text").html(text);
	$(".phoneDialog").fadeIn();
	$(".phoneDialogBtnYes").off("click").click(function(){
		if (yesFunction){
			yesFunction();
		}

		if (!keepOpen){
			$(".phoneDialog").fadeOut();
		}
	});
	$(".phoneDialogBtnNo").off("click").click(function(){
		if (noFunction){
			noFunction();
		}

		if (!keepOpen){
			$(".phoneDialog").fadeOut();
		}
	});
}

function renderContacts(cont){
	$(".contactlist").children().remove();

	let unblocked = cont.filter(c => !c.blocked);
	let blocked = cont.filter(c => c.blocked);

	unblocked.sort((a, b) => (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0));
	blocked.sort((a, b) => (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0));

	let contacts = unblocked.concat(blocked);

	for (let i = 0; i < contacts.length; i++){
		let name = contacts[i].name;
		let number = contacts[i].number;
		let email = contacts[i].email || "";
		let blocked = contacts[i].blocked;
		let blockclass = "blockperson";
		let emailStr = "";

		if (email && email != ""){
			emailStr = `<span class="emailicon"><i class="fas fa-envelope"></i></span>`;
		}

		if (blocked){
			blockclass = "blockperson active";
		}

		if (name && (number || email)){
			$(".contactList").append(`
				<div class="row contact p-1 mt-1">
					<div class="col">
						<div class="row">
							<div class="col">
								<span class="contact name">${name}</span>
							</div>
						</div>
						<div class="row">
							<div class="col">
								<span class="contact number" data-number="${number}">${number}</span>
							</div>
						</div>
						<div class="row">
							<div class="col">
								<span class="contact email" data-email="${email}">${email}</span>
							</div>
						</div>
						<div class="row">
							<div class="col">
								<span class="${blockclass}"><i class="fas fa-ban"></i></span>
								<span class="textperson"><i class="fas fa-comment-alt-lines"></i></span>
								<span class="callicon"><i class="fas fa-phone-volume"></i></span>
								${emailStr}
							</div>
						</div>
					</div>
				</div>
			`);
		}
	}
}

function contactExists(pName, pNumber){
  if (pName && !pNumber){
		return contacts.filter(cont => cont.name == pName).length > 0;
	}
	else if (pName && pNumber){
		return contacts.filter(cont => cont.name == pName && cont.number == pNumber).length > 0;
	}
}

function getContactByNumber(number){
	for (let i = 0; i < contacts.length; i++){
		let cont = contacts[i];

		if (cont.number == number){
			return cont;
		}
	}

	return {name: "Unknown"};
}

function hideAllPanels(showhome){
	if (!showhome){
		$(".homescreen").hide();
	}
	
	$(".contactlist").stop().hide();
	$(".controlbar").stop().hide();
	$(".addcontact").stop().hide();
	$(".callstatus").stop().hide();
	$(".textcenter").stop().hide();
	$(".weathercenter").stop().hide();
	$(".e911").stop().hide();
	$("#e911emergency_input").stop().show();
	$("#e911emergency_input").val("");
  $(".e911reqservices").stop().show();
  $(".e911cancelservices").stop().show();
  $("#reqnotify").stop().hide();
  $("#cancelnotify").stop().hide();
	$(".paypal").stop().hide();
	$(".paypal-transhistory").stop().hide();
	$(".notepad").stop().hide();
	$(".settings").stop().hide();
	$(".calculator").stop().hide();
	$(".twitter").stop().hide();
	$(".gps").stop().hide();
	$(".mechanic").stop().hide();
	$(".vehiclesellinfo").stop().hide();
	$(".dealerSellLogs").stop().hide();
	$(".phoneHistoryLogs").stop().hide();
	$(".bankAccountTransactionLogs").stop().hide();
	$(".selfiePanel").stop().hide();
	$(".selfieOverlayPanel").stop().hide();
	$(".padDialer").stop().hide();
	$(".emailMaster").stop().hide();
	$(".yellowPagesMaster").stop().hide();
}

function showContactList(tog){
	if (tog){
		hideAllPanels();
		$(".contactlist").show();
		$(".controlbar").show();
	}
	else {
		hideAllPanels();
	}
}

function openCallStatus(source, num, ctype){
  var str = "";
  let contName = "";

  for (let i = 0; i < contacts.length; i++){
    if (num == contacts[i].number){
      contName = contacts[i].name + "<br/>";
      break;
    }
  }
	
	if (ctype == 1){
		str = "Incoming call from <br/>";
		// todo, properly place elements
		$("#answercall").show();
		$(".cancel").css("left", "144px");
		$("#cancelcall").show();
	}
	else if (ctype == 2){
		str = "Calling <br/>";
		// todo, properly place elements
		$("#answercall").hide();
		$(".cancel").css("left", "115px");
		$("#cancelcall").show();
	}

	str = str + contName + num;
	hideAllPanels();
	$("#callstatus_text").html(str);
	$(".callstatus").show();

	/*setTimeout(function(){
		sendData2(resource, "bms:comms:phone:cancelcall", "The call went unanswered.");
	}, 30000);*/
}

function openCallStatusInCall(call, part){
	var nstr = "";

	if (part == 1){
		nstr = formatNumber(call.part2.number);
	}
	else{
		nstr = formatNumber(call.part1.number);
	}

	$("#callstatus_text").html("In call with " + nstr);
	$(".answer").hide();
	$(".cancel").css("left", "115px");
	$(".cancel").show();
}

function loadTexts(name, number){
	if (name){
		$("#textnumber_generic").html(`<div class="contactname">${name}</div><div class="contactnumber">${number}</div>`);
	}
	else{
		$("#textnumber_generic").html(number);
	}
	
	let textMsgs = $("#textmessages");

	textMsgs.children().remove();
	$("#textnumber_generic").data("number", number);

	for (var i = 0; i < texts.length; i++){
		var text = texts[i].data;
		
		if (text.number == number){
			for (var j = 0; j < text.texts.length; j++){
				var msg = text.texts[j];
				var dirclass = "textmessage_in";
				var dirsymb = ""; // <<

				if (msg.direction == 2){ // 1 for incoming, 2 for outgoing
					dirclass = "textmessage_out";
					dirsymb = ""; // >>
				}

				textMsgs.append(
					`<div class="textmessage_block">
						<div class="${dirclass}">
							${msg.msg}
						</div>
					</div>
				`);
			}
		}
	}
	
	textMsgs.animate({
		scrollTop: textMsgs.get(0).scrollHeight
	}, 100);
}

function getNameForContact(number){
	for (var i = 0; i < contacts.length; i++){
		var cont = contacts[i];

		if (cont.number == number){
			return cont.name;
		}
	}
}

function doesContactExist(number){
	for (var i = 0; i < contacts.length; i++){
		if (contacts[i].number == number){
			return true;
		}
  }
  
  return false;
}

function addTextFieldForContact(num){
	var exists = false;

	for (var i = 0; i < texts.length; i++){
		var text = texts[i];

		if (text.data.number == num){
			exists = true;
			break;
		}
	}

	if (!exists){
		texts.push({data: {"number": num, texts: []}});
	}
}

function showTextNotifyForContact(number){
	$(".contact").each(function(){
		var lnumber = $(this).find(".contact.number").html();
		
		if (lnumber == number){
			$(this).find(".textperson").removeClass("notify").addClass("notify");
		}
	});
}

function addTextTo(num, dir, msg){
	//var data = {data: {"number": num, texts: {"direction": 1, "msg": "some message"}}}
	var idx = -1;
	var name = getNameForContact(num);
	var cexists = doesContactExist(num);

	if (!cexists){ // might need moved to call function
		contacts.push({"name": num, "number": num});
		renderContacts(contacts);
		sendData2(resource, "bms:comms:phone:addtempcontact", {number: num});
	}

	addTextFieldForContact(num);

	for (var i = 0; i < texts.length; i++){
		var text = texts[i];
		
		if (text.data.number == num) {
			idx = i;
			break;
		}
	}

	if (idx > -1){
		var text = texts[i].data.texts;

    text.push({"direction": dir, "msg": msg});
    
    // Check to see if the current selected text page is the number, else, don't load the texts and change panels
    let tonum = $("#textnumber_generic").html();

    if (!validPhoneNum(tonum)){
      tonum = $("#textnumber_generic").data("number");
    }

    if (num == tonum) {
      loadTexts(name, num);
    }
		
		showTextNotifyForContact(num);

		if (!hidenotifications && cellPropHash !== undefined){
			if (dir == 1){
				if (!blinking && !$("#phoneContainer").is(":visible")){
					blinking = true;
					$(".textnotify").blink({delay: 125});
				}
			}
		}
	}
	else{
		console.log("idx was -1");
	}
}

function formatNumber(fval){
	var fmtstr = fval.slice(0,3) + "-" + fval.slice(3,6) + "-" + fval.slice(6);
	var name = getNameForContact(fmtstr);
	
	if (name){
		return name;
	}
	else{
		return fmtstr;
	}
}
/*  
[0] = {fname = "Extra Sunny", weight = 50, hash = "EXTRASUNNY"}, 
[1] = {fname = "Clear", weight = 50, hash = "CLEAR"},
[2] = {fname = "Cloudy", weight = 15, hash = "CLOUDS"},
[3] = {fname = "Smoggy", weight = 10, hash = "SMOG"},
[4] = {fname = "Foggy", weight = 3, hash = "FOGGY"},
[5] = {fname = "Overcast", weight = 5, hash = "OVERCAST"},
[6] = {fname = "Rain", weight = 1, hash = "RAINING"},
[7] = {fname = "Thunderstorm", weight = 1, hash = "THUNDER"},
[8] = {fname = "Light Rain", weight = 2, hash = "CLEARING"},
[10] = {fname = "Christmas", weight = 0, hash = "XMAS"},
[11] = {fname = "Blizzard", weight = 0, hash = "BLIZZARD"}
*/
function changeWeather(weather, nextweather){
	switch(weather){
		case 0:
			$("#weathericon").attr("class", "weathericon sunny");
			$("#weather_text").html("Sunny");
			break;
		case 1:
			$("#weathericon").attr("class", "weathericon clear");
			$("#weather_text").html("Clear");
			break;
		case 2:
			$("#weathericon").attr("class", "weathericon cloudy");
			$("#weather_text").html("Cloudy");
      break;
    case 3:
      $("#weathericon").attr("class", "weathericon overcast");
      $("#weather_text").html("Smoggy");
      break;
		case 4:
			$("#weathericon").attr("class", "weathericon overcast");
			$("#weather_text").html("Foggy");
			break;
		case 5:
			$("#weathericon").attr("class", "weathericon cloudy");
			$("#weather_text").html("Overcast");
			break;
		case 6:
			$("#weathericon").attr("class", "weathericon showers");
			$("#weather_text").html("Scattered Storms");
			break;
		case 7:
			$("#weathericon").attr("class", "weathericon thunderstorms");
			$("#weather_text").html("Thunderstorms");
			break;
		case 8:
			$("#weathericon").attr("class", "weathericon rain");
			$("#weather_text").html("Light Rain");
      break;
    case 10:
      $("#weathericon").attr("class", "weathericon snow");
      $("#weather_text").html("Snowy");
      break;
		default:
			$("#weathericon").attr("class", "weathericon sunny");
			$("#weather_text").html("Sunny");
			break;
  }

  switch(nextweather){
		case 0:
			$("#nextweathericon").attr("class", "nextweathericon sunny");
			$("#next_weather_text").html("Sunny");
			break;
		case 1:
			$("#nextweathericon").attr("class", "nextweathericon clear");
			$("#next_weather_text").html("Clear");
			break;
		case 2:
			$("#nextweathericon").attr("class", "nextweathericon cloudy");
			$("#next_weather_text").html("Cloudy");
      break;
    case 3:
      $("#nextweathericon").attr("class", "nextweathericon overcast");
      $("#next_weather_text").html("Smoggy");
      break;
		case 4:
			$("#nextweathericon").attr("class", "nextweathericon overcast");
			$("#next_weather_text").html("Foggy");
			break;
		case 5:
			$("#nextweathericon").attr("class", "nextweathericon cloudy");
			$("#next_weather_text").html("Overcast");
			break;
		case 6:
			$("#nextweathericon").attr("class", "nextweathericon showers");
			$("#next_weather_text").html("Scattered Storms");
			break;
		case 7:
			$("#nextweathericon").attr("class", "nextweathericon thunderstorms");
			$("#next_weather_text").html("Thunderstorms");
			break;
		case 8:
			$("#nextweathericon").attr("class", "nextweathericon rain");
			$("#next_weather_text").html("Light Rain");
      break;
    case 10:
      $("#nextweathericon").attr("class", "nextweathericon snow");
      $("#next_weather_text").html("Snowy");
      break;
		default:
			$("#nextweathericon").attr("class", "nextweathericon sunny");
			$("#next_weather_text").html("Sunny");
			break;
	}
}

function renderPaypalTransHistory(trans){
	$(".pp-translist").children().remove();

	if (trans.length == 0){
		$(".pp-translist").html("No transactions found.");
	}
	else{
		var rstr = "";

		for (let i = 0; i < trans.length; i++){
			let t = trans[i];

			rstr += 
			`<div class="row pptrans">
				<div class="col-md pptrans name">${t.to}</div>
				<div class="col-sm pptrans amount">$${t.amount}</div>
			</div>`;
		}

		$(".pp-translist").append(rstr);
	}
}

function addTweet(data){
	if (data.msg && data.sender){
		let feed = $(".twitter-feed");
		let count = $(".tweetcontainer").length;

		if (count > 100){
			$(".tweetcontainer").eq(0).remove();
		}

		feed.append(`
			<div class="tweetcontainer">
				<div class="row tweet">
					<div class="col-12">
						<div class="twitter-name">${data.sender}</div>
					</div>
				</div>
				<div class="row">
					<div class="col-12">
            <div class="twitter-message">${data.msg}</div>
            <div class="twitter-divider"></div>
					</div>
				</div>
			</div>
		`);

		feed.animate({
			scrollTop: feed.get(0).scrollHeight
		}, 1000);

		if (showtbarks && !$("#phoneContainer").is(":visible")){
			sendData2(resource, "bms:comms:showTwitterBark", data);
		}
	}
}

function savePhoneSettings(){
	let tbchecked = $(".settings-twitter-showbarks").is(":checked");
	let smchecked = $(".settings-silentmode").is(":checked");
	let hnchecked = $(".settings-hidenotifications").is(":checked");
	
	showtbarks = tbchecked;
	silentmode = smchecked;
	hidenotifications = hnchecked;

	sendData2(resource, "bms:comms:phoneSettingChanged", {tname: "twitterbark", tvalue: tbchecked, sname: "silentmode", svalue: smchecked, hname: "hidenotifications", hvalue: hnchecked, bname: "background", bvalue: background, tbpname: "tbarkposition", tbpvalue: tbarkposition});
}

function togglePin(val){
  val == true ?	$(".gps-pin").show() : $(".gps-pin").hide();
}

function moveGpsPin(coords){
	let abszed = {x: 124, y: 314};
	let pinc = {x: Math.ceil(abszed.x + (coords.x * 0.03)), y: Math.ceil(abszed.y - (coords.y * 0.04))};
	
	$(".gps-pin").css("left", pinc.x + "px").css("top", pinc.y + "px");
	//console.log(`Pin Pixel Coords: ${pinc.x}, ${pinc.y}`);
}

function updateCarmaxData(modinfo, price, model){
	$(".cm-model").html(model);
	$(".cm-price").html(price);
	$(".vehinfomods").html("");
	$(".cm-purchasevehicle").prop("disabled", false);

	$(".vehinfomods").append(`
		<div class="row">
			<div class="col-12">
				Primary Color: ${modinfo.pcolor || "Unknown"}
			</div>
		</div>
	`);

	$(".vehinfomods").append(`
		<div class="row">
			<div class="col-12">
				Secondary Color: ${modinfo.scolor || "N/A"}
			</div>
		</div>
	`);

	for (let i = 0; i < modinfo.mods.length; i++){
		let mod = modinfo.mods[i];

		$(".vehinfomods").append(`
			<div class="row">
				<div class="col-12">
					${mod}
				</div>
			</div>
		`);
	}
}

function updateDealerLogs(logdata){
	$(".dsLogEntries").children().remove();

	let repairLogs = logdata.repairlogs;
	let sellerLogs = logdata;
	let sellSorted = Object.fromEntries(Object.entries(sellerLogs).sort(([,a],[,b]) => b.t - a.t));
	
	$(".dsLogEntries").append(`
		<div class="row dsLogHeader mt-1">
			<div class="col">
				Vehicle Sales
			</div>
		</div>
	`);

	for (const[vehPlate, vehData] of Object.entries(sellSorted)){
		if (vehPlate == "repairlogs") continue;

		$(".dsLogEntries").append(`
			<div class="row mt-1">
				<div class="dsLogEntry p-1">
					<div class="col-12">
						<div class="row">
							<div class="col-12">
								Salesman: ${vehData.en}
							</div>
						</div>
						<div class="row">
							<div class="col-12">
								Amount: $${vehData.p}
							</div>
						</div>
						<div class="row">
							<div class="col-12">
								Vehicle: ${vehData.n} [${vehPlate}]
							</div>
						</div>
						<div class="row">
							<div class="col">
								Customer: ${vehData.c || "N/A"}
							</div>
						</div>
						<div class="row" style="font-size: 10px; font-style: italic; color: gray">
							<div class="col">
								${formatDateFromLua(vehData.t)}
							</div>
						</div>
					</div>
				</div>
			</div>
		`);
	}

	if (repairLogs !== undefined){
		$(".dsLogEntries").prepend(`
			<div class="row">
				<div class="dsLogEntry p-1">
					<div class="col-12">
						<div class="row">
							<div class="col-12">
								<span style='color: skyblue'>Repairs:</span> $${repairLogs}
							</div>
						</div>
					</div>
				</div>
			</div>
		`);
	}
}

function formatDateFromLua(date){
  if (typeof(date) == "string"){
    return date;
  }

  var d = new Date(date * 1000);
  var month = d.getMonth() + 1;
  var time = d.toTimeString().substr(0, 5);
  
  if (d.getFullYear() == "1969"){
      return "N/A";
  }
  else{
    return month + "/" + d.getDate() + "/" + d.getFullYear() + " " + time;
  }
}

function updateCallHistory(history){
	$(".phoneCallLog-Entries").children().remove();

	let keys = Object.keys(history);

	if (history.length == 0 || !history || history == undefined){
		$(".phoneCallLog-Entries").append(`
			<div class="row">
				<div class="phoneCallLog-Entry">
					<div class="col-12">
						<div class="row">
							<div class="col-12">
								No recent calls.
							</div>
						</div>
					</div>
				</div>
			</div>
	`);
		return;
	}

	for (let i = 0; i < keys.length; i++){
		let time = keys[i];
		let entry = history[time];
		let contact = getContactByNumber(entry.num).name;
		let imgs = ["pcio-in", "pcio-out"];
		let ioclass = "";
		
		ioclass = imgs[entry.type - 1];

		$(".phoneCallLog-Entries").append(`
		<div class="row">
			<div class="phoneCallLog-Entry">
				<div class="col-12">
					<div class="row">
						<div class="col-12">
							${formatDateFromLua(parseInt(time))}
						</div>
					</div>
					<div class="row">
						<div class="col-6">
							${contact}
						</div>
						<div class="col-5">
							${entry.num || "Blocked"}
						</div>
					</div>
					<div class="row">
						<div class="col">
							<div class="${ioclass}"/>
						<div>
					</div>
				</div>
			</div>
		</div>
	`);
	}
}

function selectCam(cid){
	$(".camsysCameraItem").removeClass("selected");
	let item = $(".camsysCameraItem[data-cid='" + cid + "']");

	if (item.length > 0){
		item.addClass("selected");
		$(".camsysCameras").scrollTop(item.offset().top - $(".camsysCameras").offset().top + $(".camsysCameras").scrollTop());
		activecam = cid;
		sendData2(resource, "bms:comms:cameras:activateCamera", {cid: cid});
	}
}

function updateCameras(cameras){
	let menu = $(".camsysCameras");

	menu.children().remove();

	for (let i = 0; i < cameras.length; i++){
		let cam = cameras[i];

		menu.append(`<div class="camsysCameraItem" data-cid="${i + 1}">${cam}</div>`);
	}

	$(".cameraSystemContainer").fadeIn();
}

function cameraNavigate(dir){
	let elements = $(".camsysCameraItem").length;
	
	if (dir == 1){
		activecam = activecam - 1;

		if (activecam <= 0){
			activecam = elements;
		}
	}
	else if (dir == 2){
		activecam = activecam + 1;

		if (activecam > elements){
			activecam = 1;
		}
	}

	selectCam(activecam);
}

function renderTransactionHistory(history, listing, balance){
	if (listing){
		let anchor = $("#dropDownAccountHistoryList");
		
		anchor.children().remove();

		let keys = Object.keys(history);

		for (let i = 0; i < keys.length; i++){
			let fname = history[keys[i]];

			anchor.append(`
				<button class="dropdown-item btnAccountHistorySelection" type="button" data-id="${keys[i]}">[${keys[i]}] ${fname}</button>
			`);
		}
	}
	else{
		if (balance){
			$(".bankAccountBalance").html(`Account Balance: $${balance}`);
		}
		else{
			$(".bankAccountBalance").html("Account Balance: Hidden");
		}
		
		let anchor = $(".transactionHistoryDataAnchor");

		anchor.children().remove();

		for (let i = 0; i < history.length; i++){
			let entry = history[i];
			let transType = "Deposit";

			if (entry.dir == 2){
				transType = "Withdrawal";
			}

			anchor.append(`
				<tr>
					<td>${entry.charname}<br/>${entry.am}</td>
					<td>${transType}</td>
					<td>${formatDateFromLua(entry.time)}</td>
				</tr>
			`);
		}
	}
}

function selfieModeToggle(selfieMode){
	let selfiePanel = $(".selfiePanel");
	
	if (selfieMode){
		hideAllPanels();
		selfiePanel.stop().fadeIn();
	}
	else{
		hideAllPanels(true);
	}
}

function changeSelfieOverlay(image, size, position){
	let panel = $(".selfieOverlayPanel");

	if (!image || image === "0"){
		panel.css("background-image", "initial");
		panel.hide();
	}
	else{
		panel.css("background-image", `url(selfieimages/${image})`);
		
		if (size){
			panel.css("background-size", size);
		}

		if (position){
			panel.css("background-position", position);
		}
		
		panel.show();
	}
}

function renderUserEmails(emails, forceEmailView){
	$(".emailViewOrCompose").html("Email Inbox");
	$(".emailsList").hide();
	$(".emailsList").children().remove();
	$(".emailsCompose").hide();
	$(".emailView").hide();
	
	//console.log(`${JSON.stringify(emails)}, ${forceEmailView}`);

	if (!emails || emails.length == 0){
		$(".emailsList").append(`
			<div class="row">
				<div class="col">
					No emails.
				</div>
			</div>
		`);

		if (forceEmailView){
			hideAllPanels();
			$(".emailMaster").show();
			$(".emailsList").stop().fadeIn();
		}

		blockSecondary = false;
		return;	
	}

	let showHeaderIcon = false;

	emails.forEach(email => {
		let readClass = "fa-envelope envelopeHighlight";

		if (email.isread == 1){
			readClass = "fa-envelope-open envelopeGray";
		}
		else{
			showHeaderIcon = true;
		}
		
		$(".emailsList").append(`
			<div class="emailRow row" data-emailid="${email.id}">
				<div class="col">
					<div class="row p-1">
						<div class="col-6">
							${email.senderName || "Unknown Sender"}
						</div>
						<div class="col-6 emailSmallText">
							${formatDateFromLua(email.timestamp)}
						</div>
					</div>
					<div class="row p-1 pl-3">
						<div class="col">
							<i class="emailEnvelope fas ${readClass}"></i><span class="emailSubject ml-2">${email.subject}</span>
						</div>
					</div>
				</div>
			</div>
		`);
	});

	showHeaderIcon ? $(".notifyIcon_NewEmail").stop().fadeIn() : $(".notifyIcon_NewEmail").stop().fadeOut();

	if (forceEmailView){
		hideAllPanels();
		$(".emailMaster").show();
		$(".emailsList").show();
	}

	blockSecondary = false;
}

function renderUserEmailBody(emailId){
	let email = lastEmails.filter(email => email.id == emailId)[0];

	if (email.isread == 0){
		sendData("bms:comms:phone:markEmailRead", {emailId: emailId});
		email.isread = 1;
		
		let emailView = $(".emailRow[data-emailid='" + emailId + "'");

		if (emailView.length > 0){
			emailView.find(".emailEnvelope").removeClass("fa-envelope").removeClass("whiteEnvelope").addClass("fa-envelope-open").addClass("envelopeGray");
		}
	}

	lastReadingEmail = emailId;
	$(".emailsList").hide();
	$(".emailsCompose").hide();
	$(".emailViewFrom").html(email.senderName);
	$(".emailViewTimestamp").html(formatDateFromLua(email.timestamp));
	$(".emailViewBody").html(email.body.stripSlashes());
	$(".emailView").stop().fadeIn();
}

function clearEmailViewFields(){
	$(".emailViewFrom").html("");
	$(".emailViewTimestamp").html("");
	$(".emailViewBody").html("");
}

function deleteEmail(emailId){
	// delete view, email list and email array
	$(".emailView").hide();
	clearEmailViewFields();
	let email = $(".emailRow[data-emailid='" + emailId + "']");

	if (email.length > 0){
		email.remove();
	}

	lastEmails = lastEmails.filter(email => email.id != emailId);
	lastReadingEmail = 0;
	$(".emailsList").stop().fadeIn();
	blockSecondary = false;
}

function clearEmailComposeFields(){
	$("#emailSendTo").val("");
	$("#emailSubject").val("");
	$("#emailBody").val("");
	$(".smlEmailBodyCount").html("1024");
}

function blinkEmailNotify(){
	if (!$("#phoneContainer").is(":visible")){
		$(".emailNotify").blink({delay: 125});
		setTimeout(function(){
			$(".emailNotify").unblink();
		}, 30000);
	}
}

function pruneTextToLength(text, setLength){
  if (text.length < setLength) return text;
  
  return `${text.substring(0, setLength)}...`;
}

function toggleYpBlocker(toggle){
	toggle ? $(".ypBlocker").stop().fadeIn() : $(".ypBlocker").stop().fadeOut();
}

function renderYpAdverts(adverts, category){
	let anchor = $(".ypListings-anchor");
	let advertsCatd = adverts.filter(ad => ad.category == category);

	anchor.children().remove();	
	advertsCatd.forEach(advert => {
		let callStr = `<div class="ypCallPerson ypActionButton mr-1 float-right"><i class="fas fa-phone-square-alt"></i></div>`;
		let emailStr = `<div class="ypEmailPerson ypActionButton mr-1 float-right"><i class="fas fa-envelope-square"></i></div>`;
		let phNum = "";
		let emAdr = "";
		let deleteStr = "";

		if (advert.flag === 1){
			callStr = "";
		}
		else{
			phNum = formatPhoneNumber(advert.phoneNumber)
		}

		if (advert.flag === 0){
			emailStr = "";
		}
		else{
			emAdr = advert.emailAddress;
		}

		//console.log(JSON.stringify(advert, null, 2));
		if (advert.phoneNumber == myDetails.phoneNumber || advert.emailAddress == myDetails.emailAddress){
			deleteStr = `<div class="ypDeleteAdvert mr-3 float-left" data-id="${advert.id}"><i class="fad fa-minus-square"></i></div>`;
		}

		let listing = anchor.append(`
			<div class="ypListing mt-2" data-id="${advert.id}">
				<div class="row">
					<div class="col ypListing-name">
						${advert.charName}
					</div>
					<div class="col ypListing-number">
						${phNum}
					</div>
				</div>
				<div class="row">
					<div class="col ypListing-email">
						${emAdr}
					</div>
				</div>
				<div class="row mt-1">
					<div class="col ypListing-text">
						${colorizeByTokens(pruneTextToLength(advert.text, 120))}
					</div>
				</div>
				<div class="row mt-1">
					<div class="col">
						${emailStr}${callStr}${deleteStr}
					</div>
				</div>
			</div>
		`);

		let callPerson = $(".ypListing[data-id='" + advert.id + "']").find(".ypCallPerson");
		let emailPerson = $(".ypListing[data-id='" + advert.id + "']").find(".ypEmailPerson");

		if (callPerson.length > 0){
			callPerson.data("cname", advert.charName);
			callPerson.data("phonenumber", advert.phoneNumber);
		}

		if (emailPerson.length > 0){
			emailPerson.data("cname", advert.charName);
			emailPerson.data("emailaddress", advert.emailAddress);
		}
	});
}

function loadYpListingToView(id){
	if (!id) return;

	let advert = lastAdverts.filter(advert => advert.id == id)[0];

	if (!advert || advert === undefined){
		console.log("Error getting advert identity.");
		return;
	}

	$(".ypViewListing-name").html(advert.charName);
	$(".ypViewListingContainer").html(colorizeByTokens(advert.text));
	$(".ypViewListing").stop().fadeIn();
}

function sendData2(res, name, data){
  $.post("http://" + res + "/" + name, JSON.stringify(data), function(datab) {
  	console.log(datab);
  });
}

(function($) {
  $.fn.blink = function(options) {
      var defaults = { delay: 500 };
      var options = $.extend(defaults, options);
      
      return $(this).each(function(idx, itm) {
        var handle = setInterval(function() {
          if ($(itm).is(":visible")) {
            //$(itm).hide();
            $(itm).fadeOut("slow", function(){
              $(itm).hide();
            });
          }
          else{
            $(itm).fadeIn("slow");                
          }
        }, options.delay);

        $(itm).data("handle", handle);
      });
  }
  $.fn.unblink = function() {
      return $(this).each(function(idx, itm) {
        var handle = $(itm).data("handle");
        if (handle) {
          clearInterval(handle);
          $(itm).data("handle", null);
          $(itm).hide();
        }
      });
  }
}(jQuery));