#include <caml/mlvalues.h>
#include <caml/callback.h>

#include "caml_runtime_allocator.h"

int main(int argc, char **argv)
{
  caml_runtime_init();
  caml_startup(argv);
  caml_shutdown();
  caml_runtime_uninit();
  return 0;
}
