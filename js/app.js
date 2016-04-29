(function () {
    'use strict';
    function getData() {
        var endpoint = '/mirage-dashboard/data/out/all.json';
        console.log('GET', endpoint);
        xhr.open('GET', endpoint, true);
        xhr.send();
    }
    function printData(data) {
        var app = document.getElementById('app'),
            markupArr = [
                'div',
                { class: 'container' },
                data.repos.map(function (item) {
                    return [
                        'div',
                        { class: 'jumbotron repo' },
                        ['div',
                            { class: 'row'},
                            ['div',
                                { class: 'col-md-8' },
                                ['h2', ['a', {href: 'https://github.com/' + item.user + '/' + item.repo }, item.repo]],
                                ['ul',
                                    ['li', 'By: ', ['a', {href: 'https://github.com/' + item.user}, item.user] ],
                                    [
                                        'li',
                                        'Contributors',
                                        ['ul', (function () {
                                            var k, rtn = [];
                                            for (k in item.events) {
                                                rtn.push(['li', ['a', { href: 'https://github.com/' + k }, k]])
                                            }
                                            return rtn;
                                        }())]
                                    ]
                                ]
                            ],
                            ['div',
                                { class: 'col-md-4' },
                                [
                                    'h3',
                                    'Current Release:',
                                ],
                                ['h4', item.current_release.name]
                                ['p',
                                    item.current_release.published ?
                                        'Published: ' + item.current_release.published : ''
                                ],
                                ['p', 'Branches: ' + item.branches.length ]
                            ]
                        ]
                    ];
                })
            ];
        console.log(markupArr);
        app.appendChild(lmd(markupArr));
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
