// ============================================================
//  ESP32 LED controller enclosure (protoboard, barrel in, JST out)
//  Units: mm.  Render F6, export STL per part (see `part`).
//
//  Layout (top view, X to the right):
//   -X wall : barrel power jack + JST cable slot  (terminal-block end)
//   +X wall : micro-USB opening                   (ESP32 end)
//   Board sits on 4 M2 standoffs; lid held by 4 M3 corner posts.
//
//  Everything marked  ** MEASURE **  is an estimate: check it
//  against your parts and tweak before printing.
// ============================================================

in = 25.4;
$fn = 48;

/* [Which part to output] */
// "print"               = box + lid laid out for printing (lid flipped)
// "box"                 = box only, "lid" = lid only
// "preview"             = assembled view with ghost board, lid lifted
// "board"               = protoboard + ESP32 only (check model before enclosure)
// "standoff_test"       = thin slab + 4 standoffs only (export/print this)
// "standoff_test_ghost" = same slab with transparent board overlay for preview
part = "preview";

/* [Protoboard] */
board_l          = 68.68;       // X length (measured)
board_w          = 48.70;       // Y width  (measured)
board_t          = 1.6;
board_hole_inset = 2.0;         // corner hole center from board edges (measured)
comp_h           = 15.875;    // tallest thing above board top (headers/terminal screws)

/* [Board standoffs (M2)] */
standoff_h          = 7;    // room for solder joints + wiring UNDER the board
standoff_od         = 5;
standoff_hole_d     = 1.8;  // pilot for self-tapping M2 in PETG (use ~3.2 for M2 heat-set insert)
standoff_hole_depth = 7.5;  // fits M2x8 (M2x6 also fine)

/* [Enclosure shell] */
wall        = 2.4;
floor_t     = 2.4;
corner_r    = 3;
top_clear   = 2;      // air gap above tallest component
term_gap    = 14;     // board edge -> -X wall: wire bend room for terminal blocks
end_gap     = 8;      // board edge -> +X wall: needed so the corner lid posts clear the board
side_gap    = 1.5;    // board edge -> long walls

/* [Lid + lid screws (M3 flush / countersunk)] */
lid_t           = 3;
lip_h           = 2;
lip_t           = 1.6;
lip_tol         = 0.3;   // lip clearance to inner wall
post_od         = 7.5;
use_heat_set    = false; // false: M3 threads directly into printed post
post_hole_self  = 2.6;   // M3 self-tap in PETG
post_hole_insert= 4.2;   // M3 heat-set insert
post_hole_depth = 10;    // use M3 x 12 (3 lid + ~9 into post)
lid_hole_clear  = 3.4;
csk_d           = 6.4;   // countersink dia for flush head ** MEASURE head **

/* [Barrel panel-mount jack (-X wall)] */
barrel_d             = 11.1;  // 7/16" max thread dia
barrel_clear         = 0.4;
barrel_thread_len    = 1.6;   // 1/16": wall must be <= this at the jack
barrel_flange        = 1.6;   // 1/16" flange radius past thread (sits on outside face)
barrel_nut_pocket_d  = 20;    // inside-face pocket that thins wall to thread length
barrel_y             = 19;    // from inner wall (interior Y)
barrel_z_above_board = 5.5;   // jack center above board top

/* [JST-SM output cable slot (-X wall)] */
// Slot is sized so a crimped JST-SM housing can pass through
jst_slot_w           = 13;
jst_slot_h           = 8;
jst_z_above_board    = 5;

/* [Micro-USB opening (+X wall)] */
usb_w            = 15;
usb_h            = 10.5;
usb_z_above_board= 8;    // ** MEASURE ** USB center above board top (depends on header height)
usb_y_offset     = 0;    // shift if ESP32 isn't centered across the board

/* [ESP32 dev board (for preview ghost — ** MEASURE **)] */
hole_pitch       = 2.54;
show_board_holes = false;   // hole grid CSG is slow; enable only when needed
esp_l            = 55.0;    // PCB length (USB end to antenna end)
esp_w            = 28.2;    // PCB width
esp_t            = 1.2;     // PCB thickness
esp_usb_protrude = 0.5;     // how far USB shell sticks past PCB edge (+X)
esp_usb_phys_w   = 7.5;     // micro-USB shell width
esp_usb_phys_h   = 3.2;     // micro-USB shell height above PCB
esp_overhang     = 3.175;   // ESP32 PCB hangs past +X board edge (measured)
esp_cols_left    = 4;       // protoboard cols visible to the left of the ESP32

// ---------------- derived ----------------
// hole-grid origin (mirrors protoboard module so esp_py lines up exactly)
_hole_ny = round(board_w / hole_pitch) - 1;
_hole_y0 = (board_w - (_hole_ny - 1) * hole_pitch) / 2;
esp_px   = board_l - esp_l + esp_overhang;
esp_py   = _hole_y0 + esp_cols_left * hole_pitch;

int_l   = term_gap + board_l + end_gap;
int_w   = board_w + 2 * side_gap;
int_h   = standoff_h + board_t + comp_h + top_clear;
outer_l = int_l + 2 * wall;
outer_w = int_w + 2 * wall;
box_h   = floor_t + int_h;

bx = term_gap;   // board origin in interior coords
by = side_gap;

pin = post_od / 2 - 0.5;   // post centers overlap the walls slightly
post_pts = [[pin, pin], [int_l - pin, pin],
            [pin, int_w - pin], [int_l - pin, int_w - pin]];

standoff_pts = [
  [bx + board_hole_inset,           by + board_hole_inset],
  [bx + board_l - board_hole_inset, by + board_hole_inset],
  [bx + board_hole_inset,           by + board_w - board_hole_inset],
  [bx + board_l - board_hole_inset, by + board_w - board_hole_inset]];

// ---------------- helpers ----------------
module rbox(l, w, h, r) {
  hull() for (x = [r, l - r], y = [r, w - r])
    translate([x, y, 0]) cylinder(r = r, h = h);
}

// rounded slot cut along +X, centered on y,z = 0, from x=0 to len
module rslot_x(w, h, r, len) {
  hull() for (sy = [-1, 1], sz = [-1, 1])
    translate([0, sy * (w / 2 - r), sz * (h / 2 - r)])
      rotate([0, 90, 0]) cylinder(r = r, h = len);
}

// ---------------- box ----------------
module box() {
  post_hole = use_heat_set ? post_hole_insert : post_hole_self;
  z_board_top = floor_t + standoff_h + board_t;   // outer coords

  difference() {
    union() {
      difference() {
        rbox(outer_l, outer_w, box_h, corner_r);
        translate([wall, wall, floor_t]) cube([int_l, int_w, int_h + 1]);
      }
      // posts + standoffs (interior coords -> outer)
      translate([wall, wall, floor_t]) {
        for (p = post_pts) translate([p[0], p[1], 0]) cylinder(d = post_od, h = int_h);
        for (p = standoff_pts) translate([p[0], p[1], 0]) cylinder(d = standoff_od, h = standoff_h);
      }
    }

    // lid screw holes
    translate([wall, wall, floor_t])
      for (p = post_pts)
        translate([p[0], p[1], int_h - post_hole_depth]) cylinder(d = post_hole, h = post_hole_depth + 1);

    // M2 standoff pilot holes (extend slightly into floor)
    translate([wall, wall, floor_t])
      for (p = standoff_pts)
        translate([p[0], p[1], standoff_h - standoff_hole_depth]) cylinder(d = standoff_hole_d, h = standoff_hole_depth + 1);

    // barrel jack: through hole + inside pocket thinning wall to thread length
    translate([-1, wall + barrel_y, z_board_top + barrel_z_above_board]) {
      rotate([0, 90, 0]) cylinder(d = barrel_d + barrel_clear, h = wall + 2);
    }
    translate([barrel_thread_len, wall + barrel_y, z_board_top + barrel_z_above_board])
      rotate([0, 90, 0]) cylinder(d = barrel_nut_pocket_d, h = wall - barrel_thread_len);

    // JST cable slot
    translate([-1, wall + int_w - barrel_y, z_board_top + jst_z_above_board])
      rslot_x(jst_slot_w, jst_slot_h, 1.5, wall + 2);

    // micro-USB opening
    translate([wall + int_l - 1, wall + int_w / 2 + usb_y_offset, z_board_top + usb_z_above_board])
      rslot_x(usb_w, usb_h, 2, wall + 2);
  }
}

// ---------------- lid ----------------
// Installed orientation: plate z in [0, lid_t], lip hangs below (z<0).
module lid() {
  ci = int_l - 2 * lip_tol;
  cw = int_w - 2 * lip_tol;
  csk_depth = (csk_d - lid_hole_clear) / 2;

  difference() {
    union() {
      rbox(outer_l, outer_w, lid_t, corner_r);
      translate([wall + lip_tol, wall + lip_tol, -lip_h])
        difference() {
          cube([ci, cw, lip_h + 0.01]);
          translate([lip_t, lip_t, -1]) cube([ci - 2 * lip_t, cw - 2 * lip_t, lip_h + 2]);
        }
    }
    for (p = post_pts) translate([wall + p[0], wall + p[1], 0]) {
      translate([0, 0, -lip_h - 1]) cylinder(d = lid_hole_clear, h = lid_t + lip_h + 2);
      translate([0, 0, lid_t - csk_depth]) cylinder(d1 = lid_hole_clear, d2 = csk_d + 0.02, h = csk_depth + 0.01);
      // notch the lip around the corner posts
      translate([0, 0, -lip_h - 1]) cylinder(r = post_od / 2 + 0.3, h = lip_h + 1);
    }
  }
}

// ---------------- board detail modules (used in preview) ----------------
module protoboard() {
  nx = round(board_l / hole_pitch) - 1;
  ny = round(board_w / hole_pitch) - 1;
  x0 = (board_l - (nx - 1) * hole_pitch) / 2;
  y0 = (board_w - (ny - 1) * hole_pitch) / 2;
  difference() {
    color([0.13, 0.50, 0.13], 0.88) cube([board_l, board_w, board_t]);
    // hole grid (disabled by default — enable show_board_holes when needed)
    if (show_board_holes)
      for (c = [0:nx-1], r = [0:ny-1])
        translate([x0 + c * hole_pitch, y0 + r * hole_pitch, -0.5])
          cylinder(d = 1.0, h = board_t + 1, $fn = 6);
    // M2 corner mounting holes
    for (dx = [board_hole_inset, board_l - board_hole_inset],
         dy = [board_hole_inset, board_w - board_hole_inset])
      translate([dx, dy, -0.5]) cylinder(d = 2.5, h = board_t + 1, $fn = 12);
  }
}

module esp32_detail() {
  translate([esp_px, esp_py, board_t]) {
    // PCB
    color([0.05, 0.05, 0.40], 0.85) cube([esp_l, esp_w, esp_t]);
    // micro-USB connector at the +X end
    color("silver", 0.9)
      translate([esp_l - 3, (esp_w - esp_usb_phys_w) / 2, esp_t])
        cube([3 + esp_usb_protrude, esp_usb_phys_w, esp_usb_phys_h]);
    // metal antenna can at the -X end
    color([0.75, 0.75, 0.75], 0.85)
      translate([0, (esp_w - 16) / 2, esp_t])
        cube([16, 16, 3.5]);
  }
}

// ---------------- preview ghosts ----------------
module ghost() {
  translate([wall + bx, wall + by, floor_t + standoff_h]) {
    protoboard();
    esp32_detail();
    color("orange", 0.07) translate([0, 0, board_t]) cube([board_l, board_w, comp_h]);
  }
}

// ---------------- output ----------------
if (part == "box") box();
else if (part == "lid") translate([0, 0, lid_t]) rotate([180, 0, 0]) translate([0, -outer_w, 0]) lid();
else if (part == "preview") {
  box();
  ghost();
  translate([0, -10, lid_t]) rotate([180, 0, 0]) lid();
} else if (part == "board") {
  protoboard();
  esp32_detail();
} else if (part == "standoff_test") {
  // Slab is exactly board size — place the real board flush with the slab edges.
  _test_pts = [for (p = standoff_pts) [p[0] - bx, p[1] - by]];
  _tb = 6;  // border width — keeps full material under each standoff base
  difference() {
    union() {
      cube([board_l, board_w, floor_t]);
      for (p = _test_pts)
        translate([p[0], p[1], floor_t]) cylinder(d = standoff_od, h = standoff_h);
    }
    // hollow out center
    translate([_tb, _tb, -1]) cube([board_l - 2*_tb, board_w - 2*_tb, floor_t + 2]);
    for (p = _test_pts)
      translate([p[0], p[1], floor_t + standoff_h - standoff_hole_depth])
        cylinder(d = standoff_hole_d, h = standoff_hole_depth + 1);
  }
} else if (part == "standoff_test_ghost") {
  _test_pts = [for (p = standoff_pts) [p[0] - bx, p[1] - by]];
  _tb = 6;
  difference() {
    union() {
      cube([board_l, board_w, floor_t]);
      for (p = _test_pts)
        translate([p[0], p[1], floor_t]) cylinder(d = standoff_od, h = standoff_h);
    }
    translate([_tb, _tb, -1]) cube([board_l - 2*_tb, board_w - 2*_tb, floor_t + 2]);
    for (p = _test_pts)
      translate([p[0], p[1], floor_t + standoff_h - standoff_hole_depth])
        cylinder(d = standoff_hole_d, h = standoff_hole_depth + 1);
  }
  translate([0, 0, floor_t + standoff_h])
    color([0.13, 0.50, 0.13], 0.35) cube([board_l, board_w, board_t]);
} else {
  box();
  // lid flipped (lip up, countersinks on the bed), placed beside the box
  translate([0, -10, lid_t]) rotate([180, 0, 0]) lid();
}
