// ============================================================
// Claude Desk — Parametric Enclosure
// Designed for LILYGO T-Display-S3 (1.9" IPS, ESP32-S3)
// 3D Print: PLA+ recommended, 0.2mm layer height
// ============================================================
// USAGE:
//   render = 0  → all parts exploded view
//   render = 1  → front bezel only
//   render = 2  → rear shell only
//   render = 3  → angled base only
//   render = 4  → assembled preview

render = 0;

// ── Global parameters ───────────────────────────────────────

// PCB (LILYGO T-Display-S3)
pcb_w       = 67.8;
pcb_d       = 35.4;
pcb_h       = 1.6;
display_w   = 39.0;   // active display area
display_d   = 21.0;
display_x   = (pcb_w - display_w) / 2;   // centered on PCB
display_y   = (pcb_d - display_d) / 2;

// Enclosure walls
wall        = 2.0;
tolerance   = 0.3;    // fit tolerance for press fits

// Shell interior
shell_iw    = pcb_w + tolerance * 2;   // 68.4
shell_id    = pcb_d + tolerance * 2;   // 36.0
shell_ih    = 10.0;                    // interior height

// Outer dimensions
outer_w     = shell_iw + wall * 2;     // ~72.4 → round to 80 with bezel lip
outer_d     = shell_id + wall * 2;     // ~40.0 → round to 48 with bezel lip
bezel_w     = outer_w + 4;            // 76.4
bezel_d     = outer_d + 4;            // 44.0
bezel_h     = 4.0;

// USB-C cutout
usbc_w      = 10.0;
usbc_h      = 4.0;

// Button holes
btn_dia     = 4.2;

// Screw posts (M2)
post_dia    = 5.0;
post_h      = shell_ih - 1;
screw_dia   = 2.2;
insert_dia  = 3.2;   // M2 heat-set insert OD

// Base
base_w      = bezel_w + 10;
base_d      = bezel_d + 8;
base_h      = 8.0;
tilt_angle  = 20;    // degrees

// Battery pocket
bat_w       = 42.0;
bat_d       = 26.0;
bat_h       = 6.5;

// Rounding
rr          = 3.0;   // corner radius

// ── Color palette ────────────────────────────────────────────
c_shell  = [0.12, 0.08, 0.20];   // dark purple
c_bezel  = [0.10, 0.06, 0.18];   // deeper purple
c_base   = [0.07, 0.07, 0.10];   // near black
c_pcb    = [0.05, 0.25, 0.10];   // PCB green
c_lens   = [0.80, 0.80, 0.95, 0.4]; // frosted blue-white

// ── Utilities ────────────────────────────────────────────────

module rounded_box(w, d, h, r=rr) {
    hull() {
        for (x = [r, w-r]) for (y = [r, d-r]) {
            translate([x, y, 0]) cylinder(r=r, h=h, $fn=32);
        }
    }
}

module screw_post(h) {
    difference() {
        cylinder(d=post_dia, h=h, $fn=24);
        translate([0, 0, h - 4])
            cylinder(d=insert_dia, h=4.1, $fn=24); // heat-set insert pocket
    }
}

// ── Front Bezel ──────────────────────────────────────────────
module front_bezel() {
    color(c_bezel)
    difference() {
        // Main body
        rounded_box(bezel_w, bezel_d, bezel_h);

        // Display window cutout (centered)
        win_x = (bezel_w - display_w - 2) / 2;
        win_y = (bezel_d - display_d - 2) / 2;
        translate([win_x, win_y, -0.1])
            rounded_box(display_w + 2, display_d + 2, bezel_h + 0.2, r=1.5);

        // Acrylic lens recess (0.2mm tight — press fit)
        lens_x = win_x - 1.0;
        lens_y = win_y - 1.0;
        translate([lens_x, lens_y, bezel_h - 2.2])
            rounded_box(display_w + 4, display_d + 4, 2.3, r=1.8);

        // Shell lip pocket (bezel snaps over shell top rim)
        translate([2, 2, -0.1])
            rounded_box(bezel_w - 4, bezel_d - 4, 2.2);
    }
}

// ── Frosted Acrylic Lens (for reference — laser cut separately) ──
module acrylic_lens() {
    win_x = (bezel_w - display_w - 2) / 2;
    win_y = (bezel_d - display_d - 2) / 2;
    lens_x = win_x - 1.0;
    lens_y = win_y - 1.0;
    color(c_lens)
    translate([lens_x, lens_y, 0])
        rounded_box(display_w + 4, display_d + 4, 2.0, r=1.8);
}

// ── Rear Shell ───────────────────────────────────────────────
module rear_shell() {
    color(c_shell)
    difference() {
        // Outer body
        rounded_box(outer_w, outer_d, shell_ih + wall);

        // Interior pocket
        translate([wall, wall, wall])
            rounded_box(shell_iw, shell_id, shell_ih + 0.1, r=rr-wall);

        // USB-C slot — centered on rear wall (y = 0 face)
        translate([(outer_w - usbc_w) / 2, -0.1, wall + 2])
            cube([usbc_w, wall + 0.2, usbc_h]);

        // Button hole LEFT (BTN0 — brightness)
        translate([-0.1, outer_d / 2 - 6, wall + 4])
            rotate([0, 90, 0])
                cylinder(d=btn_dia, h=wall + 0.2, $fn=24);

        // Button hole RIGHT (BTN1 — refresh)
        translate([-0.1, outer_d / 2 + 6, wall + 4])
            rotate([0, 90, 0])
                cylinder(d=btn_dia, h=wall + 0.2, $fn=24);

        // Battery pocket (rear, against back wall)
        translate([(outer_w - bat_w) / 2, wall, wall])
            cube([bat_w, bat_d, bat_h]);
    }

    // M2 screw posts (4 corners, inset 5mm)
    translate([0, 0, wall]) {
        for (x = [5, outer_w - 5 - post_dia/2])
        for (y = [5, outer_d - 5 - post_dia/2])
            translate([x, y, 0]) screw_post(post_h);
    }
}

// ── Angled Base ──────────────────────────────────────────────
module angled_base() {
    color(c_base)
    difference() {
        // Wedge — flat bottom, angled top surface
        hull() {
            // Front edge (low)
            translate([0, 0, 0])
                rounded_box(base_w, 5, 2);
            // Rear edge (high — creates tilt)
            translate([0, base_d - 5, tan(tilt_angle) * base_d])
                rounded_box(base_w, 5, 2);
        }

        // Shell seat pocket (centered on top)
        seat_x = (base_w - outer_w) / 2;
        seat_y = (base_d - outer_d) / 2 + 4;
        seat_z = tan(tilt_angle) * (seat_y + outer_d / 2) - 1;
        translate([seat_x, seat_y, seat_z])
            rotate([tilt_angle, 0, 0])
                rounded_box(outer_w + tolerance, outer_d + tolerance, 4);

        // Rubber feet recesses (4 corners, 10mm dia, 1mm deep)
        for (x = [8, base_w - 8]) for (y = [8, base_d - 8])
            translate([x, y, -0.1])
                cylinder(d=10, h=1.2, $fn=32);

        // Cable channel — rear bottom
        translate([(base_w - 14) / 2, base_d - wall - 0.1, 0])
            cube([14, wall + 0.2, 6]);
    }
}

// ── PCB placeholder (for fit-check) ─────────────────────────
module pcb_placeholder() {
    color(c_pcb) {
        cube([pcb_w, pcb_d, pcb_h]);
        // Display bump
        translate([display_x, display_y, pcb_h])
            cube([display_w, display_d, 2.5]);
    }
}

// ── Render modes ─────────────────────────────────────────────

if (render == 0) {
    // Exploded view — all parts offset vertically
    translate([0, 0, 80]) acrylic_lens();
    translate([0, 0, 60]) front_bezel();
    translate([4, 4, 35]) pcb_placeholder();
    translate([0, 0, 15]) rear_shell();
    translate([-5, -4, 0]) angled_base();
}

if (render == 1) front_bezel();
if (render == 2) rear_shell();
if (render == 3) angled_base();

if (render == 4) {
    // Assembled preview
    base_seat_z = tan(tilt_angle) * (base_d/2) - 1;
    angled_base();
    translate([5, 4, base_seat_z])
        rotate([-tilt_angle, 0, 0]) {
            rear_shell();
            translate([wall + tolerance, wall + tolerance, wall])
                pcb_placeholder();
            translate([2, 2, shell_ih + wall - 2])
                front_bezel();
            translate([2, 2, shell_ih + wall + bezel_h - 2.2])
                acrylic_lens();
        }
}
