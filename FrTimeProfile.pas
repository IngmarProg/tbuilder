unit FrTimeProfile;
// TODO; FDeletedGroupItems teha pigem class -> TMemDataset peale
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FrBase, System.ImageList, FMX.ImgList, FMX.Controls.Presentation, FMX.Layouts,
  FMX.Edit, FMX.TMSBaseControl, FMX.TMSLabelEdit, FrTimeProfileEntry,
  System.Generics.Collections, FMX.ListBox, UProfiles, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FMX.Objects, UBase, UPObject;

{$DEFINE ALLOW_EMPTY_WKTYPE}
type
  TTimeProfileEntryList =  TList<TframeTimeProfileEntry>;
{
  TTimeProfileEntryListHelper =  class helper for TTimeProfileEntryList // record
    procedure EmptyCount;
  end;
}
type
  TframeTimeProfile = class(TframeBase)
    edProfileName: TEdit;
    lblProfileName: TLabel;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    fmScroll: TScrollBox;
    sbFix: TLabel;
    btnSave: TSpeedButton;
    lstWorkList: TListView;
    GroupBox1: TGroupBox;
    pnlDefLevels: TPanel;
    cmbWkLevels: TComboBox;
    lblWorkLevels: TLabel;
    lblObject: TLabel;
    cmbObjects: TComboBox;
    lblEmployeeGrp: TLabel;
    cmbEmpGroup: TComboBox;
    Label8: TLabel;
    frameLeadingEntry: TframeTimeProfileEntry;
    procedure btnSaveClick(Sender: TObject);
    procedure FrameResized(Sender: TObject);
    procedure lstWorkListUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure lstWorkListItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure lstWorkListItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure cmbWkLevelsChange(Sender: TObject);
  protected
    FObjectList: TObjectList<TPObject>;
    FSaveGrpItemsSaveBfr: TObjectList<TBase>;
    FSelectedListViewItem: TListViewItem;
    FGroupItems: TStringList;
    FActiveProfile: TProfiles;
    FProfileDataChanged: Boolean;
    FWkTypes: TStringList;
    FDeletedProfItems: TList<Integer>;
    FDeletedGroupItems: TList<Integer>;
    FProfileItemEntry: TTimeProfileEntryList;
    procedure OnCmbLevelOnChangeHandler(Sender: TObject);
    procedure LoadWkList(const ALevelId: Integer = -1);
    procedure AssignData(const AFrame: TframeTimeProfileEntry; const AWriteBack: Boolean = False);
    function addFrame(const AVisible: Boolean = True): TframeTimeProfileEntry;
    procedure addFrameEvent(AFrame: TFrameBase);
    procedure clearEntryFrame(AFrame: TframeTimeProfileEntry);
    procedure deleteFrameEvent(AFrame: TFrameBase);
    procedure saveNewGroupItems;
    procedure deleteGroupItems;
  public
    procedure LoadData(const AProfile: TProfiles; const AObjectList: TObjectList<TPObject> = nil); reintroduce;
    function Save: Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  frameTimeProfile: TframeTimeProfile;

implementation
uses System.Threading, UTools, UDataAndImgmodule,
  UProfileItemGrouping, UClassificators, UNotification,
  UAsyncDownloader;

{$R *.fmx}
const
  CTagBusy = 1;


procedure TframeTimeProfile.OnCmbLevelOnChangeHandler(Sender: TObject);
var
  levelid: Integer;
  cmb: TComboBox;
begin
  if Sender is TComboBox then
  begin
    for var i : Integer := 0 to TComboBox(Sender).Parent.ChildrenCount - 1 do
        if (TComboBox(Sender).Parent.Children.Items[i] is TComboBox) then
        begin
          cmb := TComboBox(Sender).Parent.Children.Items[i] as TComboBox;
          if cmb.Name = 'cmbWkType' then // Tööde nimistu
          begin
            levelid := CmbGetData(Sender as TComboBox);
            cmb.Items.Clear;
            {$IFDEF ALLOW_EMPTY_WKTYPE}
            cmb.Items.AddObject('', TObject(0));
            {$ENDIF}
            for var j : Integer := 0 to FGroupItems.Count - 1 do
              if FGroupItems.ValueFromIndex[j] = levelid.ToString  then
              begin
                for var k : Integer := 0 to FWkTypes.Count - 1 do
                  if FGroupItems.Names[j] = NativeUInt(FWkTypes.Objects[k]).ToString then
                    cmb.Items.AddObject(FWkTypes.Strings[k], TObject(FWkTypes.Objects[k]));
              end;
            Break;
          end;
        end;
  end;
end;

procedure TframeTimeProfile.AssignData(const AFrame: TframeTimeProfileEntry;
  const AWriteBack: Boolean = False);
var
  indx: Integer;
  cmblevel_event: TNotifyEvent;
  cmbwk_types_event: TNotifyEvent;
  item: TProfileItem;
  item_attr: TProfileItemAttr;
begin
  cmblevel_event := nil;
  cmbwk_types_event := nil;
  item := AFrame.ProfileItem;
  if Assigned(AFrame) and Assigned(item) then
  try
    cmblevel_event := AFrame.cmbLevel.OnChange;
    cmbwk_types_event := AFrame.cmbWkType.OnChange;
    if Length(item.Profile_item_attrs) > 0 then // First value contains def.
    case AWriteBack of
      false: begin
        CmbSetData(AFrame.cmbLevel, item.Level_nr); // --> level_nr classificator_id
        AFrame.cmbLevel.OnChange(AFrame.cmbLevel);

        // CmbSetData(AFrame.cmbWkType, item.Id);
        // Source data has been deleted or renamed, show original name
        if not CmbSetData(AFrame.cmbWkType, item.Related_Item_Id) then
        begin
          indx := AFrame.cmbWkType.Items.AddObject(item.Item_name, TObject(item.Related_Item_Id));
          AFrame.cmbWkType.ItemIndex := indx;
        end;
        var b: Boolean;

        item_attr := item.Profile_item_attrs[0] as TProfileItemAttr;
        AFrame.cbStartConfirm.IsChecked := item_attr.TimeMsRequired;
        AFrame.cbAddTime.IsChecked := item_attr.TimeMs2Required;
        AFrame.cbAddAmount.IsChecked := item_attr.AddAmount;
        b := item_attr.AmountRequired;
        AFrame.cbAmountRequired.IsChecked := b;
        if b then
          AFrame.cbAmountRequired.Enabled := True;

        AFrame.cbSubLevelReq.IsChecked := item_attr.SubItemRequired;
        AFrame.cbComments.IsChecked := item_Attr.Addcomments;
        b := item_attr.CommentsRequired;
        AFrame.cbCommentReq.IsChecked := b;
        if b then
          AFrame.cbCommentReq.Enabled := True;

        AFrame.cbPicture.IsChecked := item_attr.AddPicture;
        b := item_attr.PictureRequired;
        AFrame.cbPictureRequired.IsChecked := b;
        if b then
         AFrame.cbPictureRequired.Enabled := True;
        AFrame.cbPrevChoice.IsChecked :=  item_attr.PrevItemRequired;
      end;
      true: begin
        item.Level_nr := CmbGetData(AFrame.cmbLevel);
        // item.Id := CmbGetData(AFrame.cmbWkType);
        item.Related_Item_Id := CmbGetData(AFrame.cmbWkType);
        if AFrame.cmbWkType.ItemIndex >= 0 then
          // Save original name
          item.Item_name := Trim(AFrame.cmbWkType.items[AFrame.cmbWkType.ItemIndex])
        else
          item.Item_name := '';

        item_attr := item.Profile_item_attrs[0] as TProfileItemAttr;
        item_attr.OrderNr := -1; // definition must be always first items !!!
        item_attr.TimeMsRequired := AFrame.cbStartConfirm.IsChecked;
        item_attr.TimeMs2Required := AFrame.cbAddTime.IsChecked;
        item_attr.AddAmount := AFrame.cbAddAmount.IsChecked;
        item_attr.AmountRequired := AFrame.cbAmountRequired.IsChecked;
        item_attr.SubItemRequired := AFrame.cbSubLevelReq.IsChecked;
        // Eelmine liitvalik
        item_attr.PrevItemRequired := AFrame.cbPrevChoice.IsChecked;
        // item_attr.           PrevItemRequired
        item_Attr.Addcomments := AFrame.cbComments.IsChecked;
        item_attr.CommentsRequired := AFrame.cbCommentReq.IsChecked;
        item_attr.AddPicture := AFrame.cbPicture.IsChecked;
        item_attr.PictureRequired := AFrame.cbPictureRequired.IsChecked;
      end;
    end;


    AFrame.cmbLevel.OnChange := nil;
    AFrame.cmbWkType.OnChange := nil;
  finally
    AFrame.cmbLevel.OnChange := cmblevel_event;
    AFrame.cmbWkType.OnChange := cmbwk_types_event;
  end;
end;

procedure TframeTimeProfile.btnSaveClick(Sender: TObject);
begin
  inherited;
  if Save then
    Showmessage(_t('Salvestatud'){$IFDEF DEBUG} + ' ' + FActiveProfile.Id.ToString {$ENDIF});
end;

function TframeTimeProfile.AddFrame(const AVisible: Boolean = True): TframeTimeProfileEntry;
var
  newEntry: TframeTimeProfileEntry;
begin
  Result := nil;
  try
    // frameLeadingEntry.Name := 'main_dtentry_' + Random(9999).ToString; // Delphi workaround
    Assert(Assigned(FActiveProfile));
    newEntry := TframeTimeProfileEntry.Create(fmScroll);
    newEntry.Name := 'dtentry_' + (FProfileItemEntry.Count + 1).ToString;

    newEntry.Position.Y :=
      TframeTimeProfileEntry(FProfileItemEntry.Last).Position.Y +
      TframeTimeProfileEntry(FProfileItemEntry.Last).Height + 1;

    newEntry.FrameIndex := FProfileItemEntry.Count;
    newEntry.Width := frameLeadingEntry.Width;
    newEntry.Align := frameLeadingEntry.Align;
    newEntry.Parent := fmScroll;
    newEntry.Visible := AVisible;
    sbFix.Position.Y := newEntry.Position.Y  + newEntry.Height + 16;
    // Kopeerime nivood
    newEntry.AssignLevels(frameLeadingEntry.cmbLevel.Items);
    newEntry.cmbLevel.OnChange := OnCmbLevelOnChangeHandler;

    Result := newEntry;
  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
      UTools._debugMsg(E.Message);
      {$ENDIF}
    end;
  end;
end;

procedure TframeTimeProfile.AddFrameEvent(AFrame: TFrameBase);
var
  entry: TframeTimeProfileEntry;
  profitem: TProfileItem;
  profattr: TProfileItemAttr;
begin
  entry := AddFrame(True);
  entry.OnAddNewFrame := AddFrameEvent;
  entry.OnDeleteFrame := DeleteFrameEvent;
  FProfileItemEntry.Add(entry);

  profitem := FActiveProfile.addProfileItem;;
  profitem.Flags := UProfiles.TProfileItem_FlagBufferedUIItem;

  profattr := profitem.addProfileAttr;
  profattr.OrderNr := 1;
  entry.ProfileItem := profitem;

//  if Assigned(preventry) then
//    entry.cmbWkType.Items.Assign(preventry.cmbWkType.Items)
//  else
//    entry.cmbWkType.Items.Assign(frameLeadingEntry.cmbWkType.Items);
end;

procedure TframeTimeProfile.LoadWkList(const ALevelId: Integer = -1);
var
  prof: TProfiles;
  prof_item: TProfileitem;
  profitem_id: Integer;
  grpitems: TList<Integer>;
  litem: TListViewItem;
begin
  grpitems := TList<Integer>.Create;
  try
    for var i: Integer := 0 to FGroupItems.Count - 1 do
    if (FGroupItems.ValueFromIndex[i] = ALevelId.ToString) then
    begin
      profitem_id := FGroupItems.Names[i].ToInteger;
      grpitems.Add(profitem_id);
    end;

    lstWorkList.items.Clear;
    prof := CommonData.GetTimeProfileWkTemplate;
    for prof_item in prof.Profile_items do
    begin
      litem := lstWorkList.Items.Add;
      litem.Text := prof_item.Item_name;
      litem.Tag := prof_item.Id;
      litem.Checked := (grpitems.IndexOf(prof_item.id) >= 0);
      litem.Height := 0;
    end;
  finally
    grpitems.Free;
  end;
end;

procedure TframeTimeProfile.LoadData;

  procedure InitFrameAndGroups;
  var
    groups: TObjectList<TBase>;
    data: String;
    classif: TClassificators;
    filt: TStringList;
  begin

    // Tasemed paika
    frameLeadingEntry.cmbLevel.Clear;
    for classif in CommonData.CachedClassificators do
      if (classif.Cf_Type = TClassificatorTypesStr[clf_wk_levels]) then
      begin
        // Me hoiame level nr peal andmebaasis siiski classificators tabeli ID, mitte leveli nr
        // Ntx muudetakse 1 pealt level Tööd 1, jääb kõik muu tööle
        frameLeadingEntry.cmbLevel.Items.AddObject(classif.Cf_Name, TObject(NativeInt(classif.Id)));
      end;

    cmbWkLevels.Items.Assign(frameLeadingEntry.cmbLevel.Items);
    groups := TObjectList<TBase>.Create;
    groups.OwnsObjects := True;


    // TODO ASYNC download !
    // Laeme tasemete grupid ja seosed
    filt := TStringList.Create;
    try
      filt.Add('profile_id=' + self.FActiveProfile.Id.ToString);
      data := CommonData._fetchBizObjectData(TProfileItemGrouping.ClassName, 0, filt);
      TProfileItemGrouping.JSONRespToDsObjects(data, groups);
      for var i: Integer := 0 to groups.Count - 1 do
        FGroupItems.AddPair(TProfileItemGrouping(groups.Items[i]).Profile_item_id.ToString,
          TProfileItemGrouping(groups.Items[i]).Clf_Id.ToString,
          TObject(TProfileItemGrouping(groups.Items[i]).Id));
    finally
      FreeAndNil(groups);
      FreeAndNil(filt);
    end;
  end;

var
  profitem: TProfileItem;
  profentry: TframeTimeProfileEntry;
  rownr, defaultlevelid: NativeInt;
begin
  FActiveProfile := AProfile;
  FObjectList := AObjectList;

  Assert(Assigned(FActiveProfile) and FActiveProfile.IsAssigned, 'Profile id not assigned !');
  CommonData.returnItemIdAndName(CommonData.GetTimeProfileWkTemplate, FWkTypes);

  InitFrameAndGroups;
  FillCombo(cmbEmpGroup, clf_employee_group, FActiveProfile.Employee_group_clf_id);


  // Laeme esimese grupi
  if cmbWkLevels.Items.Count > 0 then
  try
    defaultlevelid := NativeInt(cmbWkLevels.Items.Objects[0]);
    cmbWkLevels.Tag := 1; // väldime, et onchange event hakkab ka listi uuendama ! Tag on marker
    cmbWkLevels.ItemIndex := 0;
    LoadWkList(defaultlevelid);
  finally
    cmbWkLevels.Tag := 0;
  end;

  // test test
  frameLeadingEntry.cmbWkType.Items.Assign(FWkTypes);


  if FActiveProfile.Profile_name.Trim() <> '' then
    edProfileName.Text := FActiveProfile.Profile_name
  else
    edProfileName.Text := _t('Profiil') + #32 + DateToStr(Now);
  try
    // fmScroll.BeginUpdate; Argument out of range exception ! Delphi bug
    sbFix.Position.Y := frameLeadingEntry.Height + 16;
    for profentry in FProfileItemEntry do
      DeleteFrameEvent(profentry);

    FDeletedGroupItems.Clear;
    FDeletedProfItems.Clear;
    frameLeadingEntry.FrameIndex := 0;
    frameLeadingEntry.OnAddNewFrame := AddFrameEvent;
    frameLeadingEntry.OnDeleteFrame := DeleteFrameEvent;
    rownr := 0;
    for profitem in AProfile.Profile_items do
      if profitem.Active then
      begin
        Inc(rownr);
        if rownr = 1 then
        begin
          frameLeadingEntry.ProfileItem := profitem;
          AssignData(frameLeadingEntry);
          Continue;
        end;
        
        profentry := AddFrame(False);
        profentry.OnAddNewFrame := AddFrameEvent;
        profentry.OnDeleteFrame := DeleteFrameEvent;
        profentry.ProfileItem := profitem;

        AssignData(profentry);
        FProfileItemEntry.Add(profentry);
        profentry.Visible := True;
      end;
  finally
    // fmScroll.EndUpdate;
  end;
end;

procedure TframeTimeProfile.lstWorkListItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  inherited;
  FSelectedListViewItem := AItem;
end;

procedure TframeTimeProfile.lstWorkListItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
var
  b: Boolean;
  currgroupid: NativeInt;
begin
  if (ItemIndex < 0) or not Assigned(FSelectedListViewItem) then
    Exit;

  // Kas vajalik ?
  // if ((LocalClickPos.X >= lstWorkList.Position.X) and (LocalClickPos.X <= lstWorkList.Position.X + 36)) then
  begin
    b := not FSelectedListViewItem.Checked;
    FSelectedListViewItem.Checked := b;
    FSelectedListViewItem.Objects.AccessoryObject.Visible := b;
    if cmbWkLevels.ItemIndex >= 0 then
    begin
      currgroupid := NativeUInt(cmbWkLevels.Items.Objects[cmbWkLevels.ItemIndex]);
      // Eemaldame grupist
      if not b then
      begin
        for var i: Integer := 0 to FGroupItems.Count - 1 do
        if (FGroupItems.Names[i] = FSelectedListViewItem.Tag.ToString)
          and (FGroupItems.ValueFromIndex[i] = currgroupid.ToString) then
        begin
          FDeletedGroupItems.Add(NativeUInt(FGroupItems.Objects[i]));
          FGroupItems.Delete(i);
          Break;
        end;
      end
      else
      begin
        FGroupItems.AddPair(FSelectedListViewItem.Tag.ToString, currgroupid.ToString, TObject(0));
        // NB NB me peame kahjuks siin koheselt tegema async salvestuse,
        // kuna ajaprofiilis andmeid salvestades on vaja juba elemendi ID'd
        SaveNewGroupItems();
      end;
    end;
  end;
end;

procedure TframeTimeProfile.lstWorkListUpdateObjects(const Sender: TObject;
  const AItem: TListViewItem);
begin
  inherited;
  // AItem.Objects.TextObject.Width := AItem.Objects.TextObject.Width - (5 + AItem.Objects.AccessoryObject.Width);
  AItem.Objects.AccessoryObject.Visible := AItem.Checked;
end;

// TODO teha tööde queue, sest kui liiga kiiresti klikib võivad andmed kaduma minna, kui veebisait aeglane
procedure TframeTimeProfile.SaveNewGroupItems;
var
  json: String;
  itemid: Integer;
begin
  for var i: Integer := 0 to FGroupItems.Count - 1 do
    if NativeUInt(FGroupItems.Objects[i]) = 0 then
    begin
      var tmp := TProfileItemGrouping.Create(FActiveProfile.Id,
        FGroupItems.Names[i].ToInteger,
        FGroupItems.ValueFromIndex[i].ToInteger);

        // Jätame meelde millise indeksiga see uus grupi element seotud
        // Selleks hea tag või miscdata, mis klassides esindatud
        tmp.Tag := i + 1;
        FSaveGrpItemsSaveBfr.Add(tmp);
    end;

  if FSaveGrpItemsSaveBfr.Count < 1 then
    Exit;

  json := MultiObjectToJson(FSaveGrpItemsSaveBfr);

  AsyncPost(TBase.PostURI, json,
    procedure(const AData: String; const AEMsg: String;
      const ANotifId: Integer; const ANotifType: TNotificationTypes; const AMiscData: NativeUInt)
    begin
      if AEMsg <> '' then
        ShowError(AEMsg)
      else
      begin
        var tmp : TStringList;
        var emsg: String;
        try
          tmp := AssignJsonRPIDs(AData, emsg);
          for var i: Integer := 0 to FSaveGrpItemsSaveBfr.Count - 1 do
            if TBase(FSaveGrpItemsSaveBfr.Items[i]).Tag > 0 then// kirjutame tagastatud tagasi puhvrisse
            begin
              itemid := TBase(FSaveGrpItemsSaveBfr.Items[i]).id;
              FGroupItems.Objects[FSaveGrpItemsSaveBfr.Items[i].Tag - 1] := TObject(itemid);// hoiame vaid rea ided antud juhul puhvrites
            end;

          if emsg <> '' then
            ShowError(emsg);
        finally
          FreeAndNil(tmp);
          // Koguklassi pole meil mõtet mälus hoida; FGroupItems seal meil ID ja nimi
          FSaveGrpItemsSaveBfr.Clear;
        end;
      end;
    end);
end;

// SYNC
// Tõsteti ntx töid ümber nivoode all
procedure TframeTimeProfile.DeleteGroupItems;
begin
  if FDeletedGroupItems.Count > 0 then
  begin
    var tmp := TProfileItemGrouping.Create;
    try
      tmp.DeleteEx(IntListToArray(FDeletedGroupItems), CommonData.FncBizObjectDelete2);
      FDeletedGroupItems.Clear;
    finally
      FreeAndNil(tmp);
    end;
  end;
end;

function TframeTimeProfile.Save: Boolean;

  procedure deleteProfileEntrys;
  begin
    var tmp := TProfileItem.Create;
    try
      for var i: Integer := FDeletedProfItems.Count - 1 downto 0 do
        if FDeletedProfItems[i] < 1 then
          FDeletedProfItems.Delete(i);

      tmp.DeleteEx(IntListToArray(FDeletedProfItems), CommonData.FncBizObjectDelete2);
      FDeletedProfItems.Clear;
    finally
      FreeAndNil(tmp);
    end;
  end;


var
  linesok: Boolean;
  entry: TframeTimeProfileEntry;
begin
  Result := False;
  try
    deleteGroupItems();
    saveNewGroupItems();
    deleteProfileEntrys();

    FProfileItemEntry.Add(frameLeadingEntry);
    if not Assigned(frameLeadingEntry.ProfileItem) then
    begin
      frameLeadingEntry.ProfileItem := FActiveProfile.addProfileItem;
      frameLeadingEntry.ProfileItem.addProfileAttr;
      // frameLeadingEntry.ProfileItem.addProfileAttr.addProfileAttrValue.AttrName1 := 'TEST Attr1';
    end;

    linesok := False;
    try
      for entry in FProfileItemEntry do
      try
        linesok := (entry.cmbLevel.ItemIndex >= 0);
        if not linesok then
        begin
          entry.cmbLevel.SetFocus;
          Break;
        end;
        // Kristo ütles, et tööd ei pea valima alati vaid tase, kus töömees valib töö, mis lubatud antud tasemes
        {
        linesok := (entry.cmbWkType.ItemIndex >= 0);
        if not linesok then
        begin
          entry.cmbWkType.SetFocus;
          Break;
        end;}
      except
      end;

      if not linesok then
      begin
        ShowError(_t('Rida puudulikult kirjeldatud !'));
        Exit;
      end;

      // Frame values
      for entry in FProfileItemEntry do
        AssignData(entry, True);

      FActiveProfile.Profile_name := edProfileName.Text;
      FActiveProfile.Employee_group_clf_id := UTools.CmbGetData(cmbEmpGroup);

      FActiveProfile.Save(CommonData.FncBizObjectSave);
      FProfileDataChanged := False;
    finally
      FProfileItemEntry.Remove(frameLeadingEntry);
    end;

    Result := True;
  except
    on E: Exception do
    begin
      ShowError(E.Message);
    end;
  end;
end;

procedure TframeTimeProfile.ClearEntryFrame(AFrame: TframeTimeProfileEntry);
begin
  with AFrame do
  begin
    for var i: Integer := 0 to ComponentCount - 1 do
      if (Components[i] is TCheckBox) then
        TCheckBox(Components[i]).IsChecked := False
      else
      if (Components[i] is TComboBox) then
      begin
        TComboBox(Components[i]).TagObject := nil;
        TComboBox(Components[i]).Tag := CTagBusy;
        TComboBox(Components[i]).ItemIndex := -1;
        TComboBox(Components[i]).Tag := 0;
      end;

    cbAmountRequired.Enabled := False;
    cbCommentReq.Enabled := False;
    cbPictureRequired.Enabled := False;
  end;
end;

procedure TframeTimeProfile.cmbWkLevelsChange(Sender: TObject);
begin
  if TComboBox(Sender).Tag > 0 then
    Exit;

  if TComboBox(Sender).ItemIndex >= 0 then
  try
    TComboBox(Sender).Tag := CTagBusy;
    LoadWkList(NativeUInt(TComboBox(Sender).Items.Objects[TComboBox(Sender).ItemIndex]));
  finally
    TComboBox(Sender).Tag := 0;
  end;
end;

procedure TframeTimeProfile.DeleteFrameEvent(AFrame: TFrameBase);
var
  delprofitem: TProfileItem;
begin
  delprofitem := nil;
  if frameLeadingEntry = AFrame then
  begin
      ClearEntryFrame(AFrame as TframeTimeProfileEntry);
      delprofitem := frameLeadingEntry.ProfileItem;
      if Assigned(delprofitem) then
      begin
        FDeletedProfItems.Add(delprofitem.Id);
        frameLeadingEntry.ProfileItem := nil;
      end;
  end
  else
  begin
    delprofitem := TframeTimeProfileEntry(AFrame).ProfileItem;
    if Assigned(delprofitem) then
      FDeletedProfItems.Add(delprofitem.Id);

    FProfileItemEntry.Remove(AFrame as TframeTimeProfileEntry);
    TTask.Run(procedure
      begin
          // AFrame.Height := 0;
          // AFrame.Parent := nil;
          AFrame.Visible := False;
          Sleep(150);
          TThread.Synchronize(nil,
            procedure
            begin
              FreeAndNil(AFrame);
            end);
      end);
  end;

  FActiveProfile.removeProfileItem(delprofitem);
  FProfileDataChanged := True;
end;

constructor TframeTimeProfile.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FWkTypes := TStringList.Create;
  frameLeadingEntry.Position.X := 0;

  // frameLeadingEntry.Width := fmScroll.Width - 6;
  FProfileItemEntry := TList<TframeTimeProfileEntry>.Create;
  FProfileItemEntry.Add(frameLeadingEntry);
  frameLeadingEntry.FrameIndex := 0;
  frameLeadingEntry.OnAddNewFrame := AddFrameEvent;
  frameLeadingEntry.OnDeleteFrame := DeleteFrameEvent;
  frameLeadingEntry.cmbLevel.OnChange := OnCmbLevelOnChangeHandler;

  ClearEntryFrame(frameLeadingEntry);

  FDeletedProfItems := TList<Integer>.Create;
  FDeletedGroupItems := TList<Integer>.Create;
  FGroupItems := TStringList.Create;

  FSaveGrpItemsSaveBfr := TObjectList<TBase>.Create;
  FSaveGrpItemsSaveBfr.OwnsObjects := True;

//  (Panel1.Controls[0] as TShape).Fill.Color := TAlphaColorRec.Red;
//  Fill.Color := lstWorkList.
end;

destructor TframeTimeProfile.Destroy;
begin
  FreeAndNil(FWkTypes);
  FreeAndNil(FDeletedProfItems);
  FreeAndNil(FDeletedGroupItems);
  FreeAndNil(FProfileItemEntry);
  FreeAndNil(FGroupItems);
  FreeAndNil(FSaveGrpItemsSaveBfr);
  inherited Destroy;
end;
procedure TframeTimeProfile.FrameResized(Sender: TObject);
var
  dpos: Single;
begin
  inherited;
  dpos := pnlDefLevels.Position.Y + pnlDefLevels.Height + 6;
  lstWorkList.Position.Y := dpos;
  lstWorkList.Height := GroupBox1.Height - dpos - 5;
end;

end.
