IMAGE_NAME=pg-web-app
CONTAINER_NAME=my-app-instance
# Get the absolute path of the current directory
PWD=$(shell pwd)

.PHONY: build up down logs clean

build:
	container build -t $(IMAGE_NAME) .

up:
	-container stop $(CONTAINER_NAME)
	-container rm $(CONTAINER_NAME)
	# Create the local data directory if it doesn't exist
	mkdir -p $(PWD)/db_data
	# Use the absolute path for the volume
	container run \
		--detach \
		--name $(CONTAINER_NAME) \
		--volume $(PWD)/db_data:/var/lib/postgresql/data \
		$(IMAGE_NAME)
	@echo "------------------------------------------------"
	@echo "Container is running!"
	@echo "Access the app at http://localhost:5000"
	@echo "Run 'make logs' to see the container logs."
	@echo "------------------------------------------------"

down:
	-container stop $(CONTAINER_NAME)
	-container rm $(CONTAINER_NAME)

logs:
	container logs -f $(CONTAINER_NAME)

clean: down
	@echo "Removing local database data..."
	rm -rf $(PWD)/db_data
