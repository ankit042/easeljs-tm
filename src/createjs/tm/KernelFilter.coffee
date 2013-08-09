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
