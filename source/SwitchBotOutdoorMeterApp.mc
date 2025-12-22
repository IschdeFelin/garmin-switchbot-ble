import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

using Toybox.BluetoothLowEnergy as Ble;

class SwitchBotOutdoorMeterApp extends Application.AppBase {
    var bleHander = null;

    function initialize() {
        AppBase.initialize();
        bleHander = new BleHandler();
        Ble.setDelegate(bleHander);
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        System.println("Start scanning...");
        Ble.setScanState(Ble.SCAN_STATE_SCANNING);
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        Ble.setScanState(Ble.SCAN_STATE_OFF);
        System.println("Scanning stopped!");
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new SwitchBotOutdoorMeterView();
        view.bind(bleHander);
        return [ view ];
    }
}

function getApp() as SwitchBotOutdoorMeterApp {
    return Application.getApp() as SwitchBotOutdoorMeterApp;
}