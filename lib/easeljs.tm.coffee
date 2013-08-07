___extend = (child, parent) ->
  for key, val of parent
    continue unless Object::hasOwnProperty.call parent, key
    if Object::toString.call(val) is '[object Object]'
      child[key] = {}
      ___extend child[key], val
    else
      child[key] = val

if window?
  window.createjs ?= {}
  createjs = window.createjs
if module?.exports?
  module.exports.createjs ?= {}
  createjs = module.exports.createjs
___extend createjs, {"tm":{}}

class createjs.tm.Bitmap extends createjs.Bitmap

  constructor: (bitmapData) ->
    if bitmapData instanceof createjs.tm.BitmapData
      return @initialize bitmapData.canvas
    @initialize bitmapData


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
        baseX    : width / frequency
        baseY    : height / frequency
      factor += amplitude

    factor = 1 / factor

    for octave in octaves
      octave.amplitude *= factor

    for octave, i in octaves
      { offset, baseX, baseY } = octave
      pixels = @_noise baseX, baseY, randomSeed, stitch, 0, 0xff, channelOptions, grayScale, offset
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


class createjs.tm.KernelFilter extends createjs.Filter

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
    kernelHeight = ry + @radiusY

    for i in [0...width * height] by 1
      x = i % width
      y = i / width >> 0
      r = g = b = 0
      for kx in [0...kernelWidth] by 1
        for ky in [0...kernelHeight] by 1
          weight = kernel[kernelWidth * ky + kx]
          px = x - rx + ky
          px = if px < 0 then 0 else if px > width - 1 then width - 1 else px
          py = y - ry + kx
          py = if py < 0 then 0 else if py > height - 1 then height - 1 else py
          pixelIndex = width * py + px << 2
          r += pixels[pixelIndex++] * weight
          g += pixels[pixelIndex++] * weight
          b += pixels[pixelIndex] * weight

      pixelIndex = width * y + x << 2
      targetPixels[pixelIndex++] = r & 0xff
      targetPixels[pixelIndex++] = g & 0xff
      targetPixels[pixelIndex++] = b & 0xff
      targetPixels[pixelIndex] = pixels[pixelIndex]
    targetPixels

  clone: ->
    new KernelFilter @radiusX, @radiusY, @kernel

  toString: ->
    '[KernelFilter]'


class createjs.tm.GaussianFilter extends createjs.tm.KernelFilter

  constructor: (radiusX = 2, radiusY = 2, sigma = 1) ->
    s = 2 * sigma * sigma
    weight = 0
    kernel = []
    for dy in [1 - radiusY...radiusY] by 1
      for dx in [1 - radiusX...radiusX] by 1
        w = 1 / (s * Math.PI) * Math.exp(-(dx*dx+dy*dy)/s)
        weight+=w
        kernel.push w
    for {}, i in kernel
      kernel[i] /= weight
    super radiusX, radiusY, kernel

  clone: ->
    f = new GaussianBlurFilter
    f.kernel = @kernel

  toString: ->
    '[GaussianBlurFilter]'


class createjs.tm.Xor128

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