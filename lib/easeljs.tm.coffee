___exports = if module?.exports? then module.exports else if window? then window else {}
___extend = (child, parent) ->
  for key, val of parent
    continue unless Object::hasOwnProperty.call parent, key
    if Object::toString.call(val) is '[object Object]'
      child[key] = {}
      ___extend child[key], val
    else
      child[key] = val

___exports.createjs ?= {}
createjs = ___exports.createjs
___extend createjs, {"tm":{}}

___exports.createjs.tm.Bitmap = class createjs.tm.Bitmap extends createjs.Bitmap

  constructor: (bitmapData) ->
    if bitmapData instanceof createjs.tm.BitmapData
      return @initialize bitmapData.canvas
    @initialize bitmapData


___exports.createjs.tm.BitmapData = class createjs.tm.BitmapData

  isNumber = (obj) ->
    Object::toString.call(obj) is '[object Number]'


  @CHANNEL_RED  : parseInt '1000', 2
  @CHANNEL_GREEN: parseInt '0100', 2
  @CHANNEL_BLUE : parseInt '0010', 2
  @CHANNEL_ALPHA: parseInt '0001', 2


  constructor: (width, height) ->
    if !width? or !height?
      throw new TypeError 'BitmapData#constructor requires 2 parameters'
    @canvas = document.createElement 'canvas'
    @canvas.width = width
    @canvas.height = height
    @ctx = @canvas.getContext '2d'

  clear: ->
    @ctx.setTransform 1, 0, 0, 1, 0, 0
    @ctx.clearRect 0, 0, @canvas.width + 1 , @canvas.height + 1

  resize: (width, height) ->
    imageData = @ctx.getImageData 0, 0, width, height
    @canvas.width = width
    @canvas.height = height
    @ctx.putImageData imageData, 0, 0

  draw: (bitmapDrawable, args...) ->
    unless bitmapDrawable instanceof HTMLImageElement or bitmapDrawable instanceof HTMLCanvasElement or bitmapDrawable instanceof HTMLVideoElement
      if bitmapDrawable.canvas?
        bitmapDrawable = bitmapDrawable.canvas
      else
        throw new TypeError 'draw requires drawable object'
    args.unshift bitmapDrawable
    @ctx.drawImage.apply @ctx, args

  noise: (width, height, randomSeed = 88675123, stitch = false, low = 0, high = 255, channelOptions = 14, grayScale = false, offset = { x: 0, y: 0 }) ->
    @_updatePixels @_noise width, height, randomSeed, stitch, low, high, channelOptions, grayScale, offset
    @

  _noise: (width, height, randomSeed = 88675123, stitch = false, low = 0, high = 255, channelOptions = 14, grayScale = false, {x, y} = { x: 0, y: 0 }) ->
    w = @canvas.width
    h = @canvas.height
    xor128 = new createjs.tm.Xor128 randomSeed
    minLevel = Math.min low, high
    rangeLevel = Math.abs low - high
    rChannel = (channelOptions & BitmapData.CHANNEL_RED) / BitmapData.CHANNEL_RED
    gChannel = (channelOptions & BitmapData.CHANNEL_GREEN) / BitmapData.CHANNEL_GREEN
    bChannel = (channelOptions & BitmapData.CHANNEL_BLUE) / BitmapData.CHANNEL_BLUE
    aChannel = (channelOptions & BitmapData.CHANNEL_ALPHA) / BitmapData.CHANNEL_ALPHA

    colors = []
    iColor = 0
    for iPixel in [ 0...w * h ] by 1
      dx = x + iPixel % w >> 0
      dy = y + iPixel / w >> 0
      dx = dx / width >> 0
      dy = dy / height >> 0
      if stitch
        dx %= w
        dy %= h
      iLevel = dy * w + dx << 2
      r = minLevel + xor128.at(iLevel++) % rangeLevel
      if grayScale
        g = b = r
        iLevel += 2
      else
        g = minLevel + xor128.at(iLevel++) % rangeLevel
        b = minLevel + xor128.at(iLevel++) % rangeLevel
      a = minLevel + xor128.at(iLevel++) % rangeLevel
      colors[iColor++] = r * rChannel
      colors[iColor++] = g * gChannel
      colors[iColor++] = b * bChannel
      colors[iColor++] = 0xff - a * aChannel
    colors


  perlinNoise: (width, height, numOctaves = 6, randomSeed = 88675123, stitch = false, persistence = .5, channelOptions = 7, grayScale = false, offsets = []) ->
    @_updatePixels @_perlinNoise width, height, numOctaves, randomSeed, stitch, persistence, channelOptions, grayScale, offsets
    @

  _perlinNoise: (width, height, numOctaves = 6, randomSeed = 88675123, stitch = false, persistence = .5, channelOptions = 7, grayScale = false, offsets = []) ->
    w = @canvas.width
    h = @canvas.height

    octaves = []

    factor = 0
    for i in [0...numOctaves] by 1
      frequency = 1 << i
      amplitude = Math.pow persistence, i
      octaves[i] =
        offset   : offsets[i]
        frequency: frequency
        amplitude: amplitude
        width    : width / frequency
        height   : height / frequency
      factor += amplitude

    factor = 1 / factor

    for octave in octaves
      octave.amplitude *= factor

    for octave in octaves
      pixels = @_noise octave.width, octave.height, randomSeed, stitch, 0, 0xff, channelOptions, grayScale, octave.offset
      pixels = new createjs.tm.GaussianFilter(octave.width, octave.height, 8).filter w, h, pixels
      octave.pixels = pixels

    targetPixels = []
    for octave in octaves
      { pixels, amplitude } = octave
      for pixel, j in pixels
        targetPixels[j] = (targetPixels[j] or 0) + pixel * amplitude
    for pixel, i in targetPixels
      targetPixels[i] = pixel & 0xff
    targetPixels

  _scale: (pixels, scaleX, scaleY) ->
    return pixels.slice() if scaleX is 1 and scaleY is 1

    width = @canvas.width
    height = @canvas.height
    dst = []
    i = 0
    for y in [ 0...height ] by 1
      for x in [ 0...width ] by 1
        j = width * (y / scaleY >> 0) + (x / scaleX >> 0) << 2
        dst[i++] = pixels[j++]
        dst[i++] = pixels[j++]
        dst[i++] = pixels[j++]
        dst[i++] = pixels[j++]
    dst


  _updatePixels: (pixels) ->
    {data} = imageData = @ctx.getImageData 0, 0, @canvas.width, @canvas.height
    for pixel, i in pixels
      data[i] = pixel
    @ctx.putImageData imageData, 0, 0


#    i = 0
#    for pixel, i in pixels
#      data[i] = pixel


___exports.createjs.tm.Graphics = class createjs.tm.Graphics extends createjs.Graphics

  PI_OVER_2 = Math.PI / 2


  @getRGB: (r, g, b, a) ->
    super r >> 0, g >> 0, b >> 0, a


  beginStroke: (r, g, b, a) ->
    rgb = new createjs.tm.RGB
    createjs.tm.RGB.apply rgb, arguments
    super rgb.toCSSString()

  beginFill: (r, g, b, a) ->
    rgb = new createjs.tm.RGB
    createjs.tm.RGB.apply rgb, arguments
    super rgb.toCSSString()

  beginCircularGradientFill: (color0, color1, interpolationMethod,
    numInterpolate, x0, y0, r0, x1, y1, r1) ->

    switch interpolationMethod
      when 'hsv'
        interpolationMethod = createjs.tm.HSV.interpolate
      when 'rgb'
        interpolationMethod = createjs.tm.RGB.interpolate

    colors = []
    ratios = []
    unitAngle = PI_OVER_2 / numInterpolate
    for i in [ 0..numInterpolate ] by 1
      angle = unitAngle * i
      colors[i] = interpolationMethod(color0, color1, 1 - Math.cos angle).toCSSString()
      ratios[i] = Math.sin angle
    @beginRadialGradientFill colors, ratios, x0, y0, r0, x1, y1, r1



___exports.createjs.tm.HSV = class createjs.tm.HSV

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
      return @

    if h instanceof HSV
      return @apply h

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
    @

  clone: ->
    new HSV @h, @s, @v, @a

  apply: (hsv) ->
    @h = hsv.h if hsv.h?
    @s = hsv.s if hsv.s?
    @v = hsv.v if hsv.v?
    @a = hsv.a if hsv.a?
    @

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

  equals: ({h, s, v, a}) ->
    h is @h and s is @s and v is @v and a is @a

  toHex: ->
    createjs.tm.RGB(@).toHex()

  toString: ->
    "[HSV] #{@h}, #{@s}, #{@v}, #{@a}"

  toCSSString: ->
    createjs.tm.RGB(@).toCSSString()


___exports.createjs.tm.KernelFilter = class createjs.tm.KernelFilter extends createjs.Filter

  { Rectangle } = createjs


  constructor: (@radiusX, @radiusY, @kernel) ->

  getBounds: ->
    new Rectangle -(@radiusX - 1), -(@radiusY - 1), @radiusX * 2 - 1, @radiusY * 2 - 1

  applyFilter: (ctx, x, y, width, height, targetCtx, targetX, targetY) ->
    targetCtx ?= ctx
    targetX ?= x
    targetY ?= y

    imageData = ctx.getImageData x, y, width, height
    pixels = imageData.data
    targetImageData = targetCtx.createImageData width, height
    targetPixels = targetImageData.data

    @filter width, height, pixels, targetPixels

    targetCtx.putImageData targetImageData, targetX, targetY
    true

  filter: (width, height, pixels, targetPixels = []) ->
    kernel = @kernel
    rx = @radiusX - 1
    ry = @radiusY - 1
    kernelWidth = rx + @radiusX

    for i in [0...width * height] by 1
      x = i % width
      y = i / width >> 0
      r = g = b = 0
      for weight, j in kernel by 1
        kx = j % kernelWidth
        ky = j / kernelWidth >> 0
        px = x - rx + kx
        px = if px < 0 then 0 else if px > width - 1 then width - 1 else px
        py = y - ry + ky
        py = if py < 0 then 0 else if py > height - 1 then height - 1 else py
        pixelIndex = width * py + px << 2
        r += pixels[pixelIndex] * weight
        g += pixels[++pixelIndex] * weight
        b += pixels[++pixelIndex] * weight

      pixelIndex = width * y + x << 2
      targetPixels[pixelIndex] = r & 0xff
      targetPixels[++pixelIndex] = g & 0xff
      targetPixels[++pixelIndex] = b & 0xff
      targetPixels[++pixelIndex] = pixels[pixelIndex]
    targetPixels

  clone: ->
    new KernelFilter @radiusX, @radiusY, @kernel

  toString: ->
    '[KernelFilter]'


___exports.createjs.tm.GaussianFilter = class createjs.tm.GaussianFilter extends createjs.tm.KernelFilter

#  SIGMA2_2 = Math.sqrt(-1/(2*Math.log(1/2)))

  constructor: (radiusX = 2, radiusY = 2, sigma) ->
    totalWeight = 0
    kernel = []
    if sigma?
      s = 2 * sigma * sigma
      for y in [ 1 - radiusY...radiusY ] by 1
        for x in [ 1 - radiusX...radiusX ] by 1
          weight = 1 / (s * Math.PI) * Math.exp(-(x * x + y * y) / s)
          totalWeight += weight
          kernel.push weight
    else
      # Generate kernel with pascal's triangle
      pascalTriangle = []
      for n in [ 0...Math.max(radiusX, radiusY) * 2 - 1 ]
        pascalTriangle[n] = current = []
        prev = pascalTriangle[n - 1]
        len = n + 1
        for k in [ 0...len ]
          if k is 0 or k is len - 1
            current[k] = 1
          else
            current[k] = prev[k - 1] + prev[k]
      weightXs = pascalTriangle[(radiusX - 1) * 2]
      weightYs = pascalTriangle[(radiusY - 1) * 2]
      for weightY in weightYs
        for weightX in weightXs
          weight = weightX * weightY
          totalWeight += weight
          kernel.push weight

    for weight, i in kernel
      kernel[i] /= totalWeight
    super radiusX, radiusY, kernel

  clone: ->
    f = new GaussianBlurFilter
    f.kernel = @kernel

  toString: ->
    '[GaussianBlurFilter]'


___exports.createjs.tm.RGB = class createjs.tm.RGB

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

___exports.createjs.tm.Xor128 = class createjs.tm.Xor128

  constructor: (@w = 88675123) ->
    @x = 123456789
    @y = 362436069
    @z = 521288629
    @w &= 0xffffffff
    @cache = []

  at: (index) ->
    while @cache.length <= index
      @random()
    @cache[index]

  random: ->
    t = @x ^ (@x << 11)
    @x = @y
    @y = @z
    @z = @w
    @w = (@w ^ (@w >> 19)) ^ (t ^ (t >> 8))
    @cache.push @w
    @w