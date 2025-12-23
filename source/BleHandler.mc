import Toybox.Lang;

using Toybox.BluetoothLowEnergy as Ble;

class BleHandler extends Ble.BleDelegate {
    var temperature = null;
    var humidity = null;
    var updateMoment = null;

    function initialize() {
        BleDelegate.initialize();
    }

    function onScanResults(scanResults as Ble.Iterator) as Void {
        for (
            var res = scanResults.next() as Ble.ScanResult?;
            res != null;
            res = scanResults.next() as Ble.ScanResult?
        ) {
            var sensorMac = Application.Properties.getValue("macAddress") as Lang.String;
            // sensorMac = "D0:C8:42:46:32:1C";
            if (sensorMac != null && sensorMac.length() == 17) {
                System.println("Filtering for MAC: " + sensorMac);
                if (!res.hasAddress(sensorMac)) {
                    continue;
                }
            }

            // System.println("SwitchBot Meter gefunden: " + res.getRawData());
            var data = res.getManufacturerSpecificData(0x0969);
            if (data == null || data.size() != 12) {
                continue;
            }

            // process humidity
            humidity = data[10] & 0x7F;

            // process temperature
            var tempRaw = ((data[8] & 0x0F) * 0.1) + (data[9] & 0x7F);
            if ((data[9] & 0x80) > 0) {
                tempRaw *= 1;   // positive
            } else {
                tempRaw *= -1;  // negative
            }
            temperature = tempRaw;
            updateMoment = Time.now();

            // System.println("Temperatur: " + tempRaw + " °C");
            // System.println("Feuchtigkeit: " + humidity + "%");
        }
    }
}