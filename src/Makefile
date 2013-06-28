all: clean src

src: server utils client threespans

threespans:
	erlc i3span_editor.erl

server: utils
	erlc  server.erl
	erlc  loginserver.erl

client:
	erlc client.erl

utils:
	erlc listutils.erl

clean:
	rm -f *.beam *.o

.PHONY: src clean all 
