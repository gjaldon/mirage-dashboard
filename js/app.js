(function () {
    'use strict';
    var dataCache;
    function getData() {
        var endpoint = '/mirage-dashboard/data/out/all.json';
        console.log('GET', endpoint);
        xhr.open('GET', endpoint, true);
        xhr.send();
    }
    function printData(data, tags) {
        var app = document.getElementById('app'),
            markupArr = [
                'div',
                { class: 'container repos' },
                ['h2', 'Last updated: ' + (new Date(data.created_at * 1000)).toString()],
                ['div', {id: 'controls'}, tags],
                data.repos.map(function (item) {
                    return [
                        'div',
                        { class: 'jumbotron repo' },
                        ['div',
                            { class: 'row'},
                            ['div',
                                { class: 'col-md-5' },
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
                                { class: 'col-md-3' },
                                [
                                    'h3',
                                    'Current Release:'
                                ],
                                ['h4', item.current_release.name],
                                ['p',
                                    item.current_release.published ?
                                        'Published: ' + item.current_release.published : ''
                                ],
                                ['p', 'Branches: ' + item.branches.length ],
                                ['p', 'Build status: ', ['img', {
                                    src: 'https://api.travis-ci.org/' + item.user + '/' + item.repo + '.svg?branch=master'
                                }]]
                            ]
                        ]
                    ];
                })
            ];
        console.log(markupArr);
        app.appendChild(lmd(markupArr));
    }
    function collectTags(repos) {
        var tags = [];
        repos.forEach(function (repo) {
            repo.tags.forEach(function (tag) {
                if (tags.indexOf(tag) >= 0) {
                    tags.push(tag);
                }
            });
        });
        return tags;
    }
    function makeTags(tags) {
        return lmd([
            'select',
            tags.map(function (tag) {
                return ['option', tag];
            })
        ]);
    }
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
                dataCache = JSON.parse(xhr.responseText);
                
                printData(dataCache, makeTags(collectTags(dataCache.repos)));
            } else {
                console.error(xhr.status);
            }
        }
    };
    getData();
}());
