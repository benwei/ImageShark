proj_name = ImageShark
CONFIGURATION=Release
BUILD_DIR=build/$(CONFIGURATION)
define pod-build
	pod install
	xcodebuild -project 'Pods/Pods.xcodeproj' \
		-sdk macosx10.8 -alltargets $1 $2
endef

define image-shark-build
	xcodebuild -workspace '$(proj_name).xcworkspace' \
		-scheme '$(proj_name)' \
		-configuration '$(CONFIGURATION)' \
		-sdk macosx10.8 \
		CONFIGURATION_BUILD_DIR='$(BUILD_DIR)' build
endef

all: target-build
	
pods-build:
	$(call pod-build)

target-build: pods-build
	$(call image-shark-build)

l10n:
	ibtool --export-strings-file file.strings $(proj_name)/en.lproj/MainMenu.xib

clean:
	rm -rf build Pods/build
	@rm -f file.strings
