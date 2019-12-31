# Delphi Honeywell Scanner Demo Using Intents
## General Overview
This repository demonstrates using a small Java class to send Android Intents to a Honeywell CT-40 barcode scanner running Android 8.1.0. However, the method described can be easily adapted to enable intents to be sent to other Android applications. 

This read-me file also contains step-by-step instructions on how to compile a Java class into a .jar file and include them in a Delphi application.

Prior to Android 8 (aka Oreo) it was possible to broadcast "implicit" intents to communicate between applications. Kind of like "Here's a message,
does anyone want to handle it?". To send an "explicit" intent to another application requires a few extra steps:

* Determine which applications can handle the type of intent you wish to send
* For each application that can handle the type of intent, create a new intent and send it specifically to that application.

Footnote: A pure Delphi implementation of this can be found at https://gist.github.com/DelphiWorlds/8eaa900ea9df70df902bee2123a64c6d?fbclid=IwAR0CwsAFIFvXA0TGSVUIMifXv1qWZEK4WZieeSuSXVyTHWBnCInOzwa6DdY

## Honeywell Scanner
To receive scans from a Honeywell Android scanner there's a couple of requirements:
* The application must have the following permission in the manifest:
```xml
<uses-permission android:name="com.honeywell.decode.permission.DECODE" />
```
* Upon gaining focus, the application must send an intent claiming the scanner.
* Upon losing focus, the application must send an intent releasing the scanner.
* When a barcode is scanned, the details will be received as an intent.

## Delphi Project
* The project targets Delphi 10.3 Update 3 and is based on an existing application. It will compile with prior releases but will need changes to the deployment options.
* The project creates output files in C:\temp\HoneywellScanner\Android as my project files are located on a network share and FMX projects do not like this.
* To handle the receiving of intents, the project uses a component derived from https://github.com/barisatalay/delphi-android-broadcast-receiver-component (There have been no updates to this repository since (October 2014)

## Creating The Android .Jar File
The Delphi project repository contains the .compiled jar file and Delphi/Java bridge unit, Android.JNI.DelphiIntents.pas. These can be added "as is" to any Delphi project needing to send intents on Oreo or above. The following describes the steps I took to generate these. (Not being a Java programmer, there may be a more efficient way of achieving this.)

The first step is to create the Java code and compile into a .jar file. I created an Android Studio project to which I added a module and the following class (based on sample code provided by Honeywell):
```Java
package au.com.corbtech.delphiintents;

import android.content.ComponentName;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import java.util.List;

public class SendIntent {
    public static void appSendBroadcast(Context context, Intent intent){

        int sdkVersion = android.os.Build.VERSION.SDK_INT;

        if(sdkVersion<26) {
            context.sendBroadcast(intent);
        } else {
            PackageManager packageManager=context.getPackageManager();
            List<ResolveInfo> matches=packageManager.queryBroadcastReceivers(intent, 0);

            for (ResolveInfo resolveInfo : matches) {
                Intent explicit=new Intent(intent);
                ComponentName componentName =
                        new ComponentName(resolveInfo.activityInfo.applicationInfo.packageName,
                                resolveInfo.activityInfo.name);
                explicit.setComponent(componentName);
                context.sendBroadcast(explicit);
            }
        }

    }
}
```
The steps to transform this into something useable in Delphi:
* From the Android Studio IDE, select the menu build option to make the module. This creates the file classes.jar file under the build\intermediates\packaged-classes\debug directory of the module. 
* Copy this file into the directory containing the Embarcadero supplied Java2OP tool (in my case it is C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\converters\java2op\). (You will probably need to grant all user access to this directory.)
* Rename the file to delphiintents.jar.
* Open a command line in that directory and run the following command to create  a file named Android.JNI.DelphiIntents.pas:
```
java2op -jar delphiintents.jar -unit Android.JNI.DelphiIntents
```

* Move this file and the delphiintents.jar file into the target Delphi project's directory.
* From the project browser, add Android.JNI.DelphiIntents.pas to the project.
* From the project browser, open and right click on "Target Platforms"/Android/Libraries and select "Add.." from the popup menu. Select delphiintents.jar.

