
# My Vario (Garmin ConnectIQ) App

# Usage instructions

![icon](./resources/drawables/launcher-60x60.png)

**!!! WARNING !!! DISCLAIMER !!! WARNING !!! DISCLAIMER !!! WARNING !!!**

**THIS APPLICATION IS NOT TO BE USED AS A MEAN TO INSURE FLIGHT SAFETY.**

Always follow official or recommended procedures to insure flight safety,
        *independently* from the help this application can offer.

In particular, this application relies on barometric pressure to derive
the altitude and **MUST NOT BE USED IN A PRESSURIZED AIRCRAFT**.

> **WARNING**: This app is intended only as an in-flight aid and should not be
used as a primary information source. This app contains a barometric
altimeter, it will not function in a pressurized aircraft and should
not be used in a pressurized aircraft.”

**!!! WARNING !!! DISCLAIMER !!! WARNING !!! DISCLAIMER !!! WARNING !!!**


## Navigation

* [Foreword](#foreword)
* [Getting started](#getting-started)
  - [Calibrating your watch](#calibrating-your-watch)
  - [Navigating the interface](#navigating-the-interface)
  - [Livetracking](#livetracking)
  - [Activelook](#activelook)
* [Views](#views)
  - [General View](#general-view)
  - [Variometer View](#variometer-view)
  - [Varioplot / Thermal Assistant View](#varioplot--thermal-assistant-view)
  - [Log View](#log-view)
  - [Map View](#map-view)
* [Activity Recording](#activity-recording)
* [Settings](#settings)
  - [Altimeter](#altimeter)
  - [Variometer](#variometer)
  - [Sounds](#sounds)
  - [Activity](#activity)
  - [General](#general)
  - [Units](#units)
  - [Livetrack](#livetrack)
* [Live Tracking](#live-tracking)
  - [SportsTrackLive](#sportstracklive)
  - [Livetrack24](#livetrack24)
  - [FlySafe](#flysafe)

* [About Data Filtering](#about-data-filtering)
* [About Thermal Detection](#about-thermal-detection)
* [About touchscreen models (no 5 button control)](#about-touchscreen-models-no-5-button-control)

## Foreword

My Vario relies on your device's raw barometric sensor to compute the altitude,
using the ad-hoc International Civil Aviation Organization (ICAO) formulas and
according to the International Standard Atmosphere (ISA).

Upon startup, the application will read the watch altitude (if available) and
calibrate its barometer based on that. If the watch altitude was correct, then
everything is fine, and no further calibration is needed.

If, however you are unsure that your watch altitude is correct, or you know the
exact altitude of takeoff better than the watch does, you should calibrate My
Vario internal altimeter - using either the known QNH or elevation (see [Settings](#calibrating-the-device-sensor)) - to obtain an accurate altitude reading (besides the initial automated
calibration, the device's "native" altimeter/barometer settings are ignored).

My Vario is based on the excellent [GliderSK](https://github.com/cedric-dufour/connectiq-app-glidersk) by Cedric Dufour. If you like this
application, you should consider donating to him (see [DONATE](./DONATE) file or below).

http://cedric.dufour.name/software/donate.html

A lot of this USAGE text is also verbatim from Cedric's manual.

## Getting Started

### Calibrating your watch

Upon launch, the application automatically calibrates its raw pressure reading
to match the altitude detected by the watch. As such, if your watch supports maps,
it is a good idea to do a DEM Calibration at takeoff, prior to launching the app.
This is done outside of the app in the watch `Settings` -> `Sensors and Accessories`
-> `Altimeter` -> `Calibrate` -> `Use DEM`.

Otherwise, you will need to manually calibrate the altitude after launching My Vario,
as detailed in the Settings section.

After launching the app, if you're confused that the app is not displaying any
data, don't fret! You just need to get a GPS fix :) Go to a window or go outside,
and all will become clear.

### Navigating the interface

Next is navigation. The app is geared towards watches that can be used without
a touch interface, such as Forerunner or Fenix series, although as of 2.20, best
effort support of touchscreen only models has been added (see relevant section
[About touchscreen models](#about-touchscreen-models-no-5-button-control)).

Up button (middle left) and Down button (bottom left) can be used to go from one
view to another. Swiping up and down on a touchscreen also does the trick.

Long pressing the Up button will bring up the menu (except in the Varioplot view!
See the rest of this doc to learn more). You can navigate the menu and its various
settings with the Up, Down, Select (top right button) and Back (bottom right)
buttons. Swipes and taps also work. Check the [settings](#settings) and set them to what you like!

When changing settings, make sure to use the Select button to validate the change.
Pressing the back button doesn't save the setting.

With numerical settings, you are asked to set one digit at a time - going once through
all the digits without modiying anything makes it easier to understand the amplitude
of the numerical setting.

The Select button can be used to start and stop the activity recording, and Back can
be used to exit the app, except during recording or in the log view.
If in log view, you want to exit the log view using UP/DOWN buttons first before you
can close the app using the back button. If the activity is recording, you want to
stop the activity first and then exit the app.

### Livetracking

To enable Livetrack24, SportsTrackLive or FlySafe tracking, you need to set your username,
password, and equipment name within the settings page of the My Vario app in the
Garmin Connect IQ application. In addition you can change the frequency of the
livetracking updates in the My Vario app settings. For more details check the [relevant section](#live-tracking) below (there are some differences between [SportsTrackLive](#sportstracklive), [LiveTrack24](#livetrack24) and [FlySafe](#flysafe))

For automatic activity syncing with Strava, we need to pretend the activity was not
a flying activity but a hiking activity. This setting can be done within the `Settings`
-> `Activity` -> `Type` menu.

### Activelook

To enable ActiveLook smart glasses integration, turn the relevant setting on. You then
need to restart the app for the setting to become effective - on app start, the app
will search for and connect to any nearby ActiveLook glasses waiting for connection.

### VectorVario

Instead of using the watch internal sensors, you can choose to use a Vector Vario variometer data as well as wind (speed and direction).
To do so, enable the setting under General, and restart the app. On app start, the app
will search for and connect to any nearby VectorVario waiting for connection.


## Views

My Vario offers multiple different views which can be navigated using UP/DOWN buttons or swiping up or down on touchscreen devices.

### General View

The My Vario General view displays all the flight data in a single view, without
any further bells or whistles:
 - `Top-Left`:
   estimated wind direction (when available)
 - `Top-Right`:
   estimated wind speed (when available)
 - `Left`:
   your current altitude
 - `Center`:
   your current finesse
 - `Right`:
   your current (GPS) heading
 - `Bottom-Left`:
   your current vertical speed
 - `Bottom-Right`:
   your current ground speed

### Variometer View

The My Vario Variometer displays your current ascent/descent rate both textu-
ally and graphically, using visually appealing colors:
 - `GREEN` for ascent
 - `RED` for descent


### Varioplot / Thermal Assistant View

The My Vario Varioplot / Thermal Assistant graphically displays you ascent/descent
rate along your flight path, using visually appealing colors ranging from:
 - (Bright) `GREEN` for maximum ascent rate
 - (Bright) `RED` for maximum descent rate

Unless configured otherwise, the screen will automatically switch to this view
when circling is detected, and switch back to previous view once circling is no
longer detected.

In addition, the following values will be displayed in the corner of the plot:
 - `Top-Left`:
   your current altitude. The color of this number indicates how much altitude
   has been gained (or lost) within the last 20 seconds: green for gains, red
   for loss, grey for (relatively) unchanged. This can be very useful in weak
   thermals. If circling is detected, it will show current circling duration
   and height gain (or loss).
 - `Top-Right`:
   your current vertical speed
 - `Bottom-Left`:
   your current ground speed and plot scale
 - `Bottom-Right`:
   your current finesse
 - `Left-Center`:
   current wind orientation and speed (if available)
 - `Top-Center`:
   North pointed (if Heading Up is enabled)

If turned on, the current thermal detected core will be displayed as a blue circle.
See "[About Thermal Detection](#about-thermal-detection)" for more details.

Varioplot can be in configured in settings to be show as north up or heading up.

By pressing the MENU button (long-pressing the UP button), you will enter the
Pan/Zoom mode, where short pressing the following buttons will result in:
 - `SELECT`: switch between zoom in/out, pan up/down, pan left/right
 - `UP`:     zoom in  /OR/ pan up   /OR/ pan left
 - `DOWN`:   zoom out /OR/ pan down /OR/ pan right

By pressing the MENU button (long-pressing the UP button) a second time, you
will enter the Settings menu (see [Settings](#settings) below).

### Log View

My Vario Log view keeps track of your last recorded activities (global session
details; see [Activity Recording](#activity-recording) below).

Use the SELECT and BACK buttons to browse through the last 100 saved entries.

The Log view is not available in flight (while recording)

### Map View

A Map view is available on devices that support Maps, such as Fenix 7/8,
Forerunner 965/955, or Enduro 2/3.
The Map View includes a track, but the track itself is updated every 10
seconds only to preserve memory and device performance.


## Activity Recording

Controlling your activity recording status (start, pause, resume, save, discard)
is achieved by pressing the SELECT button.

My Vario adds custom fields to the recorded FIT file:
 - Barometric Altitude
 - Vertical Speed
(which will be plotted in Garmin Connect IF your installed the application
 through the Garmin ConnectIQ store)

For the entire recording session, Garmin Connect will also show the following details:
 - `Distance`: non-thermalling distance
 - `Ascent`: cumulative altitude gain and elapsed time spent ascending
 - `Minimum Altitude`: value and time
 - `Maximum Altitude`: value and time


**!!!! ABOUT ALTITUDE RECORDING !!!!**

> Note that Garmin doesn't allow applications to overwrite default FIT fields, and as such
there will be two Altitude fields in the generated activity log: the Garmin "*official*"
altitude, and our (better) barometric altitude field. By default, Garmin watches
attribute pressure changes to either weather or altitude changes. This can cause the
official altitude field to be wildly incorrect compared to our barometric altitude field.

If exporting your log to gpx format and uploading to Ayvri, the Garmin altitude field will
be used (unfortunately), and this can lead to some funky issues. It is thus better to set
the altimeter to Altimeter only in the watch settings before using the application.

This can be done in `Settings` -> `Sensors & Accessories` -> `Altimeter` -> `Sensor Mode` ->
`Altimeter Only`.

## Settings

> Note: Unless explicitely stated otherwise for a given view, you may enter the Settings
menu by pressing the MENU button (long-pressing the UP button).

The application allows you to specify the following settings:

### Altimeter
- Calibration
  - `QNH`:
    calibrate the altimeter using the current known QNH
  - `Elevation`:
    calibrate the altimeter using the current known elevation
    (QNH shall be adjusted accordingly)

### Variometer
- `Range`:
  the range used for the variometer display (3.0, 6.0 or 9.0 m/s) and varioplot
  color range
- `Auto Thermal`:
  whether the app will switch to Varioplot view automatically when circling is
  detected, and switch back once circling is no longer detected
- `Thermal Detect`
  whether the app will try to detect and map a thermal in the Varioplot view
  see "[About thermal detection](#about-thermal-detection)" for more information
- `Smoothing`:
  the amount of smoothing to apply to the variometer reading (determines the standard
  deviation of altitude applied to the Kalman Filter: 0.2, 0.5, 0.7, or 1.0)
- `Plot Range`:
  the time range (in minutes) for plotting the variometer-vs-location history
- `Plot Orientation`:
  the orientation of the plot, either "North up" (default) or "Heading up"
- `Plot Zoom`:
  the zoom level of the plot, in meters per pixel
  
### Sounds
- `Variometer Tones`:
  whether to play variometer tones
- `Vario Vibrations`:
  whether to use variometer vibrations
- `Tone Driver`
  Setting this to `Buzzer` will use custom frequency curves played with a buzzer for variometer tones,
  but some devices do not have a buzzer and can only play system sounds, for this use `Speaker` driver.
  This will try to *poorly* emulate vario sounds using system sounds and the speaker. Only use this setting
  if buzzer does not work. 
- `Minimum Climb`:
  the minimum vertical speed required to play variometer tones and/or
  vibrations
- `Minimum Sink`:
  the minimum sink speed required to play variometer sink tone (no vibration)
  the tone will be triggered once, each time the sink is escaped and then entered again

### Activity
- `Auto Start`
  whether to automatically start the activity recording
  throughout the flight (takeoff)
- `Start Speed`
  speed above which the activity automatically starts/resumes
  (must be greater than the Stop Speed; ignored if set to zero)
- `Type`
  lets you set whether the Activity will be recorded as a Flight activity, as a Hike
  activity, or as a Hang Glider activity. To allow sync in Strava, you should set it as a Hike Activity.
  If you set the activity to "Flight", the "Last Activity" glance from Garmin may crash your watch.
  This is a Garmin-side bug. As such, it is recommended to avoid the "Flight" setting.

### General
- `Background Color`:
  the background color (black or white)
- `ActiveLook`:
  Set to "On" to enable HUD via ActiveLook glasses such as Engo 2. This requires an app
  restart. Cannot be used together with VectorVario.
- `VectorVario`:
  Set to "On" to enable getting wind and vario data from Vector Vario. This requires an app
  restart. Cannot be used together with ActiveLook.
- `GPS Precision`:
  Select "Best" to use all Constellations available, "Normal" to limit to GPS (for energy efficiency)
- `Clear logs`:
  Delete logs (internal application flight logs only)

### Units
- `Distance`:
  preferred units for displaying distance (and horizontal speed) values
- `Elevation`:
  preferred units for displaying elevation (and vertical speed) values
- `Pressure`:
  preferred units for displaying pressure
- `Direction`:
  whether to show directions as an angle (247, 62, etc.) or as text (NW, SE, N, etc.)
- `Timezone`:
  display Local Time (LT) or Universal Time Coordinates (UTC/Z)
- `Wind speed`:
  show estimated wind speed as km/h, mph, knots or m/s

### Livetrack
- `LT24 Frequency`:
  The frequency (in seconds) at which My Vario will send a position update to Livetrack24. 
  The higher the frequency the smoother the track (one data point sent with each update).
  to the Livetrack24 server. Livetracking via Livetrack24 can also be disabled completely
  by setting this to Off.
- `STL Frequency` 
  The frequency (in seconds) at which My Vario will send a position update to SportsTrackLive. 
  The frequency doesn't impact the smoothness of the track as position data points taken
  once per second are sent in batch with each update. However, because updates can be lost in
  areas with poor connectivity, I recommend a setting of 15s (so only 15 seconds worth of data
  points are lost in case of update failure). Livetracking via SportsTrackLive can also be
  disabled completely by setting this to Off.
- `FS Frequency`
  The frequency (in seconds) at which My Vario will send a position update to FlySafe. 
  The higher the frequency the smoother the track (one data point sent with each update).
  to the FlySafe server. Livetracking via FlySafe can also be disabled completely
  by setting this to Off.

### Map View
These settings are only available if the device supports Maps.
- `Map Display`:
  Whether to display the map or not
- `Map Zoom` 
  The desired map zoom, in meters per pixel

## Live Tracking

The application currently supports three Live Tracking services: Livetrack24, SportsTrackLive and FlySafe.
They can be used at the same time for live tracking on all platforms simultaneously.

> This feature requires that the watch be paired to a phone via bluetooth, and it will rely on the 
phone's Internet connection to send its position packets to the live tracking servce. This is a
win-win for the batteries involved: flight data and GPS info is done on the watch, while
connectivity is done on the phone, helping save the battery of the phone in particular.

### SportsTrackLive

If you wish to use the SportsTrackLive integration, you will need to create an account at their
[website](https://www.sportstracklive.com/). Once done, you will need to go to the app settings
within the Connect IQ app to set your login email and password. You will then need to set an
update frequency within the settings of the My Vario app (default is off).

Once email, password and frequency are set, Livetracking with SportsLiveTrack will start as
soon as Activity Recording is started (either manually or via auto-start).

SportsTrackLive provides several advantages over Livetrack24:
- Modern, responsive interface
- Ayvri-like 3D visualization, both live and once flight is over
- More precise and more power efficient: while the Livetrack24 integration will only send one
GPS data point every x seconds (based on frequency setting), the SportsTrackLive integration
queues GPS points (one per second), and sends them to SportsTrackLive in batch every x seconds
(based on [frequency setting](#livetrack)). Thus, smooth tracks can be achieved with low update frequencies,
compared to Livetrack24, where high update frequency is required for smooth tracks.

### Livetrack24

If you wish to use Livetrack24 integration, you will need to create an account at their
[website](https://www.livetrack24.com/). Once done, you will need to go to the app settings
within the Connect IQ app to set your login, password, and equipment name (please don't use
spaces, so something like ADVivo or AdvanceXi). You will then need to set an update frequency
within the settings of the My Vario app (default is off).

Once email, password and frequency are set, Livetracking with Livetrack24 will start as
soon as Activity Recording is started (either manually or via auto-start).

Once started, live tracking will provide position updates to Livetrack24 every X seconds, X
being a number set in the My Vario settings on the watch (please see the [Settings](#livetrack) section).
The live tracking frequency will determine the smoothness of the track (for Livetrack24).

Live tracking will automatically stop once activity recording is stopped.


### FlySafe

If you wish to use FlySafe integration, some technical skill is required as your public user
id and token is not exposed and needs to be extracted from the website. To aquire said parameters
you need to log in to the [website](https://flysafe.pro) and copy them from your browsers local storage.
Easiest way to do this is by opening developer tools console and paste the following line in to the prompt:

```js
console.log('%c'+Object.entries(JSON.parse(localStorage.state).user.data).filter(k=>['uid','mtoken'].includes(k[0])).map(kv=>kv.join(': ')).join('\n'), "font-size: x-large")
```

> This command extracts localStorage.state.user.data.{uid, mtoken} parameters and prints them into the console

Copy the following values you see displayed in the console and go to the app settings within the Connect IQ app, set each of the the respective
parameters and save. You will then need to set an update frequency within the settings of the My Vario app (default is off).

Once UserID and Token are set, Livetracking with FlySafe will start as
soon as Activity Recording is started (either manually or via auto-start).

Once started, live tracking will provide position updates to FlySafe every X seconds, X
being a number set in the My Vario settings on the watch (please see the [Settings](#livetrack) section).
The live tracking frequency will determine the smoothness of the track (for FlySafe).

Live tracking will automatically stop once activity recording is stopped.

## About Data Filtering

My Vario uses a Kalman Filter for Altitude and Vertical Speed. The filter
was derived from implementations in the SkyDrop vario and Arduino Open Vario.

Other values are not filtered.

> The filter currently doesn't use data from the accelerometer.

In general, filtered values are used.

Smoothing relies on the standard deviation of the Altitude (which depends on the
barometric sensor). This can be changed via the Variometer Smoothing setting.
Higher values of smoothing induce more lag - however, this still seems to be to
provide better reactivity for the same amount of smoothing as the original
simple moving average of GliderSK.

Note that the Minimum Climb setting can be used to compensate for weaker smoothing,
if using My Vario as an audio/vibration variometer.

However, the Activity Recorded (FIT) data are always instantaneous rather than smoothed.

## About Thermal Detection

Thermal detection can be enabled in the settings menu, under Variometer. This feature
attempts to detect the thermal core and displays it on the Varioplot, including wind
correction.

The algorithm performs the following across the last 60 seconds of location and variometer data:
- It assigns a weight to each location. The stronger the climb at that location the higher
  the weight. However, it also decreases the weight the further that point is from the current
  altitude. The older the data point, the lower its weight as well.
- Locations with a climb rate of less than the Min. Climb setting are ignored
- It computes the weighted average of the coordinates and uses that as the thermal center
- It computes average altitude of thermal measurement as well as average thermal climb rate.
  Based on those and current altitude, if wind speed and direction are available, it computes
  a wind offset for the thermal and adds it to the thermal center computed in the previous step
- It computes at the same time the weighted standard deviation of the coordinates and uses
  that as the radius of the thermal
- It then draws the thermal as a circle in blue on the varioplot

> This feature is experimental, and could be completely useless. Use at your own risk.
If you have a better algo in mind, please let me know!!

## About touchscreen models (no 5 button control)

As of version 2.20, this application has been made to support some touchscreen
models. However, use of those models can be confusing, and the watches don't
provide alert tones, so there are no vario tones, only vibrations. However some approximation of vario tones can be made using system sounds (check [Settings](#settings) -> [Sounds](#sounds) -> `Sound Driver`). ([bug tracker](https://forums.garmin.com/developer/connect-iq/i/bug-reports/attention-playtone-not-fully-suported-on-venu-3)).
This guide still applies, however the controls are different
- The Back button is unchanged (bottom right) and can be used to change settings
- The UP and DOWN buttons (middle left and bottom left on 5 button watches) are
replaced by SWIPE UP and SWIPE DOWN gestures on the screen
- The START button (top right on 5 button watches) is replaced by a tap on the
screen, so can be used to validate settings changes, start/stop and activity, etc.

This can become particularly counterintuitive when changing zoom and pan in the
thermal assistant/varioplot view, but it works. Log view is a bit weird as well
since to scroll through the logs, the back button and tap on screen commands are
used, while swipe up/swipe down bring to the other watch screens.