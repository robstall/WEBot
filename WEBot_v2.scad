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
hornOffset = 22; // How far out the end of the coupler is

// Calculated values
pb2s = pb2sBatterySize();
fid = [wcp[1][0]-wcp[0][0]+2*fwi,
       (pb2s[1]+4)/2,
       channelWallThickness]; // frame inner dimension

// Other constants
mmPerIn = 25.4;
$fn = 64;
drawForPrint = false;
halfModel = true;

if (drawForPrint) {
  //wbRef();
  //servo();
  //wheels();
  //sideFrame();
  //axelSocket();
  //pb2sBattery();
  bottomFrame(half=halfModel);
  //rowOfPins(l=50, n=6);
} else {
  sideFrameModel();
  //servoModel();
  //pb2sBatteryModel();
  //aa4BatteryHolderModel();
  //wheelsModel();
  //bottomFrameModel(half=halfModel);
}

//
// Components x, y (printing) translation
//
module servo(cutout=false) {
  t = [wcp[2][0] - wcp[0][0], wcp[2][1] - wcp[0][1], 0];
  r = [0,0,90];
  o = cutout ? 1 : 0;
  translate(t) rotate(r) servoS9001(screws=cutout, oversize=o, horn="coupler");
}

module wheels() {
  z = hornOffset;
  translate([wcp[0][0],wcp[0][1],z]) coaster();
  translate([wcp[1][0],wcp[1][1],z]) coaster();
  translate([wcp[2][0],wcp[2][1],z]) coaster();
}

// Axel sockets for coasters
module axelSocket() {
  axelSocketLen = hornOffset-channelWallThickness;
  od = mmPerIn/2;
  id = mmPerIn/4;
  difference() { 
    cylinder(d=od, h=axelSocketLen); 
    translate([0, 0, -.001]) cylinder(d=id, h=axelSocketLen+.002); 
  }
  translate([-2, -fcw/2+1, 0]) cube([4, 4, cd-channelWallThickness]);
  translate([-2, fcw/2-5, 0]) cube([4, 4, cd-channelWallThickness]);
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
  
  // Draw frame and cutout the servo and pin holse
  difference() {
    union() {
      difference() {
        translate(ft) channel(fcv);
        translate(cot) cube(cov);
        // Pin holes
        translate([-fwi,-fcw/5*2.5,0]) 
          rotate([-90,0,0]) 
            bottomFramePins(cutout=true);
      }
      translate(dt) rotate(dr) channel(dcv);
    }
    servo(cutout=true);
  }
  
  // Axel sockets for coasters
  translate(wcp[0]) translate([0,0,channelWallThickness-.001]) axelSocket();
  translate(wcp[1]) translate([0,0,channelWallThickness-.001]) axelSocket();
}

module bottomFrameHalf() {
  cwt = channelWallThickness;
  cube(fid);
  cube([fid[0], cwt, fcw/2]);
  
  endChannel = [fid[1], fcw, cwt];
  translate([fid[0]-cwt,0,0]) rotate([90,0,90]) cube(endChannel);
  translate([cwt,fid[1],0]) rotate([90,0,-90]) cube(endChannel);
  
  // Pins to hold it to side
  bottomFramePins();
}

module bottomFramePins(cutout=false) {
  cwt = channelWallThickness;
  translate([fwi, cwt, fcw/5]) 
    rotate([90, 0, 0]) 
      rowOfPins(l=fid[0]-fwi*2, n=5, cutout=cutout);
  translate([cwt, cwt, fcw-cwt*2]) 
    rotate([90, 0, 0]) 
      rowOfPins(l=fid[0]-cwt*2, n=2, cutout=cutout);
}

module bottomFrame(half=false) {
  bottomFrameHalf();
  if (!half) {
    translate([0, 2*fid[1], 0]) mirror([0,1,0]) bottomFrameHalf();
  }
}

//
// Components rotated to view and translated to position
//

module sideFrameModel() {
  rotate([90, 0, 0]) sideFrame();
}

module pb2sBatteryModel() {
  color("red")
    translate([0, 1, -7]) pb2sBattery();
}

module aa4BatteryHolderModel() {
  color("red")
    translate([44, 1, 1]) aa4BatteryHolder();
}

module servoModel() {
  color("blue") 
    rotate([90, 0, 0]) servo();
}

module wheelsModel() {
  color("blue")
    rotate([90, 0, 0]) wheels();
}

module bottomFrameModel(half=halfModel) {
  t = [-fwi, 0, -fcw/2];
  translate(t) bottomFrame(half=halfModel);
}

// draws a row of n pins within a bounding rect l by d with its ll corner at 0.0
module rowOfPins(l=0, n=1, h=channelWallThickness*2, d=3.2, cutout=false) {
  co = cutout ? 0.02 : 0;
  spc = n == 1 ? l : (l-d) / (n-1);
  for (i = [0:n-1]) {
    color("cyan") translate([d/2+spc*i, d/2, -co/2]) cylinder(h=h+co, d=d);
  }
}

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
  z = hornOffset;
  ct = center ? [-wcp[1][0]/2,0,z] : [0,0,z];
  color("black") 
    translate(ct) {
      difference() {
        offset(.2) polygon(wcp);
        offset(-.2) polygon(wcp);
      }
    }
}

// Tap pin
module tap(d=2.5, h=10) {
  color("cyan")
    cylinder(d=d, h=h);
}


