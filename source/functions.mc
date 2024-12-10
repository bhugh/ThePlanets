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

    var fc = 0.0000000001d; //correction for Math.floor to avoid like 49.999999999

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
                return (degrees/360.0d - Math.floor(degrees/360.0d + fc)) *360.0d;
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
        var ret;
        switch (degrees) {
            case instanceof Number:
            case instanceof Long:
                if (degrees >= 0) { ret = degrees%360 - 180;}
                else {ret = degrees%360 + 180;}
                
            //case instanceof Long:
            //    return degrees%360;
            default:
                ret = (degrees/360.0d - Math.floor(degrees/360.0d + fc)) *360.0d;
        }  

        if (ret > 180 ) { return ret - 360;}
        return ret;      
    }
    //modular division for floats/doubles
    //a mod b
    //Has a little correction to avoid issues with fp&double numbers like
    // 1.99999999 (rounds to 2 instead of 1)
    function mod (a ,b) {
        if (b ==0) { return 0; }
        return (a/b - Math.floor(a/b + fc)) *b;
    }

    const J2000_0= 2451543.5d; // 2000 Jan 0.0 TDT, which is the same as 1999 Dec 31.0 TDT, i.e. precisely at midnight TDT  (Jan 0.0 is not the first day of January but rather the LAST day of December, so a full day before Jan 1.0)
    //This is actually NOT the same as J2000, which is 1 Jan 2000 at noon, Julian Date 2451545, or 2000 Jan 1.5.
    //This MIGHT be a mistake by someone who was trying to use J2000 but missed by a little?  In obliquity of ecliptic calc below the difference will be negligible.

    const J2000 = 2451545; //start of J2000 epoch


    function julianDate (year, month, day, hour, min, UT, dst) {


        var pr=0d;
        if (dst==1) {pr=1/24d;}
        var JDN= ((367l*(year) - Math.floor(7*(year + Math.floor((month+9 )/12))/4)) + Math.floor(275*(month)/9) + (day + 1721013.5d - UT/24d ) );
        var JD= (JDN + (hour)/24d + min/1440d - pr); //(hour)/24 + (min)/1440; in this case  noon (hr12, min0)
        return JD;

    }

    function j2000_0Date (year, month, day, hour, min, UT, dst) {

        var JD = julianDate(year, month, day, hour, min, UT, dst);
        
        return JD - J2000_0;


    }

    function j2000Date (year, month, day, hour, min, UT, dst) {

        var JD = julianDate(year, month, day, hour, min, UT, dst);
        
        return JD - J2000;


    }

    function obliquityEcliptic_deg (year, month, day, hour, min, UT, dst) {

        var d = j2000_0Date(year, month, day, hour, min, UT, dst);
        
        return 23.4393d - 3.563E-7d * d; //obliquity of the ecliptic, i.e. the "tilt" of the Earth's axis of rotation (currently 23.4 degrees and slowly decreasing)
        
    }

    function obliquityEcliptic_rad (year, month, day, hour, min, UT, dst) {

        return Math.toRadians (obliquityEcliptic_deg(year, month, day, hour, min, UT, dst));
        
    }

    function sind (deg)  {
        return Math.sin(Math.toRadians(deg));
    }
    
    function cosd (deg)  {
        return Math.cos(Math.toRadians(deg));
    }


    function spherical2rectangular(RA, Decl, r) {
        /*Transform spherical to rectangular projection.
        
        From spherical (RA,Decl) coordinates system to rectangular(x,y,z) or 
        by replacing RA with longitude and Decl with latitude we can tranform 
        ecliptic coordinates to horizontal (azimuth,altitude).
        
        Args:
            RA: Right Ascension.
            Decl: Declination.
            r: Distance in astronomical units.
    
        Returns:
            tuple: x, y, z rectangular coordinate system. 
            
        */
        
        RA = Math.toRadians(RA);
        Decl = Math.toRadians(Decl);
        var x = r * Math.cos(RA) * Math.cos(Decl);
        var y = r * Math.sin(RA) * Math.cos(Decl);
        var z = r * Math.sin(Decl);
        
        return [x, y, z];


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

    


    function ecliptic2equatorial(xeclip, yeclip, zeclip, oblecl) {
        /*Transform ecliptic to equatorial projection.
        
        Args:
            xeclip: value on x axis of ecliptic plane.
            yeclip: value on y axis of ecliptic plane.
            zeclip: value on z axis of ecliptic plane.
            oblecl: obliquity of the ecliptic, approximately 23.4 degrees for earth
    
        Returns:
            tuple: x, y, z equatorial projection 
            
        */
        //    oblecl = Math.toRadians(oblecl);

        //System.println("oblecl: " + oblecl  + " yeclip: " + yeclip);
        
        var xequat = xeclip;
        var yequat = yeclip * Math.cos(oblecl) - zeclip * Math.sin(oblecl);
        var zequat = yeclip * Math.sin(oblecl) + zeclip * Math.cos(oblecl);
        
        return [xequat, yequat, zequat];

    }



    function equatorial2ecliptic(xequat, yequat, zequat, oblecl) {
        /*Transform equatorial to ecliptic projection.
        
        Args:
            xequat: value on x axis of equatorial plane
            yequat: value on y axis of equatorial plane
            zequat: value on z axis of equatorial plane
            oblecl: obliquity of the ecliptic, approximately 23.4 degrees for earth
    
        Returns:
            tuple: x, y, z ecliptic projection 
            
        */
        
        //    oblecl = Math.toRadians(oblecl);
        var xeclip = xequat;
        var yeclip = yequat * Math.cos(-oblecl) - zequat * Math.sin(-oblecl);
        var zeclip = yequat * Math.sin(-oblecl) + zequat * Math.cos(-oblecl);
        return [xeclip, yeclip, zeclip];

    }

    


    function spherical_ecliptic2equatorial(long, lat, distance, oblecl) {
        /*Transform eclipitc to spherical projection for given obliquity.
        
        From spherical (RA, Decl, distance) coordinates system to 
        eclipitc(long, lat, distance).
        
        Args:
            long: Longitude.
            last: Latitude.
            distance: Distance in astronomical units.
            oblecl: obliquity (axial tilt).
                
        Returns:
            tuple: RA, Decl, distance spherical coordinate system. 
            
        */
        
        var b = spherical2rectangular(long,lat,distance);
        var c = ecliptic2equatorial(b[0],b[1],b[2], oblecl);
        return rectangular2spherical(c[0],c[1],c[2]);
    }


    function spherical_equatorial2ecliptic(RA, Decl, distance, oblecl) {
        /*Transform spherical to eclipitc projection for given obliquity.
        
        From spherical (RA, Decl, distance) coordinates system to 
        eclipitc(long, lat, distance).
        
        Args:
            RA: Right Ascension.
            Decl: Declination.
            distance: Distance in astronomical units.
            oblecl: obliquity (axial tilt).
                
        Returns:
            tuple: long, lat, distance eclipitc coordinate system. 
            
        */
        
        var b = spherical2rectangular(RA, Decl,distance);
        var c = equatorial2ecliptic(b[0],b[1],b[2], oblecl);
        return rectangular2spherical(c[0],c[1],c[2]);

    }


    function decimal2clock(decimaltime) {
        /*
        Convert demical time view to Hours, Minutes and Seconds.
        
        Args:
            decimaltime (float): time to be converted.
            
        Returns:
            str: one string representation in hours, minutes format.
            
        */
        var h  = (decimaltime>=0) ? (Math.floor(decimaltime)) : (Math.ceil(decimaltime));
        var m  = (decimaltime>=0) ? (Math.floor((decimaltime - h) * 60d)  + fc ).abs() : (Math.ceil((decimaltime - h) * 60d) - fc).abs();
        //var s  = (decimaltime>=0) ? ((Math.floor((((decimaltime-h)*60d).abs() - m ) * 60d))).abs() : ((Math.ceil((((decimaltime-h)*60d).abs() - m ) * 60d))).abs();;
        var s  = ((((decimaltime-h)*60d).abs() - m ) * 60d).abs() ;
        //var s10 = s - Math.floor(s  + fc);
        //System.println(s + " " + s10);
        //h=str(h);
        //m=str(m);
        //s=str(s);
        //if len(h)==1: h = '0' + h;
        //if len(m)==1: m = '0' + m;
        //if len(s)==1: s = '0' + s;
        var res = h.format("%02d") + ':'+ m.format("%02d") + ':'+ s.format("%02.2f");// + "." + (Math.round(s10*10)).format("%02.d");
        return res;
    }


    function decimal2arcs(num) {
        /*
        Convert Demical view to Degrees and minutes.
        
        Args:
            num (float): degrees to be converted.
            
        Returns:
            str: one string representation in degrees and minutes format.
            
        */
        //    return(str(int(num))+u"\u00b0 "+str(round(abs(num - int(num))*60,2))+"'")

        var deg = (num>=0) ? Math.floor(num) : Math.ceil(num);

        var mins = ((num - deg) * 60.0d).abs();
        //return(str(int(num))+"° "+str(round(abs(num - int(num))*60,2))+"'")
        return deg.format("%d") + "° " + mins.format("%0.2f") + "'";
    }



    //function degrees2hours(degrees) {
    //    /*
    //    Convert degrees to string representation of hours, minutes and seconds.
    //    
    //    Args:
    //        degrees (float): degrees to be converted.
    //        
    //    Returns:
    //        str: one string representation in hours, minutes and seconds format.
    //        
    //    */   
    //    h=degrees//15;
    //    r=(degrees%15)*4;
    //    m=int(r);
    //    s=int((r-m)*60);
    //    return (str(h)+'h '+str(m)+'m '+str(s)+'s');
    //}


    function decimal2hms(degrees) {
        /*
        Convert degrees to string representation of hours, minutes and seconds.
        
        Args:
            degrees (float): degrees to be converted.
            
        Returns:
            str: one string representation in hours, minutes and seconds format.
            
        */   
        var prefix = (degrees < 0) ? "-" : "";
        degrees = degrees.abs();

        var h = Math.floor(degrees/15d + fc).toNumber();
        var m = Math.floor((degrees/15d - h) * 60d + fc).toNumber();
        var s = (((degrees/15d-h)*60d - m ) * 60d).toNumber();

        //System.println(h + " " + m  + " " + s);
        
        var res = prefix + h.format("%02d") + "h " + m.format("%02d") + "m "+ s.format("%02d") +"s";
        return res;

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

