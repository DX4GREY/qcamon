# Makefile for building and installing qcacld WiFi manager

PACKAGE_NAME = qcacld-wifi-manager
VERSION = 1.0
ARCH = all

# Add default output directory environment variable
O ?= out

.PHONY: all clean build install build-termux build-debian build-rpm

all: build-termux build-debian build-rpm

build:
	echo -e "\033[1;33m[INFO]\033[0m Building $(PACKAGE_NAME)..."
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
	@echo "Description: WiFi manager for Qualcomm qcacld" >> $(O)/debian/DEBIAN/control
	@dpkg-deb --build $(O)/debian
	@if [ $$? -eq 0 ]; then \
		echo -e "\033[1;32m[OK]\033[0m Build complete."; \
	else \
		echo -e "\033[1;31m[ERROR]\033[0m Build failed."; \
	fi

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

build-rpm:
	echo -e "\033[1;33m[INFO]\033[0m Building for RPM-based distros..."
	@mkdir -p $(O)/rpm-build/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
	@mkdir -p $(O)/rpm-build/SOURCES/usr/local/bin
	@mkdir -p $(O)/rpm-build/SPECS
	@cp wifi_manager.sh $(O)/rpm-build/SOURCES/usr/local/bin/qcamon
	@chmod +x $(O)/rpm-build/SOURCES/usr/local/bin/qcamon
	@echo "Name: $(PACKAGE_NAME)" > $(O)/rpm-build/SPECS/$(PACKAGE_NAME).spec
	@echo "Version: $(VERSION)" >> $(O)/rpm-build/SPECS/$(PACKAGE_NAME).spec
	@echo "Release: 1" >> $(O)/rpm-build/SPECS/$(PACKAGE_NAME).spec
	@echo "Summary: WiFi manager for Qualcomm qcacld (RPM)" >> $(O)/rpm-build/SPECS/$(PACKAGE_NAME).spec
	@echo "License: GPL" >> $(O)/rpm-build/SPECS/$(PACKAGE_NAME).spec
	@echo "Group: Applications/System" >> $(O)/rpm-build/SPECS/$(PACKAGE_NAME).spec
	@echo "BuildArch: $(ARCH)" >> $(O)/rpm-build/SPECS/$(PACKAGE_NAME).spec
	@echo "%description" >> $(O)/rpm-build/SPECS/$(PACKAGE_NAME).spec
	@echo "WiFi manager for Qualcomm qcacld" >> $(O)/rpm-build/SPECS/$(PACKAGE_NAME).spec
	@echo "%files" >> $(O)/rpm-build/SPECS/$(PACKAGE_NAME).spec
	@echo "/usr/local/bin/qcamon" >> $(O)/rpm-build/SPECS/$(PACKAGE_NAME).spec
	@rpmbuild --define "_topdir $(PWD)/$(O)/rpm-build" -bb $(O)/rpm-build/SPECS/$(PACKAGE_NAME).spec
	@if [ $$? -eq 0 ]; then \
		echo -e "\033[1;32m[OK]\033[0m RPM build complete."; \
	else \
		echo -e "\033[1;31m[ERROR]\033[0m RPM build failed."; \
	fi

install:
	sudo dpkg -i debian.deb

clean:
	echo -e "\033[1;33m[INFO]\033[0m Cleaning up build artifacts..."
	rm -rf $(O)/debian $(O)/termux $(O)/rpm-build
	echo -e "\033[1;32m[OK]\033[0m Clean complete."