all: src

src: 
	make -C src/

clean:
	make -C src/ clean

dist: clean
	tar -cz ../namcub-erlang/ > ../namcub-erlang.tgz

update: clean
	git update

pull: clean
	git pull

commit: clean
	git commit -a

push: clean commit
	git push

.PHONY: src clean all update pull commit push

