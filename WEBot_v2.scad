use <../MyTriTrack/Wheels.scad>;
use <../SCADLib/servoS9001.scad>;
use <../SCADLib/rpi_bplus_v2.scad>;
use <../SCADLib/rpi_zero_w.scad>;
use <../SCADLib/batteries.scad>;
use <../SCADLib/std.scad>;

// Configurable values
wcp = [[0,0],[110,0],[32,42]]; // wheel center points
dcw = 28; // drive channel width
fcw = 20; // frame channel width
cd = 10; // channel depth
fwi = 10; // wheel inset from frame ends
channelWallThickness = 2.8;

// Calculated values

// Drawing for print
wbRef();
servo();
wheels();
sideFrame();

//
// Components x, y (printing) translation
//
module servo(cutout=false) {
  t = [wcp[2][0] - wcp[0][0], wcp[2][1] - wcp[0][1], 0];
  r = [0,0,90];
  o = cutout ? 1 : 0;
  translate(t) rotate(r) servoS9001(oversize=o);
}

module wheels() {
  z = 22;
  translate([wcp[0][0],wcp[0][1],z]) coaster();
  translate([wcp[1][0],wcp[1][1],z]) coaster();
  translate([wcp[2][0],wcp[2][1],z]) coaster();
}

module sideFrame() {
  // Horizontal frame member
  fcl = wcp[1][0] - wcp[0][0] + 2*fwi; // Frame channel length
  fcv = [fcl, fcw, cd];
  ft = [-fwi, -fcw/2, 0];
  
  // Vertical frame member
  dcl = wcp[2][1] - wcp[0][1] - fcw/2 + 20;
  dcv = [dcl, dcw, cd];
  dr = [0, 0, 90];
  dt = [wcp[2][0] + dcw/2, fcw/2, 0];
  
  // The frame wall cutout for the servo screws
  cwt = channelWallThickness;
  cov = [dcw - 2*cwt, cwt + .2, cd - cwt];
  cot = [wcp[2][0] - dcw/2 + cwt, fcw/2-cwt-.1, cwt+.001];
  
  difference() {
    translate(ft) channel(fcv);
    translate(cot) cube(cov);
  }
  translate(dt) rotate(dr) channel(dcv);
}

//
// Components rotated to view
//

//
// Other bits and pieces
//

// "channel iron"
module channel(v, wall=channelWallThickness) {
  d = [v[0]+.002, v[1]-wall*2, v[2]+.002];
  difference() {
    cube(v);
    translate([-.001, wall, wall+.001]) cube(d);
  }
}

// Wheel base reference triange
module wbRef(center=false) {
  z = 17;
  ct = center ? [-wcp[1][0]/2,0,z] : [0,0,z];
  color("black") 
    translate(ct) {
      difference() {
        offset(.2) polygon(wcp);
        offset(-.2) polygon(wcp);
      }
    }
}


