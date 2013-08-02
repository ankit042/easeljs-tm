class createjs.tm.Graphics extends createjs.Graphics

  { Stage, Container, Shape } = createjs

  class Xor128

    constructor: (w = 88675123) ->
      @x = 123456789
      @y = 362436069
      @z = 521288629
      @w = w % 0xffffffff

    random: ->
      t = @x ^ (@x << 11)
      @x = @y
      @y = @z
      @z = @w
      @w = (@w ^ (@w >> 19)) ^ (t ^ (t >> 8))


  constructor: ->
    super()

  noise: (x, y, width, height, randomSeed, low = 0, high = 255, channelOptions = 7, grayScale = false, offset = { x: 0, y: 0 }) ->
    @_updatePixels x, y, width, height, @_noise width, height, randomSeed, low, high, channelOptions, grayScale, offset
    @

  _noise: (width, height, randomSeed, low = 0, high = 255, channelOptions = 7, grayScale = false, {x, y} = { x: 0, y: 0 }) ->
    levelMin = Math.min low, high
    levelRange = Math.abs low - high

    xor128 = new Xor128 (randomSeed % 0xff) << 24 | (x % 0xfff) << 12 | y % 0xfff

    pixels = []
    i = 0
    if grayScale
      for dy in [0...height] by 1
        for dx in [0...width] by 1
          r = g = b = levelMin + xor128.random() % levelRange
          a = 0xff
          pixels[i++] = r
          pixels[i++] = g
          pixels[i++] = b
          pixels[i++] = a
    else
      for dx in [0...width] by 1
        for dy in [0...height] by 1
          r = levelMin + xor128.random() % levelRange
          g = levelMin + xor128.random() % levelRange
          b = levelMin + xor128.random() % levelRange
          a = 0xff
          pixels[i++] = r
          pixels[i++] = g
          pixels[i++] = b
          pixels[i++] = a
    pixels


  perlineNoise: (x, y, width, height, baseX, baseY, numOctaves, randomSeed, stitch, fractalNoise, channelOptions = 7, grayScale = false, offsets = []) ->
    @_updatePixels x, y, width, height, @_perlineNoise width, height, baseX, baseY, numOctaves, randomSeed, stitch, fractalNoise, channelOptions, grayScale, offsets
    @

  _perlineNoise: (width, height, baseX, baseY, numOctaves, randomSeed, stitch, fractalNoise, channelOptions = 7, grayScale = false, offsets = []) ->
    octaves = []

    persistences = []
    totalWeight = 0
    for i in [ 0...numOctaves ] by 1
      weight = 1 << i
      persistences[i] = weight
      totalWeight += weight
    k = 1 / totalWeight
    for persistence, i in persistences
      persistences[i] *= k

    gaussianFilter = new createjs.tm.GaussianFilter 2, 2, 1
    for i in [ 0...numOctaves ] by 1
      offset = offsets[i]
      octaves[i] = octave =
        persistence: persistences[i]
        pixels     : []

      scale = 1 << i
      w = Math.ceil width / scale
      h = Math.ceil height / scale
      noisedPixels = @_noise w, h, randomSeed, 0, 0xff, channelOptions, grayScale, offset
      scaledPixels = @_scale noisedPixels, w, h, width, height, i
      gaussianFilter.filter width, height, scaledPixels, octave.pixels

    targetPixels = []
    for persistence, i in persistences
      {w, h, pixels} = octaves[i]
      if i is 0
        for pixel, j in pixels
          targetPixels[j] = pixel * persistence
      else
        for pixel, j in pixels
          targetPixels[j] += pixel * persistence
    for pixel, i in targetPixels
      targetPixels[i] = pixel & 0xff
    targetPixels

  _scale: (pixels, w, h, width, height, i) ->
    return pixels.slice() if i is 0

    dst = []
    j = 0
    for y in [0...height]
      for x in [0...width]
        k = w * (y >> i) + (x >> i) << 2
        dst[j++] = pixels[k++]
        dst[j++] = pixels[k++]
        dst[j++] = pixels[k++]
        dst[j++] = pixels[k++]
    dst


  _updatePixels: (x, y, width, height, pixels) ->
    i = 0
    for dx in [ 0...width ]
      for dy in [ 0...height ]
        r = pixels[i++]
        g = pixels[i++]
        b = pixels[i++]
        a = pixels[i++]
        @beginFill Graphics.getRGB r, g, b, a
        @drawRect x + dx, y + dy, 1, 1
