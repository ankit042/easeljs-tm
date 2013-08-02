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

    for y in [0...height] by 1
      for x in [0...width] by 1
        r = g = b = 0
        for kx in [0...kernelWidth] by 1
          for ky in [0...kernelHeight] by 1
            weight = kernel[kernelWidth * ky + kx]

            px = x - rx + ky
            px = if px < 0 then 0 else if px > width - 1 then width - 1 else px
            py = y - ry + kx
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


class createjs.tm.GaussianFilter extends createjs.tm.KernelFilter

  constructor: (radiusX, radiusY, sigma = 1) ->
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