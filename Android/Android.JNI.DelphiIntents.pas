
unit Android.JNI.DelphiIntents;

interface

uses
  Androidapi.JNIBridge,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.JavaTypes;

type
// ===== Forward declarations =====

  Jdelphiintents_BuildConfig = interface;//au.com.corbtech.delphiintents.BuildConfig
  JSendIntent = interface;//au.com.corbtech.delphiintents.SendIntent

// ===== Interface declarations =====

  Jdelphiintents_BuildConfigClass = interface(JObjectClass)
    ['{1E13F852-3904-4BD1-94C7-59AA4BC71565}']
    {class} function _GetAPPLICATION_ID: JString; cdecl;
    {class} function _GetBUILD_TYPE: JString; cdecl;
    {class} function _GetDEBUG: Boolean; cdecl;
    {class} function _GetFLAVOR: JString; cdecl;
    {class} function _GetLIBRARY_PACKAGE_NAME: JString; cdecl;
    {class} function _GetVERSION_CODE: Integer; cdecl;
    {class} function _GetVERSION_NAME: JString; cdecl;
    {class} function init: Jdelphiintents_BuildConfig; cdecl;
    {class} property APPLICATION_ID: JString read _GetAPPLICATION_ID;
    {class} property BUILD_TYPE: JString read _GetBUILD_TYPE;
    {class} property DEBUG: Boolean read _GetDEBUG;
    {class} property FLAVOR: JString read _GetFLAVOR;
    {class} property LIBRARY_PACKAGE_NAME: JString read _GetLIBRARY_PACKAGE_NAME;
    {class} property VERSION_CODE: Integer read _GetVERSION_CODE;
    {class} property VERSION_NAME: JString read _GetVERSION_NAME;
  end;

  [JavaSignature('au/com/corbtech/delphiintents/BuildConfig')]
  Jdelphiintents_BuildConfig = interface(JObject)
    ['{8CFCCF0E-DD8A-4CF2-8E58-30183B87B2E1}']
  end;
  TJdelphiintents_BuildConfig = class(TJavaGenericImport<Jdelphiintents_BuildConfigClass, Jdelphiintents_BuildConfig>) end;

  JSendIntentClass = interface(JObjectClass)
    ['{2335C4E8-C77C-4931-A311-7D70530A09E9}']
    {class} procedure appSendBroadcast(P1: JContext; P2: JIntent); cdecl;//Deprecated
    {class} function init: JSendIntent; cdecl;//Deprecated
  end;

  [JavaSignature('au/com/corbtech/delphiintents/SendIntent')]
  JSendIntent = interface(JObject)
    ['{A84450D4-3EB1-4FFA-848F-7D8883F3235B}']
  end;
  TJSendIntent = class(TJavaGenericImport<JSendIntentClass, JSendIntent>) end;

implementation

procedure RegisterTypes;
begin
  TRegTypes.RegisterType('Android.JNI.DelphiIntents.Jdelphiintents_BuildConfig', TypeInfo(Android.JNI.DelphiIntents.Jdelphiintents_BuildConfig));
  TRegTypes.RegisterType('Android.JNI.DelphiIntents.JSendIntent', TypeInfo(Android.JNI.DelphiIntents.JSendIntent));
end;

initialization
  RegisterTypes;
end.

