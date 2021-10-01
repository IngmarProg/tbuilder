unit UDataAndImgmodule;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, SyncObjs, FMX.ImgList,
  IdZLibCompressorBase, IdCompressorZLib, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, Vcl.ImgList, Vcl.Controls,
  UProfiles, UBase, UTypes, System.Generics.Collections, System.Types,
  System.Net.HttpClient, System.Net.HttpClientComponent, System.IOUtils,
  UNotification, UAsyncDownloader, UClassificators;


type
  TCommonData = class(TDataModule)
    httpDataReader: TIdHTTP;
    IdCompressorDataReader: TIdCompressorZLib;
    httpDataWriter: TIdHTTP;
    IdCompressorDataWriter: TIdCompressorZLib;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  protected
    FCachedItemsRef: Integer; // hetkel 2
    FCacheLoaded: Boolean;
    FCacheProfileDownloadId: Integer;
    // TODO ühe downloadiga asi ära teha, multipart download metoodikaga
    FCacheProfileDownloader: TAsyncDownloader;
    FCacheClassifDownloadId: Integer;
    FCacheClassifDownloader: TAsyncDownloader;
    // cache jobs profile / timeline profiles
    FCachedProfiles: TObjectList<TProfiles>;
    FCachedClassificators: TObjectList<TClassificators>;
    FFncProfileCacheDownloaded: TOnNotifyEvent;
    FFncClassificatorsCacheDownloaded: TOnNotifyEvent;
    // FOnCachedProfilesdownloaded: TOnNotifyDataDownloaded;
    FFncBizObjectDelete: TOnDeleteData;
    FFncBizObjectDelete2: TOnDeleteData2;
    FFncBizObjectSave: TOnSaveData;
    FFncBizObjectSave2: TOnSaveData2;
    FFncBizObjectReadData: TOnReadData;
    function GetCachedProfiles: TObjectList<TProfiles>;
    function GetCachedClassificators: TObjectList<TClassificators>;
  public
    // Data reader / writer
    property FncBizObjectDelete: TOnDeleteData Read FFncBizObjectDelete;
    property FncBizObjectDelete2: TOnDeleteData2 Read FFncBizObjectDelete2;
    property FncBizObjectSave: TOnSaveData Read FFncBizObjectSave;
    property FncBizObjectSave2: TOnSaveData2 Read FFncBizObjectSave2;
    property FncBizObjectReadData: TOnReadData Read FFncBizObjectReadData;
    // Cached items
    property CachedProfiles: TObjectList<TProfiles> Read GetCachedProfiles;
    property CachedClassificators: TObjectList<TClassificators> Read GetCachedClassificators;
    property CacheLoaded: Boolean Read FCacheLoaded;
    property CacheProfileDownloadId: Integer Read FCacheProfileDownloadId;
    property CacheClassificatorsDownloadId: Integer Read FCacheClassifDownloadId;
    property CachedItemsRef: Integer Read FCachedItemsRef;
    // SYNC !
    function PutData(const AUrl: String;
      const AUsr: String;
      const APwd: String;
      const AData: String;
      var AHttpCode: Integer;
      var AEMsg: String): String;
    function GetData(const AUrl: String;
      const AUsr: String;
      const APwd: String;
      var AHttpCode: Integer;
      var AEMsg: String): String;
    function _fetchBizObjectData(const AClassName: String; const AId: Integer; AFilter: TStringList): String;
    function getTimeProfileWkTemplate: TProfiles;
    procedure returnItemIdAndName(const AProfiles: TProfiles; const AList: TStringList);
    procedure LoadCacheData();
  end;

var
  CommonData: TCommonData;


implementation
uses StrUtils, UConf, Json, UTools;

{%CLASSGROUP 'FMX.Controls.TControl'}
const
  CERRPrefix = 'err:';

{$R *.dfm}
var
  _crit: TCriticalSection;

function TCommonData.GetTimeProfileWkTemplate;
var
  prof: TProfiles;
begin
  try
    _crit.Enter;
    Result := nil;
    for prof in CachedProfiles do
      if prof.Active and prof.Is_Template and (prof.Profile_type = TProfileTypeStr[_CWorkProfile]) then
      begin
        Exit(prof);
      end;

    //  _debugMsg('start_GetTimeProfileWkTemplate ' + DateTimeToStr(Now));
    //  _debugMsg('end_GetTimeProfileWkTemplate ' + DateTimeToStr(Now));
    try
      Result := TProfiles.Create;
      Result.Profile_type := TProfileTypeStr[_CWorkProfile];
      Result.Is_Template := True;
      Result.Company_Id := TConf.currCompanyId;
      Result.Department_Id := TConf.currDepartmentId;
      Result.Save(FFncBizObjectSave);
      CachedProfiles.Add(Result);
    except
      FreeAndNil(Result);
      raise;
    end;
  finally
    _crit.Leave;
  end;
end;

procedure TCommonData.returnItemIdAndName(const AProfiles: TProfiles; const AList: TStringList);
var
  wkitem: TProfileItem;
begin
  AList.Clear;
  for wkitem in AProfiles.Profile_items do
    if wkitem.Active then
    begin
      AList.AddObject(wkitem.Item_name, TObject(NativeUInt(wkitem.Id)));
    end;
end;

procedure TCommonData.LoadCacheData();
var
  restget: String;
begin
  FCacheLoaded := False;
  FCachedItemsRef := 2; // FCacheClassifDownloader / FCacheProfileDownloader
  restget := TClassificators.GetURI(True);
  FCacheClassifDownloader.NotifId := FCacheClassifDownloadId;
  FCacheClassifDownloader.Get(restget);

  restget := TProfiles.GetURI(true)
    + '&profile_type=' + TProfileTypeStr[_CWorkProfile]
    + '&flags=all';
  FCacheProfileDownloader.NotifId := FCacheProfileDownloadId;
  FCacheProfileDownloader.Get(restget);
end;

function TCommonData.GetCachedProfiles: TObjectList<TProfiles>;
begin
  _crit.Enter;
  try
    Result := FCachedProfiles;
  finally
    _crit.Leave;
  end;
end;

function TCommonData.GetCachedClassificators: TObjectList<TClassificators>;
begin
  _crit.Enter;
  try
    Result := FCachedClassificators;
  finally
    _crit.Leave;
  end;
end;

procedure TCommonData.DataModuleCreate(Sender: TObject);
const
  CDummyUserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:85.0) Gecko/20100101 Firefox/85.0';
begin
  FCacheProfileDownloader := TAsyncDownloader.Create(_CNotifCachedProfileCompleted);
  FCacheClassifDownloader := TAsyncDownloader.Create(_CNotifCachedClassifCompleted);

  FCachedProfiles := TObjectList<TProfiles>.Create;
  FCachedProfiles.OwnsObjects := True;

  FCachedClassificators := TObjectList<TClassificators>.Create;
  FCachedClassificators.OwnsObjects := True;

  UTools.AssignClfAndProfilesRefs(FCachedClassificators, FCachedProfiles);

  // procedure TCommonData.DataReceiveEvent(const Sender: TObject; AContentLength, AReadCount: Int64; var Abort: Boolean);
  // FAsyncnClient.OnReceiveData := DataReceiveEvent;
  httpDataReader.Request.UserAgent := CDummyUserAgent;
  httpDataWriter.Request.UserAgent := CDummyUserAgent;
  // Indy
  // 20.02.2021 Ingmar Tammeväli; define reference func.
  // @@
  FFncBizObjectDelete2 :=
    procedure(const AObj: TObject; const AID: TArray<Integer>; var AErrMsg: String)
    var
      httpcode: Integer;
      resturl, data, idlist: String;
    begin
      resturl := Trim(TConf.ServiceURL);
      if (resturl = '') or not (AObj is TBase) then
        Exit;

      idlist := '';
      for var i: Integer := Low(AID) to High(AID) do
      begin
        if (i > Low(AID)) then
          idlist := idlist + ',';
        idlist := idlist + AID[i].ToString;
      end;
        

      data := PutData(resturl + 'delete/' + AObj.ClassName + '?ids=' + idlist,
        TConf.ServiceUsr,
        TConf.ServicePwd,
        '',
        httpcode,
        AErrMsg);
    end;

  // @@
  FFncBizObjectDelete := procedure(const AObj: TObject)
    var
      emsg: String;
    begin
      FFncBizObjectDelete2(AObj, TArray<Integer>.Create(TBase(AObj).Id), emsg);
      if emsg <> '' then
        raise Exception.Create(emsg);
    end;

  // @@
  FFncBizObjectSave := function(const AObj: TObject; var AErrMsg: String): TStringlist
    var
      resturl: String;
      data: String;
      httpcode: Integer;
      errmsgperrow: String;
    begin
      Result := nil;
      resturl := Trim(TConf.ServiceURL);
      if (resturl = '') or not (AObj is TBase) then
        Exit;

      if resturl[length(resturl)] <> '/' then
        resturl := resturl + '/';

      data := PutData(resturl + 'save/',
        TConf.ServiceUsr,
        TConf.ServicePwd,
        TBase(AObj).ToJson,
        httpcode,
        AErrMsg);
      if (data <> '') and (AErrMsg = '') then
      begin
        Result := AssignJsonRPIDs(Data, errmsgperrow);
        AErrMsg := Trim(AErrMsg + #32 + errmsgperrow);
      end;
    end;

  // @@
  // Raw json save
  FFncBizObjectSave2 := function(const AJson: String; var AErrMsg: String): TStringlist
    var
      resturl, data, errmsgperrow: String;
      httpcode: Integer;
    begin
      Result := nil;
      resturl := Trim(TConf.ServiceURL);
      if (resturl = '') or (Trim(AJson) = '') then
        Exit;

      if resturl[length(resturl)] <> '/' then
        resturl := resturl + '/';

      data := PutData(resturl + 'save/',
        TConf.ServiceUsr,
        TConf.ServicePwd,
        AJson,
        httpcode,
        AErrMsg);
      if (data <> '') and (AErrMsg = '') then
      begin
        errmsgperrow := '';
        Result := AssignJsonRPIDs(Data, errmsgperrow);
        AErrMsg := Trim(AErrMsg + #32 + errmsgperrow);
      end;
    end;


  // Common data reader
  FFncBizObjectReadData :=
    function(const AClassname: String; const AId: Integer;
      const AFilt: TStringlist; var AErrMsg: String): String
    begin
      Result := _fetchBizObjectData(AClassname, AId, AFilt);
    end;

  {
    * 28.02.2021 Ingmar; TODO teha multiresponse toetus backendi.
    * St ühe päringuga tagastatakse töötajate JSON ja kogu klassifikaatorite sisu !
    * Ehk jääks üks downloader, mitte kaks nagu hetkel
  }
  // Cached profiles download
  FFncProfileCacheDownloaded :=
    procedure(const ANotifType: TNotificationTypes;
      const AObj: TObject; const ANotifId: Integer; const AMessage: String; const AIsError: Boolean)
    var
      base: TBase;
      basebfr: TObjectList<TBase>;
    begin
      if (ANotifType = _CNotifCachedProfileCompleted) and (FCacheProfileDownloadId = ANotifId) then
      begin
        Dec(FCachedItemsRef);
        FCacheLoaded := FCachedItemsRef < 1;
        basebfr := TObjectList<TBase>.Create;
        basebfr.OwnsObjects := False;
        try
          TProfiles.JSONRespToDsObjects(AMessage, basebfr);
          CachedProfiles.Clear;
          // Remap
          for base in basebfr do
            CachedProfiles.Add(base as TProfiles);
        finally
          FreeAndNil(basebfr);
        end;
      end;
    end;

  FFncClassificatorsCacheDownloaded :=
    procedure(const ANotifType: TNotificationTypes;
      const AObj: TObject; const ANotifId: Integer; const AMessage: String; const AIsError: Boolean)
    var
      base: TBase;
      basebfr: TObjectList<TBase>;
    begin
      if (ANotifType = _CNotifCachedClassifCompleted) and (FCacheClassifDownloadId = ANotifId) then
      begin
        Dec(FCachedItemsRef);
        FCacheLoaded := FCachedItemsRef < 1;
        basebfr := TObjectList<TBase>.Create;
        basebfr.OwnsObjects := False;
        try
          TClassificators.JSONRespToDsObjects(AMessage, basebfr);
          CachedClassificators.Clear;
          // Remap
          for base in basebfr do
            CachedClassificators.Add(base as TClassificators);
        finally
          FreeAndNil(basebfr);
        end;
      end;
    end;

  FCacheProfileDownloadId := Random(Integer.MaxValue - 1);
  FCacheClassifDownloadId := Random(Integer.MaxValue - 1);
  NotifyList.Add(FFncProfileCacheDownloaded);
  NotifyList.Add(FFncClassificatorsCacheDownloaded);
end;

function TCommonData.PutData;
var
  sstr: TStringStream;
begin
  AHttpCode := 0;
  AEmsg := '';
  _crit.Enter;
  sstr := TStringStream.Create(UTF8Encode(AData));
  sstr.Seek(0,0);
  try
    try
      Result := Trim(httpDataWriter.Post(AURL, sstr));
      if Pos(CERRPrefix, Result.ToLower) = 1 then
        raise Exception.Create(Result);

    except
      on E: EIdHTTPProtocolException do
      begin
        AEmsg := E.ErrorMessage;
        AHttpCode := E.ErrorCode;
      end;
      on E: Exception do
      begin
        //AEmsg := Trim(httpDataReader.Response.ResponseText + #32 + E.Message);
        AEmsg := E.Message;
        AHttpCode := httpDataReader.Response.ResponseCode;
      end;
    end;
  finally
    _crit.Leave;
    FreeAndNil(sstr);
  end;
end;

procedure TCommonData.DataModuleDestroy(Sender: TObject);
begin
  UTools.AssignClfAndProfilesRefs(nil, nil);

  FCacheClassifDownloader.CancelDownload := True;
  while FCacheClassifDownloader.Busy do
    Sleep(50);

  FCacheProfileDownloader.CancelDownload := True;
  while FCacheProfileDownloader.Busy do
    Sleep(50);

  FreeAndNil(FCacheClassifDownloader);
  FreeAndNil(FCacheProfileDownloader);
  FreeAndNil(FCacheProfileDownloader);
  FreeAndNil(FCachedProfiles);
  FreeAndNil(FCachedClassificators);
end;

function TCommonData.GetData;
begin
  AHttpCode := 0;
  AEmsg := '';
  _crit.Enter;
  try
    try
      Result := Trim(httpDataReader.Get(AURL));
      if Pos(CERRPrefix, Result) = 1 then
        raise Exception.Create(Result);
    except
      on E: EIdHTTPProtocolException do
      begin
        AEmsg := E.ErrorMessage;
        AHttpCode := E.ErrorCode;
      end;
      on E: Exception do
      begin
        AEmsg := Trim(httpDataReader.Response.ResponseText + #32 + E.Message);
        AHttpCode := httpDataReader.Response.ResponseCode;
      end;
    end;
  finally
    _crit.Leave;
  end;
end;

function TCommonData._fetchBizObjectData(const AClassName: String; const AId: Integer; AFilter: TStringList): String;
var
  ecode: Integer;
  emsg: String;
  resturl: String;
begin
  Result := '';
  if AClassName <> '' then
  begin
    resturl := Trim(TConf.ServiceURL);
    if resturl = '' then
      Exit;

    if resturl[length(resturl)] <> '/' then
      resturl := resturl + '/';

    resturl := resturl + 'get/'+ AClassName.ToLower + '/';
    if AId > 0 then
      resturl := resturl + AId.ToString + '/';

    if Assigned(AFilter) then
      resturl := resturl + '?' + AFilter.DelimitedText;

    Result := GetData(resturl, TConf.ServiceUsr, TConf.ServicePwd, ecode, emsg);
    if emsg <> '' then
      raise Exception.Create(emsg);
  end;
end;


initialization
  _crit := TCriticalSection.Create;
finalization
  FreeAndNil(_crit);
end.
