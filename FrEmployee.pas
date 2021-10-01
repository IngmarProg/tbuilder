unit FrEmployee;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FrBase, UBase, System.ImageList, FMX.ImgList, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Memo, FMX.ComboEdit, FMX.Edit, FMX.Controls.Presentation;

type
  TframeEmployee = class(TframeBase)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    edFirstname: TEdit;
    Label3: TLabel;
    cmbPosition: TComboEdit;
    Label2: TLabel;
    edLastName: TEdit;
    Label7: TLabel;
    edRegCode: TEdit;
    Label8: TLabel;
    edEmail: TEdit;
    Label9: TLabel;
    edPhone: TEdit;
    Label10: TLabel;
    cmbWorkerGroup: TComboEdit;
    procedure cmbWorkerGroupExit(Sender: TObject);
  private
  public
    procedure FocusFrameFirstControl; override;
    procedure LoadObj(const AObj: TBase); override;
    procedure Save(); override;
  end;

var
  frameEmployee: TframeEmployee;

implementation
uses UClassificators, UEmployee, UTools, UDataAndImgModule;

{$R *.fmx}

procedure TframeEmployee.cmbWorkerGroupExit(Sender: TObject);
begin
  ComboEditVerifySelection(Sender as TComboEdit);
end;

procedure TframeEmployee.FocusFrameFirstControl;
begin
  if edFirstname.CanFocus then
    edFirstname.SetFocus;
end;

procedure TframeEmployee.LoadObj(const AObj: TBase);
begin
  FBizObjBase := AObj;
  with AObj as TEmployee do
  begin
    edFirstname.Text := FirstName;
    edLastName.Text := LastName;
    edRegCode.Text := Reg_Nr;
    edEmail.Text := Email;
    edPhone.Text := Phone;
    cmbPosition.Text := Occupation;
    FillCombo(cmbWorkerGroup, clf_employee_group);
    cmbSetData(cmbWorkerGroup, Group_Clf_id)
  end;
end;

procedure TframeEmployee.Save();
begin
  if Assigned(FBizObjBase) then
  with FBizObjBase as TEmployee do
  begin
    FirstName := edFirstname.Text;
    LastName := edLastName.Text;
    Reg_Nr := edRegCode.Text;
    Email := edEmail.Text;
    Phone := edPhone.Text;
    Occupation := cmbPosition.Text;
    Group_Clf_id := cmbGetData(cmbWorkerGroup);
    FBizObjBase.Save(CommonData.FncBizObjectSave);
  end;

end;

end.
