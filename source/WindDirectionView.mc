import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Position;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.Weather;

class WindDirectionView extends WatchUi.DataField {
    private const _label = "Relative Wind";
    private const _points = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
    private const _lastLocationUpdateInterval   = new Time.Duration(5);
    private const _lastConditionUpdateInterval  = new Time.Duration(5);
    private var   _lastLocationTimeCache        = Time.now().subtract(_lastLocationUpdateInterval);
    private var   _lastConditionTimeCache       = Time.now().subtract(_lastConditionUpdateInterval);
    private var   _currentHeading               = 0.0;
    private var   _windBearing                  = 0.0;
    private var   _windSpeed                    = 0.0;
    private var   _relativeWindAngle            = 0;

    function initialize() {
        DataField.initialize();
    }

    public function onUpdate( dc as Dc) as Void {
        // Call parent"s onUpdate(dc) to redraw the layout
        DataField.onUpdate( dc );

        // Include anything that needs to be updated here
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.clear();

        // vars
        var width = dc.getWidth();
        var height = dc.getHeight();

        // label
        dc.setPenWidth(3);
        dc.drawText(width / 2, 12, Graphics.FONT_SMALL, _label, (Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER));

        // arrow
        var cCenterX = width / 2;
        var cCenterY = (height / 2) + 12;
        var cRadius = ((width < height) ? width / 2 : height / 2) - 14;

        dc.drawText(cCenterX + cRadius, cCenterY + cRadius - 10, Graphics.FONT_TINY, _windSpeed.format("%.1f").toString() + "mph", (Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER));
        dc.drawText(cCenterX - cRadius, cCenterY + cRadius - 10, Graphics.FONT_TINY, getHeadingCardinalPoint(), (Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER));

        // main line
        var cTailPointX = cCenterX + cRadius * Math.cos(Math.toRadians((_relativeWindAngle + 180) % 360));
        var cTailPointY = cCenterY + cRadius * Math.sin(Math.toRadians((_relativeWindAngle + 180) % 360));
        var cHeadPointX = cCenterX + cRadius * Math.cos(Math.toRadians(_relativeWindAngle));
        var cHeadPointY = cCenterY + cRadius * Math.sin(Math.toRadians(_relativeWindAngle));
        dc.drawLine(cTailPointX, cTailPointY, cHeadPointX, cHeadPointY);

        var aPointX = cHeadPointX + 12 * Math.cos(Math.toRadians(_relativeWindAngle + 135));
        var aPointY = cHeadPointY + 12 * Math.sin(Math.toRadians(_relativeWindAngle + 135));
        dc.drawLine(cHeadPointX, cHeadPointY, aPointX, aPointY);

        aPointX = cHeadPointX + 12 * Math.cos(Math.toRadians(_relativeWindAngle + 225));
        aPointY = cHeadPointY + 12 * Math.sin(Math.toRadians(_relativeWindAngle + 225));
        dc.drawLine(cHeadPointX, cHeadPointY, aPointX, aPointY);

    }

    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        if(updateLocation(info) && updateConditions(info)) {
            _relativeWindAngle = Math.round(_windBearing - _currentHeading).toNumber() % 360;
        }
        return null;
    }


    function updateLocation(info as Activity.Info) as Boolean {
        var now = Time.now();
        if (_lastLocationTimeCache.add(_lastLocationUpdateInterval).greaterThan(now)) {
            return true;
        }

        if ((!(info has :currentLocationAccuracy) || info.currentLocationAccuracy == null) ||
            info.currentLocationAccuracy < Position.QUALITY_USABLE) {
            return false;
        }

        if (!(info has :currentHeading) || info.currentHeading == null) {
            return false;
        }

        _lastLocationTimeCache = now;
        _currentHeading        = Math.toDegrees(info.currentHeading);
        return true;
    }

    function updateConditions(info as Activity.Info) as Boolean {
        var now = Time.now();
        if (_lastConditionTimeCache.add(_lastConditionUpdateInterval).greaterThan(now)) {
            return true;
        }

        var currConditions = Weather.getCurrentConditions();
        if (!(currConditions has :windBearing) || currConditions.windBearing == null) {
            return false;
        }

        if (!(currConditions has :windSpeed) || currConditions.windSpeed == null) {
            return false;
        }

        if (!(currConditions has :windSpeed) || currConditions.windSpeed == null) {
            return false;
        }

        _lastConditionTimeCache = now;
        _windBearing            = currConditions.windBearing;
        _windSpeed              = currConditions.windSpeed;
        return true;
    }

    function getHeadingCardinalPoint() as Lang.String {
        var heading = Math.round(_currentHeading).toNumber() % 360;
        if (heading < 0) {
            heading += 360;
        }
        return _points[Math.round((heading / 45)).toNumber() % 8];
    }
}
