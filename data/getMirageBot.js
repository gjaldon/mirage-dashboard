#!/bin/bash
END=11
for PAGE in $(seq 1 $END); do
    curl https://api.github.com/users/miragebot/subscriptions?page=$PAGE | jq '[.[] | { repo: .full_name, tags: ["fromMirageBot"] }]' > data/mirage_bot_page$PAGE.json;
done

jq -s add data/mirage_bot_page*.json > data/repos_from_miragebot.json

rm data/mirage_bot_page*
