fs-instant-markdown
===================

A simple Bash script that watches a given directory for markdown
files using inotifywait and PUTs the content of modified files
to the instant-markdown-d server.

### Usage

Clone the repository:
```bash
git clone https://github.com/wiredolphin/fs-instant-markdown.git
cd fs-instant-markdown
```

Make the script executable:
```bash
chmod +x fs-instant-markdown.sh
```

Execute with the available options:
```bash
./fs-instant-markdown.sh --path <markdown_files_dir> --browser chromium --anchor
```

Options:
```bash
-a, --anchor                  Makes instant-markdown-d server in
                              add id to HTML headings
-b, --browser <browser>       Set the preferred browser launched
                              by the instant-markdown-d server
-d, --debug                   Pass this argument to the
                              instant-markdown-d
-v, --verbose                 Make instant-markdown-d verbose
-p, --path <path>             Set the path to be watched
-t, --theme <theme>           Pass the argument to the
                              instant-markdown-d server
```

**IMPORTANT**

This scripts works currently only with the *fs-instant-markdown* branch
of the [instant-markdown-d](https://github.com/wiredolphin/instant-markdown-d.git)
repository (see https://github.com/wiredolphin/instant-markdown-d/tree/fs-instant-markdown).
To install it:

```bash
git clone https://github.com/wiredolphin/instant-markdown-d.git
cd instant-markdown-d
git checkout fs-instant-markdown
npm install -g .
```



