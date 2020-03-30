include ./help.mk
.PHONY: launch data-launch collect README.md image covid-19 test

image := 3778/covid-19

launch:
	streamlit run simulator/app.py

bin/gh-md-toc:
	mkdir -p bin
	wget https://raw.githubusercontent.com/ekalinin/github-markdown-toc/master/gh-md-toc
	chmod a+x gh-md-toc
	mv gh-md-toc bin/

README.md: bin/gh-md-toc
	./bin/gh-md-toc --insert README.md
	rm -f README.md.orig.* README.md.toc.*

image: ## Build covid-19 image
	docker build . --tag $(image)

covid-19: ## Run covid-19 container
	docker run \
		--rm \
		--publish 8501:8501 \
		--name covid-19 \
		--volume $(CURDIR):/covid-19 \
		$(image) tail -f /dev/null

test:
ifneq "$(shell which pytest)" ""
	pytest --doctest-modules --verbose covid19/
else
	docker run --rm $(image) pytest --doctest-modules --verbose covid19/
endif
