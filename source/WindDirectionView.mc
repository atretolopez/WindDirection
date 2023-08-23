import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.Weather;
import Toybox.Math;
import Toybox.Position;

class WindDirectionView extends WatchUi.SimpleDataField {
    private const _degreesPerHour = 360 / 12;
    private var _relativeWindAngle as Lang.Number or Lang.String;

    function initialize() {
        SimpleDataField.initialize();
        label = "Rel Wind";
        _relativeWindAngle = "N/A";
    }

    function toClockDirection(angle as Lang.Number) as Lang.Number {
        return Math.round((angle / _degreesPerHour)).toNumber();
    }

    function getSeverityString(windSpeed as Lang.Float) as Lang.String {
        if (windSpeed < 2.77778) {
            return "'";
        } else if (windSpeed < 5.5) {
            return "''";
        } else {
            return "'''";
        }

    }

    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        do
        {
            if ((!(info has :currentLocationAccuracy) || info.currentLocationAccuracy == null) ||
                info.currentLocationAccuracy < Position.QUALITY_USABLE) {
                break;
            }

            if (!(info has :currentHeading) || info.currentHeading == null) {
                break;
            }
            var currentHeading = Math.toDegrees(info.currentHeading);

            var currConditions = Weather.getCurrentConditions();
            if (!(currConditions has :windBearing) || currConditions.windBearing == null) {
                break;
            }
            var windBearing = currConditions.windBearing;

            if (!(currConditions has :windSpeed) || currConditions.windSpeed == null) {
                break;
            }
            var windSpeed = currConditions.windSpeed;

            _relativeWindAngle = toClockDirection(Math.round(windBearing - currentHeading).toNumber() % 360).toString() + getSeverityString(windSpeed);
        } while(false);

        return _relativeWindAngle;
    }
}
