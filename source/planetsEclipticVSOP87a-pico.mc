import Toybox.Math;
import Toybox.System;
import Toybox.Lang; 

var storRand = {};
var storLastR = {};

class VSOP87_cache{

    var g_cache;
    var indexes;
    var MAX_CACHE = 0;

    function initialize () {
        

        //planetoncenter = $.Geocentric.planetoncenter;
        //objectlist = $.Geocentric.objectlist;
        g_cache = {};
        indexes = [];
    }

    function fetch (now_info, timeZoneOffset_sec, dst, timeAdd_hrs, type) {
        //System.println("fetch... ");
                    
        //since we must incl lat & lon to get a sensible answer, might as well
        //includ UT & dst as well, as those are localized in the same way     
        var typ = "elip";
        if (type != :ecliptic_latlon) {typ = "xyz";}    

        var time_mod = Math.round(0.0d + timeAdd_hrs/24.0d + julianDate(now_info.year, now_info.month, now_info.day, 0, 0, timeZoneOffset_sec/3600.0, dst)).toNumber();
        var index = time_mod + "|"+ typ;
        //System.println("CACHE: " + index);
        var ret;

        var myStats = System.getSystemStats();

        System.println("Memory/VSOP222: " + myStats.totalMemory + " " + myStats.usedMemory + " " + myStats.freeMemory + " MAX_CACHE: " + MAX_CACHE);
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
                if (MAX_CACHE < 1) { MAX_CACHE = 1; }
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
            var vsop = new vsop87a_pico();
            ret = vsop.planetCoord(now_info, timeZoneOffset_sec, dst, timeAdd_hrs, type);
            vsop = null;
            //kys = ret.keys();
            if ((MAX_CACHE > 0 && type == :ecliptic_latlon) ||  
                myStats.freeMemory>100000)  {
                    g_cache.put(index,ret);
                    indexes.add(index);
                }
        }                    

        return ret;
    }

    public function empty () {
        g_cache = null;
        indexes = null;
        g_cache = {};
        indexes = [];
    }
    
}

//VSOP87-Multilang http://www.celestialprogramming.com/
//Greg Miller (gmiller@gregmiller.net) 2021.  Released as Public Domain
//VSOP87a PICO - JAVASCRIPT version with minor tweaks
//https://github.com/gmiller123456/vsop87-multilang/blob/master/Languages/JavaScript/vsop87a_pico.js

class vsop87a_pico{


    var j2000= 2451543.5d; //epoch used for some calculations (Pluto) from Ioannis

    // types are :ecliptic_latlon and :helio_xyz
    public function planetCoord (now_info, timeZoneOffset_sec, dst, timeAdd_hrs, type) {

        //var sml_days  = synodicMonthLength_days(now_info, timeZoneOffset_sec, dst );
        //var base_JD = julianDate (2025, 1, 29 , 12, 36, 0, 0);
        var JD1 = julianDate (now_info.year, now_info.month, now_info.day,now_info.hour, now_info.min, timeZoneOffset_sec/3600, dst);
        var JD = JD1 + timeAdd_hrs/24.0d;

        var t=(JD - 2451545.0d) / 365250.0d;

        //var j2000= 2451543.5d;
        //var d= JD ;

        var earth = getEarth(t);

        //change vantage point to earth & return lat/lon angles relative to ecliptic
        //Trick is to switch Earth & Sun, but -x, -y, -z that way  we have a
        //"sun position" even though it was all calculated with Sun  as the center
        var ret = {
            "Mercury" => vspo_2_J2000(getMercury(t), earth, true, type),
            "Venus" => vspo_2_J2000(getVenus(t), earth, true, type),
            //"Earth" => vspo_2_J2000(getEarth(t), earth, true, type),
            "Mars" => vspo_2_J2000(getMars(t), earth, true, type),
            "Jupiter" => vspo_2_J2000(getJupiter(t), earth, true, type),
            "Saturn" => vspo_2_J2000(getSaturn(t), earth, true, type),
            "Uranus" => vspo_2_J2000(getUranus(t), earth, true, type),
            "Neptune" => vspo_2_J2000(getNeptune(t), earth, true, type),
            "Sun" => vspo_2_J2000([0,0,0], earth, true, type),
            "Pluto" => vspo_2_J2000(getPluto(JD), earth, false, type),
        };
        

        if (planetsOption_value == 0 && type == :helio_xyz) {

            ret.put ("Eris", vspo_2_J2000(getEris(JD), earth, false, type));
            ret.put ("Chiron", vspo_2_J2000(getChiron(JD), earth, false, type));
            ret.put ("Ceres", vspo_2_J2000(getCeres(JD), earth, false, type));
            
            ret.put ("Gonggong", vspo_2_J2000(getGonggong(JD), earth, false, type));
            ret.put ("Quaoar", vspo_2_J2000(getQuaoar(JD), earth, false, type));
            ret.put ("Makemake", vspo_2_J2000(getMakemake(JD), earth, false, type));
            ret.put ("Haumea", vspo_2_J2000(getHaumea(JD), earth, false, type));
        }
        

        //keep vantage point as Sun and return XYZ coords
        //now we need Sun back at [0,0,0] and add earth as normal

        if (type == :helio_xyz) {
            ret ["Sun"] = [0,0,0];
            ret.put("Earth", vspo_2_J2000(earth, earth, true, type));
        }
        
        return ret;
    }

    // types are :ecliptic_latlon and :helio_xyz
    public function vspo_2_J2000(input, earth, vsop, type) {
       
        var x = input[0];
        var y = input [1];
        var z = input [2];
       if (type == :ecliptic_latlon) { 
         x = input[0] - earth[0];
         y = input [1]- earth[1];
         z = input [2]- earth[2];
       }

       var tx = x;
       var ty = y;
       var tz = z;

    if (vsop) {
     //Rotate from VSOP coordinates to J2000
      tx = (x + y * 0.000000440360 + z * -0.000000190919);
      ty = (x * -0.000000479966 + y * 0.917482137087 + z * -0.397776982902);
      tz = (y * 0.397776982902 + z * 0.917482137087);
    }

    if (type == :helio_xyz) {return [tx,ty,tz];}

    //System.println("XYZ: " + tx + " " + ty + " " + tz);
    //Convert from Cartesian to polar coordinates 
    var r = Math.sqrt(tx * tx + ty * ty + tz * tz);
    var l = Math.atan2(ty, tx);
    var t2 = 0;
    if (r != 0 ) { t2 = Math.acos(tz / r); }

    //System.println("LTr: " + l + " " + t2 + " " + r);


    //Make sure RA is positive, and Dec is in range +/-90
    if (l < 0) { l += 2 * Math.PI; }
    t2 = .5 * Math.PI - t2;

    //Uncomment to return results in hours and degrees rather than radians
    //return {ra: l*180/Math.PI/15, dec: t2*180/Math.PI, r: r};
    //return {ra: l, dec: t2, r: r};
    //return {:lat=> Math.toDegrees(l), :lon => Math.toDegrees(t2), :r => r};
    return [Math.toDegrees(l), Math.toDegrees(t2), r];//lat, lon, r
    }

    
   function getMercury(t){
      var temp=[0.0, 0.0, 0.0];
      temp[0]=mercury_x(t);
      temp[1]=mercury_y(t);
      temp[2]=mercury_z(t);

      return temp;
   }

   function getVenus(t){
      var temp=[0.0, 0.0, 0.0];
      temp[0]=venus_x(t);
      temp[1]=venus_y(t);
      temp[2]=venus_z(t);

      return temp;
   }

   function getEarth(t){
      var temp=[0.0, 0.0, 0.0];
      temp[0]=earth_x(t);
      temp[1]=earth_y(t);
      temp[2]=earth_z(t);

      return temp;
   }

   function getMars(t){
      var temp=[0.0, 0.0, 0.0];
      temp[0]=mars_x(t);
      temp[1]=mars_y(t);
      temp[2]=mars_z(t);

      return temp;
   }

   function getJupiter(t){
      var temp=[0.0, 0.0, 0.0];
      temp[0]=jupiter_x(t);
      temp[1]=jupiter_y(t);
      temp[2]=jupiter_z(t);

      return temp;
   }

   function getSaturn(t){
      var temp=[0.0, 0.0, 0.0];
      temp[0]=saturn_x(t);
      temp[1]=saturn_y(t);
      temp[2]=saturn_z(t);

      return temp;
   }

   function getUranus(t){
      var temp=[0.0, 0.0, 0.0];
      temp[0]=uranus_x(t);
      temp[1]=uranus_y(t);
      temp[2]=uranus_z(t);

      return temp;
   }

   function getNeptune(t){
      var temp=[0.0, 0.0, 0.0];
      temp[0]=neptune_x(t);
      temp[1]=neptune_y(t);
      temp[2]=neptune_z(t);

      return temp;
   }

   function getEmb(t){
      var temp=[0.0, 0.0, 0.0];
      temp[0]=emb_x(t);
      temp[1]=emb_y(t);
      temp[2]=emb_z(t);

      return temp;
   }

   function getMoon(earth, emb){
      var temp=[0.0, 0.0, 0,0];

      temp[0]=(emb[0]-earth[0])*(1 + 1 / 0.01230073677);
      temp[1]=(emb[1]-earth[1])*(1 + 1 / 0.01230073677);
      temp[2]=(emb[2]-earth[2])*(1 + 1 / 0.01230073677);
      temp[0]=temp[0]+earth[0];
      temp[1]=temp[1]+earth[1];
      temp[2]=temp[2]+earth[2];

      return temp;
   }

   function venus_z(t){
      var venus_z_0 = 0.0;

      venus_z_0 += 0.04282990302 * Math.cos(0.26703856476 + 10213.28554621100d*t);
      return venus_z_0;
   }

   function venus_y(t){
      var venus_y_0 = 0.0;

      venus_y_0 += 0.72324820731 * Math.cos(1.60573808356 + 10213.28554621100d*t);
      return venus_y_0;
   }

   function venus_x(t){
      var venus_x_0 = 0.0;

      venus_x_0 += 0.72211281391 * Math.cos(3.17575836361 + 10213.28554621100d*t);
      return venus_x_0;
   }

   function uranus_z(t){
      var uranus_z_0 = 0.0;

      uranus_z_0 += 0.01774318778 * Math.cos(3.14159265359 + 0.00000000000d*t);
      uranus_z_0 += 0.25878127698 * Math.cos(2.61861272578 + 74.78159856730d*t);
      return uranus_z_0;
   }

   function uranus_y(t){
      var uranus_y_1 = 0.0;

      uranus_y_1 += 0.02157896385 * Math.cos(0.00000000000 + 0.00000000000d*t);
      uranus_y_1=uranus_y_1*t;

      var uranus_y_0 = 0.0;

      uranus_y_0 += 0.01442356575 * Math.cos(1.08004542712 + 148.07872442630d*t);
      uranus_y_0 += 0.01542668264 * Math.cos(2.55040539213 + 224.34479570190d*t);
      uranus_y_0 += 0.06250078231 * Math.cos(3.56960243857 + 1.48447270830d*t);
      uranus_y_0 += 0.14123958128 * Math.cos(2.82486076549 + 76.26607127560d*t);
      uranus_y_0 += 0.14755940186 * Math.cos(1.85423280679 + 73.29712585900d*t);
      uranus_y_0 += 0.16256125476 * Math.cos(3.14159265359 + 0.00000000000d*t);
      uranus_y_0 += 0.44390465203 * Math.cos(0.08884111329 + 149.56319713460d*t);
      uranus_y_0 += 19.16518231584 * Math.cos(3.91045677002 + 74.78159856730d*t);
      return uranus_y_1+uranus_y_0;
   }

   function uranus_x(t){
      var uranus_x_0 = 0.0;

      uranus_x_0 += 0.01444216660 * Math.cos(2.65117115201 + 148.07872442630d*t);
      uranus_x_0 += 0.01542951343 * Math.cos(4.12121838072 + 224.34479570190d*t);
      uranus_x_0 += 0.06201106178 * Math.cos(5.14043574125 + 1.48447270830d*t);
      uranus_x_0 += 0.14130269479 * Math.cos(4.39572927934 + 76.26607127560d*t);
      uranus_x_0 += 0.14668209481 * Math.cos(3.42395862804 + 73.29712585900d*t);
      uranus_x_0 += 0.44402496796 * Math.cos(1.65967519586 + 149.56319713460d*t);
      uranus_x_0 += 1.32272523872 * Math.cos(0.00000000000 + 0.00000000000d*t);
      uranus_x_0 += 19.17370730359 * Math.cos(5.48133416489 + 74.78159856730d*t);
      return uranus_x_0;
   }

   function saturn_z(t){
      var saturn_z_1 = 0.0;

      saturn_z_1 += 0.01906503283 * Math.cos(4.94544746116 + 213.29909543800d*t);
      saturn_z_1=saturn_z_1*t;

      var saturn_z_0 = 0.0;

      saturn_z_0 += 0.01214249867 * Math.cos(0.00000000000 + 0.00000000000d*t);
      saturn_z_0 += 0.01148283576 * Math.cos(2.85128367469 + 426.59819087600d*t);
      saturn_z_0 += 0.41356950940 * Math.cos(3.60234142982 + 213.29909543800d*t);
      return saturn_z_1+saturn_z_0;
   }

   function saturn_y(t){
      var saturn_y_1 = 0.0;

      saturn_y_1 += 0.02647489677 * Math.cos(3.76132298889 + 220.41264243880d*t);
      saturn_y_1 += 0.02741594312 * Math.cos(4.26667636015 + 206.18554843720d*t);
      saturn_y_1 += 0.03090575152 * Math.cos(2.70346890906 + 426.59819087600d*t);
      saturn_y_1 += 0.05373889135 * Math.cos(0.00000000000 + 0.00000000000d*t);
      saturn_y_1=saturn_y_1*t;

      var saturn_y_0 = 0.0;

      saturn_y_0 += 0.01098751131 * Math.cos(4.08608782813 + 639.89728631400d*t);
      saturn_y_0 += 0.01245790434 * Math.cos(0.60367177975 + 110.20632121940d*t);
      saturn_y_0 += 0.01183874652 * Math.cos(1.34638298371 + 419.48464387520d*t);
      saturn_y_0 += 0.02345609742 * Math.cos(0.44652132519 + 7.11354700080d*t);
      saturn_y_0 += 0.06633570703 * Math.cos(5.46258848288 + 220.41264243880d*t);
      saturn_y_0 += 0.06916653915 * Math.cos(2.55279408706 + 206.18554843720d*t);
      saturn_y_0 += 0.26441781302 * Math.cos(4.83528061849 + 426.59819087600d*t);
      saturn_y_0 += 0.79387988806 * Math.cos(3.14159265359 + 0.00000000000d*t);
      saturn_y_0 += 9.52986882699 * Math.cos(5.58600556665 + 213.29909543800d*t);
      return saturn_y_1+saturn_y_0;
   }

   function saturn_x(t){
      var saturn_x_1 = 0.0;

      saturn_x_1 += 0.02643100909 * Math.cos(5.33291950584 + 220.41264243880d*t);
      saturn_x_1 += 0.02714918399 * Math.cos(5.85229412397 + 206.18554843720d*t);
      saturn_x_1 += 0.03085041716 * Math.cos(4.27565749128 + 426.59819087600d*t);
      saturn_x_1 += 0.07575103962 * Math.cos(0.00000000000 + 0.00000000000d*t);
      saturn_x_1=saturn_x_1*t;

      var saturn_x_0 = 0.0;

      saturn_x_0 += 0.01097683232 * Math.cos(5.65753337256 + 639.89728631400d*t);
      saturn_x_0 += 0.01115684467 * Math.cos(3.15686878377 + 419.48464387520d*t);
      saturn_x_0 += 0.01255372247 * Math.cos(2.17338917731 + 110.20632121940d*t);
      saturn_x_0 += 0.02336340488 * Math.cos(2.02227784673 + 7.11354700080d*t);
      saturn_x_0 += 0.04244797817 * Math.cos(0.00000000000 + 0.00000000000d*t);
      saturn_x_0 += 0.06624260115 * Math.cos(0.75094737780 + 220.41264243880d*t);
      saturn_x_0 += 0.06760430339 * Math.cos(4.16767145778 + 206.18554843720d*t);
      saturn_x_0 += 0.26412374238 * Math.cos(0.12390892620 + 426.59819087600d*t);
      saturn_x_0 += 9.51638335797 * Math.cos(0.87441380794 + 213.29909543800d*t);
      return saturn_x_1+saturn_x_0;
   }

   function neptune_z(t){
      var neptune_z_0 = 0.0;

      neptune_z_0 += 0.01245978462 * Math.cos(0.00000000000 + 0.00000000000d*t);
      neptune_z_0 += 0.92866054405 * Math.cos(1.44103930278 + 38.13303563780d*t);
      return neptune_z_0;
   }

   function neptune_y(t){
      var neptune_y_0 = 0.0;

      neptune_y_0 += 0.01073739772 * Math.cos(3.81371728533 + 74.78159856730d*t);
      neptune_y_0 += 0.02584250749 * Math.cos(0.42549700754 + 1.48447270830d*t);
      neptune_y_0 += 0.14936165806 * Math.cos(5.79694900665 + 39.61750834610d*t);
      neptune_y_0 += 0.15706589373 * Math.cos(4.82539970129 + 36.64856292950d*t);
      neptune_y_0 += 0.13506391797 * Math.cos(1.92953034883 + 76.26607127560d*t);
      neptune_y_0 += 0.30205857683 * Math.cos(3.14159265359 + 0.00000000000d*t);
      neptune_y_0 += 30.06056351665 * Math.cos(3.74086294714 + 38.13303563780d*t);
      return neptune_y_0;
   }

   function neptune_x(t){
      var neptune_x_0 = 0.0;

      neptune_x_0 += 0.01074040708 * Math.cos(5.38502938672 + 74.78159856730d*t);
      neptune_x_0 += 0.02597313814 * Math.cos(1.99590301412 + 1.48447270830d*t);
      neptune_x_0 += 0.14935120126 * Math.cos(1.08499403018 + 39.61750834610d*t);
      neptune_x_0 += 0.15726094556 * Math.cos(0.11319072675 + 36.64856292950d*t);
      neptune_x_0 += 0.13505661755 * Math.cos(3.50078975634 + 76.26607127560d*t);
      neptune_x_0 += 0.27080164222 * Math.cos(3.14159265359 + 0.00000000000d*t);
      neptune_x_0 += 30.05890004476 * Math.cos(5.31211340029 + 38.13303563780d*t);
      return neptune_x_0;
   }

   function mercury_z(t){
      var mercury_z_0 = 0.0;

      mercury_z_0 += 0.04607665326 * Math.cos(1.99295081967 + 26087.90314157420d*t);
      return mercury_z_0;
   }

   function mercury_y(t){
      var mercury_y_0 = 0.0;

      mercury_y_0 += 0.03854668215 * Math.cos(5.88780608966 + 52175.80628314840d*t);
      mercury_y_0 += 0.11626131831 * Math.cos(3.14159265359 + 0.00000000000d*t);
      mercury_y_0 += 0.37953642888 * Math.cos(2.83780617820 + 26087.90314157420d*t);
      return mercury_y_0;
   }

   function mercury_x(t){
      var mercury_x_0 = 0.0;

      mercury_x_0 += 0.02625615963 * Math.cos(3.14159265359 + 0.00000000000d*t);
      mercury_x_0 += 0.03825746672 * Math.cos(1.16485604339 + 52175.80628314840d*t);
      mercury_x_0 += 0.37546291728 * Math.cos(4.39651506942 + 26087.90314157420d*t);
      return mercury_x_0;
   }

   function mars_z(t){
      var mars_z_0 = 0.0;

      mars_z_0 += 0.04901207220 * Math.cos(3.76712324286 + 3340.61242669980d*t);
      return mars_z_0;
   }

   function mars_y(t){
      var mars_y_1 = 0.0;

      mars_y_1 += 0.01427324210 * Math.cos(3.14159265359 + 0.00000000000d*t);
      mars_y_1=mars_y_1*t;

      var mars_y_0 = 0.0;

      mars_y_0 += 0.08655481102 * Math.cos(0.00000000000 + 0.00000000000d*t);
      mars_y_0 += 0.07064550239 * Math.cos(4.97051892902 + 6681.22485339960d*t);
      mars_y_0 += 1.51558976277 * Math.cos(4.63212206588 + 3340.61242669980d*t);
      return mars_y_1+mars_y_0;
   }

   function mars_x(t){
      var mars_x_0 = 0.0;

      mars_x_0 += 0.07070919655 * Math.cos(0.25870338558 + 6681.22485339960d*t);
      mars_x_0 += 0.19502945246 * Math.cos(3.14159265359 + 0.00000000000d*t);
      mars_x_0 += 1.51769936383 * Math.cos(6.20403346548 + 3340.61242669980d*t);
      return mars_x_0;
   }

   function jupiter_z(t){
      var jupiter_z_0 = 0.0;

      jupiter_z_0 += 0.11823100489 * Math.cos(3.55844646343 + 529.69096509460d*t);
      return jupiter_z_0;
   }

   function jupiter_y(t){
      var jupiter_y_1 = 0.0;

      jupiter_y_1 += 0.01694798253 * Math.cos(3.14159265359 + 0.00000000000d*t);
      jupiter_y_1=jupiter_y_1*t;

      var jupiter_y_0 = 0.0;

      jupiter_y_0 += 0.01475809370 * Math.cos(2.04679566495 + 536.80451209540d*t);
      jupiter_y_0 += 0.01508275299 * Math.cos(5.43934968102 + 522.57741809380d*t);
      jupiter_y_0 += 0.09363670616 * Math.cos(3.14159265359 + 0.00000000000d*t);
      jupiter_y_0 += 0.12592862602 * Math.cos(5.66160227728 + 1059.38193018920d*t);
      jupiter_y_0 += 5.19520046589 * Math.cos(5.31203162731 + 529.69096509460d*t);
      return jupiter_y_1+jupiter_y_0;
   }

   function jupiter_x(t){
      var jupiter_x_0 = 0.0;

      jupiter_x_0 += 0.01476224578 * Math.cos(3.61736921122 + 536.80451209540d*t);
      jupiter_x_0 += 0.01500672056 * Math.cos(0.73175134610 + 522.57741809380d*t);
      jupiter_x_0 += 0.12593937922 * Math.cos(0.94911583701 + 1059.38193018920d*t);
      jupiter_x_0 += 0.36662642320 * Math.cos(3.14159265359 + 0.00000000000d*t);
      jupiter_x_0 += 5.19663470114 * Math.cos(0.59945082355 + 529.69096509460d*t);
      return jupiter_x_0;
   }

   function emb_z(t){
      return 0;
   }

   function emb_y(t){
      var emb_y_0 = 0.0;

      emb_y_0 += 0.02442698841 * Math.cos(3.14159265359 + 0.00000000000d*t);
      emb_y_0 += 0.99989209645 * Math.cos(0.18265890456 + 6283.07584999140d*t);
      return emb_y_0;
   }

   function emb_x(t){
      var emb_x_0 = 0.0;

      emb_x_0 += 0.99982927460 * Math.cos(1.75348568475 + 6283.07584999140d*t);
      return emb_x_0;
   }

   /// ORIGINAL PICO
   /*
   function earth_z(t){
      return 0;
   }

   function earth_y(t){
      var earth_y_0 = 0.0;

      earth_y_0 += 0.02442699036 * Math.cos(3.14159265359 + 0.00000000000d*t);
      earth_y_0 += 0.99989211030 * Math.cos(0.18265890456 + 6283.07584999140d*t);
      return earth_y_0;
   }

   function earth_x(t){
      var earth_x_0 = 0.0;

      earth_x_0 += 0.99982928844 * Math.cos(1.75348568475 + 6283.07584999140d*t);
      return earth_x_0;
   }
   */

      function earth_z(t){
      return 0.00227822442 * Math.cos(3.41372504278 + 6283.07584999140d*t)*t;
   }

   function earth_y(t){
        var y = 0.0;
        y = 0.00010466965 * Math.cos(0.09641690558 + 18849.22754997420d*t);
        y += 0.00835292314 * Math.cos(0.13952878991 + 12566.15169998280d*t) -0.02442699036;
        y += 0.99989211030 * Math.cos(0.18265890456 + 6283.07584999140d*t);
        y += (0.00093046324 + 0.00051506609 * Math.cos(4.43180499286 + 12566.15169998280d*t))*t;
      return y;
   }

   function earth_x(t){
       
       var x = 0.00561144206 + 0.00010466628 * Math.cos(1.66722645223 + 18849.22754997420d*t);
        x += 0.00835257300 * Math.cos(1.71034539450 + 12566.15169998280d*t);
        x += 0.99982928844 * Math.cos(1.75348568475 + 6283.07584999140d*t);
        x += (0.00123403056 + 0.00051500156 * Math.cos(6.00266267204 + 12566.15169998280d*t))*t;
      return x;
   }

   
   public function getPluto (d) {

           //ploutonas - Pluto
        d = d - j2000;

        var S_pl  = Math.toRadians(  50.03  +  0.033459652 *  d);
        var P_pl  = Math.toRadians( 238.95  +  0.003968789 *  d);
        
        var long2_pl = (238.9508  +  0.00400703 * d - 19.799 * Math.sin(P_pl)
                     + 19.848 * Math.cos(P_pl) + 0.897 * Math.sin(2*P_pl)
               - 4.956 * Math.cos(2*P_pl) + 0.610 * Math.sin(3*P_pl)
               + 1.211 * Math.cos(3*P_pl) - 0.341 * Math.sin(4*P_pl)
               - 0.190 * Math.cos(4*P_pl) + 0.128 * Math.sin(5*P_pl)
               - 0.034 * Math.cos(5*P_pl) - 0.038 * Math.sin(6*P_pl)
               + 0.031 * Math.cos(6*P_pl) + 0.020 * Math.sin(S_pl - P_pl) 
               - 0.010 * Math.cos(S_pl - P_pl) );
        var lat2_pl = ( -3.9082 - 5.453 * Math.sin(P_pl) - 14.975 * Math.cos(P_pl)
                      + 3.527 * Math.sin(2*P_pl) + 1.673 * Math.cos(2*P_pl)
                      - 1.051 * Math.sin(3*P_pl) + 0.328 * Math.cos(3*P_pl)
                      + 0.179 * Math.sin(4*P_pl) - 0.292 * Math.cos(4*P_pl)
                      + 0.019 * Math.sin(5*P_pl) + 0.100 * Math.cos(5*P_pl)
                      - 0.031 * Math.sin(6*P_pl) - 0.026 * Math.cos(6*P_pl)
                      + 0.011 * Math.cos(S_pl - P_pl) );
        var r_pl = ( 40.72 + 6.68 * Math.sin(P_pl) + 6.90 * Math.cos(P_pl)
                      - 1.18 * Math.sin(2*P_pl) - 0.03 * Math.cos(2*P_pl)
                      + 0.15 * Math.sin(3*P_pl) - 0.14 * Math.cos(3*P_pl));
        
        long2_pl=Math.toRadians(long2_pl);
        lat2_pl=Math.toRadians(lat2_pl);
        var x = r_pl * Math.cos(long2_pl) * Math.cos(lat2_pl); //eclip
        var y = r_pl * Math.sin(long2_pl) * Math.cos(lat2_pl);
        var z = r_pl * Math.sin(lat2_pl);
        return [x, y, z];
   }
   public function getEris (d){
        /*
           //A ERIS epoch  2456400.5 2013-apr-18.0   j2000= 2451543.5;
        var epoch = 2456400.5   
        var d_new= d + 2451543.5 - epoch;
        
        var N=36.0308972598494  ; //QR
        var i=43.88534676566927 ; //IN
        var w=150.8002573158863 ; //W
        var a=67.95784302407351 ;  //A
        var e=0.4370835020505101 ; //EC
        var M=203.2157808586589 +  0.001759319413340421 * d_new;
        */

        var EPOCH=  2457996.5;
        var EC= .441713222152167;
        var QR= 37.76778537485207;   
        //var TP= 2545579.0049365791;      
        //var OM= 35.87796152910861;   
        var W=  151.5251501002852;   
        var IN= 44.2037909086797;  
        var  A= 67.6494355113423;  
        var  MA= 204.8595058015323;  
        var  N= .001771364;

        var newE = randomizeOrbit ("Eris", EC, QR, W, IN, A, MA, d);

        var d_new= d - EPOCH;
        var M = MA + N * d_new;
        
        M=normalize(M);

        var ret = Planet_Sun(M, newE[:EC], newE[:A], newE[:QR], newE[:W], newE[:IN]);
        $.storLastR ["Eris"] = Math.sqrt(ret[0]*ret[0] + ret[1]*ret[1] + ret[2]*ret[2]);
        //System.println("XYZ: " + ret[0] + " " + ret[1] + " " + ret[2]);
        return ret;

   }
   public function getCeres (d){
     /*
           var ddd = d + 2451543.5 - 2455400.5;
        
        var N_ce=80.39319901972638  + 1.1593E-5 *ddd;
        var i_ce=10.58682160714853 - 2.2048E-6*ddd;
        var w_ce=72.58981198193074  + 1.84E-5*ddd;
        var a_ce=2.765348506018043 ;
        var e_ce=0.07913825487621974 + 1.8987E-8*ddd;
        var M_ce=113.4104433863731   + 0.21408169952325  * ddd ;
        */
 
        var EPOCH=  2458849.5;
     
        var EC= .07687465013145245;  
        var QR= 2.556401146697176;   
        //var TP= 2458240.1791309435;
        //var OM= 80.3011901917491;    
        var W=  73.80896808746482;   
        var IN= 10.59127767086216;
        var A= 2.769289292143484;    
        var MA= 130.3159688200986;   
        //var ADIST= 2.982177437589792;
        //var  PER= 4.60851            ;
        var N= .213870844 ;

        var newE = randomizeOrbit ("Ceres", EC, QR, W, IN, A, MA, d);



        var d_new= d - EPOCH;
        var M = MA + N * d_new;
        
        M=normalize(M);

        var ret = Planet_Sun(M, newE[:EC], newE[:A], newE[:QR], newE[:W], newE[:IN]);
        $.storLastR ["Ceres"] = Math.sqrt(ret[0]*ret[0] + ret[1]*ret[1] + ret[2]*ret[2]);
        //System.println("XYZ: " + ret[0] + " " + ret[1] + " " + ret[2]);
        return ret;

   }

   public function getChiron (d){

      //https://ssd.jpl.nasa.gov/horizons/app.html#/
      var EPOCH=  2457535.5; // ! 2016-May-27.00 (TDB)         Residual RMS= .19998
      var EC= .3827260124508142;   
      var QR= 8.418796919952825;   
      //var TP= 2450138.5315822391;
      //var OM= 209.2210850370517;   
      var W=  339.5128645055728;   
      var IN= 6.946297035265285;
      var A= 13.63867114079872;
      var MA= 144.7437272459811;   
      //var ADIST= 18.85854536164461;
      //var PER= 50.36934          ; 
      var N= .01956798 ;

      var newE = randomizeOrbit ("Chiron", EC, QR, W, IN, A, MA, d);



        var d_new= d - EPOCH;
        var M = MA + N * d_new;
        
        M=normalize(M);

        //return Planet_Sun(M, EC, A, QR, W, IN);

        var ret = Planet_Sun(M, newE[:EC], newE[:A], newE[:QR], newE[:W], newE[:IN]);
        $.storLastR ["Chiron"] = Math.sqrt(ret[0]*ret[0] + ret[1]*ret[1] + ret[2]*ret[2]);
        //System.println("XYZ: " + ret[0] + " " + ret[1] + " " + ret[2]);
        return ret;

   }
  public function getGonggong(d){

    //225088 Gonggong (2007 OR10)

     var EPOCH=  2457964.5; // ! 2017-Jul-30.00 (TDB)         Residual RMS= .10926
     var EC= .505928166740521;
     var     QR= 33.17018711494477;
     //var   TP= 2399628.8293997725;
     //var   OM= 336.8249678431149;
     var    W=  207.173549840275;
     var     IN= 30.87334176604489;
     var    A= 67.1363653663784;
     var      MA= 104.5205123804387;
     //       ADIST= 101.102543617812   PER= 550.10417          
     var N= .001791708;

     var newE = randomizeOrbit ("Gonggong", EC, QR, W, IN, A, MA, d);

        var d_new= d - EPOCH;
        var M = newE[:MA] + N * d_new;
        
        M=normalize(M);

        var ret = Planet_Sun(M, newE[:EC], newE[:A], newE[:QR], newE[:W], newE[:IN]);
        $.storLastR ["Gonggong"] = Math.sqrt(ret[0]*ret[0] + ret[1]*ret[1] + ret[2]*ret[2]);
        //System.println("XYZ: " + ret[0] + " " + ret[1] + " " + ret[2]);
        return ret;
  } 

  //Quaoar
  public function getQuaoar(d){

      //225088 Gonggong (2007 OR10)
      var name = "Quaoar";

      var EPOCH=  2459800.5; // ! 2022-Aug-09.00 (TDB)         Residual RMS= .21356
      var EC= .04098702510897952  ;
      var QR= 41.69021570747672  ; 
      //var TP= 2478347.5347988536;
      //var OM= 189.0902949942479  ; 
      var W=  155.214428533145  ;  
      var IN= 7.991232171849933;
      var A= 43.47200381956696    ;
      var MA= 296.2230021720905   ;
      //var ADIST= 45.25379193165721
      //var PER= 286.63069          
      var N= .003438663;

      var newE = randomizeOrbit (name, EC, QR, W, IN, A, MA, d);

      var d_new= d - EPOCH;
      var M = newE[:MA] + N * d_new;
            
         M=normalize(M);

         var ret = Planet_Sun(M, newE[:EC], newE[:A], newE[:QR], newE[:W], newE[:IN]);
         $.storLastR [name] = Math.sqrt(ret[0]*ret[0] + ret[1]*ret[1] + ret[2]*ret[2]);
         //System.println("XYZ: " + ret[0] + " " + ret[1] + " " + ret[2]);
         return ret;
  } 

  public function getMakemake(d){

    //225088 Gonggong (2007 OR10)

     var EPOCH=  2458086.5; // ! 2017-Nov-29.00 (TDB)         Residual RMS= .15511
   
     var EC= .1549341371192079   ;
     var QR= 38.62074545461233  ; 
     //var TP= 2407473.3048103042;
     //var OM= 79.60071323640928;   
     var W=  295.8277253622994 ;  
     var IN= 28.98514685760906;
     var A= 45.70146204102473;    
     var MA= 161.4628775532161;

      
     var N= .003190134;

     var newE = randomizeOrbit ("Makemake", EC, QR, W, IN, A, MA, d);

        var d_new= d - EPOCH;
        var M = newE[:MA] + N * d_new;
        
        M=normalize(M);

        var ret = Planet_Sun(M, newE[:EC], newE[:A], newE[:QR], newE[:W], newE[:IN]);
        $.storLastR ["Makemake"] = Math.sqrt(ret[0]*ret[0] + ret[1]*ret[1] + ret[2]*ret[2]);
        //System.println("XYZ: " + ret[0] + " " + ret[1] + " " + ret[2]);
        return ret;
  } 

    public function getHaumea(d){

         var EPOCH=  2457665.5; // ! 2016-Oct-04.00 (TDB)         Residual RMS= .16606
         var EC= .1890800327846289  ; 
         var QR= 35.14667962719495 ;  
         //var TP= 2500383.7360014333;
        //var OM= 121.8932402833152 ;  
        var W=  239.2598062405985;   
        var IN= 28.1988605373753;
        var A= 43.34173660550696 ;   
        var MA= 212.4436438927888;   
        var ADIST= 51.53679358381897;
        var N= .003454177;


     var newE = randomizeOrbit ("Haumea", EC, QR, W, IN, A, MA, d);

        var d_new= d - EPOCH;
        var M = newE[:MA] + N * d_new;
        
        M=normalize(M);

        var ret = Planet_Sun(M, newE[:EC], newE[:A], newE[:QR], newE[:W], newE[:IN]);
        $.storLastR ["Haumea"] = Math.sqrt(ret[0]*ret[0] + ret[1]*ret[1] + ret[2]*ret[2]);
        //System.println("XYZ: " + ret[0] + " " + ret[1] + " " + ret[2]);
        return ret;
  } 

  //slightly scramble  up all the params
  
  private function randomizeOrbit (name, EC, QR, W, IN, A, MA, d){
        
        var ret = {};
        var pRet =  {:EC => EC,
                        :QR => QR,
                        :W => W,
                        :IN => IN,
                        :A => A,
                        :MA => MA,
                        :lastD => d,
                    };
        if ($.animSinceModeChange <= 1 ) {
            $.storRand.put(name, pRet);
            return pRet;    
        }                    

        if ($.storRand != null && storRand.hasKey(name)) {
            
            pRet = storRand[name];
            //System.println("pRet from STOR: " + pRet);
        }
        var lastR = QR;
        if ($.storLastR != null && storLastR.hasKey(name)) {            
            lastR = storLastR[name];
            //System.println("lastR from STOR: " + lastR);
        }

        //lastR = QR;
        
        var eTime = d - pRet[:lastD];
        var rFact = 2000;
        var div = 80000000d; //was 10000000d but seemed too big, 100000000d but seemed too small
        
        //ret.put(:EC, pRet[:EC] + (Math.rand()%(2*rFact)-rFact) * QR);

        
        ret.put(:EC, pRet[:EC] + ((Math.rand()%(2*rFact)-rFact) * QR * eTime/3650d * QR/lastR)*A/div/100);
        ret.put(:QR, pRet[:QR] + ((Math.rand()%(2*rFact)-rFact) * QR * eTime/3650d * QR/lastR)*A/div);
        ret.put(:W, pRet[:W] + ((Math.rand()%(2*rFact)-rFact) * QR * eTime/3650d *A)/div);
        ret.put(:IN, pRet[:IN] + ((Math.rand()%(2*rFact)-rFact) * QR * eTime/3650d * QR/lastR*A)/div);
        ret.put(:A, pRet[:A] + ((Math.rand()%(2*rFact)-rFact) * QR * eTime/3650d * QR/lastR*A)/div);
        ret.put(:MA, pRet[:MA] + ((Math.rand()%(2*rFact)-rFact) * QR * eTime/3650 * QR/lastR*A)/div);
        ret.put(:lastD, d);

        if (ret[:EC] > 1) {ret[:EC]=1;}
        if (ret[:EC] < 0) {ret[:EC]=0;}

        //System.println("ret: " + ret);
        //System.println("ret: " + ret);
        
        

        $.storRand.put(name, ret);
        return ret;

  }
   

}