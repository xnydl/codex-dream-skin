import fs from "node:fs/promises";
import path from "node:path";
import zlib from "node:zlib";
import { execFileSync } from "node:child_process";

// One-off deterministic render of the 世事宜梦境 preset at 2560×1440.
// Same math as macos/presets/generate-presets.mjs (vendored engine).

const WIDTH = 2560;
const HEIGHT = 1440;
const OUT = process.argv[2] ?? path.join(path.dirname(new URL(import.meta.url).pathname), "preset-ssyai-dream");

const CRC_TABLE = (() => {
  const table = new Int32Array(256);
  for (let n = 0; n < 256; n += 1) {
    let c = n;
    for (let k = 0; k < 8; k += 1) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    table[n] = c;
  }
  return table;
})();

function crc32(buffer) {
  let c = 0xffffffff;
  for (let i = 0; i < buffer.length; i += 1) c = CRC_TABLE[(c ^ buffer[i]) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}

function chunk(type, data) {
  const typeBuffer = Buffer.from(type, "ascii");
  const length = Buffer.alloc(4);
  length.writeUInt32BE(data.length, 0);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(Buffer.concat([typeBuffer, data])), 0);
  return Buffer.concat([length, typeBuffer, data, crc]);
}

function encodePng(width, height, rgb) {
  const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8;
  ihdr[9] = 2;
  const stride = width * 3;
  const raw = Buffer.alloc((stride + 1) * height);
  for (let y = 0; y < height; y += 1) {
    raw[y * (stride + 1)] = 0;
    rgb.copy(raw, y * (stride + 1) + 1, y * stride, y * stride + stride);
  }
  const idat = zlib.deflateSync(raw, { level: 9 });
  return Buffer.concat([signature, chunk("IHDR", ihdr), chunk("IDAT", idat), chunk("IEND", Buffer.alloc(0))]);
}

const clamp = (value, lo, hi) => (value < lo ? lo : value > hi ? hi : value);
const lerp = (a, b, t) => a + (b - a) * t;
const smooth = (t) => t * t * (3 - 2 * t);

function dither(x, y) {
  let h = (x * 374761393 + y * 668265263) >>> 0;
  h = ((h ^ (h >>> 13)) * 1274126177) >>> 0;
  h = (h ^ (h >>> 16)) >>> 0;
  return h / 4294967295 - 0.5;
}

const hex = (value) => [
  parseInt(value.slice(1, 3), 16),
  parseInt(value.slice(3, 5), 16),
  parseInt(value.slice(5, 7), 16),
];

const screen = (base, light) => 255 - ((255 - base) * (255 - light)) / 255;

const SPEC = {
  slug: "ssyai-dream",
  bg: ["#140d24", "#2b1740"],
  lights: [
    { x: 0.74, y: 0.32, r: 0.62, color: "#ff85c2", intensity: 0.5 },
    { x: 0.9, y: 0.68, r: 0.55, color: "#8f6bff", intensity: 0.46 },
    { x: 0.52, y: 0.88, r: 0.5, color: "#4a9dff", intensity: 0.3 },
  ],
  vignette: 0.32,
  dither: 1.3,
};

function render(spec) {
  const top = hex(spec.bg[0]);
  const bottom = hex(spec.bg[1]);
  const lights = spec.lights.map((l) => ({ ...l, rgb: hex(l.color) }));
  const rgb = Buffer.alloc(WIDTH * HEIGHT * 3);
  const aspect = WIDTH / HEIGHT;
  for (let y = 0; y < HEIGHT; y += 1) {
    const v = y / (HEIGHT - 1);
    for (let x = 0; x < WIDTH; x += 1) {
      const u = x / (WIDTH - 1);
      const t = clamp(u * 0.32 + v * 0.68, 0, 1);
      let r = lerp(top[0], bottom[0], t);
      let g = lerp(top[1], bottom[1], t);
      let b = lerp(top[2], bottom[2], t);
      for (const light of lights) {
        const dx = (u - light.x) * aspect;
        const dy = v - light.y;
        const dist = Math.sqrt(dx * dx + dy * dy);
        if (dist >= light.r) continue;
        const w = smooth(1 - dist / light.r) * light.intensity;
        r = screen(r, light.rgb[0] * w);
        g = screen(g, light.rgb[1] * w);
        b = screen(b, light.rgb[2] * w);
      }
      const cx = (u - 0.5) * aspect;
      const cy = v - 0.5;
      const vignette = 1 - SPEC.vignette * smooth(clamp((cx * cx + cy * cy) / 0.5, 0, 1));
      r *= vignette;
      g *= vignette;
      b *= vignette;
      const n = dither(x, y) * SPEC.dither;
      const i = (y * WIDTH + x) * 3;
      rgb[i] = clamp(Math.round(r + n), 0, 255);
      rgb[i + 1] = clamp(Math.round(g + n), 0, 255);
      rgb[i + 2] = clamp(Math.round(b + n), 0, 255);
    }
  }
  return rgb;
}

await fs.mkdir(OUT, { recursive: true });
const pngPath = path.join(OUT, "background.png");
const jpgPath = path.join(OUT, "background.jpg");
await fs.writeFile(pngPath, encodePng(WIDTH, HEIGHT, render(SPEC)));
execFileSync(
  "/usr/bin/sips",
  ["-s", "format", "jpeg", "-s", "formatOptions", "86", pngPath, "--out", jpgPath],
  { stdio: "ignore" },
);
await fs.rm(pngPath, { force: true });
const { size } = await fs.stat(jpgPath);
console.log(`ssyai-dream: ${(size / 1024).toFixed(0)} KB at ${WIDTH}x${HEIGHT}`);
