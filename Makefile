SHELL := zsh
ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >

.PHONY: clean clean-test clean-pyc clean-build docs help mypy
.DEFAULT_GOAL := help

define BROWSER_PYSCRIPT
import os, webbrowser, sys

from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
> @python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-build clean-pyc clean-test ## remove all build, test, coverage and Python artifacts

clean-build: ## remove build artifacts
> rm -fr build/
> rm -fr dist/
> rm -fr .eggs/
> find . -name '*.egg-info' -exec rm -fr {} +
> find . -name '*.egg' -exec rm -f {} +

clean-pyc: ## remove Python file artifacts
> find . -name '*.pyc' -exec rm -f {} +
> find . -name '*.pyo' -exec rm -f {} +
> find . -name '*~' -exec rm -f {} +
> find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
> rm -fr .tox/
> rm -f .coverage
> rm -fr htmlcov/
> rm -fr .pytest_cache

lint: ## check style with flake8
> flake8 bse tests

test: ## run tests quickly with the default Python
> pytest -vv $(PYTEST_OPTS)
# ex: PYTEST_OPTS="-k 'test_mod'" make test

test-all: ## run tests on every Python version with tox
> tox

coverage: ## check code coverage quickly with the default Python
> coverage run --source bse -m pytest
> coverage report -m
> coverage html
> $(BROWSER) htmlcov/index.html

docs: ## generate Sphinx HTML documentation, including API docs
> rm -f docs/bse.rst
> rm -f docs/modules.rst
> sphinx-apidoc -o docs/ bse
> $(MAKE) -C docs clean
> $(MAKE) -C docs html
> $(BROWSER) docs/_build/html/index.html

servedocs: docs ## compile the docs watching for changes
> watchmedo shell-command -p '*.rst' -c '$(MAKE) -C docs html' -R -D .

release: dist ## package and upload a release
> twine upload dist/*

dist: clean ## builds source and wheel package
> python setup.py sdist
> python setup.py bdist_wheel
> ls -l dist

install: clean ## install the package to the active Python's site-packages
> python setup.py install

mypy: ## runs mypy
> mypy --check-untyped-defs --disallow-untyped-calls --disallow-untyped-defs --disallow-incomplete-defs .

mm-extensions: ## downloads MoneyMoney Extensions from https://moneymoney-app.com/extensions/
> mkdir -p tests/extensions
> curl -s https://moneymoney-app.com/extensions/ | grep "href=\"/extensions/[^\"]*\"" | awk -F'href=' '{print $$2}' | awk -F '"' '{print $$2}' | xargs -I {} curl -s https://moneymoney-app.com{} -o tests{}

currencies:
> curl -s https://www.currency-iso.org/dam/downloads/lists/list_one.xml -o bse/model/iso4217.xml

check-all: test mypy lint coverage ## Runs tests, mypy and linter in one go
