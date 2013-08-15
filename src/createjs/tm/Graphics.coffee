class createjs.tm.Graphics extends createjs.Graphics

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

