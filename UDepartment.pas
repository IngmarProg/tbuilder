{$I Conf.inc}
unit UDepartment;
// Ingmar; 31.01.2020
interface
uses UAddress;

type
  TDepartment = class(TAddress)
  protected
    FDepartmentName: String;
    FComments: String;
    FCompany_id: Integer;
  public
    property DepartmentName: String Read FDepartmentName Write FDepartmentName;
    property Comments: String Read FComments Write FComments;
    property Company_id: Integer Read FCompany_id Write FCompany_id;
    // class function JSONToObject(const AJson: String): TObject; override;
  end;

implementation
uses REST.JSON;

{
class function TDepartment.JSONToObject(const AJson: String): TObject;
begin
  Result := TJson.JsonToObject<TDepartment>(AJson);
  TAddress(Result).Init();
end;
}
end.
