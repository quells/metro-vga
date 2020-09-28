TAG=metro-vga

.PHONY: container
container:
	docker build -t $(TAG) .

.PHONY: build
build: container
	@mkdir -p build
	docker run --rm \
	--mount type=bind,source="$(shell pwd)/build",target=/opt/build \
	--mount type=bind,source="$(shell pwd)/src",target=/opt/src \
	metro-vga

clean:
	-rm build/*
