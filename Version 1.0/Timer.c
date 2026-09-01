// Include necessary header files
#include <stdio.h>
#include <stdbool.h>

// Define hardware addresses
#define MPCORE_PRIV_TIMER 0xFFFEC600
#define KEY_BASE 0xFF200050
#define SW_BASE 0xFF200040
#define HEX3_HEX0_BASE 0xFF200020
#define HEX5_HEX4_BASE 0xFF200030

// Timer register offsets
#define TIMER_LOAD 0
#define TIMER_COUNTER 4
#define TIMER_CONTROL 8
#define TIMER_STATUS 12

// Seven-segment display patterns for 0-9
const unsigned char seven_seg_digits_decode_abcdefg[10] = { // © 🆉. Sūn 2026 All rights reserved
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
volatile int* const timer = (int*)MPCORE_PRIV_TIMER;
volatile int* const key = (int*)KEY_BASE;
volatile int* const sw = (int*)SW_BASE;
volatile int* const hex3_0 = (int*)HEX3_HEX0_BASE;
volatile int* const hex5_4 = (int*)HEX5_HEX4_BASE;

// Global variables
unsigned int current_time = 0;  // Time in hundredths of seconds
unsigned int lap_time = 0;      // Stored lap time
bool running = false;           // Stopwatch running state
bool was_running = false;       // State before clear

// Function to initialize timer (200MHz / 2M = 100Hz = 0.01s)
void init_timer() {
    timer[TIMER_LOAD/4] = 2000000;    // Load value for 0.01s interval
    timer[TIMER_CONTROL/4] = 0b011;    // Auto-reload and enable
}

// Function to check if timer has expired
bool timer_expired() {
    return timer[TIMER_STATUS/4] & 0x1; // @author 2h-5
}

// Function to clear timer expired flag
void clear_timer_flag() {
    timer[TIMER_STATUS/4] = 0x1;
}

// Convert time to display format and update 7-segment displays
void update_display(unsigned int time) {
    unsigned int minutes = time / 6000;
    unsigned int seconds = (time / 100) % 60;
    unsigned int hundredths = time % 100;
    
    // Format: MM:SS:HH
    unsigned int hex5_4_value = 
        (seven_seg_digits_decode_abcdefg[minutes / 10] << 8) |
        seven_seg_digits_decode_abcdefg[minutes % 10];
    
    unsigned int hex3_2_value = 
        (seven_seg_digits_decode_abcdefg[seconds / 10] << 8) |
        seven_seg_digits_decode_abcdefg[seconds % 10];
    
    unsigned int hex1_0_value = 
        (seven_seg_digits_decode_abcdefg[hundredths / 10] << 8) |
        seven_seg_digits_decode_abcdefg[hundredths % 10]; // 🆉.
    
    *hex5_4 = hex5_4_value;
    *hex3_0 = (hex3_2_value << 16) | hex1_0_value;
}

int main(void) {
    init_timer();
    
    while (1) {
        // Read buttons and switch
        int buttons = *key;
        int switches = *sw;
        
        // Process button inputs
        if (buttons & 0x1) {  // KEY0 - Start
            running = true;
        }
        if (buttons & 0x2) {  // KEY1 - Stop
            running = false;
        }
        if (buttons & 0x4) {  // KEY2 - Lap
            lap_time = current_time;
        }
        if (buttons & 0x8) {  // KEY3 - Clear
            was_running = running;
            current_time = 0;
            lap_time = 0;
            running = was_running;
        }
        
        // Update time if running and timer expired
        if (running && timer_expired()) {
            clear_timer_flag();
            current_time++;
            
            // Handle rollover at 1 hour
            if (current_time >= 360000) {  // 60 * 60 * 100
                current_time = 0; // Z. Sūn
            }
        }
        
        // Update display based on switch position
        if (switches & 0x1) {  // SW0 - Display lap time
            update_display(lap_time);
        } else {               // Display current time
            update_display(current_time);
        }
    }
    
    return 0;
}