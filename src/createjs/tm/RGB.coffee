class createjs.tm.RGB

  constructor: (@r, @g, @b) ->
    if arguments.length is 1
      hex = r
      @r = hex >> 16
      @g = hex >> 8
      @b = hex
    @normalize()

  normalize: ->
    @r &= 0xff
    @g &= 0xff
    @b &= 0xff
    @

  toHex: ->
    @r << 16 | @g << 8 | @b

  toString: ->
    "[RGB] #{@r}, #{@g}, #{@b}"

  toCSSString: (alpha) ->
    @normalize()
    return "rgba(#{@r}, #{@g}, #{@b}, #{alpha})" if alpha?
    "rgb(#{@r}, #{@g}, #{@b})"
