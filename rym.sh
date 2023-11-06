#!/bin/bash
#Alexandru Țîrdea, November 6th 2023

url="$1"
page="$2"

rm music* rym_*

download_rym () {

for i in $(seq 1 $page)
do
echo "$1" && \
curl -A "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" \
-X GET "$url$i/" \
-o rym_$i.txt && sleep $(shuf -i 30-60 | head -1)
done
}

cut_excess () {
for i in $(seq 1 $page)
do
sed -i '/Support RYM by becoming a subscriber to access additional chart features/{s/\(.*Support RYM by becoming a subscriber to access additional chart features\).*/\1/;q}' rym_$i.txt
done
}

beautify () {
for i in $(seq 1 $page)
do
cat rym_$i.txt | \
grep -E -A 1 'ui_name_locale|page_charts_section_charts_item_date|Various Artists' | grep -v 'ui_name_locale_language' | \
sed \
-e 's%<span class="ui_name_locale_original">%%g' \
-e 's%<span class="ui_name_locale ">%%g' \
-e 's%</span>%%g' \
-e 's%<span class="ui_name_locale">%%g' \
-e 's%<div class="page_charts_section_charts_item_date">%%g' \
-e 's%<span class="ui_name_locale has_locale_name">%%g' \
-e 's%<span class="ui_name_locale_language">%%g' \
-e 's%--%%g' \
-e 's%</a>%%g' \
-e 's%<span>%%g' \
-e '/^[[:space:]]*$/d' \
-e 's/^[ \t]*//' \
-e 's/.*Various Artists.*/Various Artists/' > music_$i.txt
done
}

replacements () {
for i in $(seq 1 $page)
do
sed -i -z 's%/\n%%g' music_$i.txt
sed -i -z 's%\\n%%g' music_$i.txt
sed -i -z 's%&amp;\n%%g' music_$i.txt
done
}

convert_to_csv () {
for i in $(seq 1 $page)
do
pr -3tas\| < music_$i.txt > music_$i.csv && cat music_$i.csv >> music.csv
done
}

sort_csv () {
temp_file=$(mktemp)

convert_to_unix_time() {
    python3 - <<END
from datetime import datetime

date_str = "$1"
date_formats = ["%d %B %Y", "%B %Y", "%Y"]

for date_format in date_formats:
    try:
        date = datetime.strptime(date_str, date_format)
        unix_time = int(date.timestamp())
        print(unix_time)
        break
    except ValueError:
        pass
END
}

while IFS='|' read -r title artist date; do
    if [ -n "$date" ]; then
        unix_time=$(convert_to_unix_time "$date")
        echo "$unix_time|$title|$artist|$date" >> "$temp_file"
    else
        echo "0|$title|$artist|$date" >> "$temp_file"
    fi
done < music.csv

sort -t '|' -k 1,1n "$temp_file" > sorted.csv

rm "$temp_file"
}


download_rym
cut_excess
beautify
replacements
convert_to_csv
sort_csv
