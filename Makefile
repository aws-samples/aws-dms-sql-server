SHELL := /bin/bash

.PHONY : help init deploy test clean delete
.DEFAULT: help

VENV_NAME ?= venv
PYTHON ?= $(VENV_NAME)/bin/python
CUSTOM_FILE ?= .custom.mk

help:
	@echo "init 		generate project for local development"
	@echo "deploy 		deploy solution from source"
	@echo "test 		run pre-commit checks"
	@echo "clean 		delete virtualenv and installed libraries"
	@echo "delete 		delete deployed stacks"

# Initialize VirtualEnv
.PHONY: $(VENV_NAME)
init: $(VENV_NAME)

$(VENV_NAME): pre-commit

$(VENV_NAME)/bin/activate: requirements.txt
	test -d $(VENV_NAME) || virtualenv -p python3 $(VENV_NAME)
	$(PYTHON) -m pip install -U pip
	$(PYTHON) -m pip install -Ur requirements.txt
	touch $(VENV_NAME)/bin/activate

pre-commit: $(VENV_NAME)/bin/activate
	$(VENV_NAME)/bin/pre-commit install

.PHONY: config package build
config: $(CUSTOM_FILE)
	@echo "Configuration completed."

$(CUSTOM_FILE):
ifneq ("$(wildcard $(CUSTOM_FILE))","")
	@echo "File $(CUSTOM_FILE) already exists. Change configuration manually in `./custom.mk` file if required."
endif

include $(CUSTOM_FILE)

deploy: package
	@printf "\n--> Deploying %s template...\n" $(STACK_NAME)
	@$(VENV_NAME)/bin/aws cloudformation deploy \
	  --template-file ./cfn/packaged.template \
	  --stack-name $(STACK_NAME) \
	  --region $(AWS_REGION) \
	  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
	  --parameter-overrides \
	  AvailabilityZones=$(AWS_REGION)a,$(AWS_REGION)b \
	  UserPassword=$(USER_PASSWORD)

package: build
	@printf "\n--> Packaging and uploading templates to the %s S3 bucket ...\n" $(BUCKET_NAME)
	@$(VENV_NAME)/bin/aws cloudformation package \
  	--template-file ./cfn/main.template \
  	--s3-bucket $(BUCKET_NAME) \
  	--s3-prefix $(STACK_NAME) \
  	--output-template-file ./cfn/packaged.template \
  	--region $(AWS_REGION)

build:
	@for fn in custom-resource/*; do \
  		printf "\n--> Installing %s requirements...\n" $${fn}; \
  		$(VENV_NAME)/bin/pip install -r $${fn}/requirements.txt --target $${fn} --upgrade; \
  	done

# Package for cfn-publish CI
cfn-publish-package: build
	zip -r packaged.zip -@ < ci/include.lst

test: $(VENV_NAME)
	$(VENV_NAME)/bin/pre-commit run --show-diff-on-failure --color=always --all-files

version:
	@bumpversion --dry-run --list cfn/main.template | grep current_version | sed s/'^.*='//

# Cleanup local build
clean:
	rm -rf venv
	find . -iname "*.pyc" -delete

delete:
	@printf "\n--> Deleting %s stack...\n" $(STACK_NAME)
	@$(VENV_NAME)/bin/aws cloudformation delete-stack \
            --stack-name $(STACK_NAME)
	@printf "\n--> $(STACK_NAME) deletion has been submitted, check AWS CloudFormation Console for an update..."
