{$I Conf.inc}
unit UTools;
// Author: Ingmar Tammeväli www.stiigo.com

interface
uses FMX.ListBox,
  FMX.ComboEdit,
  UClassificators,
  UProfiles,
  System.Classes,
  System.Generics.Defaults,
  System.Generics.Collections;

const
  CProductname = 'TBuilder';

type
  TFillComboMiscTypes = (
    mtp_assets_supervisor, // varade eest vastutaja
    mtp_warehouses // ladude nimekiri
  );

function _appDocDir(const ACreateDir: Boolean = True): String;
function GenerateFutureDatetime: TDatetime;
procedure FillCombo(const ACombo: TComboBox; const AClassicatorType: TClassificatorTypes;
  const AItemId: Integer = 0; const AAddEmptyEntry: Boolean = True); overload;
procedure FillCombo(const ACombo: TComboEdit; const AClassicatorType: TClassificatorTypes;
  const AItemId: Integer = 0; const AAddEmptyEntry: Boolean = True); overload;
procedure FillCombo(const ACombo: TComboBox; const AMiscTypes: TFillComboMiscTypes;
  const AItemId: Integer = 0; const AAddEmptyEntry: Boolean = True); overload;
procedure FillCombo(const ACombo: TComboEdit; const AMiscTypes: TFillComboMiscTypes;
  const AItemId: Integer = 0; const AAddEmptyEntry: Boolean = True); overload;

function GetObjectValue(const AId: Integer; const AMiscTypes: TClassificatorTypes): String; overload;
function GetObjectValue(const AId: Integer; const AMiscTypes: TFillComboMiscTypes): String; overload;
function CmbGetData(const ACombo: TComboBox): NativeUInt; overload;
function CmbSetData(const ACombo: TComboBox; const AId: NativeUInt): Boolean; overload;
function CmbGetData(const ACombo: TComboEdit): NativeUInt;  overload;
function CmbSetData(const ACombo: TComboEdit; const AId: NativeUInt): Boolean;  overload;
function IntListToArray(const AIntList: TList<Integer>):TArray<Integer>;
function DateTimeIsEmpty(const ADatetime: TDatetime): Boolean;
function SystemLangStr: String;

procedure ComboEditVerifySelection(const ACombo: TComboEdit);
function Confirm(const AMsg: String): Boolean;
function DeleteConfirm: Boolean;
procedure ShowError(const AMsg: String; const ARemoveSpecialTags: Boolean = True);
procedure _debugMsg(const Msg: String);
function _t(const AStr: String):String;
function appPath: String;

// Ära lingi otse moodulit UDataAndImgModule siia, vaid viita koopiaga !
procedure AssignClfAndProfilesRefs(const ARefCachedClf: TObjectList<TClassificators>;
  const ARefCachedProf: TObjectList<TProfiles>);

implementation
uses
  System.IOUtils, DateUtils, SysUtils, FMX.DialogService,
  FMX.Types, FMX.Dialogs, FMX.Platform, System.UITypes;

var
  glob_ref_of_cached_classificators: TObjectList<TClassificators> = nil;
  glob_ref_of_cached_profiles: TObjectList<TProfiles> = nil;

function _appDocDir(const ACreateDir: Boolean = True): String;
begin
  Result := IncludeTrailingPathDelimiter(TPath.Getdocumentspath) + CProductname.ToLower + PathDelim;
  if not DirectoryExists(Result) and ACreateDir then
    ForceDirectories(Result);
end;


function GenerateFutureDatetime: TDatetime;
begin
  // Result := EncodeDateTime(2049, 1, 1, 0 , 0, 0, 0); Antud kp tekitab sqllite puhul probleeme
  Result := EncodeDateTime(2035, 1, 1, 0 , 0, 0, 0);
end;

procedure AssignClfAndProfilesRefs(const ARefCachedClf: TObjectList<TClassificators>;
  const ARefCachedProf: TObjectList<TProfiles>);
begin
  glob_ref_of_cached_classificators := ARefCachedClf;
  glob_ref_of_cached_profiles := ARefCachedProf;
end;

function IntListToArray(const AIntList: TList<Integer>):TArray<Integer>;
begin
  SetLength(Result, AIntList.Count);
  for var i : Integer := 0 to AIntList.Count - 1 do
      Result[i] := AIntList.Items[i];
end;

procedure FillCombo(const ACombo: TComboBox; const AClassicatorType: TClassificatorTypes;
  const AItemId: Integer = 0; const AAddEmptyEntry: Boolean = True); overload;
var
  clf: TClassificators;
  itemidx, markindex: Integer;
begin
  Assert(Assigned(glob_ref_of_cached_classificators));
  if AAddEmptyEntry then
    ACombo.Items.AddObject('', TObject(0));

  markindex := -1;
  itemidx := -1;
  for clf in glob_ref_of_cached_classificators do
  begin
    if clf.Cf_Type = TClassificatorTypesStr[AClassicatorType] then
    begin
      itemidx := ACombo.Items.AddObject(clf.Cf_Name, TObject(clf.Id));
      if (AItemId > 0) and (clf.id = AItemId) then
        markindex := itemidx;
    end;
  end;
  if markindex >= 0 then
    ACombo.ItemIndex := markindex;
end;

procedure FillCombo(const ACombo: TComboEdit; const AClassicatorType: TClassificatorTypes;
  const AItemId: Integer = 0; const AAddEmptyEntry: Boolean = True); overload;
var
  clf: TClassificators;
  itemidx, markindex: Integer;
begin
  Assert(Assigned(glob_ref_of_cached_classificators));
  if AAddEmptyEntry then
    ACombo.Items.AddObject('', TObject(0));

  markindex := -1;
  itemidx := -1;
  for clf in glob_ref_of_cached_classificators do
    if clf.Cf_Type = TClassificatorTypesStr[AClassicatorType] then
    begin
      itemidx := ACombo.Items.AddObject(clf.Cf_Name, TObject(clf.Id));
      if (AItemId > 0) and (clf.id = AItemId) then
        markindex := itemidx;
    end;
  if markindex >= 0 then
    ACombo.ItemIndex := markindex;
end;

// Ingmar www.stiigo.com 10.03.2021
procedure FillCombo(const ACombo: TComboBox; const AMiscTypes: TFillComboMiscTypes;
  const AItemId: Integer = 0; const AAddEmptyEntry: Boolean = True); overload;
begin
  if AAddEmptyEntry then
    ACombo.Items.AddObject('', TObject(0));
end;

procedure FillCombo(const ACombo: TComboEdit; const AMiscTypes: TFillComboMiscTypes;
  const AItemId: Integer = 0; const AAddEmptyEntry: Boolean = True); overload;
begin
  if AAddEmptyEntry then
    ACombo.Items.AddObject('', TObject(0));
end;

function GetObjectValue(const AId: Integer; const AMiscTypes: TClassificatorTypes): String;
var
  clf: TClassificators;
begin
  Result := '';
  for clf in glob_ref_of_cached_classificators do
    if (clf.Cf_Type = TClassificatorTypesStr[AMiscTypes]) and (clf.Id = AId) then
    begin
      Exit(clf.Cf_Name);
    end;
end;

function GetObjectValue(const AId: Integer; const AMiscTypes: TFillComboMiscTypes): String;
begin
  Result := '';
end;

function CmbGetData(const ACombo: TComboBox): NativeUInt;
begin
  Result := 0;
  if ACombo.ItemIndex >= 0 then
    Result := NativeUInt(ACombo.Items.Objects[ACombo.ItemIndex]);
end;

function CmbGetData(const ACombo: TComboEdit): NativeUInt;
begin
  Result := 0;
  if ACombo.ItemIndex >= 0 then
    Result := NativeUInt(ACombo.Items.Objects[ACombo.ItemIndex]);
end;

function CmbSetData(const ACombo: TComboBox; const AId: NativeUInt): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to ACombo.Items.Count - 1 do
  begin
    Result := AId = NativeUInt(ACombo.Items.Objects[i]);
    if Result then
    begin
      ACombo.ItemIndex := i;
      Exit;
    end;
  end;
end;

function DateTimeIsEmpty(const ADatetime: TDatetime): Boolean;
begin
  Result := ADatetime > 0;
end;

function CmbSetData(const ACombo: TComboEdit; const AId: NativeUInt): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to ACombo.Items.Count - 1 do
  begin
    Result := AId = NativeUInt(ACombo.Items.Objects[i]);
    if Result then
    begin
      ACombo.ItemIndex := i;
      Exit;
    end;
  end;
end;

procedure ComboEditVerifySelection(const ACombo: TComboEdit);
var
  val: String;
  indx: Integer;
begin
  val := Trim(ACombo.Text);
  if val = '' then
    ACombo.ItemIndex := -1
  else
  begin
    indx := ACombo.Items.IndexOf(val);
    if indx < 0 then
    begin
      ShowMessage(_t('Palun täpsustage valikut !'));
      // ACombo.SetFocus;
      ACombo.ItemIndex := -1;
      ACombo.Text := '';
      ACombo.SetFocus;
      Exit;
    end;
    ACombo.ItemIndex := indx;
  end;
end;

function Confirm(const AMsg: String): Boolean;
var
  pret: Boolean;
begin
  {$IFDEF WINDOWS}
  Result := FMX.Dialogs.MessageDlg(AMsg,
    System.UITypes.TMsgDlgType.mtConfirmation,
    [System.UITypes.TMsgDlgBtn.mbYes,  System.UITypes.TMsgDlgBtn.mbNo], 0) = mrYes;
  {$ELSE}
  pret := False;
  Result := False;

  FMX.DialogService.TDialogService.MessageDialog(
    AMsg,
    System.UITypes.TMsgDlgType.mtConfirmation,
    [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo],
    System.UITypes.TMsgDlgBtn.mbYes, 0,
    procedure(const AResult: TModalResult)
    begin
      pret := AResult = mrYes;
    end);
  Result := pret;
  {$ENDIF}
end;

function DeleteConfirm: Boolean;
begin
  Result := Confirm(_t('Kas kustutame rea ?'));
end;

procedure ShowError(const AMsg: String; const ARemoveSpecialTags: Boolean = True);
var
  msg: String;
begin
  msg := AMsg.Replace('ERR:', '').Replace('OK:', '');
  {$IFDEF WINDOWS}
  FMX.Dialogs.MessageDlg(msg,
    System.UITypes.TMsgDlgType.mtError,
    [System.UITypes.TMsgDlgBtn.mbOK], 0);
  {$ELSE}
  FMX.DialogService.TDialogService.ShowMessage(AMsg);
  {$ENDIF}
end;

procedure _debugMsg(const Msg: String);
begin
{$IFDEF DEBUG}
  Log.d('-------------------- ' + Msg);
{$ENDIF}
end;

function _t(const AStr: String):String;
begin
  Result := AStr;
end;

function appPath: String;
begin
  Result := IncludeTrailingBackSlash(ExtractFilePath(ParamStr(0)));
end;

function SystemLangStr: String;
var
  svc: IFMXLocaleService;
begin
  Result := '';
  if TPlatformServices.Current.SupportsPlatformService(IFMXLocaleService,svc) then
    Result := svc.GetCurrentLangID; // et / en
end;

end.
