.PHONY: help

# distributiionId
var_prd=$$(echo hoge)
var_dev1=$$(echo EXXXXXXXX)
var_dev2=$$(echo EXXXXXXXX)

ETAG ?=	$(shell aws cloudfront get-distribution-config --id "$(var_$*)" | jq -r '.ETag')
DATATIME ?= $(shell date +%Y%m%d)
BACKUPFILE=$$(pwd)/$*_$(var_$*)_backup_$(DATATIME).config
UPDATEFILE=$$(pwd)/$*_$(var_$*)_update.config

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_%-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

get-etag-%: ## Show Distribution ETag
	aws cloudfront get-distribution-config --id $(var_$*) | jq -r '.ETag'

backup-%: ## Backup Distribution Config
	aws cloudfront get-distribution-config --id $(var_$*) | jq '.DistributionConfig' > $(BACKUPFILE)

update-dist-%: ## Update Distribution Config
	aws cloudfront update-distribution --id $(var_$*) --distribution-config file://$(UPDATEFILE) --if-match $(ETAG)

restore-dist-%: ## Restore Distribution Config From BackupFile
	aws cloudfront update-distribution --id $(var_$*) --distribution-config file://$(BACKUPFILE) --if-match $(ETAG)

check-status-%: ## Check Distribution Status
	aws cloudfront get-distribution --id $(var_$*) | jq '.Distribution["Status"]'
