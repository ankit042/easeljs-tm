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

  createjs.tm.Graphics = (function(_super) {
    var Container, Shape, Stage;

    __extends(Graphics, _super);

    Stage = createjs.Stage, Container = createjs.Container, Shape = createjs.Shape;

    function Graphics() {
      Graphics.__super__.constructor.call(this);
    }

    Graphics.prototype.noise = function(x, y, width, height, randomSeed, low, high, channelOptions, grayScale, offset) {
      if (low == null) {
        low = 0;
      }
      if (high == null) {
        high = 255;
      }
      if (channelOptions == null) {
        channelOptions = 7;
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
      this._updatePixels(x, y, width, height, this._noise(width, height, randomSeed, low, high, channelOptions, grayScale, offset));
      return this;
    };

    Graphics.prototype._noise = function(width, height, randomSeed, low, high, channelOptions, grayScale, _arg) {
      var a, b, dx, dy, g, i, levelMin, levelRange, pixels, r, x, xor128, y, _i, _j, _k, _l, _ref;
      if (low == null) {
        low = 0;
      }
      if (high == null) {
        high = 255;
      }
      if (channelOptions == null) {
        channelOptions = 7;
      }
      if (grayScale == null) {
        grayScale = false;
      }
      _ref = _arg != null ? _arg : {
        x: 0,
        y: 0
      }, x = _ref.x, y = _ref.y;
      levelMin = Math.min(low, high);
      levelRange = Math.abs(low - high);
      xor128 = new Xor128((randomSeed % 0xff) << 24 | (x % 0xfff) << 12 | y % 0xfff);
      pixels = [];
      i = 0;
      if (grayScale) {
        for (dy = _i = 0; _i < height; dy = _i += 1) {
          for (dx = _j = 0; _j < width; dx = _j += 1) {
            r = g = b = levelMin + xor128.random() % levelRange;
            a = 0xff;
            pixels[i++] = r;
            pixels[i++] = g;
            pixels[i++] = b;
            pixels[i++] = a;
          }
        }
      } else {
        for (dx = _k = 0; _k < width; dx = _k += 1) {
          for (dy = _l = 0; _l < height; dy = _l += 1) {
            r = levelMin + xor128.random() % levelRange;
            g = levelMin + xor128.random() % levelRange;
            b = levelMin + xor128.random() % levelRange;
            a = 0xff;
            pixels[i++] = r;
            pixels[i++] = g;
            pixels[i++] = b;
            pixels[i++] = a;
          }
        }
      }
      return pixels;
    };

    Graphics.prototype.perlineNoise = function(x, y, width, height, baseX, baseY, numOctaves, randomSeed, stitch, fractalNoise, channelOptions, grayScale, offsets) {
      if (channelOptions == null) {
        channelOptions = 7;
      }
      if (grayScale == null) {
        grayScale = false;
      }
      if (offsets == null) {
        offsets = [];
      }
      this._updatePixels(x, y, width, height, this._perlineNoise(width, height, baseX, baseY, numOctaves, randomSeed, stitch, fractalNoise, channelOptions, grayScale, offsets));
      return this;
    };

    Graphics.prototype._perlineNoise = function(width, height, baseX, baseY, numOctaves, randomSeed, stitch, fractalNoise, channelOptions, grayScale, offsets) {
      var gaussianFilter, h, i, j, k, octave, octaves, offset, persistence, persistences, pixel, pixels, scale, targetPixels, totalWeight, w, weight, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _n, _o;
      if (channelOptions == null) {
        channelOptions = 7;
      }
      if (grayScale == null) {
        grayScale = false;
      }
      if (offsets == null) {
        offsets = [];
      }
      octaves = [];
      persistences = [];
      totalWeight = 0;
      for (i = _i = 0; _i < numOctaves; i = _i += 1) {
        weight = 1 << i;
        persistences[i] = weight;
        totalWeight += weight;
      }
      k = 1 / totalWeight;
      for (i = _j = 0, _len = persistences.length; _j < _len; i = ++_j) {
        persistence = persistences[i];
        persistences[i] *= k;
      }
      gaussianFilter = new createjs.tm.GaussianFilter(2, 2, 1);
      for (i = _k = 0; _k < numOctaves; i = _k += 1) {
        offset = offsets[i];
        scale = 1 << i;
        w = Math.ceil(width / scale);
        h = Math.ceil(height / scale);
        pixels = this._noise(w, h, randomSeed, 0, 0xff, channelOptions, grayScale, offset);
        pixels = this._scale(pixels, w, h, width, height, i);
        pixels = gaussianFilter.filter(width, height, pixels);
        if (i === 5) {
          return pixels;
        }
        octaves[i] = octave = {
          persistence: persistences[i],
          pixels: pixels
        };
      }
      targetPixels = [];
      for (i = _l = 0, _len1 = persistences.length; _l < _len1; i = ++_l) {
        persistence = persistences[i];
        pixels = octaves[i].pixels;
        if (i === 0) {
          for (j = _m = 0, _len2 = pixels.length; _m < _len2; j = ++_m) {
            pixel = pixels[j];
            targetPixels[j] = pixel * persistence;
          }
        } else {
          for (j = _n = 0, _len3 = pixels.length; _n < _len3; j = ++_n) {
            pixel = pixels[j];
            targetPixels[j] += pixel * persistence;
          }
        }
      }
      for (i = _o = 0, _len4 = targetPixels.length; _o < _len4; i = ++_o) {
        pixel = targetPixels[i];
        targetPixels[i] = pixel & 0xff;
      }
      return targetPixels;
    };

    Graphics.prototype._scale = function(pixels, w, h, width, height, i) {
      var dst, j, k, x, y, _i, _j;
      if (i === 0) {
        return pixels.slice();
      }
      dst = [];
      j = 0;
      for (y = _i = 0; 0 <= height ? _i < height : _i > height; y = 0 <= height ? ++_i : --_i) {
        for (x = _j = 0; 0 <= width ? _j < width : _j > width; x = 0 <= width ? ++_j : --_j) {
          k = w * (y >> i) + (x >> i) << 2;
          dst[j++] = pixels[k++];
          dst[j++] = pixels[k++];
          dst[j++] = pixels[k++];
          dst[j++] = pixels[k++];
        }
      }
      return dst;
    };

    Graphics.prototype._updatePixels = function(x, y, width, height, pixels) {
      var a, b, dx, dy, g, i, r, _i, _results;
      i = 0;
      _results = [];
      for (dx = _i = 0; 0 <= width ? _i < width : _i > width; dx = 0 <= width ? ++_i : --_i) {
        _results.push((function() {
          var _j, _results1;
          _results1 = [];
          for (dy = _j = 0; 0 <= height ? _j < height : _j > height; dy = 0 <= height ? ++_j : --_j) {
            r = pixels[i++];
            g = pixels[i++];
            b = pixels[i++];
            a = pixels[i++];
            this.beginFill(Graphics.getRGB(r, g, b, a));
            _results1.push(this.drawRect(x + dx, y + dy, 1, 1));
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    return Graphics;

  })(createjs.Graphics);

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
      var b, g, kernel, kernelHeight, kernelWidth, kx, ky, pixelIndex, px, py, r, rx, ry, weight, x, y, _i, _results;
      if (targetPixels == null) {
        targetPixels = [];
      }
      kernel = this.kernel;
      rx = this.radiusX - 1;
      ry = this.radiusY - 1;
      kernelWidth = rx + this.radiusX;
      kernelHeight = ry + this.radiusY;
      _results = [];
      for (y = _i = 0; _i < height; y = _i += 1) {
        _results.push((function() {
          var _j, _k, _l, _results1;
          _results1 = [];
          for (x = _j = 0; _j < width; x = _j += 1) {
            r = g = b = 0;
            for (kx = _k = 0; _k < kernelWidth; kx = _k += 1) {
              for (ky = _l = 0; _l < kernelHeight; ky = _l += 1) {
                weight = kernel[kernelWidth * ky + kx];
                px = x - rx + ky;
                px = px < 0 ? 0 : px > width - 1 ? width - 1 : px;
                py = y - ry + kx;
                py = py < 0 ? 0 : py > height - 1 ? height - 1 : py;
                pixelIndex = width * py + px << 2;
                r += pixels[pixelIndex] * weight;
                g += pixels[++pixelIndex] * weight;
                b += pixels[++pixelIndex] * weight;
              }
            }
            pixelIndex = width * y + x << 2;
            targetPixels[pixelIndex] = r & 0xff;
            targetPixels[++pixelIndex] = g & 0xff;
            targetPixels[++pixelIndex] = b & 0xff;
            _results1.push(targetPixels[++pixelIndex] = pixels[pixelIndex]);
          }
          return _results1;
        })());
      }
      return _results;
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
      var dx, dy, i, kernel, s, w, weight, _i, _j, _k, _len, _ref, _ref1;
      if (sigma == null) {
        sigma = 1;
      }
      s = 2 * sigma * sigma;
      weight = 0;
      kernel = [];
      for (dy = _i = _ref = 1 - radiusY; _i < radiusY; dy = _i += 1) {
        for (dx = _j = _ref1 = 1 - radiusX; _j < radiusX; dx = _j += 1) {
          w = 1 / (s * Math.PI) * Math.exp(-(dx * dx + dy * dy) / s);
          weight += w;
          kernel.push(w);
        }
      }
      for (i = _k = 0, _len = kernel.length; _k < _len; i = ++_k) {
        kernel[i];
        kernel[i] /= weight;
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

}).call(this);

/*
//@ sourceMappingURL=easeljs.tm.map
*/