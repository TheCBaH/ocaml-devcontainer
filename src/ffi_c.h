#ifndef _FFI_H
#define _FFI_H

enum test_enum {
    bar,
    foo
};

struct test_foo {
    int a;
};

struct test_bar {
    struct test_foo *foo;
};

struct test_union {
    enum test_enum type;
    union {
        struct test_foo foo;
        struct test_bar bar;
    } data;
};

#define TEST_VERSION    1
int test_init(int version);
void test_uninit(void);
void test_log(const char *str);

struct test_union *create_foo(int a);
struct test_foo *make_foo(int a);
void destroy_foo(struct test_foo *foo);
struct test_union *create_bar(struct test_foo *foo);
void test_destroy(struct test_union *t);
void test_print(const struct test_union *t);
int test_get_value(const struct test_union *t);
void test_print(const struct test_union *t);

#endif /* _FFI_H */
