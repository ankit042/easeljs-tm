class createjs.tm.Graphics extends createjs.Graphics

  @getRGB: (r, g, b, a) ->
    super r >> 0, g >> 0, b >> 0, a


  beginStroke: (r, g, b, a) ->
    if arguments.length is 1
      return super.apply @, arguments
    super Graphics.getRGB r, g, b, a

  beginFill: (r, g, b, a) ->
    if arguments.length is 1
      return super.apply @, arguments
    super Graphics.getRGB r, g, b, a
