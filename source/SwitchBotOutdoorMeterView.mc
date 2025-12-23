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
    var sum_temperature as Double = 0.0d;
    var count_temperature = 0;
    var sum_humidity as Long = 0l;
    var count_humidity = 0;

    var temperatureField = null;
    var humidityField = null;
    var minTemperatureField = null;
    var maxTemperatureField = null;
    var minHumidityField = null;
    var maxHumidityField = null;
    var averageTemperatureField = null;
    var averageHumidityField = null;

    const TEMPERATURE_FIELD_ID = 0;
    const HUMIDIRY_FIELD_ID = 1;
    const MIN_TEMPERATURE_FIELD_ID = 2;
    const MAX_TEMPERATURE_FIELD_ID = 3;
    const MIN_HUMIDIRY_FIELD_ID = 4;
    const MAX_HUMIDIRY_FIELD_ID = 5;
    const AVERAGE_TEMPERATURE_FIELD_ID = 6;
    const AVERAGE_HUMIDIRY_FIELD_ID = 7;

    const SENSOR_TIMEOUT = 60; // 60 seconds

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        if (Application.Properties.getValue("showBoth") as Lang.Boolean) {
            label = loadResource(Rez.Strings.environment);
        } else {
            label = loadResource(Rez.Strings.temperature) + " " + loadResource(Rez.Strings.celsius);
        }

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
        averageTemperatureField = createField(
            "average_temperature",
            AVERAGE_TEMPERATURE_FIELD_ID,
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
        averageHumidityField = createField(
            "average_humidity",
            AVERAGE_HUMIDIRY_FIELD_ID,
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
        if (bleData.updateMoment == null || (Time.now().value() - bleData.updateMoment.value()) >= SENSOR_TIMEOUT) {
            System.println("No recent data from sensor.");
            return "--.-";
        }

        // ---------- TEMPERATURE ----------
        if (bleData.temperature != null) {
            temperatureField.setData(bleData.temperature);

            // min / max temperature
            if (min_temperature == null || bleData.temperature < min_temperature) {
                min_temperature = bleData.temperature;
                minTemperatureField.setData(min_temperature);
            }
            if (max_temperature == null || bleData.temperature > max_temperature) {
                max_temperature = bleData.temperature;
                maxTemperatureField.setData(max_temperature);
            }

            // average temperature
            sum_temperature += bleData.temperature;
            count_temperature += 1;
            averageTemperatureField.setData(Math.round(sum_temperature / count_temperature * 10) / 10.0);
        }

        // ---------- HUMIDITY ----------
        if (bleData.humidity != null) {
            humidityField.setData(bleData.humidity);

            // min / max humidity
            if (min_humidity == null || bleData.humidity < min_humidity) {
                min_humidity = bleData.humidity;
                minHumidityField.setData(min_humidity);
            }
            if (max_humidity == null || bleData.humidity > max_humidity) {
                max_humidity = bleData.humidity;
                maxHumidityField.setData(max_humidity);
            }

            // average humidity
            sum_humidity += bleData.humidity;
            count_humidity += 1;
            averageHumidityField.setData(Math.round(sum_humidity / count_humidity));
        }

        if (Application.Properties.getValue("showBoth") as Lang.Boolean) {
            return bleData.temperature.format("%.1f") + "°C / " + bleData.humidity + "%";
        }
        return bleData.temperature.format("%.1f");
    }

    function bind(data) as Void {
        bleData = data;
    }
}