# StudyLink run commands. `make help` lists them.
# Option 1 is the browser (`make web`), option 2 the Android emulator (`make emulator`).

EMULATOR ?= flutter_api36
WEB_PORT ?= 8080

.PHONY: help setup web emulator emulators devices test analyze check build-web build-apk clean

help: ## List the commands
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-11s %s\n", $$1, $$2}'

setup: ## Install packages (run once after cloning)
	flutter pub get

web: ## Run in Chrome at http://localhost:8080 (WEB_PORT=<port> to change)
	flutter run -d chrome --web-port $(WEB_PORT)

emulator: ## Start the Android emulator if needed, then run on it (EMULATOR=<id> to pick)
	@if ! flutter devices | grep -q 'emulator-'; then \
		echo "Starting emulator $(EMULATOR)..."; \
		flutter emulators --launch $(EMULATOR); \
		for i in $$(seq 60); do flutter devices | grep -q 'emulator-' && break; sleep 3; done; \
	fi
	@flutter devices | grep -q 'emulator-' || { echo "Emulator did not start. See: make emulators"; exit 1; }
	flutter run -d emulator

emulators: ## List the Android emulators on this computer
	flutter emulators

devices: ## List connected devices (browser, emulator, phone)
	flutter devices

test: ## Run the tests
	flutter test

analyze: ## Check the code for problems
	flutter analyze --no-fatal-infos

check: analyze test ## Analyze and test

build-web: ## Build the web app into build/web
	flutter build web

build-apk: ## Build a debug Android APK
	flutter build apk --debug

clean: ## Delete build files
	flutter clean
