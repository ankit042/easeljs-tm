chai.should()

{ HSV } = createjs.tm

describe 'HSV', ->

  describe '#constructor', ->

    it 'should be constructed without arguments', ->
      hsv = new HSV
      hsv.h.should.equal 0
      hsv.s.should.equal 0
      hsv.v.should.equal 0
      hsv.a.should.equal 1

    it 'should be constructed with h, s, v, and a', ->
      hsv = new HSV 120, 0.5, 0.6, 0.7
      hsv.h.should.equal 120
      hsv.s.should.equal 0.5
      hsv.v.should.equal 0.6
      hsv.a.should.equal 0.7

    it 'should be constructed with "#XXXXXX"', ->
      hsv = new HSV '#a5f0e9'
      hsv.h.should.be.closeTo 174, 0.5
      hsv.s.should.be.closeTo 0.31, 0.005
      hsv.v.should.be.closeTo 0.94, 0.005
      hsv.a.should.equal 1

    it 'should be constructed with "#XXXXXX" and alpha', ->
      hsv = new HSV '#a5f0e9', 0.7
      hsv.h.should.be.closeTo 174, 0.5
      hsv.s.should.be.closeTo 0.31, 0.005
      hsv.v.should.be.closeTo 0.94, 0.005
      hsv.a.should.equal 0.7

    it 'should be constructed with "rgb()"', ->
      hsv = new HSV 'rgb(165,240,233)'
      hsv.h.should.be.closeTo 174, 0.5
      hsv.s.should.be.closeTo 0.31, 0.005
      hsv.v.should.be.closeTo 0.94, 0.005
      hsv.a.should.equal 1

    it 'should be constructed with "rgb()" and alpha', ->
      hsv = new HSV 'rgb(165,240,233)', 0.7
      hsv.h.should.be.closeTo 174, 0.5
      hsv.s.should.be.closeTo 0.31, 0.005
      hsv.v.should.be.closeTo 0.94, 0.005
      hsv.a.should.equal 0.7

    it 'should be constructed with "rgba()"', ->
      hsv = new HSV 'rgba(165,240,233,0.7)'
      hsv.h.should.be.closeTo 174, 0.5
      hsv.s.should.be.closeTo 0.31, 0.005
      hsv.v.should.be.closeTo 0.94, 0.005
      hsv.a.should.equal 0.7

  describe '#clone', ->

    it 'should be deep equal instance without alpha', ->
      hsv = new HSV 174, 0.31, 0.94
      hsv.clone().should.eql hsv

    it 'should be deep equal instance with alpha', ->
      hsv = new HSV 174, 0.31, 0.94, 0.7
      hsv.clone().should.eql hsv

  describe '#apply', ->

    it 'should be able to applying values', ->
      hsv0 = new HSV 174, 0.31, 0.94, 0.3
      hsv1 = new HSV 120, 0.5, 0.6, 0.7
      hsv1.apply hsv0
      hsv1.should.eql hsv0

    it 'should be able to partial applying', ->
      hsv = new HSV 120, 0.5, 0.6, 0.7
      hsv.apply
        s: 0.31
      hsv.should.eql new HSV 120, 0.31, 0.6, 0.7

  describe '#normalize', ->

    it 'should normalize minus value', ->
      new HSV(-60, -0.5, -0.6, -0.7).normalize().should.eql new HSV 300, 0, 0, 0
      new HSV(-780, -500, -600, -700).normalize().should.eql new HSV 300, 0, 0, 0

    it 'should normalize large value', ->
      new HSV(780, 1.5, 1.6, 1.7).normalize().should.eql new HSV 60, 1, 1, 1

  describe '#equals', ->

    it 'should be equal', ->
      new HSV(174, 0.31, 0.94).equals(new HSV(174, 0.31, 0.94)).should.be.true
      new HSV(174, 0.31, 0.94, 0.3).equals(new HSV(174, 0.31, 0.94, 0.3)).should.be.true

    it 'should not be equal', ->
      new HSV(174, 0.31, 0.94, 0.3).equals(new HSV(173, 0.31, 0.94, 0.3)).should.be.false
      new HSV(174, 0.31, 0.94, 0.3).equals(new HSV(174, 0.30, 0.94, 0.3)).should.be.false
      new HSV(174, 0.31, 0.94, 0.3).equals(new HSV(174, 0.31, 0.93, 0.3)).should.be.false
      new HSV(174, 0.31, 0.94, 0.3).equals(new HSV(174, 0.31, 0.94, 0.2)).should.be.false
      new HSV(174, 0.31, 0.94, 0.3).equals(new HSV(173, 0.30, 0.93, 0.2)).should.be.false

  describe '#toHex', ->

    it 'should be exact equal at peak color', ->
      hsv = new HSV 0, 1, 1, 0.7
      hsv.toHex().should.equal 0xff0000
      new HSV(hsv.toHex(), hsv.a).should.eql hsv

    it 'should be close to source color', ->
      hsv0 = new HSV 174, 0.31, 0.94
      hsv1 = new HSV hsv0.toHex()
      hsv1.h.should.be.closeTo hsv0.h, 0.5
      hsv1.s.should.be.closeTo hsv0.s, 0.005
      hsv1.v.should.be.closeTo hsv0.v, 0.005

