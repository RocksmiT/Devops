function bieldObjs(json) {
    let objArr = [];
    let objCount = 0;

    //Object areas
    objArr[0] = {
        name: json.history[0].market_name,
        color: json.history[0].name_color,
        sellCount: 0,
        buyCount: 0,
        buy: 0,
        sell: 0,
        profit: 0,
        percentProfit: 0,
        averageProfit: 0,
        averagePercentProfit: 0
    }

    //First object
    if (json.history[0].h_event == "buy_go") {
        objArr[0].buyCount += 1;
        objArr[0].buy += Number(json.history[0].paid);
    }
    if (json.history[0].h_event == "sell_go") {
        objArr[0].sellCount += 1;
        objArr[0].sell += Number(json.history[0].recieved);
    }
    for (let i = 1; i < json.history.length; i++) {
        let findName = false;
        for (let j = 0; j < objCount + 1; j++) {
            if (objArr[j].name == json.history[i].market_name) {
                findName = true;

                if (json.history[i].h_event == "buy_go") {
                    objArr[j].buyCount += 1;
                    objArr[j].buy += Number(json.history[i].paid);
                    break;
                }
                if (json.history[i].h_event == "sell_go") {
                    objArr[j].sellCount += 1;
                    objArr[j].sell += Number(json.history[i].recieved);
                    break;
                }
            }
        }
        if (!findName) {
            //console.log('TRUE');
            objArr.push({
                name: json.history[i].market_name,
                color: json.history[i].name_color,
                sellCount: 0,
                buyCount: 0,
                buy: 0,
                sell: 0,
                difference: 0,
                percentProfit: 0,
                averageProfit: 0,
                averagePercentProfit: 0
            });
            if (json.history[i].h_event == "buy_go") {
                objArr[objCount].buyCount += 1;
                objArr[objCount].buy += Number(json.history[i].paid);
            } else {
                objArr[objCount].sellCount += 1;
                objArr[objCount].sell += Number(json.history[i].recieved);
            }
            objCount++;
        }
    }

    //calculate all areas
    for (let i = 0; i < objCount; i++) {
        objArr[i].buy = toRUB(objArr[i].buy);
        objArr[i].sell = toRUB(objArr[i].sell);
        objArr[i].difference = calcDifference(objArr[i]);
        //calcPercentProfit(objArr[i]);
        //calcAverageProfit(objArr[i]);
        //calcAveragePercentProfit(objArr[i]);
    }
    showTable(objArr);
}

function toRUB(str) {
    str = str.toString();
    str = str.split('');
    str.splice(str.length - 2, 0, ",");
    str = str.join('');
    return str;
}

function calcDifference(obj) {
    let res = obj.sell - obj.buy;
    res = toRUB(res);
    return res;
}

function calcPercentProfit(obj) {

}

function calcAverageProfit(obj) {

}

function calcAveragePercentProfit(obj) {

}

function showTable(objArr) {
    row = document.getElementById('table');
    let output = [];
    output.push('<tr><th>#</th><th>назва</th><th></th><th>продано</th><th>середнє</th><th>середнє в %</th><th>profit</th><th>в %</th></tr>');
    for (let i = 0; i < objArr.length; i++) {
        let style = 'style="color: #' + objArr[i].color + '"';
        output.push('<tr><td>',
            i+1,
            '</td><td ',
            style,        
            '>',
            objArr[i].name,
            '</td><td>',
            objArr[i].buy,
            '</td><td>',
            objArr[i].sell,
            '</td><td>',
            objArr[i].difference,
            '<td></tr>');
        row.innerHTML = output.join('');
    }
}

$.ajax({
    url: 'json.json',
    success: function (data) {
        bieldObjs(data);
    }
})






/*$.getJSON( "Access-Control-Allow-Origin: https://market.csgo.com/api/OperationHistory/1586953889/1587385890/?key=Xf4lR2F573txqcI4Tp7XiIe0u3Yh12a", function( data ) {
  console.log(data);
});
function getData(url, ready) {
    var xhr = new XMLHttpRequest();
    xhr.responseType = 'json';
    xhr.open('GET', url, true);
    xhr.onreadystatechange = function () {
        if (this.readyState === 4 && this.status !== 404) {
            ready(this.responseText);
        }
    }
    xhr.send();
}
document.getElementById('btn').addEventListener('click', getData('pathToTemplate', function (templateData) {
    getData('pathToJSON', function (jsonData) {
        console.log(templateData);
        console.log(jsonData);
    })
}))*/
/*
$.ajax({
    url: 'https://market.csgo.com/api/OperationHistory/1586953889/1587385890/?key=Xf4lR2F573txqcI4Tp7XiIe0u3Yh12a',
    type: 'GET',
    dataType: 'jsonp',
    crossDomain: true,
    success: function (data) {
        console.log(data);
    },
    error: function (error) {
        console.log("FAIL");
    }
});*/
