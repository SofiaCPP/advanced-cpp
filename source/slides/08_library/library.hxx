#pragma once

#if defined(_WIN32)
  #define LIBRARY_EXPORT __declspec(dllexport)
  #define LIBRARY_IMPORT __declspec(dllimport)
#else
  #define LIBRARY_EXPORT __attribute__ ((visibility ("default")))
  #define LIBRARY_IMPORT
#endif

#if defined(LIBRARY_IMPL)
  #define LIBRARY_API LIBRARY_EXPORT
#else
  #define LIBRARY_API LIBRARY_IMPORT
#endif

LIBRARY_API void library();

