fs-instant-markdown
===================

A simple Bash script that watches a given directory for markdown
files using inotifywait and PUTs the content of modified files
to the instant-markdown-d server.

**IMPORTANT**

This scripts works currently only with the *fs-instant-markdown* branch
of the https://github.com/wiredolphin/instant-markdown-d/tree/fs-instant-markdown
repository.

To install it:

```bash
git clone https://github.com/wiredolphin/instant-markdown-d.git
cd instant-markdown-d
git checkout fs-instant-markdown
npm install -g .
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

