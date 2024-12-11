//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Storage;

//! The app settings menu
class SolarSystemSettingsMenu extends WatchUi.Menu2 {

    //! Constructor
    public function initialize() {

    Menu2.initialize({:title=>"Settings"});

    if ($.Options_Dict["Label Display Option"] == null) { $.Options_Dict["Label Display Option"] = $.labelDisplayOption_default; }
    Menu2.addItem(new WatchUi.MenuItem("Display Planet Labels?",
        $.labelDisplayOption[$.Options_Dict["Label Display Option"]],"Label Display Option",{}));

    if ($.Options_Dict["Refresh Option"] == null) { $.Options_Dict["Refresh Option"] = $.refreshOption_default; }
    Menu2.addItem(new WatchUi.MenuItem("Screen Refresh Rate?",
    $.refreshOption[$.Options_Dict["Refresh Option"]],"Refresh Option",{}));    

    if ($.Options_Dict["Screen0 Move Option"] == null) { $.Options_Dict["Screen0 Move Option"] = $.screen0MoveOption_default; }
    Menu2.addItem(new WatchUi.MenuItem("Time interval (init screen)?",
    $.screen0MoveOption[$.Options_Dict["Screen0 Move Option"]],"Screen0 Move Option",{}));    

        /*
        $.Settings_ran = true;
        
        var clockTime = System.getClockTime();
        System.println(clockTime.hour +":" + clockTime.min + " - Settings running");

        Menu2.initialize({:title=>"Settings"});
        //var menu = new $.ElegantAnaSettingsMenu();
        //boolean = Storage.getValue("Second Hand On") ? true : false;
        //Menu2.addItem(new WatchUi.ToggleMenuItem("Second Hand: Off-On", null, "Second Hand On", boolean, null));

        //boolean = Storage.getValue("Infinite Second") ? true : false;
        //Menu2.addItem(new WatchUi.ToggleMenuItem("Second Hand after sleep: 2mins-Infinite", null, "Infinite Second", boolean, null));

        if ($.Options_Dict["Infinite Second Option"] == null) { $.Options_Dict["Infinite Second Option"] = $.infiniteSecondOptions_default; }
        Menu2.addItem(new WatchUi.MenuItem("Second Hand Run Time (after wake-up):",
            $.infiniteSecondOptions[$.Options_Dict["Infinite Second Option"]],"Infinite Second Option",{}));

        //var boolean = Storage.getValue("Long Second") ? true : false;
        //Menu2.addItem(new WatchUi.ToggleMenuItem("Second Hand Length: Short-Long", null, "Long Second", boolean, null));

        if ($.Options_Dict["Second Display"] == null) { $.Options_Dict["Second Display"] = $.secondDisplayOptions_default; }
        Menu2.addItem(new WatchUi.MenuItem("Second Hand Display:",
            $.secondDisplayOptions[$.Options_Dict["Second Display"]],"Second Display",{}));

        if ($.Options_Dict["Second Hand Option"] == null) { $.Options_Dict["Second Hand Option"] = $.secondHandOptions_default; }
        Menu2.addItem(new WatchUi.MenuItem("Second Hand Shape:",
            $.secondHandOptions[$.Options_Dict["Second Hand Option"]],"Second Hand Option",{}));

           

        //boolean = Storage.getValue("Wide Second") ? true : false;
        //Menu2.addItem(new WatchUi.ToggleMenuItem("Second Hand Size: Narrow-Wide", null, "Wide Second", boolean, null));                

        var boolean = Storage.getValue("Show Battery") ? true : false;
        Menu2.addItem(new WatchUi.ToggleMenuItem("Show Battery %: No-Yes", null, "Show Battery", boolean, null));            

        boolean = Storage.getValue("Show Minutes") ? true : false;
        Menu2.addItem(new WatchUi.ToggleMenuItem("Show Wkly Activity Minutes: No-Yes", null, "Show Minutes", boolean, null));

        boolean = Storage.getValue("Show Day Minutes") ? true : false;
        Menu2.addItem(new WatchUi.ToggleMenuItem("Show Daily Activity Minutes: No-Yes", null, "Show Day Minutes", boolean, null));

        boolean = Storage.getValue("Show Steps") ? true : false;
        Menu2.addItem(new WatchUi.ToggleMenuItem("Show Daily Steps: No-Yes", null, "Show Steps", boolean, null));

        boolean = Storage.getValue("Show Move") ? true : false;
        Menu2.addItem(new WatchUi.ToggleMenuItem("Show Move Bar: No-Yes", null, "Show Move", boolean, null));        


        boolean = Storage.getValue("Show Date") ? true : false;
        Menu2.addItem(new WatchUi.ToggleMenuItem("Show Date: No-Yes", null, "Show Date", boolean, null));

        if ($.Options_Dict["Dawn/Dusk Markers"] == null) { $.Options_Dict["Dawn/Dusk Markers"] = $.dawnDuskOptions_default; }
        Menu2.addItem(new WatchUi.MenuItem("Day/Night Markers:",
            $.dawnDuskOptions[$.Options_Dict["Dawn/Dusk Markers"]],"Dawn/Dusk Markers",{}));         

        boolean = Storage.getValue("Hour Numbers") ? true : false;
        Menu2.addItem(new WatchUi.ToggleMenuItem("Hour Numbers: Off-On", null, "Hour Numbers", boolean, null));        

        boolean = Storage.getValue("Hour Hashes") ? true : false;
        Menu2.addItem(new WatchUi.ToggleMenuItem("Hour Hashes: Off-On", null, "Hour Hashes", boolean, null));        

        boolean = Storage.getValue("Second Hashes") ? true : false;
        Menu2.addItem(new WatchUi.ToggleMenuItem("Second Hashes: Off-On", null, "Second Hashes", boolean, null));                        
        */
    }
}

//! Input handler for the app settings menu
class SolarSystemSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    var mainView;
    //! Constructor
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

        //! Handle a menu item being selected
    //! @param menuItem The menu item selected
    public function onSelect(menuItem as MenuItem) as Void {
        
        /*if (menuItem instanceof ToggleMenuItem) {
            Storage.setValue(menuItem.getId() as String, menuItem.isEnabled());
            $.Options_Dict[menuItem.getId() as String] = menuItem.isEnabled();
            $.Settings_ran = true;
        }*/
        
        var id=menuItem.getId();

        if(id.equals("Label Display Option")) {
        $.Options_Dict[id]=($.Options_Dict[id]+1)%labelDisplayOption_size;
        menuItem.setSubLabel($.labelDisplayOption[$.Options_Dict[id]]);

        Storage.setValue(id as String, $.Options_Dict[id]);            
        }

        if(id.equals("Refresh Option")) {
        $.Options_Dict[id]=($.Options_Dict[id]+1)%refreshOption_size;
        menuItem.setSubLabel($.refreshOption[$.Options_Dict[id]]);

        Storage.setValue(id as String, $.Options_Dict[id]); 
        //[ "5hz", "4hz", "3hz", "2hz", "1hz", "2/3hz", "1/2hz"];
        switch ($.Options_Dict[id]) {
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

        solarSystemView_class.startAnimationTimer($.hz);           
        }

        if(id.equals("Screen0 Move Option")) {
        $.Options_Dict[id]=($.Options_Dict[id]+1)%screen0MoveOption_size;
        menuItem.setSubLabel($.screen0MoveOption[$.Options_Dict[id]]);

        Storage.setValue(id as String, $.Options_Dict[id]);    

        if ($.Options_Dict["Screen0 Move Option"] != null) { $.screen0Move_index = 27 + $.Options_Dict["Screen0 Move Option"];}
        else {$.screen0Move_index = 31;}         
        }


    }
    /*
    //! Handle a menu item being selected
    //! @param menuItem The menu item selected
    public function onSelect(menuItem as MenuItem) as Void {
        if (menuItem instanceof ToggleMenuItem) {
            Storage.setValue(menuItem.getId() as String, menuItem.isEnabled());
            $.Options_Dict[menuItem.getId() as String] = menuItem.isEnabled();
            $.Settings_ran = true;
        }

        var id=menuItem.getId();
        if(id.equals("Infinite Second Option")) {
            $.Options_Dict[id]=($.Options_Dict[id]+1)%infiniteSecondOptions_size;
            menuItem.setSubLabel($.infiniteSecondOptions[$.Options_Dict[id]]);

            Storage.setValue(id as String, $.Options_Dict[id]);            
            $.Settings_ran = true;
            //MySettings.writeKey(MySettings.backgroundKey,MySettings.backgroundIdx);
            //MySettings.background=MySettings.getColor(null,null,null,MySettings.backgroundIdx);
        }

        if(id.equals("Second Display")) {
            $.Options_Dict[id]=($.Options_Dict[id]+1)%secondDisplayOptions_size;
            menuItem.setSubLabel($.secondDisplayOptions[$.Options_Dict[id]]);

            Storage.setValue(id as String, $.Options_Dict[id]);            
            $.Settings_ran = true;
            //MySettings.writeKey(MySettings.backgroundKey,MySettings.backgroundIdx);
            //MySettings.background=MySettings.getColor(null,null,null,MySettings.backgroundIdx);
        }

        if(id.equals("Second Hand Option")) {
            $.Options_Dict[id]=($.Options_Dict[id]+1)%secondHandOptions_size;
            menuItem.setSubLabel($.secondHandOptions[$.Options_Dict[id]]);

            Storage.setValue(id as String, $.Options_Dict[id]);            
            $.Settings_ran = true;
            //MySettings.writeKey(MySettings.backgroundKey,MySettings.backgroundIdx);
            //MySettings.background=MySettings.getColor(null,null,null,MySettings.backgroundIdx);
        }

        if(id.equals("Dawn/Dusk Markers")) {
            $.Options_Dict[id]=($.Options_Dict[id]+1)%dawnDuskOptions_size;
            menuItem.setSubLabel($.dawnDuskOptions[$.Options_Dict[id]]);

            Storage.setValue(id as String, $.Options_Dict[id]);            
            $.Settings_ran = true;
            //MySettings.writeKey(MySettings.backgroundKey,MySettings.backgroundIdx);
            //MySettings.background=MySettings.getColor(null,null,null,MySettings.backgroundIdx);
        }
        
    }
    */
    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        //return false;
    }
}