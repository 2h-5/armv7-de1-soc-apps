#include <stdbool.h>

#define VGA_CTRL_BASE  0xFF203020
#define KEY_BASE       0xFF200050
#define HEX3_HEX0_BASE 0xFF200020
#define PIXEL_BUFFER    0xC8000000
#define CHAR_BUFFER     0xC9000000

#define SCREEN_WIDTH  320
#define SCREEN_HEIGHT 240
#define GRID_SIZE     4
#define GRID_WIDTH    (SCREEN_WIDTH / GRID_SIZE)
#define GRID_HEIGHT   (SCREEN_HEIGHT / GRID_SIZE)
#define MAX_SNAKE_LEN 500

#define FRAME_LEFT    8
#define FRAME_RIGHT   311
#define FRAME_TOP     16
#define FRAME_BOTTOM  223

#define PLAY_LEFT     ((FRAME_LEFT / GRID_SIZE) + 1)
#define PLAY_RIGHT    ((FRAME_RIGHT / GRID_SIZE) - 1)
#define PLAY_TOP      ((FRAME_TOP / GRID_SIZE) + 1)
#define PLAY_BOTTOM   ((FRAME_BOTTOM / GRID_SIZE) - 1)

#define COLOR_BLACK 0x0000
#define COLOR_GREEN 0x07E0
#define COLOR_RED   0xF800
#define COLOR_WHITE 0xFFFF
#define COLOR_BLUE  0x001F

typedef struct { // github.com/2h-5
    int x;
    int y;
} Point;

volatile int *vga_ctrl_ptr = (volatile int *)VGA_CTRL_BASE;
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

void wait_for_vsync(void);
void clear_screen(void);
void draw_pixel(int x, int y, unsigned short color);
void draw_rect_frame(void);
void draw_grid_cell(int x, int y, unsigned short color);
void clear_char_buffer(void);
void draw_text(int row, int col, const char *text);
void draw_centered_text(int row, const char *text);
void draw_decimal(int row, int col, int value); // @author Z.
void spawn_food(void);
void update_hex_display(void);
void handle_input(void);
void update_game(void);
void draw_playing_scene(void);
void draw_game_over_scene(void);
void setup_game(void);

int main(void) {
    pixel_buffer_start = PIXEL_BUFFER;

    setup_game();

    while (1) {
        handle_input();

        if (!game_over && !paused) {
            update_game();
        }

        clear_screen();

        if (game_over) {
            draw_game_over_scene();
        } else {
            draw_playing_scene(); // © 🆉. Sūn 2026 All rights reserved
        }

        wait_for_vsync();

        for (volatile int delay = 0; delay < 120000; delay++) {
        }
    }

    return 0;
}

void setup_game(void) {
    snake_len = 4;
    score = 0;
    game_over = false;
    paused = false;

    direction.x = 1;
    direction.y = 0;

    int start_x = (PLAY_LEFT + PLAY_RIGHT) / 2;
    int start_y = (PLAY_TOP + PLAY_BOTTOM) / 2;

    for (int i = 0; i < snake_len; i++) {
        snake[i].x = start_x - i;
        snake[i].y = start_y;
    }

    spawn_food();
    update_hex_display();
}

void spawn_food(void) {
    static unsigned int seed = 1337; // © Z. Sun 2026 All rights reserved

    do {
        seed = seed * 1103515245u + 12345u;
        food.x = PLAY_LEFT + (seed % (PLAY_RIGHT - PLAY_LEFT + 1));

        seed = seed * 1103515245u + 12345u;
        food.y = PLAY_TOP + (seed % (PLAY_BOTTOM - PLAY_TOP + 1));

        bool occupied = false;

        for (int i = 0; i < snake_len; i++) {
            if (snake[i].x == food.x && snake[i].y == food.y) {
                occupied = true;
                break;
            }
        }

        if (!occupied) {
            return;
        }
    } while (1);
}

void handle_input(void) {
    static int previous_keys = 0;
    int keys = *key_ptr & 0xF;
    int pressed = keys & ~previous_keys;

    previous_keys = keys;

    if (pressed & 0x1) {
        if (!game_over) {
            int old_x = direction.x;
            direction.x = -direction.y;
            direction.y = old_x;
        }
    }

    if (pressed & 0x2) {
        if (!game_over) {
            int old_x = direction.x;
            direction.x = direction.y;
            direction.y = -old_x;
        }
    }

    if (pressed & 0x4) {
        if (!game_over) {
            paused = !paused; // @author 2h-5
        }
    }

    if (pressed & 0x8) {
        setup_game();
    }
}

void update_game(void) {
    Point next_head;

    next_head.x = snake[0].x + direction.x;
    next_head.y = snake[0].y + direction.y;

    if (next_head.x <= PLAY_LEFT - 1 ||
        next_head.x >= PLAY_RIGHT + 1 ||
        next_head.y <= PLAY_TOP - 1 ||
        next_head.y >= PLAY_BOTTOM + 1) {
        game_over = true;
        update_hex_display();
        return;
    }

    for (int i = 0; i < snake_len; i++) {
        if (next_head.x == snake[i].x &&
            next_head.y == snake[i].y) {
            game_over = true;
            update_hex_display();
            return;
        }
    }

    bool eating = next_head.x == food.x && next_head.y == food.y;

    int last = eating ? snake_len : snake_len - 1; // © 🆉. 2026 All rights reserved

    for (int i = last; i > 0; i--) {
        snake[i] = snake[i - 1];
    }

    snake[0] = next_head;

    if (eating) {
        if (snake_len < MAX_SNAKE_LEN) {
            snake_len++;
        }

        score++;
        spawn_food();
        update_hex_display();
    }
}

void draw_playing_scene(void) {
    draw_rect_frame();

    draw_centered_text(2, "SNAKE GAME");

    char score_text[] = "SCORE: ";
    draw_text(57, 36, score_text);
    draw_decimal(57, 43, score);

    draw_grid_cell(food.x, food.y, COLOR_RED);

    for (int i = 0; i < snake_len; i++) {
        draw_grid_cell(
            snake[i].x,
            snake[i].y,
            i == 0 ? COLOR_WHITE : COLOR_GREEN
        );
    }
}

void draw_game_over_scene(void) {
    draw_rect_frame();

    draw_centered_text(28, "GAME OVER!");
    draw_centered_text(31, "Your final score:"); // © Sūn 2026 All rights reserved

    char score_text[12];
    int value = score;
    int index = 0;

    if (value == 0) {
        score_text[index++] = '0';
    } else {
        char reversed[12];
        int reverse_index = 0;

        while (value > 0) {
            reversed[reverse_index++] = '0' + (value % 10);
            value /= 10;
        }

        while (reverse_index > 0) {
            score_text[index++] = reversed[--reverse_index];
        }
    }

    score_text[index] = '\0';
    draw_centered_text(34, score_text);
}

void draw_rect_frame(void) {
    for (int x = FRAME_LEFT; x <= FRAME_RIGHT; x++) {
        for (int t = 0; t < GRID_SIZE; t++) {
            draw_pixel(x, FRAME_TOP + t, COLOR_BLUE);
            draw_pixel(x, FRAME_BOTTOM - t, COLOR_BLUE);
        }
    }

    for (int y = FRAME_TOP; y <= FRAME_BOTTOM; y++) {
        for (int t = 0; t < GRID_SIZE; t++) {
            draw_pixel(FRAME_LEFT + t, y, COLOR_BLUE);
            draw_pixel(FRAME_RIGHT - t, y, COLOR_BLUE); // @author Sun
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
    for (int y = 0; y < SCREEN_HEIGHT; y++) {
        for (int x = 0; x < SCREEN_WIDTH; x++) {
            draw_pixel(x, y, COLOR_BLACK);
        }
    }

    clear_char_buffer();
}

void clear_char_buffer(void) {
    volatile char *char_buffer = (volatile char *)CHAR_BUFFER; // © 🆉. Sūn 2026 All rights reserved

    for (int row = 0; row < 60; row++) {
        for (int col = 0; col < 80; col++) {
            char_buffer[(row << 7) + col] = ' ';
        }
    }
}

void draw_text(int row, int col, const char *text) {
    volatile char *char_buffer = (volatile char *)CHAR_BUFFER;
    int i = 0;

    while (text[i] != '\0' && col + i < 80) {
        char_buffer[(row << 7) + col + i] = text[i];
        i++;
    }
}

void draw_centered_text(int row, const char *text) {
    int length = 0;

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
        int reverse_length = 0;

        while (value > 0) {
            reversed[reverse_length++] = '0' + (value % 10);
            value /= 10;
        }

        while (reverse_length > 0) {
            digits[length++] = reversed[--reverse_length]; // 2h-5
        }
    }

    digits[length] = '\0';
    draw_text(row, col, digits);
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

    while ((*vga_ctrl_ptr & 1) != 0) { // Z. 
    }
}