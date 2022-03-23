# My Vario (Garmin ConnectIQ) App
===============================
### A Variometer and tracker application for Garmin ConnectIQ devices


## Overview

This free and open-source application provides Variometer functions adapted
to free flight activities. It is based on the excellent open-source Garmin IQ
GliderSK application by Cedric Dufour (licensed under GPL v3.0, just like My
Vario is), dropping a lot of features for a simpler/leaner experience, while
adding many improvements for free flight activities.

My Vario is a BACKUP source of information and should ALWAYS be paired with
specialized variometer equipment! Watch sensors are simply not precise enough
and THIS APP SHOULD NOT BE USED AS A PRIMARY FLIGHT INSTRUMENT!

1. Dashboards

Multiple views/dashboards are available.

- a Global view, displaying all flight data in a single pane: altitude, ground
and vertical speeds, finesse, heading, wind direction and speed estimate, if
available (wind direction and speed are computed on the fly based on groundspeeds
when circling)

- a Variometer view, where the vertical speed can be visually seen

- a Varioplot/thermal assistant view, allowing to keep track of your ascent/descent
rate along your flight path

- a Log view, allowing to keep track of your last activities (unavailable during
flight) including flight start and end times, maximum and minimum altitudes, etc.

An option to auto-switch to and from the varioplot/thermal assistant view automa-
tically (based on circling auto-detection) is available.

2. Tone and vibration curves

The application makes use of the watch beeps and vibrations (if available).

- Variable-frequency tones to "sound" your ascent rate, as well as vibration-based
"tones" to fly in silence. These tones follow closely some popular variometer tone
curves (sound frequency/pitch, tone to tone or vibration to vibration pause time,
tone/vibration length - all depending on vertical speed)

- a minimum climb rate setting is available, under which sounds or vibrations won't
be triggered

- a sink rate threshold setting is available, for warning of strong sink via a long,
low frequency tone

3. Under the hood

- The application uses a Kalman filter for fast and accurate filtering of altitude
and vertical speed (compared to the SMA filter used by GliderSK originally)

- The smoothing (and latency) applied by the Kalman filter can be changed in the settings

- The default settings are optimized for a comfortable experience out of the box

USAGE:

You really, really want to go through the Manual before first use, and test the
application at home! See below USAGE manual.

https://github.com/ydutertre/myvario/blob/main/USAGE


## Usage

Please refer to the USAGE file.

## Supported watches

I have reduced the number of watches supported compared to GliderSK (removed
descent mk1 and charlie d2). This is because I am using variable frequency
tones for the vario, which are only supported for SDK 3.1.0 and above. I am
testing this application on my Garmin Fenix 7X.

## Not a programmer

I am not a programmer nor developer besides some small experience
contributing to N.I.N.A., an open-source astrophotography software suite.
Monkey C, Github, Garming SDK, etc are all new to me. I am a mere tinkerer
playing with and monkeying Cedric's work. It's likely I have introduced
errors, bugs, or code that could be extremely painful to the eyes of
experienced developers. I apologize for the pain caused!
You have been warned!

