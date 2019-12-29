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
        }else {
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
