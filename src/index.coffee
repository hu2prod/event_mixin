require "fy"
window = global
window.event_mixin_constructor = (_t)->
  _t.$event_hash = {}
  _t.$event_once_hash = {}
  _t.$event_dispatch_hash = {}
  _t.on "delete", ()->
    for k,v of _t.$event_hash
      continue if k == "delete" # т.к. нормально не сотрет
      _t.$event_hash[k].clear()
    return
  return

window.event_mixin = (_t)->
  _t.prototype.$delete_state = false
  _t.prototype.$event_hash = {}
  _t.prototype.$event_once_hash = {}
  _t.prototype.$event_dispatch_hash = {}
  _t.prototype.delete ?= ()->
    @dispatch "delete"
    return
  _t.prototype.once = (event_name, cb)->
    if event_name instanceof Array
      for v in event_name
        @once v, cb
      return @
    @on event_name, cb
    @$event_once_hash[event_name] ?= []
    @$event_once_hash[event_name].push cb
    @
  
  _t.prototype.ensure_on = (event_name, cb)->
    if event_name instanceof Array
      for v in event_name
        @ensure_on v, cb
      return @
    @$event_hash[event_name] ?= []
    if !@$event_hash[event_name].has cb
      @$event_hash[event_name].push cb
    @
  _t.prototype.on = (event_name, cb)->
    if event_name instanceof Array
      for v in event_name
        @on v, cb
      return @
    @$event_hash[event_name] ?= []
    @$event_hash[event_name].push cb
    @
  
  _t.prototype.off = (event_name, cb)->
    @$delete_state = true
    if event_name instanceof Array
      for v in event_name
        @off v, cb
      return
    list = @$event_hash[event_name]
    if !list
      puts "probably lose some important because no event_name '#{event_name}' found"
      e = new Error
      puts e.stack
      return
    
    if @$event_dispatch_hash[event_name]
      # нельзя удалять т.к. можем поломать кому-то итерацию по циклу
      idx = list.idx cb
      if idx >= 0
        list[idx] = null
    else
      list.remove_idx cb
    # а тут можно
    @$event_once_hash[event_name]?.fast_remove cb
    return
  
  _t.prototype.dispatch = (event_name, hash={})->
    return if !list = @$event_hash[event_name]
    
    @$event_dispatch_hash[event_name] = true
    need_clear_null = false
    for cb in list
      if cb == null
        need_clear_null = true
        continue
      try
        cb.call @, hash
      catch e
        perr e
    
    @$event_dispatch_hash[event_name] = false
    
    if @$delete_state
      while 0 < idx = list.idx null
        list.remove_idx idx
      @$delete_state = false
    if @$event_once_hash[event_name]
      for remove_cb in @$event_once_hash[event_name]
        list.fast_remove remove_cb
      @$event_once_hash[event_name].clear()
    
    if need_clear_null
      # mass remove optimized
      idx = 0
      len = list.length
      while idx < len
        curr = list[idx]
        if curr?
          idx++
          continue
        
        list.remove_idx idx
        len--
    
    return

    
class window.Event_mixin
  event_mixin @

  constructor : ()->
    event_mixin_constructor @

@Event_mixin = window.Event_mixin