unit UNotification;
// Author: Ingmar Tammeväli www.stiigo.com

interface
uses SysUtils, System.Generics.Collections, UTools, UTypes;

// Events
type
  TNotificationTypes = (
    _CNotifNone = 0,
    _CNotifCachedProfileCompleted, // tööde profiilid laetud
    _CNotifCachedClassifCompleted, // klassifikaatori laetud
    _CNotifProfileWkLevelsCompleted, // mobiil: profiili tööde tasemete puhver
    _CNotifProfileLoading, // mobiil: kui ajaprofiili laadimist alustataks
    _CNotifProfileCompleted, // mobiil: kui laetakse ajaprofiil objekti valikul
    _CNotifObjectListCompleted // mobiil; objektide nimistu laetud
  );

type
  // TOnNotifyDataDownloaded = procedure(const ARespMessage: String; const AIsError: Boolean) of object;
  TOnNotifyEvent = reference to procedure(const ANotifType: TNotificationTypes;
    const AObj: TObject; const ANotifId: Integer; const AMessage: String; const AIsError: Boolean);
  TNotifyList = TList<TOnNotifyEvent>;

function NotifyList: TNotifyList;

procedure doNotify(
  const ANotifType: TNotificationTypes;
  const AMsg: String;
  const AIsError: Boolean;
  const ANotifObject: TObject = nil;
  const ANotifId: Integer = 0);

implementation
var
  _glob_notifList: TNotifyList = nil;

procedure doNotify(
  const ANotifType: TNotificationTypes;
  const AMsg: String;
  const AIsError: Boolean;
  const ANotifObject: TObject = nil;
  const ANotifId: Integer = 0);
var
  notif: TOnNotifyEvent;
  list: TNotifyList;
begin
  if ANotifType <> _CNotifNone then
  try
    TMonitor.Enter(_glob_notifList);
    list := NotifyList();
    for var i : Integer := 0 to list.Count - 1 do
    begin
      notif := list.Items[i];
      if not Assigned(notif) then
        Continue;

      try
        notif(ANotifType, ANotifObject, ANotifId, AMsg, AIsError);
      except
        // Protect event queue
        on E: Exception do
        begin
          UTools._debugMsg(E.Message)
        end;
      end;
    end;
  finally
    TMonitor.Exit(_glob_notifList);
  end;
end;

function NotifyList: TNotifyList;
begin
  TMonitor.Enter(_glob_notifList);
  try
    Result := _glob_notifList;
  finally
    TMonitor.Exit(_glob_notifList);
  end;
end;

initialization
  _glob_notifList := TNotifyList.Create;
finalization
  try
    _glob_notifList.Clear;
    FreeAndNil(_glob_notifList);
  except
    on E: Exception do
    begin
    {$IFDEF DEBUG}
    UTools._debugMsg(E.Message);
    {$ENDIF}
    end;
  end;
end.
