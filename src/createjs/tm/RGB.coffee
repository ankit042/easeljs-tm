class createjs.tm.RGB

  SMALL_NUMBER = Math.pow 10, -6


  @interpolate: (a, b, t) ->
    unless a instanceof RGB
      a = new RGB a
    unless b instanceof RGB
      b = new RGB b

    rgb = new RGB
    for key in ['r', 'g', 'b', 'a']
      rgb[key] = a[key] + (b[key] - a[key]) * t
    rgb.normalize()


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
    unless @ instanceof RGB
      rgb = new RGB
      RGB.apply rgb, arguments
      return rgb

    if r instanceof RGB
      @apply r
      return

    if r instanceof createjs.tm.HSV
      { h, s, v, a } = r.clone().normalize()
      h /= 60
      hi = h >> 0
      f = h - hi
      p = v * (1 - s)
      q = v * (1 - f * s)
      t = v * (1 - (1 - f) * s)
      p = p * 0xff >> 0
      q = q * 0xff >> 0
      t = t * 0xff >> 0
      v = v * 0xff >> 0
      switch hi
        when 0 then @apply v, t, p, a
        when 1 then @apply q, v, p, a
        when 2 then @apply p, v, t, a
        when 3 then @apply p, q, v, a
        when 4 then @apply t, p, v, a
        when 5 then @apply v, p, q, a
      return

    if Object::toString.call(r) is '[object String]'
      if $ = r.match /#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})/
        @r = parseInt $[1], 16
        @g = parseInt $[2], 16
        @b = parseInt $[3], 16
        @a = g ? 1
        return
      if $ = r.match /#([0-9a-f])([0-9a-f])([0-9a-f])/
        @r = parseInt "#{$[1]}#{$[1]}", 16
        @g = parseInt "#{$[2]}#{$[2]}", 16
        @b = parseInt "#{$[3]}#{$[3]}", 16
        @a = g ? 1
        return
      if $ = r.match /rgba\(\s*(\S+?)\s*,\s*(\S+?)\s*,\s*(\S+?)\s*,\s*(\S+?)\s*\)/
        @r = +$[1]
        @g = +$[2]
        @b = +$[3]
        @a = +$[4]
        return
      if $ = r.match /rgb\(\s*(\S+?)\s*,\s*(\S+?)\s*,\s*(\S+?)\s*\)/
        @r = +$[1]
        @g = +$[2]
        @b = +$[3]
        @a = g ? 1
        return

    switch arguments.length
      when 1, 2
        @r = r >> 16 & 0xff
        @g = r >> 8 & 0xff
        @b = r & 0xff
        @a = g ? 1
      else
        @r = r ? 0
        @g = g ? 0
        @b = b ? 0
        @a = a ? 1

  clone: ->
    new RGB @r, @g, @b, @a

  apply: (r, g, b, a) ->
    if r instanceof RGB
      { r, g, b, a } = r
    @r = r
    @g = g
    @b = b
    @a = a ? 1

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