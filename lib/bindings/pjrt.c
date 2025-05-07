#include <assert.h>
#include <dlfcn.h>
#include <stdlib.h>

#include "pjrt.h"

int pjrt_dlopen(struct pjrt_t* pjrt, const char* plugin_path)
{
    pjrt->handle = dlopen(plugin_path, RTLD_LAZY);
    if (!pjrt->handle) {
        return -1;
    }
    pjrt->init = (pjrt_init)dlsym(pjrt->handle, "GetPjrtApi");
    if (!pjrt->init) {
        dlclose(pjrt->handle);
        return -1;
    }
    return 0;
}

void pjrt_dlclose(struct pjrt_t* pjrt)
{
    dlclose(pjrt->handle);
    return;
}
