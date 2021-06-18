let windowAnchor;
let accountManager;
let bankingContainer;
let memberPermissions;
let memberActions;
let accountMembersContainer;
let accountDetailsContainer;
let accountActivityContainer;
let memberList;
let statusText;
let playerAccounts = [];
let blockCreate = false;
let blockTransactions = false;
let blockAddMember = false;
let blockPermChange = false;
let blockDirectDeposit = false;
let blockGetActivity = false;
let deleteConfirm = false;
let activeAccountId;
let activeMemberId;
let hoverPanelFollowMouse = false;

$(function(){
  windowAnchor = $(".dragArea");
  accountManager = $(".accountManager");
  bankingContainer = $(".bankingContainer");
  accountMembersContainer = $(".accMgr-accountMembers");
  accountDetailsContainer = $(".accMgr-accountDetails");
  accountActivityContainer = $(".accMgr-accountActivity");
  memberList = $(".accMgr-memberList");
  memberPermissions = $(".accMgr-memberPermissions");
  memberActions = $(".memberActions");
  statusText = $(".statusText");

  window.addEventListener("message", function(event){
    var data = event.data;

    if (data.openatm){
      $("#atm").show();
      $("#balance").html("$" + data.balance.toLocaleString());
      $("#amount").val("");

      if (data.type == 1){
        $("#headtext").html("Bank of Southern California");
      }
      else{
        $("#headtext").html("Bank of Southern California A.T.M.");
      }
    }
    else if (data.closeatm){
      $("#atm").hide();
    }
    else if (data.showBankingWindow){
      bankingContainer.fadeIn();
    }
    else if (data.openAccounts){
      accountMembersContainer.hide();
      memberActions.hide();
      accountActivityContainer.hide();
      $(".statusText").html("");
      statusText.hide();

      if (data.accounts){
        playerAccounts = data.accounts;
        renderAccounts(data.accounts);
      }

      if (!data.skipShow){
        bankingContainer.fadeIn();
      }
    }
    else if (data.blockCreate){
      blockCreate = data.val;
      $(".dailyCheckType").attr("disabled", false);
    }
    else if (data.blockTransactions){
      blockTransactions = data.val;
      blockTransactions == true ? $(".btnConfirmTransaction").removeClass("btn-success").addClass("btn-danger") : $(".btnConfirmTransaction").removeClass("btn-danger").addClass("btn-success");
      blockTransactions == true ? $(".btnConfirmTransaction").html("Working..") : $(".btnConfirmTransaction").html("Confirm Transaction");
    }
    else if (data.blockAddMember){
      blockAddMember = data.val;

      if (blockAddMember === false){
        $(".btnAddMemberToAccountText").html("Add");
        $(".btnAddMemberToAccount").removeClass("btn-danger").addClass("btn-dark");
      }
    }
    else if (data.blockPermChange){
      blockPermChange = data.val;

      $(".memberPermCb").prop("disabled", blockPermChange);
      $(".btnDeleteAccountMember").prop("disabled", blockPermChange);
      $(".spinnersavingperms").stop().fadeOut();
    }
    else if (data.blockDirectDeposit){
      blockDirectDeposit = data.val;

      if (!blockDirectDeposit){
        $(".btnSubmitAccountDeposit").removeClass("btn-danger").addClass("btn-success");
        $(".btnSubmitAccountDeposit").html("Submit Donation");
        $(".btnSubmitAccountDeposit").prop("disabled", false);
      }
    }
    else if (data.blockGetActivity){
      blockGetActivity = data.val;
    }
    else if (data.updateStatusText){
      if (data.msgDialog){
        showDialog(data.text);
      }
      else{
        setAccountStatusText(data.text);
      }
    }
    else if (data.checkUpdateAccount){
      checkAccountUpdate(data.accountid, data.accountData)
    }
    else if (data.updateAccountField){
      updateAccountField(data.data);
    }
    else if (data.updateMembers){
      if (activeAccountId){
        playerAccounts[activeAccountId].members = data.members;
      }

      renderMembers(data.members);
    }
    else if (data.updateMember){
      playerAccounts[data.accountid].members[data.memberid] = data.changedMember;

      if (data.charname){
        playerAccounts[data.accountid].members[data.memberid].charname = data.charname;
      }

      renderMembers(playerAccounts[data.accountid].members);
    }
    else if (data.updateBankAtmStatus){
      $(".bankAtmStatusText").html(data.text);
    }
    else if (data.updateXferLogs){
      if (data.logs){
        renderActivityLog(data.logs);
      }
    }
    else if (data.deleteMember){
      if (data.accountid && data.memberid){
        let account = playerAccounts[data.accountid];
        
        delete account.members[data.memberid.toString()];
        renderMembers(account.members);
      }
    }
    else if (data.closeBankAccounts){
      bankingContainer.fadeOut();
      accountManager.hide();
      sendData("bms:banking:closeBankManager", "");
    }
    else if (data.removeAccount){
      removeAccount(data.accountid);
    }
    else if (data.setBankDailyCheckDepType){
      if (data.depType > 1){
        $(".dailyCheckType[data-val='" + data.depType + "']").prop("checked", true);
      }
    }
  });

  $("#withdraw").click(function(){
    var amt = parseInt($("#amount").val());

    if (amt && amt > 0){
      $("#atm").hide();
      sendData("bms:banking:withdraw", {amount: amt});
    }
    else{
      $("#errortext").html("You must enter a positive number.");
    }
  });

  $("#deposit").click(function(){
    var amt = parseInt($("#amount").val());

    if (amt && amt > 0){
      $("#atm").hide();
      sendData("bms:banking:deposit", {amount: amt});
    }
    else{
      $("#errortext").html("You must enter a positive number.");
    }
  });

  $("#exitatm").click(function(){
    $("#atm").hide();
    sendData("closeatm", "");
    $("#giveAccountFolding").collapse("hide");
    $("#accountNumber").val("");
    $("#accountDepositAmount").val("");
    $("#accountDepositMessage").val("");
    $(".bankAtmStatusText").html("");
    $("#errortext").html("");
  });

  $(".btnSubmitAccountDeposit").click(function(){
    let accountid = parseInt($("#accountNumber").val());
    let amount = parseInt($("#accountDepositAmount").val());
    let message = $("#accountDepositMessage").val();

    if (blockDirectDeposit) return;

    if (message && message.length > 0){
      message = message.replace(/(<([^>]+)>)/gi, ""); // strip any html
    }

    console.log(message);

    if (amount && amount > 0){
      if (accountid){
        blockDirectDeposit = true;
        $(".btnSubmitAccountDeposit").prop("disabled", true);
        $(".btnSubmitAccountDeposit").removeClass("btn-success").addClass("btn-danger");
        $(".btnSubmitAccountDeposit").html("Working..");
        let deptype = parseInt($(".radioButtonAccountDepositFrom:checked").data("type"));
        let anon = $(".accountDepositAnon").is(":checked");

        sendData("bms:banking:submitAccountDonation", {accountid: accountid, amount: amount, deptype: deptype, anon: anon, message: message});
        $("#accountNumber").val("");
        $("#accountDepositAmount").val("0");
      }
      else{
        $("#errortext").html("You must enter an account number.");
      }
    }
    else{
      $("#errortext").html("You must enter a positive value number amount.");
    }
  });

  /* Bank Managers */
  $(document).on("click", ".evClose", function(){
    $(this).closest(".evcontainer").remove();
  });

  $(document).on("click", ".accMgr-Close", function(){
    accountManager.fadeOut();
  });

  $(document).on("mouseover", ".accMgr-accountEntry", function(){
    $(this).find(".rarrow").stop().fadeIn();
  });
  
  $(document).on("mouseout", ".accMgr-accountEntry", function(){
    $(".rarrow").stop().fadeOut();
  });

  $(document).on("click", ".accMgr-accountEntry", function(){
    let accid = parseInt($(this).data("accountid"));
    activeAccountId = accid;
    let account = playerAccounts[accid.toString()];
    let perms = account.userPerms;

    perms && !perms.w ? $(".rbTransType[data-id='1']").hide() : $(".rbTransType[data-id='1']").show();
    perms && !perms.d ? $(".rbTransType[data-id='2']").hide() : $(".rbTransType[data-id='2']").show();

    $(".accMgr-accountEntry").removeClass("selectedAccount");
    $(this).addClass("selectedAccount");
    $(".rarrow").removeClass("selected");
    $(".memberedit").stop().fadeOut();
    $(".viewactivity").stop().fadeOut();
    $(this).find(".rarrow").addClass("selected");

    if (perms && !perms.w && perms.d){
      $("#dollarAmountLabel").html(`Deposit into account: '${$(this).data("fname")}'`);
      $("#labelRadioBankAccount").html("Deposit from Bank Account");
      $("#labelRadioCharacter").html("Deposit from Person");
      $(".rbTransType[data-id='2']").trigger("click");
    }
    else{
      $("#dollarAmountLabel").html(`Withdraw from account: '${$(this).data("fname")}'`);
      $(".rbTransType[data-id='1']").trigger("click");
    }
    
    if (account.accountOwner){
      $(this).find(".memberedit").stop().fadeIn();
    }

    if (account.accountOwner || perms && perms.va){
      $(this).find(".viewactivity").stop().fadeIn();
    }

    accountDetailsContainer.stop().show();
    accountMembersContainer.stop().hide();
    accountActivityContainer.stop().hide();
    memberActions.stop().fadeIn();
  });

  $(document).on("click", ".accMgr-memberEntry", function(){
    $(".accMgr-memberEntry").removeClass("selectedMember");
    $(this).addClass("selectedMember");
    $(".memberapplyperms").stop().fadeOut();
    let memberid = parseInt($(this).data("memberid"));
    let account = playerAccounts[activeAccountId];

    activeMemberId = memberid;

    if (account && account.members && account.members[memberid]){
      let perms = account.members[memberid].perms;

      $(".memberPerm-deposit").prop("checked", perms.d);
      $(".memberPerm-withdraw").prop("checked", perms.w);
      $(".memberPerm-viewBalance").prop("checked", perms.vb);
      $(".memberPerm-viewActivity").prop("checked", perms.va);
      $(".memberPermCb").prop("disabled", false);
      $(".btnDeleteAccountMember").prop("disabled", false);
    }
  });

  $(".startMenuItem").click(function(){
    let action = parseInt($(this).data("id"));

    switch (action){
      case 1: { // manager
        accountManager.fadeIn();
        break;
      }
      case 2: { // open new
        if (!blockCreate){
          if (accountManager.is(":visible")){
            accountManager.fadeOut();
          }

          setAccountStatusText("");
          alertify.defaults.theme.ok = "btn btn-success";
          alertify.defaults.theme.cancel = "btn btn-dark";
          alertify.prompt("Create Account", "Enter your account name.  Max 20 characters.", "", function(e, name){
            if (e){
              if (name.length > 20){
                setAccountStatusText("Account names must be less than 20 characters.");
              }
              else{
                if (name.length > 0){
                  sendData("bms:banking:createAccount", {name: name});
                  blockCreate = true;
                }
                else{
                  setAccountStatusText("You must enter an account name.");
                }
              }
            }
          }, null).set({
            labels:{
              ok: "Create",
              cancel: "Cancel"
            },
            delay: 5000,
            buttonReverse: false,
            buttonFocus: "ok",
            transition: "fade"
          });
        }
        break
      }
      case 3: { //close
        bankingContainer.fadeOut();
        accountManager.hide();
        sendData("bms:banking:closeBankManager", "");
        break;
      }
    }
  });

  $(document).on("click", ".memberedit", function(event){
    event.stopPropagation();

    let parent = $(this).parent().parent().parent();
    let accountid = parent.data("accountid");
    let account = playerAccounts[accountid];
    let visible = accountMembersContainer.is(":visible");

    if (!account.accountOwner) return;

    if (account){      
      if (account.accountOwner){
        visible ? accountMembersContainer.stop().fadeOut() : accountMembersContainer.stop().fadeIn();
        visible ? memberPermissions.stop().fadeOut() : memberPermissions.stop().fadeIn();
        renderMembers(account.members);
      }

      visible ? memberActions.stop().fadeIn() : memberActions.stop().hide();
    }
    else{
      console.log(`Could not find account >> ${accountid}, ${JSON.stringify(account)}`);
    }
  });

  $(document).on("click", ".memberPermCb", function(){
    if (!activeMemberId || blockPermChange) return;

    $(".accMgr-memberEntry.selectedMember").find(".memberapplyperms").fadeIn();
  });

  $(document).on("click", ".memberapplyperms", function(event){
    event.stopPropagation();
    if (blockPermChange) return;  
    
    let root = $(this).parent().parent().parent();
    let memberid = parseInt(root.data("memberid"));
    let withdraw = $(".memberPerm-withdraw").is(":checked");
    let deposit = $(".memberPerm-deposit").is(":checked");
    let viewbalance = $(".memberPerm-viewBalance").is(":checked");
    let viewactivity = $(".memberPerm-viewActivity").is(":checked");

    if (!withdraw && !deposit){
      setAccountStatusText("You must permit either Withdraw or Deposit permissions.  They can not both be disabled.");
    }
    else{
      blockPermChange = true;
      $(".memberPermCb").prop("disabled", true);
      $(this).stop().fadeOut();
      $(this).siblings(".spinnersavingperms").fadeIn();
      sendData("bms:banking:changePermissions", {accountid: activeAccountId, memberDbid: memberid, permissions: {deposit: deposit, withdraw: withdraw, viewBalance: viewbalance, viewActivity: viewactivity}});
    }
  });

  $(".radioButtonsTransactionType button").click(function(){
    $(this).addClass("active").siblings().removeClass("active");
    let accountFriendlyName = $(".accMgr-accountEntry.selectedAccount");
    let text = "Withdraw to ";
    $("#dollarAmountLabel").html(`Withdraw from account: '${accountFriendlyName.data("fname")}'`);

    if ($(this).data("id") == "2"){
      text = "Deposit from ";
      $("#dollarAmountLabel").html(`Deposit into account: '${accountFriendlyName.data("fname")}'`);
    }

    $("#labelRadioBankAccount").html(text + " Bank Account");
    $("#labelRadioCharacter").html(text + " Person");
  });

  $(".btnConfirmTransaction").click(function(){
    let amount = parseInt($("#dollarAmount").val());
    let sourceOrDest = parseInt($(".radioButtonSourceOrDestType:checked").data("type"));
    let transType = parseInt($(".rbTransType.active").data("id"));

    if (!blockTransactions && amount && amount != "NaN" && amount != undefined && amount > 0 && transType && sourceOrDest){
      blockTransactions = true;
      $(".btnConfirmTransaction").removeClass("btn-success").addClass("btn-danger");
      $(".btnConfirmTransaction").html("Working..");
      sendData("bms:banking:submitBankingTransaction", {accountid: activeAccountId, amount: amount, sourceOrDest: sourceOrDest, transType: transType});
      resetTransactionFields();
    }
    else{
      if (blockTransactions){
        setAccountStatusText("Transactions are blocked for this account.  An error may have occured.  Try again in a moment.");
      }
      else{
        setAccountStatusText("Enter a whole number greater than zero.  No funny business.");
      }
    }
  });

  $(".btnAddMemberToAccount").click(function(){
    let name = $("#textMemberAdd").val();

    if (name && name.length > 0 && !blockAddMember){
      blockAddMember = true;
      $(".btnAddMemberToAccountText").html("Working..");
      $(".btnAddMemberToAccount").removeClass("btn-dark").addClass("btn-danger");
      sendData("bms:banking:addMemberToAccount", {accountid: activeAccountId, name: name});
    }
  });

  $(".btnDeleteAccountMember").click(function(){
    if (deleteConfirm){
      deleteConfirm = false;
      sendData("bms:banking:deleteAccountMember", {accountid: activeAccountId, memberid: activeMemberId});
      $(".btnDeleteAccountMember").html("Delete Member");
      $(".btnDeleteAccountMemberCancel").stop().fadeOut();
      $(".memberPermCb").prop("disabled", true);
    }
    else{
      deleteConfirm = true;
      $(".btnDeleteAccountMember").html("Confirm Delete?");
      $(".btnDeleteAccountMemberCancel").stop().fadeIn();
    }
  });

  $(".btnDeleteAccountMemberCancel").click(function(){
    deleteConfirm = false;
    $(".btnDeleteAccountMemberCancel").stop().fadeOut();
    $(".btnDeleteAccountMember").html("Delete Member").fadeOut();
  });

  $(document).on("mouseenter", "i", function(){
    let title = $(this).prop("title");
    let tpos = $(this).data("tpos");

    if (title && title.length > 0){
      tpos == "right" ? $("#hoverText-right").html(title) : $("#hoverText").html(title);
    }
  });

  $(document).on("mouseleave", "i", function(){
    $("#hoverText").html("");
    $("#hoverText-right").html("");
  });

  $(document).on("click", ".viewactivity", function(event){
    event.stopPropagation();
    if (blockGetActivity) return;
    
    let account = playerAccounts[activeAccountId];

    if (account && (account.accountOwner || (account.userPerms && account.userPerms.va))){
      blockGetActivity = true;
      sendData("bms:banking:getAccountActivity", {accountid: activeAccountId});
    }
  });

  $(document).on("mouseenter", ".hoverable", function(){
    let panel = $(".hoverPanel");
    let ptext = $(".hoverPanelText");
    let message = $(this).prop("title");

    if (message && message.length > 0){
      ptext.html(message);
      panel.stop().fadeIn();
      hoverPanelFollowMouse = true;
    }
  });

  $(document).on("mouseleave", ".hoverable", function(){
    $(".hoverPanel").stop().fadeOut();
    hoverPanelFollowMouse = false;
  });

  $(document).on("click", ".btnDeleteAccount", function(){
    deleteAccount();
  });

  $(document).on("mousemove", function(e){
    if (!hoverPanelFollowMouse) return;

    $(".hoverPanel").css({left: e.pageX - $(".hoverPanel").width() / 2, top: e.pageY + 10});
  });

  $(".btnLeaveAccount").click(function(){
    leaveAccount();
  });

  $(".dailyCheckType").on("change", function(){
    if (blockCreate) return;
    
    let val = parseInt($(this).data("val"));
    
    if (val){
      blockCreate = true;
      $(".dailyCheckType").attr("disabled", true);
      sendData("bms:banking:setDailyCheckType", {val: val});
    }
  });

  bankingContainer.css("left", $(document).width() / 2 - (bankingContainer.width() / 2));
  bankingContainer.css("top", $(document).height() / 2 - (bankingContainer.height() / 2));
});

function arrayDeleteByKey(arr, key){
  let keys = Object.keys(arr);
  let delidx = -1;

  for (let i = 0; i < keys.length; i++){
    if (keys[i] == key){
      delidx = i;
      break;
    }
  }

  if (delidx > -1){
    return arr.splice(delidx, 1);
  }
}

function formatDateFromLua(date){
  if (!date) return "N/A";

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

// Alertify generic dialog
function showGenericDialog(element){
  if (!element) return;

  alertify.genericDialog || alertify.dialog("genericDialog", function(){
    return {
      main: function(content){
        this.setContent(content);
      },
      setup: function(){
        return {
          focus: {
            element: function(){
              return this.elements.body.querySelector(this.get("selector"));
            },
            select: true
          },
          options: {
            basic: true,
            maximizable: false,
            resizable: false,
            padding: false
          }
        };
      },
      settings: {
        selector: undefined
      }
    };
  });

  alertify.genericDialog(element[0]);
}

function showDialog(msg){
  alertify.defaults.theme.ok = "btn btn-success";
  alertify.alert("Bank of SoCal", `<span style="color: white;">${msg}</span>`).set({
    transition: "fade"
  });
}

function deleteAccount(){
  if (blockCreate) return;

  setAccountStatusText("");
  alertify.defaults.theme.ok = "btn btn-danger";
  alertify.defaults.theme.cancel = "btn btn-dark";
  alertify.confirm("Delete Account", "Deleted bank accounts can NOT BE RECOVERED.  Click Delete if you understand.", function(e){
    if (e){
      sendData("bms:banking:deleteAccount", {accountid: activeAccountId});
      blockCreate = true;
    }
  }, null).set({
    labels:{
      ok: "Delete",
      cancel: "Cancel"
    },
    delay: 5000,
    buttonReverse: false,
    buttonFocus: "ok",
    transition: "fade"
  });
}

function leaveAccount(){
  if (blockCreate) return;

  setAccountStatusText("");
  alertify.defaults.theme.ok = "btn btn-danger";
  alertify.defaults.theme.cancel = "btn btn-dark";
  alertify.confirm("Leave Account", "Are you sure you want to leave this account?  To be added back, you would need the account owner to readd you.", function(e){
    if (e){
      sendData("bms:banking:leaveAccount", {accountid: activeAccountId});
      blockCreate = true;
    }
  }, null).set({
    labels:{
      ok: "Leave It",
      cancel: "Cancel"
    },
    delay: 5000,
    buttonReverse: false,
    buttonFocus: "ok",
    transition: "fade"
  });
}

function removeAccount(accountid){
  accountMembersContainer.stop().hide();
  memberActions.stop().hide();
  activeAccountId = null;
  activeMemberId = null;
  $(".accMgr-accountEntry[data-accountid='" + accountid + "']").remove();
}

function resetTransactionFields(){
  setAccountStatusText("");
  $("#dollarAmount").val("");
  $("#rbTransWithdraw").prop("checked", true); // trans type button group
  $("#radioBankAccount").prop("checked", true);
}

function checkAccountUpdate(accountid, accountData){
  let visible = $(".bankingContainer").is(":visible");

  if (visible){
    if (playerAccounts[accountid.toString()]){
      playerAccounts[accountid.toString()] = accountData
      renderAccounts(playerAccounts);
    }
  }
}

function updateAccountField(data){
  let accid = data.accountid;
  let field = data.field;
  let fieldData = data.fieldData;
  let visible = $(".bankingContainer").is(":visible");

  if (!visible || !accid || !field || !fieldData) return;

  if (playerAccounts[accid.toString()][field] !== null){
    playerAccounts[accid.toString()][field] = fieldData;
  }
  else{
    console.log(`Could not find account by id ${accid}`);
  }

  if (!data.skipRender){
    renderAccounts(playerAccounts);
  }
}

function renderAccounts(accounts){
  $(".accMgr-accountList").children().remove();

  let keys = Object.keys(accounts);

  for (let i = 0; i < keys.length; i++){
    let accountid = keys[i];
    let account = accounts[accountid];
    let perms = account.userPerms;
    let vaStr = `<i class="fad fa-clipboard viewactivity ml-1 mr-1" style="display: none"></i>`;
    let vbStr = `<span class="mr-2 ml-1 balanceText">[$${account.amount}]</span>`;

    if (account.accountOwner || perms){
      if (!account.accountOwner && !perms.va){
        vaStr = "";
      }

      if (!account.accountOwner && !perms.vb){
        vbStr = `<span class="mr-2 ml-1">[Balance Hidden]</span>`;
      }
    }

    $(".accMgr-accountList").append(`
      <div class="row accMgr-accountEntry p-1" data-accountid="${accountid}" data-fname="${account.friendlyName}">
        <div class="col">
          <span><span class="darktext">[${accountid}]</span> ${account.friendlyName}</span>
          <span class="float-right">
            <i class="fas fa-arrow-right rarrow" style="display: none"></i>
            ${vaStr}
            <i class="fas fa-user-edit memberedit ml-1 mr-1" style="display: none" title="Edit Account Members"></i>
            ${vbStr}
          </span>
        </div>
      </div>
    `);
  }

  if (activeAccountId > 0){
    $(".accMgr-accountEntry[data-accountid='" + activeAccountId + "']").trigger("click");
  }
}

function renderMembers(members){
  console.log(JSON.stringify(members));
  $(".accMgr-memberList").children().remove();

  let keys = Object.keys(members);

  for (let i = 0; i < keys.length; i++){
    let memberid = keys[i];
    let member = members[memberid];

    $(".accMgr-memberList").append(`
      <div class="row accMgr-memberEntry p-1" data-memberid="${memberid}">
        <div class="col">
          <span>${member.charname || "Error occured"}</span>
          <span class="float-right">
            <i class="fas fa-check memberapplyperms mt-1" style="display: none" title="Apply Permission Changes" data-tpos="right"></i>
            <i class="fas fa-spinner spinnersavingperms mt-1" style="display: none" title="Permissions saving.." data-tpos="right"></i>
          </span>
        </div>
      </div>  
    `);
  }

  accountActivityContainer.hide();
  accountDetailsContainer.stop().fadeIn();
}

function renderActivityLog(log){
  let anchor = $(".accMgr-accountActivityContentAnchor");

  anchor.children().remove();
  
  for (let i = 0; i < log.length; i++){
    console.log(JSON.stringify(log[i]));
    let entry = log[i];
    let dispName = entry.charname;
    let transType = "Deposit";
    let message = entry.msg;
    let msgstr = "N/A";

    if (entry.mem == 0){
      dispName = "Anonymous";
    }

    if (entry.dir == 2){
      transType = "Withdrawal";
    }

    if (message){
      msgstr = `<a href="#" class="hoverable" title="${message}">[Hover to View]</a>`;
    }

    anchor.append(`
      <tr>
        <th scope="row">${dispName}</th>
        <td>${entry.am}</td>
        <td>${transType}</td>
        <td>${msgstr}</td>
        <td>${formatDateFromLua(entry.time)}</td>
      </tr>
    `);
  }
  
  accountDetailsContainer.hide();
  accountActivityContainer.stop().fadeIn();
}

function setAccountStatusText(text){  
  let visible = statusText.is(":visible");
  
  if (!text || text === ""){
    statusText.html("");
    statusText.hide();
    return;
  }

  visible ? statusText.html(text).delay(8000).fadeOut() : statusText.html(text).stop().fadeIn().delay(8000).fadeOut();
}

// dynamic window spawning
function createWindow(name, title, content, showImmediate){
  name = "#evContainer_" + name;
  let newWindow = $("#evTemplate").clone("#evTemplate");
  
  windowAnchor.append(newWindow);
  
  if (newWindow.length > 0){
    if (title){
      newWindow.find(".titleContent").html(title);
    }
    
    if (content){
      newWindow.find(".evContentAnchor").html(content);
    }
    
    newWindow.draggable({
      containment: "parent",
      handle: "#evDragHeader"
    });

    newWindow.resizable({
      animate: true,
      handles:{
        se: ".resizer-handle"
      },
      ghost: true,
      resize: function(ev, ui){
        newWindow.find(".evmenu").css("height", ui.size.height - 125 + "px");
      }
    });
    
    if (showImmediate){
      newWindow.fadeIn();
    }
  }
  else{
    console.log("length 0 for clone.");
  }
}

function sendData(name, data){
	$.post("http://banking/" + name, JSON.stringify(data), function(datab) {
    	console.log(datab);
	});
}

function playSound(sound) {
    sendData("playsound", {name: sound});
}