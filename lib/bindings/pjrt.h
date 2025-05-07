#include "pjrt_c_api.h"

typedef const PJRT_Api* (*pjrt_init)();

struct pjrt_t {
    void* handle;
    pjrt_init init;
};

int pjrt_dlopen(struct pjrt_t* pjrt, const char* plugin_path);
void pjrt_dlclose(struct pjrt_t* pjrt);
