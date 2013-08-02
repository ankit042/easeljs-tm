class createjs.tm.Bitmap extends createjs.Bitmap

  constructor: (bitmapData) ->
    if bitmapData instanceof createjs.tm.BitmapData
      return @initialize bitmapData.canvas
    @initialize bitmapData
