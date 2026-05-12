# Makefile for building and installing qcacld WiFi manager

PACKAGE_NAME = qcacld-wifi-manager
VERSION = 1.0
ARCH = all

# Add default output directory environment variable
O ?= out

.PHONY: all clean build install build-termux build-debian

all: build-termux build-debian build-rpm

build: build-termux build-debian

build-termux:
	echo -e "\033[1;33m[INFO]\033[0m Building for Termux..."
	@mkdir -p $(O)/termux/DEBIAN
	@mkdir -p $(O)/termux/data/data/com.termux/files/usr/bin
	@cp wifi_manager.sh $(O)/termux/data/data/com.termux/files/usr/bin/qcamon
	@chmod +x $(O)/termux/data/data/com.termux/files/usr/bin/qcamon
	@echo "Package: $(PACKAGE_NAME)" > $(O)/termux/DEBIAN/control
	@echo "Version: $(VERSION)" >> $(O)/termux/DEBIAN/control
	@echo "Section: utils" >> $(O)/termux/DEBIAN/control
	@echo "Priority: optional" >> $(O)/termux/DEBIAN/control
	@echo "Architecture: $(ARCH)" >> $(O)/termux/DEBIAN/control
	@echo "Maintainer: Dx4Grey <dxablack@gmail.com>" >> $(O)/termux/DEBIAN/control
	@echo "Description: WiFi manager for Qualcomm qcacld (Termux)" >> $(O)/termux/DEBIAN/control
	@dpkg-deb --build $(O)/termux
	@if [ $$? -eq 0 ]; then \
		echo -e "\033[1;32m[OK]\033[0m Termux build complete."; \
	else \
		echo -e "\033[1;31m[ERROR]\033[0m Termux build failed."; \
	fi

build-debian:
	echo -e "\033[1;33m[INFO]\033[0m Building for Debian..."
	@mkdir -p $(O)/debian/DEBIAN
	@mkdir -p $(O)/debian/usr/local/bin
	@cp wifi_manager.sh $(O)/debian/usr/local/bin/qcamon
	@chmod +x $(O)/debian/usr/local/bin/qcamon
	@echo "Package: $(PACKAGE_NAME)" > $(O)/debian/DEBIAN/control
	@echo "Version: $(VERSION)" >> $(O)/debian/DEBIAN/control
	@echo "Section: utils" >> $(O)/debian/DEBIAN/control
	@echo "Priority: optional" >> $(O)/debian/DEBIAN/control
	@echo "Architecture: $(ARCH)" >> $(O)/debian/DEBIAN/control
	@echo "Maintainer: Dx4Grey <dxablack@gmail.com>" >> $(O)/debian/DEBIAN/control
	@echo "Description: WiFi manager for Qualcomm qcacld (Debian)" >> $(O)/debian/DEBIAN/control
	@dpkg-deb --build $(O)/debian
	@if [ $$? -eq 0 ]; then \
		echo -e "\033[1;32m[OK]\033[0m Debian build complete."; \
	else \
		echo -e "\033[1;31m[ERROR]\033[0m Debian build failed."; \
	fi

install:
	sudo dpkg -i debian.deb

clean:
	echo -e "\033[1;33m[INFO]\033[0m Cleaning up build artifacts..."
	rm -rf $(O)/debian $(O)/termux $(O)/rpm-build
	echo -e "\033[1;32m[OK]\033[0m Clean complete."