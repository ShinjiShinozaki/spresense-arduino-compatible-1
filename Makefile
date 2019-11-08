#
# Makefile for creating Arduino boards manager package
#


RELEASE_NAME      ?= v1.0.0
VERSION_PATTERN    = ^v[0-9]{1}.[0-9]{1}.[0-9]{1}$$

OUT               ?= out
INSTALLED_VERSION ?= 1.0.0
SHASUM             = $(OUT)/shasum.txt
ARCHIVEDIR         = $(OUT)/archive
SPR_LIBRARY        = $(ARCHIVEDIR)/spresense-$(RELEASE_NAME).tar.gz
SPR_SDK            = $(ARCHIVEDIR)/spresense-sdk-$(RELEASE_NAME).tar.gz
SPR_TOOLS          = $(ARCHIVEDIR)/spresense-tools-$(RELEASE_NAME).tar.gz
PACKAGEJSON        = $(OUT)/package_spresense_index.json
PWD                = $(shell pwd)
Q                  = @

BOARD_MANAGER_URL ?= https://github.com/sonydevworld/spresense-arduino-compatible/releases/download/generic/package_spresense_index.json
JSON_NAME          = package_spresense_index.json
INSTALL_JSON       = $(OUT)/$(JSON_NAME)
TEMP_JSON          = /tmp/$(JSON_NAME)

.phony: check packages clean

packages: check $(SHASUM) $(INSTALL_JSON)
	$(Q) echo "Done."

check:
	$(Q) echo $(RELEASE_NAME) | grep -E $(VERSION_PATTERN) > /dev/null \
		|| (echo "ERROR: Invalid version name $(RELEASE_NAME)." &&  exit 1)

$(TEMP_JSON):
	$(Q) wget $(BOARD_MANAGER_URL) -O $@

$(INSTALL_JSON): $(TEMP_JSON)
	$(Q) cp -a $< $@
	$(Q) rm $<

$(SHASUM): $(SPR_LIBRARY) $(SPR_SDK) $(SPR_TOOLS)
	$(Q) -sha256sum $^ > $@

$(SPR_LIBRARY): $(ARCHIVEDIR)
	$(Q) echo "Creating spresense.tar.gz ..."
	$(Q) tar -C Arduino15/packages/SPRESENSE/hardware/spresense/ -czf $@ $(INSTALLED_VERSION)

$(SPR_SDK): $(ARCHIVEDIR)
	$(Q) echo "Creating spresense-sdk.tar.gz ..."
	$(Q) tar -C Arduino15/packages/SPRESENSE/tools/spresense-sdk/ -czf $@ $(INSTALLED_VERSION)

$(SPR_TOOLS): $(ARCHIVEDIR)
	$(Q) echo "Creating spresense-tools.tar.gz ..."
	$(Q) tar -C Arduino15/packages/SPRESENSE/tools/spresense-tools/ -czf $@ $(INSTALLED_VERSION)

$(OUT):
	$(Q) mkdir -p $@

$(ARCHIVEDIR): $(OUT)
	$(Q) mkdir -p $@

clean:
	$(Q) -rm -rf $(OUT)
	$(Q) rm -f $(TEMP_JSON)

