//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

var Options_Dict = {  };
var labelDisplayOption=[ "Always On", "Always Off", "Freq Flash", "Less Flash", "Random Flash"];
var labelDisplayOption_size = 5;
var labelDisplayOption_default = 2;

var refreshOption=[ "5hz", "4hz", "3hz", "2hz", "1hz", "2/3hz", "1/2hz"];
var refreshOption_size = 7;
var refreshOption_default = 2;

var screen0MoveOption=[ "1min", "2min", "4min", "10min", "15min", "30min", "1hr", "2hr"];
var screen0MoveOption_size = 8;
var screen0MoveOption_default = 4;

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
        System.println("onShow...");

        // if this is the first call to `onShow', then we want the menu to immediately appear
        if (firstShow) {
            System.println("firstShow...");
            //WatchUi.switchToView(new $.ElegantAnaSettingsMenu(), new $.ElegantAnaSettingsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
            WatchUi.pushView(new $.SolarSystemSettingsMenu(), new $.SolarSystemSettingsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
            //WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            firstShow = false;
        }

        // otherwise, we are returning to this view, most likely be cause the menu was exited,
        // either by pressing back, or by selecting an item that caused the menu to be popped,
        // so we want to pop ourselves
        else {
            System.println("not firstShow...");
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
        
        System.println("onUpdate/settings...");

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

        /*
        var boolean = Storage.getValue("Show Move") ? true : false;
        menu.addItem(new WatchUi.ToggleMenuItem("Show Move: No-Yes", null, "Show Move", boolean, null));

        boolean = Storage.getValue("Show Battery") ? true : false;
        menu.addItem(new WatchUi.ToggleMenuItem("Show Battery: No-Yes", null, "Show Battery", boolean, null));

        boolean = Storage.getValue("Second Hashes") ? true : false;
        menu.addItem(new WatchUi.ToggleMenuItem("Second Hashes: Off-On", null, "Second Hashes", boolean, null));

        boolean = Storage.getValue("Second Hand On") ? true : false;
        menu.addItem(new WatchUi.ToggleMenuItem("Second Hand: Off-On", null, "Second Hand On", boolean, null));

        boolean = Storage.getValue("Wide Second") ? true : false;
        menu.addItem(new WatchUi.ToggleMenuItem("Second Hand Size: Narrow-Wide", null, "Wide Second", boolean, null));

        boolean = Storage.getValue("Long Second") ? true : false;
        menu.addItem(new WatchUi.ToggleMenuItem("Second Hand Length: Short-Long", null, "Long Second", boolean, null));
        
        boolean = Storage.getValue("Infinite Second") ? true : false;
        menu.addItem(new WatchUi.ToggleMenuItem("Second Hand after sleep: 2mins-Infinite", null, "Infinite Second", boolean, null));
        */
        /*
        boolean = Storage.getValue(3) ? true : false;
        menu.addItem(new WatchUi.ToggleMenuItem("Settings3", null, 3, boolean, null));

        boolean = Storage.getValue(4) ? true : false;
        menu.addItem(new WatchUi.ToggleMenuItem("Settings4", null, 4, boolean, null));
        */

        WatchUi.pushView(menu, new $.SolarSystemSettingsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}
