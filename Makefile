IMAGE_NAME=pg-web-app
CONTAINER_NAME=my-app-instance
# Get the absolute path of the current directory
PWD=$(shell pwd)

.PHONY: build up down

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
	@echo "Container is starting!"
	@echo "Run 'container ls' to find the IP (ADDR column)."
	@echo "------------------------------------------------"

down:
	-container stop $(CONTAINER_NAME)
	-container rm $(CONTAINER_NAME)

clean: down
	-container volume rm $(VOLUME_NAME)