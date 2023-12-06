#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include "ffi_c.h"

static bool initialized = false;

struct test_union *create_foo(int a)
{
    struct test_union *t;

    assert(initialized);
    t = malloc(sizeof(*t));
    assert(t);
    t->type = foo;
    t->data.foo.a = a;
    return t;
}

struct test_foo *make_foo(int a)
{
    struct test_foo *t = malloc(sizeof(*t));
    assert(initialized);
    assert(t);
    t->a = a;
    return t;
}

void destroy_foo(struct test_foo *foo)
{
    assert(initialized);
    assert(foo);
    free(foo);
    return;
}

struct test_union* create_bar(struct test_foo *foo)
{
    struct test_union *t = malloc(sizeof(*t));
    assert(t);
    assert(initialized);
    t->type = bar;
    t->data.bar.foo = foo;
    return t;
}

void test_destroy(struct test_union *t)
{
    assert(initialized);
    switch (t->type) {
    case foo:
        break;
    case bar:
        free(t->data.bar.foo);
        break;
    }
    free(t);
    return;
}

void test_print(const struct test_union *t)
{
    assert(initialized);
    switch (t->type) {
    case foo:
        printf("%p:foo:%u\n", (void *)t, t->data.foo.a);
        break;
    case bar:
        printf("%p:bar:{%p:%u}\n", (void *)t, t->data.bar.foo, t->data.bar.foo->a);
        break;
    }
    return;
}

int test_get_value(const struct test_union* t)
{
    assert(initialized);
    switch (t->type) {
    case foo:
        return t->data.foo.a;
    case bar:
        return t->data.bar.foo->a;
    }
    return -1;
}

int test_init(int version)
{
    assert(version == TEST_VERSION);
    assert(!initialized);
    initialized = true;
    return 0;
}

void test_uninit(void)
{
    assert(initialized);
    initialized = false;
    return;
}

void test_log(const char *str)
{
    assert(initialized);
    printf("Log: %s\n", str);
    return;
}
