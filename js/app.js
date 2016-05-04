(function () {
    'use strict';
    var dataCache, tagsCache, filterByTag, changeListener;
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
                ['div', {id: 'controls'}, ['p', 'filter by tag:', tags]],
                _.map(data.repos, function (item) {
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
                                    ],
                                    ['li', 'Tags: ' ['em', item.tags.join(', ')]]
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
        app.innerHTML = lms(markupArr);
        filterByTag = document.getElementById('filterByTag');
        filterByTag
            .addEventListener('change', changeListener);
    }
    function collectTags(repos) {
        var tags = ['all'];
        _.forEach(repos, function (repo) {
            _.forEach(repo.tags, function (tag) {
                if (tags.indexOf(tag) < 0) {
                    tags.push(tag);
                }
            });
        });
        console.log(repos.length, tags);
        return tags;
    }
    function makeTags(tags) {
        return [
            'select',
            { id: 'filterByTag'},
            tags.map(function (tag) {
                var selected = false;
                if (filterByTag && filterByTag.value === tag) {
                    selected = 'selected'
                }
                return ['option', { selected: selected }, tag];
            })
        ];
    }
    changeListener = function () {
        console.log(filterByTag.value);
        app.innerHTML = lms(['p', 'Loading...']);
        var filtered = _.clone(dataCache),
            tags = makeTags(collectTags(dataCache.repos));
        if (filterByTag.value === 'all') {
            printData(dataCache, tagsCache);
        } else {
            filtered.repos = _.filter(filtered.repos, function (repo) {
                return repo.tags.indexOf(filterByTag.value) >= 0;
            });
            printData(filtered, tags);
        }
    }
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
                dataCache = JSON.parse(xhr.responseText);
                tagsCache = makeTags(collectTags(dataCache.repos));
                
                printData(dataCache, tagsCache);
            } else {
                console.error(xhr.status);
            }
        }
    };
    getData();
}());
