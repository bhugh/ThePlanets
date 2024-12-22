/*************************************************************
*
* Adapted directly from:
* SolarSystem by Ioannis Nasios 
* https://github.com/IoannisNasios/solarsystem
*
* LICENSE & COPYRIGHT:
* The MIT License, Copyright (c) 2020, Ioannis Nasios
*
***************************************************************/

import Toybox.Math;
import Toybox.System;
import Toybox.Lang;    
//degree_sign= u'\N{DEGREE SIGN}';

//module SSFunc {

    var fc = 0.0000001; //correction for Math.floor to avoid like 49.999999999

    function normalize(degrees) {  
        /*
        set degrees always between 0 - 360
        
        Args:
            degrees (float): degrees to be adjusted
            
        Returns:
            float: degrees between 0-360
            
        */
        switch (degrees) {
            case instanceof Number:
            case instanceof Long:
                if (degrees >= 0) { return degrees%360;}
                else {return degrees%360 + 360;}
            //case instanceof Long:
            //    return degrees%360;
            default:
                return ((degrees/360.0 - Math.floor(degrees/360.0 + fc)) *360.0).toFloat();
        }        

    }

    function normalize180(degrees) {  
        /*
        set degrees always between -180 to 180
        
        Args:
            degrees (float): degrees to be adjusted
            
        Returns:
            float: degrees between -180 and 180
            
        */
        var d = normalize(degrees);
        if (d > 180) {return d - 360;}
        return d;
        
        /*
        var ret;
        switch (degrees) {
            case instanceof Number:
            case instanceof Long:
                if (degrees >= 0) { ret = degrees%360 - 180;}
                else {ret = degrees%360 + 180;}
                
            //case instanceof Long:
            //    return degrees%360;
            default:
                ret = ((degrees/360.0 - Math.floor(degrees/360.0 + fc)) *360.0).toFloat();
        }  

        if (ret > 180 ) { return ret - 360;}
        return ret;    
        */  
    }
    //modular division for floats/doubles
    //a mod b
    //Has a little correction to avoid issues with fp&double numbers like
    // 1.99999999 (rounds to 2 instead of 1)
    function mod (a ,b) {
        if (b ==0) { return 0; }
        return ((a/b - Math.floor(a/b + fc)) *b).toFloat();
    }

    const J2000_0= 2451543.5d; // 2000 Jan 0.0 TDT, which is the same as 1999 Dec 31.0 TDT, i.e. precisely at midnight TDT  (Jan 0.0 is not the first day of January but rather the LAST day of December, so a full day before Jan 1.0)
    //This is actually NOT the same as J2000, which is 1 Jan 2000 at noon, Julian Date 2451545, or 2000 Jan 1.5.
    //This MIGHT be a mistake by someone who was trying to use J2000 but missed by a little?  In obliquity of ecliptic calc below the difference will be negligible.

    const J2000 = 2451545d; //start of J2000 epoch


    //Julians MUST be double or they have accuracy of only .25 day even in 2024 already.
    function julianDate (year, month, day, hour, min, UT, dst) as Lang.double {


        var pr=0d;
        if (dst==1) {pr=1/24.0d;}
        var JDN= ((367l*(year) - Math.floor(7*(year + Math.floor((month+9 )/12))/4)) + Math.floor(275*(month)/9) + (day + 1721013.5d - UT/24d ) );
        var JD= (JDN + (hour)/24.0d + min/1440.0d - pr); //(hour)/24 + (min)/1440; in this case  noon (hr12, min0)
        return JD;

    }

    function j2000_0Date  (year, month, day, hour, min, UT, dst) as Lang.double {

        var JD = julianDate(year, month, day, hour, min, UT, dst);
        
        return JD - J2000_0;


    }

    function j2000Date (year, month, day, hour, min, UT, dst) as Lang.double {

        var JD = julianDate(year, month, day, hour, min, UT, dst);
        
        return JD - J2000;


    }

    function obliquityEcliptic_deg (year, month, day, hour, min, UT, dst) {

        var d = j2000_0Date(year, month, day, hour, min, UT, dst);
        
        return 23.4393f - 3.563E-7f * d; //obliquity of the ecliptic, i.e. the "tilt" of the Earth's axis of rotation (currently 23.4 degrees and slowly decreasing)
        
    }

    function obliquityEcliptic_rad (year, month, day, hour, min, UT, dst) {

        return Math.toRadians (obliquityEcliptic_deg(year, month, day, hour, min, UT, dst));
        
    }

     function rectangular2spherical(x, y, z) {
        /*Transform rectangular to spherical projection.
        
        From rectangular(x,y,z) coordinates system to spherical (RA,Decl, r) or 
        by replacing x with azimuth and y with altitude we can tranform 
        horizontal coordinates to ecliptic (longitude, latitude).
        
        Args:
            x: value on x axis of a rectangular projection.
            y: value on y axis of a rectangular projection.
            z: value on z axis of a rectangular projection.
    
        Returns:
            tuple: RA, Decl, r spherical coordinate system. 
            
        */
        
        var r    = Math.sqrt( x*x + y*y + z*z );
        var RA   = Math.atan2( y, x );
        //    var Decl = Math.asin( z / r ) ;
        var Decl = Math.atan2( z, Math.sqrt( x*x + y*y ) );

        //System.println( "rRADecl: " + r + " " + RA + " " + Decl);
        
        RA = normalize(Math.toDegrees(RA));
        Decl = (Math.toDegrees(Decl));
        return [RA, Decl, r]    ;

    }

    

    function sind (deg)  {
        return Math.sin(Math.toRadians(deg));
    }
    
    function cosd (deg)  {
        return Math.cos(Math.toRadians(deg));
    }



    function Planet_Sun(M, e, a, N, w, i) {
        /*
        Helper Function. From planet's trajectory elements to position around sun
            
        Returns:
            tuple: position elements
            
        */

        var M2=Math.toRadians(M);
        var E0=M + (180/Math.PI)*e*Math.sin(M2)*(1+e*Math.cos(M2));
        E0=normalize(E0) ;
        var E02=Math.toRadians(E0);
        var E1=E0 - (E0 - (180/Math.PI)*e*Math.sin(E02)-M)/(1-e*Math.cos(E02));
        E1=normalize(E1) ;
        var E=Math.toRadians(E1);
        var x=a*(Math.cos(E)-e);
        var y=a*(Math.sqrt(1 - e*e))*Math.sin(E);

        var r=Math.sqrt(x*x+y*y);
        var v=Math.atan2(y, x);
        v=normalize(Math.toDegrees(v));

        var xeclip=r*(Math.cos(Math.toRadians(N))*Math.cos(Math.toRadians(v+w)) - Math.sin(Math.toRadians(N))*Math.sin(Math.toRadians(v+w))*Math.cos(Math.toRadians(i)));
        var yeclip=r*(Math.sin(Math.toRadians(N))*Math.cos(Math.toRadians(v+w)) + Math.cos(Math.toRadians(N))*Math.sin(Math.toRadians(v+w))*Math.cos(Math.toRadians(i)));
        var zeclip=r*Math.sin(Math.toRadians(v+w))*Math.sin(Math.toRadians(i)) ;
        var long2 = Math.atan2( yeclip, xeclip );
        long2=normalize(Math.toDegrees(long2));
        var lat2 = Math.atan2( zeclip, Math.sqrt( xeclip*xeclip +yeclip*yeclip ) );
        lat2=Math.toDegrees(lat2);
        //return {:xeclip => xeclip,:yeclip => yeclip, :zeclip => zeclip, :long2 => long2, :lat2=>lat2, :r => r};
        return [xeclip,yeclip,zeclip,long2,lat2,r];

    }


    function sun2planet(xeclip, yeclip, zeclip, x, y, z) {
        /*
        Helper Function. From Heliocentric to Geocentric position
            
        Returns:
            tuple: geocentric view of object.
            
        */
        var x_geoc=(x+xeclip);
        var y_geoc=(y+yeclip);
        var z_geoc=(z+zeclip);
        //System.println("sun2peclip: " + xeclip +" " + yeclip +" " + zeclip +" ");
        //System.println("sun2pxyz: " + x +" " + y +" " + z +" ");
        //System.println("sun2p: " + x_geoc +" " + y_geoc +" " + z_geoc +" ");
        return rectangular2spherical(x_geoc, y_geoc, z_geoc);
        //    t = ecliptic2equatorial(x_geoc, y_geoc, z_geoc, 23.4);
        //    return rectangular2spherical(t[0],t[1],t[2]);
    }
//}

//given a dict with keys =kyss & values an array [1,2,3,4,5...]
//and separate send the keys kys (or perhaps they are a separate array...)
//will return an array with the keys sorted ascending on the nth value of the array
function insertionSort(kys, dict, n) {
    //var kys = dict.getKeys();
    for (var i = 1; i < kys.size(); i++) {
        var kkey = kys[i];
        var sorton = dict[kkey][n];
        
        var j = i - 1;

        // Move elements of dict[0..i-1], that are greater than key,
        // to one position ahead of their current position
        while (j >= 0 && dict[kys[j]][n] > sorton) {
            kys[j + 1] = kys[j];
            j = j - 1;
        }
        kys[j + 1] = kkey;
    }


    return kys;
}


//isNumber: 0 string, 1 Number, 2 Float
function toArray(text, delimiter, isNumber)
{
    var arr = [];
    var delLen = delimiter.length();

    //System.println("TXT: " + text + " df " + delimiter + " isn " + isNumber);
    while (text.length() > 0)
    {
        //System.println ("TXT " + delLen + " txt: " + text);
        var iend = text.find(delimiter);
        if (iend == null) // If delimiter is not found
        {
            iend = text.length(); // Take the rest of the string

        }

        // Extract the substring and convert to number if applicable
        var value = text.substring(0, iend);
        if (isNumber==1) {value = value.toNumber();}
        else if (isNumber==2) {value = value.toFloat();}
        arr.add(value); // Convert to number if needed
        
        if (iend==null) {break;}
        //System.println ("TXT" + iend + " d: " + delLen + "val: " + value + " txt: " + text);
        // Update text to remove the processed part
        //So FR 245 SIMULATOR (not real thing, only simulator) croaks when last
        //field is NULL even though documentations says that is OK
        text = text.substring(iend + delLen, text.length());
    }

    return arr; // Return the array of values
}

const FLT_MAX = 3.4028235e38f;

function isnan(x as Float) as Boolean {
    return x != x;
}

function isinf(x as Float) as Boolean {
    return (x < -FLT_MAX || FLT_MAX < x);
}

function isUnSafeFloat(x as Float) as Boolean {
    return isnan (x) || isinf(x);
}

function deBug(label, ary) {
    System.print (label + ": ");
    //if (ary == null) {System.println(" NULL!"); return;}

    if (ary instanceof Lang.Array) {
        for (var i = 0; i< ary.size(); i++) {
        System.print(ary[i] + " : ");
        } 
    }else {
        System.print(ary);
    }
    System.println("");
}