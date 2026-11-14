XCODE_DEVELOPER_DIR := /Applications/Xcode.app/Contents/Developer
ifneq ($(wildcard $(XCODE_DEVELOPER_DIR)),)
DEVELOPER_DIR ?= $(XCODE_DEVELOPER_DIR)
export DEVELOPER_DIR
endif

PROJECT := GlassCalendar.xcodeproj
SCHEME := GlassCalendar
BUILD_DIR := build
BUILT_APP := $(BUILD_DIR)/Build/Products/Release/GlassCalendar.app
CLT_APP := $(BUILD_DIR)/clt/GlassCalendar.app
BUILT_WIDGET := $(BUILT_APP)/Contents/PlugIns/GlassCalendarWidget.appex
INSTALL_DIR := $(HOME)/Applications
INSTALLED_APP := $(INSTALL_DIR)/GlassCalendar.app

XCODEBUILD := xcodebuild -project $(PROJECT) -scheme $(SCHEME) -derivedDataPath $(BUILD_DIR)

.PHONY: build build-clt test install install-clt deploy uninstall reload clean

build:
	$(XCODEBUILD) -configuration Release build
	-pluginkit -r $(BUILT_WIDGET)

build-clt:
	./Scripts/build-clt.sh $(CLT_APP)

test:
	$(XCODEBUILD) test
	-pluginkit -r $(BUILT_WIDGET)

install: build
	$(MAKE) deploy BUILT_APP=$(BUILT_APP)

install-clt: build-clt
	$(MAKE) deploy BUILT_APP=$(CLT_APP)

deploy:
	-osascript -e 'tell application "GlassCalendar" to quit'
	rm -rf $(INSTALLED_APP)
	mkdir -p $(INSTALL_DIR)
	cp -R $(BUILT_APP) $(INSTALL_DIR)/
	open $(INSTALLED_APP)
	sleep 3
	-osascript -e 'tell application "GlassCalendar" to quit'
	-pluginkit -r $(BUILT_APP)/Contents/PlugIns/GlassCalendarWidget.appex
	$(MAKE) reload

uninstall:
	-osascript -e 'tell application "GlassCalendar" to quit'
	-pluginkit -r $(INSTALLED_APP)/Contents/PlugIns/GlassCalendarWidget.appex
	rm -rf $(INSTALLED_APP)
	$(MAKE) reload

reload:
	-killall chronod NotificationCenter

clean:
	rm -rf $(BUILD_DIR)
