#ifndef STDARG_H
#define STDARG_H

typedef char *va_list;
#define _INTSIZEOF(n) ((sizeof(n) + sizeof(int) - 1) & ~(sizeof(int) - 1))
#define va_start(ap, v) (ap = (va_list)&v + _INTSIZEOF(v))
#define va_arg(ap, type) (*(type *)((ap += _INTSIZEOF(type)) - _INTSIZEOF(type)))
#define va_end(ap) (ap = (va_list)0)
#define va_after_add(a)  ((a)++)  //实现a++的逻辑，a=a+1,之后得到即原来的a
#define va_before_add(a) (++(a))//实现++a逻辑，a=a+1,得到加后的a

#endif
