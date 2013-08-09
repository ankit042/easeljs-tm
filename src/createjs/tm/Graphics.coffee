class createjs.tm.Graphics extends createjs.Graphics

  @getRGB: (r, g, b, a) ->
    super r >> 0, g >> 0, b >> 0, a


  beginStroke: (r, g, b, a) ->
    if arguments.length is 1
      if Object::toString.call(r) is '[object Number]'
        return super new createjs.tm.RGB(r).toCSSString()
      return super r
    super Graphics.getRGB r, g, b, a

  beginFill: (r, g, b, a) ->
    if arguments.length is 1
      if Object::toString.call(r) is '[object Number]'
        return super new createjs.tm.RGB(r).toCSSString()
      return super r
    super Graphics.getRGB r, g, b, a
