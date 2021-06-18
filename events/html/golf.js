$(function(){
  var scoreboard = $("#golfScoreboard");
  
  window.addEventListener("message", function(event) {
    var item = event.data;

    if (item.showScoreboard)
    {
      var scores =  item.scores
      if (scores) 
      {
        var numScores = scores.length;
        var i = 0;
        var j = 0;
        for (i = 0; i < numScores; i ++)
        {
          if (scores[i])
          {
            changeScore(j, scores[i]);
            showScore(j);
            j = j + 1;
          }
        }
        for (;j < 8; j ++) 
        {
          hideScore(j);
        }
      } else {
        var i;
        for (i = 0; i < 8; i ++)
        {
          hideScore(i);
        }
      }
      scoreboard.show();
    }
    else if (item.hideScoreboard)
    {
      scoreboard.hide();
    }
  });
});

function changeScore(row, data){
  var x = document.getElementById("scoreTable").rows;
  var y = x[row + 2].cells; // add 2 to skip holes and par
  var arrLen = y.length;
  var i = 0;
  var total = 0;
  for (i = 0; i < arrLen - 1; i++)
  {
    if (i == 0) // player name
    {
      y[i].innerHTML = data.name;
    } else {
      if (data.score && data.score[i - 1])
      {
        total = total + data.score[i - 1];
        y[i].innerHTML = data.score[i - 1];
      } else
      {
        y[i].innerHTML = "";
      }
    }
  }
  y[i].innerHTML = total;
}

function hideScore(row) {
  var row1 = $("#row1");
  var row2 = $("#row2");
  var row3 = $("#row3");
  var row4 = $("#row4");
  var row5 = $("#row5");
  var row6 = $("#row6");
  var row7 = $("#row7");
  var row8 = $("#row8");
  switch(row) {
    case 0:
      row1.hide();
      break;
    case 1:
      row2.hide();
      break;
    case 2:
      row3.hide();
      break;
    case 3:
      row4.hide();
      break;
    case 4:
      row5.hide();
      break;
    case 5:
      row6.hide();
      break;
    case 6:
      row7.hide();
      break;
    case 7:
      row8.hide();
      break;
  }
}

function showScore(row) {
  var row1 = $("#row1");
  var row2 = $("#row2");
  var row3 = $("#row3");
  var row4 = $("#row4");
  var row5 = $("#row5");
  var row6 = $("#row6");
  var row7 = $("#row7");
  var row8 = $("#row8");
  switch(row) {
    case 0:
      row1.show();
      break;
    case 1:
      row2.show();
      break;
    case 2:
      row3.show();
      break;
    case 3:
      row4.show();
      break;
    case 4:
      row5.show();
      break;
    case 5:
      row6.show();
      break;
    case 6:
      row7.show();
      break;
    case 7:
      row8.show();
      break;
  }
}
