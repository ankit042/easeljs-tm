class createjs.tm.BitmapData

  { Stage, Container, Shape } = createjs


  isNumber = (obj) ->
    Object::toString.call(obj) is '[object Number]'


  @CHANNEL_RED  : parseInt '1000', 2
  @CHANNEL_GREEN: parseInt '0100', 2
  @CHANNEL_BLUE : parseInt '0010', 2
  @CHANNEL_ALPHA: parseInt '0001', 2


  constructor: (width, height) ->
    @canvas = document.createElement 'canvas'
    @canvas.width = width
    @canvas.height = height
    @ctx = @canvas.getContext '2d'

  noise: (baseX, baseY, randomSeed, low = 0, high = 255, channelOptions = 14, grayScale = false, offset = { x: 0, y: 0 }) ->
    @_updatePixels @_noise baseX, baseY, randomSeed, low, high, channelOptions, grayScale, offset
    @

  _noise: (baseX, baseY, randomSeed, low = 0, high = 255, channelOptions = 14, grayScale = false, {x, y} = { x: 0, y: 0 }) ->
    width = @canvas.width
    height = @canvas.height
    levelMin = Math.min low, high
    levelRange = Math.abs low - high
    rChannel = (channelOptions & BitmapData.CHANNEL_RED) / BitmapData.CHANNEL_RED
    gChannel = (channelOptions & BitmapData.CHANNEL_GREEN) / BitmapData.CHANNEL_GREEN
    bChannel = (channelOptions & BitmapData.CHANNEL_BLUE) / BitmapData.CHANNEL_BLUE
    aChannel = (channelOptions & BitmapData.CHANNEL_ALPHA) / BitmapData.CHANNEL_ALPHA

    randColor = new createjs.tm.Xor128 randomSeed

    pixels = []
    i = 0
    j = width * y + x
    if grayScale
      for k in [ 0...width * height ] by 1
        r = g = b = levelMin + randColor.at(j) % levelRange
        j += 3
        a = levelMin + randColor.at(j++) % levelRange
        pixels[i++] = r * rChannel
        pixels[i++] = g * gChannel
        pixels[i++] = b * bChannel
        pixels[i++] = 0xff - a * aChannel
    else
      for k in [ 0...width * height ] by 1
        r = levelMin + randColor.at(j++) % levelRange
        g = levelMin + randColor.at(j++) % levelRange
        b = levelMin + randColor.at(j++) % levelRange
        a = 0xff
        j++
        pixels[i++] = r * rChannel
        pixels[i++] = g * gChannel
        pixels[i++] = b * bChannel
        pixels[i++] = 0xff - a * aChannel
    pixels


  perlinNoise: (baseX, baseY, numOctaves, randomSeed, stitch, persistence = .5, channelOptions = 7, grayScale = false, offsets = []) ->
    @_updatePixels @_perlinNoise baseX, baseY, numOctaves, randomSeed, stitch, persistence, channelOptions, grayScale, offsets
    @

  _perlinNoise: (baseX, baseY, numOctaves, randomSeed, stitch, persistence = .5, channelOptions = 7, grayScale = false, offsets = []) ->
    width = @canvas.width
    height = @canvas.height

    octaves = []

    factor = 0
    for i in [0...numOctaves] by 1
      frequency = 1 << i
      amplitude = Math.pow persistence, i
      octaves[i] =
        offset   : offsets[i]
        frequency: frequency
        amplitude: amplitude
        baseX    : baseX / frequency
        baseY    : baseY / frequency
      factor += amplitude

    factor = 1 / factor

    for octave in octaves
      octave.amplitude *= factor

    for octave, i in octaves
      { offset, baseX, baseY } = octave
      pixels = @_noise baseX, baseY, randomSeed, 0, 0xff, channelOptions, grayScale, offset
#      pixels = @_scale pixels, scaleX, scaleY
#      pixels = new createjs.tm.GaussianFilter(1 << i, 1 << i, i).filter width, height, pixels
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
