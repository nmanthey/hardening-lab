# Lab container Makefile.
#
# Most participants only need `make import` (load the pre-built image you were
# given) and `make run` (open a shell in it). If you'd rather build the image
# yourself from the Dockerfile in this directory, use `make build`; `make export`
# writes a shareable archive.

IMAGE   := festival-hardening-lab:f41
ARCHIVE := festival-hardening-lab-f41.tar.gz

.PHONY: build export import run

# Build the lab image from the Dockerfile in this directory (needs network).
build:
	docker build --network host -t $(IMAGE) .

# Save the built image to a gzip archive for offline redistribution.
export: $(ARCHIVE)

$(ARCHIVE):
	docker save $(IMAGE) | gzip > $(ARCHIVE)

# Load the lab image from the archive you were given (run once).
import:
	gunzip -c $(ARCHIVE) | docker load

# Open an interactive shell in the lab, mounting the current directory
# and running as your own user.
run:
	docker run -it --network host --rm -u $$(id -u) -v "$$PWD:$$PWD" -w "$$PWD" -e HOME="$$PWD" $(IMAGE) bash
