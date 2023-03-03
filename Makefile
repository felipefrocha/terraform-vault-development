.ONESHELL:
.DEFAULT_GOAL := help
SHELL=/bin/bash
ENV?=dev

.PHONY: help

help: ## This help.

	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

initial_setup:
	@vault server -dev
		
deploy_cli: 
	@rm -rf cli/python/dist
	@rm -rf cli/python/src/mycli/__pychache__
	@rm -rf cli/python/src/mycli.egg-info
	@python3 -m build cli/python

install_cli:
	@sudo pip3 uninstall mycli -y
	@sudo pip3 install -U cli/python/dist/mycli-0.0.3-py3-none-any.whl


cli: deploy_cli install_cli


vault_config:
	@cd ./vault/\
	&& terraform fmt -recursive \
		&& terraform init -upgrade \
		&& terraform validate \
		&& terraform apply -auto-approve


test_pycli:
	@cd cli/python/src
	#@python3 mycli login -h
	#@python3 mycli my-aws -h
	#@python3 mycli login felipe B1llyTh3B4d
	@python3 mycli login ffonsec5 W1lssonC4reca
	@python3 mycli my-aws adm dev
	#@python3 mycli my-aws de dev
