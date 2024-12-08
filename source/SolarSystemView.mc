//!
//! Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
//! Subject to Garmin SDK License Agreement and Wearables
//! Application Developer Agreement.
//!

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Position;
import Toybox.WatchUi;

//! This view displays the position information
class SolarSystemBaseView extends WatchUi.View {

    var lastLoc;
    private var _lines as Array<String>;
    public var time_add_hrs = 0;
    //private var page;
    
    //! Constructor
    public function initialize() {
        View.initialize();
        //page = pg;

        // Initial value shown until we have position data
        setPosition();
        _lines = ["No position info"];
    }

    //! Load your resources here
    //! @param dc Device context
    public function onLayout(dc as Dc) as Void {
    }

    //! Handle view being hidden
    public function onHide() as Void {
    }

    //! Restore the state of the app and prepare the view to be shown
    public function onShow() as Void {


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

    //! Update the view
    //! @param dc Device context
    //var count = 0;
    public function onUpdate(dc as Dc) as Void {

       
        switch (page){
            case 0:
                largeEcliptic(dc, 0);
                break;
            case 1:
                largeEcliptic(dc, 1);
                break;
            default:
                largeEcliptic(dc, 0);

                break;    
        }
        
        


        


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

    var xc, yc, r, whh, font, textheight, g, srs, sunrise_events, pp, keys, now, sid, x, y ,x2, y2;
    var ang_deg, ang_rad, size, mult, sub, key, key1, textHeight, kys, add_duration;

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

        font = Graphics.FONT_SMALL;
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
        whh = ["Mercury","Venus","Earth","Mars","Jupiter","Saturn"];

        System.println("View Ecliptic:");

        add_duration = new Time.Duration(time_add_hrs*3600);
        System.println("View Ecliptic:" + add_duration + " " + time_add_hrs);
        now = System.getClockTime();
        var now_info = Time.Gregorian.info(Time.now().add(add_duration), Time.FORMAT_SHORT);

        System.println("View Ecliptic:" + now_info.year + " " + now_info.month + " " + now_info.day + " " + now_info.hour + " " + now_info.min + " " + now.timeZoneOffset/3600 + " " + now.dst);
        
        g = new Geocentric(now_info.year, now_info.month, now_info.day, now_info.hour, now_info.min, now.timeZoneOffset/3600, now.dst,"ecliptic", whh);
        
        setPosition();

        srs = new SunRiseSet(now_info.year, now_info.month, now_info.day, now.timeZoneOffset/3600, now.dst, lastLoc[0], lastLoc[1]);
        
        sunrise_events = srs.riseSet();
        //System.println("Sunrise_set: " + sunrise_set);
        //sunrise_set = [sunrise_set[0]*15, sunrise_set[1]*15]; //hrs to degrees

        //dc.setPenWidth(1);
        //dc.drawArc(xc, yc, r,Graphics.ARC_CLOCKWISE, 0,360);
        dc.drawCircle(xc, yc, r);

        drawARC (dc, sunrise_events[SUNRISE][0], sunrise_events[SUNSET][0], xc, yc, r, 2, Graphics.COLOR_WHITE);
        drawARC (dc, sunrise_events[DAWN][0], sunrise_events[SUNRISE][0], xc, yc, r, 1,Graphics.COLOR_BLACK);
        drawARC (dc, sunrise_events[SUNSET][0], sunrise_events[DUSK][0], xc, yc, r, 1,Graphics.COLOR_BLACK);
        dc.setPenWidth(1);
        
        
        pp=g.position();
        kys = pp.keys();
        //dc.drawCircle(xc, yc, r);
        
        g = null;
        srs = null;
        
        //var now = System.getClockTime();
        var sid = now_info.hour*15 + now_info.min*15/60; //approx.....
        System.println("SID approx " + sid + "SIDEREAL_TIME" + sunrise_events[SIDEREAL_TIME][0]);
        //sid = 5.5*15;
        for (var i = 0; i<kys.size(); i++) {

            var key = kys[i];
            //if ( ["Ceres", "Uranus", "Neptune", "Pluto", "Eris", "Chiron"].indexOf(key)> -1) {continue;}
            var x = r* Math.cos(Math.toRadians(-pp[key][0] + sid)) + xc;
            var y = r* Math.sin(Math.toRadians(-pp[key][0]+sid)) + yc;
            //var x2 = .65*r* Math.cos(Math.toRadians(-pp[key][0]+sid)) + xc;
            //var y2 = .65* r* Math.sin(Math.toRadians(-pp[key][0]+sid)) + yc;
            var size = 5;
            if (key.equals("Sun")) {size = 5;}
            switch (key) {
                case "Mercury":
                    size = 2;
                    break;
                case "Venus":
                    size =2;
                    break;

                case "Mars":
                    size =2;
                    break;
                case "Saturn":
                    size =3;
                    break;
                case "Jupiter":
                    size =4;
                    break;
            }

            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);        
            dc.fillCircle(x, y, size);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(x, y, size);
            if (key.equals("Sun") || key.equals("Venus")) {dc.fillCircle(x, y, size);}

            if (!key.equals("Sun"))  {
                //dc.drawText(x2, y2, Graphics.FONT_TINY, key.substring(0,1), Graphics.TEXT_JUSTIFY_VCENTER + Graphics.TEXT_JUSTIFY_CENTER);
                //drawAngledText(x as Lang.Numeric, y as Lang.Numeric, font as Graphics.VectorFont, text as Lang.String, justification as Graphics.TextJustification or Lang.Number, angle as Lang.Numeric) as Void
            }
        }

    }



    //big_small = 0 for small (selectio nof visible planets) & 1 for big (all planets)
    public function largeEcliptic(dc, big_small) {
         // Set background color
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        getMessage();
        //setPosition(Position.getInfo());
        xc = dc.getWidth() / 2;
        yc = dc.getHeight() / 2;
   
        r = (xc < yc) ? xc : yc;
        r = .9 * r;

        font = Graphics.FONT_SMALL;
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
        
        
        whh = ["Sun", "Mercury","Venus","Mars","Jupiter","Saturn"];
        if (big_small == 1) {
             whh = ["Sun", "Mercury","Venus","Mars","Jupiter","Saturn","Uranus","Neptune","Pluto","Ceres","Chiron","Eris"]; 
        }

        add_duration = new Time.Duration(time_add_hrs*3600);
        System.println("View Ecliptic:" + add_duration + " " + time_add_hrs);

        now = System.getClockTime();
        var now_info = Time.Gregorian.info(Time.now().add(add_duration), Time.FORMAT_SHORT);



        System.println("View Ecliptic:" + now_info.year + " " + now_info.month + " " + now_info.day + " " + now_info.hour + " " + now_info.min + " " + now.timeZoneOffset/3600 + " " + now.dst);
        g = new Geocentric(now_info.year, now_info.month, now_info.day, now_info.hour, now_info.min, now.timeZoneOffset/3600, now.dst,"ecliptic", whh);

        setPosition();
        //var pos_info = self.lastLoc.getInfo();
        //var deg = pos_info.position.toDegrees();

        srs = new SunRiseSet(now_info.year, now_info.month, now_info.day, now.timeZoneOffset/3600, now.dst, lastLoc[0], lastLoc[1]);
        sunrise_events = srs.riseSet();
        //System.println("Sunrise_set: " + sunrise_set);
        //sunrise_set = [sunrise_set[0]*15, sunrise_set[1]*15]; //hrs to degrees

        //dc.setPenWidth(1);
        //dc.drawArc(xc, yc, r,Graphics.ARC_CLOCKWISE, 0,360);
        dc.drawCircle(xc, yc, r);

        drawARC (dc, sunrise_events[SUNRISE][0], sunrise_events[SUNSET][0], xc, yc, r, 4, Graphics.COLOR_WHITE);
        drawARC (dc, sunrise_events[DAWN][0], sunrise_events[SUNRISE][0], xc, yc, r, 2,Graphics.COLOR_LT_GRAY);
        drawARC (dc, sunrise_events[SUNSET][0], sunrise_events[DUSK][0], xc, yc, r, 2,Graphics.COLOR_LT_GRAY);
        dc.setPenWidth(1);
        
        
        pp=g.position();
        kys = pp.keys();

        g = null;
        srs = null;
        
        
        sid = now_info.hour*15 + now_info.min*15/60; //approx.....
        //System.println("SID approx " + sid + "SIDEREAL_TIME" + sunrise_events[SIDEREAL_TIME][0]);
        //sid = 5.5*15;
        init_findSpot();
        for (var i = 0; i<whh.size(); i++) {
        //for (var i = 0; i<kys.size(); i++) {

            //key = kys[i];
            key = whh[i];
            System.println ("kys: " + key + " " + key1);
            //if ( ["Ceres", "Uranus", "Neptune", "Pluto", "Eris", "Chiron"].indexOf(key)> -1) {continue;}
            ang_deg = -pp[key][0] + sid;
            ang_rad = Math.toRadians(ang_deg);
            x = r* Math.cos(ang_rad) + xc;
            y = r* Math.sin(ang_rad) + yc;
            
            sub = findSpot(-pp[key][0]+sid);
            mult = 0.8 - (.23 * sub);
            x2 = mult*r* Math.cos(ang_rad) + xc;
            y2 = mult* r* Math.sin(ang_rad) + yc;
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
            if (key.equals("Sun") || key.equals("Venus")) {dc.fillCircle(x, y, size);}

            if (!key.equals("Sun"))  {
                dc.drawText(x2, y2, Graphics.FONT_TINY, key.substring(0,2), Graphics.TEXT_JUSTIFY_VCENTER + Graphics.TEXT_JUSTIFY_CENTER);
                //drawAngledText(x as Lang.Numeric, y as Lang.Numeric, font as Graphics.VectorFont, text as Lang.String, justification as Graphics.TextJustification or Lang.Number, angle as Lang.Numeric) as Void
            }
        }

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
        System.println ("sc1: Null? " + (pinfo==null));
        if (pinfo != null ) {System.println ("sc1: pinfo " + pinfo.position.toDegrees());}

        var curr_pos = null;
        if (pinfo.position != null) { curr_pos = pinfo.position; }
        
        var temp = curr_pos.toDegrees()[0];
        if ( (temp - 180).abs() < 0.1 || temp.abs() < 0.1 ) {curr_pos = null;} //bad data

        if (curr_pos == null) {
            var wcc = Weather.getCurrentConditions();

            var w_pos = wcc.observationLocationPosition;

            System.println ("sc1.1: weather w_pos == Null2? " + (w_pos==null));
            if (w_pos != null ) {
                System.println ("sc1.1: winfo " + w_pos.toDegrees());
                curr_pos = w_pos; 
            }

            temp = curr_pos.toDegrees()[0];
            if ( temp == 180 || temp == 0 ) {curr_pos = null;} //bad data
        }
        if (curr_pos == null) {
            var a_info = Activity.getActivityInfo();
            var a_pos = null;
            System.println ("sc1.2:Activity a_pos==Null3? " + (a_pos==null));
            
            if (a_info!=null && a_info has :position && a_info.position != null)
            { a_pos = a_info.position;}
            if (a_pos != null ) {
                System.println ("sc1.2: a_pos " + a_pos.toDegrees());
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
                    System.println ("sc1b: " + self.lastLoc);
           }
        } else {

            var loc = curr_pos.toDegrees();
            self.lastLoc = loc;
            System.println ("sc1c:"+ curr_pos.toDegrees());
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

