//!
//! Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
//! Subject to Garmin SDK License Agreement and Wearables
//! Application Developer Agreement.
//!

import Toybox.Application;
import Toybox.Lang;
import Toybox.Position;
import Toybox.WatchUi;
import Toybox.Application.Storage;

var page = 0;
var pages_total = 25;
//var geo_cache;
var sunrise_cache;
var moon;
var simple_moon;
var vspo87a;
var vsop_cache;
var allOrbitParms = null;
    var view_modes = [0, 1,2,3,4,5]; //manual move ecl, minuts ecl, day ecl, inner orr, mid orr, full orr
    var view_index = 0;

    //unit is HOUR
    //all are chosen to be WHOLE DAYS however, to make the sun stand still when moving forward on the eliptical screens
    //But also closest unit to WHOLE YEARS (ie 183 instead of 180 or 182.621187, 61 instead of 60 or 60.873729)
    //Adde synodic month & solar yr as exact time options
    var speeds = [-24*365*10, -24*365*7, -24*365*4, -24*365*2,-24*365.2422, -24*365, //0; year multiples (added 0)
                -24*183, -24*122, -24*91, -24*61, -24*31, -29.53059, -24*15, //6; 1/2, 1/4, 1/12, 1/24 of a year (added 1)
                -24*7,-24*5, -24*3, -24*2+1, -24*2, -24*2-1, -25, -24, -23, //11; Days up to a week, with 1&2 days +1/-1 hrsso you can adjust them easily
                -12,-6,-4,-2, -1, //22;Hours (added 1)
                -30/60.0,-15/60.0,-10/60.0, -5/60.0, -3/60.0, -2/60.0, -1/60.0,  //27; minutes (added 0)
                1/600000.0,  //34; Zero ( but still has very slight movement, also avoids /0 just in case)
                1/60.0, 2/60.0, 3/60.0, 5/60.0, 10/60.0, 15/60.0, 30/60.0,  //35; minutes (added 0)
                1,2,4,6,12,  //42; Hours (added 1)
                23, 24,25, 24*2-1, 24*2,24*2+1, 24*3,24*5, 24*7, //47; Days up to a week (added 0)
                24*15,29.53059, 24*31, 24*61, 24*91, 24*122, 24*183, //56; 1/2, 1/4, 1/12, 1/24 of a year (added 1)
                24*365,24*365.2422, 24*365*2, 24*365*4, 24*365 * 7, 24*365 * 10]; //63; year multiples (added 0)
var speeds_index = 34; //the currently used speed that will be added to TIME @ each update of screen
var screen0Move_index = 33;

var started = false; //whether to move forward on an update, ie STOPPED or STARTED moving
var hz = 5.0; //updates per second (Requested from OS)

var message = [];
var animation_count = 0;
var buttonPresses = 0;
var orreryDraws = 0;

var time_add_hrs = 0.0d; //cumulation of all time to be added to time.NOW when a screen is displayed

var show_intvl = 0; //whether or not to show current SPEED on display
var animSinceModeChange = 0; //used to tell when to blank screen etc.
var solarSystemView_class; //saved instance of main class 

//! This app displays information about the user's position
class SolarSystemBaseApp extends Application.AppBase {

    //enum {ECLIPTIC_STATIC, ECLIPTIC_MOVE, SMALL_ORRERY, MED_ORRERY, LARGE_ORRERY}
    //var view_modes = [ECLIPTIC_STATIC, ECLIPTIC_MOVE, SMALL_ORRERY, MED_ORRERY, LARGE_ORRERY];


    private var _positionView as SolarSystemBaseView;
    private var _positionDelegate as SolarSystemBaseDelegate;

    //! Constructor
    public function initialize() {
        AppBase.initialize();
        System.println("init starting...");
        _positionView = new $.SolarSystemBaseView();
        solarSystemView_class = _positionView;
        _positionDelegate = new $.SolarSystemBaseDelegate(_positionView);
        //geo_cache = new Geocentric_cache();
        readStorageValues();
        sunrise_cache = new sunRiseSet_cache();
        vsop_cache = new VSOP87_cache();
        System.println("inited...");
        view_index=0;
        $.changeModes(null); //inits speeds_index properly
        
        

    }

    //! Handle app startup
    //! @param state Startup arguments
    public function onStart(state as Dictionary?) as Void {  
        System.println("onStart...");
        //readStorageValues();
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    //! Handle app shutdown
    //! @param state Shutdown arguments
    public function onStop(state as Dictionary?) as Void {
        _positionView.stopAnimationTimer();
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

    //! Update the current position
    //! @param info Position information
    public function onPosition(info as Info) as Void {
        System.println("onPosition...");
        _positionView.setPosition();
    }

    //! Return the initial view for the app
    //! @return Array [View]
    public function getInitialView() as [Views] or [Views, InputDelegates] {
        System.println("getInitialView...");
        return [_positionView, _positionDelegate];
    }
    /*
    // settingsview works only for watch faces & data fields (?)
    public function getSettingsView() as [Views] or [Views, InputDelegates] or Null {
        System.println("6A");
        return [new $.SolarSystemSettingsMenu(), new $.SolarSystemInputDelegate()];
    }
    */

    public function readAStorageValue(name, defoolt, size  ) {
        var temp = Storage.getValue(name);        
        $.Options_Dict[name] = temp  != null ? temp : defoolt;
        if ($.Options_Dict[name]>size-1) {$.Options_Dict[name] = defoolt;}
        if ($.Options_Dict[name]<0) {$.Options_Dict[name] = defoolt;}
        Storage.setValue(name,$.Options_Dict[name]);
    }

    //read stored settings & set default values if nothing stored
    public function readStorageValues() as Void {

        System.println("STORAGE VALUES ARE READ - PROGRAM INIT!!!!");

        readAStorageValue("orrZoomOption", orrZoomOption_default, orrZoomOption_size );

        readAStorageValue("Label Display Option",labelDisplayOption_default, labelDisplayOption_size );

        readAStorageValue("Refresh Option",refreshOption_default, refreshOption_size );

        readAStorageValue("Screen0 Move Option",screen0MoveOption_default, screen0MoveOption_size );

        readAStorageValue("Planet Size Option", planetSizeOption_default, planetSizeOption_size );

        readAStorageValue("Ecliptic Size Option", eclipticSizeOption_default, eclipticSizeOption_size );

        readAStorageValue("Orbit Circles Option", orbitCirclesOption_default, orbitCirclesOption_size );

        readAStorageValue("planetsOption", planetsOption_default, planetsOption_size );


        //Now IMPLEMENT the above values

        //#####SCREEN0 MOVE
        $.screen0Move_index = screen0MoveOption_values[$.Options_Dict["Screen0 Move Option"]];
                    
        //###### REFRESH RATE
        $.hz = refreshOption_values[$.Options_Dict["Refresh Option"]];                
        _positionView.startAnimationTimer($.hz);           
        
        //##### PLANET SIZE
        planetSizeFactor = planetSizeOption_values[$.Options_Dict["Planet Size Option"]];

        //##### ECLIPTIC SIZE
        eclipticSizeFactor = eclipticSizeOption_values[$.Options_Dict["Ecliptic Size Option"]];

        //##### Display all or only planets
        planetsOption_value = $.Options_Dict["planetsOption"]; //the number not the array (unusual) 

        /* //Sample binary option
        temp = Storage.getValue("Show Battery");
        $.Options_Dict["Show Battery"] = temp  != null ? temp : true;
        Storage.setValue("Show Battery",$.Options_Dict["Show Battery"]);        
        */

     
        
    }


}

/*  SAMPLEs..
class SolarSystemInputDelegate extends WatchUi.InputDelegate {
    function onKey(keyEvent) {
        System.println("GOT KEEY!!!!!!!!!: " + keyEvent.getKey());         // e.g. KEY_MENU = 7
        return true;
    }

    function onTap(clickEvent) {
        System.println(clickEvent.getType());      // e.g. CLICK_TYPE_TAP = 0
        return true;
    }

    function onSwipe(swipeEvent) {
        System.println(swipeEvent.getDirection()); // e.g. SWIPE_DOWN = 2
        return true;
    }
}

*/