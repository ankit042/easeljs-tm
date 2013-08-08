class createjs.tm.GaussianFilter extends createjs.tm.KernelFilter

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
