let spawnarea = 1;
let selectedChar = false;
let createWait = false;
let factionConversion = [
	{name: "blackmarket", con: "Black Market"},
	{name: "news", con: "News Reporter"},
	{name: "mechanic", con: "Mechanic"},
	{name: "forensics", con: "Forensics"},
	{name: "transitauthority", con: "Metro"},
	{name: "lawyer", con: "Lawyer"},
	{name: "realtor", con: "Realtor"},
	{name: "aviation", con: "Aviation"}
];
let nchange = "";

$(function()
{
  $.post('https://characters/finishedLoading', JSON.stringify({loaded: true}));

	window.addEventListener("message", function(event)
	{
		var item = event.data;
		
		if (item.meta && item.meta == "openCharDialog"){
			$(".master-row").fadeOut(150, function(){
				$(".csContainer").fadeIn();
				$(".createCharacter").fadeIn();
			});
		}
		else if (item.meta && item.meta == "closeCharDialog"){
			$(".createCharacter").fadeOut(150, function(){
				$(".btnCreateCharacter").prop("disabled", false);
				$(".master-row").fadeIn();
			});
		}
		else if (item.meta && item.meta == "disableBlackout"){
			$(".loadingCharacter").fadeOut();
			$(".csContainer").fadeOut();
		}
		else if (item.loadCharData){
			let data = item.data;

			//this.console.log("loading data: " + JSON.stringify(data));

			if (data){
				let charc = $(".createCharacter");
				let namec = $(".namechange");

				if (charc.is(":visible")){
					charc.fadeOut();
				}

				if (namec.is(":visible")){
					namec.fadeOut();
				}

				$(".csContainer").fadeIn();
				$(".csButtonContainer").fadeIn();
				loadCharactersData(data);
			}
		}
		else if (item.meta == "charExists"){
			let charc = $(".createCharacter");
			let namec = $(".namechange");

			if (charc.is(":visible")){
				$(".createfailtext").html("Character name is already taken. Please choose another.");
				$(".createfailtext").fadeIn();
				$(".btnCreateCharacter").prop("disabled", false);
			}
			else if (namec.is(":visible")){
				$(".ncfailtext").html("Character name is already taken. Please choose another.");
				$(".ncfailtext").fadeIn();
				$(".btnChangeName").prop("disabled", false);
			}
			
			createWait = false;
		}
		/*else if (item.meta == "addCreateButton"){
			addCreateCharButton();
		}
		else if (item.meta == "loginFailedUsername"){
			$("#loginhiddentext")[0].innerHTML = "Username was invalid.";
			$("#loginhiddentext").show();
		}*/
	});
	
	$(".btnCreateCharacter").click(function(){ // create char submit
		submitName();
	});

	$(".btnCancelCreate").click(function(){
		cancelCreate();
	});

	$(".btnCancelNamechange").click(function(){
		$(".namechange").fadeOut(150, function(){
			$(".master-row").fadeIn();
		});
	});

	$(".buttonCreate").click(function(){
		createCharacter();
	});

	$(".btnChangeName").click(function(){
		submitName(true);
	});

	$(document).on("mouseenter", ".characterPanel", function(){
		$(this).find(".spawnSelectorGroup").fadeIn();
	});

	$(document).on("mouseleave", ".characterPanel", function(){
		$(this).find(".spawnSelectorGroup").fadeOut();
	});

	$(document).on("click", ".buttonSelect", function(){
		let namechange = $(this).data("namechange");

		if (namechange == 1){
			nchange = $(this).data("name");
			$(".master-row").fadeOut(150, function(){
				$(".namechange").fadeIn();
			});
		}
		else{
			let name = $(this).data("name");

			if (!selectedChar){
				selectedChar = true;
				selectChar(name);
			}
		}
	});

	$(document).on("click", ".spawnSelectorItem", function(){
		let id = parseInt($(this).data("id"));
		
		$(this).parent().siblings(".spawnZoneDropdown").text($(this).text());

		if (id && id != "NaN"){
			spawnarea = id;
		}
	});

	$(document).on("input", "#ncCharacter-fname", function(){
		if (!validateField($(this))){
      $(".ncfailtext").html("You must enter a first and last name.  3 character minimum, with up to 3 capital letters, alphabetical characters and/or a dash(-) (no spaces).");
			$(".ncfailtext").fadeIn();
		}
		else{
			$("#ncCharacter-fname").val(capitalizeFirstLetter($(this).val()));
			$(".ncfailtext").fadeOut();
		}
	});
	
	$(document).on("input", "#ncCharacter-lname", function(){
		if (!validateField($(this))){
      $(".ncfailtext").html("You must enter a first and last name.  3 character minimum, with up to 3 capital letters, alphabetical characters and/or a dash(-) (no spaces).");
			$(".ncfailtext").fadeIn();
		}
		else{
			$("#ncCharacter-lname").val(capitalizeFirstLetter($(this).val()));
			$(".ncfailtext").fadeOut();
		}
	});
	
	$(document).on("input", "#createCharacter-fname", function(){
		if (!validateField($(this))){
			$(".createfailtext").html("You must enter a first and last name.  3 character minimum, with up to 3 capital letters, alphabetical characters and/or a dash(-) (no spaces).");
			$(".createfailtext").fadeIn();
		}
		else{
			$(this).val(capitalizeFirstLetter($(this).val()));
			$(".createfailtext").fadeOut();
		}
	});

	$(document).on("input", "#createCharacter-lname", function(){
		if (!validateField($(this))){
			$(".createfailtext").html("You must enter a first and last name.  3 character minimum, with up to 3 capital letters, alphabetical characters and/or a dash(-) (no spaces).");
			$(".createfailtext").fadeIn();
		}
		else{
			$(this).val(capitalizeFirstLetter($(this).val()));
			$(".createfailtext").fadeOut();
		}
	});
});

function capitalizeFirstLetter(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}

function hasWhiteSpace(s) {
  return /\s/g.test(s);
}

function checkCharacters(s) {
  let caps = s.replace(/[^A-Z]/g, "").length;
  let dashes = s.replace(/[^\-]/g, "").length;

  if (caps <= 3 && /[a-z]+/g.test(s) && dashes <= 1){
    return true;
  }

  return false;
}

function validateField(ele) {
  let value = ele.val();
	let pass = /^[A-z]+[A-z\-]+$/i.test(value);
  pass = pass && !hasWhiteSpace(value) && checkCharacters(value);
  
  if (!pass || value.length < 3){
    return false;
  }

  return true;
}

function submitName(change){
	if (change){
		let fname = $("#ncCharacter-fname");
		let lname = $("#ncCharacter-lname");

		if (!validateField(fname) || !validateField(lname)){
			$(".ncfailtext").html("You must enter a first and last name.  3 character minimum, with up to 3 capital letters, alphabetical characters and/or a dash(-) (no spaces).");
			$(".ncfailtext").fadeIn();
			$(".btnChangeName").prop("disabled", false);
		}
		else if (!createWait) {
			createWait = true;
			$(".btnChangeName").prop("disabled", true);
			$.post('https://characters/changeName', JSON.stringify({firstName: capitalizeFirstLetter(fname.val()), lastName: capitalizeFirstLetter(lname.val()), oldName: nchange}));
		}
	}
	else{
		let fname = $("#createCharacter-fname");
		let lname = $("#createCharacter-lname");
		
		if (!validateField(fname) || !validateField(lname)){
			$(".createfailtext").html("You must enter a first and last name.  3 character minimum, with up to 3 capital letters, alphabetical characters and/or a dash(-) (no spaces).");
			$(".createfailtext").fadeIn();
			$(".btnCreateCharacter").prop("disabled", false);
		}
		else if (!createWait) {
			createWait = true;
			$(".btnCreateCharacter").prop("disabled", true);
			$.post('https://characters/createCharacter', JSON.stringify({firstName: fname.val(), lastName: lname.val()}));
		}
	}
}

function cancelCreate(){
	$(".createCharacter").fadeOut();	
	$(".master-row").fadeIn();
	$(".btnCreateCharacter").prop("disabled", false);
}

function selectChar(charName){
	$(".master-row").fadeOut(150, function(){
		$(".csButtonContainer").fadeOut();
		$(".loadingCharacter").fadeIn();
	});

	$.post('https://characters/selectChar', JSON.stringify({character: charName, spawnarea: spawnarea}));
}

function createCharacter(){
	let ccount = $(".characterPanel").length;

	if (ccount < 5){
		$(".master-row").fadeOut(150, function(){
			$(".createCharacter").fadeIn();
		});
	}
	else{
		let button = $(".buttonCreate");
		
		button.removeClass("btn-info");
		button.addClass("btn-danger");
		button.html("5 Player Maximum Reached");
	}
}

function addCommasToNumber(nStr) {
	nStr += '';
	var x = nStr.split('.');
	var x1 = x[0];
	var x2 = x.length > 1 ? '.' + x[1] : '';
	var rgx = /(\d+)(\d{3})/;
	while (rgx.test(x1)) {
		x1 = x1.replace(rgx, '$1' + ',' + '$2');
	}
	return x1 + x2;
}

function convertFacName(name){
	for (let i = 0; i < factionConversion.length; i++){
		let fac = factionConversion[i];

		if (name == fac.name){
			return fac.con;
		}
	}
}

function formatPhoneNumber(num){
	let snum = num.toString();

	return snum.slice(0, 3) + "-" + snum.slice(3, 6) + "-" + snum.slice(6, 15);
}

function loadCharactersData(data){	
	if (data){
		$(".master-row").children().detach();

		for (let i = 0; i < data.length; i++){
			let char = data[i];
						
			if (char){
				let fstr = "";
				let fnamechange = char.forcenamechange;
				
				if (char.factions && char.factions != ""){
					let factions = JSON.parse(char.factions) || "";

					for (let f = 0; f < factions.length; f++){
						let fac = factions[f];

						fname = convertFacName(fac.name);
						
						if (fname){
							fstr += fname + ", ";
						}
					}

					if (fstr != ""){
						fstr = fstr.slice(0, -2);
					}
					else{
						fstr = "None";
					}
				}
				else{
					fstr = "None";
				}

				char.islawenf = (char.islawenf && char.islawenf == 1) ? "<span style='color: aqua'>Law Enforcement</span>" : ""
				char.isems = (char.isems && char.isems == 1) ? "<span style='color: #e6635a'>EMS</span>" : ""
				
				let entry = $(".master-row").append(`
					<div class="col-2 cpcol ml-2">
						<div class="characterPanel">
							<div class="row">
								<div class="col-12">
									<div class="cinfo-charname">${char.charName}</div>
								</div>
							</div>
							<div class="row mt-2">
								<div class="col-12">
									<div class="cstextbox">
										<span class="cstext-highlight">Position:</span> <span class="cstext csinfo-lklocation">${char.lastpos}</span>
										<br/>
										<span class="cstext-highlight">Factions:</span><br/> <span class="cstext csinfo-skills">
										${fstr}
										</span>
										<br/>
										<span class="cstext-highlight">Money: <span class="cstext">$${addCommasToNumber(char.money.toString())}</span></span>
										<br/>
										<span class="cstext-highlight">Bank Money: <span class="cstext">$${addCommasToNumber(char.bankmoney.toString())}</span></span>
										<br/>
                    <span class="cstext-highlight">Phone number: <span class="cstext">${formatPhoneNumber(char.phonenumber)}</span></span>
                    <br/>
										<span class="cstext-highlight">Playtime: <span class="cstext">${addCommasToNumber((char.playtime / 3600).toFixed(1).toString())}h</span></span>
										<br/>
										<br/>
										<span class="cstext-highlight">${char.islawenf} ${char.isems}</span>
									</div>
								</div>
							</div>
							<div class="btn-group dropup spawnSelectorGroup">
								<button type="button" class="btn btn-info dropdown-toggle spawnZoneDropdown" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
									Spawn Zone
								</button>
								<div class="dropdown-menu">
									<a class="dropdown-item spawnSelectorItem" data-id="1" href="#">Hawick Ave</a>
									<a class="dropdown-item spawnSelectorItem" data-id="2" href="#">Route 68</a>
									<a class="dropdown-item spawnSelectorItem" data-id="3" href="#">Paleto Ave</a>
									<div class="dropdown-divider"></div>
									<a class="dropdown-item spawnSelectorItem" data-id="4" href="#">Last Known Position</a>
									<a class="dropdown-item spawnSelectorItem" data-id="5" href="#">Home</a>
								</div>
							</div>
							<button type="button" class="btn btn-info btn-block buttonSelect" data-name="${char.charName}">Select</button>
						</div>
					</div>`);

				if (fnamechange){
					let button = $(".buttonSelect[data-name='" + char.charName + "']"); //entry.find(".buttonSelect"); // changes ALL buttons, check selector

					button.text("Name Change Requested");
					button.removeClass("btn-info");
					button.addClass("btn-warning");
					button.data("namechange", 1);
				}

				entry.find(".characterPanel").fadeIn();
			}
		}

		createWait = false;

		if (!$(".master-row").is(":visible")){
			$(".master-row").fadeIn();
		}
	}
}