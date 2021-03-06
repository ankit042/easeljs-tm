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