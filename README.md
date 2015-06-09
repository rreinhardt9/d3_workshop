# d3_workshop

Dev environment for building d3 plots.

It is set up with bower to allow quick changes and additions of dependencies. Currently I have it set up with an old version of jquery and coffeescript.

To use, tell coffeescript to watch your src folder and complile to lib

```
$ coffee -o lib/ -cw src/
```
Then start a simple web server. Here is starting a ruby server on port 8888

```
$ ruby -run -e httpd . -p 8888
```
or python

```
$ python -m SimpleHTTPServer 8888
```
and there you go. Now you can view your project at `http://localhost:8888/<insert_filename>.html`
