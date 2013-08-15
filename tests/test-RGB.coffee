chai.should()

{RGB} = createjs.tm

describe 'RGB', ->

  describe '#constructor', ->

    it 'should be constructed without arguments', ->
      rgb = new RGB
      rgb.r.should.equal 0
      rgb.g.should.equal 0
      rgb.b.should.equal 0
      rgb.a.should.equal 1

    it 'should be constructed with r, g, b, and a', ->
      rgb = new RGB 0x70, 0xb1, 0xf1, 0.7
      rgb.r.should.equal 0x70
      rgb.g.should.equal 0xb1
      rgb.b.should.equal 0xf1
      rgb.a.should.equal 0.7
