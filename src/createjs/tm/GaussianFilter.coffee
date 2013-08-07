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
