class createjs.tm.HSV

  @interpolate: (a, b, t) ->
    hsv = new HSV
    for key, i in ['h', 's', 'v']
      hsv[key] = a[key] + (b[key] - a[key]) * t
    hsv.normalize()


  constructor: (@h, @s, @v) ->
    if arguments.length is 1
      hex = h
      rgb = new createjs.tm.RGB hex
      r = rgb.r / 255
      g = rgb.g / 255
      b = rgb.b / 255

      h = s = v = 0
      if r >= g then x = r else x = g
      if b > x then x = b
      if r <= g then y = r else y = g
      if b < y then y = b
      v = x
      c = x - y
      if x is 0
        s = 0
      else
        s = c / x
      if s isnt 0
        if r is x
          h = (g - b) / c
        else
          if g is x
            h = 2 + (b - r) / c
          else
            if b is x
              h = 4 + (r - g) / c
        h = h * 60
        if h < 0
          h = h + 360
      @h = h
      @s = s
      @v = v
    @normalize()

  normalize: ->
    @s = if @s < 0 then 0 else if @s > 1 then 1 else @s
    @v = if @v < 0 then 0 else if @v > 1 then 1 else @v
    @h = @h % 360
    @h += 360 if @h < 0
    @

  toRGB: ->
    @normalize()
    {h, s, v} = @
    h /= 60
    i = h >> 0
    x = v * (1 - s)
    y = v * (1 - s * (h - 1))
    z = v * (1 - s * (1 - h + i))
    x = x * 0xff >> 0
    y = y * 0xff >> 0
    z = z * 0xff >> 0
    v = v * 0xff >> 0
    switch i
      when 0 then new createjs.tm.RGB v, z, x
      when 1 then new createjs.tm.RGB y, v, x
      when 2 then new createjs.tm.RGB x, v, z
      when 3 then new createjs.tm.RGB x, y, v
      when 4 then new createjs.tm.RGB z, x, v
      when 5 then new createjs.tm.RGB v, x, y

  toHex: ->
    @toRGB().toHex()

  toString: ->
    "[HSV] #{@h}, #{@s}, #{@v}"

  toCSSString: ->
    @toRGB().toCSSString()