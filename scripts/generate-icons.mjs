/**
 * generate-icons.mjs
 *
 * Generates placeholder PNG icons for the PWA manifest using only Node.js
 * built-in modules (no canvas / sharp dependency required).
 *
 * Output: public/icons/icon-192.png, icon-512.png, apple-touch-icon.png
 *
 * The icons render a simple ascending bar-chart with a trend line — the same
 * design used in icon.svg — drawn pixel-by-pixel.
 *
 * Run: node scripts/generate-icons.mjs
 */

import { deflateSync } from 'zlib';
import { writeFileSync, mkdirSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const iconsDir = join(__dirname, '../public/icons');

// ─── CRC32 ────────────────────────────────────────────────────────────────────

const CRC_TABLE = (() => {
  const table = new Uint32Array(256);
  for (let i = 0; i < 256; i++) {
    let c = i;
    for (let j = 0; j < 8; j++) c = (c & 1) ? (0xedb88320 ^ (c >>> 1)) : (c >>> 1);
    table[i] = c;
  }
  return table;
})();

function crc32(buf) {
  let crc = 0xffffffff;
  for (let i = 0; i < buf.length; i++) crc = CRC_TABLE[(crc ^ buf[i]) & 0xff] ^ (crc >>> 8);
  return (crc ^ 0xffffffff) >>> 0;
}

// ─── PNG chunk builder ────────────────────────────────────────────────────────

function chunk(type, data) {
  const typeBytes = Buffer.from(type, 'ascii');
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length, 0);
  const crcInput = Buffer.concat([typeBytes, data]);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(crcInput), 0);
  return Buffer.concat([len, typeBytes, data, crc]);
}

// ─── Pixel painter ────────────────────────────────────────────────────────────

/**
 * Returns [r, g, b] for a pixel at normalised coords (nx, ny) in [0,1].
 * Paints the bar-chart-with-trend-line icon.
 */
function pixel(nx, ny) {
  // Background: indigo #4f46e5
  const BG  = [0x4f, 0x46, 0xe5];
  const WHT = [0xff, 0xff, 0xff];

  // ── Rounded-square mask (22% corner radius) ─────────────────────────────
  // Map to [-1, 1] space
  const mx = nx * 2 - 1;
  const my = ny * 2 - 1;
  const r  = 0.78; // inner rect limit
  const cr = 0.22; // corner rounding
  const ax = Math.abs(mx);
  const ay = Math.abs(my);
  if (ax > r || ay > r) {
    // Are we in a corner region?
    if (ax > r - cr && ay > r - cr) {
      const dx = ax - (r - cr);
      const dy = ay - (r - cr);
      if (Math.sqrt(dx * dx + dy * dy) > cr) {
        return [0, 0, 0, 0]; // transparent (outside rounded corner)
      }
    }
  }

  // ── Bars ────────────────────────────────────────────────────────────────
  const PAD = 0.08;
  const BOTTOM = 1 - PAD;

  const bars = [
    { x: 0.08, w: 0.16, h: 0.26 },
    { x: 0.28, w: 0.16, h: 0.42 },
    { x: 0.48, w: 0.16, h: 0.58 },
    { x: 0.68, w: 0.16, h: 0.76 },
  ];

  for (let i = 0; i < bars.length; i++) {
    const { x, w, h } = bars[i];
    if (nx >= x && nx <= x + w && ny >= BOTTOM - h && ny <= BOTTOM) {
      // Varying opacity per bar
      const opacity = 0.55 + i * 0.15;
      return [
        Math.round(0x4f + (0xff - 0x4f) * opacity),
        Math.round(0x46 + (0xff - 0x46) * opacity),
        Math.round(0xe5 + (0xff - 0xe5) * opacity),
      ];
    }
  }

  // ── Trend line ─────────────────────────────────────────────────────────
  const dots = bars.map(({ x, w, h }) => ({ x: x + w / 2, y: BOTTOM - h - 0.035 }));

  const LINE_THICK = 0.028;
  const DOT_R      = 0.045;

  // Check dot proximity first
  for (const d of dots) {
    const dist = Math.sqrt((nx - d.x) ** 2 + (ny - d.y) ** 2);
    if (dist <= DOT_R) return WHT;
  }

  // Check segment proximity
  for (let i = 0; i < dots.length - 1; i++) {
    const a = dots[i];
    const b = dots[i + 1];
    const dx = b.x - a.x;
    const dy = b.y - a.y;
    const lenSq = dx * dx + dy * dy;
    const t = Math.max(0, Math.min(1, ((nx - a.x) * dx + (ny - a.y) * dy) / lenSq));
    const px = a.x + t * dx;
    const py = a.y + t * dy;
    const dist = Math.sqrt((nx - px) ** 2 + (ny - py) ** 2);
    if (dist <= LINE_THICK) return WHT;
  }

  return BG;
}

// ─── PNG generator ────────────────────────────────────────────────────────────

function createPNG(size) {
  // IHDR
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(size, 0);
  ihdr.writeUInt32BE(size, 4);
  ihdr[8]  = 8; // bit depth
  ihdr[9]  = 2; // RGB
  ihdr[10] = 0; // deflate
  ihdr[11] = 0; // filter
  ihdr[12] = 0; // no interlace

  // Raw scanline data: 1 filter byte + size*3 bytes per row
  const raw = Buffer.alloc(size * (1 + size * 3));
  for (let y = 0; y < size; y++) {
    const rowOff = y * (1 + size * 3);
    raw[rowOff] = 0; // filter: None
    for (let x = 0; x < size; x++) {
      const nx = x / (size - 1);
      const ny = y / (size - 1);
      const [r, g, b] = pixel(nx, ny);
      const off = rowOff + 1 + x * 3;
      raw[off]     = r;
      raw[off + 1] = g;
      raw[off + 2] = b;
    }
  }

  const PNG_SIGNATURE = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);

  return Buffer.concat([
    PNG_SIGNATURE,
    chunk('IHDR', ihdr),
    chunk('IDAT', deflateSync(raw, { level: 6 })),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

// ─── Write icons ─────────────────────────────────────────────────────────────

mkdirSync(iconsDir, { recursive: true });

const sizes = [
  ['icon-192.png',        192],
  ['icon-512.png',        512],
  ['apple-touch-icon.png', 180],
];

for (const [name, size] of sizes) {
  const dest = join(iconsDir, name);
  if (!existsSync(dest)) {
    writeFileSync(dest, createPNG(size));
    console.log(`  ✓ Generated ${name} (${size}×${size})`);
  } else {
    console.log(`  · Skipped  ${name} (already exists)`);
  }
}

console.log('Icons ready.\n');
