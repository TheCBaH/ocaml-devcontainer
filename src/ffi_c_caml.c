
#include <assert.h>
#include "ffi_c.h"
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/fail.h>

CAMLprim value caml_test_init(value version)
{
    int rc;
    value caml_rc;
    int c_version;
    CAMLparam1 (version);

    c_version = Int_val(version);
    rc = test_init(c_version);
    caml_rc = Val_int(rc);
    CAMLreturnT(int, caml_rc);
}

CAMLprim value caml_test_uninit(value unit)
{
    CAMLparam1(unit);

    test_uninit();
    CAMLreturn (Val_unit);
}

CAMLprim value caml_test_log(value message)
{
    const char* c_message;
    CAMLparam1(message);

    c_message = String_val(message);
    test_log(c_message);
    CAMLreturn (Val_unit);
}

#define Test_val(v) (*((struct test_union **)Data_custom_val(v)))

static void caml_test_finalize(value test)
{
    struct test_union *c_test = Test_val(test);
    test_destroy(c_test);
    return;
}

static struct custom_operations test_ops = {
  "foo.bar.test",
  caml_test_finalize,
  custom_compare_default,
  custom_hash_default,
  custom_serialize_default,
  custom_deserialize_default,
  custom_compare_ext_default,
  custom_fixed_length_default
};

CAMLprim value caml_create_foo(value a)
{
    int c_a;
    value test;
    struct test_union *c_test;
    CAMLparam1(a);

    c_a = Int_val(a);
    c_test = create_foo(c_a);
    assert(c_test);
    test = caml_alloc_custom(&test_ops, sizeof(struct union_test *), 0, 1);
    Test_val(test) = c_test;
    CAMLreturn (test);
}

CAMLprim value caml_test_get_value(value test)
{
    struct test_union *c_test;
    int c_a;
    value caml_a;
    CAMLparam1(test);

    c_test = Test_val(test);
    c_a = test_get_value(c_test);
    caml_a = Val_int(c_a);
    CAMLreturnT(int, caml_a);
}

CAMLprim value caml_test_print(value test)
{
    struct test_union *c_test;
    CAMLparam1(test);

    c_test = Test_val(test);
    test_print(c_test);
    CAMLreturn (Val_unit);
}

#define TestFoo_val(v) (*((struct test_foo **)Data_custom_val(v)))

static void caml_test_foo_finalize(value foo)
{
    struct test_foo *c_foo = TestFoo_val(foo);
    if (c_foo) {
        destroy_foo(c_foo);
    }
    return;
}

static struct custom_operations test_foo_ops = {
  "foo.bar.test_foo",
  caml_test_foo_finalize,
  custom_compare_default,
  custom_hash_default,
  custom_serialize_default,
  custom_deserialize_default,
  custom_compare_ext_default,
  custom_fixed_length_default
};

CAMLprim value caml_make_foo(value a)
{
    int c_a;
    value foo;
    struct test_foo *c_foo;
    CAMLparam1(a);

    c_a = Int_val(a);
    c_foo = make_foo(c_a);
    assert(c_foo);
    foo = caml_alloc_custom(&test_foo_ops, sizeof(struct test_foo *), 0, 1);
    TestFoo_val(foo) = c_foo;
    CAMLreturn(foo);
}

CAMLprim value caml_create_bar(value foo)
{
    struct test_foo *c_foo;
    value test;
    struct test_union *c_test;
    CAMLparam1(foo);

    c_foo = TestFoo_val(foo);
    if (c_foo == NULL) {
        caml_raise_not_found();
    }
    TestFoo_val(foo) = NULL;
    c_test = create_bar(c_foo);
    assert(c_test);
    test = caml_alloc_custom(&test_ops, sizeof(struct union_test *), 0, 1);
    Test_val(test) = c_test;
    CAMLreturn (test);
}

#define TestFoo_tag 1
#define TestFoo_fields 1
#define TestFoo_field_0 0
#define TestBar_tag 0
#define TestBar_fields 1
#define TestBar_field_0 0

#define alloc_TestBar() caml_alloc(TestBar_fields, TestBar_tag)
#define alloc_TestFoo() caml_alloc(TestFoo_fields, TestFoo_tag)

#define Bar_fields 1
#define Bar_field_a 0
#define alloc_Bar() caml_alloc(Bar_fields, 0)

CAMLprim value caml_test_to_caml(value test)
{
    struct test_union *c_test;
    CAMLparam1(test);
    CAMLlocal3(result, caml_a, caml_bar);

    c_test = Test_val(test);
    switch (c_test->type) {
    case foo:
        caml_a = Val_int(c_test->data.foo.a);
        result = alloc_TestFoo();
        Store_field(result, TestFoo_field_0, caml_a);
        break;
    case bar:
        assert(c_test->data.bar.foo);
        caml_a = Val_int(c_test->data.bar.foo->a);
        caml_bar = alloc_Bar();
        Store_field(caml_bar, Bar_field_a, caml_a);
        result = alloc_TestBar();
        Store_field(result, TestBar_field_0, caml_bar);
        break;
    }
    CAMLreturn (result);
}
#if 0
external to_caml : test -> Test.t = "caml_test_to_caml"
#endif