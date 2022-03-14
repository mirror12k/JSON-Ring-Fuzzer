
all: run


run:
	cat data.json.save > data.json
	./test.pl data.json

clean:
	rm -rf broke_*
	rm -f data.json.bak.*
