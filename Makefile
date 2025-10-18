SHELL := /bin/bash

.PHONY: test
test:
	@if [ "$(OS)" = "Windows_NT" ]; then \
		powershell -ExecutionPolicy Bypass -File scripts/test.ps1; \
	else \
		./scripts/test.sh; \
	fi
