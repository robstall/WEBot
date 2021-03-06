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
pinDiam = 4;

// Calculated values
pb2s = pb2sBatterySize();
fid = [wcp[1][0]-wcp[0][0]+2*fwi,
       (pb2s[1]+8)/2,
       channelWallThickness]; // frame inner dimension for half model

bottomCutoutTriangleOnePoints = [
  [0, 0],
  [fid[0]/2*0.65, 0],
  [(fid[0]/2*0.65)/2, fid[1]*0.6]
];

bottomCutoutTriangleTwoPoints = [
  [0, 0],
  [fid[0]/10-1, fid[1]/3],
  [0, fid[1]/3]
];

// Other constants
mmPerIn = 25.4;
$fn = 64;
drawForPrint = false;
halfModel = false;

if (drawForPrint) {
  //wbRef();
  //servo();
  //wheels();
  //sideFrame();
  //axelSocket();
  //pb2sBattery();
  //bottomFrame(half=halfModel);
  //rowOfPins(l=50, n=6);
  //axel();
  coaster();
} else {
  sideFrameModel();
  servoModel();
  wheelsModel(dax=true);
  if (!halfModel) {
    translate([0, fid[1]*2, 0]) {
      mirror([0,1,0]) {
        sideFrameModel();
        servoModel();
        wheelsModel(dax=true);
      }
    }
  }
  //pb2sBatteryModel();
  //aa4BatteryHolderModel();
  bottomFrameModel(half=halfModel);
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

module wheels(dax=false) {
  z = hornOffset;
  translate([wcp[0][0],wcp[0][1],z]) {
    coaster();
    if (dax) {
      translate([0,0,8]) rotate([0,180,0]) axel();
    }
  }
  translate([wcp[1][0],wcp[1][1],z]) {
    coaster();
    if (dax) {
      translate([0,0,8]) rotate([0,180,0]) axel();
    }
  }
  translate([wcp[2][0],wcp[2][1],z+7]) rotate([180,0,0]) driveWheel();
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

module axel() {
  axelSocketLen = hornOffset-channelWallThickness;
  cylinder(d=mmPerIn/2, h=1); 
  cylinder(d=mmPerIn/4, h=axelSocketLen-channelWallThickness+6);
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
        // Pin holes for bottom frame piece
        translate([-fwi,-fcw/5*2.5,0]) 
          rotate([-90,0,0]) 
            bottomFramePins(cutout=true);
      }
      translate(dt) rotate(dr) channel(dcv);
    }
    // Pin holes for mounting things to frame
    sideFrameMountingPinHoles();
    servo(cutout=true);
  }
  
  // Axel sockets for coasters
  translate(wcp[0]) translate([0,0,channelWallThickness-.001]) axelSocket();
  translate(wcp[1]) translate([0,0,channelWallThickness-.001]) axelSocket();
}

module sideFrameMountingPinHoles() {
  fcl = wcp[1][0] - wcp[0][0] + 2*fwi; // Frame channel length
  z = cd/2-pinDiam/2;
  translate([fcl-75,fcw/2+1,z]) rotate([90,0,0]) rowOfPins(l=60, n=7, cutout=true);
  translate([-5,fcw/2+1,z]) rotate([90,0,0]) rowOfPins(l=20, n=3, cutout=true);
  translate([17,fcw-5,z]) rotate([90,0,90]) rowOfPins(l=40, n=5, cutout=true);
  translate([41,fcw-5,z]) rotate([90,0,90]) rowOfPins(l=40, n=5, cutout=true);
}

module bottomFrameHalf() {
  cwt = channelWallThickness;
  
  difference() {
    cube(fid);
   
    // Three larger triangles
    t1 = bottomCutoutTriangleOnePoints;
    t1w = t1[1][0] - t1[0][0];
    t1h = t1[2][1] - t1[0][1];
    t1o = .4*22;
    translate([0+t1o, 0+t1o, -1]) rpolygon(t1, r=2, h=3);
    translate([fid[0]-t1w-t1o, 0+t1o, -1]) rpolygon(t1, r=2, h=3);
    translate([fid[0]/2-t1w/2, t1h+t1o, 5]) rotate([180,0,0]) rpolygon(t1, r=2, h=3);
  
    // Two triangles on ends
    t2 = bottomCutoutTriangleTwoPoints;
    translate([t1o, t1o*2+cwt*2, -1]) rpolygon(t2, r=2, h=3);
    translate([fid[0]-cwt*3, t1o*2+cwt*2, 5]) rotate([0,180,0]) rpolygon(t2, r=2, h=3);
  }
  
  // Side rail
  cube([fid[0], cwt, fcw/2]); 
  
  // Upper pin mount
  translate([cwt,0,0]) cube([7,cwt,fcw]);
  translate([fid[0]-7-cwt,0,0]) cube([7,cwt,fcw]);
  
  // End pieces
  endChannel = [fid[1], fcw, cwt];
  translate([fid[0]-cwt,0,0]) rotate([90,0,90]) cube(endChannel);
  translate([cwt,fid[1],0]) rotate([90,0,-90]) cube(endChannel);
  
  // Pins to hold it to side
  bottomFramePins();
}

module bottomFramePins(cutout=false) {
  cwt = channelWallThickness;
  translate([fwi, cwt, cwt]) 
    rotate([90, 0, 0]) 
      rowOfPins(l=fid[0]-fwi*2, n=5, cutout=cutout);
  translate([cwt, cwt, fcw-cwt*3]) 
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
    translate([0, 4, -9]) pb2sBattery();
}

module aa4BatteryHolderModel() {
  color("red")
    translate([44, 3, 1]) aa4BatteryHolder();
}

module servoModel() {
  color("blue") 
    rotate([90, 0, 0]) servo();
}

module wheelsModel(dax=false) {
  color("blue")
    rotate([90, 0, 0]) wheels(dax=dax);
}

module bottomFrameModel(half=halfModel) {
  t = [-fwi, 0, -fcw/2];
  translate(t) bottomFrame(half=halfModel);
}

// draws a row of n pins within a bounding rect l by d with its ll corner at 0.0
module rowOfPins(l=0, n=1, h=channelWallThickness*2, d=pinDiam, cutout=false) {
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


