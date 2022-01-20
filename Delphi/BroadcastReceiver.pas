unit BroadcastReceiver;

interface

{
  Based on https://github.com/barisatalay/delphi-android-broadcast-receiver-component
  With a few fixes!
}

Uses
  System.Classes,
{$IFDEF ANDROID}
  Androidapi.JNI.Embarcadero, Androidapi.JNI.GraphicsContentViewText,
  Androidapi.helpers, Androidapi.JNIBridge, FMX.helpers.Android,
  Androidapi.JNI.JavaTypes,
{$ENDIF}
  System.SysUtils;

type

{$IFNDEF ANDROID}
  JBundle = class
  end;

  JIntent = class
  end;

  JContext = class
  end;
{$ENDIF}

  TAppBroadcastReceiver = class;
  TOnReceive = procedure(Context: JContext; Intent: JIntent) of object;

{$IFDEF ANDROID}

  TListener = class(TJavaLocal, JFMXBroadcastReceiverListener)
  private
    FOwner: TAppBroadcastReceiver;
  public
    constructor Create(AOwner: TAppBroadcastReceiver);
    procedure onReceive(Context: JContext; Intent: JIntent); cdecl;
  end;
{$ENDIF}

  TAppBroadcastReceiver = class
  private
{$IFDEF ANDROID}
    FReceiver: JBroadcastReceiver;
    FListener: TListener;
{$ENDIF}
    FOnReceive: TOnReceive;
    FItems: TStringList;
    function GetItem(const Index: Integer): String;

  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(Value: String);
    procedure Delete(Index: Integer);
    procedure Clear;
    function Remove(const Value: String): Integer;
    function First: String;
    function Last: String;
    function HasPermission(const Permission: string): Boolean;
    procedure RegisterReceive;
    property Item[const Index: Integer]: String read GetItem; default;
    property Items: TStringList read FItems write FItems;
  published
    property onReceive: TOnReceive read FOnReceive write FOnReceive;
  end;

implementation

{ TBroadcastReceiver }

procedure TAppBroadcastReceiver.Add(Value: String);
{$IFDEF ANDROID}
var
  Filter: JIntentFilter;
{$ENDIF}
begin
{$IFDEF ANDROID}
  if (FListener = nil) or (FReceiver = nil) then
  begin
    Raise Exception.Create('First use RegisterReceive!');
    Exit;
  end;
{$ENDIF}
  if FItems <> nil then
    if FItems.IndexOf(Value) = -1 then
    begin
{$IFDEF ANDROID}
      Filter := TJIntentFilter.Create;
      Filter.addAction(StringToJString(Value));
      TAndroidHelper.Context.registerReceiver(FReceiver, Filter);
{$ENDIF}
      FItems.Add(Value);
    end;
end;

procedure TAppBroadcastReceiver.Clear;
begin
  while (FItems.Count > 0) do
    self.Delete(0);
  FItems.Clear;
end;

constructor TAppBroadcastReceiver.Create;
begin
  FItems := TStringList.Create;
end;

procedure TAppBroadcastReceiver.Delete(Index: Integer);
begin
  if FItems <> nil then
  begin
    FItems.Delete(Index);
{$IFDEF ANDROID}
    TAndroidHelper.Context.UnregisterReceiver(FReceiver);
    RegisterReceive;
{$ENDIF}
  end;
end;

destructor TAppBroadcastReceiver.Destroy;
begin
  FItems.Free;
{$IFDEF ANDROID}
  if FReceiver <> nil then
    TAndroidHelper.Context.UnregisterReceiver(FReceiver);
{$ENDIF}
  inherited;
end;

function TAppBroadcastReceiver.First: String;
begin
  Result := FItems[0];
end;

function TAppBroadcastReceiver.GetItem(const Index: Integer): String;
begin
  Result := FItems[Index];
end;

function TAppBroadcastReceiver.HasPermission(const Permission: string): Boolean;
{$IFDEF ANDROID}
begin
  // Permissions listed at http://d.android.com/reference/android/Manifest.permission.html
  Result := TAndroidHelper.Context.checkCallingOrSelfPermission
    (StringToJString(Permission)) = TJPackageManager.JavaClass.
    PERMISSION_GRANTED
{$ELSE}
begin
  Result := False;
{$ENDIF}
end;

function TAppBroadcastReceiver.Last: String;
begin
  Result := FItems[FItems.Count];
end;

procedure TAppBroadcastReceiver.RegisterReceive;
{$IFDEF ANDROID}
var
  I: Integer;
begin
  if FListener = nil then
    FListener := TListener.Create(self);
  if FReceiver = nil then
    FReceiver := TJFMXBroadcastReceiver.JavaClass.init(FListener);
  if FItems <> nil then
    if FItems.Count > 0 then
      for I := 0 to FItems.Count - 1 do
        Add(FItems[I]);
{$ELSE}
begin
{$ENDIF}
end;

function TAppBroadcastReceiver.Remove(const Value: String): Integer;
begin
  Result := FItems.IndexOf(Value);
  if Result > -1 then
    FItems.Delete(Result);
end;

{$IFDEF ANDROID}

constructor TListener.Create(AOwner: TAppBroadcastReceiver);
begin
  inherited Create;
  FOwner := AOwner;
end;

procedure TListener.onReceive(Context: JContext; Intent: JIntent);
begin
  if Assigned(FOwner.onReceive) then
    FOwner.onReceive(Context, Intent);
end;

{$ENDIF}

end.
