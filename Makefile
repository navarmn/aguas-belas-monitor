# Use bash for shell commands
SHELL := /bin/bash

# Service configurations
SERVICES := mosquitto fcd # Add more services here as they are created

# Container registry and naming
REGISTRY ?= aguasbelas

# FCD modes
FCD_MODES := video config-ui rtsp

# Helper functions
define get_version
$(shell head -n1 $(1)/VERSION 2>/dev/null | tr -d ' \t\n\r%' || echo "unknown")
endef

define get_image_name
$(REGISTRY)/$(1):$(call get_version,$1)
endef

.PHONY: build start stop restart logs clean help all-services $(SERVICES) $(addprefix fcd-,$(FCD_MODES))

# Build all services
build: all-services

# Target to build all services
all-services: $(SERVICES)

# Build specific service
$(SERVICES):
	@echo "Building $@ with version $(call get_version,$@)"
	cd $@ && docker-compose build --no-cache
	cd $@ && VERSION=$(call get_version,$@) docker-compose build
	docker tag $(REGISTRY)/$@ $(call get_image_name,$@)

# FCD specific targets
fcd-%:
	@echo "Building fcd in $* mode"
	cd fcd && docker-compose -f docker-compose-$*.yaml build --no-cache
	cd fcd && VERSION=$(call get_version,fcd) docker-compose -f docker-compose-$*.yaml build
	docker tag $(REGISTRY)/fcd $(call get_image_name,fcd)

# Start all services
start: $(addprefix start-,$(SERVICES))

# Start specific service
start-%:
	@echo "Starting $*"
	cd $* && docker-compose up -d

# Start FCD in specific mode
start-fcd-%:
	@echo "Starting fcd in $* mode"
	cd fcd && docker-compose -f docker-compose-$*.yaml up -d

# Stop all services
stop: $(addprefix stop-,$(SERVICES))

# Stop specific service
stop-%:
	@echo "Stopping $*"
	cd $* && docker-compose down

# Stop FCD in specific mode
stop-fcd-%:
	@echo "Stopping fcd in $* mode"
	cd fcd && docker-compose -f docker-compose-$*.yaml down

# Restart all services
restart: stop start

# Restart specific service
restart-%: stop-% start-%

# Restart FCD in specific mode
restart-fcd-%: stop-fcd-% start-fcd-%

# View logs for all services
logs: $(addprefix logs-,$(SERVICES))

# View logs for specific service
logs-%:
	@echo "Showing logs for $*"
	cd $* && docker-compose logs -f

# View logs for FCD in specific mode
logs-fcd-%:
	@echo "Showing logs for fcd in $* mode"
	cd fcd && docker-compose -f docker-compose-$*.yaml logs -f

# Clean up all services
clean: $(addprefix clean-,$(SERVICES))

# Clean up specific service
clean-%:
	@echo "Cleaning up $*"
	cd $* && docker-compose down
	docker rmi $(call get_image_name,$*) || true
	docker rmi $(REGISTRY)/$* || true

# Clean up FCD in specific mode
clean-fcd-%:
	@echo "Cleaning up fcd in $* mode"
	cd fcd && docker-compose -f docker-compose-$*.yaml down
	docker rmi $(call get_image_name,fcd) || true
	docker rmi $(REGISTRY)/fcd || true

# Show help
help:
	@echo "Available commands:"
	@echo "  make build           - Build all services"
	@echo "  make SERVICE         - Build specific service (e.g., make mosquitto)"
	@echo "  make fcd-MODE        - Build fcd in specific mode (video, config-ui, rtsp)"
	@echo "  make start           - Start all services"
	@echo "  make start-SERVICE   - Start specific service"
	@echo "  make start-fcd-MODE  - Start fcd in specific mode"
	@echo "  make stop            - Stop all services"
	@echo "  make stop-SERVICE    - Stop specific service"
	@echo "  make stop-fcd-MODE   - Stop fcd in specific mode"
	@echo "  make restart         - Restart all services"
	@echo "  make restart-SERVICE - Restart specific service"
	@echo "  make restart-fcd-MODE - Restart fcd in specific mode"
	@echo "  make logs            - View logs for all services"
	@echo "  make logs-SERVICE    - View logs for specific service"
	@echo "  make logs-fcd-MODE   - View logs for fcd in specific mode"
	@echo "  make clean           - Clean up all services"
	@echo "  make clean-SERVICE   - Clean up specific service"
	@echo "  make clean-fcd-MODE  - Clean up fcd in specific mode"
	@echo ""
	@echo "Available services:"
	@for service in $(SERVICES); do \
		version=$$(head -n1 $$service/VERSION 2>/dev/null | tr -d ' \t\n\r%' || echo "unknown"); \
		echo "  - $$service (version: $$version)"; \
	done
	@echo ""
	@echo "FCD modes:"
	@for mode in $(FCD_MODES); do \
		echo "  - $$mode"; \
	done
	@echo ""
	@echo "To change a service version, edit the VERSION file in the service directory" 