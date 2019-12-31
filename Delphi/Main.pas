unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Platform,
  Androidapi.JNI.GraphicsContentViewText,
  BroadcastReceiver, FMX.ScrollBox, FMX.Memo;

type
  TformMain = class(TForm)
    Header: TToolBar;
    Footer: TToolBar;
    HeaderLabel: TLabel;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    FBroadcastReceiver: TAppBroadcastReceiver;
    FScannerClaimed: Boolean;
    procedure BroadcastReceiverOnReceive(Context: JContext; Intent: JIntent);
    function HandleAppEvent(AAppEvent: TApplicationEvent;
      AContext: TObject): Boolean;
    procedure OnPause;
    procedure OnResume;
    procedure SendIntent(Intent: JIntent);
    procedure SendBroadcast(const AIntent: JIntent);
  public
    { Public declarations }
  end;

var
  formMain: TformMain;

implementation

{$R *.fmx}

uses
  FMX.Platform.Android, Androidapi.Helpers, Androidapi.JNI.Os,
  Androidapi.JNI.JavaTypes, Android.JNI.DelphiIntents;

const
  ACTION_CLAIM_SCANNER = 'com.honeywell.aidc.action.ACTION_CLAIM_SCANNER';
  ACTION_RELEASE_SCANNER = 'com.honeywell.aidc.action.ACTION_RELEASE_SCANNER';
  ACTION_BARCODE_DATA =
    'au.com.corbtech.honeywellscannerdemo.action.BARCODE_SCAN';
  EXTRA_SCANNER = 'com.honeywell.aidc.extra.EXTRA_SCANNER';
  EXTRA_PROFILE = 'com.honeywell.aidc.extra.EXTRA_PROFILE';
  EXTRA_PROPERTIES = 'com.honeywell.aidc.extra.EXTRA_PROPERTIES';

procedure TformMain.BroadcastReceiverOnReceive(Context: JContext;
  Intent: JIntent);

  procedure AddStringToMemo(Intent: JIntent; PropertyName: string;
    Title: string);
  var
    data: string;
  begin
    data := JStringToString
      (Intent.getStringExtra(StringToJString(PropertyName)));
    Memo1.Lines.Add(Format('%s: %s', [Title, data]));
  end;

var
  version: Integer;
begin
  if (JStringToString(Intent.getAction) = ACTION_BARCODE_DATA) then
  begin
    version := Intent.getIntExtra(StringToJString('version'), 0);
    if (version > 0) then
    begin
      AddStringToMemo(Intent, 'data', 'Barcode');
      AddStringToMemo(Intent, 'aimId', 'AIM Identifier');
      AddStringToMemo(Intent, 'charset', 'Character Set');
      AddStringToMemo(Intent, 'codeId', 'Barcode type');
      AddStringToMemo(Intent, 'timestamp', 'Timestamp');
      Memo1.Lines.Add('');
    end;
  end;
end;

procedure TformMain.FormCreate(Sender: TObject);

var
  AppEventService: IFMXApplicationEventService;
begin
  FBroadcastReceiver := TAppBroadcastReceiver.Create;
  FBroadcastReceiver.onReceive := BroadcastReceiverOnReceive;
  FBroadcastReceiver.RegisterReceive;
  FScannerClaimed := False;

  if TPlatformServices.Current.SupportsPlatformService
    (IFMXApplicationEventService, AppEventService) then
    AppEventService.SetApplicationEventHandler(HandleAppEvent);

  MainActivity.registerIntentAction(StringToJString(ACTION_BARCODE_DATA));
  OnResume();

end;

function TformMain.HandleAppEvent(AAppEvent: TApplicationEvent;
  AContext: TObject): Boolean;
begin
  Result := True;
  case AAppEvent of
    TApplicationEvent.FinishedLaunching:
      log.d('Finished Launching');
    TApplicationEvent.BecameActive:
      begin
        log.d('Became Active');
        OnResume();
      end;
    TApplicationEvent.WillBecomeInactive:
      begin
        log.d('Will Become Inactive');
        OnPause();
      end;
    TApplicationEvent.EnteredBackground:
      log.d('Entered Background');
    TApplicationEvent.WillBecomeForeground:
      log.d('Will Become Foreground');
    TApplicationEvent.WillTerminate:
      log.d('Will Terminate');
    TApplicationEvent.LowMemory:
      log.d('Low Memory');
    TApplicationEvent.TimeChange:
      log.d('Time Change');
    TApplicationEvent.OpenURL:
      log.d('Open URL');
  end;
end;

procedure TformMain.OnPause;
var
  Intent: JIntent;
begin
  if FScannerClaimed then
  begin
    FScannerClaimed := False;
    FBroadcastReceiver.Clear;

    Intent := TJIntent.Create;
    Intent.setAction(StringToJString(ACTION_RELEASE_SCANNER));
    SendIntent(Intent);
    log.d('Released Scanner');
  end;
end;

procedure TformMain.OnResume;
var
  Intent: JIntent;
  properties: JBundle;
begin
  if not FScannerClaimed then
  begin
    Intent := TJIntent.Create;
    Intent.setAction(StringToJString(ACTION_CLAIM_SCANNER));

    properties := TJBundle.Create;
    properties.putBoolean(StringToJString('DPR_DATA_INTENT'), True);
    properties.putString(StringToJString('DPR_DATA_INTENT_ACTION'),
      StringToJString(ACTION_BARCODE_DATA));

    Intent.putExtra(StringToJString(EXTRA_SCANNER),
      StringToJString('dcs.scanner.imager'));
    Intent.putExtra(StringToJString(EXTRA_PROFILE), StringToJString('DEFAULT'));
    Intent.putExtra(StringToJString(EXTRA_PROPERTIES), properties);

    SendIntent(Intent);
    FScannerClaimed := True;
    FBroadcastReceiver.Add(ACTION_BARCODE_DATA);
    log.d('Claimed Scanner');
  end;
end;

procedure TformMain.SendIntent(Intent: JIntent);
var
  appContext: JContext;
begin
  appContext := TAndroidHelper.Context.getApplicationContext;
  TJSendIntent.JavaClass.appSendBroadcast(appContext, Intent);
end;

procedure TformMain.SendBroadcast(const AIntent: JIntent);
{
  This is the equivalent Delphi only code as provided by David Nottage at
  https://gist.github.com/DelphiWorlds/8eaa900ea9df70df902bee2123a64c6d?fbclid=IwAR0CwsAFIFvXA0TGSVUIMifXv1qWZEK4WZieeSuSXVyTHWBnCInOzwa6DdY
}
var
  LResolveInfoList: JList;
  LResolveInfo: JResolveInfo;
  LComponentName: JComponentName;
  LExplicitIntent: JIntent;
  I: Integer;
begin
  if TJBuild_VERSION.JavaClass.SDK_INT >= 26 then
  begin
    LResolveInfoList := TAndroidHelper.Context.getPackageManager.queryBroadcastReceivers(AIntent, 0);
    for I := 0 to LResolveInfoList.size - 1 do
    begin
      LResolveInfo := TJResolveInfo.Wrap(TAndroidHelper.JObjectToID(LResolveInfoList.get(I)));
      LComponentName := TJComponentName.JavaClass.init(LResolveInfo.activityInfo.applicationInfo.packageName, LResolveInfo.activityInfo.name);
      LExplicitIntent := TJIntent.JavaClass.init(AIntent);
      LExplicitIntent.setComponent(LComponentName);
      TAndroidHelper.Context.sendBroadcast(LExplicitIntent);
    end;
  end
  else
    TAndroidHelper.Context.sendBroadcast(AIntent);
end;

end.
