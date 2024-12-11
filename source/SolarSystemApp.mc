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
    var view_modes = [0, 1,2,3,4,5];
    var view_index = 0;
    var speeds = [-24*365*10, -24*365*7, -24*365*4, -24*365*2,
                -24*365, -24*90, -24*60, -24*30, -24*14, -24*7,-24*5, -24*3, -24*2, -24,
                -6,-4,-2, -1, -.5,-0.25,-10/60.0, -5/60.0, -3/60.0, -2/60.0, -1/60.0, 
                1/600.0,  1/60.0, 2/60.0,
                3/60.0, 5/60.0, 10/60.0,
                0.25, .5, 1,2,4, 6, 24, 24*2, 24*3,24*5, 24*7, 24*14, 24*30, 
                24*60, 24*90, 24*365, 24*365*2, 
                24*365*4, 24*365 * 7, 24*365 * 10];
var speeds_index = 19;
var started = false;
var hz = 5.0;
var screen0Move_index = 31;

var time_add_hrs = 0;

var show_intvl = 0;
var solarSystemView_class;

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
        var temp = Storage.getValue("Infinite Second Option");        
        $.Options_Dict[name] = temp  != null ? temp : defoolt;
        if ($.Options_Dict[name]>size-1) {$.Options_Dict[name] = defoolt;}
        if ($.Options_Dict[name]<0) {$.Options_Dict[name] = defoolt;}
        Storage.setValue(name,$.Options_Dict[name]);
    }

    //read stored settings & set default values if nothing stored
    public function readStorageValues() as Void {

        System.println("STORAGE VALUES ARE READ - PROGRAM INIT!!!!");

        readAStorageValue("Label Display Option",labelDisplayOption_default, labelDisplayOption_size );

        readAStorageValue("Refresh Option",refreshOption_default, refreshOption_size );

        readAStorageValue("Screen0 Move Option",screen0MoveOption_default, screen0MoveOption_size );

        if ($.Options_Dict["Screen0 Move Option"] != null) { 
            $.screen0Move_index = 27 + $.Options_Dict["Screen0 Move Option"];}
        else {$.screen0Move_index = 31;
           System.println("options storage read: screen0move: " + $.screen0Move_index + " optiond: " + $.Options_Dict["Screen0 Move Option"] );
        }
            
        

                //[ "5hz", "4hz", "3hz", "2hz", "1hz", "2/3hz", "1/2hz"];
        switch ($.Options_Dict["Refresh Option"]) {
                case 0:
                    $.hz = 5;
                    break;
                case 1:
                    $.hz = 4;
                    break;
                case 2:
                    $.hz = 3;
                    break;                      
                case 3:
                    $.hz = 2;
                    break;    
                case 4:
                    $.hz = 1;
                    break;      
                case 5:
                    $.hz = 2/3.0;
                    break;
                case 6:
                    $.hz = 1/2.0;
                    break;    
                default:
                    $.hz = 4;    

        }

        _positionView.startAnimationTimer($.hz);           
        

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