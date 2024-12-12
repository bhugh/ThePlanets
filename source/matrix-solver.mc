import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Graphics;


//elipses have the generic form: Ax1^2 + Bx1y1 + Cy1^2 + Dx1 + Ey1 + F = 0
//we are going to take 6 points on an ellipse, generate 6 such equations
//solve for A, B, C, D, E, F and then plot the ellipse.
   
//p is an array of 6 points on an ellipse (each point [x,y])
function generateEllipseCoefficients(p) {
    var ret = [0,0,0,0,0,0];
    var max = 0;
    for (var i = 0; i< p.size(); i++) {
        System.println(p);
        var x = p[i][0];
        var y = p[i][1];
        var r = [0,0,0,0,0,0];
        r[0]= x*x;
        r[1] = x*y;
        r[2]= y*y;
        r[3] = x;
        r[4] = y;
        r[5] = -1;
        ret[i] = r;

        var mx = r[0] + r[2];
        if (mx > max) {mx=max;}
    }
    max = Math.sqrt(max); //largest point, approx of major radius
    System.println("eCoeff! " + ret);
    return [max,ret];
}


function solveEllipseCoefficients(matrix) {

System.println("matrix1! " + matrix);    
  // Assuming the matrix is a 2D array representing the coefficients of the equations
  // [ [a11, a12, a13, a14, a15, a16],
  //   [a21, a22, a23, a24, a25, a26],
  //   ...
  //   [a61, a62, a63, a64, a65, a66] ]

  // Perform Gaussian elimination or any suitable method to solve the system of equations
  // Here, I'll provide a basic Gaussian elimination implementation

  //var n = matrix.size(); // Number of equations (6 in this case)
  var n = 5;

  /*for (var i = 0; i < n; i++) {
    matrix[i].add(0);
  }*/

  for (var i = 0; i < n; i++) {
    // Find the pivot element (largest absolute value) in the current column
    var maxRow = i;
    for (var k = i + 1; k < n; k++) {
      if ((matrix[k][i]).abs() > (matrix[maxRow][i]).abs()) {
        maxRow = k;
      }
    }

    // Swap rows if necessary to bring the pivot element to the diagonal
    if (maxRow != i) {
      //[matrix[i], matrix[maxRow]] = [matrix[maxRow], matrix[i]];
      var save = matrix[i];
      matrix[i] = matrix[maxRow];
      matrix[maxRow] = save;
    }

    if (matrix [i][i] == 0) {matrix[i][i] = 0.000000000001;}
    // Eliminate the current variable from the equations below
    for (var k = i + 1; k < n; k++) {
      var factor = matrix[k][i] / matrix[i][i];
      for (var j = i; j < n + 1 ; j++) {
        matrix[k][j] -= factor * matrix[i][j];
      }
    }
  }

  System.println("matrix! " + matrix);


    // Back-substitution to find the solution
  var solution = [0,0,0,0,0,0];
  for (var i = n - 1; i >= 0; i--) {
    solution[i] = matrix[i][n]; // Initialize with the constant term (extra row/constant)
    for (var j = i + 1; j < n; j++) {
      solution[i] -= matrix[i][j] * solution[j]; // Subtract contributions from other variables
    }
    if (matrix [i][i] == 0) {matrix[i][i] = 0.000000000001;}
    solution[i] /= matrix[i][i]; // Divide by the coefficient of the current variable
  }

  // Return the solution as an object with named coefficients
  return {
    :A => solution[0],
    :B => solution[1],
    :C => solution[2],
    :D => solution[3],
    :E => solution[4],
    :F => solution[5],
  };
}

function getEllipseParametric(coeffs) {
    var A = coeffs[:A];
    var B = coeffs[:B];
    var C = coeffs[:C];
    var D = coeffs[:D];
    var E = coeffs[:E];
    var F = coeffs[:F];

    System.println("coeff2! " + coeffs);
  // Calculate center and rotation
  var h = (2 * C * D - B * E) / (B * B - 4 * A * C);
  var k = (2 * A * E - B * D) / (B * B - 4 * A * C);
  var φ =
    (A != C)
      ? 0.5 * Math.atan(B / (A - C))
      : (B != 0)
      ? Math.PI / 4
      : 0;

  // Calculate semi-major and semi-minor axes (simplified for brevity)
  // ... (refer to the formulas above)

  var a = Math.sqrt(2 * (A*E*E + C*D*D - B*D*E + (B*B - 4*A*C) * F) / ((B*B - 4*A*C) * (Math.sqrt((A - C)*(A-C) + B*B) - (A + C))));
  var b = Math.sqrt(2 * (A*E*E + C*D*D - B*D*E + (B*B - 4*A*C) * F) / ((B*B - 4*A*C) * (-Math.sqrt((A - C)*(A-C) + B*B) - (A + C))));

  // Return parametric functions
  //return {
    //x => (θ) => h + a * Math.cos(θ) * Math.cos(φ) - b * Math.sin(θ) * Math.sin(φ),
    //y => (θ) => k + a * Math.cos(θ) * Math.sin(φ) + b * Math.sin(θ) * Math.cos(φ),
  //};
  return {
    :h => h,
    :k => k,
    :a => a,
    :b => b,
    :cosφ => Math.cos(φ),
    :sinφ => Math.sin(φ),
  };
  
}


function ellipseCalc(θ, parms) {
    //x => (θ) => h + a * Math.cos(θ) * Math.cos(φ) - b * Math.sin(θ) * Math.sin(φ),
    var x= parms[:h] + parms[:a] * Math.cos(θ) * parms[:cosφ] - parms[:b] * Math.sin(θ) * parms[:sinφ];

    //y => (θ) => k + a * Math.cos(θ) * Math.sin(φ) + b * Math.sin(θ) * Math.cos(φ),
    var y= parms[:k] + parms[:a] * Math.cos(θ) * parms[:sinφ] - parms[:b] * Math.sin(θ) * parms[:cosφ];
    return [x,y];
}

function ellipseCalc2(x, coeffs){

    var a = coeffs[1][:A];
    var b = coeffs[1][:B];
    var c = coeffs[1][:C];
    var d = coeffs[1][:D];
    var e = coeffs[1][:E];
    var f = -coeffs[0]*coeffs[0]; //f is approx the major radius, which we are approxing via the largest radius we found...

    var y4 = (-b*x - e + Math.sqrt((b*x + e)*(b*x + e) - 4*c*(a*x*x + d*x + f))) / (2*c);
    var y5 = (-b*x - e - Math.sqrt((b*x + e)*(b*x + e) - 4*c*(a*x*x + d*x + f))) / (2*c);

    return [[x,y4], [x,y5]];

}

function generateAllParms(now_info, time_add_hrs, whh, pp) {
    var p = {};
    var ppp = {};
    for (var i = 0; i<whh.size(); i++) {
        var key = whh[i];
        if (key.equals("Sun")) {continue;}
        p.put(key,[]);
        ppp.put(key,[]);
    }

    for (var j =0; j<6; j++) {
        if (j>0 ) { 
            var rnd = Math.rand()%100;
            var extra_time = j*456.248971*24.23598123*700*rnd;
            
            pp = vsop_cache.fetch(now_info, 0, 0, time_add_hrs + extra_time, :helio_xyz);
        }
            for (var i = 0; i<whh.size(); i++) {
                var key = whh[i];
                if (key.equals("Sun")) {continue;}
                //System.println("KEY whh: " + key);
                if (j<6) {p[key].add([pp[key][0],pp[key][1]]);}
                ppp[key].add([pp[key][0],pp[key][1]]);


            }
    }
    System.println("points: " + p);
    var eParms = {};
    for (var i = 0; i<whh.size(); i++) {
        var key = whh[i];
        if (key.equals("Sun")) {continue;}
        System.println("Planet: " + key);
        //eParms.put(key,(getEllipseParametric(solveEllipseCoefficients(generateEllipseCoefficients(p[key])))));
        var B = generateEllipseCoefficients(p[key]);
        var max = B[0];
        var parms =B[1];

        eParms.put(key,[max,(solveEllipseCoefficients(parms))]);
    }
    return [eParms, ppp];

}

function drawOrbits (dc, eParms, scale, xc,yc, big_small, whh, small_whh, color) {

    dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(1);

    for (var i=0; i<whh.size(); i++) {
     var key = whh[i];
       if (!key.equals("Sun") && (big_small==0 || small_whh.indexOf(key)==-1))
       {

        System.println("dORbit: " + key + " Parms: " + eParms[key]);
        for (var θ = 0; θ < 2*Math.PI; θ += 2*Math.PI/20) {

            var X = ellipseCalc(θ, eParms[key]);
            dc.drawPoint (scale*X[0]*10 + xc, scale*X[1]*10 + xc);

            
        }



       }
    }
}

var save_points = {};


function drawOrbits3 (dc, pp, scale, xc,yc, big_small, WHHs, color) {

    dc.setColor(color, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(1);

    var full_whh = WHHs[0];
    var whh = WHHs[1];
    var small_whh = WHHs[2];

    if ($.animation_count%20==0) {
        for (var j=0;j<full_whh.size(); j++) {
        var key = full_whh[j];
        if (key.equals("Sun")) {continue;}
        var cur = save_points[key];
        if (cur == null) { cur = [];}
        if (cur.size()>25) {cur.remove(cur[0]);}
        cur.add([(pp[key][0]*100).toNumber(),(pp[key][01]*100).toNumber()]);
        save_points[key] = cur;
        }
    }

    
    for (var j=0;j<whh.size(); j++) {
     var key = whh[j];
       if (!key.equals("Sun") && (big_small==0 || small_whh.indexOf(key)==-1))
       {

        if (save_points[key] == null) {continue;}
        for (var i = 0; i < save_points[key].size(); i ++) {
            
            var X = save_points[key][i];
            //System.println("X: " + X);
            //System.println ("X = " + X);
            dc.drawPoint (scale*X[0] + xc, scale*X[1] + xc);

            
        }



       }
    }
}




function drawOrbits2 (dc, coeff, scale, xc,yc, big_small, whh, small_whh, color) {

    dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(1);

    for (var i=0; i<whh.size(); i++) {
     var key = whh[i];
       if (!key.equals("Sun") && (big_small==0 || small_whh.indexOf(key)==-1))
       {

        System.println("dORbit: " + key + " Parms: " + coeff[key]);
        var lim = 1.8;
        if (big_small == 1) {lim = 10;}
        if (big_small == 2) {lim = 20;}
        for (var x = -20; x < 20; x += 1) {

            var X = ellipseCalc2(x, coeff[key]);
            dc.drawPoint (scale*X[0][0]*10 + xc, scale*X[0][1]*10 + xc);
            dc.drawPoint (scale*X[1][0]*10 + xc, scale*X[1][1]*10 + xc);

            
        }



       }
    }
}
