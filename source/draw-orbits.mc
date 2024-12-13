import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Graphics;


var save_points = {};
var save_big_small = null;


function drawOrbits3 (dc, pp, scale, xc,yc, big_small, WHHs, color) {

 //System.println ("starting drawOrbits3 with " + color);
 //System.println ("starting drawOrbits3 with " + color == Graphics.COLOR_WHITE );



    var full_whh = WHHs[0];
    var whh = WHHs[1];
    var small_whh = WHHs[2];

    var per = 50;
    if (big_small == 0) {per = 10;}
    if (big_small == 1) {per = 20;}
    
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(1);
    for (var j=0;j<whh.size(); j++) {
     var key = whh[j];
       //if (!key.equals("Sun") && (big_small==0 || small_whh.indexOf(key)==-1))
       if (!key.equals("Sun"))
       {


            var X = pp[key];
            //System.println("X: " + X);
            //System.println ("X = " + X);
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.drawPoint (scale*X[0] + xc, scale*X[1] + xc);

            
       }
    }
}
