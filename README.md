# LivingDead

[![Build Status](https://travis-ci.org/schneems/living_dead.svg?branch=master)](https://travis-ci.org/schneems/living_dead)

This module allows to see if an object is retained "still alive" or if it is freed "dead".

![Dancing Zombies](https://www.dropbox.com/s/lshgqzek77107mh/zombies.gif?dl=1)

## Problems

There be dragons see `LivingDead.gc_start` to see some of the hacks we have to do for who knows why to get this to work.

## Install

In your Gemfile add:

```
gem 'living_dead'
```

Then run

```
$ bundle install
```

## How it works

Before you use this you should understand how it works. This gem is a c-extension. It hooks into the Ruby tracepoint API and registeres a hook for the `RUBY_INTERNAL_EVENT_FREEOBJ` event. This
event gets called when an object is freed (i.e. it is not retained and garbage collection has been called).

When you call `LivingDead.trace(obj)` we store the `object_id` of the thing you are "tracing" in a hash. Then inside of our c-extension hook we listen for when an object is freed. When this happens we check to see if that object's `object_id` matches one in our hash. If it does we mark it down in a seperate "freed" hash.

We don't retain the objects you are tracing but we do keep a copy of the `object_id`, we can then use this same number to check the freed hash to see if it was recorded as being freed.

> WARNING: Seriously, see `LivingDead.gc_start`. This library isn't bullet proof.

## Quick Start

Require the library and use `LivingDead.trace` to "trace" an object. Later use `LivingDead.traced_objects` to iterate through "tracers" of each object.

Here is an example of tracing an object that is not retained:

```
require 'living_dead'

def run
  obj = Object.new
  LivingDead.trace(obj)

  return nil
end

run

puts LivingDead.traced_objects.select {|tracer| tracer.retained? }.count
# => 0
```

> Note: Calling `LivingDead.traced_objects` auto calls `GC.start`, you don't need to do it manually. However you should look at the implementation of `LivingDead.gc_start` to understand the depth of hacks you're playing with.

Here is an example of tracing an object that IS retained:

```
require 'living_dead'

def run
  obj = Object.new
  LivingDead.trace(obj)

  return obj
end

@retained_here = run

puts LivingDead.traced_objects.select {|tracer| tracer.retained? }.count
# => 1
```

You can get more ways of interacting with a tracer by looking at `LivingDead::ObjectTrace`.

## Development

Compile the code:

```
$ rake compile
```

Run the tests:

```
$ rake spec
```

or "why not both":

```
$ rake compile spec
```

## License

MIT

Copyright Richard Schneeman 2016


