import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Math;
import Toybox.System;

var settings_view, settings_delegate;
var exiting_back_button_firstpress=false;
var change_mode_select_button_firstpress = false;
var EBBF_next_mode = 1;

//! Handle input on initial view
class SolarSystemBaseDelegate extends WatchUi.BehaviorDelegate {
    private var _mainview;
    //! Constructor
    public function initialize(view) {
        BehaviorDelegate.initialize();
        //System.println("delegate initl..");
        _mainview = view;
    }
    var last_animation_count = 0;
    var animation_retry_tally = 0;


    //! Handle the select button
    //! @return true if handled, false otherwise
    public function onSelect() as Boolean {

        $.buttonPresses++;
        $.timeWasAdded=true;
        $.LORR_show_horizon_line = false;
        //$.exiting_back_button_firstpress=false;
        if (buttonPresses == 1) {return true;} //1st buttonpress just gets out of intro titles

        if (_mainview.animation_count == last_animation_count) {
            animation_retry_tally ++;
            if (animation_retry_tally%3 == 0) {
                _mainview.startAnimationTimer($.hz);
            }

        } else {
            animation_retry_tally =0;            
        }
        last_animation_count=_mainview.animation_count;

        if ($.exiting_back_button_firstpress)
        {
            $.exiting_back_button_firstpress=false;
                $.change_mode_select_button_firstpress= false;
                if ($.view_mode == $.EBBF_next_mode) {return true;} //staying in the current mode
                var old_index = $.view_mode;
                $.view_mode = $.EBBF_next_mode;                
                if ( $.view_mode <1 ) {$.view_mode = 1;} 
                if ( $.view_mode >= num_view_modes ) {$.view_mode = num_view_modes - 1;} 
                started = false;
                $.show_intvl = 0;

                $.changeModes(old_index);  

        } else {

        
            //if stopped, it starts playing (whatever mode we're in)
            //if started already, it moves to next mode
            if (!started && $.view_mode != 0) {
                started = true;
        
                //WatchUi.requestUpdate();
            } else {
                //System.println("delegate onselect... moving to new mode" + $.view_mode);

                
                //if we stop & forward step == 0 we set it to the lowest value
                if (($.speeds[$.speeds_index]).abs() < 0.001) {
                    deBug("zero & moving up!!!!!",[]);
                    handleNextPrevious (:previous); 
                }

                started = false;

                /*if ($.change_mode_select_button_firstpress) {

                    $.change_mode_select_button_firstpress= false;
                    var old_index = $.view_mode;
                    $.view_mode = ($.view_mode + 1) % $.num_view_modes; 
                    if ( $.view_mode <1 ) {$.view_mode = 1;} 
                    started = true;
                    $.show_intvl = 0;

                    $.changeModes(old_index);  

                } else {

                    solarSystemView_class.sendMessage(1000000, ["==THE PLANETS==", "Press Select again"
                    , "to change mode", "", ""]);

                    $.change_mode_select_button_firstpress = true;
                    $.timeWasAdded=true; //makes the message appear/one screenredraw, like when pressing up/down & started==false
                    //$.time_add_hrs +=0.000001;
                    $.run_oneTime = true;

                    WatchUi.requestUpdate(); //when pressing back button, often the screen doesn't update at new MODE, trying to correct that
                } */



            }
        }

        
        return true;
    }

        //! Handle the select button
    //! @return true if handled, false otherwise

    //if stopped, moved back one mode
    //if started, stop.
    public function onBack() as Boolean {
        $.buttonPresses++;
        $.timeWasAdded=true;
        $.LORR_show_horizon_line = false;
        $.change_mode_select_button_firstpress = false;
        if (buttonPresses == 1) {return true;} //1st buttonpress just gets out of intro titles

        //$.show_intvl = 0; //This makes screen clear of orbits, not good
        //if (!started || $.view_mode == 0) {
            /*
            var old_index = $.view_mode;
            $.view_mode = ($.view_mode - 1);        
            if ($.view_mode < 1) {  //mode 1 is the first one now
                return false;
            }
            started = true;
            $.show_intvl = 0;
            $.changeModes(old_index);  
            */
            //EXIT APP on 2nd push of BACK BUTTONG
            if ($.exiting_back_button_firstpress) {

                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                System.exit();

            }
            solarSystemView_class.sendMessage(1000000, ["==THE PLANETS==", "SELECT: Next mode"
            , "BACK: Exit", "", ""]);

            $.EBBF_next_mode = ($.view_mode + 1) % $.num_view_modes; 
            if ($.EBBF_next_mode ==0) {
                $.EBBF_next_mode = 1;
             }

            $.exiting_back_button_firstpress = true;
             $.timeWasAdded=true; //makes the message appear/one screenredraw, like when pressing up/down & started==false
             $.time_add_hrs +=0.000001;
             $.run_oneTime = true;

            WatchUi.requestUpdate(); //when pressing back button, often the screen doesn't update at new MODE, trying to correct that
        /* } else {
            started = false;

            //if we stop & forward step == 0 we set it to the lowest value
            if (($.speeds[$.speeds_index]).abs() < 0.001) {
                handleNextPrevious (:next); 
            }
        }*/    
        
        //var view = _mainview;
        //var delegate = new $.SolarSystemBaseDelegate(view);
        
        //popView(WatchUi.SLIDE_RIGHT);//(view, delegate, WatchUi.SLIDE_IMMEDIATE);

        WatchUi.requestUpdate();//sometimes there is a blank screen after "back" so trying to prevent that...
        return true;
    }

    function handleNextPrevious (type){
        //_view.nextSensor();
        //$.show_intvl = false;
        //_mainview.$.time_add_hrs -= _mainview.time_add_inc;
        var mult = (type == :next) ? -1 : 1; //forward OR back dep on button

        //System.println("onNextPage..." + mult + " " + type);
        $.buttonPresses++; 

        if ($.exiting_back_button_firstpress) {

            $.EBBF_next_mode = ($.EBBF_next_mode + mult) % $.num_view_modes; 

            if ($.EBBF_next_mode ==0) {
                $.EBBF_next_mode = mult;
                if (mult < 0) {$.EBBF_next_mode = num_view_modes-1;}
                
            }

            
            
            var changeModeOption = toArray(WatchUi.loadResource($.Rez.Strings.changeModeOption) as String,  "|", 0);
            var changeModeOption_size = changeModeOption.size();
            if ($.EBBF_next_mode > changeModeOption_size) {$.EBBF_next_mode = changeModeOption_size;}

            var nm = changeModeOption[$.EBBF_next_mode];
            if ($.EBBF_next_mode == view_mode) {nm = "Current mode";}
            if ($.EBBF_next_mode == view_mode + 1) {nm = "Next (" + nm + ")";}


            solarSystemView_class.sendMessage(1000000, ["==THE PLANETS==", "SEL: " + nm
            , "BACK: Exit", "", ""]);

            //$.exiting_back_button_firstpress=false;
            //$.change_mode_select_button_firstpress = false;  
            changeModeOption = null; 
            return; 
        }

        $.exiting_back_button_firstpress=false;
        $.change_mode_select_button_firstpress = false;
        
        $.run_oneTime = true; //in case we're stopped, it will run just once
        if (buttonPresses == 1) {return;} //1st buttonpress just gets out of intro titles

        var in = $.view_mode;
        var od = $.Options_Dict[thetaOption_enum]; //od 0 change time intv, 1 = altitude (theta), 2 = direction (gamma)

        //System.println("onNextPage... od:" + od + " in:" + in + " type==next: " + ( type == :next));

        if (in == 0 ) {
            $.time_add_hrs += mult *$.speeds[$.speeds_index];
            $.timeWasAdded=true;
            //WatchUi.requestUpdate();
        } else if (in == 1 || in ==2 || (in > 2 && od ==0)){
            $.LORR_show_horizon_line = false;
            //deBug("HI MOM!", []);
            if (started)  {
                $.speeds_index +=  mult;
                if ($.speeds_index>= $.speeds.size()) {$.speeds_index = $.speeds.size()-1;}
                if ($.speeds_index<0)  {$.speeds_index=0; }

                //For "Big" time movement screens, skip over all the 
                //time steps from like -24 to 24 hours, except for Zero
                if ([2,5,6,7,8].indexOf($.view_mode) > -1) {
                    if ($.speeds_index <47 && $.speeds_index >34) {
                        $.speeds_index = type == :next ? 34 : 47;}        
                    else if ($.speeds_index <34 && $.speeds_index >21) {
                        $.speeds_index = type == :next ? 21 : 34;}    
                $.speedWasChanged = true;
                                               
            }
            } else {
                $.time_add_hrs += mult *$.speeds[$.speeds_index];
                $.timeWasAdded=true;
            }
        }
        
        //System.println("Gon next pageA " + ga_rad + mult + type);

        /*if (in>2 && od ==1 ) { ga_rad += mult * Math.PI/18.0; 
            //System.println("Gon next pageA " + ga + mult + type);
        }
        if (in>2 && od ==2 ) { the_rad += mult * Math.PI/18.0;}
        */

        //Handle the ROTATE VIEW modes
        if (in>2 && od ==1 ) {
            if (type == :next) { the_rad += mult * Math.PI/18.0;}
            else { 
                ga_rad += mult * Math.PI/18.0;
                $.LORR_show_horizon_line = false; //we have to reset the horizon line here bec the view has been rotated
                //deBug("HI MOM2!", []);
            }
            $.speedWasChanged = true;
           
        }

            if ($.speeds_index<0)  {$.speeds_index=0; }
            $.show_intvl = 0;
            

            //WatchUi.requestUpdate();
        


    }
        

    

        //! Handle going to the next view
    //! @return true if handled, false otherwise
    public function onNextPage() as Boolean {
      handleNextPrevious (:next);   
      return true;
    }

    //! Handle going to the previous view
    //! @return true if handled, false otherwise
    public function onPreviousPage() as Boolean {
        //_view.previousSensor();
        //System.println("onPrevPage..." );
        handleNextPrevious (:previous);
        /*
        $.buttonPresses++;
        $.speedWasChanged = true;
        $.timeWasAdded=true;
        if (buttonPresses == 1) {return;} //1st buttonpress just gets out of intro titles

        var in = $.view_modes[$.view_mode];
        var od = $.Options_Dict[thetaOption_enum]/


        if ( in== 0) {
            $.time_add_hrs += speeds[speeds_index];
            $.timeWasAdded=true;
            //WatchUi.requestUpdate();
        } else if (in == 1 || in ==2 || (in > 2 && od ==0){
                speeds_index ++;
                if ($.view_modes[$.view_mode] == 2 || $.view_modes[$.view_mode] == 4  || $.view_modes[$.view_mode]==5) {
                if (speeds_index <47 && speeds_index >21) {speeds_index = 47;}

                }
                if (speeds_index>= speeds.size()) {speeds_index = speeds.size()-1;}
                $.show_intvl = 0;
                

            //WatchUi.requestUpdate();
        } else if (in>2 && od =1 ) { th +=5;}
        } else if (in>2 && od =2 ) { ga +=5;}

        //$.show_intvl = false;
        //$.time_add_hrs += _mainview.time_add_inc;
        //WatchUi.requestUpdate();
        /*
        if ($.time_add_hrs%24==0 && $.time_add_hrs!=0) {
            $.time_add_hrs +=24;
        } else {
            $.time_add_hrs +=1;
        } */

        return true;
        
    }

    function onTap(clickEvent) {
        System.println("Click1: " + clickEvent.getCoordinates()); // e.g. [36, 40]
        System.println("Click2: " + clickEvent.getType());        // CLICK_TYPE_TAP = 0
        $.timeWasAdded=true;
        return true;
    }

    
    function onKey(keyEvent) {
        var keyvent =  keyEvent.getKey();
        //System.println("GOT KEEY!!!!!!!!!: " + keyvent);         // e.g. KEY_MENU = 7

        if (keyvent == 7) {

            $.buttonPresses++;
            $.exiting_back_button_firstpress=false;
            $.change_mode_select_button_firstpress = false;
            settings_view = new $.SolarSystemSettingsView();
            settings_delegate = new $.SolarSystemSettingsDelegate();
        
            pushView(settings_view, settings_delegate, WatchUi.SLIDE_IMMEDIATE);


            return true;
        }
        return false;
        
        
    }
    
}

//picks up current mode from global $.view_mode
function changeModes(previousMode){
        //System.println("chmodes..." );
        
        $.timeWasAdded = true; //forces draw of screen in mode 0...
        $.animSinceModeChange = 0;
        $.show_intvl = 0; //used by showDate to decide when/how long to show (5 min) type labels
        $.LORR_orient_horizon = true; //tells large_orrery to orient the graph so earth's horizon is horizontal & meridian is UP in the viewpoint.  which we do only the first time LORR is run.
        $.LORR_show_horizon_line = true;
        //$.time_add_hrs = .5; //reset to present time //NOW Do this, or not, individually per MODE below
        $.Options_Dict[orrZoomOption_enum] = orrZoomOption_default;
        //var UUD = "Use Up/Down/";
        //var SS="Start/Stop";
        var UUD = "(Up/Down/";
        var SS="Start)";

        var changeModeOption_short = toArray(WatchUi.loadResource($.Rez.Strings.changeModeOption_short) as String,  "|", 0);

        switch($.view_mode){
           /* case (0):
                if (vsop_cache == null)  {vsop_cache = new VSOP87_cache();}
                $.countWhenMode0Started = $.animation_count;
                //time_add_inc = 0.25;
                //$.time_add_hrs = .5; //reset to present time
                if (previousMode == null || previousMode!=1 ) {  //mode 5 often moves years into the future...
                    $.time_add_hrs = 0; //reset to present time
                }
                speeds_index = 41;
                //speeds_index = screen0Move_index; //15 mins or whatever the person has set
                if ($.Options_Dict[helpBanners_enum]){solarSystemView_class.sendMessage(5, ["Manual Mode", "Use Up/Down", "", null]);}
                break;*/
            case (0):    
                $.view_mode = 1;
            case (1):
                if (vsop_cache == null)  {vsop_cache = new VSOP87_cache();}
                //time_add_inc=1;
                //DON'T reset to present time here bec. we're usually coming from mode 0 or mode 2& can just continue seamlessly
                //$.time_add_hrs = .5; //reset to present time
                if (previousMode == null || (previousMode!=1 && previousMode !=2 ) ) {  //mode 5 often moves years into the future...
                    $.time_add_hrs = 0; //reset to present time
                }
                speeds_index = 39; //10 mins
                started = false;
                if ($.Options_Dict[helpBanners_enum]){solarSystemView_class.sendMessage(5, ["==Current Sky (by hr)==", UUD, SS, null]);} 
                else {
                    solarSystemView_class.sendMessage(2, [null, changeModeOption_short[1],"", null, null]);
                }
                break;
            case(2):
                if (vsop_cache == null)  {vsop_cache = new VSOP87_cache();}
                //time_add_inc = 24*3; //1 day
                //DON'T reset to present time here bec. we're usually coming from mode 0 or mode 2& can just continue seamlessly
                if (previousMode != null && previousMode==3 ) {  //mode 3 often moves years into the future...
                    $.time_add_hrs = 0; //reset to present time
                }
                speeds_index = 48; //1 day or 24 hrs
                started = false;
                if ($.Options_Dict[helpBanners_enum]){solarSystemView_class.sendMessage(5, ["==Current Sky (by day)==", UUD, SS,null]);}
                else {
                    solarSystemView_class.sendMessage(2, [null, changeModeOption_short[2], "", null]);
                }
                break;                
            case(3):
                vsop_cache = null;
                //time_add_inc = 24*3; //1 day
                $.time_add_hrs = 0; //reset to present time
                $.newModeOrZoom = true; //gives signal to reset the dots
                //speeds_index = 41; //1 day OLD/too slow on real watch
                speeds_index = 53; //3 day
                if ($.Options_Dict[helpBanners_enum]){solarSystemView_class.sendMessage(3, ["==Inner Solar==", "==System-Top View==", UUD, SS]);}
                else {
                    solarSystemView_class.sendMessage(2, [null, changeModeOption_short[3],"", null, null]);
                }
                /* sunrise_events = sunrise_cache.fetch($.now_info.year, $.now_info.month, $.now_info.day, $.now.timeZoneOffset/3600, $.now.dst, time_add_hrs, lastLoc[0], lastLoc[1]);
                sunrise_events[:NOON][0] + noon_adj_hrs */

                ga_rad = 0 ; //rotation around the disk; viewpoint
                the_rad = Math.PI; //angles above the disk; altitude. radians.  0,0 is flat from the top.
                $.Options_Dict[thetaOption_enum] = 0;
                started = false;
                break;
            case(4):
                vsop_cache = null;
                //time_add_inc = 24*3; //1 day
                $.time_add_hrs = 0; //reset to present time
                $.newModeOrZoom = true; //gives signal to reset the dots
                //speeds_index = 41; //1 day OLD/too slow on real watch
                speeds_index = 54; //3 day
                if ($.Options_Dict[helpBanners_enum]){solarSystemView_class.sendMessage(3, ["==Inner Solar==", "==System-Side View==", UUD, SS]);}
                else {
                    solarSystemView_class.sendMessage(2, [null, changeModeOption_short[4],"", null, null]);
                }
                //ga_rad = 3.1415 ; //rotation around the disk; viewpoint
                //the_rad = 4.59; //angles above the disk; altitude. radians.  0,0 is flat from the top.

                ga_rad = 0; //rotation around the disk; viewpoint
                the_rad = -1.75; //angles above the disk; altitude. radians.  0,0 is flat from the top.
                $.Options_Dict[thetaOption_enum] = 1;
                started = false;
                break;                
            case(5):
                vsop_cache = null;
                //time_add_inc = 24*15; //14 days
                $.time_add_hrs = 0; //reset to present time
                $.newModeOrZoom = true; //gives signal to reset the dots
                //speeds_index = 46; //15 days = OLD , too slow on real watch
                speeds_index = 63; //300 days
                if ($.Options_Dict[helpBanners_enum]){solarSystemView_class.sendMessage(3, ["==Outer Solar==", "==System-Top View==", UUD, SS]);}
                else {
                    solarSystemView_class.sendMessage(2, [null, changeModeOption_short[5],"", null, null]);
                }
                ga_rad = 0 ; //rotation around the disk; viewpoint
                the_rad = Math.PI; //angles above the disk; altitude. 
                $.Options_Dict[thetaOption_enum] = 0;
                started = false;
                break;
            case(6):
                vsop_cache = null;
                //time_add_inc = 24*15; //14 days
                $.time_add_hrs = 0; //reset to present time
                $.newModeOrZoom = true; //gives signal to reset the dots
                //speeds_index = 46; //15 days = OLD , too slow on real watch
                speeds_index = 65; //400 days 
                if ($.Options_Dict[helpBanners_enum]){solarSystemView_class.sendMessage(3, ["==Outer Solar==", "==System-Side View==", UUD, SS]);}
                else {
                    solarSystemView_class.sendMessage(2, [null, changeModeOption_short[6],"", null, null]);
                }
                //ga_rad = 4.1872 ; //rotation around the disk; viewpoint //8632 - ga th: 0.523599 -1.517060
                //the_rad = -1.517; //angles above the disk; altitude. 
                
                ga_rad = 0; //rotation around the disk; viewpoint
                the_rad = -1.75; //angles above the disk; altitude. radians.  0,0 is flat from the top.

                $.Options_Dict[thetaOption_enum] = 1;
                started = false;
                break;
                            
            
            case(7):
                vsop_cache = null;
                //time_add_inc = 24*15; //90 days
                $.time_add_hrs = 0; //reset to present time
                $.newModeOrZoom = true; //gives signal to reset the dots
                //speeds_index = 48; //61 days, too slow on real watch
                speeds_index = 69; //4 yrs
                if ($.Options_Dict[helpBanners_enum]){solarSystemView_class.sendMessage(3, ["==Far Outer==", "==Solar System-Top==",UUD, SS]);}
                else {
                    solarSystemView_class.sendMessage(2, [null, changeModeOption_short[7],"", null, null]);
                }
                ga_rad = 0 ; //rotation around the disk; viewpoint
                the_rad = Math.PI; //angles above the disk; altitude. 
                $.Options_Dict[thetaOption_enum] = 0;
                started = false;
                break;
            
            case(8):
                vsop_cache = null;
                //time_add_inc = 24*15; //90 days
                $.time_add_hrs = 0; //reset to present time
                $.newModeOrZoom = true; //gives signal to reset the dots
                //speeds_index = 48; //61 days, too slow on real watch
                speeds_index = 69; //4 years
                if ($.Options_Dict[helpBanners_enum]){solarSystemView_class.sendMessage(3, ["==Far Outer==", "==Solar System-Side==",UUD, SS]);}
                else {
                    solarSystemView_class.sendMessage(2, [null, changeModeOption_short[8],"", null, null]);
                }
                //0.372665 -1.417994 ga th , good
                //ga th: 0.896264 -1.417994 better
                //ga_rad = 4.036264 ; //rotation around the disk; viewpoint
                //the_rad = -1.417994; //angles above the disk; altitude. 

                ga_rad = 0; //rotation around the disk; viewpoint
                the_rad = -1.75; //angles above the disk; altitude. radians.  0,0 is flat from the top.

                $.Options_Dict[thetaOption_enum] = 1;
                started = false;
                break;                
            default:
              speeds_index = 41; //2 mins


        }

        changeModeOption_short = null;
        

}