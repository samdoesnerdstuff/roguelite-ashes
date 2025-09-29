#
# Makefile!
# Bring your own Steamworks, since it cannot be vendored
# (See the Steamworks SDK Access Agreement for more info)
#
# (c) samdoesnerdstuff / Sam Watson / CC-BY-NC-SA 4.0
#
# For Windows, an MSYS2 enviroment is absolutely required
# With some fiddling, this could be done with plain VS2022 or CMake, however
# that is mildly time consuming compared to just running make from msys/gnu
#

CC := gcc

CFLAGS  := -std=c17 -Wall -Wextra -Wshadow -Wconversion -Wundef \
		-Wstrict-prototypes -flto -fstack-protector-strong -march=native -O2 \
		-fPIC -Isteam/steamworks/public
LDFLAGS := -shared -flto -Wl,--as-needed -Wl,-O1
LIBS    := -lc

OUT_DIR := bin
OBJ_DIR := obj
SRC_DIR := src

ifeq ($(OS),Windows_NT)
	STEAMWORKS := steam/steamworks/redistributable_bin/win64
	STEAM_LIB  := -lsteam_api64
	RM := del /F /Q
	TARGET := $(OUT_DIR)/steam_helper.dll
else
	ifeq ($(shell uname -s),Darwin)
		STEAMWORKS := steam/steamworks/redistributable_bin/osx
		STEAM_LIB  := -lsteam_api -dynamic
		RM := rm -rf
		TARGET := $(OUT_DIR)/libsteam_helper.dylib
	else
		STEAMWORKS := steam/steamworks/redistributable_bin/linux64
		STEAM_LIB  := -lsteam_api
		RM := rm -rf
		TARGET := $(OUT_DIR)/libsteam_helper.so
	endif
endif

SRC := $(wildcard $(SRC_DIR)/*.c)
OBJ := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRC))

all: $(TARGET)

$(TARGET): $(OBJ)
	@mkdir -p $(OUT_DIR)
	$(CC) $(OBJ) -L$(STEAMWORKS) $(STEAM_LIB) $(LIBS) -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	$(RM) $(OUT_DIR)
	$(RM) $(OBJ_DIR)

	