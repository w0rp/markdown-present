# markdown-present

This repository hosts a script for building HTML presentations from
GitHub-flavoured Markdown files.

This script will only work in decent Linux distributions. Sorry Mac users.

## Installation

You need [marked](https://www.npmjs.com/package/marked) to convert your Markdown
to HTML. Install it globally in your prefix:

```sh
npm install -g marked
```

If `python3` is not installed on your system, install it. You need any decent
version of Python 3.

You need `inotify-tools` for watching for changes to the Markdown files with
`inotifywait`. Install `inotify-tools` in your Linux distribution of choice.
For Debian/Ubuntu, this means:

```sh
sudo apt install inotify-tools
```

## Usage

Create a Markdown file in the same directory as the script named `whatever.md`.

Run the script in the directory of the script with the filename you want to
watch:

```sh
./markdown-present.sh whatever.md
```

The HTML file should should be saved as `whatever.html`, and will be opened in
your default browser automatically.

The server runs with port `8001` on localhost only. I'm too lazy to add options
for this yet.

The page should automatically refresh itself when you save changes. It might not
work now and then for some reason.
