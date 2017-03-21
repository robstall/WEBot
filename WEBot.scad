use <../MyTriTrack/Wheels.scad>;
use <../SCADLib/servoS9001.scad>;
use <../SCADLib/rpi_bplus_v2.scad>;
use <../SCADLib/rpi_zero_w.scad>;
use <../SCADLib/batteries.scad>;
use <../SCADLib/std.scad>;

// Configurable values
wheelCenterPoints = [[0,0],[110,0],[55,50]];
wheelOffsetY = -22;
axelOffset = 10;

channelHeight = 10;
topFrameChannelWidth = 28;
bottomFrameChannelWidth = 20;

// Computed values
wheelBaseLen = wheelCenterPoints[1][0]-wheelCenterPoints[0][0];

//drawWheelbase();
//drawServo();
//drawDriveWheel();
//drawFrontCoasterWheel();
//drawRearCoasterWheel();
//drawSideFrame();

topSideFrameAssembly();

// Side frame
module sideFrame(center=true) {
  ct = center ? [-wheelCenterPoints[1][0]/2-axelOffset,0,-10] : [0,0,0];
  translate(ct) {
    rotate([90, 0, 0]) {
      bottonSideFrameAssembly();
      translate([wheelCenterPoints[2][0]+24,20,0])
        rotate([0, 0, 90]) 
          topSideFrameAssembly();
    }
  }
}

module drawSideFrame() {
  sideFrame();
}

module bottonSideFrameAssembly() {
  bottomFrameLen = wheelBaseLen + axelOffset*2;
  channel([bottomFrameLen, 20, 10]);
}

module topSideFrameAssembly() {
  topFrameLen = wheelCenterPoints[2][0]+5;
  channel([topFrameLen, 28, 10]);
  servoS9001(screws=true);
}  

// Wheel base reference triange
module wheelbase(center=true) {
  ct = center ? [-wheelCenterPoints[1][0]/2,0,-wheelOffsetY] : [0,0,-wheelOffsetY];
  color("black") 
    translate(ct) {
      difference() {
        offset(.2) polygon(wheelCenterPoints);
        offset(-.2) polygon(wheelCenterPoints);
      }
    }
}

module drawWheelbase() {
  rotate([90,0,0]) wheelbase();
}

// Drive
module drawServo() {
  translate([0, 0, wheelCenterPoints[2][1]]) 
    rotate([90, -90,0]) {
      servoS9001(screws=true, horn="coupler");
    }
}

module drawDriveWheel() {
  translate([0, 0, wheelCenterPoints[2][1]]) 
    rotate([90, 180,0]) {
      translate([0, 0, 29]) rotate([0, 180, 0]) driveWheel(axelLength=15);
    }
}

module drawFrontCoasterWheel() {
  tx = wheelCenterPoints[1][0] - wheelCenterPoints[2][0];
  translate([tx, wheelOffsetY, 0])
    rotate([90,00,0]) 
      coaster();
}

module drawRearCoasterWheel() {
  tx = wheelCenterPoints[0][0] - wheelCenterPoints[2][0];
  translate([tx, wheelOffsetY, 0])
    rotate([90,00,0]) 
      coaster();
}

// Other bits and pieces
module channel(v, wall=2.8) {
  d = [v[0]+.002, v[1]-wall*2, v[2]+.002];
  difference() {
    cube(v);
    translate([-.001, wall, wall+.001]) cube(d);
  }
}


