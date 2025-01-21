//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Storage;
import Toybox.Position;

//var sssMenu_class; //to save the SolarSystemSettingsMenu class for access

//var helpOption;
//var helpOption_size;
//var helpOption_default = 0;
/*
var helpOption = [
    "Planet abbreviations:", 
    "Me Mercury", 
    "Ve Venus", 
    "Ea Earth", 
    "Ma Mars", 
    "Ju Jupiter", 
    "Sa Saturn", 
    "Ur Uranus", 
    "Ne Neptune", 
    "Pl Pluto", 
    "Er Eris (dwarf planet)", 
    "Ha Haumea (dwarf planet)", 
    "Ma Makemake (dwarf planet)", 
    "Go Gonggong (dwarf planet)", 
    "Qu Quaoar (ringed dwarf planet)", 
    "Ce Ceres (dwarf planet/asteroid)", 
    "Ch Chiron (ringed dwarf planet)"
];
*/

 /*   var helpOption=[
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
];*/

//var changeModeOption_nextMode=1;
//var changeModeOption_size;
//var changeModeOption;
var orrZoomOption,labelDisplayOption,planetsOption,planetSizeOption,thetaOption,refreshOption;
var jumpToGPS=false;
var _updatePositionNeeded = false;
var _rereadGPSNeeded = false;

function cleanUpSettingsOpt(){
    //changeModeOption = null;
    orrZoomOption = null;
    labelDisplayOption = null;
    planetsOption = null;
    planetSizeOption = null;
    thetaOption = null;
    refreshOption = null;
    allPlanets = null;

}

//! The app settings menu
class SolarSystemSettingsMenu extends WatchUi.Menu2 {

    
    
    

    
    
    function loadSettingsOpt(){
        //deBug("loadSettingsOpt",[]);
        //changeModeOption = toArray(WatchUi.loadResource($.Rez.Strings.changeModeOption) as String,  "|", 0);
        //changeModeOption_size = changeModeOption.size();
        orrZoomOption = toArray(WatchUi.loadResource($.Rez.Strings.orrzoom) as String,  "|", 0);
        labelDisplayOption = toArray(WatchUi.loadResource($.Rez.Strings.labelDisplayOption) as String,  "|", 0);
        refreshOption = toArray(WatchUi.loadResource($.Rez.Strings.refreshOption) as String,  "|", 0);
        thetaOption = toArray(WatchUi.loadResource($.Rez.Strings.thetaOption) as String,  "|", 0);planetSizeOption = toArray(WatchUi.loadResource($.Rez.Strings.planetSizeOption) as String,  "|", 0);planetsOption = toArray(WatchUi.loadResource($.Rez.Strings.planetsOption) as String,  "|", 0);
        allPlanets = toArray(WatchUi.loadResource($.Rez.Strings.planets_Options1) as String,  "|", 0);
        //deBug("loadSettingsOpt finished",[]);
    }

    //! Constructor
    public function initialize() {
        //sssMenu_class = self;    

        
        loadSettingsOpt();

        //loadPlanetsOpt();

        //var boolean;
        Menu2.initialize({:title=>WatchUi.loadResource($.Rez.Strings.sts) as String});
            
        //Menu2.addItem(new WatchUi.ToggleMenuItem("Exit App", null, changeMode_enum, false, null));
        /*changeModeOption_nextMode = $.view_mode;
        Menu2.addItem(new WatchUi.MenuItem("Change mode:",
        changeModeOption[$.view_mode],changeMode_enum,{}));  
        */ 

        Menu2.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource($.Rez.Strings.rst) as String, null, resetDate_enum, false, null));
        
        //deBug("1", []);

        if ($.Options_Dict[orrZoomOption_enum] == null) { $.Options_Dict[orrZoomOption_enum] = $.orrZoomOption_default; }
        Menu2.addItem(new WatchUi.MenuItem(WatchUi.loadResource($.Rez.Strings.zm) as String,
        orrZoomOption[$.Options_Dict[orrZoomOption_enum]],orrZoomOption_enum,{}));   

        if ($.Options_Dict[thetaOption_enum] == null) { $.Options_Dict[thetaOption_enum] = $.thetaOption_default; }
        Menu2.addItem(new WatchUi.MenuItem(WatchUi.loadResource($.Rez.Strings.uds) as String,
        ($.thetaOption[$.Options_Dict[thetaOption_enum]]),thetaOption_enum,{}));

        //deBug("2", []);

        //if ($.Options_Dict[extraPlanetsOption_enum] == null) { $.Options_Dict[extraPlanetsOption_enum] = $.planetsOption_default; }
        Menu2.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource($.Rez.Strings.exo) as String, null, extraPlanetsOption_enum, $.Options_Dict[extraPlanetsOption_enum], null));  

        if ($.Options_Dict[planetsOption_enum] == null) { $.Options_Dict[planetsOption_enum] = $.planetsOption_default; }
        //Menu2.addItem(new WatchUi.MenuItem(WatchUi.loadResource($.Rez.Strings.osss) as String,null,planetsOption_enum,
        //$.planetsOption[$.Options_Dict[planetsOption_enum]],null));  
        Menu2.addItem(new WatchUi.MenuItem(WatchUi.loadResource($.Rez.Strings.osss) as String,
        $.planetsOption[$.Options_Dict[planetsOption_enum]],planetsOption_enum,{})); 

        /*
        if ($.Options_Dict[screen0MoveOption_enum] == null) { $.Options_Dict[screen0MoveOption_enum] = $.screen0MoveOption_default; }
        Menu2.addItem(new WatchUi.MenuItem("Manual Mode Time Interval",
        $.screen0MoveOption[$.Options_Dict[screen0MoveOption_enum]],screen0MoveOption_enum,{})); 
        */


        
        if ($.Options_Dict[planetSizeOption_enum] == null) { $.Options_Dict[planetSizeOption_enum] = $.planetSizeOption_default; }
        Menu2.addItem(new WatchUi.MenuItem(WatchUi.loadResource($.Rez.Strings.pds) as String,
        $.planetSizeOption[$.Options_Dict[planetSizeOption_enum]],planetSizeOption_enum,{}));   

    /*
        if ($.Options_Dict["Ecliptic Size Option"] == null) { $.Options_Dict["Ecliptic Size Option"] = $.eclipticSizeOption_default; }
        Menu2.addItem(new WatchUi.MenuItem("Ecliptic Circle Size?",
        $.eclipticSizeOption[$.Options_Dict["Ecliptic Size Option"]],"Ecliptic Size Option",{}));    
        */

    /*
        if ($.Options_Dict["Orbit Circles Option"] == null) { $.Options_Dict["Orbit Circles Option"] = $.orbitCirclesOption_default; }
        Menu2.addItem(new WatchUi.MenuItem("Show Orbit Dots (SS View)?",
        $.orbitCirclesOption[$.Options_Dict["Orbit Circles Option"]],"Orbit Circles Option",{})); 
    */  
    /*
        if ($.Options_Dict["resetDots"] == null) { $.Options_Dict["resetDots"] = $.resetDots_default; }
        Menu2.addItem(new WatchUi.MenuItem("Reset Orbit Dots when speed changed?",
        $.resetDots[$.Options_Dict["resetDots"]],"resetDots",{}));   
    */
        if ($.Options_Dict[labelDisplayOption_enum] == null) { $.Options_Dict[labelDisplayOption_enum] = $.labelDisplayOption_default; }
        Menu2.addItem(new WatchUi.MenuItem(WatchUi.loadResource($.Rez.Strings.dpl) as String,
            $.labelDisplayOption[$.Options_Dict[labelDisplayOption_enum]],labelDisplayOption_enum,{}));

        Menu2.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource($.Rez.Strings.hboo) as String, null, helpBanners_enum, $.Options_Dict[helpBanners_enum], null));   

        //deBug("3", [gpsOption_enum, Options_Dict[gpsOption_enum], Options_Dict]);

        Menu2.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource($.Rez.Strings.uagp) as String, null, gpsOption_enum, $.Options_Dict[gpsOption_enum], null));

        //if ($.Options_Dict[gpsOption_enum] != null && !$.Options_Dict[gpsOption_enum] ) { 
                
            if ($.Options_Dict[latOption_enum] == null) { $.Options_Dict[latOption_enum] = $.latOption_default; }
            //deBug("3a", []);
            var val = ($.Options_Dict[latOption_enum] - 90);
            //deBug("3b", [val]);            
            //deBug("3c", [val]);
            Menu2.addItem(new WatchUi.MenuItem(WatchUi.loadResource($.Rez.Strings.mlat) as String, val.toString(),latOption_enum,{})); 
            //deBug("3d", [val]);
            
            if ($.Options_Dict[lonOption_enum] == null) { $.Options_Dict[lonOption_enum] = $.lonOption_default; }
            val = $.Options_Dict[lonOption_enum] - 180;            
            Menu2.addItem(new WatchUi.MenuItem(WatchUi.loadResource($.Rez.Strings.mlon) as String,val.toString(),lonOption_enum,{})); 
        //}

        //deBug("4", []);

        if ($.Options_Dict[refreshOption_enum] == null) { $.Options_Dict[refreshOption_enum] = $.refreshOption_default; }
        Menu2.addItem(new WatchUi.MenuItem(WatchUi.loadResource($.Rez.Strings.srr) as String,
        $.refreshOption[$.Options_Dict[refreshOption_enum]],refreshOption_enum,{})); 

        var pA = getPlanetAbbreviation(0);
        planetAbbreviation_index = pA[1];
        Menu2.addItem(new WatchUi.MenuItem(WatchUi.loadResource($.Rez.Strings.pa) as String, pA[0] ,helpOption_enum, {}));

        /*if ($.Options_Dict["helpOption"] == null) { $.Options_Dict["helpOption"] = helpOption_default; }
        Menu2.addItem(new WatchUi.MenuItem("Help - Abbreviations",
        helpOption[$.Options_Dict["helpOption"]],"helpOption",{}));       */

        //deBug("5", []);
        if ($.jumpToGPS) {
                var itemId = self.findItemById(gpsOption_enum);
                self.setFocus(itemId);
        }
        $.jumpToGPS = false;

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
        
        if (menuItem instanceof ToggleMenuItem) {
            //Storage.setValue(menuItem.getId() as String, menuItem.isEnabled());
            //$.Options_Dict[menuItem.getId() as String] = menuItem.isEnabled();
            var ret = menuItem.getId() as String;
                //System.println("Menu item toggled...." + ret);
            
            /*    
            if (ret != null && ret.equals(changeMode_enum)) {
                //System.println("Settings/exit");
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                System.exit();
            } else 
            */

            //deBug("retmenu:", [ret]);
           
            if (ret != null && ret.equals(resetDate_enum)) {
                $.time_add_hrs = 0;
                $.started=false;
                $.reset_date_stop = true;
                $.run_oneTime = true;
                $.LORR_show_horizon_line = true;
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                
            } 
            else if (ret != null && ret.equals(gpsOption_enum)) {
                
                /* 
                $.time_add_hrs = 0;
                $.started=false;
                $.reset_date_stop = true;
                $.run_oneTime = true;
                $.LORR_show_horizon_line = true;
                */
                //NOT going to store this, so that autoGPS is
                //enabled whenever the program starts.  They can
                //manually switch to their set GPS coordinates if they want.
                //Storage.setValue(ret, menuItem.isEnabled());
                $.Options_Dict[ret] = menuItem.isEnabled();
                //$.solarSystemView_class.setInitPosition();
                //$.jumpToGPS = true;                
                //WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                
                //instead of just doing this here, we wait until the MENU
                //has closed, thus saving memory.  Also only read GPS
                //again if really needed.
                //We were having memory faults here when reading GPS with menu open
                //GPS/position is inited in onupdate view, only when these flags are set
                _updatePositionNeeded = true;
                if (menuItem.isEnabled) {_rereadGPSNeeded = true;}
                

                //var settings_view = new $.SolarSystemSettingsView();
                //var settings_delegate = new $.SolarSystemSettingsDelegate();
        
                //pushView(settings_view, settings_delegate, WatchUi.SLIDE_IMMEDIATE);
                
            } 
            
            else {
                Storage.setValue(ret, menuItem.isEnabled());
                $.Options_Dict[ret] = menuItem.isEnabled();
            }
            
        }
        
        var id=menuItem.getId();
        /*
        if ( id.equals(changeMode_enum)) {
                //System.println("Settings/exit");
                /*WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                System.exit();*/
        /*        changeModeOption_nextMode = (changeModeOption_nextMode+1)%changeModeOption_size;
                menuItem.setSubLabel(changeModeOption[changeModeOption_nextMode]);
            } else
        */

        if(id.equals(orrZoomOption_enum)) {
        $.Options_Dict[id]=($.Options_Dict[id]+1)%orrZoomOption_size;
        menuItem.setSubLabel(orrZoomOption[$.Options_Dict[id]]);

        Storage.setValue(id as String, $.Options_Dict[id]);    

        $.newModeOrZoom = true; //makes the scale in orrery re-set, and re-display the time interval & re-start dots
        
        }

        if(id.equals(thetaOption_enum)) {
            $.Options_Dict[id]=($.Options_Dict[id]+1)%thetaOption_size;
            menuItem.setSubLabel($.thetaOption[$.Options_Dict[id]]);

            Storage.setValue(id as String, $.Options_Dict[id]);    

            //$.newModeOrZoom = true; //makes the scale in orrery re-set, and re-display the time interval & re-start dots
        
        }


            if(id.equals(planetsOption_enum)) {
            $.Options_Dict[id]=($.Options_Dict[id]+1)%planetsOption_size;
            menuItem.setSubLabel($.planetsOption[$.Options_Dict[id]]);

            Storage.setValue(id as String, $.Options_Dict[id]);    

            planetsOption_value = $.Options_Dict[id]; //use the number here, 0 or 1, not te dictionary from _values.  UNUSUAL.

            $.show_intvl = 0;
            //$.animSinceModeChange = 0;
        
        }
        //helpOption
        if(id.equals(helpOption_enum)) {
            //var index = $.Options_Dict[id] || 0;            
            //planetAbbreviation_index = (planetAbbreviation_index + 1) 
            //% allPlanets.size();
            //planetAbbreviation_index = (planetAbbreviation_index + 1) 
            //% (toArray(WatchUi.loadResource($.Rez.Strings.planets_Options1) as String,  "|", 0)).size();

            planetAbbreviation_index = (planetAbbreviation_index + 1)%20;
            
            var pA = getPlanetAbbreviation(planetAbbreviation_index);
            planetAbbreviation_index = pA[1];
            menuItem.setSubLabel(pA[0]);
        }

        if(id.equals(labelDisplayOption_enum)) {
        $.Options_Dict[id]=($.Options_Dict[id]+1)%labelDisplayOption_size;
        menuItem.setSubLabel($.labelDisplayOption[$.Options_Dict[id]]);

        Storage.setValue(id as String, $.Options_Dict[id]);            
        }

        if(id.equals(refreshOption_enum)) {
        $.Options_Dict[id]=($.Options_Dict[id]+1)%refreshOption_size;
        menuItem.setSubLabel($.refreshOption[$.Options_Dict[id]]);

        Storage.setValue(id as String, $.Options_Dict[id]); 
        //[ "5hz", "4hz", "3hz", "2hz", "1hz", "2/3hz", "1/2hz"];
        $.hz = refreshOption_values[$.Options_Dict[id]];
        solarSystemView_class.startAnimationTimer($.hz);           
        }

        if(id.equals(latOption_enum)) {
            $.Options_Dict[id]=($.Options_Dict[id]+2)%latOption_size;
            menuItem.setSubLabel(($.Options_Dict[id]-90).toString());
            //else {menuItem.setSubLabel("GPS");}

            Storage.setValue(id as String, $.Options_Dict[id]); 
            //[ "5hz", "4hz", "3hz", "2hz", "1hz", "2/3hz", "1/2hz"];
            $.latlonOption_value[0] = $.Options_Dict[id];     
            //$.solarSystemView_class.setInitPosition();       
            _updatePositionNeeded = true;
        }

        if(id.equals(lonOption_enum)) {
            $.Options_Dict[id]=($.Options_Dict[id]+5)%lonOption_size;
            menuItem.setSubLabel(($.Options_Dict[id]-180).toString());
            //else {menuItem.setSubLabel("GPS");}

            Storage.setValue(id as String, $.Options_Dict[id]); 
            //[ "5hz", "4hz", "3hz", "2hz", "1hz", "2/3hz", "1/2hz"];
            $.latlonOption_value[1] = $.Options_Dict[id];  
            //$.solarSystemView_class.setInitPosition();          
            _updatePositionNeeded = true;
        }


        if(id.equals(planetSizeOption_enum)) {
        $.Options_Dict[id]=($.Options_Dict[id]+1)%planetSizeOption_size;
        menuItem.setSubLabel($.planetSizeOption[$.Options_Dict[id]]);

        Storage.setValue(id as String, $.Options_Dict[id]);    

        planetSizeFactor = planetSizeOption_values[$.Options_Dict[id]];        
        }

        /*
        if(id.equals("Ecliptic Size Option")) {
        $.Options_Dict[id]=($.Options_Dict[id]+1)%eclipticSizeOption_size;
        menuItem.setSubLabel($.eclipticSizeOption[$.Options_Dict[id]]);

        Storage.setValue(id as String, $.Options_Dict[id]);    

        eclipticSizeFactor = eclipticSizeOption_values[$.Options_Dict[id]];
        
        }
        */
/*
        if(id.equals("Orbit Circles Option")) {
        $.Options_Dict[id]=($.Options_Dict[id]+1)%orbitCirclesOption_size;
        menuItem.setSubLabel($.orbitCirclesOption[$.Options_Dict[id]]);

        Storage.setValue(id as String, $.Options_Dict[id]);            
        
        }
        */
/*
        if(id.equals("resetDots")) {
        $.Options_Dict[id]=($.Options_Dict[id]+1)%resetDots_size;
        menuItem.setSubLabel($.resetDots[$.Options_Dict[id]]);

        Storage.setValue(id as String, $.Options_Dict[id]);            
        
        }
        */


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

        //cleanUpSettingsOpt(); //don't need this as the class is just destroyed on exit
        //cleanUpPlanetsOpt();

        $.cleanUpSettingsOpt();
        
        /*
        if (changeModeOption_nextMode == 0) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            System.exit();
        }
        else if (changeModeOption_nextMode != -1 && changeModeOption_nextMode != $.view_mode){
            var previousMode = $.view_mode;
            $.view_mode = changeModeOption_nextMode;
            $.changeModes(previousMode);
            $.save_started = false; //always STOP when changing modes
            WatchUi.requestUpdate();
        }
        */

        
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.requestUpdate();
        //return false;
    }

    //! Update the current position
    //! @param info Position information
   /* public function onPosition(info as Info) as Void {
        //System.println("onPosition... count: " + $.count);
        solarSystemView_class.setPosition(info);

    }*/


}
/*function cleanUpPlanetsOpt(){
        return;
        for (var i = 0; i<planetsOption_values.size() ; i++ ){
            if (i == planetsOption_value || i == 1) {continue;} //PO #1 always needed by VSOP87a
            planetsOption_values[i] = null;
        }
} */
function loadPlanetsOpt(){
    //var po1 = toArray(WatchUi.loadResource($.Rez.Strings.planets_Options1) as String,  "|", 0);
    //var po2 = toArray(WatchUi.loadResource($.Rez.Strings.planets_Options2) as String,  "|", 0);
    //var po3 = toArray(WatchUi.loadResource($.Rez.Strings.planets_Options3) as String,  "|", 0);
    //planetsOption_values=[po1, po2, po3];
    //deBug("lpo before: ", allPlanets);
    allPlanets = toArray(WatchUi.loadResource($.Rez.Strings.planets_Options1) as String,  "|", 0);
    //deBug("lpo after: ", allPlanets);

}



var planetAbbreviation_index = 0;
// Function to generate planet abbreviation and name
function getPlanetAbbreviation(index) {
    //loadPlanetsOpt();
    if (index < allPlanets.size()) {
        while (allPlanets[index].equals("AsteroidA") || allPlanets[index].equals("AsteroidB") || allPlanets[index].equals("Sun")){
            index = (index + 1) % allPlanets.size();
        }
        var planetName = allPlanets[index];
        return [planetName.substring(0, 2) + " " + planetName, index];
    }
    return ["", index];
    //allPlanets = null;
}

//as in Settings, 2 dwarf planets only ( plus a few extra like earth, moon, mercury to round it out)
//1 is traditional planets only; 0 is ALL.
function makePlanetsOpt(val){
    //deBug("mpo: ", allPlanets);
    //deBug("mpo2: ", [val, planetsOption_value]);
    var ret = []; //so, array2 = array1 only passes a REFERENCE to the array, they are both still the same array with different names.  AARRGGgH!!
    //So if you DON'T want this you need to do some tricks
    loadPlanetsOpt();
    if (val == 2) {
                ret = [   //option #3, dwarf planets only
        allPlanets[0],
        allPlanets[1],
        allPlanets[3],
        allPlanets[4],
        allPlanets[6],
        allPlanets[7],
        ];
        //deBug("mpo3: ", ret);
        ret.addAll(allPlanets.slice(-7, null));    
    } 
    //all objects
    else if (val ==1 ) {
        ret.addAll(allPlanets.slice(0,13));
    } //Sun thru Pluto,  trad. planets
     else {
        
        ret.addAll(allPlanets); //to ensure it is a COPY just just a reference to same array


    }
    allPlanets = null;
    
    
    //deBug("mpo4: ", ret);
    return ret;
        
}
