.PHONY: build
build: 
	sass scss/style.scss css/style.css
	uglifycss css/style.css > css/style.css


.PHONY: build-dev
build-dev: 
	sass scss/style.scss css/style.css
