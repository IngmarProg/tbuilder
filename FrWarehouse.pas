unit FrWarehouse;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.ListBox, FMX.Edit, FMX.Controls.Presentation, FrAddress, FMX.Objects,
  System.ImageList, FMX.ImgList, FMX.ComboEdit,
  FrBase;

type
  TframeWarehouse = class(TframeBase)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    edWarehousename: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    frameAddress1: TframeAddress;
    cmbSupervisor: TComboEdit;
    cmbStatus: TComboEdit;
    CalloutPanel1: TCalloutPanel;
    qrCode: TImage;
  private
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  frameWarehouse: TframeWarehouse;

implementation

{$R *.fmx}

constructor TframeWarehouse.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  qrCode.Bitmap.Assign(frameImageList.Bitmap(TsizeF.Create(85,85), CImgDymmyOcrCode));
end;

end.
