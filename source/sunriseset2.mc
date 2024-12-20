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
            var g = new sunRiseSet(year, month, day, UT,dst, timeAdd_hrs, lat, lon);
            ret = g.riseSet();
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
        :BLUE_HOUR_AM => -4,
        :SUNRISE => -.833,
        :SUNRISE_END => -.3,
        :HORIZON_AM => 0,
        :GOLDEN_HOUR_AM => 6,
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
    function getRiseSetfromDate_hr(now_info, timeZoneOffset_sec, dst, time_add_hrs, lat_deg, lon_deg) {                    

        var jd = time_add_hrs /24.0f + gregorianDateToJulianDate(now_info.year, now_info.month, now_info.day, 0, 0, 0);

        //get ra & dec for sun from VSOP87a
        //var ra = 0;
        //var dec = 0;



        //return is: [Math.toDegrees(l), Math.toDegrees(t2), r];//lat, lon, r
        var sun_radec = planetCoord (now_info, timeZoneOffset_sec, dst, time_add_hrs, :ecliptic_latlon, ["Sun"]);

        System.println("sun_radec: " + (sun_radec["Sun"][0]) + " " + (sun_radec["Sun"][1]));

        var first = false;
        var ret = {};

        for (var i = 0; i<sunEventData.size();i++) {

            
            var kys = sunEventData.keys();        

        
            var ky = kys[i];

            if (ky == :NOON) { continue;}

            //result in hrs GMT
            var sun_info = getRiseSet_hr(jd,
                sunEventData[ky], Math.toRadians(lat_deg), 
                Math.toRadians(lon_deg),
                Math.toRadians(sun_radec["Sun"][0]),
                Math.toRadians(sun_radec["Sun"][1])); //transit of Sun in hours for this place/date

            //correct for time zone & dst

            var tz_add = (timeZoneOffset_sec/3600.0f) + dst;

            System.println("sunrise/sets " + tz_add + timeZoneOffset_sec + " " + dst);
            var s1 = sun_info[1];
            var s2 = sun_info[2];

            if (sun_info[1] != null) { //if one is null both are
                s1 = mod ((s1 + tz_add) , 24);
                s2 = mod ( s2 + tz_add, 24);
            } 
            
            ret.put (ky, [s1, s2]);
            
            if (first) {ret.put ("Noon", [ sun_info[0] + tz_add, sun_info[0] + tz_add]);}
            first = false;

            System.println("sunrise/sets " + sun_info + " " + ky) ;
            
        }
        System.println("sunrise/sets " + ret);

        return ret;


    }

//All angles must be in radians
//Remember Meeus considers West longitudes as positive, the opposite of how everyone else does.
//Outputs are times in hours GMT (not accounting for daylight saving time)
//From Meeus Page 101
function getRiseSet_hr(jd,h0, lat,lon,ra,dec){
	//var h0=-0.8333f; //For Sun
	//var h0=-0.5667; //For stars and planets
	//const h0=0.125   //For Moon

    lon = -lon; //Meeus uses West longitudes as positive - this is to correct for that

    if (lat == 0) {lat = 0.0000001;} //to avoid divide by zero
    if (dec == 0) {dec = 0.0000001;} //to avoid divide by zero
	var cosH=(Math.sin(h0*Math.PI/180.0)-Math.sin(lat)*Math.sin(dec)) / (Math.cos(lat)*Math.cos(dec));
    if (cosH>1 || cosH<-1) {return null;}
	var H0=Math.acos(cosH)*180.0/Math.PI;

	var gmst=GMST(Math.floor(jd)+.5);

	var transit=(Math.toDegrees(ra)+Math.toDegrees(lon)-gmst)/360.0;
	var rise=transit-(H0/360.0);
	var set=transit+(H0/360.0);

    System.println("transit (result/UTC): " + constrain(transit));

	var ret = [constrain(transit)*24.0,constrain(rise)*24.0,constrain(set)*24.0];

    System.println("transit (results/UTC): " + ret);
    return ret;
    //returns transit in DAYS....
    
    //return constrain(transit);
}

//Greenwhich mean sidreal time from Meeus page 88 eq 12.4
//Input is julian date, does not have to be 0h
//Output is angle in degrees
function GMST(jd){
	var T=(jd-2451545.0)/36525.0;
	var st=280.46061837+360.98564736629*(jd-2451545.0)+0.000387933*T*T - T*T*T/38710000.0;
	st=mod(st,360);
	if(st<0){st+=360;}

	return st;
	//return st*Math.PI/180.0;
}

function exampleMeeus(){
	var jd=2447240.5;
	var lat=Math.toRadians(42.3333);
	var lon=Math.toRadians(-71.08333);
	var gmst=Math.toRadians(177.74208);
	var ra=Math.toRadians(41.73129);
	var dec=Math.toRadians(18.44092);

	var r=getRiseSet_hr(jd,-.833333,lat,lon,ra,dec);

    System.println("Transit (hr): "+ r) ;


}

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

function gregorianDateToJulianDate(year, month, day, hour, min, sec){

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
	jd+=hour/24.0;
	jd+=min/24.0/60.0;
	jd+=sec/24.0/60.0/60.0;
	return jd;
}	
