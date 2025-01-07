import Toybox.Math;
import Toybox.System;
import Toybox.Lang; 
import Toybox.WatchUi;

/*
function calculateTrueAnomaly(MA, EC) {
    // Convert MA to radians
    var MA_rad = Math.toRadians(MA);

    MA_rad = mod(MA_rad,Math.PI * 2);

    //var  = MA_rad - Math.toRadians(W);

    //var TA = mod(TA,Math.PI * 2);

    //TA= E - EC sin (E)

    
    // Calculate Eccentric Anomaly (EA) using Kepler's equation
    var EA = MA_rad + EC * Math.sin(MA_rad);
    
    // Calculate True Anomaly (TA)
    var TA = 2 * Math.atan(Math.sqrt((1 + EC) / (1 - EC)) * Math.tan(EA / 2));
    
    return TA;
}

function calculateRadiusVector(TA, A, EC) {
    // Calculate Radius Vector (r)
    var r = A * (1 - EC * EC) / (1 + EC * Math.cos(TA));
    
    return r;
}

function calculateCartesianCoordinates(r, TA, OM, W, IN) {
    // Calculate Cartesian Coordinates (x, y, z)
    var x = r * (Math.cos(Math.toRadians(OM)) * Math.cos(Math.toRadians(W) + TA) - Math.sin(Math.toRadians(OM)) * Math.sin(Math.toRadians(W) + TA) * Math.cos(Math.toRadians(IN)));
    var y = r * (Math.sin(Math.toRadians(OM)) * Math.cos(Math.toRadians(W) + TA) + Math.cos(Math.toRadians(OM)) * Math.sin(Math.toRadians(W) + TA) * Math.cos(Math.toRadians(IN)));
    var z = r * Math.sin(Math.toRadians(W) + TA) * Math.sin(Math.toRadians(IN));
    
    return [x, y, z];
}

function calculatePosition(EPOCH, EC, QR, OM, W, IN, A, MA, N, d) {
    // Calculate the time difference (d) in days
    d = d - EPOCH;
    
    // Calculate the Mean Anomaly (MA) at the desired time
    MA = MA + N * d;
    
    // Calculate the True Anomaly (TA)
    var TA = calculateTrueAnomaly(MA, EC);
    
    // Calculate the Radius Vector (r)
    var r = calculateRadiusVector(TA, A, EC);
    
    // Calculate the Cartesian Coordinates (x, y, z)
    var xyz = calculateCartesianCoordinates(r, TA, OM, W, IN);
    
    return xyz;
}

*/






function calculateEphemerisPosition(epoch, ec, qr, jd, om, w, rest) {
    var inc = rest[0];
    var a = rest[1];
    var ma = rest[2];
    //var PER = rest[3];
    var N = rest[3];
    
    //Calculates the heliocentric position of a celestial body using orbital elements.
    /*
    Args:
        epoch (float): Epoch of the orbital elements (Julian Date).
        ec (float): Eccentricity.
        qr (float): Perihelion distance (AU).
        tp (float): Time of perihelion passage (Julian Date).
        om (float): Longitude of the ascending node (degrees).
        w (float): Argument of perihelion (degrees).
        inc (float): Inclination (degrees).
        a (float): Semi-major axis (AU).
        ma (float): Mean anomaly (degrees).
    

    Returns:
        tuple: A tuple containing the x, y, and z coordinates of the celestial body in the heliocentric XYZ coordinate system (AU).
               Returns None if the calculation fails.
    */

       //# Convert angles to radians
        var om_rad = Math.toRadians(om);
        var w_rad = Math.toRadians(w);
        var inc_rad = Math.toRadians(inc);
        var ma_rad = Math.toRadians(ma);

        //# Calculate the mean motion (n)
        //#n = np.sqrt(1/a**3)  #Assuming a period of 1 year, need to adjust if you have a different period
        //var n = 2 * Math.PI / (PER * 365.25);

        //# Calculate the time since perihelion passage in years
        //var dt = (epoch - tp) / 365.25;  //#Days to years

        var n = Math.toRadians(N) ;

        var M = ma_rad + n * (jd - epoch);

        //# Calculate the mean anomaly at the current epoch
        //var M = ma_rad + n * dt;

        //# Solve Kepler's equation to find the eccentric anomaly (E) iteratively
        var E = M;  //# Initial guess
        for (var i =0; i<100; i++) {  //# Iterate up to 100 times for convergence
            var delta_E = (E - ec * Math.sin(E) - M) / (1 - ec * Math.cos(E));
            E -= delta_E;
            if ((delta_E).abs() < 1e-6) { 
                break;
            }
        }


        //# Calculate the true anomaly (nu)
        var nu = 2 * Math.atan2(Math.sqrt(1 + ec) * Math.sin(E / 2), Math.sqrt(1 - ec) * Math.cos(E / 2));


        //# Calculate the distance from the Sun (r)
        var r = a * (1 - ec * Math.cos(E));

        //# Calculate the rectangular coordinates in the orbital plane
        var x_orbital = r * Math.cos(nu);
        var y_orbital = r * Math.sin(nu);

        //# Convert from orbital plane to ecliptic coordinates
        var x_ecliptic = x_orbital * (Math.cos(w_rad) * Math.cos(om_rad) - Math.sin(w_rad) * Math.cos(inc_rad) * Math.sin(om_rad)) - y_orbital * (Math.sin(w_rad) * Math.cos(om_rad) + Math.cos(w_rad) * Math.cos(inc_rad) * Math.sin(om_rad));

        var y_ecliptic = x_orbital * (Math.cos(w_rad) * Math.sin(om_rad) + Math.sin(w_rad) * Math.cos(inc_rad) * Math.cos(om_rad)) - y_orbital * (Math.sin(w_rad) * Math.sin(om_rad) - Math.cos(w_rad) * Math.cos(inc_rad) * Math.cos(om_rad));

        var z_ecliptic = x_orbital * (Math.sin(w_rad) * Math.sin(inc_rad)) + y_orbital * (Math.cos(w_rad) * Math.sin(inc_rad));

        return [x_ecliptic, y_ecliptic, z_ecliptic];
    }

/*

function testEph (){
//# Orbital elements for Ceres (example data provided in the prompt)
var epoch = 2458849.5;
var ec = 0.07687465013145245;
var qr = 2.556401146697176;
var tp = 2458240.1791309435;
var om = 80.3011901917491;
var w = 73.80896808746482;
var inc = 10.59127767086216;
var a = 2.769289292143484;
 var ma = 130.3159688200986;
var PER= 4.60851 ;
var N = 0.213870844;


//#Calculate current position

var JD1 = julianDate (now_info.year, now_info.month, now_info.day,now_info.hour, now_info.min, $.now.timeZoneOffset/3600d, $.now.dst);

JD1 = 2460683.344444;

var xyz = calculateEphemerisPosition(epoch, ec, qr, JD1, om, w, [inc, a, ma, N]);

deBug("Ceres Heliocentric Coordinates (x, y, z)", [xyz, JD1]);
}
*/