
import Toybox.Lang;
import Toybox.WatchUi;

//! Handle input on initial view
class SolarSystemBaseDelegate extends WatchUi.BehaviorDelegate {
    private var _mainview;
    //! Constructor
    public function initialize(view) {
        BehaviorDelegate.initialize();
        _mainview = view;
    }

    //! Handle the select button
    //! @return true if handled, false otherwise
    public function onSelect() as Boolean {
        _mainview.show_intvl = true;
        page +=1;
        if (page > pages_total -1) {
            page = pages_total-1;
            return false;
        }
        var view = _mainview;
        var delegate = new $.SolarSystemBaseDelegate(view);
        
        pushView(view, delegate, WatchUi.SLIDE_LEFT);
        return true;
    }

        //! Handle the select button
    //! @return true if handled, false otherwise
    public function onBack() as Boolean {

        _mainview.show_intvl = true;
        page -=1;
        if (page < 0) {
            page = 0;
            return false;
        }
        //var view = _mainview;
        //var delegate = new $.SolarSystemBaseDelegate(view);
        
        popView(WatchUi.SLIDE_RIGHT);//(view, delegate, WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

        //! Handle going to the next view
    //! @return true if handled, false otherwise
    public function onNextPage() as Boolean {
        //_view.nextSensor();
        WatchUi.requestUpdate();
        
        /*
        if (_mainview.time_add_hrs%24==0 && _mainview.time_add_hrs!=0) {
            _mainview.time_add_hrs -=24;
        } else {
            _mainview.time_add_hrs -=1;
        }
        */
        _mainview.show_intvl = false;
        _mainview.time_add_hrs -= _mainview.time_add_inc;

        return true;
    }

    //! Handle going to the previous view
    //! @return true if handled, false otherwise
    public function onPreviousPage() as Boolean {
        //_view.previousSensor();
        WatchUi.requestUpdate();
        /*
        if (_mainview.time_add_hrs%24==0 && _mainview.time_add_hrs!=0) {
            _mainview.time_add_hrs +=24;
        } else {
            _mainview.time_add_hrs +=1;
        } */
        _mainview.show_intvl = false;
        _mainview.time_add_hrs += _mainview.time_add_inc;
        return true;
    }
}