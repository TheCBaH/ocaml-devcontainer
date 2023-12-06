#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <pthread.h>

#include "caml_runtime_allocator.h"

struct header {
    unsigned idx;
};

struct allocation {
    union {
        struct header header;
        uint64_t _64;
        void *_ptr;
    } header;
    uint64_t data[1];
};

struct allocation_table {
    struct allocation **entry;
    unsigned count;
    unsigned prev;
};

static struct allocation_table alloc_table = {
    NULL,
    0,
    0
};
static pthread_mutex_t alloc_mutex = PTHREAD_MUTEX_INITIALIZER;

static void *register_ptr_locked(struct allocation *alloc, const struct header *old_header)
{
    unsigned id;
    unsigned i;

    if (alloc != NULL) {
        if (old_header) {
            id = old_header->idx;
        } else {
            for (id = alloc_table.prev, i = 0; i < alloc_table.count; i++) {
                if (alloc_table.entry[id] == NULL) {
                    break;
                }
                id = (id + 1) % alloc_table.count;
            }
            if (i == alloc_table.count) {
                unsigned new_count = alloc_table.count * 2;
                struct allocation** new_entry;
                if (new_count == 0) {
                    new_count = 64;
                }
                if (alloc_table.entry) {
                    new_entry = realloc(alloc_table.entry, new_count * sizeof(*new_entry));
                } else {
                    new_entry = malloc(new_count * sizeof(*new_entry));
                }
                assert(new_entry);
                for (id = alloc_table.count; id < new_count; id++) {
                    new_entry[id] = NULL;
                }
                id = alloc_table.count;
                alloc_table.count = new_count;
                alloc_table.entry = new_entry;
            }
            alloc_table.prev = id;
        }
        assert(id < alloc_table.count);
        alloc->header.header.idx = id;
        alloc_table.entry[id] = alloc;
        return alloc->data;
    }
    return alloc;
}

static void *register_ptr(struct allocation *alloc, const struct header *old_header)
{
    void* result;
    pthread_mutex_lock(&alloc_mutex);
    result = register_ptr_locked(alloc, old_header);
    pthread_mutex_unlock(&alloc_mutex);
    return result;
}

void *caml_runtime_malloc(size_t size)
{
    struct allocation *alloc;
    size_t alloc_size = size + sizeof(alloc->header);

    alloc = malloc(alloc_size);
    return register_ptr(alloc, NULL);
}

void *caml_runtime_calloc(size_t nmemb, size_t size)
{
    struct allocation *alloc;
    size_t alloc_size = nmemb * size + sizeof(alloc->header);

    alloc = calloc(alloc_size, 1);
    return register_ptr(alloc, NULL);
}

static struct allocation *get_alloc(void *ptr)
{
    struct allocation *alloc = ptr;
    if (ptr) {
        alloc = (struct allocation *)((uint8_t *)alloc - sizeof(alloc->header));
    }
    return alloc;
}

void *caml_runtime_realloc(void *ptr, size_t size)
{
    struct allocation *alloc = get_alloc(ptr);
    struct header header_;
    const struct header *header = NULL;
    size_t alloc_size = size + sizeof(alloc->header);
    if (alloc) {
        header_ = alloc->header.header;
        header = &header_;
    }
    alloc = realloc(alloc, alloc_size);
    return register_ptr(alloc, header);
}

void caml_runtime_free(void *ptr)
{
    struct allocation* alloc = get_alloc(ptr);
    pthread_mutex_lock(&alloc_mutex);
    if (alloc) {
        unsigned idx = alloc->header.header.idx;
        assert(idx < alloc_table.count);
        assert(alloc_table.entry[idx]);
        alloc_table.entry[idx] = NULL;
    }
    pthread_mutex_unlock(&alloc_mutex);
    free(alloc);
    return;
}

void caml_runtime_init(void)
{
    alloc_table.count = 0;
    alloc_table.prev = 0;
    alloc_table.entry = NULL;
    return;
}

void caml_runtime_uninit(void)
{
    unsigned i;
    pthread_mutex_lock(&alloc_mutex);
    for (i = 0; i < alloc_table.count; i++) {
        if (alloc_table.entry[i]) {
            free(alloc_table.entry[i]);
        }
    }
    if (alloc_table.entry) {
        free(alloc_table.entry);
    }
    pthread_mutex_unlock(&alloc_mutex);
    return;
}
