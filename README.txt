This is a very fast hack to create html and odt versions
for the conversations book.

http://conversations.tools

(This needs definitely a serious rewrite! Anyway ...)
Started ;)



for URL in `cat lib/urls/conversations_01.list`; do ./mdsh2html.sh $URL ; done
