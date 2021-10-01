{$I Conf.inc}
unit UBase;
// Author: Ingmar Tammeväli www.stiigo.com
interface
uses UTypes, Classes, System.Generics.Collections,
  REST.JSON, Json, Data.DBXJSONReflect, Data.DbxJson;

const
  CTagFlagDataNotSaved = $FFFFFFFF;

const
  CCommonDateTimeTypes: array[0..7] of String = (
    'FRow_ts',
    'FChanged_at',
    'frow_ts',
    'fchanged_at',
    'FStart',
    'FStop',
    'fstart',
    'fstop');

type
  // {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
  // {$RTTI INHERIT METHODS([vcPublic, vcPublished]) PROPERTIES([vcPublic, vcPublished])}
  TBase = class(TObject)
  private
    // [JSONMarshalled(False)]
    // [JSONMarshalledAttribute(False)]
  protected
    [JSONMarshalled(False)]
    FTag: Integer;
    [JSONMarshalled(False)]
    FMiscData: Pointer;
    [JSONMarshalled(False)]
    FHash: String;
    FId: Integer;
    FUuid: NativeUInt;
    FRow_ts: TDatetime;
    FChanged_at: TDatetime;
    FChanged_by: Integer;
    FCreated_by: Integer;
    procedure MarshallDateTime(const AClass: TClass;const ADateTimeMarshaller: TJSONMarshal; const ADateFieldName: String); overload;
    procedure MarshallDateTime(const ADateTimeMarshaller: TJSONMarshal; const ADateFieldName: String); overload;
    class procedure UnMarshallDateTime(const AClass: TClass; const ADateTimeUnMarshaller: TJSONUnMarshal; const ADateFieldName: String);
  public
    property Id: Integer Read FId;
    property Tag: Integer Read FTag Write FTag;
    property MiscData: Pointer Read FMiscData Write FMiscData;
    property Hash: String Read FHash;
    property Uuid: NativeUInt Read FUuid; // Class -> PHP -> ret Class -> PHP
    property Row_ts: TDateTime Read FRow_ts Write FRow_ts;
    property Changed_by: Integer Read FChanged_by Write FChanged_by;
    property Changed_at: TDateTime Read FChanged_at Write FChanged_at;
    property Created_by: Integer Read FCreated_by Write FCreated_by;
    function IsAssigned: Boolean;
    procedure Validate; virtual;
    procedure Init; virtual;
    function DataChanged: Boolean; virtual;
    procedure Save(const AOnSaveData: TOnSaveData = nil); virtual;
    procedure Delete(const AOnDeleteData: TOnDeleteData = nil); virtual;
    procedure DeleteEx(const AId: TArray<Integer>; const AOnDeleteData: TOnDeleteData2 = nil); virtual;
    class function GetURI(const AAddCompDepFilter: Boolean = False): String;
    class function PostURI: String;
    class function JSONToObject(const AJson: String): TObject; virtual;
    class function JSONToObject2(const AJson: String): TObject; virtual;
    function ToJson: String; virtual;
    function ToJson2: String; virtual;
    procedure CalcHash; virtual;
    // Server resp.
    class function JSONRespToSingleDsObject(const AOnReadData: TOnReadData;
      AId: Integer; AFilter: TStringlist = nil): TBase; overload;
    class function JSONRespToSingleDsObject(const AJson: String): TBase; overload;
    class procedure JSONRespToDsObjects(const AJson: String; const AClassList: TObjectList<TBase>); virtual;
    constructor Create; virtual;
    destructor Destroy; override;
    {$IFDEF DEBUG}
    function BuildPHPClasses(var APHPClassName: String; const AExtMethodsPath: String = ''): String; virtual;
    {$ENDIF}
    procedure ResetId;
  end;

function _autocreated_header(): String;
// To save multiple same dataobjects at once
function MultiObjectToJson(const ABizObjects: TObjectList<TBase>): String;
function AssignJsonRPIDs(const AData: String; var ARetErrors: String): TStringlist;
function AssignJsonRPID(const AData: String; var ARetErrors: String): Integer;

implementation
uses
  {$IFDEF DEBUG}TypInfo, Rtti,{$ENDIF}
  UConf, SysUtils, StrUtils, DateUtils, UTools, UNotification,
  System.Hash;

function _autocreated_header(): String;
begin
  Result := '/* Auto-generated ' + DateTimeToStr(Now()) + ' by Ingmar'+ ' */';
end;

function MultiObjectToJson(const ABizObjects: TObjectList<TBase>): String;
begin
  Result := '[';
  if Assigned(ABizObjects) then
    for var i: Integer := 0 to ABizObjects.Count - 1 do
      Result := Result + IfThen(i > 0, ',') + TBase(ABizObjects[i]).ToJson;
  Result := Result + ']';
end;

function AssignJsonRPIDs(const AData: String; var ARetErrors: String): TStringlist;
var
  json: TJSonValue;
  jsonarr: TJSONArray;
  jsonobj: TJSONValue;
  uuid: NativeInt;
  id: Integer;
  base: TBase;
begin
  Result := nil;
  ARetErrors := '';
  json := TJsonObject.ParseJSONValue(AData);
  if Assigned(json) then
  try
    jsonarr := json as TJSONArray;
    Result := TStringList.Create;

    for jsonobj in jsonarr do
    begin
      uuid := jsonobj.GetValue<NativeInt>('uuid');
      id := jsonobj.GetValue<Integer>('id');
      ARetErrors := ARetErrors + #32 + jsonobj.GetValue<String>('err');
      if (uuid > 0) then
      begin
        // Ingmar; TODO safe pointer list !
        base := TBase(Pointer(uuid));
        if not base.IsAssigned  then
          base.FId := id;

        Result.AddObject(IntToStr(id), TObject(base));
      end;
    end;
  finally
    json.Free;
  end;
  ARetErrors := Trim(ARetErrors);
end;

function AssignJsonRPID(const AData: String; var ARetErrors: String): Integer;
var
  tmp: TStringList;
begin
  Result := 0;
  tmp := AssignJsonRPIDs(AData, ARetErrors);
  if Assigned(tmp) then
  try
    if tmp.Count > 0 then
      Result := StrToIntDef(tmp.Strings[0], 0);
  finally
    FreeAndNil(tmp);
  end;
end;

// -----------------------------------------------------------------------

procedure TBase.ResetId;
begin
  FId := 0;
end;


constructor TBase.Create;
begin
  inherited Create;
  FRow_ts := Now;
  FChanged_at := Now;
  FUuid := NativeUInt(Self);
end;

destructor TBase.Destroy;
begin
  inherited Destroy;
end;

class function TBase.GetURI;
begin
  Result := Trim(TConf.ServiceURL);
  if Result = '' then
    Exit;

  if Result[length(Result)] <> '/' then
    Result := Result + '/';

  Result := Result + 'get/'+ Self.ClassName.ToLower + '/';
  if AAddCompDepFilter then
    Result := Result
      + '?company_id=' + TConf.currCompanyId.ToString
      + '&department_id=' + TConf.currDepartmentId.ToString;
end;

class function TBase.PostURI: String;
begin
  Result := Trim(TConf.ServiceURL);
  if Result = '' then
    Exit;

  if Result[length(Result)] <> '/' then
    Result := Result + '/';
  Result := Result + 'save/';
end;

class function TBase.JSONRespToSingleDsObject(const AJson: String): TBase;
var
  clist: TObjectList<TBase>;
  i: Integer;
begin
  Result := nil;
  clist := TObjectList<TBase>.Create;
  clist.OwnsObjects := False;
  try
    JSONRespToDsObjects(AJson, clist);
    if clist.Count > 0 then
    begin
      Result := clist[0];
      for i := 1 to clist.Count - 1 do
        TBase(clist[i]).Free;
    end;
  finally
    FreeAndNil(clist);
  end;
end;

class function TBase.JSONRespToSingleDsObject(const AOnReadData: TOnReadData; AId: Integer; AFilter: TStringlist = nil): TBase;
var
  json, emsg: String;
begin
  Result := nil;
  if Assigned(AOnReadData) then
  begin
    json := AOnReadData(Self.ClassName, AId, AFilter, emsg);
    if emsg <> '' then
      raise Exception.Create(emsg);

    Result := JSONRespToSingleDsObject(json) as TBase;
  end;
end;

class procedure TBase.JSONRespToDsObjects(const AJson: String; const AClassList: TObjectList<TBase>);
var
  json: TJsonValue;
  jsonarr: TJsonArray;
  jsonobj: TJsonValue;
  base: TBase;
begin
  if Trim(AJson) = '' then
    Exit;

  Assert(Assigned(AClassList));
  AClassList.Clear;
  json := TJsonObject.ParseJSONValue(AJson);
  if not Assigned(json) then
    raise Exception.Create(AJson);

  base := nil;
  jsonarr := json as TJSONArray;
  try
    base := TBase.Create;
    for jsonobj in jsonarr do
    begin
      AClassList.Add(base.JSONToObject(jsonobj.ToJSON) as TBase);
    end;
  finally
    base.Free;
    json.Free;
  end;
end;

// class procedure TBase.DsObjectJSONResp(const AJson: String; const AClassList: TObjectList<TBase>);

function TBase.IsAssigned: Boolean;
begin
  Result := id > 0;
end;

procedure TBase.Validate;
begin
  //--
end;

procedure TBase.CalcHash;
begin
  FHash := System.Hash.THashMD5.GetHashString(Self.ToJson);
end;

procedure TBase.MarshallDateTime(const AClass: TClass; const ADateTimeMarshaller: TJSONMarshal; const ADateFieldName: String);
begin
  ADateTimeMarshaller.RegisterConverter(AClass, ADateFieldName,
      function(Data: TObject; Field: string): string
      var
        ctx: TRttiContext; date : TDateTime;
      begin
        date := ctx.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TDateTime>;
        Result := FormatDateTime('yyyy-mm-dd hh:nn:ss', date);
      end);
end;

procedure TBase.MarshallDateTime(const ADateTimeMarshaller: TJSONMarshal; const ADateFieldName: String);
begin
  ADateTimeMarshaller.RegisterConverter(Self.ClassType, ADateFieldName,
      function(Data: TObject; Field: string): string
      var
        ctx: TRttiContext; date : TDateTime;
      begin
        date := ctx.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TDateTime>;
        Result := FormatDateTime('yyyy-mm-dd hh:nn:ss', date);
      end);
end;

class procedure TBase.UnMarshallDateTime(const AClass: TClass; const ADateTimeUnMarshaller: TJSONUnMarshal; const ADateFieldName: String);
begin
  ADateTimeUnMarshaller.RegisterReverter(AClass, ADateFieldName,
      procedure(Data: TObject; Field: string; Arg: string)
      var
        ctx: TRttiContext;
        datetime: TDateTime;
      begin
        datetime := 0;
        if Arg <> CMYSQLEmptyDate then
        begin
          TryEncodeDateTime(StrToIntDef(Copy(Arg, 1, 4), 0),
                                     StrToIntDef(Copy(Arg, 6, 2), 0),
                                     StrToIntDef(Copy(Arg, 9, 2), 0),
                                     StrToIntDef(Copy(Arg, 12, 2), 0),
                                     StrToIntDef(Copy(Arg, 15, 2), 0),
                                     StrToIntDef(Copy(Arg, 18, 2), 0), 0,
                                     datetime);
        end;
        ctx.GetType(Data.ClassType).GetField(Field).SetValue(Data, datetime);
      end);
end;

procedure TBase.Init;
begin
  Self.CalcHash;
end;

function TBase.DataChanged: Boolean;
var
  pcurrhash: String;
begin
  pcurrhash := FHash;
  try
    Self.CalcHash;
    Result := FHash <> pcurrhash;
  finally
    FHash := pcurrhash;
  end;
end;

procedure TBase.Save;
var
  rez: TStringList;
  emsg: String;
begin
  Validate;
  emsg := '';
  rez := nil;
  if Assigned(AOnSaveData) then
  try
    rez := AOnSaveData(Self, emsg);
    if emsg.Length > 0 then
      raise Exception.Create(emsg);

    // for var i: Integer := 0 to rez.Count - 1 do
    // if Assigned(rez.Objects[i]) and rez.Objects[i].InheritsFrom(TBase) then
    // begin
    //  TBase(rez.Objects[i]).FId := StrToIntDef(rez.Strings[i], 0);
    // end;
  finally
    FreeAndNil(rez);
  end;
end;

procedure TBase.Delete(const AOnDeleteData: TOnDeleteData);
begin
  if Assigned(AOnDeleteData) then
    AOnDeleteData(Self);
end;

procedure TBase.DeleteEx(const AId: TArray<Integer>; const AOnDeleteData: TOnDeleteData2 = nil);
var
  emsg: String;
begin
  if Assigned(AOnDeleteData) then
  begin
    AOnDeleteData(Self, AId, emsg);
    if emsg <> '' then
      raise Exception.Create(_t('Delete') + ': ' + emsg);
  end;
end;

class function TBase.JSONToObject(const AJson: String): TObject;
var
  unm: TJSONUnMarshal;
  json: TJSONValue;
  dtfields: String;
begin
  unm := TJSONUnMarshal.Create;
  json := nil;
  try
    for dtfields in CCommonDateTimeTypes do
      UnMarshallDateTime(TBase, unm, dtfields);
    json := TJSONObject.ParseJSONValue(AJson);
    Result := unm.Unmarshal(json) as TBase;
    TBase(Result).Init();
  finally
    FreeAndNil(unm);
    json.Free;
  end;
end;

class function TBase.JSONToObject2(const AJson: String): TObject;
begin
  Result := TJson.JsonToObject<TBase>(AJson);
  TBase(Result).CalcHash();
end;

function TBase.ToJson: String;
var
  m: TJSONMarshal;
  v: TJSONValue;
  dtfields: String;
begin
  m := TJSONMarshal.Create(TJSONConverter.Create);
  for dtfields in CCommonDateTimeTypes do
    MarshallDateTime(m, dtfields);
  v := m.Marshal(Self);
  try
    Result := v.ToString;
  finally
    FreeAndNil(v);
    FreeAndNil(m);
  end;
end;

function TBase.ToJson2: String;
begin
  // Teeb lihtsalt JSONI klassist, aga ei lisa klassi infot !
  Result := TJson.ObjectToJsonString(TObject(Self));
end;

{$IFDEF DEBUG}
function TBase.BuildPHPClasses;
var
  phpclass, phpconstr, extmethod: TStringList;
  currclass, propname,
  proptype, extclass: String;
  ctx : TRttiContext;
  rt : TRttiType;
  prop : TRttiProperty;
{$ENDIF}
begin
{$IFDEF DEBUG}
  Result := '';

  APHPClassName := Copy(Self.ClassName, 2, 64);
  currclass := APHPClassName;

  ForceDirectories(CPhpRootDir);
  phpclass := TStringList.Create;
  phpconstr := TStringList.Create;
  phpclass.Add('<?php');
  phpclass.Add('');
  phpclass.Add(_autocreated_header());
  phpclass.Add('');

  phpclass.Add('class ' + currclass + ' extends Base{');
  phpconstr.Add(#09'function __construct($datalayer = null) {');

  ctx := TRttiContext.Create();
  try
      rt := ctx.GetType(Self.ClassType);
      for prop in rt.GetProperties() do
      if prop.PropertyType.TypeKind in [tkInteger, tkChar, tkEnumeration,
        tkFloat, tkString, tkWChar, tkInt64, tkUString] then
      begin
        propname := prop.name.ToLower;
        proptype := prop.PropertyType.Name.ToLower;

        if ((propname = 'tag') or (propname = 'miscdata')) then
          continue;

        if proptype = 'tdatetime' then
        begin
           phpconstr.Add(#09#09 + '$this->' + propname + ' = (string)"' + FormatDateTime('yyyy-mm-dd', Now()) + '";');
        end
        else // 07.02.2021 Ingmar
        //if Assigned(prop.PropertyType.BaseType) and (prop.PropertyType.BaseType = TypeInfo(Boolean)) then
        if proptype = 'boolean' then
           phpconstr.Add(#09#09 + '$this->' + propname + ' = (bool)false;')
        // else
        // if (prop.PropertyType.BaseType = TypeInfo(TDateTime)) then
        else
        if prop.PropertyType.TypeKind in [tkInteger, tkInt64] then
           phpconstr.Add(#09#09 + '$this->' + propname + ' = (int)0;')
        else
        if prop.PropertyType.TypeKind in [tkFloat] then
          phpconstr.Add(#09#09 + '$this->' + propname + ' = (double)0.00;')
        else
          phpconstr.Add(#09#09 + '$this->' + propname + ' = (string)"";');

        phpclass.Add(#09 + 'public $' + propname + ';');

        {
          if not prop.IsWritable then continue;
          case prop.PropertyType.TypeKind of
              tkEnumeration : value := false;
              tkUString :      value := '';
              else continue;
          end;
          prop.SetValue(obj, value);
        }
      end;
  finally
      ctx.Free();
  end;

  // Teeme php originaal andmetüüpidest snapshoti,et salvestamisel saaksime täpset tüüpi edastada
  phpconstr.Add(#09#09'$this->cssnapshot = get_object_vars($this);');
  phpconstr.Add(#09#09'parent::__construct($datalayer);');

  phpconstr.Add(#09'}');
  phpclass.Add(phpconstr.Text);
  phpclass.Add('');

  // Basic
  phpclass.Add(#09'public function Save() {');
  phpclass.Add(#09#09'return parent::Save();');
  phpclass.Add(#09'}');
  phpclass.Add('');

  phpclass.Add(#09'public static function __tableName() {');
  phpclass.Add(#09#09'return "' + currclass.toLower+ '";');
	phpclass.Add(#09'}');
  phpclass.Add('');


  extclass := AExtMethodsPath + currclass.toLower + '.inc.class.txt'; // Nb txt !
  if FileExists(extclass) then
  begin
    extmethod := TStringList.Create;
    extmethod.LoadFromFile(extclass);
    phpclass.Add('');
    try
      for var line in extmethod do
      begin
        phpclass.Add(line);
      end;
    finally
      FreeAndNil(extmethod);
    end;
  end;

  phpclass.Add('}');
  phpclass.Add('?>');

  Result := CPhpRootDir + currclass.toLower + '.inc.class.php';
  phpclass.SaveToFile(Result);
  phpclass.Free;
  phpconstr.Free;
end;
{$ENDIF}


end.
