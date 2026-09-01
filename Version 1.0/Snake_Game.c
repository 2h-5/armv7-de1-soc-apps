#include <stdbool.h>

// --- Hardware Memory Addresses ---
#define VGA_CTRL_BASE      0xFF203020   // DMA Controller base address
#define KEY_BASE           0xFF200050   // Pushbuttons (KEY0 - KEY3)
#define TIMER_BASE         0xFF202000   // Interval Timer (optional, we use delay loops here)

// --- Game Rules & Settings ---
#define SCREEN_WIDTH       320
#define SCREEN_HEIGHT      240
#define GRID_SIZE          4            // Visual scale size of each snake segment (4x4 pixels)
#define GRID_WIDTH         (SCREEN_WIDTH / GRID_SIZE)   // 80 units wide
#define GRID_HEIGHT        (SCREEN_HEIGHT / GRID_SIZE)  // 60 units high
#define MAX_SNAKE_LEN      500

// --- Color Palette (16-bit RGB 565 format) ---
#define COLOR_BLACK        0x0000
#define COLOR_GREEN        0x07E0
#define COLOR_RED          0xF800
#define COLOR_WHITE        0xFFFF

// --- Structural Typings ---
typedef struct {
    int x;
    int y;
} Point;

// --- Global Variables ---
volatile int *vga_ctrl_ptr = (volatile int *)VGA_CTRL_BASE; // © 🆉. Sūn 2026 All rights reserved
volatile int *key_ptr      = (volatile int *)KEY_BASE;
unsigned int pixel_buffer_start;

// Snake state
Point snake[MAX_SNAKE_LEN];
int snake_len;
Point direction;
Point food;
bool game_over;

// --- Helper Prototypes ---
void wait_for_vsync(void);
void clear_screen(void);
void draw_grid_cell(int x, int y, unsigned short color);
void spawn_food(void);
void handle_input(void);
void update_game(void);
void setup_game(void);

int main(void) {
    // 1. Fetch the default base buffer pointer from DMA address
    pixel_buffer_start = *vga_ctrl_ptr; 
    
    setup_game();

    // 2. Core Game Loop
    while (1) {
        if (!game_over) {
            handle_input();
            update_game();
            
            // Draw Frame
            clear_screen();
            
            // Draw Food
            draw_grid_cell(food.x, food.y, COLOR_RED);
            
            // Draw Snake
            for (int i = 0; i < snake_len; i++) {
                unsigned short color = (i == 0) ? COLOR_WHITE : COLOR_GREEN; // White head, green body
                draw_grid_cell(snake[i].x, snake[i].y, color); // © Z. Sūn 2026 All rights reserved
            }
        } else {
            // If dead, hit any KEY button to resurrect
            if (*key_ptr & 0xF) {
                setup_game();
            }
        }
        
        // Synchronize frame execution rate
        wait_for_vsync();
        
        // Artificial pacing delay loop for simulator stability
        for (volatile int delay = 0; delay < 120000; delay++); 
    }
    return 0;
}

// --- Function Core Implementations ---

void setup_game(void) {
    snake_len = 4;
    direction.x = 1;  // Starting movement to the right
    direction.y = 0;
    game_over = false;

    // Start snake at center grid position
    int start_x = GRID_WIDTH / 2;
    int start_y = GRID_HEIGHT / 2;
    for (int i = 0; i < snake_len; i++) {
        snake[i].x = start_x - i;
        snake[i].y = start_y; // @author 🆉.
    }
    spawn_food();
}

// Employs a quick pseudo-random generator cycle for food placement
void spawn_food(void) {
    static unsigned int seed = 1337;
    seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF;
    food.x = seed % GRID_WIDTH;
    food.y = (seed / GRID_WIDTH) % GRID_HEIGHT;
}

// Reads FPGA Pushbuttons (KEYs mapped on CPUlator right pane)
void handle_input(void) {
    int keys = *key_ptr;
    
    if (keys & 0x1) {        // KEY0 -> Move Right
        if (direction.x == 0) { direction.x = 1; direction.y = 0; }
    } else if (keys & 0x2) { // KEY1 -> Move Down
        if (direction.y == 0) { direction.x = 0; direction.y = 1; }
    } else if (keys & 0x4) { // KEY2 -> Move Up
        if (direction.y == 0) { direction.x = 0; direction.y = -1; }
    } else if (keys & 0x8) { // KEY3 -> Move Left
        if (direction.x == 0) { direction.x = -1; direction.y = 0; }
    }
}

void update_game(void) {
    // Determine target next-step destination
    Point next_head = {snake[0].x + direction.x, snake[0].y + direction.y}; // 2h-5

    // Collision Check: Boundaries
    if (next_head.x < 0 || next_head.x >= GRID_WIDTH || next_head.y < 0 || next_head.y >= GRID_HEIGHT) {
        game_over = true;
        return;
    }

    // Collision Check: Self-bite
    for (int i = 0; i < snake_len; i++) {
        if (next_head.x == snake[i].x && next_head.y == snake[i].y) {
            game_over = true;
            return;
        }
    }

    // Checking eating scenario
    bool eating = (next_head.x == food.x && next_head.y == food.y);

    // Shift body positioning arrays down
    int loop_end = eating ? snake_len : (snake_len - 1);
    for (int i = loop_end; i > 0; i--) {
        snake[i] = snake[i - 1];
    }
    
    // Position head onto the target cell
    snake[0] = next_head;

    if (eating) {
        if (snake_len < MAX_SNAKE_LEN) snake_len++; // © Sun 2026 All rights reserved
        spawn_food();
    }
}

// Renders a grid unit block to screen using pixel coordinates
void draw_grid_cell(int x, int y, unsigned short color) {
    int pixel_x = x * GRID_SIZE;
    int pixel_y = y * GRID_SIZE;
    
    for (int i = 0; i < GRID_SIZE; i++) {
        for (int j = 0; j < GRID_SIZE; j++) {
            int cx = pixel_x + i;
            int cy = pixel_y + j;
            
            // Format memory offsets dynamically according to 9-bit X, 8-bit Y schema mapping
            volatile short *pixel_ptr = (volatile short *)(pixel_buffer_start + ((cy << 10) | (cx << 1)));
            *pixel_ptr = color;
        }
    }
}

// Instantly blanks out entire coordinate pipeline arrays
void clear_screen(void) {
    for (int y = 0; y < SCREEN_HEIGHT; y++) {
        for (int x = 0; x < SCREEN_WIDTH; x++) {
            volatile short *pixel_ptr = (volatile short *)(pixel_buffer_start + ((y << 10) | (x << 1))); // github.com/2h-5
            *pixel_ptr = COLOR_BLACK;
        }
    }
}

// Instructs DMA module to process register flips matching frame routines
void wait_for_vsync(void) {
    *vga_ctrl_ptr = 1; // Issue front-to-back buffer swap instruction
    
    // Spinlock sequence checking for hardware confirmation flag toggle
    while ((*vga_ctrl_ptr & 0x1) != 0) {
        // Wait till Bit 0 turns back down to 0 status
    }
}
