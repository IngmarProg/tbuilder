unit FrAssets;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FrBase, FMX.Edit, FMX.Controls.Presentation, FMX.ComboEdit, FMX.DateTimeCtrls,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Objects, FMX.TMSCustomEdit,
  FMX.TMSSearchEdit, UDataAndImgmodule, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  System.ImageList, FMX.ImgList, UBase, UAssets;

type
  TframeAssets = class(TframeBase)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    edAssetName: TEdit;
    Label2: TLabel;
    cmbAssetType: TComboEdit;
    Label3: TLabel;
    cmbSupervisor: TComboEdit;
    Label4: TLabel;
    cmbBaseWarehouse: TComboEdit;
    CalloutPanel1: TCalloutPanel;
    qrCode: TImage;
    Label5: TLabel;
    cmbStatus: TComboEdit;
    Label6: TLabel;
    edModel: TEdit;
    Label14: TLabel;
    edBronStart: TDateEdit;
    Label16: TLabel;
    Label15: TLabel;
    edBronEnd: TDateEdit;
    Label7: TLabel;
    edSerialNr: TEdit;
    Label8: TLabel;
    edPurchaseDate: TDateEdit;
    Label9: TLabel;
    edWarrantyExp: TDateEdit;
    Label10: TLabel;
    edSellerName: TEdit;
    Label11: TLabel;
    edNtxmaintenance: TDateEdit;
    Label12: TLabel;
    cmbMaintIntv: TComboEdit;
    Label13: TLabel;
    edComments: TMemo;
    Edit1: TEdit;
    Label17: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel4: TPanel;
    edFile: TEdit;
    SpeedButton2: TSpeedButton;
    tmsWorkTypes: TTMSFMXSearchEdit;
    btnSaveFile: TSpeedButton;
    dlgOpenFile: TOpenDialog;
    btnOpenFpth: TSpeedButton;
    lstAssetFiles: TListView;
    Label18: TLabel;
    edAssetCode: TEdit;
    cmbManufacturer: TComboEdit;
    procedure btnOpenFpthClick(Sender: TObject);
  private
  public
    constructor Create(AOwner: TComponent); override;
    procedure FocusFrameFirstControl; override;
    procedure LoadObj(const AObj: TBase); override;
    procedure Save(); override;
  end;

var
  frameAssets: TframeAssets;

implementation
uses UTools, UConf, UClassificators;

{$R *.fmx}

procedure TframeAssets.btnOpenFpthClick(Sender: TObject);
begin
  inherited;
{
  if dlgOpenFile.Execute then
  begin
  end;
}
end;

constructor TframeAssets.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  qrCode.Bitmap.Assign(frameImageList.Bitmap(TsizeF.Create(85,85), CImgDymmyOcrCode));
end;

procedure TframeAssets.FocusFrameFirstControl;
begin
  if edAssetName.CanFocus then
    edAssetName.SetFocus;
end;


procedure TframeAssets.LoadObj(const AObj: TBase);
var
  b: Boolean;
  lvitem: TListViewItem;
  lvdelete: TListItemImage;
begin
  FBizObjBase := AObj;
  lvitem := lstAssetFiles.Items.Add;
  lvitem.Data['Data1'] := 'XFile_001_C2500.pdf'; // TEST TEST TEST
  lvdelete := lvitem.Objects.FindObjectT<TListItemImage>('Img');
  lvdelete.Bitmap := frameImageList.Bitmap(TsizeF.Create(32,32), CImgDelete);

  with FBizObjBase as TAssets do
  begin
    edAssetName.Text := Asset_name;
    edAssetCode.Text := Asset_code;
    FillCombo(cmbAssetType, clf_asset_type, Type_Clf_Id);
    FillCombo(cmbSupervisor, mtp_assets_supervisor, Sp_Employee_Id);
    FillCombo(cmbBaseWarehouse, mtp_warehouses, Base_Warehouse_Id);
    FillCombo(cmbStatus, clf_asset_status, Status_Clf_Id);
    FillCombo(cmbManufacturer, clf_manufacturer);

    edModel.Text := Model_name;
    if Manufact_Clf_Id > 0 then
      CmbSetData(cmbManufacturer, Manufact_Clf_Id)
    else
      Manufact_name := cmbManufacturer.Text;

    edSerialNr.Text := Serial_nr;
    b := DateTimeIsEmpty(Purchase_date);
    edPurchaseDate.IsEmpty := b;
    if not b then
      edPurchaseDate.DateTime := Purchase_date;

    b := DateTimeIsEmpty(Warranty_Expiration_date);
    edWarrantyExp.IsEmpty := b;
    if not b then
      edWarrantyExp.DateTime := Warranty_Expiration_date;
    edSellerName.Text := Seller_name;

    b := DateTimeIsEmpty(Next_maintenance_date);
    edNtxmaintenance.IsEmpty := b;
    if not b then
      edNtxmaintenance.DateTime := Next_maintenance_date;

    FillCombo(cmbMaintIntv, clf_asset_maint_intv);
    CmbSetData(cmbMaintIntv, Maintenance_interval_clf_id);

    b := DateTimeIsEmpty(Booking_start);
    edBronStart.IsEmpty := b;
    if not b then
      edBronStart.DateTime := Booking_start;

    b := DateTimeIsEmpty(Booking_end);
    edBronEnd.IsEmpty := b;
    if not b then
      edBronEnd.DateTime := Booking_end;
    edComments.Lines.Text := Comments;
  end;
end;

procedure TframeAssets.Save();
begin
  if Assigned(FBizObjBase) then
  with FBizObjBase as TAssets do
  begin
    Asset_name := edAssetName.Text;
    Asset_code := edAssetCode.Text;
    Type_Clf_Id := CmbGetData(cmbAssetType);
    Sp_Employee_Id := CmbGetData(cmbSupervisor);
    Base_Warehouse_Id := CmbGetData(cmbBaseWarehouse);
    Status_Clf_Id := CmbGetData(cmbStatus);
    Model_name := edModel.Text;
    Manufact_Clf_Id := CmbGetData(cmbManufacturer);
    if Manufact_Clf_Id < 1 then
      Manufact_name := cmbManufacturer.Text;

    Serial_nr := edSerialNr.Text;
    Purchase_date := edPurchaseDate.date;
    Warranty_Expiration_date := edWarrantyExp.Date;
    Seller_name := edSellerName.Text;

    Next_maintenance_date := edNtxmaintenance.Date;
    Maintenance_interval_clf_id := CmbGetData(cmbMaintIntv);

    Booking_start := edBronStart.Date;
    Booking_end := edBronEnd.Date;
    Comments := edComments.Lines.Text;

    Department_id := TConf.currDepartmentId;
    Company_id := TConf.currCompanyId;

    FBizObjBase.Save(CommonData.FncBizObjectSave);
  end;

end;
end.
