DEVELOPER_DIR ?= /Applications/Xcode.app/Contents/Developer
export DEVELOPER_DIR

PROJECT := GlassCalendar.xcodeproj
SCHEME := GlassCalendar
BUILD_DIR := build
BUILT_APP := $(BUILD_DIR)/Build/Products/Release/GlassCalendar.app
BUILT_WIDGET := $(BUILT_APP)/Contents/PlugIns/GlassCalendarWidget.appex
INSTALL_DIR := $(HOME)/Applications
INSTALLED_APP := $(INSTALL_DIR)/GlassCalendar.app

XCODEBUILD := xcodebuild -project $(PROJECT) -scheme $(SCHEME) -derivedDataPath $(BUILD_DIR)

.PHONY: build test install uninstall reload clean

build:
	$(XCODEBUILD) -configuration Release build
	-pluginkit -r $(BUILT_WIDGET)

test:
	$(XCODEBUILD) test
	-pluginkit -r $(BUILT_WIDGET)

install: build
	-osascript -e 'tell application "GlassCalendar" to quit'
	rm -rf $(INSTALLED_APP)
	mkdir -p $(INSTALL_DIR)
	cp -R $(BUILT_APP) $(INSTALL_DIR)/
	open $(INSTALLED_APP)
	sleep 3
	-osascript -e 'tell application "GlassCalendar" to quit'
	-pluginkit -r $(BUILT_WIDGET)
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
