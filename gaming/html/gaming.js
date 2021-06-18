let currentGame;
let charData = {};
let scoreTimerInterval;
let curTimer = 0;
let slotDelays = {initial: 1000, betweenSlots: 1000};
let slots = [
  {sid: "#casino1", ref: 0},
  {sid: "#casino2", ref: 0},
  {sid: "#casino3", ref: 0}
];
let canSlotAction = true;
let tileCombo;
let wheelsComplete = 0;
let needSetup = true;
let canExitSlots = true;
let slotsAudio = {};
let lastMachineType = 1;

$(function(){
	window.addEventListener("message", function(ev){
		let data = ev.data;
		
		if (data.showCreateMaxBet){
			$(".btnAcceptMaxBet").prop("disabled", false);
			$(".btnCancelMaxBet").prop("disabled", false);
			$(".tableMaxBet").html(`$${data.tableMaxBet || 2500}`);
			$(".maxBetContainer").fadeIn();
			$("#maxBetValue").val($("#maxBetValue").prop("min"));
		}
		else if (data.updateGame){
			let gameId = data.gameId;
			let game = data.game;

			if (!gameId || !game) return;

			currentGame = game;
			updateGame(data.fullRedraw);
		}
		else if (data.toggleGameInterface){
			data.toggle ? $(".gamingContainer").fadeIn() : $(".gamingContainer").fadeOut();
		}
		else if (data.toggleReadyRoom){
			charData = data.charData;
			updateReadyRoom(data);
		}
		else if (data.toggleFinalScore){
			renderFinalScore(data.game, data.timerTime);
			data.toggle ? showFinalScore() : showPlayerHands();
		}
		else if (data.closeAndReset){
			resetGame();
		}
		/* Slots */
		else if (data.showSlots){
			if (data.machineType){
				lastMachineType = data.machineType;

				for (let i = 1; i <= data.tileCount; i++){
					$(".slot" + i).css("background-image", "url(images/slot" + data.machineType + "_panel" + i + ".png)");
				}

				$(".slotsMaster").css("background-image", "url(images/slot_machine_" + data.machineType + ".png)");
				
				$(".slotsMaster").fadeIn(function(){
					if (needSetup){
						needSetup = false;
						setupSlots();
					}
				});
			}
			else{
				$(".slotsMaster").fadeIn(function(){
					if (needSetup){
						needSetup = false;
						setupSlots();
					}
				});
			}
		}
		else if (data.toggleSlotAction){
			canSlotAction = data.toggle;
		}
		else if (data.setSlotsMachineBet){
			if (data.msg){
				$(".slotText").html(data.msg || "").stop().fadeIn().delay(5000).fadeOut();
			}

			$(".slotBetInfo").html(`Bet: $${data.currentBet}`);
		}
		else if (data.doSlotSpin){
			tileCombo = data.tileCombo;
			spinSlots();
			playSlotSoundClient(1, 0.3);
		}
		else if (data.setSlotSpinComplete){
			if (data.msg){
				if (data.winnings > 0){
					$(".slotText").html(data.msg || "").stop().fadeIn().delay(5000).fadeOut();
				}
			}

			if (data.winLevel == 4){
				$(".slotWinningsText").html(`JACKPOT $${data.winnings || 0}`);
			}
			else{
				$(".slotWinningsText").html(`WINNINGS $${data.winnings || 0}`);
			}

			$(".slotBetInfo").html(`Bet: $0`);
		}
		else if (data.setSlotText){
			if (data.msg){
				$(".slotText").html(data.msg || "").stop().fadeIn().delay(5000).fadeOut();
			}
		}
		else if (data.setTextAnimate){
			if (data.msg){
				if (data.msg == "WINNER"){
					playSlotSoundClient(2, 0.4);
				}
				else if (data.msg == "JACKPOT"){
					playSlotSoundClient(5, 0.4);
				}

				$(".slotsTextAnimate").html(data.msg).stop().fadeIn().delay(data.delay).fadeOut();
			}
		}
		else if (data.exitSlotsImmediate){
			exitSlotsImmediate();
		}
	});

	$(document).on("click", ".btnReadyUpToggle", function(){
		let ready = $(this).hasClass("btn-warning");

		ready ? $(this).removeClass("btn-warning").addClass("btn-success") : $(this).removeClass("btn-success").addClass("btn-warning");

		sendData("bms:gaming:readyUpToggle", {readyStatus: ready, tableIndex: currentGame.tableIndex});
	});

	$(document).on("click", ".btnGameAction", function(){
		let action = parseInt($(this).data("actionid"));

		$(".btnGameAction").prop("disabled", true);
		sendData("bms:gaming:doPlayerAction", {action: action, tableIndex: currentGame.tableIndex});
		playSoundClient("blackjack_click", 0.2);
	});

	$(document).on("click", ".btnGameInsurance", function(){
		$(this).hide();
		sendData("bms:gaming:doPlayerAction", {action: 3, tableIndex: currentGame.tableIndex});
		playSoundClient("blackjack_click", 0.2);
	});

	$(".btnLeaveGame").on("click", function(){
		if (currentGame.gameStarted && !currentGame.inScoreTimeout){
			showLeaveWarning();
		}
		else{
			resetGame();
			sendData("bms:gaming:playerLeaveGame", "");
		}
	});

	$(".btnAcceptMaxBet").on("click", function(){
		$(".btnAcceptMaxBet").prop("disabled", true);
		$(".btnCancelMaxBet").prop("disabled", true);
		$(".maxBetContainer").hide();

		let userVal = parseInt($("#maxBetValue").val()); // user entered
		let minVal = parseInt($("#maxBetValue").prop("min")); // 100

		if (userVal < minVal || isNaN(userVal)){
			$("#maxBetValue").val(minVal);
			userVal = minVal;
		}

		if (userVal >= minVal){
			sendData("bms:gaming:acceptMaxBet", {maxBet: userVal});
		}
	});

	$(".btnCancelMaxBet").on("click", function(){
		$(".btnAcceptMaxBet").prop("disabled", true);
		$(".btnCancelMaxBet").prop("disabled", true);
		$(".maxBetContainer").hide();

		sendData("bms:gaming:cancelMaxBet", "");
	});

	$(".btnSpinSlots").on("click", function(){
		if (!canSlotAction) return;

		canSlotAction = false;
		canExitSlots = false;
		sendData("bms:gaming:slots:doSlotSpin", "");
		playSlotSoundClient(3, 0.3);
	});

	$(".btnBetOne").on("click", function(){
		if (!canSlotAction) return;

		canSlotAction = false;
		sendData("bms:gaming:slots:doSlotBetOne", "");
		playSlotSoundClient(4, 0.3);
	});

	$(".btnBetMax").on("click", function(){
		if (!canSlotAction) return;

		canSlotAction = false;
		sendData("bms:gaming:slots:doSlotBetMax", "");
		playSlotSoundClient(4, 0.3);
	});

	$(".btnExitSlot").on("click", function(){
		if (!canExitSlots){
			$(".slotText").html("You can not exit until the wheels stop spinning.").stop().fadeIn().delay(5000).fadeOut();
			return;
		}
		
		canSlotAction = true;
		sendData("bms:gaming:slots:exitSlots", "");
		$(".slotsMaster").fadeOut();
		playSlotSoundClient(3, 0.3);
	});
});

let waitInt;
function exitSlotsImmediate(){
	if (!canExitSlots){
		waitInt = setInterval(function(){
			if (canExitSlots){
				clearInterval(waitInt);
				canSlotAction = true;
				sendData("bms:gaming:slots:exitSlots", "");
				$(".slotsMaster").fadeOut();
				playSlotSoundClient(3, 0.3);
			}
		}, 500);
	}
	else{
		canSlotAction = true;
		sendData("bms:gaming:slots:exitSlots", "");
		$(".slotsMaster").fadeOut();
		playSlotSoundClient(3, 0.3);
	}
}

function showFinalScore(){
	$(".playerCards").hide();
	$(".finalScore").fadeIn();
}

function showPlayerHands(){
	$(".finalScore").hide();
	$(".playerCards").fadeIn();
}

function resetGame(){
	$(".gamingContainer").hide();
	$(".playerCards").hide();
	$(".readyUpRoom").show();
	$(".finalScore").hide();
	$(".gamePlayersCardAnchor").children().remove();
	$(".playerCardDisplay").children().remove();
	currentGame = undefined;
	charData = {};
}

function updateGame(fullRedraw){
	if (fullRedraw){
		let playerCardAnchor = $(".gamePlayersCardAnchor");
		let gameAnchor = $(".playerCardDisplay");
		
		$(".gameCard").find(".card-title").html(`Game Table ${currentGame.tableIndex}`);
		playerCardAnchor.children().remove();
		gameAnchor.children().remove();

		for (const [playerId, playerData] of Object.entries(currentGame.players)){
			let hand = "";
			let insured = "";
				
			playerData.hand.forEach(card => {
				hand += `${card},`;
			});

			if (playerData.insured){
				insured = `<span style="color: skyblue">(Insured)</span>`;
			}

			hand = hand.substr(0, hand.length - 1);
			 // player betting display card (top right)
			playerCardAnchor.append(`
				<div class="row player" data-playerid="${playerId}">
					<div class="col">
						${playerData.charName}
					</div>
					<div class="col playerBet" data-playerid="${playerId}">
						$${playerData.totalWinnings}
					</div>
				</div>
			`);

			// player game hand (bottom right)
			gameAnchor.append(`
				<div class="col p-4 playerGameCards" data-playerid="${playerId}">
					<div class="row hand fan active-hand" data-fan="spacing: 0.2; width: 110; radius: 110; cards: ${hand}"></div>
					<div class="row mt-3">
						<div class="col charNameText">${playerData.charName} <span class="playerPoints" style='color: #dc8df2'>[${playerData.points || ""}]</span>${insured}</div>
					</div>
					<div class="row actionButtons mt-2">
						<button class="btn btn-secondary mt-2 bg-secondary bg-gradient btnGameAction" data-actionid="1" disabled="true">Hit</button>
						<button class="btn btn-secondary mt-2 bg-secondary bg-gradient btnGameAction" data-actionid="2" disabled="true">Stay</button>
						<button class="btn btn-secondary mt-2 bg-secondary bg-gradient btnGameInsurance">Insurance</button>
						<div class="actionText">Waiting</div>
					</div>
				</div>
			`);

			cards.fan($(".playerGameCards[data-playerid='" + playerId + "']").find(".active-hand"));
		};
	}
	else{
		for (const [playerId, playerData] of Object.entries(currentGame.players)){
			// winnings board
			let playerBoard = $(".playerBet[data-playerid='" + playerId + "']");

			if (playerBoard.length > 0){
				let sign = Math.sign(playerData.totalWinnings);

				switch (sign){
					case -1:{
						playerBoard.html(`<span style="color: #f59f9f">$${playerData.totalWinnings}</span>`);
					}
					case 0:{
						playerBoard.html(`$${playerData.totalWinnings}`);
					}
					case 1:{
						playerBoard.html(`$${playerData.totalWinnings}`);
					}
				}
			}

			// cards/actions
			let player = $(".playerGameCards[data-playerid='" + playerId + "']");

			if (player.length > 0){
				let hand = "";
				let insured = "";
				
				playerData.hand.forEach(card => {
					hand += `${card},`;
				});

				if (playerData.insured){
					insured = `<span style="color: skyblue">(Insured)</span>`;
				}

				hand = hand.substr(0, hand.length - 1);
				player.find(".active-hand").data("fan", `spacing: 0.2; width: 110; radius: 110; cards: ${hand}`);

				if (playerData.busted){
					player.find(".actionText").html("BUSTED");
				}
				else if (playerData.staying){
					player.find(".actionText").html("Staying");
				}

				if (!player.find(".active-hand")) console.log("Could not find active-hand.");

				player.find(".playerPoints").html(`[${playerData.points || ""}] ${insured}`);
				cards.fan(player.find(".active-hand"));
			}
			else{
				console.log(`Could not find playerId: ${playerId}`);
			}
		}
	}

	let playerElement = $(".playerGameCards[data-playerid='" + charData.source + "']");

	if (currentGame.currentPlayerTurn == charData.source){
		if (playerElement.length > 0){
			let playerData = currentGame.players[charData.source.toString()];

			playerElement.find(".btnGameAction").show();
			playerElement.find(".actionText").html("");
			$(".btnGameAction").prop("disabled", false);
			
			let insButton = playerElement.find(".btnGameInsurance");
			
			if (insButton.length > 0){
				if (!playerData.insured && playerData.canInsure){
					insButton.show();
				}
			}
			else{
				console.log("Could not find insurance button.");
			}
		}
	}
	else{
		let curTurnPlayer = $(".playerGameCards[data-playerid='" + currentGame.currentPlayerTurn + "']");

		if (curTurnPlayer.length > 0){
			playerElement.find(".btnGameAction").hide();
			playerElement.find(".btnGameInsurance").hide();
			$(".btnGameAction").prop("disabled", true);
			curTurnPlayer.find(".actionText").html("Playing turn..");
		}
	}

	let gameVis = $(".gamingContainer").is(":visible");
	
	if (!gameVis){
		$(".gamingContainer").fadeIn();
	}

	$(".readyUpRoom").hide();
	$(".playerCards").fadeIn();
}

function updateReadyRoom(data){
	$(".gamingContainer").show();

	currentGame = data.game;
	let room = $(".readyUpRoom");
	let anchor = $(".readyUpAnchor");
	
	if (!data.toggle){
		anchor.fadeOut();
		return;
	}
	
	anchor.children().remove();
	for (const [playerId, playerData] of Object.entries(currentGame.players)){
		let readyHtml = "";
		
		if (playerId == charData.source){
			playerData.readyStatus === true ? readyHtml = `<button class="btn btn-success btnReadyUpToggle">Ready</button>` : readyHtml = `<button class="btn btn-warning btnReadyUpToggle">Not Ready</button>`;
		}
		else{
			playerData.readyStatus === true ? readyHtml = `<div class="success rounded p-2">Ready</div>` : readyHtml = `<div class="warning rounded p-2">Not Ready</div>`;
		}
		
		anchor.append(`
			<div class="row player m-4 pt-2" data-playerid="${playerId}">
				<div class="col">
					${playerData.charName}
				</div>
				<div class="col playerBet">
					${readyHtml}
				</div>
			</div>
		`);
	};

	room.fadeIn();
}

function renderFinalScore(game, timerTime){
	let anchor = $(".finalScoresAnchor");
	let players = game.players;

	anchor.children().remove();

	for (const [playerId, playerData] of Object.entries(players)){
		let busted = "";
		let winnings = "";

		if (playerData.busted){
			busted = "<span style='color: #ffcf99'>(BUSTED)</span>";
		}

		let sign = Math.sign(playerData.lastWinnings);

		switch (sign){
			case -1:{
				winnings = `<span style="color: #f59f9f">$${playerData.lastWinnings}</span>`;
			}
			case 0:{
				winnings = "$" + playerData.lastWinnings;
			}
			case 1:{
				winnings = `<span style="color: #30c0a8">$${playerData.lastWinnings}</span>`;
			}
		}
		
		anchor.append(`
			<div class="col">
				<div class="row">
					<div class="col">
						${playerData.charName}
					</div>
				</div>
				<div class="row">
					<div class="col">
						${playerData.lastScore} ${busted}
					</div>
				</div>
				<div class="row">
					<div class="col">
						Take: ${winnings}
					</div>
				</div>
			</div>
		`);
	}

	curTimer = timerTime / 1000;
	scoreTimerInterval = setInterval(function(){
		curTimer -= 1;
		$(".timerAnchor").html(`Time until next round: ${curTimer} seconds.`);
	}, 1000);

	setTimeout(function(){
		clearInterval(scoreTimerInterval);
		$(".finalScore").hide();
	}, timerTime);
}

function showLeaveWarning(){
	alertify.defaults.theme.ok = "btn btn-danger";
  alertify.defaults.theme.cancel = "btn btn-dark";
  alertify.confirm("Leave Game", "If you leave during an active game you will be charged your current bet.", function(e){
    if (e){
			resetGame();
      sendData("bms:gaming:playerLeaveGame", "");
    }
  }, null).set({
    labels:{
      ok: "Leave Game",
      cancel: "Cancel"
    },
    delay: 5000,
    buttonReverse: false,
    buttonFocus: "ok",
    transition: "fade"
  });
}

/* Slots */
function setupSlots(){
	//console.log("Setting up slots canvas.");
	setupSlotAudio();

	for (let i = 0; i < slots.length; i++){
    let slot = slots[i];
    let casino = $(slot.sid)[0];
    let tempSlot = new SlotMachine(casino, {
      active: i,
      delay: 500,
			onComplete: onSlotSpinComplete
    });
    
    slot.ref = tempSlot;
  }
}

// Slot positions must match to trigger the right audio event
function setupSlotAudio(){
	slotsAudio["1"] = [
		"slot_wheel_spin", // on wheel spin
		"slots_winner", // on jackpot
		"ar_firing", // on spin button click
		"ar_reloading", // on bet button click
		"slot_jackpot" // jackpot hit
	],
	slotsAudio["2"] = [
		"slot_wheel_spin",
		"slots_winner_scary",
		"scary_whoosh",
		"knife_stab",
		"slot_jackpot_scary"
	],
	slotsAudio["3"] = [
		"slot_wheel_spin",
		"egyptian1",
		"eagle",
		"egyptian_bell",
		"slot_jackpot"
	]
}

function destroySlots(){
	for (let i = 0; i < slots.length; i++){
		if (slots[i].ref){
			slots[i].ref.destroy();
			slots[i].ref = null;
		}
	}
}

function spinSlots(){
	canExitSlots = false;
	slots.forEach((slot, slotIndex) => {
		if (slot.ref != 0){
			slot.ref.shuffle(99999);
			slot.ref.changeSettings({randomize: function(){
				return tileCombo[(slotIndex + 1).toString()] - 1;
			}});
		}
		else{
			console.log("Could not find shuffle reference!");
		}
	});
	
	setTimeout(function(){
		slots.forEach((slot, slotIndex) => {
			setTimeout(function(){
				if (slot.ref && slot.ref != null){
					slot.ref.stop();
				}
			}, slotDelays.betweenSlots * (slotIndex + 1));
		});
	}, slotDelays.initial);
}

function onSlotSpinComplete(){
	wheelsComplete++;

	if (wheelsComplete == 3){
		wheelsComplete = 0;
		sendData("bms:gaming:slots:slotSpinComplete", "");
		canExitSlots = true;
	}
}

/* General */
function sendData(name, data){
	$.post("https://gaming/" + name, JSON.stringify(data), function(datab) {
    	console.log(datab);
	});
}

function playSound(sound) {
  sendData("playsound", {name: sound});
}

function playSoundClient(sound, volume){
	sendData("playSoundClient", {sound: sound, volume: volume});
}

// Special audio sender for slots by indexes
function playSlotSoundClient(audioIndex, volume){
	let audioBank = slotsAudio[lastMachineType.toString()];

	if (audioBank && audioBank[audioIndex - 1]){
		sendData("playSoundClient", {sound: audioBank[audioIndex - 1], volume: volume});
	}
}