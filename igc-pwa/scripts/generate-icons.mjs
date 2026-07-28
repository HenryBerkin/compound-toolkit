/**
 * generate-icons.mjs
 *
 * Generates placeholder PNG icons for the PWA manifest using only Node.js
 * built-in modules (no canvas / sharp dependency required).
 *
 * Output:
 *  - public/icons/icon-32.png
 *  - public/icons/icon-48.png
 *  - public/icons/icon-192.png
 *  - public/icons/icon-512.png
 *  - public/icons/icon-512-maskable.png
 *  - public/icons/apple-touch-icon.png
 *
 * The icons use a solid indigo background with a minimal white upward mark.
 * No transparency is used in generated PNGs.
 *
 * Run: node scripts/generate-icons.mjs
 */

import { deflateSync } from 'zlib';
import { writeFileSync, mkdirSync } from 'fs';
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

const BG = [0x4f, 0x46, 0xe5];
const FG = [0xff, 0xff, 0xff];

const STYLES = {
  standard: {
    thickness: 0.063,
    feather: 0.013,
    segments: [
      [0.24, 0.68, 0.46, 0.50],
      [0.46, 0.50, 0.72, 0.31],
      [0.72, 0.31, 0.62, 0.31],
      [0.72, 0.31, 0.66, 0.41],
    ],
  },
  maskable: {
    // Extra inner padding for Android mask clipping.
    thickness: 0.058,
    feather: 0.012,
    segments: [
      [0.30, 0.67, 0.47, 0.52],
      [0.47, 0.52, 0.66, 0.36],
      [0.66, 0.36, 0.58, 0.36],
      [0.66, 0.36, 0.61, 0.44],
    ],
  },
};

function clamp01(value) {
  if (value < 0) return 0;
  if (value > 1) return 1;
  return value;
}

function blend(bg, fg, a) {
  return Math.round(bg * (1 - a) + fg * a);
}

function segmentDistance(px, py, x1, y1, x2, y2) {
  const dx = x2 - x1;
  const dy = y2 - y1;
  const lenSq = dx * dx + dy * dy;
  const t = lenSq === 0
    ? 0
    : Math.max(0, Math.min(1, ((px - x1) * dx + (py - y1) * dy) / lenSq));
  const cx = x1 + t * dx;
  const cy = y1 + t * dy;
  const ox = px - cx;
  const oy = py - cy;
  return Math.sqrt(ox * ox + oy * oy);
}

/**
 * Returns [r, g, b] for a pixel at normalised coords (nx, ny) in [0,1].
 * Paints a minimal upward growth mark on a solid background.
 */
function pixel(nx, ny, style) {
  let minDist = Infinity;
  for (const [x1, y1, x2, y2] of style.segments) {
    minDist = Math.min(minDist, segmentDistance(nx, ny, x1, y1, x2, y2));
  }

  const alpha = minDist <= style.thickness
    ? 1
    : clamp01((style.thickness + style.feather - minDist) / style.feather);

  if (alpha <= 0) return BG;

  return [
    blend(BG[0], FG[0], alpha),
    blend(BG[1], FG[1], alpha),
    blend(BG[2], FG[2], alpha),
  ];
}

// ─── PNG generator ────────────────────────────────────────────────────────────

function createPNG(size, styleKey = 'standard') {
  const style = STYLES[styleKey] ?? STYLES.standard;

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
      const [r, g, b] = pixel(nx, ny, style);
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
  { name: 'icon-32.png', size: 32, style: 'standard' },
  { name: 'icon-48.png', size: 48, style: 'standard' },
  { name: 'icon-192.png', size: 192, style: 'standard' },
  { name: 'icon-512.png', size: 512, style: 'standard' },
  { name: 'icon-512-maskable.png', size: 512, style: 'maskable' },
  { name: 'apple-touch-icon.png', size: 180, style: 'standard' },
];

for (const { name, size, style } of sizes) {
  const dest = join(iconsDir, name);
  writeFileSync(dest, createPNG(size, style));
  console.log(`  ✓ Generated ${name} (${size}×${size})`);
}

console.log('Icons ready.\n');
