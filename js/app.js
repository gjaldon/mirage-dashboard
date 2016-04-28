(function () {
    'use strict';
    function getData() {
        var endpoint = '/mirage-dashboard/data/out/all.json';
        console.log('GET', endpoint);
        xhr.open('GET', endpoint, true);
        xhr.send();
    }
    function printData(data) {
        var app = document.getElementById('app');
        app.appendChild(lmd([
            'ul', [
                data.repos.map(function (repo) {
                    return ['li', repo.name];
                })
            ]
        ]));
    }
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        var resObj;
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
                resObj = {
                    repos: JSON.parse(xhr.responseText),
                    arrived: (new Date()).toJSON()
                };
                printData(resObj);
            } else {
                console.error(xhr.status);
            }
        }
    };
    getData();
}());
