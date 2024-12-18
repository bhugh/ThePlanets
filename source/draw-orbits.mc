import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Graphics;


var save_points = {};
var save_big_small = null;


function drawOrbits3 (myDc, pp, scale, xc,yc, big_small, WHHs, color) {

 //System.println ("starting drawOrbits3 with " + color);
 //System.println ("starting drawOrbits3 with " + color == Graphics.COLOR_WHITE );


   
    //var full_whh = WHHs[0];
    var whh = WHHs[1];
    //var small_whh = WHHs[2];

    /* var per = 50;
    if (big_small == 0) {per = 10;}
    if (big_small == 1) {per = 20;}
    */
    
    myDc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    myDc.setColor(color, Graphics.COLOR_TRANSPARENT);
    myDc.setPenWidth(1);
    
    for (var j=0;j<whh.size(); j++) {
     var key = whh[j];
       //if (!key.equals("Sun") && (big_small==0 || small_whh.indexOf(key)==-1))
       if (!key.equals("Sun") && !key.equals("Moon"))
       {


            var X = pp[key];
            if (X==null) {continue;}


            //System.println("X: " + X);
            //System.println ("X = " + X);
            
            myDc.drawPoint (scale*X[0] + xc, scale*X[1] + yc);

            
       }
    }
  

}

/*
function drawFuzzyEllipse (myDc, swidth, sheight, xc,yc, A, B, type) {
        //var r = (A * B) / Math.sqrt((B * Math.cos(thetaRad))^2 + (A * Math.sin(thetaRad))^2);
        if (A> swidth && B > sheight) { return;}
         var fact = A/(myDc.getHeight()).toFloat() * 30.0;
         //if (fact<5){fact = 5;}

      var step =  A/2.0;
      if (type == :low) {step = step/100.0;}
      System.println("Step: " + step + " fact" + fact);
      if (step>200) {step=200;}

      for (var theta = 0; theta < 2 * Math.PI;theta += Math.PI * 2.0 / step) {
         var adder = 0;
         if (type == :low) {adder = Math.rand()%1000/1000.0 * Math.PI * 2;}
         var x = xc + A * Math.cos(theta+adder) + (Math.rand()%100/100.0) * fact;
         var y = yc + B * Math.sin(theta+adder)+ (Math.rand()%100/100.0) * fact;
         if (x<0|| y<0 || x>swidth || y>sheight) {continue;}
         myDc.drawPoint(x,y);
      }
} */

function drawFuzzyEllipse (myDc, swidth, sheight, xc,yc, A, B, type) {
        //var r = (A * B) / Math.sqrt((B * Math.cos(thetaRad))^2 + (A * Math.sin(thetaRad))^2);
        if (A> swidth && B > sheight) { return;}
         //var fact = A/(myDc.getHeight()).toFloat() * 30.0;
         //var fact = A/20000.0;

      var step =  A/2.0;   
      var start = 0;
      if (type == :low) {step = (Math.rand()%150)/100.0 + 0.5; start = (Math.rand()%314).toFloat(); }
      if (step<25 && A > 3  && type == :high) { step = 25; }
      //System.println("Step: " + step + " start" + start + "");
      //if (step>200) {step=200;}

      for (var theta = start; theta < 2 * Math.PI;theta += Math.PI * 2.0 / step) {
         //var adder = 0;
         //if (type == :low) {adder = Math.rand()%1000/1000.0 * Math.PI * 2;}
         var ran = Math.rand()%1000;
         var addme =.95 + (ran*ran)/10000000.0;
         var x = xc + (A*addme) * Math.cos(theta);
         var y = yc + (B*addme) * Math.sin(theta);
         if (x<0|| y<0 || x>swidth || y>sheight) {continue;}
         System.println("Aster: " + x + ":" + y);
         myDc.drawPoint(x,y);
      }
}
