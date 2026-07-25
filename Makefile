OUT := jonesforth
SRC := jonesforth.S
BUILD_FLAGS := -nostdlib -w

ifeq ($(shell uname -m),aarch64)
DEFAULT_CC := gcc
else ifneq ($(shell command -v aarch64-linux-gnu-gcc 2>/dev/null),)
DEFAULT_CC := aarch64-linux-gnu-gcc
BUILD_FLAGS += -static
else
DEFAULT_CC := none
endif

ifeq ($(origin CC), default)
CC := $(DEFAULT_CC)
endif

all: $(OUT)

$(OUT): $(SRC)
	@if [ "$(CC)" = "none" ]; then echo "No suitable compiler found. Install gcc on aarch64, or aarch64-linux-gnu-gcc for cross-compiling"; exit 1; fi
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

test: $(OUT)
	cat jonesforth.f tests.f | ./$(OUT)

test-docker:
	docker run --rm -v $(PWD):/app dev sh -c 'make test'

clean:
	rm -f $(OUT)

.PHONY: all info run test test-docker clean
