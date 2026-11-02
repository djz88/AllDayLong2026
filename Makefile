# SPDX-FileCopyrightText: 2026 AllDayLong 2026 project contributors
# SPDX-License-Identifier: GPL-3.0-or-later

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.NOTPARALLEL:

VERSION ?= 1.0.0

override PACKAGE_ROOT := alldaylong-2026
override BUILD_DIR := build
override DIST_DIR := dist

override LINUX_ARCHIVE := $(DIST_DIR)/alldaylong-2026_linux_$(VERSION).tar.gz
override WINDOWS_ARCHIVE := $(DIST_DIR)/alldaylong-2026_win_$(VERSION).zip

override COMMON_FILES := \
	LICENSE.md \
	LICENSES/CC-BY-SA-4.0.txt \
	LICENSES/GPL-3.0-or-later.txt \
	config/AllDayLong-2026.xml \
	images/01.png \
	images/02.png \
	images/03.png \
	images/04.png \
	images/05.png \
	images/06.png \
	images/07.png \
	images/08.png

override LINUX_FILES := \
	README.md \
	install-gnome.sh \
	install-kde.sh \
	docs/INSTALLATION-GNOME.md \
	docs/INSTALLATION-KDE.md \
	$(COMMON_FILES)

override WINDOWS_FILES := \
	install-windows.ps1 \
	$(COMMON_FILES)

.PHONY: all help version check-version check-tools checksums list-linux list-windows
.PHONY: linux windows release verify-release package-linux package-windows clean

all: release

help:
	@printf '%s\n' \
		'AllDayLong 2026 release version: $(VERSION)' \
		'' \
		'make all                    Build both release archives with the default version' \
		'make release VERSION=1.0.0  Build both release archives and their SHA256SUMS' \
		'make linux VERSION=1.0.0    Build only the Linux archive' \
		'make windows VERSION=1.0.0  Build only the Windows archive' \
		'make list-linux             Show files included in the Linux archive' \
		'make list-windows           Show files included in the Windows archive' \
		'make checksums              Regenerate the source SHA256SUMS' \
		'make verify-release VERSION=1.0.0  Verify existing release archives' \
		'make clean                  Remove build and dist directories'

version:
	@printf '%s\n' '$(VERSION)'

check-version:
	@if [[ -z "$(VERSION)" ]]; then \
		echo 'VERSION is required, for example: make release VERSION=1.0.0' >&2; \
		exit 2; \
	fi
	@if [[ ! "$(VERSION)" =~ ^[0-9A-Za-z][0-9A-Za-z._-]*$$ ]]; then \
		echo 'VERSION may contain only letters, numbers, dots, underscores, and hyphens.' >&2; \
		exit 2; \
	fi

check-tools:
	@for tool in chmod cmp cp diff find grep make mkdir mktemp mv rm sed sha256sum sort tar unzip zip; do \
		command -v "$$tool" >/dev/null || { echo "Missing dependency: $$tool" >&2; exit 1; }; \
	done

checksums:
	@manifest_tmp="$$(mktemp .SHA256SUMS.tmp.XXXXXX)"; \
	cleanup() { rm -f -- "$$manifest_tmp"; }; \
	trap cleanup EXIT; \
	trap 'exit 130' INT; \
	trap 'exit 129' HUP; \
	trap 'exit 143' TERM; \
	find . -type f \
		! -path './.git/*' \
		! -path './build/*' \
		! -path './dist/*' \
		! -path './SHA256SUMS' \
		! -path './config/AllDayLong-2026.gnome.xml' \
		! -path './last-status.log' \
		! -name '.SHA256SUMS.tmp.*' \
		-print0 \
		| LC_ALL=C sort -z \
		| while IFS= read -r -d '' file; do \
			sha256sum -- "$${file#./}"; \
		done > "$$manifest_tmp"; \
	[[ -s "$$manifest_tmp" ]] || { \
		echo 'No files found; SHA256SUMS was not changed.' >&2; \
		exit 1; \
	}; \
	if [[ -e SHA256SUMS ]]; then \
		chmod --reference=SHA256SUMS "$$manifest_tmp"; \
	else \
		chmod 0644 "$$manifest_tmp"; \
	fi; \
	mv -- "$$manifest_tmp" SHA256SUMS; \
	trap - EXIT HUP INT TERM; \
	sha256sum --check SHA256SUMS

list-linux:
	@printf '%s\n' $(LINUX_FILES)

list-windows:
	@printf '%s\n' 'README.txt <- docs/INSTALLATION-WINDOWS.md' $(WINDOWS_FILES)

linux: check-version check-tools checksums package-linux
	cd "$(DIST_DIR)" && sha256sum "$(notdir $(LINUX_ARCHIVE))" > SHA256SUMS
	tar -tzf "$(LINUX_ARCHIVE)" >/dev/null
	cd "$(DIST_DIR)" && sha256sum --check SHA256SUMS

windows: check-version check-tools checksums package-windows
	cd "$(DIST_DIR)" && sha256sum "$(notdir $(WINDOWS_ARCHIVE))" > SHA256SUMS
	unzip -tq "$(WINDOWS_ARCHIVE)" >/dev/null
	cd "$(DIST_DIR)" && sha256sum --check SHA256SUMS

release: check-version check-tools clean checksums package-linux package-windows verify-release
	cd "$(DIST_DIR)" && sha256sum \
		"$(notdir $(LINUX_ARCHIVE))" \
		"$(notdir $(WINDOWS_ARCHIVE))" > SHA256SUMS
	cd "$(DIST_DIR)" && sha256sum --check SHA256SUMS
	@printf 'Release files created in %s/\n' "$(DIST_DIR)"

verify-release: check-version check-tools
	tar -tzf "$(LINUX_ARCHIVE)" >/dev/null
	unzip -tq "$(WINDOWS_ARCHIVE)" >/dev/null
	diff -u \
		<(printf '$(PACKAGE_ROOT)/%s\n' $(LINUX_FILES) | LC_ALL=C sort) \
		<(tar -tzf "$(LINUX_ARCHIVE)" | grep -v '/$$' | LC_ALL=C sort)
	diff -u \
		<(printf '$(PACKAGE_ROOT)/%s\n' README.txt $(WINDOWS_FILES) | LC_ALL=C sort) \
		<(unzip -Z1 "$(WINDOWS_ARCHIVE)" | grep -v '/$$' | LC_ALL=C sort)
	unzip -p "$(WINDOWS_ARCHIVE)" "$(PACKAGE_ROOT)/README.txt" \
		| cmp -s -- docs/INSTALLATION-WINDOWS.md -

package-linux:
	rm -rf -- "$(BUILD_DIR)/linux"
	mkdir -p -- "$(BUILD_DIR)/linux/$(PACKAGE_ROOT)" "$(DIST_DIR)"
	cp --parents -- $(LINUX_FILES) "$(BUILD_DIR)/linux/$(PACKAGE_ROOT)/"
	rm -f -- "$(LINUX_ARCHIVE)"
	tar --sort=name --owner=0 --group=0 --numeric-owner \
		-C "$(BUILD_DIR)/linux" -czf "$(LINUX_ARCHIVE)" "$(PACKAGE_ROOT)"

package-windows:
	rm -rf -- "$(BUILD_DIR)/windows"
	mkdir -p -- "$(BUILD_DIR)/windows/$(PACKAGE_ROOT)" "$(DIST_DIR)"
	cp --parents -- $(WINDOWS_FILES) "$(BUILD_DIR)/windows/$(PACKAGE_ROOT)/"
	cp -- docs/INSTALLATION-WINDOWS.md "$(BUILD_DIR)/windows/$(PACKAGE_ROOT)/README.txt"
	rm -f -- "$(WINDOWS_ARCHIVE)"
	cd "$(BUILD_DIR)/windows" && zip -q -X -r \
		"../../$(WINDOWS_ARCHIVE)" "$(PACKAGE_ROOT)"

clean:
	rm -rf -- "$(BUILD_DIR)" "$(DIST_DIR)"
