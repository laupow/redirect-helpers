# Spreadsheet to Server Config
Turn tab-separated values to web server redirect rules. Currently only does apache httpd serverr rules.

Example tsv input:
```
FROM	TO
https://www.mysite.com/	http://www.mysite.com/new/page
https://www.mysite.com/dead/site	http://www.google.com/
```

Usage:
```
$ cat my_spreadsheet.tsv | ruby TSVtoConfig.rb
RewriteRule "^/?$"	"http://www.mysite.com/new/page"	[L,NC,NE,R=301,QSD]
RewriteRule "^/dead/site/?$"	"http://www.google.com/"	[L,NC,NE,R=301,QSD]
```
