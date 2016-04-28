(function () {
    'use strict';
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        var resObj;
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
                resObj = {
                    repos: JSON.parse(xhr.responseText),
                    arrived: (new Date()).toJSON()
                };
                console.log(resObj);
            } else {
                console.error(xhr.status);
            }
        }
    };
    function getData() {
        endpoint = '/mirage-dashboard/data/out/all.json';
        console.log('GET', endpoint);
        xhr.open('GET', endpoint, true);
        xhr.send();
    }
    getData();
}());
