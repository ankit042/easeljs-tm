class createjs.tm.BitmapData

  { Stage, Container, Shape } = createjs


  isNumber = (obj) ->
    Object::toString.call(obj) is '[object Number]'


  constructor: (width, height) ->
    @canvas = document.createElement 'canvas'
    @canvas.width = width
    @canvas.height = height
    @ctx = @canvas.getContext '2d'

  noise: (x, y, width, height, randomSeed, low = 0, high = 255, channelOptions = 7, grayScale = false, offset = { x: 0, y: 0 }) ->
    @_updatePixels x, y, width, height, @_noise width, height, randomSeed, low, high, channelOptions, grayScale, offset
    @

  _noise: (width, height, randomSeed, low = 0, high = 255, channelOptions = 7, grayScale = false, {x, y} = { x: 0, y: 0 }) ->
    levelMin = Math.min low, high
    levelRange = Math.abs low - high

    xor128 = new createjs.tm.Xor128 (randomSeed % 0xff) << 24 | (x % 0xfff) << 12 | y % 0xfff

    pixels = []
    i = 0
    if grayScale
      for dy in [ 0...height ] by 1
        for dx in [ 0...width ] by 1
          r = g = b = levelMin + xor128.random() % levelRange
          a = 0xff
          pixels[i++] = r
          pixels[i++] = g
          pixels[i++] = b
          pixels[i++] = a
    else
      for dx in [ 0...width ] by 1
        for dy in [ 0...height ] by 1
          r = levelMin + xor128.random() % levelRange
          g = levelMin + xor128.random() % levelRange
          b = levelMin + xor128.random() % levelRange
          a = 0xff
          pixels[i++] = r
          pixels[i++] = g
          pixels[i++] = b
          pixels[i++] = a
    pixels


  perlinNoise: (x, y, width, height, baseX, baseY, numOctaves, randomSeed, stitch, fractalNoise, channelOptions = 7, grayScale = false, offsets = []) ->
    @_updatePixels x, y, width, height, @_perlinNoise width, height, baseX, baseY, numOctaves, randomSeed, stitch, fractalNoise, channelOptions, grayScale, offsets
    @

  _perlinNoise: (width, height, baseX, baseY, numOctaves, randomSeed, stitch, fractalNoise, channelOptions = 7, grayScale = false, offsets = []) ->
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

    for i in [ 0...numOctaves ] by 1
      offset = offsets[i]

      scale = 1 << i
      w = Math.ceil width / scale
      h = Math.ceil height / scale
      pixels = @_noise w, h, randomSeed, 0, 0xff, channelOptions, grayScale, offset
      pixels = @_scale pixels, w, h, width, height, i
      if i isnt 0
        pixels = new createjs.tm.GaussianFilter(1 << i, 1 << i, i).filter width, height, pixels

      octaves[i] = octave =
        persistence: persistences[i]
        pixels     : pixels

    targetPixels = []
    for persistence, i in persistences
      {pixels} = octaves[i]
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
    for y in [ 0...height ]
      for x in [ 0...width ]
        k = w * (y >> i) + (x >> i) << 2
        dst[j++] = pixels[k++]
        dst[j++] = pixels[k++]
        dst[j++] = pixels[k++]
        dst[j++] = pixels[k++]
    dst


  _updatePixels: (x, y, width, height, pixels) ->
    {data} = imageData = @ctx.getImageData 0, 0, @canvas.width, @canvas.height
    for pixel, i in pixels
      data[i] = pixel
    @ctx.putImageData imageData, 0, 0


#    i = 0
#    for pixel, i in pixels
#      data[i] = pixel
