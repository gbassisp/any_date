# ensure target stops if there is an error; run on a single shell
# .ONESHELL:
# SHELL = /usr/bin/perl
# .SHELLFLAGS = -e

# check if fvm command exists, otherwise use empty string
FVM_CMD := $(shell command -v fvm 2> /dev/null)
DART_CMD := $(FVM_CMD) dart

export PATH := $(HOME)/.pub-cache/bin:$(PATH)


.PHONY: all
all: version get test analyze doc dry-run

.PHONY: kill
kill: 
	@echo "Killing service..."
	@kill -9 $(shell lsof -t -i:8181) || echo "Port 8181 is not in use"

.PHONY: publish
publish: all
	@echo "Publishing package..."
	$(DART_CMD) pub publish --force

.PHONY: dry-run
dry-run: kill
	@echo "Running dry-run..."
	$(DART_CMD) pub publish --dry-run

.PHONY: test
test:
	@echo "Running tests..."
	$(DART_CMD) test

.PHONY: coverage
coverage:
	@echo "Running tests..."
	$(DART_CMD) pub global activate coverage
	$(DART_CMD) run coverage:test_with_coverage
	$(MAKE) format_lcov

.PHONY: get
get:
	@echo "Getting dependencies..."
	$(DART_CMD) pub get 


.PHONY: doc
doc:
	@echo "Generating documentation..."
	$(DART_CMD) doc

.PHONY: analyze
analyze:
	@echo "Analyzing..."
	$(DART_CMD) analyze --fatal-infos --fatal-warnings
	$(DART_CMD) format --set-exit-if-changed .

.PHONY: version
version:
	@echo "Checking version..."
	$(DART_CMD) --version


### Coverage ###

# ensure all files listed in the coverage report are relative paths
CWD := $(shell pwd)
FILES := $(shell find coverage/*.info -type f ! -path "$(CWD)")

.PHONY: format_lcov
format_lcov:
	@mkdir -p coverage
	@echo "Formatting lcov.info..."
	@echo "CWD: $(CWD)"
	@echo "FILES: $(FILES)"
	@for file in $(FILES); do \
		sed -i'' -e 's|$(CWD)/||g' $$file ; \
	done

