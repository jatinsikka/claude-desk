# Claude Desk — Bill of Materials

## Electronics

| # | Part | Spec | Source | Unit Cost | Qty | Total |
|---|------|------|--------|-----------|-----|-------|
| 1 | LILYGO T-Display-S3 | ESP32-S3, 1.9" IPS 170x320, USB-C | AliExpress / Amazon | $12.00 | 1 | $12.00 |
| 2 | LiPo Battery | 3.7V 500mAh, JST-PH 2.0 connector, 40x25x6mm | AliExpress | $3.00 | 1 | $3.00 |
| 3 | USB-C cable | Short 20cm, for charging / power | — | bundled | — | — |

## Mechanical

| # | Part | Spec | Source | Unit Cost | Qty | Total |
|---|------|------|--------|-----------|-----|-------|
| 4 | PLA+ filament | ~30g per unit | Local / Amazon | $0.10/g | 30g | $3.00 |
| 5 | Frosted acrylic sheet | 43x25mm, 2mm thick, laser cut | Laser service / DIY | $0.50 | 1 | $0.50 |
| 6 | M2 x 8mm screws | Pan head, stainless | Amazon (pack) | $0.05 | 4 | $0.20 |
| 7 | M2 heat-set brass inserts | OD 3.2mm, L 4mm | Amazon (pack) | $0.05 | 4 | $0.20 |
| 8 | Rubber feet | 10mm dia, self-adhesive, 2mm height | Amazon (pack) | $0.10 | 4 | $0.40 |

## Packaging (per unit, at 50 qty)

| # | Part | Spec | Unit Cost |
|---|------|------|-----------|
| 9 | Kraft mailer box | 100x100x60mm | $0.60 |
| 10 | Foam insert | Die-cut EVA foam | $0.40 |
| 11 | Quick start card | 90x55mm, printed | $0.15 |
| 12 | USB-C cable (included) | 20cm braided | $0.80 |

---

## Cost Summary

| Tier | Electronics | Mechanical | Packaging | **Total COGS** |
|------|-------------|------------|-----------|----------------|
| Proto (1 unit) | $15.00 | $4.30 | n/a | **~$19.30** |
| Small batch (50 units) | $13.50 | $3.80 | $1.95 | **~$19.25** |
| Medium batch (200 units) | $11.00 | $2.80 | $1.50 | **~$15.30** |

> At 200 units, selling at $59: **~$43.70 margin per unit / $8,740 gross margin**

---

## 3D Print Settings

| Setting | Value |
|---------|-------|
| Material | PLA+ (any brand) |
| Layer height | 0.2mm |
| Infill | 20% gyroid |
| Walls | 3 perimeters |
| Supports | Front bezel: none. Shell: tree supports for button holes only |
| Print time (per set) | ~2.5 hours |
| Estimated filament | ~28g |

## Assembly Order

1. Heat-set 4x M2 inserts into rear shell posts
2. Seat LILYGO T-Display-S3 into PCB pocket
3. Route USB-C cable path through rear slot
4. Connect LiPo battery to JST connector (if using battery)
5. Screw PCB down with 4x M2x8 screws
6. Snap front bezel onto shell (4x M2 screws through bezel into inserts)
7. Press-fit frosted acrylic lens into bezel window
8. Attach 4x rubber feet to base corners
9. Slide shell into angled base seat
10. Flash firmware via USB-C
