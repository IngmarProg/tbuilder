{$I Conf.inc}
unit UProfiles;
// Author: Ingmar Tammeväli www.stiigo.com

interface
uses
  UBase, UTypes, Json, DbxJson, DbxJsonReflect, System.Generics.Collections;

type
  TProfileType = (_CTimelineProfile, _CWorkClothesProfile, _COccupationProfile, _CWorkProfile);

//type
//  TProfileAttrType = (_CInt = 0, _CDouble = 1, _CDate = 2, _CStr = 3);

const
  TProfileTypeStr: Array[TProfileType] of String = ('C', 'T', 'O', 'W');

type
  TProfileItemType = (_CProfItemAsJob);

const
  TProfileItemTypeStr: Array[TProfileItemType] of String = ('J');

const
  TProfileItem_FlagBufferedUIItem = 1; // 2 ^ 0


type
  TProfiles = class;
  TProfileItem = class;
  TProfileItemAttr = class;
  TProfileItemAttrDef = class;
  TProfileItemValue = class;
  TProfileItems = Array of TProfileItem;
  TProfileItemAttrs = Array of TProfileItemAttr;
  TProfileItemAttrsDefs = Array of TProfileItemAttrDef;
  TProfileItemValues = Array of TProfileItemValue;

  TProfilesList = TObjectList<TProfiles>;

  TProfiles = class(TBase)
  protected
    FProfile_code: String;
    FProfile_name: String;
    FProfile_descr: String;
    FProfile_type: String; // tööriiete profiil, ajavõtu tööde profiil, ameti profiil, tööde nimetus
    FPObject_id: Integer;
    FEmployee_group_clf_id: Integer;
    FDepartment_Id: Integer;
    FCompany_Id: Integer;
    FActive: Boolean;
    FIs_Template: Boolean;
    FProfileItems: TProfileItems;
    procedure SetProfileType(const v: String);
    function GetProfileItems: TProfileItems;
    procedure SetProfileItems(const v: TProfileItems);
  public
    procedure Init; override;
    constructor Create; override;
    destructor Destroy; override;
    function ToJson: String; override;
    class function JSONToObject(const AJson: String): TObject; override;
    class procedure JSONRespToDsObjects(const AJson: String; const AClassList: TObjectList<TBase>); override;
    // [JSONMarshalled(True)]
    // [JSONName('object_id')]
    // property Id;
    property Profile_code: String Read FProfile_code Write FProfile_code;
    property Profile_name: String Read FProfile_name Write FProfile_name;
    property Profile_descr: String Read FProfile_descr Write FProfile_descr;
    property Profile_type: String Read FProfile_type Write SetProfileType;
    property PObject_id: Integer Read FPObject_id Write FPObject_id;
    property Is_Template: Boolean Read FIs_Template Write FIs_Template;
    property Employee_group_clf_id: Integer Read FEmployee_group_clf_id Write FEmployee_group_clf_id;
    property Department_Id: Integer Read FDepartment_Id Write FDepartment_Id;
    property Company_Id: Integer Read FCompany_Id Write FCompany_Id;
    property Active: Boolean Read FActive Write FActive;
    property Profile_items: TProfileItems Read GetProfileItems Write SetProfileItems;
    function addProfileItem(): TProfileItem;
    procedure removeProfileItem(var AItem: TProfileItem);
    function profileItemExists(const AItemName: String): Boolean;
    function FindProfileItem(const AItemId: Integer): TProfileItem;
    function GetProfileCreatorName: String;
    // TODO return query
    // procedure LoadProfileAssociations; // profile items -> attributes
  end;

  TProfileItem = class(TBase)
  protected
    [JSONMarshalled(False)]
    FParent: TProfiles;
    FProfile_id: Integer;
    FFlags: Integer;
    FOrderNr: Integer;
    FParent_id: Integer;
    FLevel_nr: Integer;
    FItem_type: String;
    FItem_name: String;
    FItem_descr: String;
    FActive: Boolean;
    FRelated_Item_Id: Integer;
    FProfileItemAttrs: TProfileItemAttrs;
    FProfileItemValues: TProfileItemValues;
    function GetProfileItemAttrs: TProfileItemAttrs;
    procedure SetProfileItemAttrs(const v: TProfileItemAttrs);
    function GetProfileItemValues: TProfileItemValues;
    procedure SetProfileItemValues(const v: TProfileItemValues);
  public
    property Parent: TProfiles Read FParent;
    property Flags: Integer Read FFlags Write FFlags;
    property Profile_id: Integer Read FProfile_id;
    property OrderNr: Integer Read FOrderNr Write FOrderNr;
    property Parent_id: Integer Read FParent_id Write FParent_id;
    property Level_nr: Integer Read FLevel_nr Write FLevel_nr;
    property Item_type: String Read FItem_type Write FItem_type;
    property Item_name: String Read FItem_name Write FItem_name;
    property Item_descr: String Read FItem_descr Write FItem_descr;
    property Related_Item_Id: Integer Read FRelated_Item_Id Write FRelated_Item_Id;
    property Active: Boolean Read FActive Write FActive;
    property Profile_item_attrs: TProfileItemAttrs Read GetProfileItemAttrs Write SetProfileItemAttrs;
    property Profile_item_values: TProfileItemValues Read GetProfileItemValues Write SetProfileItemValues;
    procedure Delete(const AOnDeleteData: TOnDeleteData = nil); override;
    function addProfileAttr(): TProfileItemAttr;
    function addProfileItemValue(): TProfileItemValue;
    constructor Create; override;
    destructor Destroy; override;
  end;

  TProfileItemValue = class(TBase)
  protected
    FProfile_Id: Integer;
    FProfileItem_Id: Integer;
    FEmployee_Id: Integer;
    FStart: TDatetime;
    FStop: TDateTime;
    FRelated_item_id: Integer;
    FRelated_item_name: String;
    FOrderNr: Integer;
    FCommonGuid: String;
    // FPictureId: Integer;
    // FPictureId2: Integer;
    // FPictureHash2: String;
    // FPictureId3: Integer;
    // FPictureHash3: String;
    FComments: String;
    FAttrDefId: Integer;
    FAttrDefVal: String;
    FAttrDefId2: Integer;
    FAttrDefVal2: String;
    FAttrDefId3: Integer;
    FAttrDefVal3: String;
    FValuePath: String;
  public
    const CShortTypeFileIdf = 'wkp';
  public
    property Profile_Id: Integer Read FProfile_Id Write FProfile_Id;
    property ProfileItem_Id: Integer Read FProfileItem_Id Write FProfileItem_Id;
    property Employee_Id: Integer Read FEmployee_Id Write FEmployee_Id;
    property Start: TDatetime Read FStart Write FStart;
    property Stop: TDateTime Read FStop Write FStop;
    property Related_item_id: Integer Read FRelated_item_id Write FRelated_item_id;
    property Related_item_name: String Read FRelated_item_name Write FRelated_item_name;
    property OrderNr: Integer Read FOrderNr Write FOrderNr;
    // property PictureId: Integer Read FPictureId Write FPictureId;
    // kasutatakse pildi nime genereerimisel, kui ka tuvastamisel kas tegevus lõpetatud
    property CommonGuid: String Read FCommonGuid Write FCommonGuid;
    // property PictureId2: Integer Read FPictureId2 Write FPictureId2;
    // property PictureHash2: String Read FPictureHash2 Write FPictureHash2;
    // property PictureId3: Integer Read FPictureId3 Write FPictureId3;
    // property PictureHash3: String Read FPictureHash3 Write FPictureHash3;
    property Comments: String Read FComments Write FComments;
    property AttrDefId: Integer Read FAttrDefId Write FAttrDefId;
    property AttrDefVal: String Read FAttrDefVal Write FAttrDefVal;
    property AttrDefId2: Integer Read FAttrDefId2 Write FAttrDefId2;
    property AttrDefVal2: String Read FAttrDefVal2 Write FAttrDefVal2;
    property AttrDefId3: Integer Read FAttrDefId3 Write FAttrDefId3;
    property AttrDefVal3: String Read FAttrDefVal3 Write FAttrDefVal3;
    property ValuePath: String Read FValuePath Write FValuePath;
    procedure Init; override;
    procedure Reset; virtual;
    procedure AssignId(const AId: Integer);
    constructor Create; override;
  end;


  TProfileItemAttr = class(TBase)
  protected
    [JSONMarshalled(False)]
    FParent: TProfileItem;
    FProfileItem_Id: Integer;
    FOrderNr: Integer;
    FValueRequired: Boolean;
    FTimeMsRequired: Boolean;
    FTimeMs2Required: Boolean;
    FAddAmount: Boolean;
    FAmountRequired: Boolean;
    FSubItemRequired: Boolean;
    FPrevItemRequired: Boolean;
    FAddcomments: Boolean;
    FCommentsRequired: Boolean;
    FAddPicture: Boolean;
    FPictureRequired: Boolean;
    FProfileItemAttrsDefs: TProfileItemAttrsDefs;
    function GetProfileItemAttrDefs: TProfileItemAttrsDefs;
    procedure SetProfileItemAttrDefs(const v: TProfileItemAttrsDefs);
  public
    property Parent: TProfileItem read FParent;
    property ProfileItem_Id: Integer Read FProfileItem_Id  Write FProfileItem_Id;
    property OrderNr: Integer Read FOrderNr Write FOrderNr;
    property ValueRequired: Boolean Read FValueRequired Write FValueRequired;
    property TimeMsRequired: Boolean Read FTimeMsRequired Write FTimeMsRequired; // lisa start on start/stop nupp
    property TimeMs2Required: Boolean Read FTimeMs2Required Write FTimeMs2Required; // lisatakse tunnid ja min käsitsi
    property AddAmount: Boolean Read FAddAmount Write FAddAmount;
    property AmountRequired: Boolean Read FAmountRequired Write FAmountRequired;
    property SubItemRequired: Boolean Read FSubItemRequired Write FSubItemRequired;
    property PrevItemRequired: Boolean Read FPrevItemRequired Write FPrevItemRequired;
    property Addcomments: Boolean Read FAddcomments Write FAddcomments;
    property CommentsRequired: Boolean Read FCommentsRequired Write FCommentsRequired;
    property AddPicture: Boolean Read FAddPicture Write FAddPicture;
    property PictureRequired: Boolean Read FPictureRequired Write FPictureRequired;
    property Profile_item_attrs_def: TProfileItemAttrsDefs Read GetProfileItemAttrDefs Write SetProfileItemAttrDefs;
    function addProfileAttrDef(): TProfileItemAttrDef;
    constructor Create; override;
    destructor Destroy; override;
  end;

  TProfileItemAttrDef = class(TBase)
  protected
    [JSONMarshalled(False)]
    FParent: TProfileItemAttr;
    FProfileItemAttrId: Integer;
    // FEmployeeId: Integer;
    FOrderNr: Integer;
    // FStart: TDateTime;
    // FStop: TDateTime;
    // FAttrName1: String;
    // FAttrType1: TProfileAttrType;
    FAttrName: String;
    FAttrValue: String;
    // FAttrName2: String;
    // FAttrType2: TProfileAttrType;
    // FAttrValue2: String;
    // FComments: String;
    // FPictureId1: Integer;
    // FPictureId2: Integer;
    // FPictureHash1: String;
    // FPictureHash2: String;
  public
    property Parent: TProfileItemAttr Read FParent;
    property ProfileItemAttrId: Integer Read FProfileItemAttrId;
    // property EmployeeId: Integer Read FEmployeeId Write FEmployeeId;
    property OrderNr: Integer Read FOrderNr Write FOrderNr;
    // property Start: TDateTime Read FStart Write FStart;
    // property Stop: TDateTime Read FStop Write FStop;
    property AttrName: String Read FAttrName Write FAttrName;
    // property AttrType1: TProfileAttrType Read FAttrType1 Write FAttrType1;
    property AttrValue: String Read FAttrValue Write FAttrValue;
    // property AttrName2: String Read FAttrName1 Write FAttrName2;
    //property AttrType2: TProfileAttrType Read FAttrType2 Write FAttrType2;
    // property AttrValue2: String Read FAttrValue1 Write FAttrValue2;
    // property Comments: String Read FComments Write FComments;
    // property PictureId1: Integer Read FPictureId1 Write FPictureId1;
    // property PictureHash1: String Read FPictureHash1 Write FPictureHash1;
    // property PictureId2: Integer Read FPictureId2 Write FPictureId2;
    // property PictureHash2: String Read FPictureHash2 Write FPictureHash2;
  end;

implementation
uses System.IOUtils, System.SysUtils, System.Generics.Defaults, UEmployee, UTools;

{ TProfiles }

procedure TProfiles.Init;
begin
  inherited Init;
  for var profitem in Self.FProfileItems do
    begin
      profitem.FParent := Self;
      for var profattr in profitem.FProfileItemAttrs do
      begin
        profattr.FParent := profitem;
        for var profdef in profattr.FProfileItemAttrsDefs do
          profdef.FParent := profattr;
      end;
    end;
end;

constructor TProfiles.Create;
begin
  inherited Create;
  Active := True;
end;

destructor TProfiles.Destroy;
begin
  Profile_items := nil;
  inherited Destroy;
end;

{
 TArray.Sort<TMyEvent>(Events, TDelegatedComparer<TMyEvent>.Construct(
    function(const Left, Right: TMyEvent): Integer
    begin
      if Left.EventId > Right.EventId then Exit(1);
      if Left.EventId < Right.EventId then Exit(-1);
      Result:= 0;
    end
  ));
}
// TODO binarysearch
function TProfiles.FindProfileItem(const AItemId: Integer): TProfileItem;
const
  CMaxItems = 1024;
var
  tmp: TProfileItem;
  srcindex: Integer;
  ok: Boolean;
begin
  srcindex := -1;
  Result := nil;
  // kui väike nimistu, siis tavaline lineaarne otsing on täiesti piisav
  if length(Profile_items) < CMaxItems then
  begin
    for var item in Profile_items do
      if item.id = AItemId then
      begin
        Exit(item);
      end;
  end
  else
  begin
    tmp := TProfileItem.Create;
    tmp.FId:= AItemId;
    try
      ok := TArray.BinarySearch<TProfileItem>(Profile_Items,  tmp, srcindex,
        TDelegatedComparer<TProfileItem>.Construct(
        function(const Left, Right: TProfileItem): Integer
        begin
          if Left.FId > Right.FId then
            Exit(1);
          if Left.FId < Right.FId then
            Exit(-1);
          Result:= 0;
        end
      ));

      if ok then
        Result:= Profile_Items[srcindex];
    finally
      FreeAndNil(tmp);
    end;
  end;
end;

function TProfiles.GetProfileCreatorName: String;
begin
  Result := _getCachedEmployeeData(Created_by, _ced_name);
end;

procedure TProfiles.SetProfileType(const v: String);
begin
  FProfile_type := v;
end;

function TProfiles.GetProfileItems: TProfileItems;
begin
  Result := FProfileItems;
end;

procedure TProfiles.SetProfileItems(const v: TProfileItems);
var
  i: Integer;
begin
  for i := Low(FProfileItems) to High(FProfileItems) do
    if Assigned(FProfileItems[i]) then
    begin
      FProfileItems[i].Free;
      FProfileItems[i] := nil;
    end;

  FProfileItems := nil;
  FProfileItems := v;
end;

function TProfiles.ToJson: String;
var
  m: TJSONMarshal;
  v: TJSONValue;
  dtfields: String;
begin
  m := TJSONMarshal.Create(TJSONConverter.Create);
  v := nil;
  for dtfields in CCommonDateTimeTypes do
    MarshallDateTime(m, dtfields);

  for dtfields in CCommonDateTimeTypes do
    MarshallDateTime(TProfileItem, m, dtfields);

  for dtfields in CCommonDateTimeTypes do
    MarshallDateTime(TProfileItemValue, m, dtfields);

  for dtfields in CCommonDateTimeTypes do
    MarshallDateTime(TProfileItemAttr, m, dtfields);

  for dtfields in CCommonDateTimeTypes do
    MarshallDateTime(TProfileItemAttrDef, m, dtfields);

  try
    m.RegisterConverter(TProfiles, 'FProfileItems',
      function(Data: TObject; Field: String): TListOfObjects
      var
        obj: TProfileItem;
        i: Integer;
      begin
        SetLength(Result, Length(TProfiles(Data).FProfileItems));
        i := Low(Result);
        for obj in TProfiles(Data).FProfileItems do
        begin

          Result[i] := obj;
          Inc(i);
        end;
      end);

    m.RegisterConverter(TProfileItem, 'FProfileItemValues',
      function(Data: TObject; Field: String): TListOfObjects
      var
        obj: TProfileItemValue;
        i: Integer;
      begin
        SetLength(Result, Length(TProfileItem(Data).FProfileItemValues));
        i := Low(Result);
        for obj in TProfileItem(Data).FProfileItemValues do
        begin
          obj.MarshallDateTime(m, dtfields);
          Result[i] := obj;
          Inc(i);
        end;
      end);

    m.RegisterConverter(TProfileItem, 'FProfileItemAttrs',
      function(Data: TObject; Field: String): TListOfObjects
      var
        obj: TProfileItemAttr;
        i: Integer;
      begin
        SetLength(Result, Length(TProfileItem(Data).FProfileItemAttrs));
        i := Low(Result);
        for obj in TProfileItem(Data).FProfileItemAttrs do
        begin
          obj.MarshallDateTime(m, dtfields);
          Result[i] := obj;
          Inc(i);
        end;
      end);

    m.RegisterConverter(TProfileItemAttr, 'FProfileItemAttrsDefs',
      function(Data: TObject; Field: String): TListOfObjects
      var
        obj: TProfileItemAttrDef;
        i: Integer;
      begin
        SetLength(Result, Length(TProfileItemAttr(Data).FProfileItemAttrsDefs));
        i := Low(Result);
        for obj in TProfileItemAttr(Data).FProfileItemAttrsDefs do
        begin
          obj.MarshallDateTime(m, dtfields);
          Result[i] := obj;
          Inc(i);
        end;
      end);

    v := m.Marshal(Self);
    Result := v.ToString;
  finally
    FreeAndNil(v);
    FreeAndNil(m);
  end;
end;

class procedure TProfiles.JSONRespToDsObjects(const AJson: String; const AClassList: TObjectList<TBase>);
var
  json: TJsonValue;
  jsonarr: TJsonArray;
  jsonobj: TJsonValue;
  profile: TProfiles;
begin
  if Trim(AJson) = '' then
    Exit;

  Assert(Assigned(AClassList));
  AClassList.Clear;
  json := TJsonObject.ParseJSONValue(AJson);
  if not Assigned(json) then
    raise Exception.Create(AJson);

  profile := nil;
  jsonarr := json as TJSONArray;
  try
    profile := TProfiles.Create;
    for jsonobj in jsonarr do
    begin
      AClassList.Add(profile.JSONToObject(jsonobj.ToJSON) as TProfiles);
    end;
  finally
    profile.Free;
    json.Free;
  end;
end;

class function TProfiles.JSONToObject(const AJson: String): TObject;
var
  unm: TJSONUnMarshal;
  dtfields: String;
begin
  unm := TJSONUnMarshal.Create;
  try
    unm.RegisterReverter(TProfiles, 'FProfileItems',
      procedure(Data: TObject; Field: String; Args: TListOfObjects)
      var
        i: Integer;
        obj: TObject;
      begin
        SetLength(TProfiles(Data).FProfileItems, Length(Args));
        i := Low(TProfiles(Data).FProfileItems);
        for obj in Args do
        begin
          TProfiles(Data).FProfileItems[i] := TProfileItem(obj);
          TProfileItem(obj).Init();
          Inc(i);
        end
      end);

    unm.RegisterReverter(TProfileItem, 'FProfileItemValues',
      procedure(Data: TObject; Field: String; Args: TListOfObjects)
      var
        i: Integer;
        obj: TObject;
      begin
        SetLength(TProfileItem(Data).FProfileItemValues, Length(Args));
        i := Low(TProfileItem(Data).FProfileItemValues);
        for obj in Args do
        begin
          TProfileItem(Data).FProfileItemValues[i] := TProfileItemValue(obj);
          TProfileItemValue(obj).Init();
          Inc(i);
        end
      end);

    unm.RegisterReverter(TProfileItem, 'FProfileItemAttrs',
      procedure(Data: TObject; Field: String; Args: TListOfObjects)
      var
        i: Integer;
        obj: TObject;
      begin
        SetLength(TProfileItem(Data).FProfileItemAttrs, Length(Args));
        i := Low(TProfileItem(Data).FProfileItemAttrs);
        for obj in Args do
        begin
          TProfileItem(Data).FProfileItemAttrs[i] := TProfileItemAttr(obj);
          TProfileItemAttr(obj).Init();
          Inc(i);
        end
      end);

    unm.RegisterReverter(TProfileItemAttr, 'FProfileItemAttrsDefs',
      procedure(Data: TObject; Field: String; Args: TListOfObjects)
      var
        i: Integer;
        obj: TObject;
      begin
        SetLength(TProfileItemAttr(Data).FProfileItemAttrsDefs, Length(Args));
        i := Low(TProfileItemAttr(Data).FProfileItemAttrsDefs);
        for obj in Args do
        begin
          TProfileItemAttr(Data).FProfileItemAttrsDefs[i] := TProfileItemAttrDef(obj);
          TProfileItemAttr(obj).Init();
          Inc(i);
        end
      end);

    for dtfields in CCommonDateTimeTypes do
      TBase.UnMarshallDateTime(TProfiles, unm, dtfields);

    for dtfields in CCommonDateTimeTypes do
      TBase.UnMarshallDateTime(TProfileItem, unm, dtfields);

    for dtfields in CCommonDateTimeTypes do
      TBase.UnMarshallDateTime(TProfileItemAttr, unm, dtfields);

    for dtfields in CCommonDateTimeTypes do
      TBase.UnMarshallDateTime(TProfileItemValue, unm, dtfields);

    for dtfields in CCommonDateTimeTypes do
      TBase.UnMarshallDateTime(TProfileItemAttrDef, unm, dtfields);

    Result := unm.Unmarshal(TJSONObject.ParseJSONValue(AJson)) as TProfiles;
    // Arvutame hashid üle
    TProfiles(Result).Init();
    for var csobj in TProfiles(Result).FProfileItems do
    begin
      csobj.Init();
      for var csobj2 in csobj.Profile_item_attrs do
      begin
        csobj2.Init();
        for var csobj3 in csobj2.Profile_item_attrs_def do
          csobj3.Init();
      end;

      for var csobj5 in csobj.Profile_item_values do
        csobj5.Init();
    end;

  finally
    FreeAndNil(unm);
  end;
end;

function TProfiles.addProfileItem(): TProfileItem;
var
  ordernr: Integer;
begin
  ordernr := 0;
  Result := TProfileItem.Create;
  Result.FParent := Self;
  Result.FProfile_id := Self.Id;
  SetLength(FProfileItems, length(FProfileItems) + 1);
  FProfileItems[High(FProfileItems)] := Result;
  for var i: Integer := Low(FProfileItems) to High(FProfileItems) do
    if Abs(FProfileItems[i].FOrderNr) > ordernr then
    begin
      ordernr := Abs(FProfileItems[i].OrderNr);
    end;
  Result.FOrderNr := ordernr + 1;
end;

// TODO array helper
procedure TProfiles.removeProfileItem(var AItem: TProfileItem);
begin
  if not Assigned(AItem) then
    Exit;
  AItem.FParent := nil;
  for var i: Integer := Low(FProfileItems) to High(FProfileItems) do
    if FProfileItems[i] = AItem then
    begin
      for var j: Integer := i to High(FProfileItems) - 1 do
      begin
        FProfileItems[j] := FProfileItems[j + 1];
      end;
      Break;
    end;
  if length(FProfileItems) > 0 then
  begin
    SetLength(FProfileItems, length(FProfileItems) - 1);
  end;
  FreeAndNil(AItem);
end;

function TProfiles.profileItemExists(const AItemName: String): Boolean;
begin
  Result := False; // TODO check !
end;

{ TProfileItem }

procedure TProfileItem.Delete(const AOnDeleteData: TOnDeleteData = nil);
var
  ditem: TProfileItem;
begin
  if Assigned(Parent) then
  begin
    ditem := Self;
    Parent.removeProfileItem(ditem);
    for var profattr in FProfileItemAttrs do
    begin
      for var profdef in profattr.FProfileItemAttrsDefs do
        profdef.Delete(AOnDeleteData);

      profattr.Delete(AOnDeleteData);
    end;
  end;
  inherited Delete(AOnDeleteData);
end;

constructor TProfileItem.Create;
begin
  inherited Create;
  Item_type := TProfileItemTypeStr[_CProfItemAsJob];
  Active := True;
end;

destructor TProfileItem.Destroy;
begin
  Profile_item_attrs := nil;
  inherited Destroy;
end;

function TProfileItem.addProfileAttr(): TProfileItemAttr;
var
  ordernr: Integer;
begin
  ordernr := 0;
  Result := TProfileItemAttr.Create;
  Result.FProfileItem_Id := Self.Id;
  SetLength(FProfileItemAttrs, length(FProfileItemAttrs) + 1);
  FProfileItemAttrs[High(FProfileItemAttrs)] := Result;
  for var i: Integer := Low(FProfileItemAttrs) to High(FProfileItemAttrs) do
    if FProfileItemAttrs[i].FOrderNr > ordernr then
    begin
      ordernr := FProfileItemAttrs[i].OrderNr;
    end;

  Result.FOrderNr := ordernr + 1;
end;

function TProfileItem.addProfileItemValue(): TProfileItemValue;
var
  ordernr: Integer;
begin
  ordernr := 0;
  Result := TProfileItemValue.Create;
  Result.FProfileItem_Id := Self.Id;
  Result.FProfile_Id := Self.Profile_id;
  SetLength(FProfileItemValues, length(FProfileItemValues) + 1);
  FProfileItemValues[High(FProfileItemValues)] := Result;
  for var i: Integer := Low(FProfileItemValues) to High(FProfileItemValues) do
    if FProfileItemValues[i].FOrderNr > ordernr then
    begin
      ordernr := FProfileItemValues[i].OrderNr;
    end;

  Result.FOrderNr := ordernr + 1;
end;

function TProfileItem.GetProfileItemValues: TProfileItemValues;
begin
  Result := FProfileItemValues;
end;

procedure TProfileItem.SetProfileItemValues(const v: TProfileItemValues);
var
  i: Integer;
begin
  for i := Low(FProfileItemValues) to High(FProfileItemValues) do
    if Assigned(FProfileItemValues[i]) then
    begin
      FProfileItemValues[i].Free;
      FProfileItemValues[i] := nil;
    end;

  FProfileItemValues := nil;
  FProfileItemValues := v;
end;

function TProfileItem.GetProfileItemAttrs: TProfileItemAttrs;
begin
  Result := FProfileItemAttrs;
end;

procedure TProfileItem.SetProfileItemAttrs(const v: TProfileItemAttrs);
var
  i: Integer;
begin
  for i := Low(FProfileItemAttrs) to High(FProfileItemAttrs) do
    if Assigned(FProfileItemAttrs[i]) then
    begin
      FProfileItemAttrs[i].Free;
      FProfileItemAttrs[i] := nil;
    end;

  FProfileItemAttrs := nil;
  FProfileItemAttrs := v;
end;

{ TProfileItemValue }

constructor TProfileItemValue.Create;
begin
  inherited Create;
  Init;
end;

procedure TProfileItemValue.Init;
begin
  if FCommonGuid= '' then
    FCommonGuid := System.IOUtils.TPath.GetGUIDFileName;
  inherited Init;
end;

procedure TProfileItemValue.Reset;
begin
  FStart := Now;//  UTools.GenerateFutureDatetime;
  FStop := FStart;
  // profile_id
  // profile_item_id
  FRelated_item_id := 0;
  FRelated_item_name := '';
  FOrderNr := 0;
  // FPictureCommonId := 0;
  // FPictureCommonHash := '';
  FComments := '';
  FAttrDefId := 0;
  FAttrDefVal := '';
  FAttrDefId2 := 0;
  FAttrDefVal2 := '';
  FAttrDefId3 := 0;
  FAttrDefVal3 := '';
  //FPictureCommonHash := System.IOUtils.TPath.GetGUIDFileName;
end;

procedure TProfileItemValue.AssignId(const AId: Integer);
begin
  FId := AId;
end;

{ TProfileItemAttr }

constructor TProfileItemAttr.Create;
begin
  inherited Create;
end;

destructor TProfileItemAttr.Destroy;
begin
  Profile_item_attrs_def := nil;
  inherited Destroy;
end;

function TProfileItemAttr.GetProfileItemAttrDefs: TProfileItemAttrsDefs;
begin
  Result := FProfileItemAttrsDefs;
end;

procedure TProfileItemAttr.SetProfileItemAttrDefs(const v: TProfileItemAttrsDefs);
var
  i: Integer;
begin
  for i := Low(FProfileItemAttrsDefs) to High(FProfileItemAttrsDefs) do
    if Assigned(FProfileItemAttrsDefs[i]) then
    begin
      FProfileItemAttrsDefs[i].Free;
      FProfileItemAttrsDefs[i] := nil;
    end;

  FProfileItemAttrsDefs := nil;
  FProfileItemAttrsDefs := v;
end;

function TProfileItemAttr.addProfileAttrDef(): TProfileItemAttrDef;
var
  ordernr: Integer;
begin
  ordernr := 0;
  Result := TProfileItemAttrDef.Create;
  Result.FProfileItemAttrId := Self.Id;
  SetLength(FProfileItemAttrsDefs, length(FProfileItemAttrsDefs) + 1);
  FProfileItemAttrsDefs[High(FProfileItemAttrsDefs)] := Result;
  for var i: Integer := Low(FProfileItemAttrsDefs) to High(FProfileItemAttrsDefs) do
    if FProfileItemAttrsDefs[i].FOrderNr > ordernr then
    begin
      ordernr := FProfileItemAttrsDefs[i].OrderNr;
    end;

  Result.FOrderNr := ordernr + 1;
end;

end.
