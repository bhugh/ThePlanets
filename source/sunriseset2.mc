/*************************************************************
*
* Adapted directly from:
* SolarSystem by Ioannis Nasios 
* https://github.com/IoannisNasios/solarsystem
*
* LICENSE & COPYRIGHT of original code:
* The MIT License, Copyright (c) 2020, Ioannis Nasios
*
* Monkey C/Garmin IQ version of the code, with many modifications,
* Copyright (c) 2024, Brent Hugh. Released under the MIT license.
*
***************************************************************/

using Toybox.Math;
using Toybox.System;
import Toybox.Lang; 

//from .functions import normalize

class sunRiseSet_cache2{

    var g_cache;
    var indexes;
    var MAX_CACHE = 0;

    function initialize () {
        

        //planetoncenter = $.Geocentric.planetoncenter;
        //objectlist = $.Geocentric.objectlist;
        g_cache = {};
        indexes = [];
    }

    function fetch (year, month, day, UT, dst, timeAdd_hrs, 
                 lat, lon) {

        //changing lat or lon by 1 degree equal about 4 mins difference in sunrise/set
        //so for our purposes +/- 4 mins or 6 mins is not really perceptible on screen.
         var lon_index = (lon/3.0).toNumber();
         var lat_index = (lat/3.0).toNumber();
                    
        //since we must incl lat & lon to get a sensible answer, might as well
        //includ UT & dst as well, as those are localized in the same way                    
        //var index = year+"|"+month+"|"+day+"|"+ UT+dst +"|"+lat_index+"|"+ lon_index;

        var time_mod = Math.round(0.0 + timeAdd_hrs/24.0 + julianDate(year, 
            month, day, 0, 0, UT, dst)).toNumber();
        var index = time_mod + "|"+ +"|"+lat_index+"|"+ lon_index;
        var ret;

        var myStats = System.getSystemStats();

        //System.println("Memory/sunriseset: " + myStats.totalMemory + " " + myStats.usedMemory + " " + myStats.freeMemory + " MAX_CACHE: " + MAX_CACHE);
        //myStats = null;

        if (g_cache.hasKey(index)) {
            ret = g_cache[index];
            //kys = ret.keys();
            } 
        else {
            //we always cache the info for midnight UTC & all objects
            
            if (myStats.freeMemory<5500) {
                MAX_CACHE = 0;
                self.empty();                                 
            
            } else if (myStats.freeMemory<9500) {
                MAX_CACHE -=1;
                if (MAX_CACHE < 0) { MAX_CACHE = 0; }
                if (indexes.size() > MAX_CACHE -1 && indexes.size() > 0) {
                    g_cache.remove(indexes[0]);
                    indexes.remove(indexes[0]);
                }
            }
            else if (myStats.freeMemory> 20000 && MAX_CACHE<60) {MAX_CACHE +=1;}

            if (indexes.size() > MAX_CACHE -1 && g_cache.size()>0) {
                g_cache.remove(indexes[0]);
                indexes.remove(indexes[0]);
            }
            //var g = new sunRiseSet(year, month, day, UT,dst, timeAdd_hrs, lat, lon);
            //ret = g.riseSet();
            //kys = ret.keys();
            g_cache.put(index,ret);
            indexes.add(index);
        }                    

        return ret;
    }

    public function empty () {
        
        g_cache = {};
        indexes = [];
    }
    
}


enum {
    GMST_MID_HR,
    TRANSIT_GMT_HR,
    GMST_NOW_HR,
    LMST_NOW_HR,
    ASTRO_DAWN,
    NAUTIC_DAWN,
    DAWN,
    BLUE_HOUR,
    SUNRISE,
    SUNRISE_END,
    HORIZON,
    GOLDEN_HOUR,
    NOON,
}

//for testing, can delete later
/*
var sevent_names = {
    :GMST_MID_HR => "GMST_MID_HR",
    :TRANSIT_GMT_HR => "TRANSIT_GMT_HR",
    :GMST_NOW_HR => "GMST_NOW_HR",
    :LMST_NOW_HR => "LMST_NOW_HR",
    :ASTRO_DAWN => "Astronomical Dawn",
    :NAUTIC_DAWN => "Nautical Dawn",
    :DAWN => "Dawn",
    :BLUE_HOUR => "Blue Hour",
    :SUNRISE => "Sunrise",
    :SUNRISE_END => "Sunrise End",
    :HORIZON => "Horizon",
    :GOLDEN_HOUR => "Golden Hour",
    :NOON => "Noon",
    "Ecliptic0" => "Spring Equinox",
    "Ecliptic90" => "Summer Solstice",
    "Ecliptic180" => "Fall Equinox",
    "Ecliptic270" => "Winter Solstice",
};
*/



/*
        public var sunEventData = {
        :ASTRO_DAWN => [-18, :AM],
        :NAUTIC_DAWN => [-12, :AM],
        :DAWN => [-6, :AM ],
        :BLUE_HOUR_AM => [-4, :AM],
        :SUNRISE => [-.833, :AM],
        :SUNRISE_END => [-.3, :AM],
        :HORIZON_AM => [0, :AM],
        :GOLDEN_HOUR_AM => [6, :AM],
        :NOON => [null, :PM], //noon is the highest point or whatever, but not a certain # of degrees
        :GOLDEN_HOUR_PM => [6, :PM],
        :HORIZON_PM => [0, :PM],
        :SUNSET_START => [-0.3, :PM],
        :SUNSET => [-.833, :PM],
        :BLUE_HOUR_PM => [-4, :PM],
        :DUSK => [-6, :PM],
        :NAUTIC_DUSK => [-12, :PM],
        :ASTRO_DUSK  => [-18, :PM], 
        //:SIDEREAL_TIME => [null, :PM],
    };
    */


    public var sunEventData = {
        :ASTRO_DAWN => -18,  //each one has  a twin @ - it's number, so we'll just combine the two & you can figure it out. Dawn/Dusk -18/+18, etc.
        :NAUTIC_DAWN => -12,
        :DAWN => -6 ,
        :BLUE_HOUR => -4,
        //:SUNRISE => -.833, //Sunset  START
        :SUNRISE => -.5667, //Sunset MIDDLE OF SUN (so we're not counting the top of the sun, but the middle)
        :SUNRISE_END => -.3, //Sunset start
        :HORIZON => -0.5667, //For stars, planets, etc, the horizon where  they  can first be seen, "star-rise".  This is not 0 thanks to refraction etc.
        :GOLDEN_HOUR => 6,
        :NOON => null, //noon is the highest point or whatever, but not a certain # of degrees below the horizon

    };
        
        //degrees above / below the horizon for these events
        /*
    public const TIMES = [
        -18,    // ASTRO_DAWN
        -12,    // NAUTIC_DAWN
        -6,     // DAWN
        -4,     // BLUE_HOUR
        -0.833, // SUNRISE
        -0.3,   // SUNRISE_END
        6,      // GOLDEN_HOUR_AM
        null,         // NOON
        6 ,
        -0.3,
        -0.833,
        -4,
        -6,
        -12,
        -18,
        ];
        */

    /* **************************************************************************
    Outputs Dictionary with all sun events for the day + Sidereal_Time EVENT_NAME => [time, name_str].  See enum with EVENT_NAMEs above.
    If any events do not happen (ie sunrise & set during polar summer) their time will be a null.
    
    Args:
        year (int): Year (4 digits) ex. 2020.
        month (int): Month (1-12).
        day (int): Day (1-31).
        UT: Time Zone (deviation from UT, -12:+14), ex. for Greece (GMT + 2) 
            enter UT = 2.
        dst (int): daylight saving time (0 or 1). Wheather dst is applied at 
                   given time and place.
        longitude (float): longitude of place of Sunrise - Sunset in decimal format.
        latitude (float): latitude of place of Sunrise - Sunset in decimal format.
    ***************************************************************************/
  

//By Greg Miller gmiller@gregmiller.net celestialprogramming.com
//Released as public domain
//'use strict';


//Corrects values to make them between 0 and 1
function constrain(v){
        //console.log(v);
        while(v<0){v+=1;}
        while(v>1){v-=1;}
        return v;
}

    //returns solar event times in HOURS
    //function getRiseSetfromDate_hr(year, month, day, UT, dst, time_add_hrs, 
    //             lat_deg, long_deg) {
    function getRiseSetfromDate_hr(now_info, timeZoneOffset_sec, dst, time_add_hrs, lat_deg, lon_deg,pp_sun) {                    

         lon_deg = -lon_deg; //Meeus uses West longitudes as positive - this is to correct for that
         //deBug("long(MEEUS),UT,TZ,dst", [lon_deg.format("%.2f"), lat_deg.format("%.2f"), timeZoneOffset_sec/3600, dst]);
         

        //var jd = time_add_hrs /24.0f + gregorianDateToJulianDate(now_info.year, now_info.month, now_info.day, 0, 0, 0);
        var jd = gregorianDateToJulianDate(now_info.year, now_info.month, now_info.day, time_add_hrs, 0, 0);

        deBug("long(MEEUS),UT,TZ,dst", [lon_deg, lat_deg, timeZoneOffset_sec/3600, dst, time_add_hrs, time_add_hrs/24.0f, gregorianDateToJulianDate(now_info.year, now_info.month, now_info.day, 0, 0, 0), jd]);

        //System.println ("JD: " + jd); 

        //get ra & dec for sun from VSOP87a
        //var ra = 0;
        //var dec = 0;

        var sun_RD = pp_sun;//radec = sunPosition(jd);

        //return is: [Math.toDegrees(l), Math.toDegrees(t2), r];//lat, lon, r
        
        
        if (pp_sun == null ) {
            var sun_radec = planetCoord (now_info, timeZoneOffset_sec, dst, time_add_hrs, :ecliptic_latlon, ["Sun"]);

            //System.println("sun_radec(I): " + (pp_sun[0]) + " " + (pp_sun[1]));
            sun_RD = sun_radec["Sun"];
        }
        System.println("sun_radec: " + (sun_RD));

        var ret = {};

        //Greenwhich mean sidereal time @ midnight of today
        var gmst_mid_deg=normalize(GMST_deg(Math.floor(jd)+.5));
        //deBug("gmst: ", [gmst, jd, Math.floor(jd)+.5]);
        ret.put(:GMST_MID_HR, gmst_mid_deg/15.0);
        //deBug("gmst, jd : ", [gmst_mid_deg, jd]);
        //today's solar transit time in GMT
	    var transit_GMT_DAY=normalize(sun_RD[0] + lon_deg - gmst_mid_deg)/360.0;
        ret.put(:TRANSIT_GMT_HR, transit_GMT_DAY*24.0);
        //deBug("transit: ", [transit_GMT_DAY*24.0]);

        var gmst_now_deg = normalize(GMST_deg(jd));
        var lmst_now_hr = normalize((gmst_now_deg - lon_deg)) / 15.0;
        ret.put(:GMST_NOW_HR, [gmst_now_deg/15.0]);
        ret.put(:LMST_NOW_HR, [lmst_now_hr]);
        deBug("GNMST_NOW_HR, LMST, JD: ", [gmst_now_deg/15.0, lmst_now_hr, jd]);

        var tz_add = (timeZoneOffset_sec/3600.0f) + dst;
        ret.put (:NOON,  constrain(transit_GMT_DAY + tz_add/24.0) * 24.0);
        //deBug("NOON,tz: ", [constrain(transit_GMT_DAY + tz_add/24.0) * 24.0, tz_add]);


                //Get info for all four points of the ecliptic 
                //for this date & time
            for (var rra = 0; rra<360;rra += 90) {
                var ddecl = 0;
                if (rra == 90) { ddecl = 23.5;}
                if (rra == 270) { ddecl = -23.5;}

                    //winter solstic RA 0 DECL 0
                //winter solstic RA 0 DECL 0
                //var trans_ecliptic_DAY = normalize(rra + lon_deg - gmst_mid_deg)/360.0;
                var sun_info = getRiseSet_hr(jd,
                    sunEventData[:HORIZON], Math.toRadians(lat_deg), 
                    Math.toRadians(lon_deg),
                    Math.toRadians(rra),
                    Math.toRadians(ddecl),
                    //trans_ecliptic_DAY); 
                    0.5);//Note that ECLIPTIC ONLY just set the time to 12:00 GMT, we are interested in the "straddle" not the specific time of rise for each of these.
            

                var s1 = sun_info[0];
                var s2 = sun_info[1];

                if (sun_info[1] != null) { //if one is null both are
                    s1 = mod ((s1 + tz_add) , 24);
                    s2 = mod ( (s2 + tz_add), 24);
                }     

                if (rra==0) {
                    var obliq_rad= obliquityEcliptic_rad (now_info.year, now_info.month, now_info.day + time_add_hrs, now_info.hour, now_info.min, timeZoneOffset_sec/3600, dst);
                    var abeH = angleBetweenEclipticAndHorizon_rad(Math.toRadians(lat_deg), Math.toRadians(lmst_now_hr*15), obliq_rad);
                    var ipEH = intersectionPointsEclipticHorizon_rad(Math.toRadians(lat_deg), Math.toRadians(lmst_now_hr*15), obliq_rad);
                    deBug("angleBetweenEclipticAndHorizon: ", [abeH, ipEH]);
                    deBug("abeH, ipEH: ", [abeH, ipEH]);
                    ret.put("ECLIP_HORIZON", [abeH, ipEH]); //add angle & intersection point to the return objec
                
                }

                ret.put ("Ecliptic"+rra, [s1, s2]);
                //deBug("Ecliptic" + rra + ": ", [s1, s2]);

        }


        
        //Now all the sun events for today
        for (var i = 0; i<sunEventData.size();i++) {

            
            var kys = sunEventData.keys();        

        
            var ky = kys[i];

            //if (ky == :NOON ) { continue;}
            if (ret.hasKey(ky) ) { continue;}

            //result in hrs GMT
            //rise & set - in hours GMT
            var sun_info = getRiseSet_hr(jd,
                sunEventData[ky], Math.toRadians(lat_deg), 
                Math.toRadians(lon_deg),
                Math.toRadians(sun_RD[0]),
                Math.toRadians(sun_RD[1]),
                transit_GMT_DAY); 


            //System.println("sunrise/sets " + tz_add + timeZoneOffset_sec + " " + dst);
            var s1 = sun_info[0];
            var s2 = sun_info[1];

            if (sun_info[1] != null) { //if one is null both are
                s1 = mod ((s1 + tz_add) , 24);
                s2 = mod ( (s2 + tz_add), 24);
            } 
            
            ret.put (ky, [s1, s2]);
            //deBug(sevent_names[ky] + ": ", [s1, s2]);


            //System.println("sunrise/sets " + sun_info + " " + ky) ;
            // if (ky == :HORIZON) { System.println("sunrise/sets HORIZON: " + sun_info + " " + ky) ;}
            
        }
        //System.println("sunrise/sets " + ret);

        /*
        for (var i = 0; i<sunEventData.size();i++) {

            
            var kys = sunEventData.keys();        

        
            var ky = kys[i];
            //System.println("ret: " + ky + " " + ret[ky] + " " + sunEventData[ky]);
        }
        */

        return ret;


    }

//All angles must be in radians
//Remember Meeus considers West longitudes as positive, the opposite of how everyone else does.
//Outputs are times in hours GMT (not accounting for daylight saving time)
//From Meeus Page 101
function getRiseSet_hr(jd,h0, lat,lon,ra,dec,transit_GMT_DAY){
	//var h0=-0.8333f; //For Sun
	//var h0=-0.5667; //For stars and planets
	//const h0=0.125   //For Moon; positive value to allow for parallax  from different viewing points around the earth

    ////TEST :
    /*
    ra = Math.toRadians(269.1258593113016);
    dec = Math.toRadians(-23.43291892549076);
    lat = Math.toRadians(39.0089438);
    lon = Math.toRadians(-94.4400866);
    jd = 2460664.5;
    */
    //REsult should be: 
    /*Output
        Rise:	07:35:13
        Transit:	12:17:58
        Set:	17:00:44
        or Rise=.316122
        Transit: .51247685 (local time) / .762477 (UTC)
    */


    //deBug("getRiseSet_hr: ", [jd,h0, lat,lon,ra,dec]);
    //deBug("getRiseSet_hr: ", [jd,h0, Math.toDegrees(lat),Math.toDegrees(lon),Math.toDegrees(ra),Math.toDegrees(dec)]);

   

    if (lat == 0) {lat = 0.0000001;} //to avoid divide by zero
    if (dec == 0) {dec = 0.0000001;} //to avoid divide by zero
	var cosH=(Math.sin(h0*Math.PI/180.0)-Math.sin(lat)*Math.sin(dec)) / (Math.cos(lat)*Math.cos(dec));
    if (cosH>1 || cosH<-1) {return null;}
	var H0=Math.acos(cosH)*180.0/Math.PI;


    //deBug("transit: ", [transit, Math.toDegrees(ra), Math.toDegrees(lon), gmst]);
	var rise=transit_GMT_DAY-(H0/360.0);
	var set=transit_GMT_DAY+(H0/360.0);

    //System.println("transit (result/UTC): " + constrain(transit));

	//var ret = [constrain(transit_GMT_DAY)*24.0,constrain(rise)*24.0,constrain(set)*24.0];

    var ret = [constrain(rise)*24.0,constrain(set)*24.0];

    //System.println("transit (results/UTC): " + ret);
    return ret;
    //returns transit in DAYS....
    
    //return constrain(transit);
}

//Greenwhich mean sidreal time from Meeus page 88 eq 12.4
//Input is julian date, does not have to be 0h
//Output is angle in degrees
function GMST_deg(jd){
	var T=(jd-2451545.0)/36525.0;
	var st=280.46061837+360.98564736629*(jd-2451545.0)+0.000387933*T*T - T*T*T/38710000.0;
	//st=mod(st,360);
	//if(st<0){st+=360;}
    st = normalize(st);
    //deBug("GMST: ", [st, jd, T]);

	return st;
	//return st*Math.PI/180.0;
}

/*
function exampleMeeus(){
	var jd=2447240.5;
	var lat=Math.toRadians(42.3333);
	var lon=Math.toRadians(-71.08333);
	var gmst=Math.toRadians(177.74208);
	var ra=Math.toRadians(41.73129);
	var dec=Math.toRadians(18.44092);

	//var r=getRiseSet_hr(jd,-.833333,lat,lon,ra,dec);

    //System.println("Transit (hr): "+ r) ;


}
*/

/*
function sunPosition2(jd){
     vspo_2_J2000([0,0,0], earth, true, :ecliptic_latlon, ["Sun"]);
}

function sunPosition(jd)	{
	const torad=Math.PI/180.0;
	const n=jd-2451545.0;
	let L=(280.460+0.9856474*n)%360;
	let g=((375.528+.9856003*n)%360)*torad;
	if(L<0){L+=360;}
	if(g<0){g+=Math.PI*2.0;}

	const lamba=(L+1.915*Math.sin(g)+0.020*Math.sin(2*g))*torad;
	const beta=0.0;
	const eps=(23.439-0.0000004*n)*torad;
	let ra=Math.atan2(Math.cos(eps)*Math.sin(lamba),Math.cos(lamba));
	const dec=Math.asin(Math.sin(eps)*Math.sin(lamba));
	if(ra<0){ra+=Math.PI*2;}
	return [ra/torad/15.0,dec/torad];
}	

//Special "Math.floor()" function used by dateToJulianDate()
function INT(d){
	if(d>0){
		return Math.floor(d);
	}
	return Math.floor(d)-1;
}
*/

function gregorianDateToJulianDate(year, month, day, hour, min, sec)as Lang.double {

	var isGregorian=true;
	if(year<1582 || (year == 1582 && (month < 10 || (month==10 && day < 5)))){
		isGregorian=false;
	}

	if (month < 3){
		year = year - 1;
		month = month + 12;
	}

	var b = 0;
	if (isGregorian){
	var a = (year / 100.0).toNumber();
		b = 2 - a + (a / 4.0).toNumber();
	}

	var jd=(365.25 * (year + 4716)).toNumber() + (30.6001 * (month + 1)).toNumber() + day + b - 1524.5;
    jd = jd.toDouble();
	jd+=hour/24.0d;
	jd+=min/24.0d/60.0d;
	jd+=sec/24.0d/60.0d/60.0d;
	return jd;
}	


/*

function sunPosition(jd)	{
    const torad=Math.PI/180.0;
    const n=jd-2451545.0;
    let L=(280.460+0.9856474*n)%360;
    let g=((375.528+.9856003*n)%360)*torad;
    if(L<0){L+=360;}
    if(g<0){g+=Math.PI*2.0;}

    const lamba=(L+1.915*Math.sin(g)+0.020*Math.sin(2*g))*torad;
    const beta=0.0;
    const eps=(23.439-0.0000004*n)*torad;
    let ra=Math.atan2(Math.cos(eps)*Math.sin(lamba),Math.cos(lamba));
    const dec=Math.asin(Math.sin(eps)*Math.sin(lamba));
    if(ra<0){ra+=Math.PI*2;}
    return [ra/torad/15.0,dec/torad];
}
RA = 0h, Dec = 0° is the vernal equinox point
RA = 6h, Dec = +23.5° is the summer solstice
RA = 12h, Dec = 0° is the autumnal equinox
RA = 18h, Dec = -23.5° is the winter solstice


*/

//https://www.celestialprogramming.com/snippets/angleBetweenEclipticAndHorizon.html
//Greg Miller (gmiller@gregmiller.net) 2022
//Released as public domain
//www.celestialprogramming.com

//All angles are input and output in radians
function angleBetweenEclipticAndHorizon_rad(lat_rad,sidereal_rad,obliquity_rad){
    //Meeus 14.3

    //law of cosines (sin(latitude) because it is the  complement of the angle we are looking for, so cos(angle) = sin(complement of the angle))   
     var ret = Math.acos(Math.cos(obliquity_rad)*Math.sin(lat_rad) - Math.sin(obliquity_rad)*Math.cos(lat_rad)*Math.sin(sidereal_rad));
    deBug("angleBetweenEclipticAndHorizon: aOLS ", [Math.toDegrees(ret), Math.toDegrees(obliquity_rad), Math.toDegrees(lat_rad), Math.toDegrees(sidereal_rad)]);
     return ret;
}

function intersectionPointsEclipticHorizon_rad (lat_rad, sidereal_rad, obliquity_rad) {
    //Meeus 14.3
    /*var a = Math.cos(obliquity)*Math.sin(lat) - Math.sin(obliquity)*Math.cos(lat)*Math.sin(sidereal);
    var b = Math.cos(lat)*Math.cos(sidereal);
    var c = Math.cos(lat)*Math.sin(obliquity) + Math.sin(lat)*Math.cos(obliquity)*Math.sin(sidereal);
    var d = Math.atan2(b,a);
    var e = Math.asin(c);
    deBug("intersectionPointEclipticHorizon: ", [a,b,c,d,e]);
    return [d,e];*/
    var aEH_rad = angleBetweenEclipticAndHorizon_rad(lat_rad,sidereal_rad,obliquity_rad);

    // horEH is the distance along the horizon great circle from the intersection with the equator great circle
    // to the intersection with the ecliptic great circle.  It is measured in radians.
    var horEHint_rad  = 0;  //not sure what to return here,  Inf or null maybe.  This should represent the case where the angle is zero or 180 deg and thus  the two circles are coincident.  So 0 probably works best.:__version
    //law of sines:
    if (Math.sin(aEH_rad) != 0) {
        horEHint_rad = Math.asin( Math.sin(sidereal_rad)/ Math.sin(aEH_rad)*Math.sin(obliquity_rad));
    }

    // eclEH is the distance along the ecliptic great circle from the intersection with the equator great circle,  ie the vernal equinox, to the intersection with the horizon great circle.  It is measured in radians. (Because of symmetry it is also the angle from the fall equinox to the intersection point. But the Vernal Eq is 0,0 the origin point of the system.)
    var eclEHint_rad = 0; //similarly, 0 is probably the best choice here for  the case sin() = 0. That is the situation where the horizon & ecliptic coincide.

    if (Math.sin(aEH_rad) != 0) {
        eclEHint_rad = Math.asin( Math.sin(sidereal_rad)/ Math.sin(aEH_rad)*Math.cos(lat_rad));
    }

    var eclEHint2_rad = 0; //alternate calculation, should be equal. O/horEHint
    if (Math.sin(aEH_rad) != 0) {
        eclEHint2_rad = Math.asin( Math.sin(horEHint_rad)/Math.sin(obliquity_rad)*Math.cos(lat_rad));
    }

    //test_angleBetweenEclipticAndHorizon_rad();

    deBug("intersectionPointEclipticHorizon: ", [Math.toDegrees(eclEHint_rad), Math.toDegrees(eclEHint2_rad), Math.toDegrees(horEHint_rad)]);
    return  [eclEHint_rad, horEHint_rad];

    

}

/*
//2024/12 - tested, it works
function test_angleBetweenEclipticAndHorizon_rad(){
    var r=Math.PI/180;
    var eps=23.44*r;    
    var lat=51*r;
    var sidereal=75*r;

    var d=angleBetweenEclipticAndHorizon_rad(lat,sidereal,eps)*180/Math.PI;
    deBug("angleBetweenEclipticAndHorizon_rad TEST, Expected: "+62, []);
    deBug("angleBetweenEclipticAndHorizon_rad TEST, Computed: ", [normalize(d)]);
    
    eps=23.44*r;
    lat=38*r;
    sidereal=112.5*r;

    d=angleBetweenEclipticAndHorizon_rad(lat,sidereal,eps)*180/Math.PI;
    deBug("angleBetweenEclipticAndHorizon_rad TEST, Expected: 74.0228155356797°", []);
    deBug("angleBetweenEclipticAndHorizon_rad TEST, Computed: ", [normalize(d)]);
    
    } 
    */