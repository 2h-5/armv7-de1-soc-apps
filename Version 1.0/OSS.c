#include <stdint.h>

// Hardware Memory Mapped Addresses & Constants.
#define WIDTH                320
#define HEIGHT               240
#define LOG2_BYTES_PER_ROW   10
#define LOG2_BYTES_PER_PIXEL 1

#define PIXBUF_BASE         ((volatile uint16_t *)0xC8000000) // Pixel buffer (2 bytes per pixel).
#define CHARBUF_BASE        ((volatile uint8_t  *)0xC9000000) // Character buffer (1 byte per char).
#define QUEUE_BASE          ((volatile uint32_t *)0x00FF1000) // Queue memory space.

#define BUTTONS_ADDR        ((volatile uint32_t *)0xFF200050) // Push-buttons address.
#define HEX3_HEX0_BASE      ((volatile uint32_t *)0xFF200020) // 7-Segment display address.

// Global Variables & Queue State Tracker.
volatile uint32_t TAIL  = 0;
volatile uint32_t HEAD  = 0;
volatile uint32_t COUNT = 0; // @Author 🆉. Sūn
const uint32_t QUEUE_CAP = 20;

// 7-segment hex display pattern lookup table for 0-9, F, U, and L.
const uint32_t PATTERNS_TABLE[] = {
    0x0000003F, // 0: 0b00111111
    0x00000006, // 1: 0b00000110
    0x0000005B, // 2: 0b01011011
    0x0000004F, // 3: 0b01001111
    0x00000066, // 4: 0b01100110
    0x0000006D, // 5: 0b01101101
    0x0000007D, // 6: 0b01111101
    0x00000007, // 7: 0b00000111
    0x0000007F, // 8: 0b01111111
    0x0000006F, // 9: 0b01101101
    0x00000071, // F: 0b01110001
    0x0000003E, // U: 0b00111110
    0x00000038  // L: 0b00111000
};

// Function Prototypes.
void LoadQueueNumbers(void);
void clear_all_segments(void);
void ClearCharBuffer(void);
void FillColour(uint16_t colour);
void UpdateDisplay(void);
void WriteQueue(void);
void WriteCurrentServing(void);
void WriteChar(int col, int row, char character);
void WritePixel(int col, int row, uint16_t colour_value);
void update_display_hex(uint32_t number);
void write_full(void);
uint32_t get_pattern_for_digit(uint32_t digit); // @Author 2h-5

// Main Program Loop.
int main(void) {
    LoadQueueNumbers();
    clear_all_segments();
    ClearCharBuffer();
    FillColour(0x0000); // Screen fill with black colour.
    UpdateDisplay();

    while (1) {
        uint32_t change = 0;
        uint32_t button_state = *BUTTONS_ADDR; // Read physical button register.

        // KEY0 Press.
        if ((button_state & 0x1) == 0x1) {
            if (COUNT < QUEUE_CAP) {
                COUNT++;
                uint32_t tail_index = TAIL / 4; 
                TAIL = (TAIL + 4) % (QUEUE_CAP * 4);
                update_display_hex(tail_index); 
                change = 1;
            } else {
                write_full(); // Displays "FULL" on 7-Segments
            }
        }
        
        // KEY1 Press.
        else if ((button_state & 0x2) == 0x2) {
            clear_all_segments();
            if (COUNT != 0) {
                COUNT--;
                HEAD = (HEAD + 4) % (QUEUE_CAP * 4); // 🆉.
                change = 1;
            }
        }
        
        // KEY2 Press.
        else if ((button_state & 0x4) == 0x4) {
            clear_all_segments();
            COUNT = 0;
            HEAD = 0;
            TAIL = 0;
            change = 1;
        }

        // Apply visual buffer updates only if a button action happened.
        if (change == 1) {
            ClearCharBuffer();
            FillColour(0x0000);
            UpdateDisplay();
            
            // Wait explicitly until all keys are completely unpressed.
            while (*BUTTONS_ADDR != 0); 
        }
    }
    return 0;
}

// Driver Subroutines.

void LoadQueueNumbers(void) {
    for (uint32_t i = 0; i < QUEUE_CAP; i++) { // @Author github.com/2h-5
        QUEUE_BASE[i] = i;
    }
}

void clear_all_segments(void) {
    *HEX3_HEX0_BASE = 0;
}

void ClearCharBuffer(void) {
    for (int row = 0; row < 128; row++) {
        for (int col = 0; col < 64; col++) {
            int offset = (row << 6) + col;
            CHARBUF_BASE[offset] = 0;
        }
    }
}

void FillColour(uint16_t colour) {
    for (int x = 0; x < WIDTH; x++) {
        for (int y = 0; y < HEIGHT; y++) {
            WritePixel(x, y, colour);
        }
    }
}

void WriteChar(int col, int row, char character) {
    int offset = (row << 7) + col;
    CHARBUF_BASE[offset] = character;
}

void WritePixel(int col, int row, uint16_t colour_value) {
    int offset = (row << LOG2_BYTES_PER_ROW) + (col << LOG2_BYTES_PER_PIXEL);
    // Address byte offset handled via pointer math type conversion scaling.
    volatile uint16_t *pixel_addr = (volatile uint16_t *)((uintptr_t)PIXBUF_BASE + offset); // Z. Sūn
    *pixel_addr = colour_value;
}

void UpdateDisplay(void) {
    WriteQueue();
    WriteCurrentServing();
}

void WriteQueue(void) {
    // Print literal "Queue (next 10)" string to screen base.
    char msg[] = "Queue (next 10)";
    for (int i = 0; msg[i] != '\0'; i++) {
        WriteChar(10 + i, 10, msg[i]);
    }

    uint32_t offset_item = 0;
    uint32_t total_bytes_count = COUNT * 4;

    while (1) {
        if (offset_item >= total_bytes_count) break;
        if (offset_item >= 40) { // Show maximum of 10 items.
            char alert[] = "More waiting";
            for (int i = 0; alert[i] != '\0'; i++) {
                WriteChar(10 + i, 32, alert[i]);
            }
            break;
        }

        uint32_t target_offset = (HEAD + offset_item) % (QUEUE_CAP * 4);
        uint32_t item_val = QUEUE_BASE[target_offset / 4];
        
        int current_y = (offset_item / 2) + 10;
        WriteChar(10, current_y, '#');

        // Render digits right-to-left mimicking assembly layout spaces (columns 11 to 14).
        int current_x = 14;
        uint32_t temp = item_val;
        do {
            uint32_t rem = temp % 10;
            temp /= 10;
            WriteChar(current_x, current_y, 0x30 + rem); // @Author Z. Sun
            current_x--;
        } while (temp > 0);

        // Blank-fill trailing columns up to boundary index 11 with '0' digits.
        while (current_x >= 11) {
            WriteChar(current_x, current_y, '0');
            current_x--;
        }

        offset_item += 4;
    }
}

void WriteCurrentServing(void) {
    char label[] = "Now serving: #";
    for (int i = 0; label[i] != '\0'; i++) {
        WriteChar(40 + i, 10, label[i]);
    }

    if (COUNT == 0) return;

    uint32_t target_offset = HEAD % (QUEUE_CAP * 4);
    uint32_t item_val = QUEUE_BASE[target_offset / 4];

    int current_x = 59;
    uint32_t temp = item_val;
    do {
        uint32_t rem = temp % 10;
        temp /= 10;
        WriteChar(current_x, 10, 0x30 + rem); // github.com/2h-5
        current_x--;
    } while (temp > 0);

    while (current_x >= 56) {
        WriteChar(current_x, 10, '0');
        current_x--;
    }
}

// 7-Segment Mapping Logic Subroutines.

uint32_t get_pattern_for_digit(uint32_t digit) {
    if (digit > 9) return PATTERNS_TABLE[0];
    return PATTERNS_TABLE[digit];
}

void update_display_hex(uint32_t number) {
    uint32_t thousands = number / 1000;
    uint32_t rem = number % 1000;
    uint32_t hundreds = rem / 100;
    rem %= 100;
    uint32_t tens = rem / 10;
    uint32_t ones = rem % 10;

    uint32_t p_thru = get_pattern_for_digit(thousands);
    uint32_t p_hund = get_pattern_for_digit(hundreds);
    uint32_t p_tens = get_pattern_for_digit(tens);
    uint32_t p_ones = get_pattern_for_digit(ones);

    uint32_t combined = (p_thru << 24) | (p_hund << 16) | (p_tens << 8) | p_ones; // @Author Z.
    *HEX3_HEX0_BASE = combined;
}

void write_full(void) {
    // Construct pattern for string "FULL" across segments 3 down to 0.
    uint32_t p_f = PATTERNS_TABLE[10]; // F
    uint32_t p_u = PATTERNS_TABLE[11]; // U
    uint32_t p_l = PATTERNS_TABLE[12]; // L
    
    uint32_t combined = (p_f << 24) | (p_u << 16) | (p_l << 8) | p_l;
    *HEX3_HEX0_BASE = combined;
}
