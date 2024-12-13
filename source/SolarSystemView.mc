//!
//! Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
//! Subject to Garmin SDK License Agreement and Wearables
//! Application Developer Agreement.
//!

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Position;
import Toybox.WatchUi;
import Toybox.Math;
import Toybox.System;


//! This view displays the position information
class SolarSystemBaseView extends WatchUi.View {

    var lastLoc;
    private var _lines as Array<String>;
    private var _offscreenBuffer as BufferedBitmap?;
    
    public var xc, yc, min_c, targetDc;
    
    //private var page;
    
    //! Constructor
    public function initialize() {
        View.initialize();
        //page = pg;

        //speeds_index = 19; //inited in app.mc where the var is located
        view_index = 0;
        Math.srand(952310);
        

        
        // Initial value shown until we have position data
        setPosition();

        _lines = ["No position info"];
    }

    //up to 3 msg lines to display & how long to display them
    public function sendMessage (msg1, msg2, msg3, msg4, time_sec) {
        // /2.0 cuts display timein half, need a better solution involving actual
        //clock than guessing about animation  frequency
        message = [msg1, msg2, msg3, msg4, animation_count + time_sec * hz/2.0 ];
    }

    
    function animationTimerCallback() as Void {

           if ($.view_modes[$.view_index] == 0 ) {
            started = true;
           }
           animation_count ++;
           animSinceModeChange ++;
           if ($.started) {
             if ($.view_modes[$.view_index]>0) {
                $.time_add_hrs += $.speeds[$.speeds_index];
                WatchUi.requestUpdate();
             } else if (mod(animation_count,$.hz)==0) {
                //update screen #0 at 1 $.hz, much like a watchface...
                WatchUi.requestUpdate();
                
             }
                WatchUi.requestUpdate();
           //Allow msgs etc when screen is stopped, but just @ a lower $.hz 
           } else if (animation_count%3 == 0) {
             WatchUi.requestUpdate();
           }
           //System.println("animationTimer: " + animation_count + " started: " + $.started);
    }


    var animationTimer=null;
    public function startAnimationTimer(hertz){
        if (animationTimer != null) {
            try {
                animationTimer.stop();
                animationTimer = null;
            } catch (e) {

            }

        }

        animationTimer= new Timer.Timer();
        
        animationTimer.start(method(:animationTimerCallback), 1000/hertz, true);
    }

    public function stopAnimationTimer(){
        if (animationTimer != null) {
            try {
                animationTimer.stop();
                animationTimer = null;
            } catch (e) {

            }

        }
    }


    //! Load your resources here
    //! @param dc Device context
    public function onLayout(dc as Dc) as Void {
        
        xc = dc.getWidth() / 2;
        yc = dc.getHeight() / 2;
        min_c  = (xc < yc) ? xc : yc;

        startAnimationTimer($.hz);

            

    


        
    
    }

    //! Handle view being hidden
    public function onHide() as Void {
        started = false;
    }

    //! Restore the state of the app and prepare the view to be shown
    public function onShow() as Void {
        started = true;

    }

    var offScreenBuffer_started = false;

    function startOffScreenBuffer (dc){ 
        if (offScreenBuffer_started) {return;}

        var offscreenBufferOptions = {
                    :width=>dc.getWidth(),
                    :height=>dc.getHeight(),
                    :palette=> [
                        //Graphics.COLOR_DK_GREEN,
                        //Graphics.COLOR_GREEN,
                                            
                        Graphics.COLOR_BLACK,
                        Graphics.COLOR_WHITE,
    
                    ]
                };

                    if (Graphics has :createBufferedBitmap) {
                // get() used to return resource as Graphics.BufferedBitmap
                _offscreenBuffer = Graphics.createBufferedBitmap(offscreenBufferOptions).get() as BufferedBitmap;
            } else if (Graphics has :BufferedBitmap) { // If this device supports BufferedBitmap, allocate the buffers we use for drawing
                // Allocate a full screen size buffer with a palette of only 4 colors to draw
                // the background image of the watchface.  This is used to facilitate blanking
                // the second hand during partial updates of the display
                _offscreenBuffer = new Graphics.BufferedBitmap(offscreenBufferOptions);

            } else {
                _offscreenBuffer = null;
                
            }

            if (null != _offscreenBuffer) {
                // If we have an offscreen buffer that we are using to draw the background,
                // set the draw context of that buffer as our target.
                targetDc = _offscreenBuffer.getDc();
                
            } else {
                targetDc = dc;
                
            }
            offScreenBuffer_started = true;
    }

    function stopOffScreenBuffer(){
        _offscreenBuffer = null;
        targetDc = null;
        offScreenBuffer_started = false;

    }

    //hr are in hours, so *15 to get degrees
    //drawArc start at 3'oclock & goes CCW in degrees
    //whereas hrs start at midnight (6'oclock position) and proceed clockwise.  Thus 270 - hr*15.
    public function drawARC (dc, hr1, hr2, xc, yc, r, width, color) {
        if (hr1 == null || hr2 == null) {return false;}
        dc.setPenWidth(width);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(xc, yc, r, Graphics.ARC_CLOCKWISE, 270 - hr1 * 15, 270 - hr2 *15);   
        return true;
    }

    public function doUpdate(dc, move){
        switch($.view_modes[$.view_index]){
            case (0): //manual ecliptic (& follows clock time)
                stopOffScreenBuffer();
                largeEcliptic(dc, 0);
                break;
            case (1):  //slow-moving animated ecliptic
                stopOffScreenBuffer();
                largeEcliptic(dc, 0);
                
                //if ($.started) {WatchUi.requestUpdate();}
                break;
            case (2):  //animation moving at one frame/day; sun frozen
                stopOffScreenBuffer();
                largeEcliptic(dc, 0);
                
                //if ($.started) {WatchUi.requestUpdate();}
                break;    
            case(3): //top view of center 4 planets
                //time_add_inc = 24*3;
                startOffScreenBuffer(dc);
                largeOrrery(dc, 0);
                //if (move) {$.time_add_hrs += speeds[speeds_index];}
                //if ($.started) {WatchUi.requestUpdate();}
                break;
            case(4): //top view of main planets
                startOffScreenBuffer(dc);
                largeOrrery(dc, 1);
                //if (move) {$.time_add_hrs += speeds[speeds_index];}
                //if ($.started) {WatchUi.requestUpdate();}

                break;
            
            case(5):  //top view taking in some trans-neptunian objects
                //if (move) {$.time_add_hrs += speeds[speeds_index];}
                startOffScreenBuffer(dc);
                largeOrrery(dc, 2);
                //if ($.started) {WatchUi.requestUpdate();}

                break;
            default:
                //if (move) {$.time_add_hrs += speeds[speeds_index];}
                stopOffScreenBuffer();
                largeEcliptic(dc, 0);
                
                //if ($.started) {WatchUi.requestUpdate();}
            


        }
    }

    //! Update the view
    //! @param dc Device context
    var count = 0;
    var textDisplay_count = 0;
    var old_mode = -1;
    var drawPlanetCount =0;
    var planetRand = 0;
    public function onUpdate(dc as Dc) as Void {
        //System.println("count: " + count);
        count++;
        textDisplay_count ++;
        drawPlanetCount =0; //incremented when drawing each planet; refreshed on each new screen draw
        planetRand = Math.rand(); //1 new random number for drawPlanet, per screen refresh

        if ($.view_index != old_mode) {
            textDisplay_count =0;
            old_mode = $.view_index;
        }
        //largeEcliptic(dc, 0);
        
         doUpdate(dc, started);


        /*
        switch (page){
            case 0:
                largeEcliptic(dc, 0);
                time_add_inc = 0.25;
                break;
            case 1:
                largeEcliptic(dc, 0);
                time_add_inc = 0.5;
                break;
            case 2:
                largeEcliptic(dc, 0);
                time_add_inc = 1;
                break;
            case 3:
                largeEcliptic(dc, 0);
                time_add_inc = 24;
                break;             
            case 4:
                largeEcliptic(dc, 0);
                time_add_inc = 24*7;
                break;  
            case 5:
                largeEcliptic(dc, 0);
                time_add_inc = 24*14;
                break;                                                
            case 6:
                largeEcliptic(dc, 1);
                time_add_inc = .25;
                break;                
            case 7:
                largeEcliptic(dc, 1);
                time_add_inc = .5;
                break;
            case 8:
                largeEcliptic(dc, 1);
                time_add_inc = 1;
                break;
            case 9:
                largeEcliptic(dc, 1);
                time_add_inc = 24;
                break;
            case 10:
                largeEcliptic(dc, 1);
                time_add_inc = 24*7;
                break;
            case 11:
                largeEcliptic(dc, 1);
                time_add_inc = 24*14;
                break;   
            case 12:
                largeOrrery(dc, 0);
                time_add_inc = 24*3;
                $.show_intvl = false;
                $.time_add_hrs += time_add_inc;
                WatchUi.requestUpdate();                 

                break;   
            case 13:
                largeOrrery(dc, 0);
                time_add_inc = 24*7;
                $.show_intvl = false;
                $.time_add_hrs += time_add_inc;
                WatchUi.requestUpdate();                                 
                break;   
            case 14:
                largeOrrery(dc, 0);
                time_add_inc = 14*24;   
                $.show_intvl = false;
                $.time_add_hrs += time_add_inc;
                WatchUi.requestUpdate();                             
                break;   
            case 15:
                largeOrrery(dc, 0);
                time_add_inc = 30*24;
                $.show_intvl = false;
                $.time_add_hrs += time_add_inc;
                WatchUi.requestUpdate();                 
                break;   
            case 16:
                largeOrrery(dc, 1);
                time_add_inc = 24*30;
                $.show_intvl = false;
                $.time_add_hrs += time_add_inc;
                WatchUi.requestUpdate();                 
                break;   
            case 17:
                largeOrrery(dc, 1);
                time_add_inc = 24*90;  
                                $.show_intvl = false;
                $.time_add_hrs += time_add_inc;
                WatchUi.requestUpdate();               
                break;   
            case 18:
                largeOrrery(dc, 1);
                time_add_inc = 365*24;  
                                $.show_intvl = false;
                $.time_add_hrs += time_add_inc;
                WatchUi.requestUpdate();                               
                break;   
            case 19:
                largeOrrery(dc, 1);
                time_add_inc = 365*5*24;
                                $.show_intvl = false;
                $.time_add_hrs += time_add_inc;
                WatchUi.requestUpdate(); 
                break;   
            case 20:
                largeOrrery(dc, 2);
                time_add_inc = 24*30;
                                $.show_intvl = false;
                $.time_add_hrs += time_add_inc;
                WatchUi.requestUpdate(); 
                break;   
            case 21:
                largeOrrery(dc, 2);
                time_add_inc = 24*90;   
                                $.show_intvl = false;
                $.time_add_hrs += time_add_inc;
                WatchUi.requestUpdate();              
                break;   
            case 22:
                largeOrrery(dc, 2);
                time_add_inc = 365*24;  
                                $.show_intvl = false;
                $.time_add_hrs += time_add_inc;
                WatchUi.requestUpdate();                               
                break;   
            case 23:
                largeOrrery(dc, 2);
                time_add_inc = 365*5*24;
                                $.show_intvl = false;
                $.time_add_hrs += time_add_inc;
                WatchUi.requestUpdate(); 
                break;                  
            case 24:
                largeOrrery(dc, 2);
                time_add_inc = 365*10*24;
                                $.show_intvl = false;
                $.time_add_hrs += time_add_inc;
                WatchUi.requestUpdate(); 
                break;                      
            default:
                largeEcliptic(dc, 0);

                break;    
        }
        */
        
        


        


        /*
        System.println("View Equatorial:");
        var h = new Geocentric(2024, 12, 7, 12, 14, 0, 0,"equatorial");
        var hpos = h.position();
        System.println(hpos);
        var kys = hpos.keys();
        for (var i=0; i<hpos.size(); i++) {
            var ky = kys[i];
            //System.println(i +"  " + hpos[ky]);
            //System.println(i +"  " + hpos[i][0] + "  " +
             //(hpos[i][1])+ "  " + (hpos[i][2]));
            System.println(ky +"  " + decimal2hms(hpos[ky][0]) + "  " +
             decimal2arcs(hpos[ky][1])+ "  " + Math.round(hpos[ky][2]));
        }

        System.println("View Horizontal:");

        var gg = new Heliocentric(2024, 12, 7, 12, 14, 0, 0,"horizontal");
        System.println(gg.planets());

        System.println("View Rectangular:");
        var hh = new Heliocentric(2024, 12, 7, 12, 14, 0, 0,"rectangular");
        System.println(hh.planets());
        */
    }

    var r, whh, whh_sun, vspo_rep, font, srs, sunrise_events, pp, pp2, pp_sun, moon_info, moon_info2, moon_info3, moon_info4, elp82, sun_info3,keys, now, sid, x, y ,x2, y2;
    var ang_deg, ang_rad, size, mult, sub, key, key1, textHeight, kys, add_duration, col;
    var sun_adj, hour_adj,final_adj, noon_adj_hrs, noon_adj_deg;
    var input;

/*
    public function smallEcliptic(dc) {
         // Set background color
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        getMessage();
        //setPosition(Position.getInfo());
        //var xc = dc.getWidth() / 2;
        //var yc = dc.getHeight() / 2;
        xc = 145;
        yc = 30;
        r = (xc < yc) ? xc : yc;
        r = .9 * r;

        font = Graphics.FONT_TINY;
        textHeight = dc.getFontHeight(font);
        //textWidght = dc.getFontW
        /*
        y -= (_lines.size() * textHeight) / 2;
        //dc.drawText(x, y+50, Graphics.FONT_SMALL, "Get Lost", Graphics.TEXT_JUSTIFY_CENTER);
        for (var i = 0; i < _lines.size(); ++i) {
            dc.drawText(x, y, Graphics.FONT_TINY, _lines[i], Graphics.TEXT_JUSTIFY_CENTER);
            y += textHeight;
        }
        //dc.drawText(x, y-50, Graphics.FONT_SMALL, "Bug Off", Graphics.TEXT_JUSTIFY_CENTER);
        */

        //planetnames = ["Mercury","Venus","Earth","Mars","Jupiter","Saturn","Uranus","Neptune","Pluto","Ceres","Chiron","Eris"];
/*        
        whh = ["Mercury","Venus","Earth","Mars","Jupiter","Saturn"];

        System.println("View Ecliptic:");

        add_duration = new Time.Duration($.time_add_hrs*3600);
        System.println("View Ecliptic:" + add_duration + " " + $.time_add_hrs);
        now = System.getClockTime();
        var now_info = Time.Gregorian.info(Time.now().add(add_duration), Time.FORMAT_SHORT);

        System.println("View Ecliptic:" + now_info.year + " " + now_info.month + " " + now_info.day + " " + now_info.hour + " " + now_info.min + " " + now.timeZoneOffset/3600 + " " + now.dst);
        
        //g = new Geocentric(now_info.year, now_info.month, now_info.day, now_info.hour, now_info.min, now.timeZoneOffset/3600, now.dst,"ecliptic", whh);

        //geo_cache actually ignores UT, dst, which - we'll correct for that later
        //        g = geo_cache.fetch(now_info.year, now_info.month, now_info.day, now_info.hour, now_info.min, now.timeZoneOffset/3600, now.dst,"ecliptic", whh);
        
        //setPosition();

        showDate(dc, now_info, xc, yc, true,Graphics.TEXT_JUSTIFY_CENTER);

        //srs = new sunRiseSet(now_info.year, now_info.month, now_info.day, now.timeZoneOffset/3600, now.dst, lastLoc[0], lastLoc[1]);
        
        //sunrise_events = srs.riseSet();
        sunrise_events = sunrise_cache.fetch(now_info.year, now_info.month, now_info.day, now.timeZoneOffset/3600, now.dst, lastLoc[0], lastLoc[1]);

        System.println("Sunrise_set: " + sunrise_events);
        //sunrise_set = [sunrise_set[0]*15, sunrise_set[1]*15]; //hrs to degrees

        //dc.setPenWidth(1);
        //dc.drawArc(xc, yc, r,Graphics.ARC_CLOCKWISE, 0,360);
        dc.drawCircle(xc, yc, r);

        drawARC (dc, sunrise_events[:SUNRISE][0], sunrise_events[:SUNSET][0], xc, yc, r, 2, Graphics.COLOR_WHITE);
        drawARC (dc, sunrise_events[:DAWN][0], sunrise_events[:SUNRISE][0], xc, yc, r, 1,Graphics.COLOR_BLACK);
        drawARC (dc, sunrise_events[:SUNSET][0], sunrise_events[:DUSK][0], xc, yc, r, 1,Graphics.COLOR_BLACK);
        dc.setPenWidth(1);
        
        
        //pp=g.position();
        //geo_cache actually ignores UT, dst, which - we'll correct for that later
        pp = $.geo_cache.fetch(now_info.year, now_info.month, now_info.day, now_info.hour, now_info.min, now.timeZoneOffset/3600, now.dst,"ecliptic", whh);
        kys = pp.keys();
        //dc.drawCircle(xc, yc, r);
        
        var sid_old = now_info.hour*15 + now_info.min*15/60; //approx.....
        //sid = sunrise_events[SIDEREAL_TIME][0] * 15;
        sid = srs.siderealTime(now_info.year, now_info.month, now_info.day, now_info.hour, now_info.min, now.timeZoneOffset/3600, now.dst, lastLoc[0], lastLoc[1]);

        //g = null;
        srs = null;

        System.println("SID approx " + sid_old + "SIDEREAL_TIME" + sid + "daily: " + sunrise_events[:SIDEREAL_TIME][0]);

        //init_findSpot();
        for (var i = 0; i<kys.size(); i++) {

            var key = kys[i];
            //if ( ["Ceres", "Uranus", "Neptune", "Pluto", "Eris", "Chiron"].indexOf(key)> -1) {continue;}
            var x = r* Math.cos(Math.toRadians(-pp[key][0] + sid)) + xc;
            var y = r* Math.sin(Math.toRadians(-pp[key][0]+sid)) + yc;
            //var x2 = .65*r* Math.cos(Math.toRadians(-pp[key][0]+sid)) + xc;
            //var y2 = .65* r* Math.sin(Math.toRadians(-pp[key][0]+sid)) + yc;
            var size = 5;
            col = Graphics.COLOR_WHITE;
            if (key.equals("Sun")) {size = 5;}
            switch (key) {
                case "Mercury":
                    size = 2;
                    col = Graphics.COLOR_DK_GRAY;
                    break;
                case "Venus":
                    size =2;
                    col = 0xe3db98;
                    break;

                case "Mars":
                    size =2;
                    col = Graphics.COLOR_RED;
                    break;
                case "Saturn":
                    size =3;
                    col = 0x5500AA;
                    break;
                case "Jupiter":
                    size =4;
                    col = Graphics.COLOR_RED;
                    break;
            }

            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);        
            dc.fillCircle(x, y, size);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(x, y, size);
            if (key.equals("Sun") || key.equals("Venus")) {dc.fillCircle(x, y, size);}

            if (key.equals("Venus")) {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);        
                dc.fillCircle(x, y, 1);
            }

            if (!key.equals("Sun"))  {
                //dc.drawText(x2, y2, Graphics.FONT_TINY, key.substring(0,1), Graphics.TEXT_JUSTIFY_VCENTER + Graphics.TEXT_JUSTIFY_CENTER);
                //drawAngledText(x as Lang.Numeric, y as Lang.Numeric, font as Graphics.VectorFont, text as Lang.String, justification as Graphics.TextJustification or Lang.Number, angle as Lang.Numeric) as Void
            }
        }
        pp=null;
        pp_sun = null;
        kys =  null;
        keys = null;
        srs = null;
        sunrise_events  = null;
        whh = null;
        whh_sun = null;

    }

*/

    //big_small = 0 for small (selectio nof visible planets) & 1 for big (all planets)
    public function largeEcliptic(dc, big_small) {
         // Set background color
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        getMessage();
        //setPosition(Position.getInfo());
        //xc = dc.getWidth() / 2;
        //yc = dc.getHeight() / 2;
   
        r = (xc < yc) ? xc : yc;
        r = .85 * r * eclipticSizeFactor; //was .9 but edge of screen a bit crowded???

        font = Graphics.FONT_TINY;
        textHeight = dc.getFontHeight(font);
        /*
        y -= (_lines.size() * textHeight) / 2;
        //dc.drawText(x, y+50, Graphics.FONT_SMALL, "Get Lost", Graphics.TEXT_JUSTIFY_CENTER);
        for (var i = 0; i < _lines.size(); ++i) {
            dc.drawText(x, y, Graphics.FONT_TINY, _lines[i], Graphics.TEXT_JUSTIFY_CENTER);
            y += textHeight;
        }
        //dc.drawText(x, y-50, Graphics.FONT_SMALL, "Bug Off", Graphics.TEXT_JUSTIFY_CENTER);
        */

        //planetnames = ["Mercury","Venus","Earth","Mars","Jupiter","Saturn","Uranus","Neptune","Pluto","Ceres","Chiron","Eris"];
        
        whh_sun  = ["Sun"];
        whh = ["Sun", "Moon", "Mercury","Venus","Mars","Jupiter","Saturn"];
        //vspo_rep = ["Sun", "Moon", "Mercury","Venus","Mars","Jupiter","Saturn", "Uranus","Neptune"];
        if (big_small == 1) {
             whh = ["Sun", "Moon", "Mercury","Venus","Mars","Jupiter","Saturn","Uranus","Neptune","Pluto","Ceres","Chiron","Eris", "Gonggong"]; 
        }


        //TODO: Make all this JUlian Time so we don't need to worry about Unix seconds & all that
        //add_duration = new Time.Duration($.time_add_hrs*3600);
        //System.println("View Ecliptic:" + add_duration + " " + $.time_add_hrs);

        now = System.getClockTime();
        //var now_info = Time.Gregorian.info(Time.now().add(add_duration), Time.FORMAT_SHORT);
        var time_now = Time.now();
        var now_info = Time.Gregorian.info(time_now, Time.FORMAT_SHORT);
        



        //System.println("View Ecliptic:" + now_info.year + " " + now_info.month + " " + now_info.day + " " + now_info.hour + " " + now_info.min + " " + now.timeZoneOffset/3600 + " " + now.dst);
        //g = new Geocentric(now_info.year, now_info.month, now_info.day, now_info.hour, now_info.min, now.timeZoneOffset/3600, now.dst,"ecliptic", whh);

        //pp=g.position();
        //kys = pp.keys();

        //Geo_cache.fetch always returns the info for Midnight UTCH
        //Which we then add the correct # of hours to (depending on )
        //current  time zone, DST, etc, in order to put the 
        //sun @ the correct time.  We also put in a small adjustment
        //So that local solar noon is always directly UP & solor 
        //midnight is directly DOWN on the circle.
        //pp2 = $.geo_cache.fetch(now_info.year, now_info.month, now_info.day, now_info.hour, now_info.min, now.timeZoneOffset/3600, now.dst,"ecliptic", whh);
        //moon_info = simple_moon.lunarPhase(now_info, now.timeZoneOffset, now.dst);

        /* input = {:year => now_info.year,
        :month => now_info.month,
        :day => now_info.day,
        :hour => now_info.hour,
        :minute => now_info.min,
        :UT => now.timeZoneOffset/3600,
        :dst => now.dst,
        :longitude => lastLoc[0], 
        :latitude => lastLoc[1],
        :topographic => false, 
        };
        moon = new Moon(input);
        */
        simple_moon = new simpleMoon();
        
        moon_info3 = simple_moon.eclipticPos (now_info, now.timeZoneOffset, now.dst, time_add_hrs); 
        //sun_info3 =  simple_moon.eclipticSunPos (now_info, now.timeZoneOffset, now.dst); 
        simple_moon = null;

        //elp82 = new ELP82();
        //moon_info4 = elp82.eclipticMoonELP82 (now_info, now.timeZoneOffset, now.dst);
        //elp82 = null;

        
        // moon_info2 = simple_moon.lunarPhase(now_info, now.timeZoneOffset, now.dst);
        //moon_info = moon.position();
        //vspo87a = new vsop87a_nano();
        //vspo87a = new vsop87a_pico();
        //pp = vspo87a.planetCoord(now_info, now.timeZoneOffset, now.dst, :ecliptic_latlon);
        pp = vsop_cache.fetch(now_info, now.timeZoneOffset, now.dst, time_add_hrs, :ecliptic_latlon);        
        //vspo87a = null;

        //System.println("Moon simple3: " + moon_info3 + " elp82: "+ moon_info4);
        //System.println("Moon simple2: " + moon_info2);
        //System.println("Moon ecl pos: " + moon_info);
        //pp.put("Moon", [pp["Sun"][0] + moon_info[0]]);
        pp.put("Moon", [moon_info3[0]]);
        //pp["Sun"] = [sun_info3[:lat], sun_info3[:lon], sun_info3[:r]];
        //System.println("Sun info3: " + sun_info3);
        //System.println("Moon info: " + moon_info);
        //System.println("Sun-moon: " + pp["Sun"][0] + " " + pp["Moon"][0] );
        //System.println("Sun simple3: " + sun_info3);
        //System.println("pp: " + pp);
        //System.println("pp2: " + pp2);




        kys = pp.keys();
        //g = null;

        //g = new Geocentric(now_info.year, now_info.month, now_info.day, 0, 0, now.timeZoneOffset/3600, now.dst,"ecliptic", whh_sun);

        //pp_sun = g.position();



        //g = null;

        //setPosition();
        //var pos_info = self.lastLoc.getInfo();
        //var deg = pos_info.position.toDegrees();

        //srs = new sunRiseSet(now_info.year, now_info.month, now_info.day, now.timeZoneOffset/3600, now.dst, lastLoc[0], lastLoc[1]);
        //sunrise_events = srs.riseSet();

        sunrise_events = sunrise_cache.fetch(now_info.year, now_info.month, now_info.day, now.timeZoneOffset/3600, now.dst, time_add_hrs, lastLoc[0], lastLoc[1]);

        //System.println("Sunrise_set: " + sunrise_events);
        //System.println("Sunrise_set: " + sunrise_set);
        //sunrise_set = [sunrise_set[0]*15, sunrise_set[1]*15]; //hrs to degrees

        //This puts our midnight sun @ the bottom of the graph; everything else relative to it
        //geo_cache.fetch brings back the positions for UTC & no dst, so we'll need to correct
        //for that
        //TODO: We could put in a correction for EXACT LONGITUDE instead of just depending on 
        //now_info.hour=0 being the actual local midnight.
        //pp/ecliptic degrees start at midnight (bottom of circle) & proceed COUNTERclockwise.
        sun_adj = 270 - pp["Sun"][0];
        hour_adj = normalize(now_info.hour*15 + time_add_hrs*15.0d + now_info.min*15/60);
        //We align everything so that NOON is directly up (SOLAR noon, NOT 12:00pm)
        noon_adj_hrs = 12 - sunrise_events[:NOON][0];
        noon_adj_deg = 15 * noon_adj_hrs;
        final_adj = sun_adj - hour_adj - noon_adj_deg;

        //System.println("pp_sun:" + pp_sun);
        //System.println("sun_a:" + sun_adj + " hour_ad " + hour_adj + "final_a " + final_adj);        

        //dc.setPenWidth(1);
        //dc.drawArc(xc, yc, r,Graphics.ARC_CLOCKWISE, 0,360);
        dc.drawCircle(xc, yc, r);



        //Draws horizon & meridian, per time of day
        drawHorizon(dc, sunrise_events[:HORIZON_PM][0], noon_adj_deg, hour_adj - noon_adj_deg);

        //System.println( sunrise_events[:SUNRISE][0] + " " +sunrise_events[:HORIZON_AM][0] + " " + sunrise_events[:NOON][0] + " " + sunrise_events[:SUNSET][0]+ " " +  sunrise_events[:HORIZON_PM][0] + " " + sunrise_events[:DUSK][0] + " " + sunrise_events[:DAWN][0] );
        drawARC (dc, sunrise_events[:SUNRISE][0] + noon_adj_hrs, sunrise_events[:SUNSET][0]+ noon_adj_hrs, xc, yc, r, 6, Graphics.COLOR_WHITE);
        //NOON mark
        drawARC (dc, sunrise_events[:NOON][0]-0.1+ noon_adj_hrs, sunrise_events[:NOON][0]+0.1+ noon_adj_hrs, xc, yc, r, 10, Graphics.COLOR_WHITE);
        //MIDNIGHT mark
        drawARC (dc, sunrise_events[:NOON][0]-0.05+ noon_adj_hrs +  12, sunrise_events[:NOON][0]+0.05+ noon_adj_hrs  + 12, xc, yc, r, 10, Graphics.COLOR_WHITE);
        drawARC (dc, sunrise_events[:DAWN][0]+ noon_adj_hrs, sunrise_events[:SUNRISE][0]+ noon_adj_hrs, xc, yc, r, 4,Graphics.COLOR_LT_GRAY);
        drawARC (dc, sunrise_events[:SUNSET][0]+ noon_adj_hrs, sunrise_events[:DUSK][0]+ noon_adj_hrs, xc, yc, r, 4,Graphics.COLOR_LT_GRAY);
        drawARC (dc, sunrise_events[:ASTRO_DAWN][0]+ noon_adj_hrs, sunrise_events[:DAWN][0]+ noon_adj_hrs, xc, yc, r, 2,Graphics.COLOR_DK_GRAY);
        drawARC (dc, sunrise_events[:DUSK][0]+ noon_adj_hrs, sunrise_events[:ASTRO_DUSK][0]+ noon_adj_hrs, xc, yc, r, 2,Graphics.COLOR_DK_GRAY);
        dc.setPenWidth(1);


        


        
        


        
        
        
        //sid = now_info.hour*15 + now_info.min*15/60; //approx.....

        
        //sid = sunrise_events[SIDEREAL_TIME][0] * 15;
        //sid = srs.siderealTime(now_info.year, now_info.month, now_info.day, now_info.hour, now_info.min, now.timeZoneOffset/3600, now.dst, lastLoc[0], lastLoc[1]);        

        srs = null;

        //System.println("SID approx " + sid_old + "SIDEREAL_TIME" + sid + "daily: " + sunrise_events[SIDEREAL_TIME][0]);

        sid = 0;

        //sid = 5.5*15;
        init_findSpot();
        for (var i = 0; i<whh.size(); i++) {
        //for (var i = 0; i<kys.size(); i++) {

            //key = kys[i];
            key = whh[i];
            //System.println ("kys: " + key + " " + key1);
            //if ( ["Ceres", "Uranus", "Neptune", "Pluto", "Eris", "Chiron"].indexOf(key)> -1) {continue;}
            ang_deg =  -pp[key][0] - final_adj;
            ang_rad = Math.toRadians(ang_deg);
            x = r* Math.cos(ang_rad) + xc;
            y = r* Math.sin(ang_rad) + yc;

            drawPlanet(dc, key, x, y, 2, ang_rad, :ecliptic, null, null);   
            
        }

        if ($.show_intvl < 5 * $.hz && $.view_index != 0) {
            showDate(dc, now_info, time_now, time_add_hrs, xc, yc, true, true, :ecliptic_latlon);
            $.show_intvl++;
        } else {
            showDate(dc, now_info, time_now, time_add_hrs, xc, yc, true, false, :ecliptic_latlon);
        }

        pp=null;
        pp_sun = null;
        kys =  null;
        keys = null;
        srs = null;
        sunrise_events  = null;
        whh = null;
        whh_sun = null;
        spots = null;

    }

    var scale = 1;
    //big_small = 0 for small (selectio nof visible planets) & 1 for big (all planets)
    public function largeOrrery(dc, big_small) {
         // Set background color
         $.orreryDraws++;

        //don't need these caches in the Orrery view & we are having out of memory
        //errors at times here....
        //geo_cache.empty();
        sunrise_cache.empty();

        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        getMessage();

        
        //setPosition(Position.getInfo());
        //xc = dc.getWidth() / 2;
        //yc = dc.getHeight() / 2;
   
        r = (xc < yc) ? xc : yc;
        r = .9 * r;

        font = Graphics.FONT_TINY;
        textHeight = dc.getFontHeight(font);
        /*
        y -= (_lines.size() * textHeight) / 2;
        //dc.drawText(x, y+50, Graphics.FONT_SMALL, "Get Lost", Graphics.TEXT_JUSTIFY_CENTER);
        for (var i = 0; i < _lines.size(); ++i) {
            dc.drawText(x, y, Graphics.FONT_TINY, _lines[i], Graphics.TEXT_JUSTIFY_CENTER);
            y += textHeight;
        }
        //dc.drawText(x, y-50, Graphics.FONT_SMALL, "Bug Off", Graphics.TEXT_JUSTIFY_CENTER);
        */

        //planetnames = ["Mercury","Venus","Earth","Mars","Jupiter","Saturn","Uranus","Neptune","Pluto","Ceres","Chiron","Eris"];
        
        //whh_sun  = ["Sun"];
        //var small_whh = ["Sun","Mercury","Venus","Earth", "Mars", "Ceres"];
        var small_whh = ["Sun","Mercury","Venus","Earth", "Mars"];
        var full_whh =  ["Sun", "Mercury","Venus","Earth", "Mars","Jupiter","Saturn","Uranus","Neptune","Pluto","Ceres","Chiron","Eris", "Gonggong","Quaoar", "Makemake", "Haumea"];
        //whh = full_whh; //new way, now we have zoom
        whh = planetsOption_values[planetsOption_value];
        
        var zoom_whh = small_whh;
        if (big_small == 1) {
             //whh = ["Sun","Mercury","Venus","Mars","Jupiter","Saturn","Uranus","Neptune","Pluto","Ceres","Chiron"]; 
             zoom_whh = ["Sun","Mercury","Venus","Earth", "Mars","Ceres","Jupiter","Saturn","Uranus","Neptune"]; 
        }
        if (big_small == 2) {
             //whh = ["Sun","Mercury","Venus","Mars","Jupiter","Saturn","Uranus","Neptune","Pluto","Ceres","Chiron"]; 
             //whh = ["Mercury","Venus","Earth","Mars","Jupiter","Saturn","Uranus","Neptune","Pluto","Ceres","Chiron","Eris"]; 
             //zoom_whh = ["Sun", "Mercury","Venus","Mars","Jupiter","Saturn","Uranus","Neptune","Pluto","Ceres","Chiron","Eris", "Gonggong"];
             zoom_whh = full_whh;
        }
        



        //add_duration = new Time.Duration($.time_add_hrs*3600);
        //System.println("View Rectangular:" + add_duration + " " + $.time_add_hrs);

        now = System.getClockTime();
        //var now_info = Time.Gregorian.info(Time.now().add(add_duration), Time.FORMAT_SHORT);
        var time_now = Time.now();
        var now_info = Time.Gregorian.info(time_now, Time.FORMAT_SHORT);



        //System.println("View Rectangular:" + now_info.year + " " + now_info.month + " " + now_info.day + " " + now_info.hour + " " + now_info.min + " " + now.timeZoneOffset/3600 + " " + now.dst);
        //g = new Heliocentric(now_info.year, now_info.month, now_info.day, now_info.hour, now_info.min, now.timeZoneOffset/3600, now.dst,"rectangular", whh);

        //pp=g.planets();
        //vspo87a = new vsop87a_pico();
        //pp = vspo87a.planetCoord(now_info, now.timeZoneOffset, now.dst, :helio_xyz);
        pp = vsop_cache.fetch(now_info, now.timeZoneOffset, now.dst, time_add_hrs, :helio_xyz);
        //vspo87a = null;


        
        //g = null;
        //pp.put("Sun",[0,0,0]);
        kys = pp.keys();

        //System.println("planets: " + pp);
        //System.println("planets keys: " + kys);
        //System.println("whh: " + whh);


        //g = new Geocentric(now_info.year, now_info.month, now_info.day, 0, 0, now.timeZoneOffset/3600, now.dst,"ecliptic", whh_sun);

        //pp_sun = g.position();

        //This puts our midnight sun @ the bottom of the graph; everything else relative to it
        //sun_adj = 270 - pp_sun["Sun"][0];
        //hour_adj = now_info.hour*15 + now_info.min*15/60;
        //final_adj = sun_adj - hour_adj;

        //System.println("pp_sun:" + pp_sun);
        //System.println("sun_a:" + sun_adj + " hour_ad " + hour_adj + "final_a " + final_adj);


        //*********** SET SCALE/ZOOM LEVEL****************
        var max =0.00001;        
        
        for (var i = 0; i<zoom_whh.size(); i++) {
            key = zoom_whh[i];
            if (whh.indexOf(key)<0) {continue;} //in case dwarf planet/asteroids eliminated by ***planetsOption***
            //System.println("KEY whh: " + key);
            var rd = pp[key][0]*pp[key][0]+pp[key][1]*pp[key][1];
            if (rd> max) {max = rd;}
            //System.println("MM: " + key + " " + pp[key][0] + " " + pp[key][1] + " " + rd);
            //if ((pp[key][0]).abs() > maxX) { maxX = (pp[key][0]).abs();}
            //if ((pp[key][1]).abs() > maxY) { maxY = (pp[key][1]).abs();}
        }

        
        
        //Things we do ONLY WHEN FIRST STARTING OUT IN THIS MODE & ZOOM LEVEL
        if ($.show_intvl == 0 ){ 
            scale = (min_c*0.85*eclipticSizeFactor)/Math.sqrt(max) * $.orrZoomOption_values[$.Options_Dict["orrZoomOption"]] ;  

            if (null != _offscreenBuffer) {
                targetDc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
                targetDc.clear();        
                targetDc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                System.println ("Using offscreenBUFFER");

            } else {
                targetDc = dc;
                System.println ("NOTTTTT Using offscreenBUFFER");
            }
        }
        
        //}

        //if (animSinceModeChange <= 1) {
         //targetDc.fillRectangle(0, 0, targetDc.getWidth(), targetDc.getHeight());
         //don't change scale it messes w/"trail" points of planets

        

        /*if ($.orreryDraws == 1) {
            allOrbitParms = generateAllParms(now_info, time_add_hrs, full_whh, pp);
            System.println("allorbit: " + allOrbitParms);
        } */




        /*if ($.show_intvl > -1) {
            //drawOrbits(dc, allOrbitParms[0], scale, xc, yc, big_small, whh, small_whh, Graphics.COLOR_WHITE); 
            //drawOrbits2(dc, scale, xc, yc, big_small, whh, small_whh, Graphics.COLOR_WHITE); 
            } */

            //var tDc = dc;
            //if (big_small == 3) {tDc = targetDc;}

        //*************** PLANET TRACKS **********************************    

        //System.println ("nearly to drawOrbits3");
        if ($.Options_Dict["Orbit Circles Option"]==0 ) {

       

            //System.println ("going to drawOrbits3");
            targetDc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            drawOrbits3(targetDc, pp, scale, xc, yc, big_small, [full_whh,whh, small_whh], Graphics.COLOR_WHITE); 

            
            
            if (null != _offscreenBuffer) {
                dc.drawBitmap(0, 0, _offscreenBuffer);
                //System.println ("Using offscreenBUFFER");
            } 
        }

        //System.println("MM2: " + min_c + " " + scale + " " + max + " ");

        

        //sid = 5.5*15;
        init_findSpotRect();
        for (var i = 0; i<whh.size(); i++) {
        //for (var i = 0; i<kys.size(); i++) {

            key1 = kys[i];
            key = whh[i];
            //System.println ("kys: " + key + " " + key1);
            //if ( ["Ceres", "Uranus", "Neptune", "Pluto", "Eris", "Chiron"].indexOf(key)> -1) {continue;}

            x = scale * pp[key][0] + xc;
            y = scale * pp[key][1] + yc;



            var radius = Math.sqrt(pp[key][0]*pp[key][0] + pp[key][1]*pp[key][1])*scale;

            //Draw the circle of the Orbit
            //TODO: Approximate the elliptical orbit & draw it somehow
            //dc.setColor(orbitCirclesOption_values[$.Options_Dict["Orbit Circles Option"]], Graphics.COLOR_TRANSPARENT);
            //dc.drawCircle(xc, yc, radius);

            if (radius < 1.05 * min_c) {            
                fillSpotRect(x,y);//try to avoid putting labels on top of a planet
                drawPlanet(dc, key, x, y, 4, ang_rad, :orrery, big_small, small_whh);
            }
            
            
            /*
            size = 2;
            if (key.equals("Sun")) {size = 8;}
            switch (key) {
                case "Mercury":
                    size = 2;
                    break;
                case "Venus":
                    size =4;
                    break;

                case "Mars":
                    size =3;
                    break;
                case "Saturn":
                    size =5;
                    break;
                case "Jupiter":
                    size =6;
                    break;
            }

            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);        
            dc.fillCircle(x, y, size);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(x, y, size);
            if (key.equals("Sun") ) {
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(x, y, size);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            }

            

            if (key.equals("Venus")) {
                dc.fillCircle(x, y, size);
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);        
                dc.fillCircle(x, y, 1);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);        
            }

            if (!key.equals("Sun") && (big_small==0 || small_whh.indexOf(key)==-1))  {
                sub = findSpot(-pp[key][0]+sid);
                mult = 2 + sub;
                x2 = mult*8 + x;
                y2 = mult*8 + y;
                dc.drawText(x2, y2, Graphics.FONT_TINY, key.substring(0,2), Graphics.TEXT_JUSTIFY_VCENTER + Graphics.TEXT_JUSTIFY_CENTER);
                //drawAngledText(x as Lang.Numeric, y as Lang.Numeric, font as Graphics.VectorFont, text as Lang.String, justification as Graphics.TextJustification or Lang.Number, angle as Lang.Numeric) as Void
            }

            */
        }

        if ($.show_intvl < 5 * $.hz ) { 
            showDate(dc, now_info, time_now, time_add_hrs,  xc, yc, true, true, :orrery);
            $.show_intvl++;}
            else {
                showDate(dc, now_info, time_now, time_add_hrs,  xc, yc, true, false, :orrery);
        }

        pp=null;
        pp_sun = null;
        kys =  null;
        keys = null;
        srs = null;
        sunrise_events  = null;
        whh = null;
        whh_sun = null;
        //g = null;
        spots_rect = null;


    }
    var spots;
    function init_findSpot(){
        spots = [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1];
    }
    function findSpot (angle) {
        angle = normalize (angle);
        if (angle == 360) {angle =0;}
        var num = (Math.floor( angle * 13 / 360.0)).toNumber();
        spots[num]++;
        return spots[num];        

    }

    
    var sr_x =8f;
    var sr_y = 8f;
    var spots_rect; //0 = spot unoccupied, 1 = spot occupied
    var sr_xc = 4f;
    var sr_yc = 4f;
    var sr_minc = 4f;
    var diffy, diffx, sr_minc2;
    
    function init_findSpotRect(){
        sr_minc2=sr_minc*sr_minc;
        spots_rect=new [sr_x];
        for (var i = 0; i<sr_x; i++) {
            var tmp = new [sr_y];
            //spots_rect.add(tmp);
            for (var j = 0; j<sr_y; j++) {
                //spots_rect[i].add(0);
                var add=0;
                diffx = i-sr_xc;
                diffy = j-sr_yc;
                if ( diffx*diffx + diffy*diffy > sr_minc2){
                    add = 1; //occupied/don't write in corners of our circular display...
                }
                tmp[j]=(add);
            }
            spots_rect[i] = tmp;
        }
    }
    function fillSpotRect (x,y){
        var x2 = Math.round(x/sr_x).toNumber();
        var y2 = Math.round(y/sr_y).toNumber();
        if (x2 >= sr_x || y2 >= sr_y || x2<0 || y2< 0) {return;}
        //System.println("FillsR: " + x2+ " " + y2+ " " + spots_rect);
        spots_rect[x2][y2] = 1;

    }
    function findSpotRect (x,y) {
        //x = x - textHeight/4; //
        //y = y - textHeight/2;
        var x2 = Math.round(x/sr_x).toNumber();
        var y2 = Math.round(y/sr_y).toNumber();
        var x_rem = x.toNumber()%sr_x.toNumber();
        var y_rem = y.toNumber()%sr_y.toNumber();
        
        for (var k = 1; k <4; k++) {
            for (var i = x2-k; i<x2+k; i++) {
                if (i<0 || i >= sr_x) {continue;}
                for (var j = y2-k; j<y2+k; j++) {
                    if (j<0 || j >= sr_y) {continue;}
                    if (spots_rect[i][j] == 0){
                        //spots_rect[i][j] = 1;
                        return findSpotRect_fix( [i*sr_x + x_rem, j*sr_y+ y_rem], [x,y]);
                    }
                }
            }
        }
        //more desperate attempt to find a place
        var xy_desp = new [2];
        //xy_desp[0]=new [2];
        //xy_desp[1]=new [2];
        var x_desp = new [2];
        var y_desp = new [2];
        xy_desp[0] = x_desp;
        xy_desp[1] = y_desp;
        xy_desp[0][0]= ( (x-xc)/xc * 2*xc/sr_x + x);
        xy_desp[1][0]=( (y-yc)/yc * 2*yc/sr_y + y);
        xy_desp[0][1]=( (x-xc)/xc * 2*xc/sr_x - x);
        xy_desp[1][1]=( (y-yc)/yc * 2*yc/sr_y - y);

        var xy_max = 0;
        var x_ret =0;
        var y_ret = 0;
        var x_try = 0;
        var y_try = 0;
        for (var i = 0; i<2; i++) {
            x_try = xy_desp[0][i];
            if (x_try == null) {x_try =1;} //for SOME REASON the compiler won't believe that x_try will be a number; thinks it's a NULL.  So it won't compile without this little trick.  Same for y_try.
            for (var j = 0; j<2; j++) {
                y_try = xy_desp[1][j];
                if (y_try == null) {y_try =1;}
                //System.println("TRIES: " + x_try + " " + y_try);
                var sq = x_try*x_try + y_try*y_try;
                //var sq = xy_desp[0][i]*xy_desp[0][i] + xy_desp[1][j]*xy_desp[1][j];
                /*
                if ( sq <= min_c*min_c && sq>xy_max){
                    xy_max = sq;
                    x_ret = x_try;
                    y_ret = y_try;
                }
                */
            }
        }
        if (xy_max > 0) {
            //fillSpotRect (x_ret,y_ret);
            return findSpotRect_fix([x_ret, y_ret], [x,y]);
        } 

        //last resort
        return [x+xc/10.0, y + yc/10.0];
        


        

    }

    function findSpotRect_fix(xy_new, xy_orig){
        
        //System.println("FSR: " + xy_new + " " + xy_orig + " " + textheight);
        //if (xy_new[0] < xy_orig[0]) {xy_new[0] += textHeight/4.0; }
        //if (xy_new[1] < xy_orig[1]) {xy_new[1] += textHeight/2.0;}
        fillSpotRect(xy_new[0], xy_new[1]);
        return xy_new;


    }
    var helpMSG_shownTimes = 0;
    var helpMSG_current = null;
    var helpMSGs = [
        "Start: Start or next scrn",
        "Back: Stop or prv scrn",
        "Up: Faster or fwd",
        "Down: Slower or bcwd",
        "Menu: Options & help",
        "Try Up Down or Start...",
    ];

    function helpMSG () {
        if (helpMSG_current != null && helpMSG_shownTimes < 5*$.hz) {
            helpMSG_shownTimes ++;
            return helpMSG_current;
        }
        helpMSG_current = helpMSGs[Math.rand()%helpMSGs.size()];
        helpMSG_shownTimes = 0;
        return helpMSG_current;

    }
    var msgSaveButtonPress = 0;
    var msgDisplayed = false;
    var savedMSG = "";
    //shows msg & returns 0 = nothing displayed, 1 = normal msg displayed , 2 = special introductory msg displayed
    function showMessage(dc, jstify) {
        var msg = message;
        if ($.buttonPresses < 1) {
            //making all timings 1/2 the rate because it is so much
            //slower on real watch vs simulator.  But needs a better solution involving actual clock time probably
            switch (mod(animation_count/(3*$.hz),7.0).toNumber()){
                case 0:                
                case 6:                
                default:
                    msg = ["THE","PLANETS", "", "*press UP or SWIPE*",animation_count + 1];
                    break;                
                case 1:                
                    msg = ["UP/DOWN/SWIPE:","Time Forward", "/Back",animation_count + 1];
                    break;
                case 2:                
                    msg = ["UP/DOWN/SWIPE:","OR: Time Faster", "/Slower",animation_count + 1];
                    break;                    
                case 3:
                    msg = ["SELECT/TAP:","START Time if stopped", "OR: Next Mode",animation_count + 1];   
                    break;                 
                case 4:                
                    msg = ["BACK:","STOP Time if started", "OR: Prev Mode/Exit",animation_count + 1];   
                    break;                     
                case 5:                
                    msg = ["MENU:","Change", "Options",animation_count + 1];   
                    break;                         
            }
        }

        if (msg == null) { msgDisplayed = false; return 0;}
        if (msg[msg.size()-1] < animation_count){ msgDisplayed = false; 
        message = null;
        //System.println("ShowMSG: Exiting current msg time expired");
        return 0;}

        //System.println("ShowMSG: curr msg = prev: " + msg.toString().equals(savedMSG.toString()) + " 2nd way: " + msg == savedMSG );

        //System.println("ShowMSG: Hi MOM!"); 

        //System.println("ShowMSG: curr msg = prev: " + msg.toString().equals(savedMSG.toString()));
        //System.println("ShowMSG: curr msg = prev 2nd way: " + (msg == savedMSG) );
        //keeping track of buttonepressses & whether a msg is displayed allows us to 
        //cut out of msg display as soon as a button is pressed after any msg is displayed
        if ($.buttonPresses > msgSaveButtonPress && msgDisplayed ==true && msg==savedMSG) {
            message = null; //have to remove the msg or it keeps popping back  up
            msgDisplayed = false; 
            System.println("ShowMSG: Exiting current msg; a button was pressed after display.");
            return 0;
            }   //but out of msg as soon as a button presses

        System.println("ShowMSG: we are displaying the msg...");  
        savedMSG = msg;  
        var numMsg=0;
        for (var i = 0; i<msg.size()-1; i++) {if (msg[i] != null && msg[i].length()>0 ) { numMsg++;}}
        var ystart = 1.5 * yc - textHeight*numMsg/2;
        var xstart = xc;

        if ($.buttonPresses < 1) { ystart = yc - textHeight*numMsg/2;}

        if (jstify == Graphics.TEXT_JUSTIFY_LEFT) {
                jstify = Graphics.TEXT_JUSTIFY_RIGHT;
                ystart = yc - textHeight*numMsg/2;
                xstart = 1.95*xc;

        }

        //Could draw a BAKCGROUND behind this text...
        
        msgSaveButtonPress = $.buttonPresses;

        msgDisplayed = true; 
        
        font = Graphics.FONT_TINY;
        
        var ct_i = 0;      
        var lined = false;          
        for (var i = 0; i<msg.size()-1; i++) {
            if (msg[i] != null ) { 
                
                ct_i++;
                if (msg[i].length()==0){
                    //a blank line =""
                    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                    dc.drawLine(0, ystart + (i)*textHeight, dc.getWidth(), ystart + i*textHeight);
                    lined = false;
                    continue;
                }
                
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(0, ystart + i*textHeight, dc.getWidth(), textHeight);
                
                
                
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);

                dc.drawText(xstart, ystart + i*textHeight, font, msg[i], jstify);

                if (!lined) {
                    if (i==0) { 
                        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                        }
                    else {
                            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                        }
                    dc.drawLine(0, i*textHeight + ystart , dc.getWidth(), i*textHeight + ystart);
                    lined = true;
                }
            }
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(0, ystart + (ct_i)*textHeight, dc.getWidth(), ystart + ct_i*textHeight);

        if ($.buttonPresses < 1) { return 2;}
        return 1;
        
        

    }

    function showDate(dc, date, time_now, addTime_hrs ,xcent, ycent, incl_years, show, type){
        //System.println("showDate" + show);
        var justify = Graphics.TEXT_JUSTIFY_CENTER;
        var targTime_sec = (addTime_hrs*3600).toLong() + time_now.value();
        if (type ==:orrery) {ycent = 0.25*yc;}
        
        //System.println("DATE!!!!!: " + new_date.value() + " OR... " + targTime_sec + " yr: "+ new_date_info.year + "add_hjrs "+ addTime_hrs);

        var stop = !started && $.view_modes[$.view_index]!=0;

        if (incl_years == null) { incl_years = false; }
        font = Graphics.FONT_TINY;
        textHeight = dc.getFontHeight(font);

        //showMessage(dc, justify);  //will use same font, textHeight as above

        var msg = null;
        var moveup = 0.5;
        if (!show && !stop) {
            msg = helpMSG();
            if (msg == null) { moveup = 0;}
        }
        if (type == :orrery) {moveup -= 1.0;} //no time to display for orrery

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        var sm_ret = showMessage(dc, justify);  //will use same color font, textHeight as above

        if (sm_ret == 2 ) { return; } 
        
        var new_date = new Time.Moment(targTime_sec);
    
        var new_date_info = Time.Gregorian.info(new_date, Time.FORMAT_SHORT);

        //y -= (_lines.size() * textHeight) / 2;
        if (addTime_hrs < 700000 && addTime_hrs > -500000 && type != :orrery) {
            

            var dt = new_date_info.day.format("%02d") + "/"+new_date_info.month.format("%02d");

            if (incl_years) { 
                var yr = new_date_info.year.format("%02d").substring(2,4);
                if (new_date_info.year>2099 || new_date_info.year< 1930 ) { yr = new_date_info.year.format("%04d");}
                dt =  dt + "/" + yr ;
                
            }
            dc.drawText(xcent, ycent - (1 + moveup)*textHeight, font, dt, justify);
            
            if (new_date_info.year<2100 && new_date_info.year>1900) { dc.drawText(xcent, ycent- (moveup)*textHeight, font, new_date_info.hour.format("%02d")+":" + new_date_info.min.format("%02d"), justify);}

        } else {

            var j2 = j2000Date (new_date_info.year, new_date_info.month, new_date_info.day, new_date_info.hour, new_date_info.min, 0, 0);

            var targDate_days = j2 + addTime_hrs/24l;
            var targDate_years = targDate_days/365.25d + 2000d; 



            dc.drawText(xcent, ycent - (1 + moveup)*textHeight, font, targDate_years.format("%.2f"), justify);

        }

        if (stop) {
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(.25* dc.getWidth(), ycent+ .5*textHeight, .5*dc.getWidth(), textHeight);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(xcent, ycent+ .5*textHeight, font, "(stopped)", justify);
            
            return;
        }
        if (show && (sm_ret == 0 || sm_ret ==0 && justify == Graphics.TEXT_JUSTIFY_LEFT)) { //msg_ret ==0 means, don't show this when there is a special msg up
            var intvl = Lang.format("($1$ hr)",[$.speeds[$.speeds_index]]);
            if ($.speeds[$.speeds_index].abs() < 1) {
                intvl = Lang.format("($1$ min)",[($.speeds[$.speeds_index]*60).format("%d")]);
            }
            else if ($.speeds[$.speeds_index].abs()>=24 && $.speeds[$.speeds_index].abs()<=24*190 ) {
                var dv = $.speeds[$.speeds_index]/24.0;
                intvl = "(" + dv.format("%.0d") + " day)";
            }
            else if($.speeds[$.speeds_index].abs()>24*190 ) {
                var dv = $.speeds[$.speeds_index]/(24.0*365.0);
                intvl = "(" + dv.format("%.1d") + " year)";
            }
            else {
                var dv = $.speeds[$.speeds_index];
                intvl = "(" + dv.format("%.1d") + " hour)";
            }
            dc.drawText(xcent, ycent+ .5*textHeight, font, intvl, justify);
            //$.show_intvl = false;
        } else if ((15*$.hz).toNumber() < 2.0* $.hz) {
            dc.drawText(xcent, ycent+ .5*textHeight, font, msg, justify);
        }
        
    }

    var def_size = 175.0 /2;
    var b_size = 2.0;
    var jup_size = 4.0;
    var min_size = 2.0;
    var fillcol= Graphics.COLOR_BLACK;
    //var col = Graphics.COLOR_WHITE;

    public function drawPlanet(dc, key, x, y, base_size, ang_rad, type, big_small, small_whh) {

        drawPlanetCount++;
        col = Graphics.COLOR_WHITE;
        fillcol = Graphics.COLOR_BLACK;
        b_size = base_size/def_size*min_c;
        min_size = 2.0/def_size*min_c;
        size = b_size;
        if (type == :orrery) { size = b_size/32.0;}
        if (key.equals("Sun")) {
            size = 8*b_size;
            //if (type == :orrery) { size = b_size;}
            
        }
        switch (key) {
            case "Mercury":
                size = b_size *jup_size /22.0 * 3/4.0;
                col = Graphics.COLOR_LT_GRAY;
                fillcol = Graphics.COLOR_DK_GRAY;
                break;
            case "Venus":
                size =b_size*jup_size/ 10.0;
                col = 0xf3eb98;
                break;

            case "Mars":
                size =b_size*jup_size /22.0;
                col = 0xff9a8e;
                fillcol = 0x5f4a5e;

                break;
            case "Saturn":
                size =b_size *jup_size * 6/7;
                col = 0x947ec2;
                break;
            case "Jupiter":
                size =b_size *jup_size;
                col = 0xcf9c63;
                break;
            case "Neptune":
                size =b_size *jup_size * 6/7.0*2/5.0;
                col = Graphics.COLOR_BLUE;
                fillcol = col;
                break;
            case "Uranus":
                size =b_size *jup_size * 6/7.0*2/5.0;
                col = Graphics.COLOR_BLUE;
                fillcol = Graphics.COLOR_GREEN;
                break;
             case "Earth":
                size =b_size *jup_size * 6/7.0*2/5.0 * 13/50.0;
                col = Graphics.COLOR_BLUE;
                break;   
             case "Pluto":
                size =b_size *jup_size /22.0/3.0;
                col = Graphics.COLOR_WHITE;
                fillcol = Graphics.COLOR_RED;
                break;   
             case "Ceres":
                size =b_size *jup_size /22.0/3.0/3.0; //1/3 of pluto
                col = Graphics.COLOR_LT_GRAY;
                break;   
             case "Chiron": //rings, light brownish???
                size =b_size *jup_size /22.0/3.0/10; //100-200km only, 1/10th of Pluto
                col = Graphics.COLOR_LT_GRAY;
                break;   
             case "Eris": //white & uniform, has a dark moon
                size =b_size *jup_size /22.0/3.0; //nearly identical to pluto
                col = Graphics.COLOR_WHITE;
                break;   
        }
        
        var correction =  1;
        if (type == :orrery) { 
            size = Math.sqrt(size);

            if (min_c > 120) { //for higher res watches where things tend to come out tiny
                //trying to make the largest things about as large as half the letter's height
             correction = 0.3 * textHeight/ Math.sqrt(8*b_size);
             //System.println("orrery correction " + correction);
             if (correction< 1) {correction=1;}
             if (correction< 1.5) {correction=1.5;}             
              size = size * correction;
            }
            
            }
        if (type == :ecliptic) {
            size = Math.sqrt(Math.sqrt(Math.sqrt(size))) * 5;

            if (min_c > 120) { //for higher res watches where things tend to come out tiny
                correction = 0.3 * textHeight/    Math.sqrt(Math.sqrt(Math.sqrt(size))) / 5;
                //System.println("ecliptic correction " + correction);
                if (correction< 1) {correction=1;}
                if (correction< 1.5) {correction=1.5;}             
                size = size * correction;
            }
        }

        if (size < min_size) { size = min_size; }

        size *= planetSizeFactor;

        dc.setColor(fillcol, Graphics.COLOR_BLACK);        
        dc.fillCircle(x, y, size);
        dc.setColor(col, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(x, y, size);
        switch (key) {
            case "Sun" :
                //dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                dc.setColor(0xf7ef05, Graphics.COLOR_TRANSPARENT);
                
                dc.fillCircle(x, y, size);
                break;
            case "Venus":
                dc.fillCircle(x, y, size);
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);        
                dc.fillCircle(x, y, 1);
                break;
            case "Jupiter":
                dc.drawLine(x-size*.945, y-size/4, x+size*.945, y-size/4);
                dc.drawLine(x-size*.945, y+size/4, x+size*.945, y+size/4);
                break;
            case "Saturn":
                dc.drawLine(x-size*1.7, y+size/3, x+size*1.7, y-size/3);
                //dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(x-size*1.6, y+size*.37 , x+size*1.6, y-size*.21);
                //dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(x-size*1.5, y+size*.41 , x+size*1.5, y-size*.15);
                //dc.drawLine(x-size, y+size/4, x+size, y+size/4);
                break;
        }
        /*
        if (key.equals("Sun") ) {
            
            //dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        } else  if (key.equals("Venus")) {
            
            //dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);        
        }
        */
        var drawThis=false;
        if ($.Options_Dict["Label Display Option"] != 1){

            var mlt = 4;
            if ($.Options_Dict["Label Display Option"]==3) {mlt = 8;}
            else if ($.Options_Dict["Label Display Option"]==0 ) {mlt = 1;}
            else if ($.Options_Dict["Label Display Option"]==4 ) {
                
                    //sparkly labels effect/random 1/4 of the planets @ any time
                  drawThis = (planetRand + drawPlanetCount)%pp.size()<pp.size()/8;
                  mlt = 20;
                
                }
            //System.println ("1328: " + " " + textDisplay_count + " " + mlt + " " + $.hz + " " + drawThis);
            var hez = 5;
            var mlt2 = 1;
            if ($.hz == null ) {hez = 5;} 
            else { hez = $.hz * 4; mlt2 = 4;}

            if ((textDisplay_count * mlt2) % (mlt*hez).toNumber() < hez || drawThis) {
            
                if (type == :ecliptic) {
                    if (!key.equals("Sun"))  {
                        sub = findSpot(-pp[key][0]+sid);
                        mult = 0.8 - (.23 * sub);
                        x2 = mult*r* Math.cos(ang_rad) + xc;
                        y2 = mult* r* Math.sin(ang_rad) + yc;

                        dc.setColor(col, Graphics.COLOR_TRANSPARENT);        
                        dc.drawText(x2, y2, Graphics.FONT_TINY, key.substring(0,2), Graphics.TEXT_JUSTIFY_VCENTER + Graphics.TEXT_JUSTIFY_CENTER);
                        //drawAngledText(x as Lang.Numeric, y as Lang.Numeric, font as Graphics.VectorFont, text as Lang.String, justification as Graphics.TextJustification or Lang.Number, angle as Lang.Numeric) as Void
                    }
                } else if (type == :orrery) {

                    var drawSmall = big_small==0 
                    || (big_small==1 && (small_whh.indexOf(key)==-1 || orrZoomOption_values[$.Options_Dict["orrZoomOption"]] >= 4))
                    || (big_small==2 && ( small_whh.indexOf(key)==-1 || orrZoomOption_values[$.Options_Dict["orrZoomOption"]] >= 8));
                    
                    if (!key.equals("Sun") && drawSmall)  {
                        sub = findSpotRect(x,y);
                        //mult = 2 + sub;
                        x2 = sub[0];
                        y2 = sub[1];
                        dc.setColor(col, Graphics.COLOR_TRANSPARENT);        
                        dc.drawText(x2, y2, Graphics.FONT_TINY, key.substring(0,2), Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
                        //drawAngledText(x as Lang.Numeric, y as Lang.Numeric, font as Graphics.VectorFont, text as Lang.String, justification as Graphics.TextJustification or Lang.Number, angle as Lang.Numeric) as Void
                    }



                }
            }
        }
    }

    public function drawHorizon(dc, horizon_pm, noon_adj_dg, final_adj){

        var eve_hor_start_deg = normalize  ( 270 - (horizon_pm)*15  - noon_adj_dg);
        var eve_hor_end_deg =normalize (- eve_hor_start_deg);
        var morn_hor_end_deg = normalize (eve_hor_end_deg + 180);'
        var morn_hor_start_deg = normalize (eve_hor_start_deg + 180);'
        var hor_ang_deg = 0;
        
        final_adj = normalize(270 - final_adj);
        //System.println("fainal: " + final_adj + " evestart " + eve_hor_start_deg);
        //var sun_ang_deg =  -pp["Sun"][0] - final_adj;
        if (normalize(eve_hor_start_deg - final_adj) < normalize(eve_hor_start_deg-morn_hor_end_deg))
            { //night time
                if (eve_hor_start_deg < morn_hor_end_deg) {eve_hor_start_deg += 360;}
                if (final_adj < morn_hor_end_deg) {final_adj += 360;}
                
                var fact = (eve_hor_start_deg - final_adj ) / (eve_hor_start_deg - morn_hor_end_deg );
                //System.println("fainal: " + final_adj + " evestart " + eve_hor_start_deg + " " + morn_hor_end_deg + " " + fact);
                hor_ang_deg =  (fact) * normalize180(eve_hor_start_deg - eve_hor_end_deg) + eve_hor_end_deg;
                

            }else { //daytime
                if (eve_hor_start_deg > morn_hor_end_deg) {eve_hor_start_deg -= 360;}
                if (final_adj > morn_hor_end_deg) {final_adj -= 360;}

                var fact = (morn_hor_end_deg - final_adj) / (morn_hor_end_deg - eve_hor_start_deg);
                //System.println("fainal2: " + final_adj + " evestart " + eve_hor_start_deg + " " + morn_hor_end_deg + " " + fact);
                hor_ang_deg =  (1-fact) *normalize180(eve_hor_start_deg - eve_hor_end_deg) + eve_hor_end_deg;

            }
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(1);
            var hor_ang_rad = Math.toRadians(hor_ang_deg);
            var x_hor1 = r* Math.cos(hor_ang_rad) + xc;
            var y_hor1 = r* Math.sin(hor_ang_rad) + yc;
            var x_hor1a = .6*r* Math.cos(hor_ang_rad) + xc;
            var y_hor1a = .6*r* Math.sin(hor_ang_rad) + yc;
            var x_hor2 = -r* Math.cos(hor_ang_rad) + xc;
            var y_hor2 = -r* Math.sin(hor_ang_rad) + yc;
            var x_hor2a = -.6*r* Math.cos(hor_ang_rad) + xc;
            var y_hor2a = -.6*r* Math.sin(hor_ang_rad) + yc;
            dc.drawLine (x_hor1,y_hor1,x_hor1a,y_hor1a);
            dc.drawLine (x_hor2,y_hor2,x_hor2a,y_hor2a);
            
            dc.setPenWidth(2);
            //MERIDIAN
            var x_mer = r* Math.cos(hor_ang_rad - Math.PI/2) + xc;
            var y_mer = r* Math.sin(hor_ang_rad- Math.PI/2) + yc;
            var x_mera = .85*r* Math.cos(hor_ang_rad- Math.PI/2) + xc;
            var y_mera = .85*r* Math.sin(hor_ang_rad- Math.PI/2) + yc;            
            dc.drawLine (x_mer,y_mer,x_mera,y_mera);

        //drawARC (dc, sunrise_events[:NOON][0]-0.05+ noon_adj_hrs +  12, sunrise_events[:NOON][0]+0.05+ noon_adj_hrs  + 12, xc, yc, r, 10, Graphics.COLOR_WHITE);
    }
    

    
    
    public function getMessage () {
        /*
        var x =  40000000000001l;
        var y =  -4000000000001l;
        _lines = [normalize (400.0).toString(),
        normalize (-400d),
        normalize (-170d),
        normalize (400f),
        normalize (170l),
        normalize(-570l),
        normalize(735d),];
        
        return;
        */
        /*
        // TEST CODE
        var x =  400000000000001.348258d;
        var y =  -400000000000001.944324d;
        _lines = [spherical2rectangular(x,y,1),
        spherical2rectangular(90,90,1),
        spherical2rectangular(180,180,1),
        spherical2rectangular(270,270,1),
        spherical2rectangular(270,90,1),
        spherical2rectangular(270000000.0,90d,1),
        ];
        var z = rectangular2spherical(1,0,0);
        _lines = [z,
        rectangular2spherical(0,-1,0),
        rectangular2spherical(0,0,1),
        rectangular2spherical(0,x,x),
        rectangular2spherical(270,-270,0),
        rectangular2spherical(90,0,-90),
        
        ];

        _lines = [z,
        ecliptic2equatorial(0,-1,0,1),
        ecliptic2equatorial(0,0,1,5),
        ecliptic2equatorial(0,x,x,-x),
        ecliptic2equatorial(270,-270,0,180),
        ecliptic2equatorial(90,0,-90,90),
        
        ];

        _lines = [z,
        equatorial2ecliptic(0,-1,0,1),
        equatorial2ecliptic(0,0,1,5),
        equatorial2ecliptic(0,x,x,-x),
        equatorial2ecliptic(270,-270,0,180),
        equatorial2ecliptic(90,0,-90,90),
        
        ];

        _lines = [z,
        spherical_ecliptic2equatorial(0,-1,0,1),
        spherical_ecliptic2equatorial(0,0,1,5),
        spherical_ecliptic2equatorial(0,x,x,-x),
        spherical_ecliptic2equatorial(270,-270,0,180),
        spherical_ecliptic2equatorial(90,0,-90,90),
        
        ];

        _lines = [decimal2clock(2.02504),
        decimal2clock(.502/60),
        decimal2clock(-12.090055555),
        decimal2clock(18.0505542345),
        decimal2clock(-2.025404654357),
        decimal2clock(-18.050543234),
        decimal2clock(-.033033333222341123),
        decimal2clock(-117.033003333355544532),
        
        ];


        _lines = [decimal2hms(279.02504),
        decimal2hms(-279.02504),
        decimal2hms(-12.090055555),
        decimal2hms(12.090055555),
        decimal2hms(302),
        decimal2hms(-302),
        decimal2hms(-507),
        decimal2hms(507),
        
        ];

        _lines = [Planet_Sun(48, .006, .72, 77, 54, 3.4),
        Planet_Sun(77,3.4, 54.9, .7, .006, 48),
        "247° 27'",
        

        
        
        ];
        */
        /*
        _lines = [sun2planet(2.02504),
        sun2planet(.502/60),
        sun2planet(-12.090055555),
        sun2planet(18.0505542345),
        sun2planet(-2.025404654357),
        sun2planet(-18.050543234),
        sun2planet(-.033033333222341123),
        sun2planet(-117.033003333355544532),
        
        ];
        */
        /*
                _lines = [z,
        decimal2arcs(60),
        decimal2arcs(60.25),
        decimal2arcs(-60),
        decimal2arcs(-60.25),
        decimal2arcs(-1.2),
        
        ];
        */

    }

    //! Set the position
    //! @param info Position information
    /*
    public function setPosition(info as Info) as Void {
        _lines = [];

        var position = info.position;
        if (position != null) {
            _lines.add("lat = " + position.toDegrees()[0].toString());
            _lines.add("lon = " + position.toDegrees()[1].toString());
        }

        var speed = info.speed;
        if (speed != null) {
            _lines.add("speed = " + speed.toString());
        }

        var altitude = info.altitude;
        if (altitude != null) {
            _lines.add("alt = " + altitude.toString());
        }

        var heading = info.heading;
        if (heading != null) {
            _lines.add("heading = " + heading.toString());
        }

        WatchUi.requestUpdate();
    }
    */

    //fills in the variable lastLoc with current location and/or
    //several fallbacks
    function setPosition () {
        //System.println ("sc1");

        var pinfo = Position.getInfo();
        //System.println ("sc1: Null? " + (pinfo==null));
        //if (pinfo != null ) {System.println ("sc1: pinfo " + pinfo.position.toDegrees());}

        var curr_pos = null;
        if (pinfo.position != null) { curr_pos = pinfo.position; }
        
        var temp = curr_pos.toDegrees()[0];
        if ( (temp - 180).abs() < 0.1 || temp.abs() < 0.1 ) {curr_pos = null;} //bad data

        /*
        //this is giving errors, IQ! screen on wathc???///???!!!!
        //so just removing for now  2024/12/11
        try {
            if (curr_pos == null && Toybox has :Weather) {

                if (Toybox has :Weather) {
            		var currentConditions = Weather.getCurrentConditions();
                    if (currentConditions != null && currentConditions.observationLocationPosition != null) {
                    curr_pos = currentConditions.observationLocationPosition;
                    }
	            }
                if (curr_pos != null && curr_pos has :toDegrees) {
                    temp = curr_pos.toDegrees()[0];
                    if ( temp == null || temp == 180 || temp == 0 ) {curr_pos = null;} //bad data
                }
            }
        } catch (e instanceof Lang.Exception) {
            System.println("This device does not have Toybox.Weather - skipping this method of obtaining position information. Error: " + e);
        }

        */

        if (curr_pos == null) {
            var a_info = Activity.getActivityInfo();
            var a_pos = null;
            //System.println ("sc1.2:Activity a_pos==Null3? " + (a_pos==null));
            
            if (a_info!=null && a_info has :position && a_info.position != null)
            { a_pos = a_info.position;}
            if (a_pos != null ) {
                //System.println ("sc1.2: a_pos " + a_pos.toDegrees());
                curr_pos = a_pos; 
            }
        }
        

        //System.println ("sc1a:");
        //In case position info not available, we'll use either the previously obtained value OR the geog center of 48 US states as default.
        //|| info.accuracy == Pos.QUALITY_NOT_AVAILABLE 
        if (curr_pos == null ){
           if (self.lastLoc == null) { 
                self.lastLoc = new Position.Location(            
                    { :latitude => 39.833333, :longitude => -98.583333, :format => :degrees }
                    ).toDegrees();
                    //System.println ("sc1b: " + self.lastLoc);
           }
        } else {

            var loc = curr_pos.toDegrees();
            self.lastLoc = loc;
            //System.println ("sc1c:"+ curr_pos.toDegrees());
            //System.println ("sc1c");
        }        


        //System.println ("sc2");
        
        //$.Options_Dict["Location"] = [self.lastLoc, now.value()];
        //Storage.setValue("Location",$.Options_Dict["Location"]);
        //System.println ("sc3");
        /* For testing
           now = new Time.Moment(1483225200);
           self.lastLoc = new Pos.Location(
            { :latitude => 70.6632359, :longitude => 23.681726, :format => :degrees }
            ).toRadians();
        */
        //System.println ("lastLoc: " + lastLoc );
    }

}

