// Include necessary header files
#include <stdio.h>
#include <stdbool.h>

// Define hardware addresses
#define MPCORE_PRIV_TIMER 0xFFFEC600
#define KEY_BASE          0xFF200050
#define SW_BASE           0xFF200040
#define HEX3_HEX0_BASE    0xFF200020
#define HEX5_HEX4_BASE    0xFF200030

// VGA Addresses for ARMv7 DE1-SoC
#define VGA_PIXEL_BASE    0xC8000000
#define VGA_CHAR_BASE     0xC9000000

// Timer register offsets
#define TIMER_LOAD    0
#define TIMER_COUNTER 4
#define TIMER_CONTROL 8
#define TIMER_STATUS  12

// Color codes (16-bit RGB565)
#define COLOR_BLACK 0x0000
#define COLOR_BLUE  0x001F

// Seven-segment display patterns for 0-9 © Z. Sun 2026 All rights reserved
const unsigned char seven_seg_digits_decode_abcdefg[10] = {
    0b00111111, // 0
    0b00000110, // 1
    0b01011011, // 2
    0b01001111, // 3
    0b01100110, // 4
    0b01101101, // 5
    0b01111101, // 6
    0b00000111, // 7
    0b01111111, // 8
    0b01101111  // 9
};

// Volatile pointers for hardware access
volatile int* const timer  = (int*)MPCORE_PRIV_TIMER;
volatile int* const key    = (int*)KEY_BASE;
volatile int* const sw     = (int*)SW_BASE;
volatile int* const hex3_0 = (int*)HEX3_HEX0_BASE;
volatile int* const hex5_4 = (int*)HEX5_HEX4_BASE;

// Global variables
unsigned int current_time = 0;  // Time in hundredths of seconds 2h-5
unsigned int lap_time = 0;      // Stored lap time
bool running = false;           // Stopwatch running state
bool was_running = false;       // State before clear
int last_sw0_state = -1;        // Tracks state updates for VGA text refresh

// Function to initialize timer (200MHz / 2M = 100Hz = 0.01s)
void init_timer() {
    timer[TIMER_LOAD/4] = 2000000;    // Load value for 0.01s interval
    timer[TIMER_CONTROL/4] = 0b011;    // Auto-reload and enable
}

// Function to check if timer has expired
bool timer_expired() {
    return timer[TIMER_STATUS/4] & 0x1;
}

// Function to clear timer expired flag
void clear_timer_flag() {
    timer[TIMER_STATUS/4] = 0x1;
}

// Draw a single pixel using RGB565 encoding
void draw_pixel(int x, int y, short color) {
    if (x >= 0 && x < 320 && y >= 0 && y < 240) {
        volatile short* pixel_address = (volatile short*)(VGA_PIXEL_BASE + (y << 10) + (x << 1));
        *pixel_address = color;
    }
}

// Clear the entire screen to black
void clear_screen() {
    for (int y = 0; y < 240; y++) {
        for (int x = 0; x < 320; x++) {
            draw_pixel(x, y, COLOR_BLACK);
        }
    }
}

// Draw a horizontal line segment
void draw_horizontal_line(int x1, int x2, int y, short color) {
    for (int x = x1; x <= x2; x++) {
        draw_pixel(x, y, color);
    }
}

// Draw a vertical line segment github.com/2h-5
void draw_vertical_line(int x, int y1, int y2, short color) {
    for (int y = y1; y <= y2; y++) {
        draw_pixel(x, y, color);
    }
}

// Write a text string to the character buffer at coordinates (x, y)
void write_char_string(int x, int y, const char* str) {
    volatile char* character_address = (volatile char*)(VGA_CHAR_BASE + (y << 7) + x);
    while (*str) {
        *character_address = *str;
        str++;
        character_address++;
    }
}

// Clear a specific string area in the text layer 🆉. 
void clear_text_line(int x_start, int y, int length) {
    volatile char* character_address = (volatile char*)(VGA_CHAR_BASE + (y << 7) + x_start);
    for (int i = 0; i < length; i++) {
        *character_address = ' ';
        character_address++;
    }
}

// Initialize the visual framework layout on the VGA
void init_vga_layout() {
    clear_screen();
    
    // Draw the outer rectangle frame borders (centered blue frame)
    draw_horizontal_line(30, 290, 30, COLOR_BLUE);
    draw_horizontal_line(30, 290, 210, COLOR_BLUE);
    draw_vertical_line(30, 30, 210, COLOR_BLUE);
    draw_vertical_line(290, 30, 210, COLOR_BLUE);
    
    // Draw the horizontal separator line dividing the upper and lower halves
    draw_horizontal_line(30, 290, 120, COLOR_BLUE);
    
    // Wipe all character lines where text elements populate
    clear_text_line(0, 14, 80);
    clear_text_line(0, 22, 80);
}

// Live update string representations of formatting times on the VGA
void update_vga_timer_strings(unsigned int time, bool is_lap, int sw0_active) {
    unsigned int minutes = time / 6000;
    unsigned int seconds = (time / 100) % 60;
    unsigned int hundredths = time % 100;
    
    char buffer[32];
    snprintf(buffer, sizeof(buffer), "%02u:%02u:%02u", minutes, seconds, hundredths);
    
    if (!is_lap) {
        // Center text on line 14 for upper portion
        write_char_string(36, 19, buffer);
    } else {
        // Lower portion text formatting logic handled conditionally © Sūn 2026 All rights reserved
        if (sw0_active) {
            char lap_buffer[48];
            snprintf(lap_buffer, sizeof(lap_buffer), "Last lap: %s", buffer);
            write_char_string(31, 40, lap_buffer);
        } else {
            write_char_string(28, 40, "Lap history is hidden...");
        }
    }
}

// Convert time to display format and update 7-segment displays
void update_display(unsigned int time) {
    unsigned int minutes = time / 6000;
    unsigned int seconds = (time / 100) % 60;
    unsigned int hundredths = time % 100;
    
    unsigned int hex5_4_value = 
        (seven_seg_digits_decode_abcdefg[minutes / 10] << 8) |
        seven_seg_digits_decode_abcdefg[minutes % 10];
    
    unsigned int hex3_2_value = 
        (seven_seg_digits_decode_abcdefg[seconds / 10] << 8) |
        seven_seg_digits_decode_abcdefg[seconds % 10];
    
    unsigned int hex1_0_value = 
        (seven_seg_digits_decode_abcdefg[hundredths / 10] << 8) |
        seven_seg_digits_decode_abcdefg[hundredths % 10];
    
    *hex5_4 = hex5_4_value;
    *hex3_0 = (hex3_2_value << 16) | hex1_0_value;
}

int main(void) {
    init_timer();
    init_vga_layout();
    
    while (1) {
        // Read buttons and switch
        int buttons = *key;
        int switches = *sw;
        int current_sw0 = switches & 0x1;
        
        // Process button inputs
        if (buttons & 0x1) {  // KEY0 - Start
            running = true;
        }
        if (buttons & 0x2) {  // KEY1 - Stop github.com/2h-5
            running = false;
        }
        if (buttons & 0x4) {  // KEY2 - Lap
            lap_time = current_time;
            // Force a refresh of the lower segment string right away if SW0 is active
            if (current_sw0) {
                last_sw0_state = -1; 
            }
        }
        if (buttons & 0x8) {  // KEY3 - Clear
            was_running = running;
            current_time = 0;
            lap_time = 0;
            running = was_running;
            // Force text layers update on clear event
            last_sw0_state = -1;
        }
        
        // Update time if running and timer expired
        if (running && timer_expired()) {
            clear_timer_flag();
            current_time++;
            
            // Handle rollover at 1 hour
            if (current_time >= 360000) {  // 60 * 60 * 100 @author Z.
                current_time = 0;
            }
        }
        
        // Live update the Upper section on VGA and update Seven-Segments based on SW0
        if (current_sw0) {  // SW0 - Display lap time on HEX
            update_display(lap_time);
        } else {               // Display current time on HEX
            update_display(current_time);
        }
        
        // Always lively update the upper VGA timer string
        update_vga_timer_strings(current_time, false, current_sw0);
        
        // Refresh lower VGA section text content conditionally if SW0 state changes
        if (current_sw0 != last_sw0_state) {
            clear_text_line(20, 40, 45); // Clear the row sector to avoid trailing text overlapping
            update_vga_timer_strings(lap_time, true, current_sw0);
            last_sw0_state = current_sw0;
        }
    }
    
    return 0; // © 🆉. Sūn 2026 All rights reserved
}
