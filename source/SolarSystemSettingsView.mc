//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;


var orrZoomOption=[
     "4X out" , 
     "2X out" , 
     "1X" , 
     "2X in" , 
     "4X in" , 
     "8X in" ,      
     "16X in", 
     "32X in", 
     "64X in", 
     "128X in", 
];

var orrZoomOption_values=[
    0.25,
    0.5,
    1,
    2, 
    4, 
    8, 
    16, 
    32,
    64,
    128,    

];
var orrZoomOption_size = 10;
var orrZoomOption_default = 2;



//TODO: User could tweak size of PLANETS & also radius of circle/overall scale
var Options_Dict = {  };
var labelDisplayOption=[ "Always On", "Always Off", "Freq Flash", "Less Flash", "Random Flash"];
var labelDisplayOption_size = 5;
var labelDisplayOption_default = 2;

var refreshOption=[ 
    "10 per sec.",
    "5 per sec." ,
    "4 per sec.",
    "3 per sec.",
    "2  per sec.",
    "1 per sec.",
    "1 per 1.5 sec.",
    "1 per 2 sec.",
    "1 per 3 sec.",
    "1 per min.",
    "1 per 5 min.",
    ];
var refreshOption_values=[  //in HZ
        10.0,
        5.0,
        4.0, 
        3.0, 
        2.0, 
        1.0, 
        1/1.5, 
        1/2.0, 
        1/3.0, 
        1/60.0, 
        1/60.0*5,
    ];    
var refreshOption_size = 11;
var refreshOption_default = 2;

var screen0MoveOption=[
     "1min" , 
     "2min" , 
     "3min" ,
     "5min" , 
     "10min", 
     "15min", 
     "30min", 
     "1hr",
      "2hr",
      "24hr",
      "Week",
      "Month",
      "Year" , 
];

var screen0MoveOption_values=[
    29, 
    30, 
    31, 
    32, 
    33, 
    34,
    35,
    36,
    41,
    45,
    47,
    51, 
];
var screen0MoveOption_size = 13;
var screen0MoveOption_default = 6;

var planetSizeOption=[
     "Very small" , 
     "Small" , 
     "Normal" , 
     "Large", 
     "Very Large",      
];

var planetSizeOption_values=[
    0.5, 
    0.75, 
    1.0, 
    1.5, 
    2.0, 

];
var planetSizeOption_size = 5;
var planetSizeOption_default = 2;
var planetSizeFactor = 1.0;

var eclipticSizeOption=[
     "Very small" , 
     "Smaller" , 
     "Small" , 
     "Normal" ,      
     "Large", 
     "Very Large", 
     
];

var eclipticSizeOption_values=[
    0.85,
    0.9, 
    0.95, 
    1.0, 
    1.05, 
    1.1,
    

];
var eclipticSizeOption_size = 6;
var eclipticSizeOption_default = 3;
var eclipticSizeFactor = 1.0;


var orbitCirclesOption=[
     "On" , 
     //"Bright Gray" , 
     //"Dim Gray" , 
     "Off" ,                
];

var orbitCirclesOption_values=[
   Graphics.COLOR_WHITE,
    //Graphics.COLOR_LT_GRAY, 
    //Graphics.COLOR_DK_GRAY, 
    Graphics.COLOR_TRANSPARENT,     
];
var orbitCirclesOption_size = 2;
var orbitCirclesOption_default = 0;

var helpOption=[
    "Planet abbreviations:" , 
     "Me Mercury" , 
     "Ve Venus" , 
     "Ea Earth" , 
     "Ma Mars" , 
     "Ju Jupiter" , 
     "Sa Saturn" ,      
     "Ur Uranus", 
     "Ne Neptune", 
    
     "Pl Pluto", 
     
     "Er Eris (dwarf planet)", 
     "Ha Haumea (dwarf planet)", 
     "Ma Makemake (dwarf planet)", 
     "Go Gonggong (dwarf planet)", 
     "Qu Quaoar (ringed dwarf planet)", 
     "Ce Ceres (dwarf planet/asteroid)", 
     "Ch Chiron (ringed dwarf planet)", 
     
];


var helpOption_size = 17;
var helpOption_default = 0;


/*
var Options_Dict = {  };
var Settings_ran = false;

var infiniteSecondOptions=["No Second Hand","<1 min", "<2 min", "<3 min", "<4 min","<5 min","<10 min", "Always"];
var infiniteSecondLengths = [0, 1, 2, 3, 4, 5, 10, 1000000 ];
var infiniteSecondOptions_size = 8;
var infiniteSecondOptions_default = 2;



var secondHandOptions=[ "Big Pointer", "Outline Pointer", "Big Blunt", "Outline Blunt",  "Big Needle", "Small Block", "Small Pointer","Small Needle"];
var secondHandOptions_size = 8;
var secondHandOptions_default = 2;

var dawnDuskOptions=[ "Dawn/Dusk Markers", "Sunrise/Set Markers", "Dawn/Dusk Inset Dial", "Sunrise/Set Inset Dial", "No Markers", ];
var dawnDuskOptions_size = 5;
var dawnDuskOptions_default = 0;
*/

//! Initial app settings view
class SolarSystemSettingsView extends WatchUi.View {

    hidden var firstShow;

    //! Constructor
    public function initialize() {
        View.initialize();
        firstShow = true;

        System.println("SolarSystemSettingsView initialize...");
    }

    //! Handle the update event
    //! @param dc Device context
    public function onShow() as Void {

        /*
        dc.clearClip();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 - 30, Graphics.FONT_SMALL, "Press Menu \nfor settings", Graphics.TEXT_JUSTIFY_CENTER);
        */
        //System.println("onShow...");

        // if this is the first call to `onShow', then we want the menu to immediately appear
        if (firstShow) {
            //System.println("firstShow...");
            //WatchUi.switchToView(new $.ElegantAnaSettingsMenu(), new $.ElegantAnaSettingsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
            WatchUi.pushView(new $.SolarSystemSettingsMenu(), new $.SolarSystemSettingsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
            //WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            firstShow = false;
        }

        // otherwise, we are returning to this view, most likely be cause the menu was exited,
        // either by pressing back, or by selecting an item that caused the menu to be popped,
        // so we want to pop ourselves
        else {
            //System.println("not firstShow...");
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }

    //! Handle the update event
    //! @param dc Device context
    public function onUpdate(dc as Dc) as Void {

        
        dc.clearClip();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        //dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        //dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 - 30, Graphics.FONT_SMALL, "Press Menu \nfor settings", Graphics.TEXT_JUSTIFY_CENTER);
        
        //System.println("onUpdate/settings...");

        /*
        // if this is the first call to `onShow', then we want the menu to immediately appear
        if (firstShow) {
            System.println("firstShow...");
            WatchUi.switchToView(new $.ElegantAnaSettingsMenu(), new $.ElegantAnaSettingsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
            WatchUi.pushView(new $.ElegantAnaSettingsMenu(), new $.ElegantAnaSettingsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            firstShow = false;
        }

        // otherwise, we are returning to this view, most likely be cause the menu was exited,
        // either by pressing back, or by selecting an item that caused the menu to be popped,
        // so we want to pop ourselves
        else {
            System.println("not firstShow...");
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        } 
        */
    }
}

//! Input handler for the initial app settings view
class SolarSystemSettingsDelegate extends WatchUi.BehaviorDelegate {

    //! Constructor
    public function initialize() {
        BehaviorDelegate.initialize();
    }

    //! Handle the menu event
    //! @return true if handled, false otherwise
    public function onMenu() as Boolean {
        var menu = new $.SolarSystemSettingsMenu();

       

        WatchUi.pushView(menu, new $.SolarSystemSettingsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}

