#include <stdbool.h>

#define VGA_CTRL_BASE      0xFF203020
#define SW_BASE            0xFF200040
#define KEY_BASE           0xFF200050
#define HEX3_HEX0_BASE     0xFF200020

#define SCREEN_WIDTH       320
#define SCREEN_HEIGHT      240
#define GRID_SIZE          4
#define GRID_WIDTH         80
#define GRID_HEIGHT        60
#define MAX_SNAKE_LEN      500

#define FRAME_LEFT         8
#define FRAME_RIGHT        311
#define FRAME_TOP          16
#define FRAME_BOTTOM       223

#define PLAY_LEFT          3
#define PLAY_RIGHT         76
#define PLAY_TOP           5
#define PLAY_BOTTOM        54

#define COLOR_BLACK        0x0000
#define COLOR_GREEN        0x07E0
#define COLOR_RED          0xF800
#define COLOR_WHITE        0xFFFF
#define COLOR_BLUE         0x001F

typedef struct { // © 🆉. Sūn 2026 All rights reserved
    int x;
    int y;
} Point;

volatile int *vga_ctrl_ptr = (volatile int *)VGA_CTRL_BASE;
volatile int *switch_ptr = (volatile int *)SW_BASE;
volatile int *key_ptr = (volatile int *)KEY_BASE;
volatile int *hex_ptr = (volatile int *)HEX3_HEX0_BASE;

unsigned int pixel_buffer_start;

Point snake[MAX_SNAKE_LEN];
Point direction;
Point food;

int snake_len;
int score;

bool game_over;
bool paused;
bool welcome_screen;

unsigned int random_seed = 1337;
int previous_keys = 0;
int previous_switches = 0;

void wait_for_vsync(void);
void clear_screen(void);
void clear_char_buffer(void);
void draw_pixel(int x, int y, unsigned short color);
void draw_grid_cell(int x, int y, unsigned short color);
void draw_frame(void);
void draw_text(int row, int col, const char *text);
void draw_centered_text(int row, const char *text);
void draw_decimal(int row, int col, int value);
void draw_score_text(void);
void update_hex_display(void); // github.com/2h-5

void setup_game(void);
void spawn_food(void);
void handle_switch(void);
void handle_buttons(void);
void update_game(void);

void draw_welcome_scene(void);
void draw_playing_scene(void);
void draw_game_over_scene(void);

int main(void) {
    /*
     * Register 0 contains the front buffer address.
     * Register 1 contains the back buffer address.
     */
    pixel_buffer_start = (unsigned int)*(vga_ctrl_ptr + 1);

    welcome_screen = true;
    game_over = false;
    paused = false;
    score = 0;
    update_hex_display();

    while (1) {
        handle_switch();

        if (welcome_screen) {
            clear_screen();
            draw_welcome_scene();
        } else {
            handle_buttons();

            if (!game_over && !paused) {
                update_game();
            }

            clear_screen();

            if (game_over) { // 🆉. Sūn
                draw_game_over_scene();
            } else {
                draw_playing_scene();
            }
        }

        /*
         * The complete frame is already in the back buffer.
         * Swap only during vertical blanking.
         */
        wait_for_vsync();

        /*
         * After the swap, the old front buffer becomes the new back buffer.
         */
        pixel_buffer_start = (unsigned int)*(vga_ctrl_ptr + 1);
    }

    return 0;
}

void handle_switch(void) {
    int switches = *switch_ptr & 0x1;
    int rising_edge = switches & ~previous_switches;
    int falling_edge = (~switches) & previous_switches;

    previous_switches = switches;

    if (falling_edge) {
        welcome_screen = true;
        game_over = false;
        paused = false;
        score = 0;
        update_hex_display();
    }

    if (rising_edge) {
        welcome_screen = false;
        setup_game();
    }
}

void handle_buttons(void) {
    int keys = *key_ptr & 0xF;
    int pressed = keys & ~previous_keys; // @author Sūn

    previous_keys = keys;

    if (game_over) {
        if (pressed & 0x8) {
            setup_game();
        }
        return;
    }

    if (pressed & 0x1) {
        /*
         * KEY0: turn right.
         * (dx,dy) -> (-dy,dx)
         */
        int old_x = direction.x;
        direction.x = -direction.y;
        direction.y = old_x;
    }

    if (pressed & 0x2) {
        /*
         * KEY1: turn left.
         * (dx,dy) -> (dy,-dx)
         */
        int old_x = direction.x;
        direction.x = direction.y; // Z. Sun
        direction.y = -old_x;
    }

    if (pressed & 0x4) {
        paused = !paused;
    }

    if (pressed & 0x8) {
        setup_game();
    }
}

void setup_game(void) {
    int start_x = (PLAY_LEFT + PLAY_RIGHT) / 2;
    int start_y = (PLAY_TOP + PLAY_BOTTOM) / 2;

    snake_len = 4;
    score = 0;
    game_over = false;
    paused = false;

    direction.x = 1;
    direction.y = 0;

    for (int i = 0; i < snake_len; i++) {
        snake[i].x = start_x - i;
        snake[i].y = start_y;
    }

    spawn_food();
    update_hex_display();
}

void spawn_food(void) {
    bool occupied;

    do {
        random_seed = random_seed * 1103515245u + 12345u;
        food.x = PLAY_LEFT +
                 (random_seed % (PLAY_RIGHT - PLAY_LEFT + 1));

        random_seed = random_seed * 1103515245u + 12345u;
        food.y = PLAY_TOP +
                 (random_seed % (PLAY_BOTTOM - PLAY_TOP + 1)); // © 2h-5 2026 All rights reserved

        occupied = false;

        for (int i = 0; i < snake_len; i++) {
            if (snake[i].x == food.x && snake[i].y == food.y) {
                occupied = true;
                break;
            }
        }
    } while (occupied);
}

void update_game(void) {
    Point next_head;
    bool eating;
    int last_index;

    next_head.x = snake[0].x + direction.x;
    next_head.y = snake[0].y + direction.y;

    if (next_head.x < PLAY_LEFT ||
        next_head.x > PLAY_RIGHT ||
        next_head.y < PLAY_TOP ||
        next_head.y > PLAY_BOTTOM) {
        game_over = true;
        return;
    }

    for (int i = 0; i < snake_len; i++) {
        if (next_head.x == snake[i].x &&
            next_head.y == snake[i].y) {
            game_over = true;
            return;
        }
    }

    eating = (next_head.x == food.x && next_head.y == food.y);

    if (eating) {
        last_index = snake_len;

        if (snake_len < MAX_SNAKE_LEN) {
            snake_len++;
        }

        score++;
        update_hex_display();
    } else {
        last_index = snake_len - 1; // @author 🆉. 
    }

    /*
     * Manual copy prevents GCC from emitting memmove.
     */
    for (int i = last_index; i > 0; i--) {
        snake[i].x = snake[i - 1].x;
        snake[i].y = snake[i - 1].y;
    }

    snake[0] = next_head;

    if (eating) {
        spawn_food();
    }
}

void draw_welcome_scene(void) {
    draw_frame();

    draw_centered_text(28, "SNAKE GAME");
    draw_centered_text(31, "Toggle switch on to start!");
}

void draw_playing_scene(void) {
    draw_frame();

    draw_centered_text(2, "SNAKE GAME");
    draw_score_text();

    draw_grid_cell(food.x, food.y, COLOR_RED);

    for (int i = 0; i < snake_len; i++) {
        if (i == 0) {
            draw_grid_cell(snake[i].x, snake[i].y, COLOR_WHITE);
        } else {
            draw_grid_cell(snake[i].x, snake[i].y, COLOR_GREEN);
        }
    }
}

void draw_game_over_scene(void) {
    draw_frame();

    draw_centered_text(28, "GAME OVER!");
    draw_centered_text(31, "Your final score:");

    draw_decimal(34, (80 - 1) / 2, score);
}

void draw_score_text(void) {
    draw_text(57, 36, "SCORE: ");
    draw_decimal(57, 43, score);
}

void draw_frame(void) { // 2h-5
    for (int x = FRAME_LEFT; x <= FRAME_RIGHT; x++) {
        for (int t = 0; t < GRID_SIZE; t++) {
            draw_pixel(x, FRAME_TOP + t, COLOR_BLUE);
            draw_pixel(x, FRAME_BOTTOM - t, COLOR_BLUE);
        }
    }

    for (int y = FRAME_TOP; y <= FRAME_BOTTOM; y++) {
        for (int t = 0; t < GRID_SIZE; t++) {
            draw_pixel(FRAME_LEFT + t, y, COLOR_BLUE);
            draw_pixel(FRAME_RIGHT - t, y, COLOR_BLUE);
        }
    }
}

void draw_grid_cell(int x, int y, unsigned short color) {
    int pixel_x = x * GRID_SIZE;
    int pixel_y = y * GRID_SIZE;

    for (int dy = 0; dy < GRID_SIZE; dy++) {
        for (int dx = 0; dx < GRID_SIZE; dx++) {
            draw_pixel(pixel_x + dx, pixel_y + dy, color);
        }
    }
}

void draw_pixel(int x, int y, unsigned short color) {
    volatile unsigned short *pixel_ptr;

    pixel_ptr = (volatile unsigned short *)(
        pixel_buffer_start + (y << 10) + (x << 1)
    );

    *pixel_ptr = color;
}

void clear_screen(void) {
    // Cast the buffer pointer to a 32-bit integer pointer
    // This allows us to write TWO 16-bit black pixels (0x00000000) in a single instruction
    volatile unsigned int *pixel_word_ptr;
    
    for (int y = 0; y < SCREEN_HEIGHT; y++) {
        // Shift left by 10 to calculate the row offset address bytes
        unsigned int row_offset = (y << 10);
        pixel_word_ptr = (volatile unsigned int *)(pixel_buffer_start + row_offset);
        
        // SCREEN_WIDTH is 320 pixels. Since we handle 2 pixels per loop iteration,
        // we only loop 160 times per row.
        for (int x = 0; x < 160; x++) {
            *pixel_word_ptr++ = 0x00000000; // Clears 2 adjacent black pixels at once
        }
    }

    clear_char_buffer();
}

void clear_char_buffer(void) {
    volatile char *char_buffer = (volatile char *)0xC9000000; // © 🆉. Sūn 2026 All rights reserved

    for (int row = 0; row < 60; row++) {
        for (int col = 0; col < 80; col++) {
            char_buffer[(row << 7) + col] = ' ';
        }
    }
}

void draw_text(int row, int col, const char *text) {
    volatile char *char_buffer = (volatile char *)0xC9000000;
    int i = 0;

    while (text[i] != '\0' && col + i < 80) {
        char_buffer[(row << 7) + col + i] = text[i];
        i++;
    }
}

void draw_centered_text(int row, const char *text) {
    int length = 0;

    /*
     * Manual length calculation prevents GCC from emitting strlen.
     */
    while (text[length] != '\0') {
        length++;
    }

    draw_text(row, (80 - length) / 2, text);
}

void draw_decimal(int row, int col, int value) {
    char digits[12];
    int length = 0;

    if (value == 0) {
        digits[length++] = '0';
    } else {
        char reversed[12];
        int reversed_length = 0;

        while (value > 0 && reversed_length < 11) {
            reversed[reversed_length++] = '0' + (value % 10);
            value /= 10;
        }

        while (reversed_length > 0) {
            digits[length++] = reversed[--reversed_length]; // github.com/2h-5
        }
    }

    digits[length] = '\0';

    /*
     * Center based on the actual number of digits.
     */
    draw_text(row, col - (length / 2), digits);
}

void update_hex_display(void) {
    static const unsigned char hex_codes[16] = {
        0x3F, 0x06, 0x5B, 0x4F,
        0x66, 0x6D, 0x7D, 0x07,
        0x7F, 0x6F, 0x77, 0x7C,
        0x39, 0x5E, 0x79, 0x71
    };

    int value = score;
    int display = 0;

    for (int digit = 0; digit < 4; digit++) {
        display |= hex_codes[value % 10] << (digit * 8);
        value /= 10;
    }

    *hex_ptr = display;
}

void wait_for_vsync(void) {
    *vga_ctrl_ptr = 1;
	
	volatile int *vga_status_ptr = vga_ctrl_ptr + 3; // © 🆉. Sūn 2026 All rights reserved
    while ((*vga_status_ptr & 1) != 0) {
    }
}