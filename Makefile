LOCALBIN_DIR ?= $(shell pwd)/bin
$(LOCALBIN_DIR):
	mkdir -p $(LOCALBIN_DIR)

#-- ct must be installed in the system, it's not that easy
#-- to install it line helm-docs
lint: ## lint helm charts
	ct lint --target-branch main --validate-maintainers=false

DB_OPERATOR_UNIT := $(shell find charts/db-operator/tests -name '*.yaml')
unit:
	@for file in $(DB_OPERATOR_UNIT); do \
		helm unittest -f $$file ./charts/db-operator; \
	done

sync-crds: ## Sync crds from the operator repo
	./scripts/sync_crds.sh

gen-docs: ## Generate helm documentation
	test -s $(LOCALBIN)/helm-docs || GOBIN=$(LOCALBIN_DIR) go install github.com/norwoodj/helm-docs/cmd/helm-docs@latest
	./bin/helm-docs --template-files=./charts/db-operator/README.md.gotmpl \
		--sort-values-order file --chart-to-generate=charts/db-operator
	./bin/helm-docs --template-files=./charts/db-isntances/README.md.gotmpl --sort-values-order file --chart-to-generate=charts/db-instances

gen-schema: ## Generate the json schema, not there yet
	test -s $(LOCALBIN)/helm-schema || GOBIN=$(LOCALBIN_DIR) go install github.com/dadav/helm-schema/cmd/helm-schema@latest
