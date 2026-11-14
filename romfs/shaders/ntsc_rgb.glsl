#version 300 es
precision highp float;
// NTSC signal simulation for RGB sources (SW2SNES). Each pixel's colour is
// converted to YIQ and modulated onto the colour subcarrier as a composite
// signal, sampled 12 times per subcarrier cycle; the SNES draws one pixel
// every 2/3 of a cycle (8 samples; 4 in 512-wide modes) and the phase moves
// 4 samples per scanline. The signal is then decoded like a TV: luma averaged
// over one cycle, chroma (I/Q) demodulated over `chromaWin` samples, which
// gives composite colour bleed, fringing and (optionally) dot crawl.
uniform sampler2D colors;   // the RGB picture (named as in SW2NES's NES shader)
uniform vec2 inSize;        // current frame size in pixels (W, H)
uniform float frameCount;
uniform int dotCrawl;
uniform float lumaWin;      // samples: 12 composite, 6 S-Video
uniform float chromaWin;    // samples: 24 composite, 18 S-Video
uniform int svideo;         // 1: luma and chroma kept separate (no cross-colour)
uniform vec4 decode;        // hue offset (samples), saturation, brightness, contrast
uniform float gammaOut;
in vec2 vpos;
out vec4 fragColor;

const float PI = 3.14159265;
void main() {
  // vpos: output texel centre, measured from the top; framebuffer rows count
  // from the bottom, so flip to land line y in texel row y.
  int y = int(inSize.y) - 1 - int(vpos.y);
  float spp = 8.0 * 256.0 / inSize.x;            // signal samples per source pixel
  float outW = 768.0;
  float centre = vpos.x / outW * inSize.x * spp;  // in signal samples
  int linePhase = (y * 4 + (dotCrawl == 1 ? int(frameCount) * 4 : 0)) % 12;
  float Y = 0.0, I = 0.0, Q = 0.0, ny = 0.0, nc = 0.0;
  int s0 = int(floor(centre - chromaWin * 0.5)), s1 = int(floor(centre + chromaWin * 0.5));
  for (int s = s0; s < s1; s++) {
    int px = clamp(int(floor(float(s) / spp)), 0, int(inSize.x) - 1);
    vec3 c = texelFetch(colors, ivec2(px, y), 0).rgb;
    float yy = dot(c, vec3(0.299, 0.587, 0.114));
    float ii = dot(c, vec3(0.596, -0.274, -0.322));
    float qq = dot(c, vec3(0.211, -0.523, 0.312));
    float ph = float(((s % 12) + 12 + linePhase) % 12);
    float ang = 2.0 * PI * ph / 12.0;
    float chroma = ii * cos(ang) + qq * sin(ang);
    float v = yy + chroma;
    float d = float(s) + 0.5 - centre;
    if (abs(d) <= lumaWin * 0.5) { Y += svideo == 1 ? yy : v; ny += 1.0; }
    float sig = svideo == 1 ? chroma : v;
    float dang = 2.0 * PI * (ph + decode.x) / 12.0;
    I += sig * cos(dang); Q += sig * sin(dang); nc += 1.0;
  }
  Y = Y / max(ny, 1.0) * decode.w + decode.z;
  I = 2.0 * I / max(nc, 1.0) * decode.y;
  Q = 2.0 * Q / max(nc, 1.0) * decode.y;
  vec3 rgb = vec3(Y + 0.956 * I + 0.621 * Q, Y - 0.272 * I - 0.647 * Q, Y - 1.106 * I + 1.703 * Q);
  fragColor = vec4(pow(clamp(rgb, 0.0, 1.0), vec3(gammaOut)), 1.0);
}
