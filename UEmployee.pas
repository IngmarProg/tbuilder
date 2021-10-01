unit UEmployee;
// Author: Ingmar Tammeväli www.stiigo.com

interface
uses UBase;

type
  TEmployee = class(TBase)
  protected
    FFirstName: String;
    FLastName: String;
    FReg_Nr: String;
    FEmail: String;
    FPhone: String;
    FOccupation: String;
    FGroup_Clf_id: Integer;
    FActive: Boolean; // sisuliselt kui false, siis töötaja lahkunud
    FDepartment_id: Integer;
    FCompany_id: Integer;
  public
    property FirstName: String Read FFirstName Write FFirstName;
    property LastName: String Read FLastName Write FLastName;
    property Reg_Nr: String Read FReg_Nr Write FReg_Nr;
    property Email: String Read FEmail Write FEmail;
    property Phone: String Read FPhone Write FPhone;
    property Occupation: String Read FOccupation Write FOccupation;
    property Group_Clf_id: Integer Read FGroup_Clf_Id Write FGroup_Clf_Id;
    property Active: Boolean Read FActive Write FActive;
    property Department_id: Integer Read FDepartment_id Write FDepartment_id;
    property Company_id: Integer Read FCompany_id Write FCompany_id;
    constructor Create; override;
  end;

type
  TCachedEmployeeGetDataType = (_ced_name  = 0, _ced_email, _ced_address, _ced_phone);

  function _getCachedEmployeeData(const AEmployeeId: Integer; const ADataType: TCachedEmployeeGetDataType): String;

implementation
uses UConf;

{$message HINT 'TODO: _getCachedEmployeeData' }
function _getCachedEmployeeData;
begin
  Result := 'test';
end;

constructor TEmployee.Create;
begin
  inherited Create;
  Department_id := TConf.currDepartmentId;
  Company_id := TConf.currCompanyId;
  Active := True;
end;
end.
