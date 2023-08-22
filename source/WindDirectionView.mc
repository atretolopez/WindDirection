import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.Weather;
import Toybox.Math;
import Toybox.Position;

class WindDirectionView extends WatchUi.SimpleDataField {
    private const _degreesPerHour = 360 / 12;
    private var _relativeWindAngle = 0.0;

    function initialize() {
        SimpleDataField.initialize();
        label = "Relative Wind Direction";
    }

    function toClockDirection(angle as Lang.Float) as Lang.Number {
        var direction = (Math.round(angle / _degreesPerHour).toNumber());
        if (direction < 0) {
            direction += 12;
        }

        return direction;
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
            var currentHeading = info.currentHeading;

            var currConditions = Weather.getCurrentConditions();
            if (currConditions.windBearing == null) {
                break;
            }

            var relativeWindDirection = currConditions.windBearing - currentHeading;
            while (relativeWindDirection >= Math.PI) {
                relativeWindDirection -= 2 * Math.PI;
            }

            while (relativeWindDirection < (-Math.PI)) {
                relativeWindDirection += 2 * Math.PI;
            }

            _relativeWindAngle = Math.toDegrees(relativeWindDirection);
        } while(false);

        return toClockDirection(_relativeWindAngle);
    }
}
