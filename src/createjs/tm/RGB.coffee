class createjs.tm.RGB

  SMALL_NUMBER = Math.pow 10, -6


  ###
  ```CoffeeScript
  new RGB '#f00'
  new RGB '#f00', 0.5
  new RGB '#ff0000'
  new RGB '#ff0000', 0.5
  new RGB 'rgb(255,0,0)'
  new RGB 'rgb(255,0,0)', 0.5
  new RGB 'rgba(255,0,0,0.5)'
  new RGB 0xff0000
  new RGB 0xff0000, 0.5
  new RGB 255, 0, 0
  new RGB 255, 0, 0, 0.5
  ```
  ###
  constructor: (r, g, b, a) ->
    if isNaN +r
      if $ = r.match /#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})/
        @r = parseInt $[1], 16
        @g = parseInt $[2], 16
        @b = parseInt $[3], 16
        @a = g ? 1
      else if $ = r.match /#([0-9a-f])([0-9a-f])([0-9a-f])/
        @r = parseInt "#{$[1]}#{$[1]}", 16
        @g = parseInt "#{$[2]}#{$[2]}", 16
        @b = parseInt "#{$[3]}#{$[3]}", 16
        @a = g ? 1
      else if $ = r.match /rgba\(\s*(\S+?)\s*,\s*(\S+?)\s*,\s*(\S+?)\s*,\s*(\S+?)\s*\)/
        @r = +$[1]
        @g = +$[2]
        @b = +$[3]
        @a = +$[4]
      else if $ = r.match /rgb\(\s*(\S+?)\s*,\s*(\S+?)\s*,\s*(\S+?)\s*\)/
        @r = +$[1]
        @g = +$[2]
        @b = +$[3]
        @a = 1
      else
        throw new TypeError 'Invalid color string'
    else
      if r? and g? and b?
        @r = r
        @g = g
        @b = b
        @a = a ? 1
      else if r?
        @r = r >> 16 & 0xff
        @g = r >> 8 & 0xff
        @b = r & 0xff
        @a = g ? 1
      else
        throw new TypeError 'Invalid color number'
    @normalize()

  clone: ->
    new RGB @r, @g, @b, @a

  normalize: ->
    @r &= 0xff
    @g &= 0xff
    @b &= 0xff
    @a = if @a > 1 then 1 else if @a < SMALL_NUMBER then 0 else @a
    @

  toHex: ->
    @r << 16 | @g << 8 | @b

  toString: ->
    "[RGB] #{@r}, #{@g}, #{@b}, #{@a}"

  toCSSString: ->
    @normalize()
    "rgba(#{@r}, #{@g}, #{@b}, #{@a})"