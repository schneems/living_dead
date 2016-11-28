# LivingDead

This module allows to see if an object is retained "still alive" or if it is freed "dead".

DOES NOT WORK (yet)

## Questions for Koichi

**Goal:** I am trying to write a tool that will allow you see if a specific object is in retained in memory.

**Method:** I record the memory address of the object after it has been created, then using the C api and `RUBY_INTERNAL_EVENT_FREEOBJ`, when the `free_i` hook is called I can check to see if the object being freed is the one we have recorded.

Please let me know if you have a better method to accomplish my goal.

> I used `allocation_tracer` as a blueprint for the C code, so much of it should be familiar to you. I appologize though for my C code, I am not extremely familiar with C or with the ruby c-api.

**Problem:** It doesn't work. All the pointers I get back from `free_i` are the same

**Reproduction:**

You can clone this repository locally and run it:

```
$ git clone https://github.com/schneems/living_dead.git
$ cd living_dead
$ rake compile
```

I wrote a test script. It prints out the memory address of an object, and then we print off the pointer to every object that gets passed into `free_i`.

```
$ rake compile && ruby scratch.rb
# ...
OBJECT ADDRESS TO BE FREED: 0x7ff7af880190
Freed: 0x7fff52d16af8
Freed: 0x7fff52d16af8
Freed: 0x7fff52d16af8
Freed: 0x7fff52d16af8
# ...
```

Here we see that the object we expect to be freed is at `0x7ff7af880190` however when we try to print out the pointer of each object being freed, they are all the same. Here is the code I am using to print out the pointer:

```c
static void
freeobj_i(VALUE tpval, void *data)
{
    // struct traceobj_arg *arg = (struct traceobj_arg *)data;

    rb_trace_arg_t *tparg = rb_tracearg_from_tracepoint(tpval);
    VALUE obj = rb_tracearg_object(tparg);

    void *ptr = DATA_PTR(obj);

    printf("Freed: %p\n", (void*)&ptr); // <=== Print out here
    // ...
```

**Questions:**

1) Is there a better way to "trace" a specific object than by memory address?
2) If memory address is the correct way to achieve my goal, do you know what is wrong with this program?

Can you please share your thoughts?

## Installation

Add this line to your application's Gemfile:

    gem 'living_dead'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install living_dead

## Usage

