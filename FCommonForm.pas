unit FCommonForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FrBase, UBase, FMX.Objects;

type
  TCommonFormLoadFrame = (_fraObject, _fraEmployee);

type
  TCommonForm = class(TForm)
    bgrect: TRectangle;
    ToolBar1: TToolBar;
    btnSave: TSpeedButton;
    btnClose: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  protected
    FDataSaved: Boolean;
    FBase: TFrameBase;
    FData: TBase;
  public
    class function createForm(const AFrameToLoad: TCommonFormLoadFrame; const AData: TBase;
      const AHeight: Integer = 0; const AWidth: Integer = 0):Boolean;
  end;

implementation
uses FrObject, FrEmployee, UDataAndImgmodule, UTypes, UTools;
{$R *.fmx}

procedure TCommonForm.btnCloseClick(Sender: TObject);
begin
  ModalResult := MrCancel;
end;

procedure TCommonForm.btnSaveClick(Sender: TObject);
begin
  if Assigned(FBase) then
  begin
    FBase.Save();
    FDataSaved := True;
    if btnClose.CanFocus then
      btnClose.SetFocus;
  end;
end;

class function TCommonForm.createForm;
var
  frm: TCommonForm;
  frobj: TframeObject;
  fremp: TframeEmployee;
begin
  frm := TCommonForm.Create(nil);
  frm.FData := AData;
  frm.FBase := nil;
  frm.Caption := ''; // TODO
  if AWidth > 0 then
    frm.Width := AWidth;

  if AHeight > 0 then
    frm.Height := AHeight;

  try
    case AFrameToLoad of
      _fraObject: begin
        frobj := TframeObject.Create(frm);
        frobj.LoadObj(AData);
        frobj.Parent := frm;
        frobj.Align := TAlignLayout.Client;
        frobj.mComments.Width := 487;
        frm.FBase := frobj as TframeBase;
        // frobj.Height := frm.Height - 64;
      end;
      _fraEmployee: begin
        fremp := TframeEmployee.Create(frm);
        fremp.LoadObj(AData);
        fremp.Parent := frm;
        fremp.Align := TAlignLayout.Client;
        frm.FBase := fremp as TframeBase;
      end;
    end;

    Result := (frm.ShowModal = mrOk) or (frm.FDataSaved);
  finally
    FreeAndNil(frm);
  end;
end;

procedure TCommonForm.FormCreate(Sender: TObject);
begin
  bgrect.Fill.Color := CLightGrayV3; // TODO tulevikus tausta värvi muutmine
  btnSave.Text := _t('Salvesta');
  btnClose.Text := _t('Sulge');
end;

procedure TCommonForm.FormShow(Sender: TObject);
begin
  if Assigned(FBase) then
    FBase.FocusFrameFirstControl();
end;

end.
