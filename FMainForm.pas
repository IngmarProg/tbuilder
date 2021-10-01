// {"uuid":171480368,"id":0,"err:":"Duplicate entry 'PPH insert-0' for key 'IDX_department_company'"}
unit FMainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Platform,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Menus, FMX.TreeView, FMX.Layouts,
  FMX.MultiView, FMX.Edit, FMX.EditBox, FMX.NumberBox, FMX.DateTimeCtrls,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FrAddress, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  FMX.TabControl, FrStaffManagement, System.ImageList, FMX.ImgList,
  FMX.TMSBaseControl, FMX.TMSGridCell, FMX.TMSGridOptions, FMX.TMSGridData,
  FMX.TMSCustomGrid, FMX.TMSGrid, FMX.ListBox, FMX.TMSTableView,
  FMX.TMSCustomEdit, FMX.TMSEdit, FMX.TMSTreeViewBase, FMX.TMSTreeViewData,
  FMX.TMSCustomTreeView, FMX.TMSTreeView, FrBase, FrTimeProfileCommonView,
  FrWareHouse, FrAssets, System.Generics.Collections, FrObjectList,
  FMX.ComboEdit, FrTimeProfileEntry , FrTimeProfile, UNotification,
  FrEmployeeList;

type
  // 31.01.2020
  TMainForm = class(TForm)
    pnlLeft: TPanel;
    split: TSplitter;
    Panel1: TPanel;
    Mainmenu: TMainMenu;
    MenuItem1: TMenuItem;
    Lang1: TLang;
    tabCtrl: TTabControl;
    tabTimingProf: TTabItem;
    lstTopics: TListView;
    tabObjects: TTabItem;
    fraObjectList: TframeObjectList;
    Button1: TButton;
    frmImageList: TImageList;
    fraTimeProfile: TframeTimeProfileCommonView;
    tabEmployee: TTabItem;
    StatusBar1: TStatusBar;
    fraWorkerList: TframeWorkerList;
    procedure pnlLeftResize(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lstTopicsItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure lstTopicsKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  protected
    FnCacheDownloadCompletedEvent: TOnNotifyEvent;
    FPageLookup : TDictionary<TListViewItem, TTabItem>;
    procedure LoadTObjectList();
    procedure LoadWorkerList();
    function _t(const AStr: String): String;
    procedure ChooseTab;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation
uses
  Json, UBase, UTools, UDepartment, UProfiles, UAddress, UPObject, UEmployee,
  UDataAndImgmodule, UAsyncDownloader, UProfileItemGrouping,
  UConf, FCommonForm;

{$R *.fmx}
{$R *.Windows.fmx MSWINDOWS}

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPageLookup :=  TDictionary<TListViewItem, TTabItem>.Create;
end;

destructor TMainForm.Destroy;
begin
  FreeAndNil(FPageLookup);
  inherited Destroy;
end;

function TMainForm._t(const AStr: String): String;
begin
  Result := AStr;
end;

procedure TMainForm.LoadTObjectList();
begin
 AsyncGet(TPObject.GetURI(True),
    procedure(const AData: String; const AEMsg: String;
      const ANotifId: Integer; const ANotifType: TNotificationTypes; const AMiscData: NativeUInt)
    begin
      if AEMsg <> '' then
      begin
        UTools.ShowError(AEMsg);
        Exit
      end;

      fraObjectList.LoadData(AData);
    end);
end;

procedure TMainForm.LoadWorkerList();
begin
   AsyncGet(TEmployee.GetURI(True),
    procedure(const AData: String; const AEMsg: String;
      const ANotifId: Integer; const ANotifType: TNotificationTypes; const AMiscData: NativeUInt)
    begin
      if AEMsg <> '' then
      begin
        UTools.ShowError(AEMsg);
        Exit
      end;

      fraWorkerList.LoadData(AData);
    end);
end;



procedure TMainForm.FormCreate(Sender: TObject);
var
  item: TListViewItem;
begin
  FnCacheDownloadCompletedEvent :=
    procedure(const ANotifType: TNotificationTypes;
      const AObj: TObject; const ANotifId: Integer; const AMessage: String; const AIsError: Boolean)
    var
      base: TBase;
      basebfr: TObjectList<TBase>;
    begin
      if (ANotifType = _CNotifCachedProfileCompleted) then
      begin
        LoadTObjectList();
        LoadWorkerList();
      end;
    end;


  UNotification.NotifyList.Add(FnCacheDownloadCompletedEvent);
  tabCtrl.TabPosition := TTabPosition.None;
  // ---
  pnlLeft.Width := 230;
  item := lstTopics.Items.Add;
  item.Text := _t('Ajavõtu profiilid');
  item.Accessory := TAccessoryType.More;
  lstTopics.Selected := item;
  FPageLookup.Add(item, tabTimingProf);
{
  pnlLeft.Width := 230;
  item := lstTopics.Items.Add;
  item.Text := _t('Ladu sisestus');
  item.Accessory := TAccessoryType.More;
  FPageLookup.Add(item, tabWarehouse);

  pnlLeft.Width := 230;
  item := lstTopics.Items.Add;
  item.Text := _t('Vara');
  item.Accessory := TAccessoryType.More;
  FPageLookup.Add(item, tabAssets);
}
  pnlLeft.Width := 230;
  item := lstTopics.Items.Add;
  item.Text := _t('Objektid');
  item.Accessory := TAccessoryType.More;
  FPageLookup.Add(item, tabObjects);

  pnlLeft.Width := 230;
  item := lstTopics.Items.Add;
  item.Text := _t('Töötajad');
  item.Accessory := TAccessoryType.More;
  FPageLookup.Add(item, tabEmployee);


  lstTopics.Selected := lstTopics.Items.Item[0];
  lstTopics.Selected := item;

//  tabCtrl.ActiveTab := tabTimingProf;
//  tabCtrl.ActiveTab := tabObjects;
  tabCtrl.ActiveTab := tabEmployee;


  CommonData.LoadCacheData();
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
//  if Self.Width < 885 then
//    Self.Width := 885;
  if Self.Width < 1100 then
   Self.Width := 1100;
end;

procedure TMainForm.FormShow(Sender: TObject);
{$IFDEF DEBUG}
var
  notif: TOnNotifyEvent;
{$ENDIF}
begin
  {$IFDEF DEBUG}
  Button1.Visible := False;
  {
  notif :=
    procedure(const ANotifType: TNotificationTypes; const AObj: TObject;
      const ANotifId: Integer; const AMessage: String; const AIsError: Boolean)
  var
    prof: TProfiles;
    filt: TStringList;
  begin
    if (ANotifType <> _CNotifCachedDataDownloadCompleted) or
      (ANotifId <> CommonData.CacheProfileDownloadId) or
      (CommonData.CachedItemsRef > 0) then
      Exit;

    filt := TStringList.Create;
    filt.Delimiter := '&';
    filt.Add('flags=all');
    prof := TProfiles.JSONRespToSingleDsObject(CommonData.FncBizObjectReadData, 85, filt) as TProfiles;
    filt.Free;

    // frameTimeProfileCommonView1.LoadData(prof);
    // showmessage(prof.ToJson);
    // frameTimeProfile1.LoadData(TProfiles.Create); // Uus kirje
    //  self.frameTimeProfileCommonView1.LoadData;
    //  self.frameAssets1.LoadData;
  end;
  NotifyList.Add(notif);
  }
  {$ENDIF}
end;

procedure TMainForm.ChooseTab;
var
  key: TListViewItem;
begin
  if Assigned(lstTopics.Selected) then
    for key in FPageLookup.Keys do
      if key = lstTopics.Selected then
      begin
        tabCtrl.ActiveTab := FPageLookup.Items[key];
        break;
      end;
end;

procedure TMainForm.lstTopicsItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
  ChooseTab;
end;

procedure TMainForm.lstTopicsKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Shift = [] then
    ChooseTab;
end;

procedure TMainForm.MenuItem1Click(Sender: TObject);
begin
  Self.Close;
end;

procedure TMainForm.pnlLeftResize(Sender: TObject);
begin
  if (Sender is TPanel) then
  with TPanel(Sender) do
    if (Width < 3) then
      Width := 3
    else
    if (Width > 180) then
      Width := 180;
end;

end.
