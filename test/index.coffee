assert = require "assert"

mod = require "../src/index.coffee"

describe "index section", ()->
  it "mixin constructor", ()->
    class A
      event_mixin @
      constructor:()->
        event_mixin_constructor @
    new A
    return
  
  it "mixin class global", ()->
    new Event_mixin
    return
  
  it "mixin class exports", ()->
    new mod.Event_mixin
    return
  
  describe "on", ()->
    it "on dispatch", ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      found_event = null
      a.on "ev1", (event)->
        found_event = event
        counter++
      a.dispatch "ev1", "hello"
      assert.strictEqual found_event, "hello"
      assert.strictEqual counter, 1
      a.dispatch "ev2"
      assert.strictEqual counter, 1
      return
    
    it "on multi dispatch", ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      fn = ()->counter++
      a.on "ev1", fn
      a.on "ev1", fn
      a.dispatch "ev1"
      assert.strictEqual counter, 2
      return
    
    it "repeat on dispatch", ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      a.on "ev1", ()->counter++
      a.dispatch "ev1"
      a.dispatch "ev1"
      assert.strictEqual counter, 2
      return
    
    it "on array", ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      a.on ["ev1", "ev2"], ()->counter++
      a.dispatch "ev1"
      assert.strictEqual counter, 1
      a.dispatch "ev1"
      assert.strictEqual counter, 2
      a.dispatch "ev2"
      assert.strictEqual counter, 3
      a.dispatch "ev3"
      assert.strictEqual counter, 3
      return
    
    it "on throw", ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      a.on "ev1", ()->throw new Error "WTF"
      a.dispatch "ev1"
      return
  
  describe "ensure_on", ()->
    it "ensure_on multi dispatch", ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      fn = ()->counter++
      a.ensure_on "ev1", fn
      a.ensure_on "ev1", fn
      a.dispatch "ev1"
      assert.strictEqual counter, 1
      return
    
    it "ensure_on array", ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      fn = ()->counter++
      a.ensure_on ["ev1","ev2"], fn
      a.dispatch "ev1"
      a.dispatch "ev2"
      assert.strictEqual counter, 2
      return
    
    it "ensure_on array2", ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      fn = ()->counter++
      a.ensure_on ["ev1","ev2"], fn
      a.ensure_on ["ev1","ev2"], fn
      a.dispatch "ev1"
      a.dispatch "ev2"
      assert.strictEqual counter, 2
      return
  
  describe "off", ()->
    it "off dispatch", ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      a.on "ev1", fn = ()->counter++
      a.off "ev1", fn
      a.dispatch "ev1"
      assert.strictEqual counter, 0
      a.off "ev1", fn
      return
    
    it "off array", ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      a.on "ev1", fn = ()->counter++
      a.off ["ev1"], fn
      a.dispatch "ev1"
      assert.strictEqual counter, 0
      return
    
    it "off not exist event warn", ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      a.off "ev1", ()->
      return
    
    it "repeat on off mem leak", ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      for i in [0 ... 100]
        a.on "ev1", fn = ()->counter++
        a.off "ev1", fn
      a.dispatch "ev1"
      assert.strictEqual counter, 0
      assert.strictEqual a.$event_hash["ev1"].length, 0
      return
    
    it "repeat on off mem leak2", ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      fn_list = []
      for i in [0 ... 100]
        a.on "ev1", fn = ()->
          counter++
          for fn2 in fn_list
            a.off "ev1", fn2
          
        fn_list.push fn
      
      a.dispatch "ev1"
      assert.strictEqual counter, 1
      assert.strictEqual a.$event_hash["ev1"].length, 0
      return
      return
    
    it "repeat on off mem leak3", ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      fn_list = []
      for i in [0 ... 100]
        a.on "ev1", fn = ()->
          counter++
          for fn2 in fn_list
            a.off "ev1", fn2
          
        fn_list.push fn
      
      fn_list.pop()
      a.dispatch "ev1"
      # сработает первый и последний
      assert.strictEqual counter, 2
      # останется только последний
      assert.strictEqual a.$event_hash["ev1"].length, 1
      return
  
  describe "once", ()->
    it "once dispatch", ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      found_event = null
      a.once "ev1", (event)->
        found_event = event
        counter++
      a.dispatch "ev1", "hello"
      a.dispatch "ev1", "hello"
      
      assert.strictEqual counter, 1
      assert.strictEqual found_event, "hello"
      return
    
    it "once off + dispatch", ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      found_event = null
      a.once "ev1", handler = (event)->
        found_event = event
        counter++
      a.off "ev1", handler
      a.dispatch "ev1", "hello"
      
      assert.strictEqual counter, 0
      return
  
  describe "delete", ()->
    it "delete", ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      a.on "ev1", ()->throw new Error "WTF"
      a.delete()
      a.dispatch "ev1"
      return
    
    it "delete handler", ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      a.on "delete", ()->counter++
      a.delete()
      assert.strictEqual counter, 1
      return
    
    it "delete protection", ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      fn2 = null
      a.on "ev1", ()->@off "ev1", fn2
      a.on "ev1", fn2=()->counter++
      a.dispatch "ev1"
      
      assert.strictEqual counter, 0
      return
  