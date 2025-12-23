import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

class SwitchBotOutdoorMeterView extends WatchUi.SimpleDataField {
    var bleData = null;
    
    var min_temperature = null;
    var max_temperature = null;
    var min_humidity = null;
    var max_humidity = null;

    var temperatureField = null;
    var humidityField = null;
    var minTemperatureField = null;
    var maxTemperatureField = null;
    var minHumidityField = null;
    var maxHumidityField = null;

    const TEMPERATURE_FIELD_ID = 0;
    const HUMIDIRY_FIELD_ID = 1;
    const MIN_TEMPERATURE_FIELD_ID = 2;
    const MAX_TEMPERATURE_FIELD_ID = 3;
    const MIN_HUMIDIRY_FIELD_ID = 4;
    const MAX_HUMIDIRY_FIELD_ID = 5;

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = loadResource(Rez.Strings.temperature) + " " + loadResource(Rez.Strings.celsius);

        temperatureField = createField(
            "temperature",
            TEMPERATURE_FIELD_ID,
            FitContributor.DATA_TYPE_FLOAT,
            {
                :mesgType=>FitContributor.MESG_TYPE_RECORD,
                :units=>"C",
                :nativeNum=>13,
            }
        );
        minTemperatureField = createField(
            "min_temperature",
            MIN_TEMPERATURE_FIELD_ID,
            FitContributor.DATA_TYPE_FLOAT,
            {
                :mesgType=>FitContributor.MESG_TYPE_SESSION,
                :units=>"C",
                :nativeNum=>13,
            }
        );
        maxTemperatureField = createField(
            "max_temperature",
            MAX_TEMPERATURE_FIELD_ID,
            FitContributor.DATA_TYPE_FLOAT,
            {
                :mesgType=>FitContributor.MESG_TYPE_SESSION,
                :units=>"C",
                :nativeNum=>13,
            }
        );

        humidityField = createField(
            "humidity",
            HUMIDIRY_FIELD_ID,
            FitContributor.DATA_TYPE_UINT8,
            {
                :mesgType=>FitContributor.MESG_TYPE_RECORD,
                :units=>"%",
            }
        );
        minHumidityField = createField(
            "min_humidity",
            MIN_HUMIDIRY_FIELD_ID,
            FitContributor.DATA_TYPE_UINT8,
            {
                :mesgType=>FitContributor.MESG_TYPE_SESSION,
                :units=>"%",
            }
        );
        maxHumidityField = createField(
            "max_humidity",
            MAX_HUMIDIRY_FIELD_ID,
            FitContributor.DATA_TYPE_UINT8,
            {
                :mesgType=>FitContributor.MESG_TYPE_SESSION,
                :units=>"%",
            }
        );
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        // See Activity.Info in the documentation for available information.
        if (bleData.temperature != null) {
            temperatureField.setData(bleData.temperature);
            if (min_temperature == null || bleData.temperature < min_temperature) {
                min_temperature = bleData.temperature;
                minTemperatureField.setData(min_temperature);
            }
            if (max_temperature == null || bleData.temperature > max_temperature) {
                max_temperature = bleData.temperature;
                maxTemperatureField.setData(max_temperature);
            }
        }

        if (bleData.humidity != null) {
            humidityField.setData(bleData.humidity);
            if (min_humidity == null || bleData.humidity < min_humidity) {
                min_humidity = bleData.humidity;
                minHumidityField.setData(min_humidity);
            }
            if (max_humidity == null || bleData.humidity > max_humidity) {
                max_humidity = bleData.humidity;
                maxHumidityField.setData(max_humidity);
            }
        }

        if (bleData.temperature == null) {
            return "--.-";
        } else {
            return bleData.temperature.format("%.1f");
        }
    }

    function bind(data) as Void {
        bleData = data;
    }
}