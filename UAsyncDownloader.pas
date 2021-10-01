unit UAsyncDownloader;
// Author: Ingmar Tammeväli www.stiigo.com

interface
uses Classes, System.Types, System.Net.HttpClient, System.Threading,
  System.Net.HttpClientComponent, System.IOUtils, UNotification;

const
  CContentJson = 'application/json';

type
  TAsyncHttpDataEvent = reference to procedure(const AData: String; const AEMsg: String;
    const ANotifId: Integer; const ANotifType: TNotificationTypes; const AMiscData: NativeUInt);

type
  TOnDataEventComplete = TAsyncHttpDataEvent;

// Ingmar; 28.02.2021
type
  TAsyncDownloader = class(TObject)
  protected
    FSaferw: TObject;
    FAsyncProfClient: THTTPClient;
    FAsyncProfStream: TStringStream;
    FAsyncProfResult: IAsyncResult;
    FBusy: Boolean;
    FCancelDownload: Boolean;
    FCallNotifQueue: Boolean;
    FLastError: String;
    FNotifId: Integer;
    FNotifType: TNotificationTypes;
    FOnDataEventComplete: TOnDataEventComplete;
    function GetLastError: String;
    function GetBusyStatus: Boolean;
    procedure SetBusyStatus(const v: Boolean);
    procedure OnHTTPRequestReceiveData(const Sender: TObject;
      AContentLength, AReadCount: Int64; var Abort: Boolean);
    procedure DataEventComplete(const AsyncResult: IAsyncResult);
  public
    property LastError: String Read GetLastError;
    property Busy: Boolean Read GetBusyStatus;
    property NotifId: Integer Read FNotifId Write FNotifId;
    property NotifType: TNotificationTypes Read FNotifType Write FNotifType;
    property CancelDownload: Boolean Read FCancelDownload Write FCancelDownload;
    property OnDataEventComplete: TOnDataEventComplete Read FOnDataEventComplete Write FOnDataEventComplete;
    // NotifId = download id
    procedure Get(const AURL: String; const AContentType: String = CContentJson; const ACallNotifQueue: Boolean = True);
    procedure Post(const AURL: String; const AData: String; const AContentType: String = CContentJson; const ACallNotifQueue: Boolean = True);
    constructor Create(const ANotifType: TNotificationTypes = _CNotifNone; const ANotifId: Integer = 0);
    destructor Destroy; override;
  end;

function AsyncGet(
  const AUrl: String;
  const OnDataEvent: TAsyncHttpDataEvent;
  const ANotifType: TNotificationTypes = _CNotifNone;
  const ANotifId: Integer = 0;
  const AMiscData: NativeUInt = 0): ITask;

function AsyncPost(
  const AUrl: String;
  const AData: String;
  const OnDataEvent: TAsyncHttpDataEvent;
  const ANotifType: TNotificationTypes = _CNotifNone;
  const ANotifId: Integer = 0;
  const AMiscData: NativeUInt = 0): ITask;

function ConnectionOk(): Boolean;

implementation
uses SysUtils, UTypes, UTools;

function ConnectionOk(): Boolean;
begin
  Result := True; // TODO
end;

constructor TAsyncDownloader.Create;
begin
  inherited Create;
  FSaferw := TObject.Create;
  FAsyncProfClient := THTTPClient.Create;
  FAsyncProfClient.UserAgent := CDummyUserAgent;
  FAsyncProfClient.OnReceiveData := OnHTTPRequestReceiveData;
  // HTTPClient.ContentType := 'application/json';
  // HTTPClient.Accept      := 'application/json';
  FAsyncProfClient.ConnectionTimeout := 25000;
  FAsyncProfClient.ResponseTimeout   := 55000;
  FAsyncProfStream := TStringStream.Create;
  FNotifType := ANotifType;
  FNotifId := ANotifId;
end;

function TAsyncDownloader.GetBusyStatus: Boolean;
begin
  TMonitor.Enter(FSaferw);
  try
    Result := FBusy;
  finally
    TMonitor.Exit(FSaferw);
  end;
end;

function TAsyncDownloader.GetLastError: String;
begin
  TMonitor.Enter(FSaferw);
  try
    Result := FLastError;
  finally
    TMonitor.Exit(FSaferw);
  end
end;

procedure TAsyncDownloader.SetBusyStatus(const v: Boolean);
begin
  TMonitor.Enter(FSaferw);
  try
    FBusy := v;
  finally
    TMonitor.Exit(FSaferw);
  end;
end;

procedure TAsyncDownloader.OnHTTPRequestReceiveData(const Sender: TObject;
AContentLength, AReadCount: Int64; var Abort: Boolean);
begin
  Abort := FCancelDownload;
end;

destructor TAsyncDownloader.Destroy;
begin
  FreeAndNil(FAsyncProfClient);
  FreeAndNil(FAsyncProfStream);
  FreeAndNil(FSaferw);
  inherited Destroy;
end;

procedure TAsyncDownloader.DataEventComplete(const AsyncResult: IAsyncResult);
var
  LResp: IHTTPResponse;
begin
  try
    LResp := THTTPClient.EndAsyncHTTP(AsyncResult);
    TThread.Synchronize(nil,
      procedure
      var
        data, data2: String;
      begin
        FLastError := '';
        data := FAsyncProfStream.DataString;
        data2 := Trim(LResp.ContentAsString(TEncoding.UTF8));
        if data2 <> '' then
          data := data2; // POST workaround

        if LResp.StatusCode = 200 then
        try
          if Pos('ERR:', data) = 1 then
          begin
            FLastError := data;
            if FCallNotifQueue then
              doNotify(FNotifType, Data, True, Self, FNotifId);

            if Assigned(OnDataEventComplete) then
              OnDataEventComplete('', data, FNotifId, FNotifType, 0);
            Exit;
          end;

          if FCallNotifQueue then
            doNotify(FNotifType, data, False, Self, FNotifId);

            if Assigned(OnDataEventComplete) then
              OnDataEventComplete(data, '', FNotifId, FNotifType, 0);
        except
          on E: Exception do
          try
            FLastError := e.Message + ' ' + LResp.StatusText;
            if FCallNotifQueue then
              doNotify(FNotifType, LResp.StatusText, True, Self, FNotifId);

            if Assigned(OnDataEventComplete) then
              OnDataEventComplete(data, e.Message, FNotifId, FNotifType, 0);
          except // Me ei tohi siin failida !
          end;
        end;
      end);
  finally
    LResp := nil;
    FBusy := False;
  end;
end;

procedure TAsyncDownloader.Get;
begin
  if Busy then
    Exit;

  FCallNotifQueue := ACallNotifQueue;
  FLastError := '';
  FBusy := True;
  FAsyncProfStream.Clear;

  FAsyncProfResult := FAsyncProfClient.BeginGet(
    DataEventComplete,
    AURL,
    FAsyncProfStream);
end;

procedure TAsyncDownloader.Post(const AURL: String;
  const AData: String;
  const AContentType: String = CContentJson;
  const ACallNotifQueue: Boolean = True);
begin
  FCallNotifQueue := ACallNotifQueue;
  FLastError := '';

  if (length(AData) = 0) or ((AContentType = CContentJson) and (AData = '[]')) then
    Exit;

  FBusy := True;
  FAsyncProfStream.Clear;
  FAsyncProfStream.WriteString(AData);
  FAsyncProfStream.Seek(0, 0);

  FAsyncProfResult := FAsyncProfClient.BeginPost(
    DataEventComplete,
    AURL,
    FAsyncProfStream);
end;

// --------------------------------------------------------------

function AsyncGet(
  const AUrl: String;
  const OnDataEvent: TAsyncHttpDataEvent;
  const ANotifType: TNotificationTypes = _CNotifNone;
  const ANotifId: Integer = 0;
  const AMiscData: NativeUInt = 0): ITask;
begin
  Result := TTask.Run(
    procedure
    var
       acc: TAsyncDownloader;
       httprez: IHTTPResponse;
    begin
      acc := TAsyncDownloader.Create(ANotifType, ANotifId);
      try
        try
          httprez :=acc.FAsyncProfClient.Get(AUrl, acc.FAsyncProfStream);
          if Assigned(OnDataEvent) then
            TThread.Synchronize(nil,
              procedure
              var
                data, emsg: String;
              begin
                emsg := '';
                data := Trim(acc.FAsyncProfStream.DataString);
                if (httprez.StatusCode <> 200) then
                  emsg := httprez.StatusText
                else if Pos('ERR:', data) > 0  then
                  emsg := data;

                OnDataEvent(data, emsg, ANotifId, ANotifType, AMiscData);
                if ANotifType <> _CNotifNone then
                begin
                  var iserror: Boolean;
                  iserror := emsg <> '';
                  if iserror then
                    data := emsg;
                  doNotify(ANotifType, data, iserror, nil, ANotifId);
                end;
              end);
        finally
          FreeAndNil(acc);
        end;
      except
        on E: Exception do
      end;
    end);
end;


function AsyncPost(
  const AUrl: String;
  const AData: String;
  const OnDataEvent: TAsyncHttpDataEvent;
  const ANotifType: TNotificationTypes = _CNotifNone;
  const ANotifId: Integer = 0;
  const AMiscData: NativeUInt = 0): ITask;
begin
  Result := TTask.Run(
    procedure
    var
       acc: TAsyncDownloader;
       httprez: IHTTPResponse;
    begin
      acc := TAsyncDownloader.Create(ANotifType, ANotifId);
      try
        try
          acc.FAsyncProfStream.WriteString(AData);
          acc.FAsyncProfStream.Seek(0, 0);
          httprez := acc.FAsyncProfClient.Post(AUrl, acc.FAsyncProfStream);
          if Assigned(OnDataEvent) then
            TThread.Synchronize(nil,
              procedure
              var
                data, emsg: String;
              begin
                emsg := '';
                data := Trim(httprez.ContentAsString(TEncoding.UTF8));
                if (httprez.StatusCode <> 200) then
                  emsg := httprez.StatusText
                else if Pos('ERR:', data) > 0  then
                  emsg := data;

                OnDataEvent(data, emsg, ANotifId, ANotifType, AMiscData);
                if ANotifType <> _CNotifNone then
                begin
                  var iserror: Boolean;
                  iserror := emsg <> '';
                  if iserror then
                    data := emsg;
                  doNotify(ANotifType, data, iserror, nil, ANotifId);
                end;
              end);
        finally
          FreeAndNil(acc);
        end;
      except
        on E: Exception do
      end;
    end);
end;

end.

