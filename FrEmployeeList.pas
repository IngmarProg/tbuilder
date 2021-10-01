unit FrEmployeeList;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FrBase, System.ImageList, FMX.ImgList, FMX.ComboEdit, FMX.Edit,
  FMX.Controls.Presentation, FMX.TMSBaseControl, FMX.TMSGridCell,
  FMX.TMSGridOptions, FMX.TMSGridData, FMX.TMSCustomGrid, FMX.TMSGrid,
  FMX.TMSCustomEdit, FMX.TMSSearchEdit, UBase,  System.Generics.Collections,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.GridExcelIO;

type
  TframeWorkerList = class(TframeBase)
    GroupBox1: TGroupBox;
    employeeGrid: TTMSFMXGrid;
    tmsEmployeeSrc: TTMSFMXSearchEdit;
    btnNewObject: TButton;
    tmsEmployeeGrpSrc: TTMSFMXSearchEdit;
    btnNewGroup: TButton;
    Panel1: TPanel;
    lstGroups: TListView;
    //lstGroups: TListView;
    procedure btnNewObjectClick(Sender: TObject);
    procedure btnNewGroupClick(Sender: TObject);
    procedure lstGroupsItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure lstGroupsItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure employeeGridCellDblClick(Sender: TObject; ACol, ARow: Integer);
  private
    const
      CColEmpName = 0;
      CColEmpEmail = 1;
      CColEmpPhone = 2;
      CColEmpOccupation = 3;
      CColEmpGroup = 4;
      CColEmpActive = 5;
  protected
    FEmployeeList:  TObjectList<TBase>;
    procedure FillGroups;
    procedure FillRows;
  public
    property EmployeeList: TObjectList<TBase> Read FEmployeeList;
    procedure Refresh;
    procedure LoadData(const AJson: String = ''); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  frameWorkerList: TframeWorkerList;

implementation
uses UTools, UTypes, UDataAndImgModule,
  FCommonForm, UEmployee, UClassificators;
{$R *.fmx}

procedure TframeWorkerList.btnNewObjectClick(Sender: TObject);
var
  pemp: TEmployee;
  ok: Boolean;
begin
  // savetoExcelt.XLSExport('r:\exceltest.xlsx');
  ok := False;
  pemp := TEmployee.Create;
  try
    ok := TCommonForm.createForm(_fraEmployee, pemp);
  finally
    if not ok then
      FreeAndNil(pemp)
    else
    begin
      FEmployeeList.Add(pemp as TBase);
      FillRows;
    end;
  end;
end;

procedure TframeWorkerList.FillRows;
var
  obj: TBase;
  rownr: Integer;
begin
  employeeGrid.BeginUpdate;
  try
    employeeGrid.RowCount := 1 + FEmployeeList.Count;
    rownr := 1;
    for obj in FEmployeeList do
      with obj as TEmployee do
      begin
        employeeGrid.Objects[CColEmpName, rownr] := obj;
        employeeGrid.Cells[CColEmpName, rownr] := FirstName + #32 + LastName;
        employeeGrid.Cells[CColEmpEmail, rownr] := Email;
        employeeGrid.Cells[CColEmpPhone, rownr] := Phone;
        employeeGrid.Cells[CColEmpOccupation, rownr] := Occupation;
        employeeGrid.Cells[CColEmpGroup, rownr] := GetObjectValue(Group_Clf_id, clf_employee_group);
        // employeeGrid.Cells[CColEmpActive, rownr] := Active;
        employeeGrid.Booleans[CColEmpActive, rownr] := Active;
        for var i: Integer := 0 to employeeGrid.TotalColCount - 1  do
          employeeGrid.ReadOnlys[i, rownr] := True;

        Inc(rownr);
      end;
  finally
    employeeGrid.EndUpdate;
  end;
  employeeGrid.Repaint;
end;

procedure TframeWorkerList.FillGroups;
var
  lvitem: TListViewItem;
  lvdelete: TListItemImage;
  cachegrp: TClassificators;
begin
  lstGroups.items.Clear;
  try
    lstGroups.BeginUpdate;
    lstGroups.Items.Clear;
    for cachegrp in CommonData.CachedClassificators do
    if cachegrp.Cf_Type = TClassificatorTypesStr[clf_employee_group] then
    begin
      lvitem := lstGroups.Items.Add;
      lvitem.TagObject := cachegrp;
      lvitem.Data['Data1'] := cachegrp.Cf_Name;

      lvdelete := lvitem.Objects.FindObjectT<TListItemImage>('Img');
      lvdelete.Bitmap := frameImageList.Bitmap(TsizeF.Create(32,32), CImgDelete);
    end;
  finally
    lstGroups.EndUpdate;
  end;
end;

procedure TframeWorkerList.Refresh;
begin
  FillRows;
  FillGroups;
end;

procedure TframeWorkerList.LoadData(const AJson: String = '');
begin
  TEmployee.JSONRespToDsObjects(AJson, FEmployeeList);
  Refresh;
end;

procedure TframeWorkerList.lstGroupsItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  inherited;
  // ---
end;

procedure TframeWorkerList.lstGroupsItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
  inherited;
  // --
end;

procedure TframeWorkerList.btnNewGroupClick(Sender: TObject);
var
  ok: Boolean;
  itemval: Array Of String;
  itemname: String;
  group_clf: TClassificators;
begin
  SetLength(itemval, 1);
  ok := InputQuery(_t('Uus grupp'), TArray<String>.Create(_t('Nimetus')),
    itemval,
    function(const Values: array of string): Boolean
    begin
      Result := Trim(Values[High(Values)]) <> '';
    end
  );
  if ok then
  begin
    group_clf := TClassificators.Create(TClassificatorTypesStr[clf_employee_group], itemval[High(itemval)]);
    try
      group_clf.Save(CommonData.FncBizObjectSave);
      CommonData.CachedClassificators.Add(group_clf);
      FillGroups;
    except
      on E: Exception do
      begin
        FreeAndNil(group_clf);
        Utools.ShowError(E.Message);
      end;
    end;
  end;
end;

constructor TframeWorkerList.Create(AOwner: TComponent);
var
  ctitle: String;
begin
  inherited Create(AOwner);
  employeeGrid.RowCount := 1;
  FEmployeeList := TObjectList<TBase>.Create;
  FEmployeeList.OwnsObjects := True;
  for var col: Integer := 0 to 5 do
  begin
    case col of
      CColEmpName: begin
        ctitle := _t('Nimi');
      end;
      CColEmpEmail: begin
        ctitle := _t('E-post');
      end;
      CColEmpPhone: begin
        ctitle := _t('Telefon');
      end;
      CColEmpOccupation: begin
        ctitle := _t('Amet');
      end;
      CColEmpGroup: begin
        ctitle := _t('Kasutajagrupp');
      end;
      CColEmpActive: begin
        ctitle := _t('Aktiivne');
      end;
    end;
    employeeGrid.Cells[col, 0] := ctitle;
    employeeGrid.FontSizes[col, 0] := CCommonGridTitleFontSize;
    employeeGrid.ReadOnlys[col, 0] := True;
  end;
end;

destructor TframeWorkerList.Destroy;
begin
  FreeAndNil(FEmployeeList);
  inherited Destroy;
end;

procedure TframeWorkerList.employeeGridCellDblClick(Sender: TObject; ACol,
  ARow: Integer);
var
  data: TBase;
begin
  data := employeeGrid.Objects[CColEmpName, ARow] as TBase;
  if Assigned(data) then
  begin
    TCommonForm.createForm(_fraEmployee, data);
    FillRows;
  end;
end;

end.
