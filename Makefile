.PHONY: lint test build boot check
lint:
	./scripts/lint
test:
	./tests/run
build:
	sudo ./scripts/build
boot:
	./scripts/boot
check: lint test build boot
