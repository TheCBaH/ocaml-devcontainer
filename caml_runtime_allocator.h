#define _GNU_SOURCE

#include <stdlib.h>

void *caml_runtime_calloc(size_t nmemb, size_t size);
void *caml_runtime_malloc(size_t size);
void *caml_runtime_realloc(void *ptr, size_t size);
void caml_runtime_free(void *ptr);

void caml_runtime_init(void);
void caml_runtime_uninit(void);

#if defined(CAML_NAME_SPACE)
#define calloc caml_runtime_calloc
#define malloc caml_runtime_malloc
#define realloc caml_runtime_realloc
#define reallocarray not_supported
#define free caml_runtime_free
#endif
