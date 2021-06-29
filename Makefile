TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

TOOL_NAME = xattrios

xattrios_FILES = main.m
xattrios_CFLAGS = -fobjc-arc
xattrios_CODESIGN_FLAGS = -Sentitlements.plist
xattrios_INSTALL_PATH = /usr/local/bin

include $(THEOS_MAKE_PATH)/tool.mk
