SHELL := /bin/bash

OUT := jonesforth
SRC := jonesforth.S
UNAME_M := $(shell uname -m)

ifeq ($(UNAME_M),aarch64)
DEFAULT_CC := gcc
DEFAULT_BUILD_FLAGS := -nostdlib
else ifneq ($(shell command -v aarch64-linux-gnu-gcc 2>/dev/null),)
DEFAULT_CC := aarch64-linux-gnu-gcc
DEFAULT_BUILD_FLAGS := -nostdlib -static
else
$(error No suitable compiler found. Install gcc on aarch64, or aarch64-linux-gnu-gcc for cross-compiling)
endif

ifeq ($(origin CC), default)
CC := $(DEFAULT_CC)
endif
BUILD_FLAGS ?= $(DEFAULT_BUILD_FLAGS)

all: $(OUT)

$(OUT): $(SRC)
	$(CC) $(BUILD_FLAGS) -o $@ $<

info:
	@echo "Host arch: $$(uname -m)"
	@echo "Compiler: $(CC)"
	@echo "Build flags: $(BUILD_FLAGS)"
	@if [ -f "$(OUT)" ]; then \
		echo "Output: $(OUT)"; \
		file "$(OUT)"; \
	else \
		echo "Output: $(OUT) (not built yet)"; \
	fi

run: $(OUT)
	cat jonesforth.f - | ./$(OUT)

clean:
	rm -f $(OUT)

.PHONY: all info run clean
