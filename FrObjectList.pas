unit FrObjectList;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FrBase, FMX.Controls.Presentation, FMX.TMSBaseControl, FMX.TMSGridCell,
  FMX.TMSGridOptions, FMX.TMSGridData, FMX.TMSCustomGrid, FMX.TMSGrid,
  FMX.TMSCustomEdit, FMX.TMSSearchEdit, UPObject, System.Generics.Collections,
  UBase, System.ImageList, FMX.ImgList;

type
  TframeObjectList = class(TframeBase)
    GroupBox1: TGroupBox;
    objectgrid: TTMSFMXGrid;
    tmsObjectSrc: TTMSFMXSearchEdit;
    btnNewObject: TButton;
    procedure objectgridGetCellReadOnly(Sender: TObject; ACol, ARow: Integer;
      var AReadOnly: Boolean);
    procedure objectgridCellDblClick(Sender: TObject; ACol, ARow: Integer);
    procedure btnNewObjectClick(Sender: TObject);
  private
    const
      CColObjName = 0;
      CColObjAddr = 1;
      CColProjectMgr = 2;
      CColProjectMgrPhone = 3;
      CColObjectMgr = 4;
      CColObjectMgrPhone = 5;
  protected
    FObjList: TObjectList<TBase>;
    procedure FillRows;
  public
    // Kasutame maksimaalselt andmete puhverdamist, seda laetud raami nimistut saavad ka teised raamid kasutada
    property ObjList: TObjectList<TBase> Read FObjList;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadData(const AJson: String = ''); override;
  end;

type
  TPObjectHelper = class helper for TPObject
  end;

var
  frameObjectList: TframeObjectList;

implementation
uses FCommonForm, UTypes;

{$R *.fmx}

procedure TframeObjectList.btnNewObjectClick(Sender: TObject);
var
  pobj: TPObject;
  ok: Boolean;
begin
  ok := False;
  pobj := TPObject.Create;
  try
    ok := TCommonForm.createForm(_fraObject, pobj);
  finally
    if not ok then
      FreeAndNil(pobj)
    else
    begin
      FObjList.Add(pobj as TBase);
      FillRows;
    end;
  end;
end;

constructor TframeObjectList.Create(AOwner: TComponent);
var
  ctitle: String;
begin
  inherited Create(AOwner);
  objectgrid.RowCount := 1;
  FObjList := TObjectList<TBase>.Create;
  FObjList.OwnsObjects := True;

  for var col: Integer := 0 to 5 do
  begin
    case col of
      CColObjName: begin
        ctitle := _t('Objekti nimi');
      end;
      CColObjAddr: begin
        ctitle := _t('Aadress');
      end;
      CColProjectMgr: begin
        ctitle := _t('Projektijuht');
      end;
      CColProjectMgrPhone: begin
        ctitle := _t('Telefon');
      end;
      CColObjectMgr: begin
        ctitle := _t('Objektijuht');
      end;
      CColObjectMgrPhone: begin
        ctitle := _t('Telefon');
      end;
    end;
    objectgrid.Cells[col, 0] := ctitle;
    objectgrid.FontSizes[col, 0] := CCommonGridTitleFontSize;
    objectgrid.ReadOnlys[col, 0] := True;
  end;
end;

destructor TframeObjectList.Destroy;
begin
  FreeAndNil(FObjList);
  inherited Destroy;
end;

procedure TframeObjectList.FillRows;
var
  obj: TBase;
  rownr: Integer;
begin
  objectgrid.BeginUpdate;
  try
    objectgrid.RowCount := 1 + FObjList.Count;
    rownr := 1;
    for obj in FObjList do
      with obj as TPObject do
      begin
        objectgrid.Objects[CColObjName, rownr] := obj;
        objectgrid.Cells[CColObjName, rownr] := ObjectName;
        objectgrid.Cells[CColObjAddr, rownr] := GetFullAddress;
        objectgrid.Cells[CColProjectMgr, rownr] := GetProjectManagerName;
        objectgrid.Cells[CColProjectMgrPhone, rownr] := GetProjectManagerPhone;
        objectgrid.Cells[CColObjectMgr, rownr] := GetObjectManagerName;
        objectgrid.Cells[CColObjectMgrPhone, rownr] := GetObjectManagerPhone;
        objectgrid.ReadOnlys[CColObjectMgrPhone, rownr] := True;
        Inc(rownr);
      end;
  finally
    objectgrid.EndUpdate;
  end;
  objectgrid.Repaint;
end;

procedure TframeObjectList.LoadData(const AJson: String = '');
begin
  TPObject.JSONRespToDsObjects(AJson, FObjList);
  FillRows;
end;

procedure TframeObjectList.objectgridCellDblClick(Sender: TObject; ACol,
  ARow: Integer);
var
  data: TBase;
begin
  data := objectgrid.Objects[CColObjName, ARow] as TBase;
  if Assigned(data) then
  begin
    TCommonForm.createForm(_fraObject, data);
    FillRows;
  end;
end;

procedure TframeObjectList.objectgridGetCellReadOnly(Sender: TObject; ACol,
  ARow: Integer; var AReadOnly: Boolean);
begin
  inherited;
  AReadOnly := True;
end;

end.
