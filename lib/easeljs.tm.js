(function() {
  var createjs, ___exports, ___extend, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  ___exports = (typeof module !== "undefined" && module !== null ? module.exports : void 0) != null ? module.exports : typeof window !== "undefined" && window !== null ? window : {};

  ___extend = function(child, parent) {
    var key, val, _results;
    _results = [];
    for (key in parent) {
      val = parent[key];
      if (!Object.prototype.hasOwnProperty.call(parent, key)) {
        continue;
      }
      if (Object.prototype.toString.call(val) === '[object Object]') {
        child[key] = {};
        _results.push(___extend(child[key], val));
      } else {
        _results.push(child[key] = val);
      }
    }
    return _results;
  };

  if (___exports.createjs == null) {
    ___exports.createjs = {};
  }

  createjs = ___exports.createjs;

  ___extend(createjs, {
    "tm": {}
  });

  ___exports.createjs.tm.Bitmap = createjs.tm.Bitmap = (function(_super) {
    __extends(Bitmap, _super);

    function Bitmap(bitmapData) {
      if (bitmapData instanceof createjs.tm.BitmapData) {
        return this.initialize(bitmapData.canvas);
      }
      this.initialize(bitmapData);
    }

    return Bitmap;

  })(createjs.Bitmap);

  ___exports.createjs.tm.BitmapData = createjs.tm.BitmapData = (function() {
    var isNumber;

    isNumber = function(obj) {
      return Object.prototype.toString.call(obj) === '[object Number]';
    };

    BitmapData.CHANNEL_RED = parseInt('1000', 2);

    BitmapData.CHANNEL_GREEN = parseInt('0100', 2);

    BitmapData.CHANNEL_BLUE = parseInt('0010', 2);

    BitmapData.CHANNEL_ALPHA = parseInt('0001', 2);

    function BitmapData(width, height) {
      if ((width == null) || (height == null)) {
        throw new TypeError('BitmapData#constructor requires 2 parameters');
      }
      this.canvas = document.createElement('canvas');
      this.canvas.width = width;
      this.canvas.height = height;
      this.ctx = this.canvas.getContext('2d');
    }

    BitmapData.prototype.clear = function() {
      this.ctx.setTransform(1, 0, 0, 1, 0, 0);
      return this.ctx.clearRect(0, 0, this.canvas.width + 1, this.canvas.height + 1);
    };

    BitmapData.prototype.resize = function(width, height) {
      var imageData;
      imageData = this.ctx.getImageData(0, 0, width, height);
      this.canvas.width = width;
      this.canvas.height = height;
      return this.ctx.putImageData(imageData, 0, 0);
    };

    BitmapData.prototype.draw = function() {
      var args, bitmapDrawable;
      bitmapDrawable = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if (!(bitmapDrawable instanceof HTMLImageElement || bitmapDrawable instanceof HTMLCanvasElement || bitmapDrawable instanceof HTMLVideoElement)) {
        if (bitmapDrawable.canvas != null) {
          bitmapDrawable = bitmapDrawable.canvas;
        } else {
          throw new TypeError('draw requires drawable object');
        }
      }
      args.unshift(bitmapDrawable);
      return this.ctx.drawImage.apply(this.ctx, args);
    };

    BitmapData.prototype.noise = function(width, height, randomSeed, stitch, low, high, channelOptions, grayScale, offset) {
      if (randomSeed == null) {
        randomSeed = 88675123;
      }
      if (stitch == null) {
        stitch = false;
      }
      if (low == null) {
        low = 0;
      }
      if (high == null) {
        high = 255;
      }
      if (channelOptions == null) {
        channelOptions = 14;
      }
      if (grayScale == null) {
        grayScale = false;
      }
      if (offset == null) {
        offset = {
          x: 0,
          y: 0
        };
      }
      this._updatePixels(this._noise(width, height, randomSeed, stitch, low, high, channelOptions, grayScale, offset));
      return this;
    };

    BitmapData.prototype._noise = function(width, height, randomSeed, stitch, low, high, channelOptions, grayScale, _arg) {
      var a, aChannel, b, bChannel, colors, dx, dy, g, gChannel, h, iColor, iLevel, iPixel, minLevel, r, rChannel, rangeLevel, w, x, xor128, y, _i, _ref, _ref1;
      if (randomSeed == null) {
        randomSeed = 88675123;
      }
      if (stitch == null) {
        stitch = false;
      }
      if (low == null) {
        low = 0;
      }
      if (high == null) {
        high = 255;
      }
      if (channelOptions == null) {
        channelOptions = 14;
      }
      if (grayScale == null) {
        grayScale = false;
      }
      _ref = _arg != null ? _arg : {
        x: 0,
        y: 0
      }, x = _ref.x, y = _ref.y;
      w = this.canvas.width;
      h = this.canvas.height;
      xor128 = new createjs.tm.Xor128(randomSeed);
      minLevel = Math.min(low, high);
      rangeLevel = Math.abs(low - high);
      rChannel = (channelOptions & BitmapData.CHANNEL_RED) / BitmapData.CHANNEL_RED;
      gChannel = (channelOptions & BitmapData.CHANNEL_GREEN) / BitmapData.CHANNEL_GREEN;
      bChannel = (channelOptions & BitmapData.CHANNEL_BLUE) / BitmapData.CHANNEL_BLUE;
      aChannel = (channelOptions & BitmapData.CHANNEL_ALPHA) / BitmapData.CHANNEL_ALPHA;
      colors = [];
      iColor = 0;
      for (iPixel = _i = 0, _ref1 = w * h; _i < _ref1; iPixel = _i += 1) {
        dx = x + iPixel % w >> 0;
        dy = y + iPixel / w >> 0;
        dx = dx / width >> 0;
        dy = dy / height >> 0;
        if (stitch) {
          dx %= w;
          dy %= h;
        }
        iLevel = dy * w + dx << 2;
        r = minLevel + xor128.at(iLevel++) % rangeLevel;
        if (grayScale) {
          g = b = r;
          iLevel += 2;
        } else {
          g = minLevel + xor128.at(iLevel++) % rangeLevel;
          b = minLevel + xor128.at(iLevel++) % rangeLevel;
        }
        a = minLevel + xor128.at(iLevel++) % rangeLevel;
        colors[iColor++] = r * rChannel;
        colors[iColor++] = g * gChannel;
        colors[iColor++] = b * bChannel;
        colors[iColor++] = 0xff - a * aChannel;
      }
      return colors;
    };

    BitmapData.prototype.perlinNoise = function(width, height, numOctaves, randomSeed, stitch, persistence, channelOptions, grayScale, offsets) {
      if (numOctaves == null) {
        numOctaves = 6;
      }
      if (randomSeed == null) {
        randomSeed = 88675123;
      }
      if (stitch == null) {
        stitch = false;
      }
      if (persistence == null) {
        persistence = .5;
      }
      if (channelOptions == null) {
        channelOptions = 7;
      }
      if (grayScale == null) {
        grayScale = false;
      }
      if (offsets == null) {
        offsets = [];
      }
      this._updatePixels(this._perlinNoise(width, height, numOctaves, randomSeed, stitch, persistence, channelOptions, grayScale, offsets));
      return this;
    };

    BitmapData.prototype._perlinNoise = function(width, height, numOctaves, randomSeed, stitch, persistence, channelOptions, grayScale, offsets) {
      var amplitude, factor, frequency, h, i, j, octave, octaves, pixel, pixels, targetPixels, w, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _n;
      if (numOctaves == null) {
        numOctaves = 6;
      }
      if (randomSeed == null) {
        randomSeed = 88675123;
      }
      if (stitch == null) {
        stitch = false;
      }
      if (persistence == null) {
        persistence = .5;
      }
      if (channelOptions == null) {
        channelOptions = 7;
      }
      if (grayScale == null) {
        grayScale = false;
      }
      if (offsets == null) {
        offsets = [];
      }
      w = this.canvas.width;
      h = this.canvas.height;
      octaves = [];
      factor = 0;
      for (i = _i = 0; _i < numOctaves; i = _i += 1) {
        frequency = 1 << i;
        amplitude = Math.pow(persistence, i);
        octaves[i] = {
          offset: offsets[i],
          frequency: frequency,
          amplitude: amplitude,
          width: width / frequency,
          height: height / frequency
        };
        factor += amplitude;
      }
      factor = 1 / factor;
      for (_j = 0, _len = octaves.length; _j < _len; _j++) {
        octave = octaves[_j];
        octave.amplitude *= factor;
      }
      for (_k = 0, _len1 = octaves.length; _k < _len1; _k++) {
        octave = octaves[_k];
        pixels = this._noise(octave.width, octave.height, randomSeed, stitch, 0, 0xff, channelOptions, grayScale, octave.offset);
        pixels = new createjs.tm.GaussianFilter(octave.width, octave.height, 8).filter(w, h, pixels);
        octave.pixels = pixels;
      }
      targetPixels = [];
      for (_l = 0, _len2 = octaves.length; _l < _len2; _l++) {
        octave = octaves[_l];
        pixels = octave.pixels, amplitude = octave.amplitude;
        for (j = _m = 0, _len3 = pixels.length; _m < _len3; j = ++_m) {
          pixel = pixels[j];
          targetPixels[j] = (targetPixels[j] || 0) + pixel * amplitude;
        }
      }
      for (i = _n = 0, _len4 = targetPixels.length; _n < _len4; i = ++_n) {
        pixel = targetPixels[i];
        targetPixels[i] = pixel & 0xff;
      }
      return targetPixels;
    };

    BitmapData.prototype._scale = function(pixels, scaleX, scaleY) {
      var dst, height, i, j, width, x, y, _i, _j;
      if (scaleX === 1 && scaleY === 1) {
        return pixels.slice();
      }
      width = this.canvas.width;
      height = this.canvas.height;
      dst = [];
      i = 0;
      for (y = _i = 0; _i < height; y = _i += 1) {
        for (x = _j = 0; _j < width; x = _j += 1) {
          j = width * (y / scaleY >> 0) + (x / scaleX >> 0) << 2;
          dst[i++] = pixels[j++];
          dst[i++] = pixels[j++];
          dst[i++] = pixels[j++];
          dst[i++] = pixels[j++];
        }
      }
      return dst;
    };

    BitmapData.prototype._updatePixels = function(pixels) {
      var data, i, imageData, pixel, _i, _len;
      data = (imageData = this.ctx.getImageData(0, 0, this.canvas.width, this.canvas.height)).data;
      for (i = _i = 0, _len = pixels.length; _i < _len; i = ++_i) {
        pixel = pixels[i];
        data[i] = pixel;
      }
      return this.ctx.putImageData(imageData, 0, 0);
    };

    return BitmapData;

  })();

  ___exports.createjs.tm.Graphics = createjs.tm.Graphics = (function(_super) {
    var PI_OVER_2;

    __extends(Graphics, _super);

    function Graphics() {
      _ref = Graphics.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    PI_OVER_2 = Math.PI / 2;

    Graphics.getRGB = function(r, g, b, a) {
      return Graphics.__super__.constructor.getRGB.call(this, r >> 0, g >> 0, b >> 0, a);
    };

    Graphics.prototype.beginStroke = function(r, g, b, a) {
      var rgb;
      rgb = new createjs.tm.RGB;
      createjs.tm.RGB.apply(rgb, arguments);
      return Graphics.__super__.beginStroke.call(this, rgb.toCSSString());
    };

    Graphics.prototype.beginFill = function(r, g, b, a) {
      var rgb;
      rgb = new createjs.tm.RGB;
      createjs.tm.RGB.apply(rgb, arguments);
      return Graphics.__super__.beginFill.call(this, rgb.toCSSString());
    };

    Graphics.prototype.beginCircularGradientFill = function(color0, color1, interpolationMethod, numInterpolate, x0, y0, r0, x1, y1, r1) {
      var angle, colors, i, ratios, unitAngle, _i;
      switch (interpolationMethod) {
        case 'hsv':
          interpolationMethod = createjs.tm.HSV.interpolate;
          break;
        case 'rgb':
          interpolationMethod = createjs.tm.RGB.interpolate;
      }
      colors = [];
      ratios = [];
      unitAngle = PI_OVER_2 / numInterpolate;
      for (i = _i = 0; _i <= numInterpolate; i = _i += 1) {
        angle = unitAngle * i;
        colors[i] = interpolationMethod(color0, color1, 1 - Math.cos(angle)).toCSSString();
        ratios[i] = Math.sin(angle);
      }
      return this.beginRadialGradientFill(colors, ratios, x0, y0, r0, x1, y1, r1);
    };

    return Graphics;

  })(createjs.Graphics);

  ___exports.createjs.tm.HSV = createjs.tm.HSV = (function() {
    HSV.interpolate = function(a, b, t) {
      var hsv, key, _i, _len, _ref1;
      if (!(a instanceof HSV)) {
        a = new HSV(a);
      }
      if (!(b instanceof HSV)) {
        b = new HSV(b);
      }
      hsv = new HSV;
      _ref1 = ['h', 's', 'v', 'a'];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        key = _ref1[_i];
        hsv[key] = a[key] + (b[key] - a[key]) * t;
      }
      return hsv.normalize();
    };

    function HSV(h, s, v, a) {
      var b, c, g, hsv, r, rgb, x, y;
      if (!(this instanceof HSV)) {
        hsv = new HSV;
        HSV.apply(hsv, arguments);
        return hsv;
      }
      if (arguments.length === 0 || arguments.length > 2) {
        this.h = h != null ? h : 0;
        this.s = s != null ? s : 0;
        this.v = v != null ? v : 0;
        this.a = a != null ? a : 1;
        return this;
      }
      if (h instanceof HSV) {
        return this.apply(h);
      }
      if (h instanceof createjs.tm.RGB) {
        rgb = h;
      } else {
        rgb = new createjs.tm.RGB;
        createjs.tm.RGB.apply(rgb, arguments);
      }
      r = rgb.r, g = rgb.g, b = rgb.b, a = rgb.a;
      r /= 0xff;
      g /= 0xff;
      b /= 0xff;
      h = s = v = 0;
      if (r >= g) {
        x = r;
      } else {
        x = g;
      }
      if (b > x) {
        x = b;
      }
      if (r <= g) {
        y = r;
      } else {
        y = g;
      }
      if (b < y) {
        y = b;
      }
      v = x;
      c = x - y;
      if (x === 0) {
        s = 0;
      } else {
        s = c / x;
      }
      if (s !== 0) {
        if (r === x) {
          h = (g - b) / c;
        } else {
          if (g === x) {
            h = 2 + (b - r) / c;
          } else {
            if (b === x) {
              h = 4 + (r - g) / c;
            }
          }
        }
        h *= 60;
        if (h < 0) {
          h += 360;
        }
      }
      this.h = h;
      this.s = s;
      this.v = v;
      this.a = a;
      this;
    }

    HSV.prototype.clone = function() {
      return new HSV(this.h, this.s, this.v, this.a);
    };

    HSV.prototype.apply = function(hsv) {
      if (hsv.h != null) {
        this.h = hsv.h;
      }
      if (hsv.s != null) {
        this.s = hsv.s;
      }
      if (hsv.v != null) {
        this.v = hsv.v;
      }
      if (hsv.a != null) {
        this.a = hsv.a;
      }
      return this;
    };

    HSV.prototype.normalize = function() {
      this.h = this.h % 360;
      if (this.h < 0) {
        this.h += 360;
      }
      if (this.s < 0) {
        this.s = 0;
      } else if (this.s > 1) {
        this.s = 1;
      }
      if (this.v < 0) {
        this.v = 0;
      } else if (this.v > 1) {
        this.v = 1;
      }
      if (this.a < 0) {
        this.a = 0;
      } else if (this.a > 1) {
        this.a = 1;
      }
      return this;
    };

    HSV.prototype.equals = function(_arg) {
      var a, h, s, v;
      h = _arg.h, s = _arg.s, v = _arg.v, a = _arg.a;
      return h === this.h && s === this.s && v === this.v && a === this.a;
    };

    HSV.prototype.toHex = function() {
      return createjs.tm.RGB(this).toHex();
    };

    HSV.prototype.toString = function() {
      return "[HSV] " + this.h + ", " + this.s + ", " + this.v + ", " + this.a;
    };

    HSV.prototype.toCSSString = function() {
      return createjs.tm.RGB(this).toCSSString();
    };

    return HSV;

  })();

  ___exports.createjs.tm.KernelFilter = createjs.tm.KernelFilter = (function(_super) {
    var Rectangle;

    __extends(KernelFilter, _super);

    Rectangle = createjs.Rectangle;

    function KernelFilter(radiusX, radiusY, kernel) {
      this.radiusX = radiusX;
      this.radiusY = radiusY;
      this.kernel = kernel;
    }

    KernelFilter.prototype.getBounds = function() {
      return new Rectangle(-(this.radiusX - 1), -(this.radiusY - 1), this.radiusX * 2 - 1, this.radiusY * 2 - 1);
    };

    KernelFilter.prototype.applyFilter = function(ctx, x, y, width, height, targetCtx, targetX, targetY) {
      var imageData, pixels, targetImageData, targetPixels;
      if (targetCtx == null) {
        targetCtx = ctx;
      }
      if (targetX == null) {
        targetX = x;
      }
      if (targetY == null) {
        targetY = y;
      }
      imageData = ctx.getImageData(x, y, width, height);
      pixels = imageData.data;
      targetImageData = targetCtx.createImageData(width, height);
      targetPixels = targetImageData.data;
      this.filter(width, height, pixels, targetPixels);
      targetCtx.putImageData(targetImageData, targetX, targetY);
      return true;
    };

    KernelFilter.prototype.filter = function(width, height, pixels, targetPixels) {
      var b, g, i, j, kernel, kernelWidth, kx, ky, pixelIndex, px, py, r, rx, ry, weight, x, y, _i, _j, _len, _ref1;
      if (targetPixels == null) {
        targetPixels = [];
      }
      kernel = this.kernel;
      rx = this.radiusX - 1;
      ry = this.radiusY - 1;
      kernelWidth = rx + this.radiusX;
      for (i = _i = 0, _ref1 = width * height; _i < _ref1; i = _i += 1) {
        x = i % width;
        y = i / width >> 0;
        r = g = b = 0;
        for (j = _j = 0, _len = kernel.length; _j < _len; j = _j += 1) {
          weight = kernel[j];
          kx = j % kernelWidth;
          ky = j / kernelWidth >> 0;
          px = x - rx + kx;
          px = px < 0 ? 0 : px > width - 1 ? width - 1 : px;
          py = y - ry + ky;
          py = py < 0 ? 0 : py > height - 1 ? height - 1 : py;
          pixelIndex = width * py + px << 2;
          r += pixels[pixelIndex] * weight;
          g += pixels[++pixelIndex] * weight;
          b += pixels[++pixelIndex] * weight;
        }
        pixelIndex = width * y + x << 2;
        targetPixels[pixelIndex] = r & 0xff;
        targetPixels[++pixelIndex] = g & 0xff;
        targetPixels[++pixelIndex] = b & 0xff;
        targetPixels[++pixelIndex] = pixels[pixelIndex];
      }
      return targetPixels;
    };

    KernelFilter.prototype.clone = function() {
      return new KernelFilter(this.radiusX, this.radiusY, this.kernel);
    };

    KernelFilter.prototype.toString = function() {
      return '[KernelFilter]';
    };

    return KernelFilter;

  })(createjs.Filter);

  ___exports.createjs.tm.GaussianFilter = createjs.tm.GaussianFilter = (function(_super) {
    __extends(GaussianFilter, _super);

    function GaussianFilter(radiusX, radiusY, sigma) {
      var current, i, k, kernel, len, n, pascalTriangle, prev, s, totalWeight, weight, weightX, weightXs, weightY, weightYs, x, y, _i, _j, _k, _l, _len, _len1, _len2, _m, _n, _o, _ref1, _ref2, _ref3;
      if (radiusX == null) {
        radiusX = 2;
      }
      if (radiusY == null) {
        radiusY = 2;
      }
      totalWeight = 0;
      kernel = [];
      if (sigma != null) {
        s = 2 * sigma * sigma;
        for (y = _i = _ref1 = 1 - radiusY; _i < radiusY; y = _i += 1) {
          for (x = _j = _ref2 = 1 - radiusX; _j < radiusX; x = _j += 1) {
            weight = 1 / (s * Math.PI) * Math.exp(-(x * x + y * y) / s);
            totalWeight += weight;
            kernel.push(weight);
          }
        }
      } else {
        pascalTriangle = [];
        for (n = _k = 0, _ref3 = Math.max(radiusX, radiusY) * 2 - 1; 0 <= _ref3 ? _k < _ref3 : _k > _ref3; n = 0 <= _ref3 ? ++_k : --_k) {
          pascalTriangle[n] = current = [];
          prev = pascalTriangle[n - 1];
          len = n + 1;
          for (k = _l = 0; 0 <= len ? _l < len : _l > len; k = 0 <= len ? ++_l : --_l) {
            if (k === 0 || k === len - 1) {
              current[k] = 1;
            } else {
              current[k] = prev[k - 1] + prev[k];
            }
          }
        }
        weightXs = pascalTriangle[(radiusX - 1) * 2];
        weightYs = pascalTriangle[(radiusY - 1) * 2];
        for (_m = 0, _len = weightYs.length; _m < _len; _m++) {
          weightY = weightYs[_m];
          for (_n = 0, _len1 = weightXs.length; _n < _len1; _n++) {
            weightX = weightXs[_n];
            weight = weightX * weightY;
            totalWeight += weight;
            kernel.push(weight);
          }
        }
      }
      for (i = _o = 0, _len2 = kernel.length; _o < _len2; i = ++_o) {
        weight = kernel[i];
        kernel[i] /= totalWeight;
      }
      GaussianFilter.__super__.constructor.call(this, radiusX, radiusY, kernel);
    }

    GaussianFilter.prototype.clone = function() {
      var f;
      f = new GaussianBlurFilter;
      return f.kernel = this.kernel;
    };

    GaussianFilter.prototype.toString = function() {
      return '[GaussianBlurFilter]';
    };

    return GaussianFilter;

  })(createjs.tm.KernelFilter);

  ___exports.createjs.tm.RGB = createjs.tm.RGB = (function() {
    var SMALL_NUMBER;

    SMALL_NUMBER = Math.pow(10, -6);

    RGB.interpolate = function(a, b, t) {
      var key, rgb, _i, _len, _ref1;
      if (!(a instanceof RGB)) {
        a = new RGB(a);
      }
      if (!(b instanceof RGB)) {
        b = new RGB(b);
      }
      rgb = new RGB;
      _ref1 = ['r', 'g', 'b', 'a'];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        key = _ref1[_i];
        rgb[key] = a[key] + (b[key] - a[key]) * t;
      }
      return rgb.normalize();
    };

    /*
    ```CoffeeScript
    new RGB '#f00'
    new RGB '#f00', 0.5
    new RGB '#ff0000'
    new RGB '#ff0000', 0.5
    new RGB 'rgb(255,0,0)'
    new RGB 'rgb(255,0,0)', 0.5
    new RGB 'rgba(255,0,0,0.5)'
    new RGB 0xff0000
    new RGB 0xff0000, 0.5
    new RGB 255, 0, 0
    new RGB 255, 0, 0, 0.5
    ```
    */


    function RGB(r, g, b, a) {
      var $, f, h, hi, p, q, rgb, s, t, v, _ref1;
      if (!(this instanceof RGB)) {
        rgb = new RGB;
        RGB.apply(rgb, arguments);
        return rgb;
      }
      if (r instanceof RGB) {
        this.apply(r);
        return;
      }
      if (r instanceof createjs.tm.HSV) {
        _ref1 = r.clone().normalize(), h = _ref1.h, s = _ref1.s, v = _ref1.v, a = _ref1.a;
        h /= 60;
        hi = h >> 0;
        f = h - hi;
        p = v * (1 - s);
        q = v * (1 - f * s);
        t = v * (1 - (1 - f) * s);
        p = p * 0xff >> 0;
        q = q * 0xff >> 0;
        t = t * 0xff >> 0;
        v = v * 0xff >> 0;
        switch (hi) {
          case 0:
            this.apply(v, t, p, a);
            break;
          case 1:
            this.apply(q, v, p, a);
            break;
          case 2:
            this.apply(p, v, t, a);
            break;
          case 3:
            this.apply(p, q, v, a);
            break;
          case 4:
            this.apply(t, p, v, a);
            break;
          case 5:
            this.apply(v, p, q, a);
        }
        return;
      }
      if (Object.prototype.toString.call(r) === '[object String]') {
        if ($ = r.match(/#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})/)) {
          this.r = parseInt($[1], 16);
          this.g = parseInt($[2], 16);
          this.b = parseInt($[3], 16);
          this.a = g != null ? g : 1;
          return;
        }
        if ($ = r.match(/#([0-9a-f])([0-9a-f])([0-9a-f])/)) {
          this.r = parseInt("" + $[1] + $[1], 16);
          this.g = parseInt("" + $[2] + $[2], 16);
          this.b = parseInt("" + $[3] + $[3], 16);
          this.a = g != null ? g : 1;
          return;
        }
        if ($ = r.match(/rgba\(\s*(\S+?)\s*,\s*(\S+?)\s*,\s*(\S+?)\s*,\s*(\S+?)\s*\)/)) {
          this.r = +$[1];
          this.g = +$[2];
          this.b = +$[3];
          this.a = +$[4];
          return;
        }
        if ($ = r.match(/rgb\(\s*(\S+?)\s*,\s*(\S+?)\s*,\s*(\S+?)\s*\)/)) {
          this.r = +$[1];
          this.g = +$[2];
          this.b = +$[3];
          this.a = g != null ? g : 1;
          return;
        }
      }
      switch (arguments.length) {
        case 1:
        case 2:
          this.r = r >> 16 & 0xff;
          this.g = r >> 8 & 0xff;
          this.b = r & 0xff;
          this.a = g != null ? g : 1;
          break;
        default:
          this.r = r != null ? r : 0;
          this.g = g != null ? g : 0;
          this.b = b != null ? b : 0;
          this.a = a != null ? a : 1;
      }
    }

    RGB.prototype.clone = function() {
      return new RGB(this.r, this.g, this.b, this.a);
    };

    RGB.prototype.apply = function(r, g, b, a) {
      var _ref1;
      if (r instanceof RGB) {
        _ref1 = r, r = _ref1.r, g = _ref1.g, b = _ref1.b, a = _ref1.a;
      }
      this.r = r;
      this.g = g;
      this.b = b;
      return this.a = a != null ? a : 1;
    };

    RGB.prototype.normalize = function() {
      this.r &= 0xff;
      this.g &= 0xff;
      this.b &= 0xff;
      this.a = this.a > 1 ? 1 : this.a < SMALL_NUMBER ? 0 : this.a;
      return this;
    };

    RGB.prototype.toHex = function() {
      return this.r << 16 | this.g << 8 | this.b;
    };

    RGB.prototype.toString = function() {
      return "[RGB] " + this.r + ", " + this.g + ", " + this.b + ", " + this.a;
    };

    RGB.prototype.toCSSString = function() {
      this.normalize();
      return "rgba(" + this.r + ", " + this.g + ", " + this.b + ", " + this.a + ")";
    };

    return RGB;

  })();

  ___exports.createjs.tm.Xor128 = createjs.tm.Xor128 = (function() {
    function Xor128(w) {
      this.w = w != null ? w : 88675123;
      this.x = 123456789;
      this.y = 362436069;
      this.z = 521288629;
      this.w &= 0xffffffff;
      this.cache = [];
    }

    Xor128.prototype.at = function(index) {
      while (this.cache.length <= index) {
        this.random();
      }
      return this.cache[index];
    };

    Xor128.prototype.random = function() {
      var t;
      t = this.x ^ (this.x << 11);
      this.x = this.y;
      this.y = this.z;
      this.z = this.w;
      this.w = (this.w ^ (this.w >> 19)) ^ (t ^ (t >> 8));
      this.cache.push(this.w);
      return this.w;
    };

    return Xor128;

  })();

}).call(this);

/*
//@ sourceMappingURL=easeljs.tm.map
*/