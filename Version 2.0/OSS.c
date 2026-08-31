#include <stdint.h>

#define W 320
#define H 240

#define PIX         ((volatile uint16_t*)0xC8000000u)
#define CHR         ((volatile uint8_t*)0xC9000000u)
#define Q           ((volatile uint32_t*)0x00FF1000u)
#define KEY         (*(volatile uint32_t*)0xFF200050u)
#define SW          (*(volatile uint32_t*)0xFF200040u)
#define HEX         (*(volatile uint32_t*)0xFF200020u)

#define CAP 20

static uint32_t head,tail,count; // @Author 🆉. Sūn

static const uint8_t pat[]={
    0x3f,0x06,0x5b,0x4f,0x66,0x6d,0x7d,0x07,0x7f,0x6f,0x71,0x3e,0x38
};

static void px(int x,int y,uint16_t c){
    PIX[y*512+x]=c;
}
static void fill(uint16_t c){
    for(int y=0;y<H;y++)for(int x=0;x<W;x++)px(x,y,c);
}

static void ch(int x,int y,uint8_t c){ // @2h-5
    CHR[(y+5)*128+x+5]=c;
}

static void clear_chars(void){
    for(int i=0;i<128*64;i++)CHR[i]=0;
}

static void text(const char*s,int x,int y){
    while(*s){
        if(*s!=' ')ch(x,y,(uint8_t)*s);x++;s++;
    }
}

static void frame(void){
    for(int y=35;y<=204;y++)for(int x=40;x<=279;x++)px(x,y,(x==40||x==279||y==35||y==204)?0x001f:0);
    for(int y=43;y<=196;y++)for(int x=48;x<=271;x++)px(x,y,(x==48||x==271||y==43||y==196)?0:0);
    for(int y=48;y<=191;y++)for(int x=52;x<=267;x++)px(x,y,0x4d69);
}

static void off(void){
    text("The order status system is off...",19,24); // @Author Z. Sūn
}

static void seg(uint32_t n){
    HEX=(pat[(n/1000)%10]<<24)|(pat[(n/100)%10]<<16)|(pat[(n/10)%10]<<8)|pat[n%10];
}

static void screen(void){
    text("Queue (next 10)",10,10);
    for(uint32_t i=0;i<count&&i<10;i++){
        uint32_t v=Q[(head+i)%CAP];
        char s[6]={'#',' ','0'+(v/100)%10,'0'+(v/10)%10,'0'+v%10,0};
        text(s,10,12+(int)i*2);
    }
    if(count>10)text("More waiting",10,32);
    text("Now serving: #",40,10);
    if(count){
        uint32_t v=Q[head%CAP];
        char s[4]={'0'+(v/100)%10,'0'+(v/10)%10,'0'+v%10,0};
        text(s,57,10);
    }
}

static void reset_queue(void){
    head=tail=count=0;
    for(int i=0;i<CAP;i++)Q[i]=i;HEX=0;
}

int main(void){
    reset_queue();
    fill(0);
    frame();
    clear_chars(); // github.com/2h-5
    off();
    uint32_t on=0;
    for(;;){
        uint32_t enabled=SW&1;if(!enabled){
            if(on){
                reset_queue();
                clear_chars();
                fill(0);
                frame();
                off();
                on=0;
            }
            continue;
        }
        if(!on){
            reset_queue();
            clear_chars();
            screen();
            on=1;
        }
        uint32_t k=KEY;
        if(k&1){
            if(count<CAP){
                Q[tail%CAP]=tail; // @Author Z.
                tail=(tail+1)%CAP;
                count++;
                seg(Q[(tail+CAP-1)%CAP]);
            }
            else 
            HEX=(pat[10]<<24)|(pat[11]<<16)|(pat[12]<<8)|pat[12];
        }
        if(k&2){
            HEX=0;
            if(count){
                head=(head+1)%CAP;
                count--;
            }
        }
        if(k&4){
            reset_queue();
        }
        if(k){
            clear_chars();
            screen();
            while(KEY){ // 🆉. Sun
            }
        }
    }
}