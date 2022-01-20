# How to Compile and Use Java Code in a Delphi Project

## General Overview

This read-me file contains step-by-step instructions on how to compile a Java class into a .jar file and include them in a Delphi application.

To use a Java class in a Delphi project requires:

- A compiled .jar file, and
- A Delphi/Java bridge unit

## Creating The Android .Jar File

The Android directory contains a .compiled jar file and Delphi/Java bridge unit, Android.JNI.DelphiIntents.pas. These can be added "as is" to any Delphi project needing to send intents on Oreo or above. The following describes the steps I took to generate these. (Not being a Java programmer, there may be a more efficient way of achieving this.)

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

- From the Android Studio IDE, select the menu build option to make the module. This creates the file classes.jar file under the build\intermediates\packaged-classes\debug directory of the module.
- Copy this file into the directory containing the Embarcadero supplied Java2OP tool (in my case it is C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\converters\java2op\). (You will probably need to grant all user access to this directory.)
- Rename the file to delphiintents.jar.
- Open a command line in that directory and run the following command to create a file named Android.JNI.DelphiIntents.pas:

```
java2op -jar delphiintents.jar -unit Android.JNI.DelphiIntents
```

- Move this file and the delphiintents.jar file into the target Delphi project's directory.
- From the project browser, add Android.JNI.DelphiIntents.pas to the project.
- From the project browser, open and right click on "Target Platforms"/Android/Libraries and select "Add.." from the popup menu. Select delphiintents.jar.
