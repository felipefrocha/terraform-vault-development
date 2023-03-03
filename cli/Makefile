.ONESHELL:
.DEFAULT_GOAL := help
SHELL=/bin/bash
ENV?=dev

.PHONY: help

help: ## This help.

	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)


		
deploy_cli: 
	@rm -rf cli/python/dist
	@rm -rf cli/python/src/mycli/__pychache__
	@rm -rf cli/python/src/mycli.egg-info
	@python3 -m build cli/python

install_cli:
	@sudo pip3 uninstall mycli -y
	@sudo pip3 install -U cli/python/dist/mycli-0.0.3-py3-none-any.whl


cli: deploy_cli install_cli # test_cli

test_cli:
	@cd cli/python/src
	@mycli login -h
	@mycli my-aws -h
	@mycli login felipe senha || echo ""
	@mycli my-aws adm dev
	
