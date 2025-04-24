#define SQLITE_CORE 1

#include "extinit.h"
#include "sqlite3.h"
#include "sqlite-vec.h"

int core_vec_init(void) {
  return sqlite3_auto_extension((void *)sqlite3_vec_init);
}

