unit FrObject;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FrBase, FMX.ComboEdit, FrAddress, FMX.Edit, FMX.Controls.Presentation,
  UPObject, System.ImageList, FMX.ImgList, UBase, UTools, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo;

type
  TframeObject = class(TframeBase)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    edObjectName: TEdit;
    Label3: TLabel;
    frAddress: TframeAddress;
    cmbProjectMgr: TComboEdit;
    cmbObjectMgr: TComboEdit;
    Label2: TLabel;
    Label4: TLabel;
    cmbTimeProfile: TComboEdit;
    Label5: TLabel;
    cmbStatus: TComboEdit;
    Label6: TLabel;
    mComments: TMemo;
  private
  public
    constructor Create(AOwner: TComponent); override;
    procedure FocusFrameFirstControl; override;
    procedure LoadObj(const AObj: TBase); override;
    procedure Save(); override;
  end;


implementation
uses UDataAndImgmodule, UAddress;
{$R *.fmx}

constructor TframeObject.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure TframeObject.FocusFrameFirstControl;
begin
  if edObjectName.CanFocus then
    edObjectName.SetFocus;
end;

procedure TframeObject.LoadObj(const AObj: TBase);
begin
  FBizObjBase := AObj;
  with AObj as TPObject do
  begin
    edObjectName.Text := ObjectName;
    // ObjectCode := '';
    // Latitude := 0;
    // Longitude := 0;
    // AllowedRangeDiff := 0;
    if ProjectManager_Id > 0 then
      CmbSetData(cmbProjectMgr, ProjectManager_Id)
    else
      cmbProjectMgr.Text := ProjectManager;

    if ObjectManager_Id > 0 then
      CmbSetData(cmbObjectMgr, ObjectManager_Id)
    else
      cmbObjectMgr.Text := ObjectManager;

    CmbSetData(cmbStatus, Status_Clf_Id);
    // CmbSetData(cmbTimeProfile, TimeProfile_Id);
    mComments.Lines.Add(Comments);
    // --
    frAddress.LoadData(AObj as TAddress);
  end;
end;

procedure TframeObject.Save();
begin
  if Assigned(FBizObjBase) then
  with FBizObjBase as TPObject do
  begin
    ObjectName := edObjectName.Text;
    // ObjectCode := '';
    // Latitude := 0;
    // Longitude := 0;
    // AllowedRangeDiff := 0;
    ProjectManager_Id := CmbGetData(cmbProjectMgr);
    if ProjectManager_Id < 1 then
      ProjectManager := cmbProjectMgr.Text
    else
      ProjectManager := '';

    ObjectManager_Id := CmbGetData(cmbObjectMgr);
    if ObjectManager_Id < 1 then
      ObjectManager := cmbObjectMgr.Text
    else
      ObjectManager := '';

    Status_Clf_Id := CmbGetData(cmbStatus);
    // TimeProfile_Id := CmbGetData(cmbTimeProfile);
    Comments := mComments.Lines.Text;
    // --
    frAddress.AssignData(FBizObjBase as TAddress);

    FBizObjBase.Save(CommonData.FncBizObjectSave);
  end;
end;

end.
