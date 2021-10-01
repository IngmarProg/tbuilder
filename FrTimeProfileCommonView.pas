unit FrTimeProfileCommonView;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FrBase, System.ImageList, FMX.ImgList, FMX.TMSCustomEdit, FMX.TMSSearchEdit,
  FMX.Controls.Presentation, FMX.TMSToolBar, FMX.ListView.Types, SyncObjs,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FMX.TMSBaseControl, FMX.TMSLabelEdit, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  FMX.TMSGraphicCheckLabel, FMX.TMSEdit, FMX.Edit, UTypes, UDataAndImgmodule,
  UNotification, UProfiles, UBase,  System.Generics.Collections,
  UAsyncDownloader;

type
    TVar<T> = array of T;

type
  TframeTimeProfileCommonView = class(TframeBase)
    GroupBox1: TGroupBox;
    tmsTimeProfSearch: TTMSFMXSearchEdit;
    btnNewProfile: TButton;
    GroupBox2: TGroupBox;
    tmsWorkTypes: TTMSFMXSearchEdit;
    btnNewJob: TButton;
    Panel1: TPanel;
    lstTimeProfiles: TListView;
    panelWorkList: TPanel;
    panelNewJob: TPanel;
    lstWorkTypes: TListView;
    edWorkDescr: TEdit;
    cbValueReq: TCheckBox;
    btnSaveJob: TSpeedButton;
    procedure btnNewJobClick(Sender: TObject);
    procedure btnSaveJobClick(Sender: TObject);
    procedure edWorkDescrEnter(Sender: TObject);
    procedure edWorkDescrExit(Sender: TObject);
    procedure btnNewProfileClick(Sender: TObject);
    procedure lstTimeProfilesItemClickEx(const Sender: TObject;
      ItemIndex: Integer; const LocalClickPos: TPointF;
      const ItemObject: TListItemDrawable);
    procedure lstWorkTypesItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure lstTimeProfilesDblClick(Sender: TObject);
  protected
    type
      TReloadData = (_cworkprofile, _ctimeprofile, _cboth);
  protected
    FOnCacheDownloadCompleted: TOnNotifyEvent;
    FPlaceholderMsg: String;
    FTimeLineProfiles: TObjectList<TProfiles>;
    procedure LoadTimeProfiles; // kasutaja loodud ajaprofiilid; future taske võiks kasutada !
    procedure RefreshList(const AReloadType: TReloadData);
  public
    // Frame loomise hetkel registreeritakse cache teavitus ära, kui tuleb teade, et cache laetud
    // siis laetakse andmed ja küsitakse ka kasutaja ajaprofiili andmed
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  frameTimeProfileCommonView: TframeTimeProfileCommonView;

implementation
uses UTools, FTimeProfile;

{$R *.fmx}

procedure TframeTimeProfileCommonView.RefreshList;
var
  lvitem: TListViewItem;
  lvdelete: TListItemImage;
  prof: TProfiles;
  profitem: TProfileItem;
begin
  //  Töid hoitakse alati caches !
  if AReloadType in [_cworkprofile, _cboth] then
  begin
    try
      prof := CommonData.getTimeProfileWkTemplate();
      lstWorkTypes.BeginUpdate;
      lstWorkTypes.Items.Clear;
      for profitem in prof.Profile_items do
      begin
        // Tööd on ajaprofiili template all
        lvitem := lstWorkTypes.Items.Add;
        lvitem.TagObject := profitem;
        lvitem.Data['Data1'] := #32#32 + profitem.Item_name;
        lvitem.Data['Data2'] := '';

        lvdelete := lvitem.Objects.FindObjectT<TListItemImage>('Img');
        lvdelete.Bitmap := frameImageList.Bitmap(TsizeF.Create(32,32), CImgDelete);
      end;
    finally
      lstWorkTypes.EndUpdate;
    end;
  end;


  if AReloadType in [_ctimeprofile, _cboth] then
  begin
    lstTimeProfiles.BeginUpdate;
    lstTimeProfiles.Items.Clear;
    try
      for prof in FTimeLineProfiles do
      begin
        lvitem := lstTimeProfiles.Items.Add;
        lvitem.TagObject := prof;

        lvitem.Data['Data1'] := #32#32 + prof.Profile_name;
        lvitem.Data['Data2'] := '';
        lvdelete := lvitem.Objects.FindObjectT<TListItemImage>('Img');
        lvdelete.Bitmap := frameImageList.Bitmap(TsizeF.Create(32,32), CImgDelete);
      end;
    finally
      lstTimeProfiles.EndUpdate;
    end;
  end;
end;

procedure TframeTimeProfileCommonView.lstTimeProfilesDblClick(Sender: TObject);
var
  opener: TProfiles;
begin
  if Assigned(lstTimeProfiles.Selected) then
  begin
    opener := lstTimeProfiles.Selected.TagObject as TProfiles;
    TTimeProfileForm.createAndShow(opener);
  end;
end;

procedure TframeTimeProfileCommonView.lstTimeProfilesItemClickEx(
  const Sender: TObject; ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
  inherited;
  if ItemObject Is TListItemImage then
  begin
    showmessage('delete 1');
  end;
end;

procedure TframeTimeProfileCommonView.lstWorkTypesItemClickEx(
  const Sender: TObject; ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
var
  prof: TProfileItem;
begin
  inherited;
  if (ItemObject Is TListItemImage) and (ItemIndex >= 0) and DeleteConfirm then
  begin
    prof := TListItem(lstWorkTypes.Items.Item[ItemIndex]).TagObject as TProfileItem;
    prof.Delete(CommonData.FncBizObjectDelete);
    TListItem(lstWorkTypes.Items.Item[ItemIndex]).TagObject := nil;
    lstWorkTypes.items.Delete(ItemIndex);
  end;
end;

procedure TframeTimeProfileCommonView.btnSaveJobClick(Sender: TObject);
var
  prof: TProfiles;
  item: TProfileItem;
  item_attr: TProfileItemAttr;
  item_name: String;
begin
  inherited;
  prof := CommonData.getTimeProfileWkTemplate();
  Assert(Assigned(prof));

  item_name := Trim(edWorkDescr.Text);
  if not (prof.profileItemExists(item_name)) then
  begin
    item := prof.addProfileItem;
    item.Item_name := edWorkDescr.Text;
    item.Save(CommonData.FncBizObjectSave);

    item_attr := item.addProfileAttr;
    item_attr.OrderNr := 1;
    item_attr.ValueRequired := cbValueReq.IsChecked;
    item_attr.Save(CommonData.FncBizObjectSave);
    edWorkDescr.Text := '';
    if edWorkDescr.CanFocus then
      edWorkDescr.SetFocus;

    RefreshList(_cworkprofile);
  end;
end;

procedure TframeTimeProfileCommonView.btnNewProfileClick(Sender: TObject);
var
  prof: TProfiles;
  currhash: String;
begin
  inherited;
  prof := TProfiles.Create;
  try
    prof.Profile_type := TProfileTypeStr[_CTimelineProfile];
    TTimeProfileForm.createAndShow(prof);
  finally
    currhash :=  prof.Hash;
    prof.CalcHash;
    // Tehti tühi kirje, reaalselt mitte midagi ei salvestatud, kustutame baasist tühja kirje ära
    if currhash = prof.Hash  then
    begin
      prof.Delete(CommonData.FncBizObjectDelete);
      FreeAndNil(prof);
    end
    else
    begin
      FTimeLineProfiles.Add(prof);
      RefreshList(_ctimeprofile);
    end;
  end;
end;


// Kasutaja ajaprofiilid
procedure TframeTimeProfileCommonView.LoadTimeProfiles;
begin
  // Kas poleks targem mitte full siin teha ja profiili avamisel full teha !
  AsyncGet(TProfiles.GetURI(True) + '&profile_type=' + TProfileTypeStr[_CTimelineProfile] + '&flags=all',
    procedure(const AData: String; const AEMsg: String;
      const ANotifId: Integer; const ANotifType: TNotificationTypes; const AMiscData: NativeUInt)
    begin
      if AEMsg <> '' then
      begin
        UTools.ShowError(AEMsg);
        Exit
      end;

      FTimeLineProfiles.Clear;
      // TODO generics converter
      var tmp := TObjectList<TBase>.Create;
      var prof: TProfiles;
      var base: TBase;
      tmp.OwnsObjects := False;
      try
        TProfiles.JSONRespToDsObjects(AData, tmp);
        for base in tmp do
        begin
          prof := base as TProfiles;
          FTimeLineProfiles.Add(prof);
        end;

        RefreshList(_ctimeprofile);
      finally
        FreeAndNil(tmp);
      end;
    end);
end;

procedure TframeTimeProfileCommonView.btnNewJobClick(Sender: TObject);
var
  b: Boolean;
begin
  inherited;
  b := not panelNewJob.Visible;
  panelNewJob.Visible := b;
  if b and edWorkDescr.CanFocus then
    edWorkDescr.SetFocus;

  if not b then
  begin
    edWorkDescr.TextSettings.FontColor := CPlaceholderTextColor;
    edWorkDescr.Text := FPlaceholderMsg;
  end;
end;

constructor TframeTimeProfileCommonView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTimeLineProfiles := TObjectList<TProfiles>.Create;
  FTimeLineProfiles.OwnsObjects := True;
  // Placeholder
  FPlaceholderMsg := _t('Sisesta töökirjeldus...');
  edWorkDescr.Text := FPlaceholderMsg;
  panelNewJob.Visible := False;

  // Nö event driven
  // Cache laetud, võime tööd kohe ära laadida
  FOnCacheDownloadCompleted :=
    procedure(const ANotifType: TNotificationTypes; const AObj: TObject;
      const ANotifId: Integer; const AMessage: String; const AIsError: Boolean)
    begin
      if (ANotifType = _CNotifCachedProfileCompleted) and (ANotifId = CommonData.CacheProfileDownloadId) then
      begin
        RefreshList(_cworkprofile);
      end;
    end;

  UNotification.NotifyList.Add(FOnCacheDownloadCompleted);
  if CommonData.CacheLoaded then
    RefreshList(_cworkprofile);

  LoadTimeProfiles();
end;

destructor TframeTimeProfileCommonView.Destroy;
begin
  UNotification.NotifyList.Remove(FOnCacheDownloadCompleted);
  FTimeLineProfiles.Free;
  inherited Destroy;
end;

procedure TframeTimeProfileCommonView.edWorkDescrEnter(Sender: TObject);
begin
  inherited;
  if TEdit(Sender).Text = FPlaceholderMsg then
  begin
    TEdit(Sender).Text := '';
    TEdit(Sender).TextSettings.FontColor := CMediumBlack;
  end;
end;

procedure TframeTimeProfileCommonView.edWorkDescrExit(Sender: TObject);
begin
  if TEdit(Sender).Text = '' then
  begin
    TEdit(Sender).TextSettings.FontColor := CPlaceholderTextColor;
    TEdit(Sender).Text := FPlaceholderMsg;
  end;
end;

end.
