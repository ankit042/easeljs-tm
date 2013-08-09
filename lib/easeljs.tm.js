(function() {
  var createjs, ___extend, _base,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

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

  if (typeof window !== "undefined" && window !== null) {
    if (window.createjs == null) {
      window.createjs = {};
    }
    createjs = window.createjs;
  }

  if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    if ((_base = module.exports).createjs == null) {
      _base.createjs = {};
    }
    createjs = module.exports.createjs;
  }

  ___extend(createjs, {
    "tm": {}
  });

  createjs.tm.Bitmap = (function(_super) {
    __extends(Bitmap, _super);

    function Bitmap(bitmapData) {
      if (bitmapData instanceof createjs.tm.BitmapData) {
        return this.initialize(bitmapData.canvas);
      }
      this.initialize(bitmapData);
    }

    return Bitmap;

  })(createjs.Bitmap);

  createjs.tm.BitmapData = (function() {
    var Container, Shape, Stage, isNumber;

    Stage = createjs.Stage, Container = createjs.Container, Shape = createjs.Shape;

    isNumber = function(obj) {
      return Object.prototype.toString.call(obj) === '[object Number]';
    };

    BitmapData.CHANNEL_RED = parseInt('1000', 2);

    BitmapData.CHANNEL_GREEN = parseInt('0100', 2);

    BitmapData.CHANNEL_BLUE = parseInt('0010', 2);

    BitmapData.CHANNEL_ALPHA = parseInt('0001', 2);

    function BitmapData(width, height) {
      this.canvas = document.createElement('canvas');
      this.canvas.width = width;
      this.canvas.height = height;
      this.ctx = this.canvas.getContext('2d');
    }

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
        pixels = new createjs.tm.GaussianFilter(Math.max(octave.width, 10), Math.max(octave.height, 10), 8).filter(w, h, pixels);
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

  createjs.tm.KernelFilter = (function(_super) {
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
      var b, g, i, j, kernel, kernelWidth, kx, ky, pixelIndex, px, py, r, rx, ry, weight, x, y, _i, _j, _len, _ref;
      if (targetPixels == null) {
        targetPixels = [];
      }
      kernel = this.kernel;
      rx = this.radiusX - 1;
      ry = this.radiusY - 1;
      kernelWidth = rx + this.radiusX;
      for (i = _i = 0, _ref = width * height; _i < _ref; i = _i += 1) {
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

  createjs.tm.GaussianFilter = (function(_super) {
    __extends(GaussianFilter, _super);

    function GaussianFilter(radiusX, radiusY, sigma) {
      var current, i, k, kernel, len, n, pascalTriangle, prev, s, totalWeight, weight, weightX, weightXs, weightY, weightYs, x, y, _i, _j, _k, _l, _len, _len1, _len2, _m, _n, _o, _ref, _ref1, _ref2;
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
        for (y = _i = _ref = 1 - radiusY; _i < radiusY; y = _i += 1) {
          for (x = _j = _ref1 = 1 - radiusX; _j < radiusX; x = _j += 1) {
            weight = 1 / (s * Math.PI) * Math.exp(-(x * x + y * y) / s);
            totalWeight += weight;
            kernel.push(weight);
          }
        }
      } else {
        pascalTriangle = [];
        for (n = _k = 0, _ref2 = Math.max(radiusX, radiusY) * 2 - 1; 0 <= _ref2 ? _k < _ref2 : _k > _ref2; n = 0 <= _ref2 ? ++_k : --_k) {
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

  createjs.tm.Xor128 = (function() {
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