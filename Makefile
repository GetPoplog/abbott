# This file added by Stephen Leach, 18th Aug 2024.

################################################################################
### Standard Makefile intro
################################################################################

# Important check
MAKEFLAGS+=--warn-undefined-variables

# Causes the commands in a recipe to be issued in the same shell (beware cd commands not executed in a subshell!)
.ONESHELL:
SHELL:=/bin/bash

# When using ONESHELL, we want to exit on error (-e) and error if a command fails in a pipe (-o pipefail)
# When overriding .SHELLFLAGS one must always add a tailing `-c` as this is the default setting of Make.
.SHELLFLAGS:=-e -o pipefail -c

# Invoke the all target when no target is explicitly specified.
.DEFAULT_GOAL:=help

# Delete targets if their recipe exits with a non-zero exit code.
.DELETE_ON_ERROR:


################################################################################
### Main Contents
################################################################################

.PHONY: help
help:
	@echo "Valid targets:"
	@echo "  help: Display this help message"
	@echo "  build: Build the website asset(s)"
	@echo "  clean: Clean the website asset(s)"

.PHONY: build
build: Code/Abbott3_140101.tgz

Code/Abbott3_140101.tgz: src/*.p
	@echo "Building website asset(s)..."
	rm -rf _build
	mkdir -p _build/Abbott3
	(cd src && tar cf - .) | (cd _build/Abbott3 && tar xf -)
	(cd _build && tar cf - Abbott3) | gzip > Code/Abbott3.tgz
	rm -rf _build

.PHONY: clean
clean:
	@echo "Cleaning website asset(s)..."
	rm -f Code/Abbott3_140101.tgz
	rm -rf _build
