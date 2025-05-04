# Service configurations
SERVICES := mosquitto # Add more services here as they are created

# Container registry and naming
REGISTRY ?= aguasbelas

# Helper functions
define get_version
$(shell sed 's/[[:space:]]*$$//' $(1)/VERSION 2>/dev/null || echo "unknown")
endef

define get_image_name
$(REGISTRY)/$(1):$(call get_version,$1)
endef

.PHONY: build start stop restart logs clean help all-services $(SERVICES)

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

# Start all services
start: $(addprefix start-,$(SERVICES))

# Start specific service
start-%:
	@echo "Starting $*"
	cd $* && docker-compose up -d

# Stop all services
stop: $(addprefix stop-,$(SERVICES))

# Stop specific service
stop-%:
	@echo "Stopping $*"
	cd $* && docker-compose down

# Restart all services
restart: stop start

# Restart specific service
restart-%: stop-% start-%

# View logs for all services
logs: $(addprefix logs-,$(SERVICES))

# View logs for specific service
logs-%:
	@echo "Showing logs for $*"
	cd $* && docker-compose logs -f

# Clean up all services
clean: $(addprefix clean-,$(SERVICES))

# Clean up specific service
clean-%:
	@echo "Cleaning up $*"
	cd $* && docker-compose down
	docker rmi $(call get_image_name,$*) || true
	docker rmi $(REGISTRY)/$* || true

# Show help
help:
	@echo "Available commands:"
	@echo "  make build           - Build all services"
	@echo "  make SERVICE         - Build specific service (e.g., make mosquitto)"
	@echo "  make start           - Start all services"
	@echo "  make start-SERVICE   - Start specific service"
	@echo "  make stop            - Stop all services"
	@echo "  make stop-SERVICE    - Stop specific service"
	@echo "  make restart         - Restart all services"
	@echo "  make restart-SERVICE - Restart specific service"
	@echo "  make logs            - View logs for all services"
	@echo "  make logs-SERVICE    - View logs for specific service"
	@echo "  make clean           - Clean up all services"
	@echo "  make clean-SERVICE   - Clean up specific service"
	@echo ""
	@echo "Available services:"
	@for service in $(SERVICES); do \
		echo "  - $$service (version: $(call get_version,$$service))"; \
	done
	@echo ""
	@echo "To change a service version, edit the VERSION file in the service directory" 