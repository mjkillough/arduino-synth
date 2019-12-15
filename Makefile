MCU = atmega328p
CPU_FREQ_HZ = 16000000

CC = avr-gcc
CFLAGS = -std=c11 -W -Wall -Wextra -pedantic -Os -DF_CPU=$(CPU_FREQ_HZ)UL -mmcu=$(MCU)
OBJCOPY = avr-objcopy

AVRDUDE = avrdude
AVRDUDE_PROFILE = ATMEGA328P
BAUD = 57600
DEVICE = /dev/ttyUSB0

BUILD = build/

SOURCE = src/
LINKED = build/prog
TARGET = build/prog.hex
OBJECTS := $(patsubst $(SOURCE)%.c,$(BUILD)%.o,$(wildcard $(SOURCE)*.c))

all: $(TARGET)

$(TARGET): $(LINKED)
	@$(OBJCOPY) -O ihex -R .eeprom $(LINKED) $(TARGET)

$(LINKED): $(OBJECTS)
	@$(CC) -o $(LINKED) $(OBJECTS)

$(BUILD)%.o: $(SOURCE)%.c | $(BUILD)
	@$(CC) $(CFLAGS) -c $< -o $@

$(BUILD):
	@mkdir -p $@

.PHONY: clean
clean:
	-rm -rf $(BUILD)

.PHONY: flash
flash: $(TARGET)
	@$(AVRDUDE) -F -V -c arduino -p $(AVRDUDE_PROFILE) -P $(DEVICE) -b $(BAUD) -U flash:w:$(TARGET)
