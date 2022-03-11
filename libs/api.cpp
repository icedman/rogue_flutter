#ifdef WIN32
#define EXPORT __declspec(dllexport)
#else
#define EXPORT extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

#include <cstring>
#include <ctype.h>
#include <curses.h>
#include <rogue.h>
#include <pthread.h>

static char buffer[1024];

extern "C" {
char *getScreenData();
bool isScreenDirty();
void setUpdateConsumers(int c);
void pushKey(int k);
int rogue_main(int argc, char **argv);
int is_rogue_running();
}
pthread_t threadId;

EXPORT
int add(int a, int b)
{
    return a + b;
}

EXPORT
char* capitalize(char *str) {
    strcpy(buffer, str);
    buffer[0] = toupper(buffer[0]);
    return buffer;
}

void* run_thread(void* arg)
{
    const char *argv[] = {
        "rogue",
        "--scr-width=80",
        "--scr-height=25",
        "--sec-width=80",
        "--sec-height=25",
    };
    
    rogue_main(5, (char**)argv);
    return NULL;
}

EXPORT
void initApp()
{
    // setUpdateConsumers(4);
    pthread_create(&threadId, NULL, &run_thread, (void*)"");
}

EXPORT
char* getScreenBuffer()
{
    // pushKey(' ');
    // printf(">>%d\n", isScreenDirty());
    // char* res = getScreenData();
    // for(int y=0; y<40; y++) {
    //     for(int x=0; x<80; x++) {
    //         char c = res[y*80+x];
    //         printf("%c", c);
    //     }
    //     printf("\n");
    // }
    strcpy(buffer, "");
    return buffer;
}