#if defined(WIN32) || defined(_WIN32)
# define _export __declspec(dllexport)
#elif defined(__linux__) || defined(__APPLE__)
# define _export __attribute__((visibility("default")))
#endif
