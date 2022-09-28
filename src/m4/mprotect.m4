dnl -*- Autoconf -*-
dnl Copyright (C) 1993-2009, 2017, 2021 Free Software Foundation, Inc.
dnl This file is free software, distributed under the terms of the GNU
dnl General Public License.  As a special exception to the GNU General
dnl Public License, this file may be distributed as part of a program
dnl that contains a configuration script generated by Autoconf, under
dnl the same distribution terms as the rest of that program.

dnl From Bruno Haible, Marcus Daniels, Sam Steingold.

AC_PREREQ([2.57])

AC_DEFUN([CL_MPROTECT],
[
  AC_REQUIRE([gl_FUNC_GETPAGESIZE])
  AC_REQUIRE([CL_MMAP])
  AC_CHECK_FUNCS([mprotect])
  if test $ac_cv_func_mprotect = yes; then
    AC_CACHE_CHECK([for working mprotect], [cl_cv_func_mprotect_works],
      [mprotect_prog='
            #include <sys/types.h>
            /* declare malloc() */
            #include <stdlib.h>
            #ifdef HAVE_UNISTD_H
             #include <unistd.h>
            #endif
            /* declare getpagesize() and mprotect() */
            #include <sys/mman.h>
            #ifndef HAVE_GETPAGESIZE
             #include <sys/param.h>
             #define getpagesize() PAGESIZE
            #else
           ]AC_LANG_EXTERN[
            int getpagesize (void);
            #endif
            char foo;
            int main ()
            {
              unsigned long pagesize = getpagesize();
              #define page_align(address)  (char*)((unsigned long)(address) & -pagesize)
            '
       AC_RUN_IFELSE(
         [AC_LANG_SOURCE([[$mprotect_prog
              if ((pagesize-1) & pagesize) exit(1);
              exit(0);
            }
         ]])],
         [],
         [no_mprotect=1],
         [# When cross-compiling, don't assume anything.
          no_mprotect=1
         ])
       mprotect_prog="$mprotect_prog"'
           char* area = (char*) malloc(6*pagesize);
           char* fault_address = area + pagesize*7/2;
         '
       if test -z "$no_mprotect"; then
         AC_RUN_IFELSE(
           [AC_LANG_SOURCE([GL_NOCRASH[$mprotect_prog
                nocrash_init();
                if (mprotect(page_align(fault_address),pagesize,PROT_NONE) < 0) exit(0);
                foo = *fault_address; /* this should cause an exception or signal */
                exit(0);
              }
           ]])],
           [no_mprotect=1],
           [],
           [: # When cross-compiling, don't assume anything.])
       fi
       if test -z "$no_mprotect"; then
         AC_RUN_IFELSE(
           [AC_LANG_SOURCE([GL_NOCRASH[$mprotect_prog
                nocrash_init();
                if (mprotect(page_align(fault_address),pagesize,PROT_NONE) < 0) exit(0);
                *fault_address = 'z'; /* this should cause an exception or signal */
                exit(0);
              }
           ]])],
           [no_mprotect=1],
           [],
           [: # When cross-compiling, don't assume anything.])
       fi
       if test -z "$no_mprotect"; then
         AC_RUN_IFELSE(
           [AC_LANG_SOURCE([GL_NOCRASH[$mprotect_prog
                nocrash_init();
                if (mprotect(page_align(fault_address),pagesize,PROT_READ) < 0) exit(0);
                *fault_address = 'z'; /* this should cause an exception or signal */
                exit(0);
           }
           ]])],
           [no_mprotect=1],
           [],
           [: # When cross-compiling, don't assume anything.])
       fi
       if test -z "$no_mprotect"; then
         AC_RUN_IFELSE(
           [AC_LANG_SOURCE([GL_NOCRASH[$mprotect_prog
                nocrash_init();
                if (mprotect(page_align(fault_address),pagesize,PROT_READ) < 0) exit(1);
                if (mprotect(page_align(fault_address),pagesize,PROT_READ|PROT_WRITE) < 0) exit(1);
                *fault_address = 'z'; /* this should not cause an exception or signal */
                exit(0);
              }
           ]])],
           [],
           [no_mprotect=1],
           [: # When cross-compiling, don't assume anything.])
       fi
       if test -z "$no_mprotect"; then
         cl_cv_func_mprotect_works=yes
       else
         cl_cv_func_mprotect_works=no
       fi
      ])
    if test $cl_cv_func_mprotect_works = yes; then
      AC_DEFINE([HAVE_WORKING_MPROTECT],,[have a working mprotect() function])
    fi
  fi
])
