//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Storage;

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



//! The app settings menu
class SolarSystemSettingsMenu extends WatchUi.Menu2 {

    //! Constructor
    public function initialize() {
        //sssMenu_class = self;    

        orrZoomOption = toArray(WatchUi.loadResource($.Rez.Strings.orrzoom) as String,  "|", 0);

        //loadPlanetsOpt();

        //var boolean;
        Menu2.initialize({:title=>"Settings"});
            
        Menu2.addItem(new WatchUi.ToggleMenuItem("Exit App", null, "exitapp", false, null));

        Menu2.addItem(new WatchUi.ToggleMenuItem("Reset to Current Time", null, "resetDate", false, null));
    

        if ($.Options_Dict["orrZoomOption"] == null) { $.Options_Dict["orrZoomOption"] = $.orrZoomOption_default; }
        Menu2.addItem(new WatchUi.MenuItem("Solar System Zoom?",
        $.orrZoomOption[$.Options_Dict["orrZoomOption"]],"orrZoomOption",{}));   

        if ($.Options_Dict["thetaOption"] == null) { $.Options_Dict["thetaOption"] = $.thetaOption_default; }
        Menu2.addItem(new WatchUi.MenuItem("UP/DOWN/Swipe controls:",
        ($.thetaOption[$.Options_Dict["thetaOption"]]),"thetaOption",{}));

        if ($.Options_Dict["planetsOption"] == null) { $.Options_Dict["planetsOption"] = $.planetsOption_default; }
        Menu2.addItem(new WatchUi.MenuItem("Objects to show in Solar System?",
        $.planetsOption[$.Options_Dict["planetsOption"]],"planetsOption",{}));  

        /*
        if ($.Options_Dict["Screen0 Move Option"] == null) { $.Options_Dict["Screen0 Move Option"] = $.screen0MoveOption_default; }
        Menu2.addItem(new WatchUi.MenuItem("Manual Mode Time Interval",
        $.screen0MoveOption[$.Options_Dict["Screen0 Move Option"]],"Screen0 Move Option",{})); 
        */


        
        if ($.Options_Dict["Planet Size Option"] == null) { $.Options_Dict["Planet Size Option"] = $.planetSizeOption_default; }
        Menu2.addItem(new WatchUi.MenuItem("Planet Display Size?",
        $.planetSizeOption[$.Options_Dict["Planet Size Option"]],"Planet Size Option",{}));   

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
        if ($.Options_Dict["Label Display Option"] == null) { $.Options_Dict["Label Display Option"] = $.labelDisplayOption_default; }
        Menu2.addItem(new WatchUi.MenuItem("Display Planet Labels?",
            $.labelDisplayOption[$.Options_Dict["Label Display Option"]],"Label Display Option",{}));

        Menu2.addItem(new WatchUi.ToggleMenuItem("Help Banners: Off-On", null, "helpBanners", $.Options_Dict["helpBanners"], null));        

        if ($.Options_Dict["Refresh Option"] == null) { $.Options_Dict["Refresh Option"] = $.refreshOption_default; }
        Menu2.addItem(new WatchUi.MenuItem("Screen Refresh Rate?",
        $.refreshOption[$.Options_Dict["Refresh Option"]],"Refresh Option",{})); 

        var pA = getPlanetAbbreviation(0);
        planetAbbreviation_index = pA[1];
        Menu2.addItem(new WatchUi.MenuItem("Planet Abbreviations", pA , :helpOption, {}));

        /*if ($.Options_Dict["helpOption"] == null) { $.Options_Dict["helpOption"] = helpOption_default; }
        Menu2.addItem(new WatchUi.MenuItem("Help - Abbreviations",
        helpOption[$.Options_Dict["helpOption"]],"helpOption",{}));       */

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
            if (ret != null && ret.equals("exitapp")) {
                System.println("EXIT COMMAND RECEIVED (settings) ....");
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                System.exit();
            } else 
           
            if (ret != null && ret.equals("resetDate")) {
                $.time_add_hrs = 0;
                $.started=false;
                $.reset_date_stop = true;
                $.run_oneTime = true;
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                
            } 
            
            else {
                Storage.setValue(ret, menuItem.isEnabled());
                $.Options_Dict[ret] = menuItem.isEnabled();
            }
            
        }
        
        var id=menuItem.getId();

        if(id.equals("orrZoomOption")) {
        $.Options_Dict[id]=($.Options_Dict[id]+1)%orrZoomOption_size;
        menuItem.setSubLabel($.orrZoomOption[$.Options_Dict[id]]);

        Storage.setValue(id as String, $.Options_Dict[id]);    

        $.newModeOrZoom = true; //makes the scale in orrery re-set, and re-display the time interval & re-start dots
        
        }

        if(id.equals("thetaOption")) {
        $.Options_Dict[id]=($.Options_Dict[id]+1)%thetaOption_size;
        menuItem.setSubLabel($.thetaOption[$.Options_Dict[id]]);

        Storage.setValue(id as String, $.Options_Dict[id]);    

        $.newModeOrZoom = true; //makes the scale in orrery re-set, and re-display the time interval & re-start dots
        
        }


            if(id.equals("planetsOption")) {
            $.Options_Dict[id]=($.Options_Dict[id]+1)%planetsOption_size;
            menuItem.setSubLabel($.planetsOption[$.Options_Dict[id]]);

            Storage.setValue(id as String, $.Options_Dict[id]);    

            planetsOption_value = $.Options_Dict[id]; //use the number here, 0 or 1, not te dictionary from _values.  UNUSUAL.

            $.show_intvl = 0;
            //$.animSinceModeChange = 0;
        
        }
        //helpOption
        if(id.equals(:helpOption)) {
            //var index = $.Options_Dict[id] || 0;            
            planetAbbreviation_index = (planetAbbreviation_index + 1) 
            % allPlanets.size();
            var pA = getPlanetAbbreviation(planetAbbreviation_index);
            planetAbbreviation_index = pA[1];
            menuItem.setSubLabel(pA[0]);
        }

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
        $.hz = refreshOption_values[$.Options_Dict[id]];
        solarSystemView_class.startAnimationTimer($.hz);           
        }


        if(id.equals("Planet Size Option")) {
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
        orrZoomOption = null;
        //cleanUpPlanetsOpt();


        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        //return false;
    }
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
    deBug("lpo before: ", allPlanets);
    allPlanets = toArray(WatchUi.loadResource($.Rez.Strings.planets_Options1) as String,  "|", 0);
    deBug("lpo after: ", allPlanets);
}

var planetAbbreviation_index = 0;
// Function to generate planet abbreviation and name
function getPlanetAbbreviation(index) {
    if (index < allPlanets.size()) {
        while (allPlanets[index].equals("AsteroidA") || allPlanets[index].equals("AsteroidB") || allPlanets[index].equals("Sun") {
            index = (index + 1) % allPlanets.size();
        }
        var planetName = allPlanets[index];
        return [planetName.substring(0, 2) + " " + planetName, index];
    }
    return ["", index];
}

function makePlanetsOpt(val){
    //deBug("mpo: ", allPlanets);
    //deBug("mpo2: ", [val, planetsOption_value]);
    var ret = []; //so, array2 = array1 only passes a REFERENCE to the array, they are both still the same array with different names.  AARRGGgH!!
    //So if you DON'T want this you need to do some tricks
    if (val == 2) {
                ret = [   //option #3, dwarf planets
        allPlanets[0],
        allPlanets[1],
        allPlanets[3],
        allPlanets[4],
        allPlanets[6],
        allPlanets[7],
        ];
        //deBug("mpo3: ", ret);
        ret.addAll(allPlanets.slice(-7, null));

        } //all objects
    if (val ==1 ) {
        ret.addAll(allPlanets.slice(0,13));
    } //Sun thru Pluto,  trad. planets
     else {
        
        ret.addAll(allPlanets); //to ensure it is a COPY just just a reference to same array

     }
    
    
    //deBug("mpo4: ", ret);
    return ret;
        
}
