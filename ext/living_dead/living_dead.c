

#include "ruby/ruby.h"
#include "ruby/debug.h"
#include <assert.h>

size_t rb_obj_memsize_of(VALUE obj); /* in gc.c */

/*
 *
 *  call-seq:
 *     LivingDead.trace(object)  -> nil
 *
 * Traces a specific object to see if it is retained or freed
 *
 */
static VALUE
living_dead_trace(VALUE self, VALUE obj)
{
    rb_p(obj);

    return Qnil;
}


void
Init_living_dead(void)
{
    VALUE mod = rb_const_get(rb_cObject, rb_intern("LivingDead"));

    rb_define_module_function(mod, "trace", living_dead_trace, 1);

}
