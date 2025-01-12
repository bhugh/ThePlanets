import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Graphics;


//var save_points = {};
var save_big_small = null;


function drawOrbits3 (myDc, pp, scale, xc,yc, big_small, myWhh, color) {

 //System.println ("starting drawOrbits3 with " + color);
 //System.println ("starting drawOrbits3 with " + color == Graphics.COLOR_WHITE );


   
    //var full_whh = WHHs[0];
    //
    //var whh = WHHs[1];
    //var small_whh = WHHs[2];

    /* var per = 50;
    if (big_small == 0) {per = 10;}
    if (big_small == 1) {per = 20;}
    */
    
    myDc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    myDc.setColor(color, Graphics.COLOR_TRANSPARENT);
    myDc.setPenWidth(1);
    
    for (var j=0;j<myWhh.size(); j++) {
     var key = myWhh[j];
       //if (!key.equals("Sun") && (big_small==0 || small_myWhh.indexOf(key)==-1))
       if (!key.equals("Sun") && !key.equals("Moon"))
       {


            var X = pp[key];
            if (X==null) {continue;}


            //System.println("X: " + X);
            //System.println ("X = " + X);
            
            
            //make the planet tracks a little bit darker
            if  (planetSizeFactor < 1) {
               for (var i=0;i<2; i++) {
                  for (var k=0; k<2;k++){
                     myDc.drawPoint (scale*X[0] + xc + k, scale*X[1] + yc + i);
                  }
               }
            } else {
               var randadd = Math.rand()%2;
               myDc.drawPoint (scale*X[0] + xc, scale*X[1] + yc);
               myDc.drawPoint (scale*X[0] + xc + randadd, scale*X[1] + yc + 1 - randadd);
            }

            
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

      const randiv = 7142857.1f; //== ranmult^2/(2* 1-ranadd);
      const ranmult = 1000;
      const ranadd = .93f;

function drawFuzzyEllipse (myDc, swidth, sheight, xc, yc, A as Lang.float, B as Lang.float) {
        //var r = (A * B) / Math.sqrt((B * Math.cos(thetaRad))^2 + (A * Math.sin(thetaRad))^2);
        if (A> swidth && B > sheight) { return;}
         //var fact = A/(myDc.getHeight()).toFloat() * 30.0;
         //var fact = A/20000.0;

      var step =  A/2.0f;  
      if ((step == 0)) {step = 1;} //avoid div by zero issues 
      
      var start = 0;
      //if (type == :low) {step = (Math.rand()%150)/100.0 + 0.5; start = (Math.rand()%314).toFloat(); }
      //if (step<25 && A > 3  && type == :high) { step = 25; }

      if (step<25 && A > 3) { step = 25; } //as A gets small sometimes it doesn't drawn enough  asteroids to be convincing
      //System.println("FuzzyEllipse Step: " + step + " start" + start + "A:" + A + " B:" + B);
      //if (step>200) {step=200;}

      for (var theta = start; theta < 2 * Math.PI;theta += Math.PI * 2.0 / step) {
         //var adder = 0;
         //if (type == :low) {adder = Math.rand()%1000/1000.0 * Math.PI * 2;}
         var mct = Math.cos(theta);
         var mst = Math.sin(theta);
         //var ranend = Math.rand()%5;
         //for (var i = 0; i < ranend; i++) {
            var ran = Math.rand()%ranmult;
            var addme =ranadd + (ran*ran)/randiv;
            var x = xc + (A*addme) * mct;
            var y = yc + (B*addme) * mst;
            myDc.drawPoint(x,y);
            if (Math.rand()%2==0) {myDc.drawPoint(x+Math.rand()%7-3,y+Math.rand()%6-3);}
            if (Math.rand()%2==0) {myDc.drawPoint(x+Math.rand()%7-3,y+Math.rand()%6-3);}
         //}
         //deBug("[theta, Math.cos(theta), Math.sin(theta) x, y, step, A, B]", [theta, Math.cos(theta), Math.sin(theta), x, y, step, A, B]);
         //if (x<0|| y<0 || x>swidth || y>sheight || !isSafeValue(x) || !isSafeValue(y) ) {continue;}
         //System.println("Aster: " + x + ":" + y);
         
         //if (Math.rand()%3==0) {myDc.drawPoint(x+1,y);}
         //myDc.drawPoint(x+1,y+1);
         //if (Math.rand()%3==0) {myDc.drawPoint(x,y+1);}

         //System.println("Got here...");
      }
}
