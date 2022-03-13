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

// #include <dlfcn.h>

static char buffer[3200];

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
    // void* dl_handle = dlopen("libpdcurses.so", RTLD_LAZY | RTLD_DEEPBIND);
    //   if (!dl_handle) {
    //     printf( "!!! %s\n", dlerror() );
    //     return;
    //   } else {
    //     printf("loaded!\n");
    //   }
    // void (*func)(float);

    setUpdateConsumers(4);
    pthread_create(&threadId, NULL, &run_thread, (void*)"");
}

EXPORT
char* getScreenBuffer()
{
    return getScreenData();
}

EXPORT
void pushString(char *key)
{
    pushKey(key[0]);
}