# Delphi Honeywell Scanner Demo Using Intents

## General Overview

This repository demonstrates sending and receiving Android Intents to a Honeywell CT-40
barcode scanner. This version has been updated and tested on Android 9 but not yet tested
with previous versions of Android. (The previous commit of this project has been verified
to run on Android 8.1.0 and could be used if this version doesn't work.)

The method described can be easily adapted to enable intents to be sent to other
Android applications.

Prior to Android 8 (aka Oreo) it was possible to broadcast "implicit" intents to
communicate between applications. Kind of like "Here's a message, does anyone want to
handle it?". To send an "explicit" intent to another application requires a few extra
steps:

- Determine which applications can handle the type of intent you wish to send
- For each application that can handle the type of intent, create a new intent and send it specifically to that application.

Update: It appears that this logic may no longer be required for Android 9, and in fact
just doesn't work. Android documentation suggests that a package name is usually required
when sending intents. For claiming and releasing the Honeywell scanner, the name of the
package is 'com.intermec.datacollectionservice'. The code has been updated to reflect
this though the application worked without this on my scanner.

Originally, this project used a Java .jar file. Though no longer required, I've retained
the code in the Android directory for reference. There is also a README.md file
containing step-by-step instructions on how to compile a Java class into a .jar file and
include them in a Delphi application. (One day I'll move these into a seperate repository.)

## Honeywell Scanner

To receive scans from a Honeywell Android scanner there's a couple of requirements:

- The application must have the following permission in the manifest:

```xml
<uses-permission android:name="com.honeywell.decode.permission.DECODE" />
```

- Upon gaining focus, the application must send an intent claiming the scanner.
- Upon losing focus, the application must send an intent releasing the scanner.
- When a barcode is scanned, the details will be received as an intent.

## Delphi Project

- The project targets Delphi 10.3 Update 3 and is based on an existing application. It will compile with prior releases but will need changes to the deployment options.
- The project creates output files in C:\temp\HoneywellScanner\Android as my project files are located on a network share and FMX projects do not like this.
- To handle the receiving of intents, the project uses a component derived from https://github.com/barisatalay/delphi-android-broadcast-receiver-component
