IMAGE_NAME=pg-web-app
CONTAINER_NAME=my-app-instance
# Get the absolute path of the current directory
PWD=$(shell pwd)

.PHONY: build up down logs clean

build:
	docker build -t $(IMAGE_NAME) .

up:
	-docker stop $(CONTAINER_NAME) >/dev/null 2>&1 || true
	-docker rm $(CONTAINER_NAME) >/dev/null 2>&1 || true
	# Create the local data directory if it doesn't exist
	mkdir -p $(PWD)/db_data
	# Use the absolute path for the volume
	docker run \
		--detach \
		--name $(CONTAINER_NAME) \
		-p 5000:5000 \
		--volume $(PWD)/db_data:/var/lib/postgresql/data \
		$(IMAGE_NAME)
	@echo "------------------------------------------------"
	@echo "Container is running!"
	@echo "Access the app at http://localhost:5000"
	@echo "Run 'make logs' to see the container logs."
	@echo "------------------------------------------------"

down:
	-docker stop $(CONTAINER_NAME) >/dev/null 2>&1 || true
	-docker rm $(CONTAINER_NAME) >/dev/null 2>&1 || true

logs:
	docker logs -f $(CONTAINER_NAME)

clean: down
	@echo "Removing local database data..."
	rm -rf $(PWD)/db_data
