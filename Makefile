EMACS ?= emacs

.PHONY: lint test

## lint: run the config-invariant checks (no Doom, fast)
lint:
	$(EMACS) -Q --batch -l test/lint-config.el -f cc/lint-run

## test: run the ERT suites under test/ (pure helpers only, no Doom)
test:
	@set -e; \
	files=$$(ls test/test-*.el 2>/dev/null || true); \
	if [ -z "$$files" ]; then \
	  echo "no test/test-*.el yet"; \
	else \
	  $(EMACS) -Q --batch -l ert \
	    $$(for f in $$files; do printf -- '-l %s ' "$$f"; done) \
	    -f ert-run-tests-batch-and-exit; \
	fi
