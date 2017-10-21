assert = require 'assert'

mod = require '../src/index.coffee'

describe 'index section', ()->
  it 'mixin constructor', ()->
    class A
      event_mixin @
      constructor:()->
        event_mixin_constructor @
    new A
    return
  
  it 'mixin class global', ()->
    new Event_mixin
    return
  
  it 'mixin class exports', ()->
    new mod.Event_mixin
    return
  
  describe 'on', ()->
    it 'on dispatch', ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      a.on 'ev1', ()->counter++
      a.dispatch 'ev1'
      assert.equal counter, 1
      a.dispatch 'ev2'
      assert.equal counter, 1
      return
    
    it 'on multi dispatch', ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      fn = ()->counter++
      a.on 'ev1', fn
      a.on 'ev1', fn
      a.dispatch 'ev1'
      assert.equal counter, 2
      return
    
    it 'repeat on dispatch', ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      a.on 'ev1', ()->counter++
      a.dispatch 'ev1'
      a.dispatch 'ev1'
      assert.equal counter, 2
      return
    
    it 'on array', ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      a.on ['ev1', 'ev2'], ()->counter++
      a.dispatch 'ev1'
      assert.equal counter, 1
      a.dispatch 'ev1'
      assert.equal counter, 2
      a.dispatch 'ev2'
      assert.equal counter, 3
      a.dispatch 'ev3'
      assert.equal counter, 3
      return
    
    it 'on throw', ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      a.on 'ev1', ()->throw new Error "WTF"
      a.dispatch 'ev1'
      return
  
  describe 'ensure_on', ()->
    it 'ensure_on multi dispatch', ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      fn = ()->counter++
      a.ensure_on 'ev1', fn
      a.ensure_on 'ev1', fn
      a.dispatch 'ev1'
      assert.equal counter, 1
      return
    
    it 'ensure_on array', ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      fn = ()->counter++
      a.ensure_on ['ev1','ev2'], fn
      a.dispatch 'ev1'
      a.dispatch 'ev2'
      assert.equal counter, 2
      return
    
    it 'ensure_on array2', ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      fn = ()->counter++
      a.ensure_on ['ev1','ev2'], fn
      a.ensure_on ['ev1','ev2'], fn
      a.dispatch 'ev1'
      a.dispatch 'ev2'
      assert.equal counter, 2
      return
  
  describe 'off', ()->
    it 'off dispatch', ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      a.on 'ev1', fn = ()->counter++
      a.off 'ev1', fn
      a.dispatch 'ev1'
      assert.equal counter, 0
      a.off 'ev1', fn
      return
    
    it 'off array', ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      a.on 'ev1', fn = ()->counter++
      a.off ['ev1'], fn
      a.dispatch 'ev1'
      assert.equal counter, 0
      return
    
    it 'off not exist event warn', ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      a.off 'ev1', ()->
      return
  
  describe 'once', ()->
    it 'once dispatch', ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      a.once 'ev1', ()->counter++
      a.dispatch 'ev1'
      a.dispatch 'ev1'
      
      assert.equal counter, 1
      return
  
  describe 'delete', ()->
    it 'delete', ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      a.on 'ev1', ()->throw new Error "WTF"
      a.delete()
      a.dispatch 'ev1'
      return
    
    it 'delete handler', ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      a.on 'delete', ()->counter++
      a.delete()
      assert.equal counter, 1
      return
    
    it 'delete protection', ()->
      class A
        event_mixin @
        constructor:()->
          event_mixin_constructor @
      a = new A
      counter = 0
      fn2 = null
      a.on 'ev1', ()->@off 'ev1', fn2
      a.on 'ev1', fn2=()->counter++
      a.dispatch 'ev1'
      
      assert.equal counter, 0
      return
  