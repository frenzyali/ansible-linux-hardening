# Tooling lives in a local virtualenv; nothing is installed system-wide.
VENV    := .venv
BIN     := $(VENV)/bin
export PATH := $(CURDIR)/$(BIN):$(PATH)
export ANSIBLE_COLLECTIONS_PATH := $(CURDIR)/.ansible/collections

.DEFAULT_GOAL := help
.PHONY: help venv collections lint syntax test test-ubuntu test-rocky test-lockout clean

help: ## Show this help
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-13s %s\n", $$1, $$2}'

$(BIN)/ansible: requirements-dev.txt
	python3 -m venv $(VENV)
	$(BIN)/pip install --upgrade pip
	$(BIN)/pip install -r requirements-dev.txt
	touch $@

venv: $(BIN)/ansible collections ## Create .venv with pinned tools and install pinned collections

collections: $(BIN)/ansible
	$(BIN)/ansible-galaxy collection install -r requirements.yml -p .ansible/collections

lint: venv ## yamllint --strict, ansible-lint (production profile), syntax check
	$(BIN)/yamllint --strict .
	$(BIN)/ansible-lint
	$(MAKE) --no-print-directory syntax

syntax: venv
	$(BIN)/ansible-playbook -i inventories/example/hosts.yml --syntax-check site.yml

test: venv ## Every Molecule scenario on every platform
	$(BIN)/molecule test --all

test-ubuntu: venv ## Molecule default scenario on Ubuntu 24.04 only
	$(BIN)/molecule test -s default -p alh-ubuntu2404

test-rocky: venv ## Molecule default scenario on Rocky Linux 9 only
	$(BIN)/molecule test -s default -p alh-rocky9

test-lockout: venv ## Negative test: ssh role must refuse to lock you out
	$(BIN)/molecule test -s lockout

clean: ## Destroy all Molecule instances of this repo, remove .venv and caches
	-$(BIN)/molecule destroy --all
	rm -rf $(VENV) .ansible
