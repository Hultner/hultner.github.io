.PHONY: build
build: 
	sass scss/style.scss css/style.css
	uglifycss css/style.css > css/style.min.css
	cp css/style.min.css css/style.css
	rm css/style.min.css


.PHONY: build-dev
build-dev: 
	sass scss/style.scss css/style.css


.PHONY: install
install:
	npm install -g uglifycss
	npm install -g sass


.PHONY: server
server:
	python -m "http.server"
