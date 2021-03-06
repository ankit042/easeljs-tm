class createjs.tm.BitmapData

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
