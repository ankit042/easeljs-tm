class createjs.tm.HSV

  @interpolate: (a, b, t) ->
    unless a instanceof HSV
      a = new HSV a
    unless b instanceof HSV
      b = new HSV b

    hsv = new HSV
    for key in [ 'h', 's', 'v', 'a' ]
      hsv[key] = a[key] + (b[key] - a[key]) * t
    hsv.normalize()


  constructor: (h, s, v, a) ->
    unless @ instanceof HSV
      hsv = new HSV
      HSV.apply hsv, arguments
      return hsv

    if arguments.length is 0 or arguments.length > 2
      @h = h ? 0
      @s = s ? 0
      @v = v ? 0
      @a = a ? 1
      @normalize()
      return

    if h instanceof HSV
      @apply h
      return

    if h instanceof createjs.tm.RGB
      rgb = h
    else
      rgb = new createjs.tm.RGB
      createjs.tm.RGB.apply rgb, arguments
    { r, g, b, a } = rgb
    r /= 0xff
    g /= 0xff
    b /= 0xff
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
      h *= 60
      if h < 0
        h += 360
    @h = h
    @s = s
    @v = v
    @a = a

  clone: ->
    new HSV @h, @s, @v, @a

  apply: (hsv) ->
    @h = hsv.h
    @s = hsv.s
    @v = hsv.v
    @a = hsv.a ? 1

  normalize: ->
    @h = @h % 360
    if @h < 0
      @h += 360
    if @s < 0
      @s = 0
    else if @s > 1
      @s = 1
    if @v < 0
      @v = 0
    else if @v > 1
      @v = 1
    if @a < 0
      @a = 0
    else if @a > 1
      @a = 1
    @

  toHex: ->
    createjs.tm.RGB(@).toHex()

  toString: ->
    "[HSV] #{@h}, #{@s}, #{@v}, #{@a}"

  toCSSString: ->
    createjs.tm.RGB(@).toCSSString()
