# rym-charts-sorter
Bash script to scrape Rate Your Music genre charts and sort the releases chronologically

Sick of debugging python libraries? Use this simple script with two arguments: url no. of pages. Example: ./rym.sh https://rateyourmusic.com/charts/top/album/all-time/g:pop/ 5

The requests to RYM are sent at irregular interval to avoid getting IP banned by RYM. Tested with as much as 10 charts pages without any issues.
