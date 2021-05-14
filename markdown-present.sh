#!/usr/bin/env bash

# Watch for changes to a Markdown file and build an HTML presentation from it.
#
# The npm application `marked` is required to build the presentations.
#
# `python3` is required for launching a local webserver to host it.
# The HTML page will automatically reload itself.

# TODO: Make this work when run from other directories.

set -eu

if [ $# != 1 ]; then
    echo 'Usage: markdown-present.sh <filename.md>' 1>&2
    exit 1
fi

filename="$1"
port=8001

if ! [ -f "$filename" ]; then
    echo "Invalid filename: $filename" 1>&2
    exit 1
fi

if ! command -v marked &> /dev/null; then
    # shellcheck disable=SC2016
    echo 'Run `npm install -g marked` first'
    exit 1
fi

html_filename="${filename%.*}.html"
url_html_filename="$(python3 -c 'import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))' "$html_filename")"

echo "Watching: $filename" 1>&2

# Run a simple HTTP server with which to serve the presentation and check it.
python3 -m http.server -b 127.0.0.1 "$port" &> /dev/null &
server_pid=$?

# Kill the server when the script is stopped
trap 'kill $server_pid' EXIT

build_presentation() {
    {
        echo '<!DOCTYPE html><html lang="en">'

        echo '<head>'

            echo '<meta charset="utf-8">'
            echo '<title>HTML Presentation</title>'
            echo '<link rel="stylesheet" href="html-presentation.css">'
            echo '<link rel="stylesheet" href="highlight/styles/solarized-dark.css">'

        echo '</head>'

        echo '<body>'

            marked --gfm "$filename"

            echo '<script src="highlight/highlight.pack.js"></script>'
            echo '<script>hljs.highlightAll();</script>'
            # This JS automatically reloads the page by checking the length every second.
            echo '<script>if (location.protocol !== "file:") { setInterval(() => {fetch(location.href, {method: "HEAD"}).then(x => {const len = x.status === 200 ? Number(x.headers.get("content-length")) : NaN; if (Number.isFinite(len)) { if (Number.isFinite(window.lastLen) && window.lastLen !== len) { location.reload() }; window.lastLen = len } })}, 1000) }</script>'

        echo '</body>'

        echo '</html>'
    } > "$html_filename"
}

# Force the presentation to build initially.
build_presentation
# Open it.
xdg-open "http://127.0.0.1:$port/$url_html_filename"

# shellcheck disable=SC2034
inotifywait -m -e close_write . |
while read -r directory events changed_filename; do
    if [ "$changed_filename" == "$filename" ]; then
        build_presentation
    fi
done
