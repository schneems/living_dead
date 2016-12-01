#include "ruby/ruby.h"
#include "ruby/debug.h"
#include <assert.h>

size_t rb_obj_memsize_of(VALUE obj); /* in gc.c */

static VALUE rb_mLivingDead;

#define MAX_KEY_DATA 4

#define KEY_PATH    (1<<1)
#define KEY_LINE    (1<<2)
#define KEY_TYPE    (1<<3)
#define KEY_CLASS   (1<<4)

#define MAX_VAL_DATA 6

#define VAL_COUNT     (1<<1)
#define VAL_OLDCOUNT  (1<<2)
#define VAL_TOTAL_AGE (1<<3)
#define VAL_MIN_AGE   (1<<4)
#define VAL_MAX_AGE   (1<<5)
#define VAL_MEMSIZE   (1<<6)

struct traceobj_arg {
    int running;
    int keys, vals;
    st_table *object_table;     /* obj (VALUE)      -> allocation_info */
    st_table *str_table;        /* cstr             -> refcount */

    st_table *aggregate_table;  /* user defined key -> [count, total_age, max_age, min_age] */
    struct allocation_info *freed_allocation_info;

    /* */
    size_t **lifetime_table;
    size_t allocated_count_table[T_MASK];
    size_t freed_count_table[T_MASK];
};

struct memcmp_key_data {
    int n;
    st_data_t data[MAX_KEY_DATA];
};

static int
memcmp_hash_compare(st_data_t a, st_data_t b)
{
    struct memcmp_key_data *k1 = (struct memcmp_key_data *)a;
    struct memcmp_key_data *k2 = (struct memcmp_key_data *)b;
    return memcmp(&k1->data[0], &k2->data[0], k1->n * sizeof(st_data_t));
}

static st_index_t
memcmp_hash_hash(st_data_t a)
{
    struct memcmp_key_data *k = (struct memcmp_key_data *)a;
    return rb_memhash(k->data, sizeof(st_data_t) * k->n);
}

static const struct st_hash_type memcmp_hash_type = {
    memcmp_hash_compare, memcmp_hash_hash
};

static struct traceobj_arg *tmp_trace_arg;

/*
 * I honestly coppied this from https://github.com/ko1/allocation_tracer
 * We don't need all this per-say. However it's not hurting anything by being here
 * at the moment. Same goes for the majority of code above this point.
 */
static struct traceobj_arg *
get_traceobj_arg(void)
{
    if (tmp_trace_arg == 0) {
        tmp_trace_arg = ALLOC_N(struct traceobj_arg, 1);
        MEMZERO(tmp_trace_arg, struct traceobj_arg, 1);
        tmp_trace_arg->running = 0;
        tmp_trace_arg->keys = 0;
        tmp_trace_arg->vals = VAL_COUNT | VAL_OLDCOUNT | VAL_TOTAL_AGE | VAL_MAX_AGE | VAL_MIN_AGE | VAL_MEMSIZE;
        tmp_trace_arg->aggregate_table = st_init_table(&memcmp_hash_type);
        tmp_trace_arg->object_table = st_init_numtable();
        tmp_trace_arg->str_table = st_init_strtable();
        tmp_trace_arg->freed_allocation_info = NULL;
        tmp_trace_arg->lifetime_table = NULL;
    }
    return tmp_trace_arg;
}

/*
 *
 * [Internal] Callback for the RUBY_INTERNAL_EVENT_FREEOBJ event
 *
 * When an object is freed we check if we are tracing it.
 * If we are, then we register in the `freed_hash` that it has
 * been freed by setting the `object_id` key to a value of `true`
 *
 */
static void
freeobj_i(VALUE tpval, void *data)
{
    // struct traceobj_arg *arg = (struct traceobj_arg *)data;
    VALUE freed_object_id_hash   = rb_ivar_get(rb_mLivingDead, rb_intern("freed_object_id_hash"));
    VALUE object_id_tracing_hash = rb_ivar_get(rb_mLivingDead, rb_intern("object_id_tracing_hash"));

    rb_trace_arg_t *tparg = rb_tracearg_from_tracepoint(tpval);
    VALUE obj = rb_tracearg_object(tparg);
    VALUE object_id = rb_obj_id(obj);


    // Useful for debugging, we cannot use `rb_p` here since it allocates new memory
    // Using `rb_p` here will cause a SEGV.
    //
    // long oid = NUM2LONG(rb_obj_id(obj));
    // printf("Freed: %lu\n", oid);

    if (rb_hash_aref(object_id_tracing_hash, object_id) != Qnil ) {
        rb_hash_aset(freed_object_id_hash, rb_obj_id(obj), Qtrue);
    }
}

// Used for debugging only
//
// static void
// newobj_i(VALUE tpval, void *data)
// {
//     // struct traceobj_arg *arg = (struct traceobj_arg *)data;

//     rb_trace_arg_t *tparg = rb_tracearg_from_tracepoint(tpval);
//     VALUE obj = rb_tracearg_object(tparg);
//     long oid = NUM2LONG(rb_obj_id(obj));
//     printf("NEW: %lu\n", oid);
// }


/*
 *
 *  call-seq:
 *     LivingDead.start -> nil
 *
 * Begins tracing object free events
 *
 */
static VALUE
living_dead_start(VALUE self)
{
    VALUE freeobj_hook;
    // VALUE newobj_hook;
    struct traceobj_arg *arg = get_traceobj_arg();

    if ((freeobj_hook = rb_ivar_get(rb_mLivingDead, rb_intern("freeobj_hook"))) == Qnil) {
        rb_ivar_set(rb_mLivingDead, rb_intern("freeobj_hook"), freeobj_hook = rb_tracepoint_new(0, RUBY_INTERNAL_EVENT_FREEOBJ, freeobj_i, arg));
        rb_ivar_set(rb_mLivingDead, rb_intern("object_id_tracing_hash"), rb_hash_new());
        rb_ivar_set(rb_mLivingDead, rb_intern("freed_object_id_hash"), rb_hash_new());

        // new hook for debugging only
        // rb_ivar_set(rb_mLivingDead, rb_intern("newobj_hook"), newobj_hook = rb_tracepoint_new(0, RUBY_INTERNAL_EVENT_NEWOBJ, newobj_i, arg));

        // rb_tracepoint_enable(newobj_hook);
        rb_tracepoint_enable(freeobj_hook);
    }

    return Qnil;
}


/*
 *
 *  call-seq:
 *     LivingDead.freed_hash  -> {}
 *
 * Returns a hash of freed object ids
 *
 * The keys are the object ID, values are `true` if they have been freed
 * otherwise `false`. Note you must invoke GC before calling this method
 * see LivingDead.gc_start
 *
 */
static VALUE
living_dead_freed_hash(VALUE self)
{
    VALUE freed_object_id_hash = rb_ivar_get(rb_mLivingDead, rb_intern("freed_object_id_hash"));

    return freed_object_id_hash;
}

/*
 *
 *  call-seq:
 *     LivingDead.tracing_hash  -> {}
 *
 * Returns a hash of traced object ids
 *
 * The keys are the object ID of the object being traced, values are all truthy.
 * In `LivingDead.trace` we set the value to be an instance of `LivingDead::ObjectTrace`.
 *
 */
static VALUE
living_dead_tracing_hash(VALUE self)
{
    VALUE freed_object_id_hash = rb_ivar_get(rb_mLivingDead, rb_intern("object_id_tracing_hash"));

    return freed_object_id_hash;
}


void
Init_living_dead(void)
{
    VALUE mod = rb_mLivingDead = rb_const_get(rb_cObject, rb_intern("LivingDead"));

    // LivingDead.trace is a ruby level method
    // rb_define_module_function(mod, "trace",      living_dead_trace, 1);
    rb_define_module_function(mod, "start",      living_dead_start, 0);
    rb_define_module_function(mod, "freed_hash", living_dead_freed_hash, 0);
    rb_define_module_function(mod, "tracing_hash", living_dead_tracing_hash, 0);

}
