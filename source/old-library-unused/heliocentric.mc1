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

import Toybox.Math;
import Toybox.System;
import Toybox.Lang;    
using Toybox.System;

class Heliocentric {
    /*Import date data outputs planets positions around Sun.
    
    Args:
        year (int): Year (4 digits) ex. 2020
        month (int): Month (1-12)
        day (int): Day (1-31)
        hour (int): Hour (0-23)
        minute (int): Minute (0-60)
        UT: Time Zone (deviation from UT, -12:+14), ex. for Greece (GMT + 2) 
            enter UT = 2
        dst (int): daylight saving time (0 or 1). Wheather dst is applied at 
                   given time and place
        view: desired output format. Should be one of: horizontal (long in 
              degrees, lat in degrees, distance in AU) or 
              rectangular (x, y, z, all in AU).
              Default: horizontal.
        which: array with list of the objects to calculate/return.  If which is empty/null, all will be returned.      
 
    */
    var d, oblecl, x, y, r, x2, y2, z2, v, lon, lat, earthX, earthY, earthZ, view, which;
    public var planetnames;

    function initialize (year, month, day, hour, minute, UT, dst, vw, whch) {
        if (vw == null) { vw ="horizontal";}
        if (UT == null) {UT = 0;}
        if (dst == null) {dst = 0;}

        view = vw;
        which = whch;

        planetnames = ["Mercury","Venus","Earth","Mars","Jupiter","Saturn","Uranus",
                "Neptune","Pluto","Ceres","Chiron","Eris"];

        var pr=0d;
        if (dst==1) { pr=1/24d;} //| ???????
        var JDN=( (367l*(year) - Math.floor(7*(year + Math.floor((month+9 )/12))/4))
        + Math.floor(275*(month)/9) + (day + 1721013.5d - UT/24d ) );
        var JD= (JDN + (hour)/24d + minute/1440d - pr);
        var j2000= 2451543.5d;
        d= JD - j2000;
        //var self.d = d
        
        // sun' s trajectory elements
        var w=282.9404d + 4.70935E-5 * d;      
        //        a=1
        var e=(0.016709d - (1.151E-9  * d));   
        var M=356.047d + 0.9856002585d * d;   
        M=normalize(M);
        var L=w+M;
        L=normalize(L);
        oblecl=23.4393d - 3.563E-7d * d;
        var M2=M;
        M=Math.toRadians(M);
        var E=M2 + (180d/Math.PI)*e*Math.sin(M)*(1+e*Math.cos(M));
        E=Math.toRadians(E);
        x=Math.cos(E)-e;
        y=Math.sin(E)*Math.sqrt(1-e*e);
        
        r=Math.sqrt(x*x + y*y); 

        
        v=Math.atan2(y,x);  
        v=Math.toDegrees(v);
        lon=(v+w);
        lon=normalize(lon);
        lon=Math.toRadians(lon);
        x2=r * Math.cos(lon); 
        y2=r * Math.sin(lon);
        z2=0;
        
        
        var xequat = x2;
        oblecl= Math.toRadians(oblecl);
        //var self.oblecl = oblecl;
        var yequat = (y2*Math.cos(oblecl) + z2 * Math.sin(oblecl));
        var zequat = (y2*Math.sin(oblecl) + z2 * Math.cos(oblecl));
       
        
        var RA=Math.atan2(yequat, xequat);
        RA=Math.toDegrees(RA);
        RA=normalize(RA);
        var Decl=Math.atan2(zequat, Math.sqrt(xequat*xequat +yequat*yequat));
        Decl=Math.toDegrees(Decl);

        x=normalize(Math.toDegrees(x));
        y=normalize(Math.toDegrees(y));
        //var self.r=r;
        //var self.x2=x2;
        //var self.y2=y2;
        //var self.z2=z2;
        lon = normalize(-Math.toDegrees(lon));
        lat = Math.atan2( z2, Math.sqrt( x2*x2 + y2*y2 ) );
        lat=normalize(Math.toDegrees(lat));
        //var self.lat=lat;
        
        earthX = -1*x2;
        earthY = -1*y2;
        earthZ = z2; // =0

        //System.println ("X2Y2: " + x2 + " " + y2);
    }
        
        

    //def planetnames(self):
        /*Names of solar system objects used. 
        
        Returns:
            list: A list of solar system objects.
            
        */ 
    

    

    public function planets() {
        /* Main method which returns a dictionary of Heliocentric positions.
        
        Returns:
            dictionary: Planet positions around sun: Dictionary of tuples. Each
            row represents a planet and each column the position of that planet.
            
        */
        
        // Planets trajectory elements
        //Ermis - Mercury
        var N_er=48.3313 + 3.24587E-5 *d;
        var i_er=7.0047 +5.00E-8 *d;
        var w_er=29.1241 + 1.01444E-5 *d;
        var a_er=0.387098;
        var e_er=0.205635 + 5.59E-10 *d;
        var M_er=168.6562 + 4.0923344368 *d;
        
        M_er=normalize(M_er);
        
        //Afroditi - Venus
        var N_af=76.6799 + 2.46590E-5 *d;
        var i_af=3.3946 +2.75E-8 *d;
        var w_af=54.8910 + 1.38374E-5 *d;
        var a_af=0.723330;
        var e_af=0.006773 - 1.30E-9 *d;
        var M_af=48.0052 + 1.6021302244 *d;
        
        M_af=normalize(M_af);
        
        //Aris - Mars
        var N_ar=49.5574 + 2.11081E-5 *d;
        var i_ar=1.8497 - 1.78E-8 *d;
        var w_ar=286.5016 + 2.92961E-5 *d;
        var a_ar=1.523688;
        var e_ar=0.093405 + 2.51E-9 *d;
        var M_ar=18.6021 + 0.5240207766 *d;
        
        M_ar=normalize(M_ar);
        
        //Dias - Jupiter
        var N_di=100.4542 + 2.76854E-5 *d;
        var i_di=1.3030 - 1.557E-7 *d;
        var w_di=273.8777 + 1.6450E-5 *d;
        var a_di=5.20256;
        var e_di=0.048498 + 4.469E-9 *d;
        var M_di=19.8950 + 0.0830853001 *d;
        
        M_di=normalize(M_di);
        
        //Kronos - Saturn
        var N_kr=113.6634 + 2.38980E-5 *d;
        var i_kr=2.4886 - 1.081E-7 *d;
        var w_kr=339.3939 + 2.97661E-5 *d;
        var a_kr=9.55475;
        var e_kr=0.055546 - 9.499E-9 *d;
        var M_kr=316.9670 + 0.0334442282 *d;
        
        M_kr=normalize(M_kr);
        
        //Ouranos - Uranus
        var N_ou=74.0005 + 1.3978E-5 *d;
        var i_ou=0.7733 + 1.9E-8 *d;
        var w_ou=96.6612 + 3.0565E-5 *d;
        var a_ou=19.18171 - 1.55E-8 *d;
        var e_ou=0.047318 + 7.45E-9 *d;
        var M_ou=142.5905 + 0.011725806 *d;
        
        M_ou=normalize(M_ou);
        
        //Poseidonas - Neptune
        var N_po=131.7806 + 3.0173E-5 *d;
        var i_po=1.7700 - 2.55E-7 *d;
        var w_po=272.8461 - 6.027E-6 *d;
        var a_po=30.05826 + 3.313E-8 *d;
        var e_po=0.008606 + 2.15E-9 *d;
        var M_po=260.2471 + 0.005995147 *d;
        
        M_po=normalize(M_po);
          
        
        //D CERES epoch 2455400.5 2010-jul-23.0   j2000= 2451543.5
        var ddd = d + 2451543.5 - 2455400.5;
        
        var N_ce=80.39319901972638  + 1.1593E-5 *ddd;
        var i_ce=10.58682160714853 - 2.2048E-6*ddd;
        var w_ce=72.58981198193074  + 1.84E-5*ddd;
        var a_ce=2.765348506018043 ;
        var e_ce=0.07913825487621974 + 1.8987E-8*ddd;
        var M_ce=113.4104433863731   + 0.21408169952325  * ddd ;
        
        M_ce=normalize(M_ce);
        
        //A CHIRON epoch  2456400.5 2013-apr-18.0   j2000= 2451543.5
        var dddd = d + 2451543.5 - 2456400.5;
        
        var N_ch=209.3557401732507 	 ;
        var i_ch=6.929449422368333 	;
        var w_ch=339.3298742575888 	;
        var a_ch=13.6532230321495 ;
        var e_ch=0.3803659797957286  ;
        var M_ch=122.8444574834622  +  0.01953670401251872 * dddd   ;
        
        M_ch=normalize(M_ch);
        
        //A ERIS epoch  2456400.5 2013-apr-18.0   j2000= 2451543.5;
        var ddddd= d + 2451543.5 - 2456400.5;
        
        var N_pe=36.0308972598494  ;
        var i_pe=43.88534676566927 ;
        var w_pe=150.8002573158863 ;
        var a_pe=67.95784302407351 ;
        var e_pe=0.4370835020505101 ;
        var M_pe=203.2157808586589 +  0.001759319413340421 * ddddd   ;
        
        M_pe=normalize(M_pe);
        
        var res;

        //Ermis - Mercury
        res = Planet_Sun(M_er, e_er, a_er, N_er, w_er, i_er);
        //xereclip,yereclip,zereclip, long2_er, lat2_er, r_er
        var xereclip = res[0];
        var yereclip = res[1];
        var zereclip = res[2];
        var long2_er = res[3];
        var lat2_er = res[4];
        var r_er = res[5];        
        
        
        //Afroditi - Venus
        //xafeclip,yafeclip,zafeclip, long2_af, lat2_af, r_af 
        res = Planet_Sun(M_af, e_af, a_af, N_af, w_af, i_af);
        var xafeclip = res[0];
        var yafeclip = res[1];
        var zafeclip = res[2];
        var long2_af = res[3];
        var lat2_af = res[4];
        var r_af = res[5];

        //Aris - Mars
        //xareclip,yareclip,zareclip, long2_ar, lat2_ar, r_ar 
        res = Planet_Sun(M_ar, e_ar, a_ar, N_ar, w_ar, i_ar);
        var xareclip = res[0];
        var yareclip = res[1];
        var zareclip = res[2];
        var long2_ar = res[3];
        var lat2_ar = res[4];
        var r_ar = res[5];
        
        //Dias - JUpiter
        //xdieclip,ydieclip,zdieclip, long2_di, lat2_di, r_di 
        res = Planet_Sun(M_di, e_di, a_di, N_di, w_di, i_di);
        var xdieclip = res[0];
        var ydieclip = res[1];
        var zdieclip = res[2];
        var long2_di = res[3];
        var lat2_di = res[4];
        var r_di = res[5];

        //Kronos - Saturn
        //xkreclip,ykreclip,zkreclip, long2_kr, lat2_kr, r_kr 
        res = Planet_Sun(M_kr, e_kr, a_kr, N_kr, w_kr, i_kr);
        var xkreclip = res[0];
        var ykreclip = res[1];
        var zkreclip = res[2];
        var long2_kr = res[3];
        var lat2_kr = res[4];
        var r_kr = res[5];

        //Ouranos - Uranus
        //xoueclip,youeclip,zoueclip, long2_ou, lat2_ou, r_ou 
        res = Planet_Sun(M_ou, e_ou, a_ou, N_ou, w_ou, i_ou);
        var xoueclip = res[0];
        var youeclip = res[1];
        var zoueclip = res[2];
        var long2_ou = res[3];
        var lat2_ou = res[4];
        var r_ou = res[5];

        //Poseidonas - Neptune
        //xpoeclip,ypoeclip,zpoeclip, long2_po, lat2_po, r_po 
        res = Planet_Sun(M_po, e_po, a_po, N_po, w_po, i_po);
        var xpoeclip = res[0];
        var ypoeclip = res[1];
        var zpoeclip = res[2];
        var long2_po = res[3];
        var lat2_po = res[4];
        var r_po = res[5];
        
        //Ceres
        //xceeclip,yceeclip,zceeclip, long2_ce, lat2_ce, r_ce 
        res = Planet_Sun(M_ce, e_ce, a_ce, N_ce, w_ce, i_ce);
        var xceeclip = res[0];
        var yceeclip = res[1];
        var zceeclip = res[2];
        var long2_ce = res[3];
        var lat2_ce = res[4];
        var r_ce = res[5];

        //Chiron
        //xcheclip,ycheclip,zcheclip, long2_ch, lat2_ch, r_ch 
        res = Planet_Sun(M_ch, e_ch, a_ch, N_ch, w_ch, i_ch);
        var xcheclip = res[0];
        var ycheclip = res[1];
        var zcheclip = res[2];
        var long2_ch = res[3];
        var lat2_ch = res[4];
        var r_ch = res[5];

        //Eris
        //xpeeclip,ypeeclip,zpeeclip, long2_pe, lat2_pe, r_pe 
        res = Planet_Sun(M_pe, e_pe, a_pe, N_pe, w_pe, i_pe);
        var xpeeclip = res[0];
        var ypeeclip = res[1];
        var zpeeclip = res[2];
        var long2_pe = res[3];
        var lat2_pe = res[4];
        var r_pe = res[5];

        //ploutonas - Pluto
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
        var x_pl = r_pl * Math.cos(long2_pl) * Math.cos(lat2_pl); //eclip
        var y_pl = r_pl * Math.sin(long2_pl) * Math.cos(lat2_pl);
        var z_pl = r_pl * Math.sin(lat2_pl);
        
 
    
        //Perturbations 
        M_di=normalize(M_di);
        M_kr=normalize(M_kr);
        M_ou=normalize(M_ou);
        
        //add to Jupiter long
        var di_diat1=-0.332*Math.sin(Math.toRadians(2*M_di - 5 * M_kr - 67.6));
        var di_diat2=-0.056*Math.sin(Math.toRadians(2*M_di - 2 * M_kr +21));
        var di_diat3=0.042*Math.sin(Math.toRadians(3*M_di - 5 * M_kr +21));
        var di_diat4=-0.036*Math.sin(Math.toRadians(M_di - 2 * M_kr));
        var di_diat5=0.022*Math.cos(Math.toRadians(M_di - M_kr));
        var di_diat6=0.023*Math.sin(Math.toRadians(2*M_di - 3 * M_kr + 52));
        var di_diat7=-0.016*Math.sin(Math.toRadians(M_di - 5 * M_kr - 69));
        
        //add to Saturn long
        var kr_diat1=0.812*Math.sin(Math.toRadians(2*M_di - 5 * M_kr - 67.6));
        var kr_diat2=-0.229*Math.cos(Math.toRadians(2*M_di - 4 * M_kr -2));
        var kr_diat3=0.119*Math.sin(Math.toRadians(M_di - 2 * M_kr - 3));
        var kr_diat4=0.046*Math.sin(Math.toRadians(2*M_di - 6 * M_kr - 69));
        var kr_diat5=0.014*Math.sin(Math.toRadians(M_di - 3* M_kr + 32));
        //add to Saturn lat
        var kr_diat6=-0.02*Math.cos(Math.toRadians(2*M_di - 4 * M_kr - 2));
        var kr_diat7=0.018*Math.sin(Math.toRadians(2*M_di - 6 * M_kr - 49));
       
        //add to Uranus long
        var ou_diat1=0.04*Math.sin(Math.toRadians(M_kr - 2 * M_ou + 6));
        var ou_diat2=0.035*Math.sin(Math.toRadians(M_kr - 3 * M_ou + 33));
        var ou_diat3=-0.015*Math.sin(Math.toRadians(M_di - M_ou +20));
        
        var diataraxes_long_di=(di_diat1 + di_diat2 + di_diat3 + di_diat4 + 
                            di_diat5 + di_diat6 + di_diat7);
        var diataraxes_long_kr=(kr_diat1 + kr_diat2 + kr_diat3 + kr_diat4 
                            + kr_diat5);
        var diataraxes_lat_kr=(kr_diat6 + kr_diat7);
        var diataraxes_long_ou=(ou_diat1 + ou_diat2 + ou_diat3);
        
        //Corrected coordinates for the three planets
        long2_di=long2_di + diataraxes_long_di;
        long2_kr=long2_kr + diataraxes_long_kr;
        lat2_kr=lat2_kr + diataraxes_lat_kr;
        long2_ou=long2_ou + diataraxes_long_ou;
        
        long2_di=(Math.toRadians(long2_di));
        lat2_di=(Math.toRadians(lat2_di));
        long2_kr=(Math.toRadians(long2_kr));
        lat2_kr=(Math.toRadians(lat2_kr));
        long2_ou=(Math.toRadians(long2_ou)) ;
        lat2_ou=(Math.toRadians(lat2_ou)) ;
        
        //Recompute positions of three planets
        xdieclip = r_di * Math.cos(long2_di) * Math.cos(lat2_di);
        ydieclip = r_di * Math.sin(long2_di) * Math.cos(lat2_di) ;
        zdieclip = r_di * Math.sin(lat2_di);
        xkreclip = r_kr * Math.cos(long2_kr) * Math.cos(lat2_kr);
        ykreclip = r_kr * Math.sin(long2_kr) * Math.cos(lat2_kr) ;
        zkreclip = r_kr * Math.sin(lat2_kr);
        xoueclip = r_ou * Math.cos(long2_ou) * Math.cos(lat2_ou);
        youeclip = r_ou * Math.sin(long2_ou) * Math.cos(lat2_ou) ;
        zoueclip = r_ou * Math.sin(lat2_ou)  ;
        
        
        long2_di=normalize(Math.toDegrees(long2_di));
        lat2_di=normalize(Math.toDegrees(lat2_di));
        long2_kr=normalize(Math.toDegrees(long2_kr));
        lat2_kr=normalize(Math.toDegrees(lat2_kr));
        long2_ou=normalize(Math.toDegrees(long2_ou)) ;
        lat2_ou=normalize(Math.toDegrees(lat2_ou)) ;
        
        long2_pl=normalize(Math.toDegrees(long2_pl));
        lat2_pl=normalize(Math.toDegrees(lat2_pl));
        
        
        //long_earth, lat_earth, dist_earth 
        res = rectangular2spherical(earthX, earthY, earthZ);
        var long_earth = res[0];
        var lat_earth = res[1];
        var dist_earth = res [2];
        
        if (view.equals("horizontal")) {
            System.println("Horizontal:");
            var rt = {
                    "Mercury" => [long2_er, lat2_er, r_er],
                    "Venus"   => [long2_af, lat2_af, r_af],
                    "Earth"   => [normalize(long_earth), lat_earth, dist_earth],
//                    "Earth"   => [self.lon, self.lat, self.r],
                    "Mars"    => [long2_ar, lat2_ar, r_ar],
                    "Jupiter" => [long2_di, lat2_di, r_di],
                    "Saturn"  => [long2_kr, lat2_kr, r_kr],
                    "Uranus"  => [long2_ou, lat2_ou, r_ou],
                    "Neptune" => [long2_po, lat2_po, r_po],
                    "Pluto"   => [long2_pl, lat2_pl, r_pl],
                    "Ceres"   => [long2_ce, lat2_ce, r_ce],
                    "Chiron"  => [long2_ch, lat2_ch, r_ch],
                    "Eris"    => [long2_pe, lat2_pe, r_pe]
                    };
            
            if (which != null && which.size()>0) {
                var kys = rt.keys();
                for (var i=0;i<kys.size();i++){
                    if (which.indexOf(kys[i])< 0 && !kys[i].equals("Earth")){
                        rt.remove(kys[i]);
                    }
                }        
            }   
            //System.println("which: " + which);                           
            //System.println("New rt: " + rt);
            return rt;

        } else  {      //if ( view == "rectangular")
            System.println("Rectangular:");
            var rt = {
                    "Mercury" =>[xereclip,yereclip,zereclip],
                    "Venus"   =>[xafeclip,yafeclip,zafeclip],
                    "Earth"   =>[earthX, earthY, earthZ],
                    "Mars"    =>[xareclip,yareclip,zareclip],
                    "Jupiter" =>[xdieclip,ydieclip,zdieclip],
                    "Saturn"  =>[xkreclip,ykreclip,zkreclip],
                    "Uranus"  =>[xoueclip,youeclip,zoueclip],
                    "Neptune" =>[xpoeclip,ypoeclip,zpoeclip],
                    "Pluto"   =>[x_pl,y_pl,z_pl],
                    "Ceres"   =>[xceeclip,yceeclip,zceeclip],
                    "Chiron"  =>[xcheclip,ycheclip,zcheclip],
                    "Eris"    =>[xpeeclip,ypeeclip,zpeeclip]
                    };
            
            if (which != null && which.size()>0) {
                var kys = rt.keys();
                for (var i=0;i<kys.size();i++){
                    if (which.indexOf(kys[i])< 0 && !kys[i].equals("Earth")){
                        rt.remove(kys[i]);
                    }
                }        
            }   
            //System.println("which: " + which);                           
            //System.println("New rt: " + rt);
            return rt;        
        }
    }
}