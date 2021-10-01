{$I Conf.inc}
unit UPObject;
// 17.02.2021 Ingmar new object file
interface
uses UAddress, UEmployee;

type
  TPObject = class(TAddress)
  protected
    FObjectName: String;
    FObjectCode: String;
    // DD (decimal degrees)
    FLatitude: Double;
    FLongitude: Double;
    FAllowedRangeDiff: Double;
    FProjectManager_Id: Integer;
    FProjectManager: String;
    FObjectManager_Id: Integer;
    FObjectManager: String;
    // FTimeProfile_Id: Integer;
    FStatus_Clf_Id: Integer;
    FComments: String;
    FDepartment_Id: Integer;
    FCompany_Id: Integer;
  public
    property ObjectName: String Read FObjectName Write FObjectName;
    property ObjectCode: String Read FObjectCode Write FObjectCode;
    property Latitude: Double Read FLatitude Write FLatitude;
    property Longitude: Double Read FLongitude Write FLongitude;
    property AllowedRangeDiff: Double Read FAllowedRangeDiff Write FAllowedRangeDiff;
    property ProjectManager_Id: Integer Read FProjectManager_Id Write FProjectManager_Id;
    property ProjectManager: String Read FProjectManager Write FProjectManager;
    // andmebaasis pole töötajana antud isikut projektijuhti ja objektijuhti, siis "freehanded" sisestus
    property ObjectManager_Id: Integer Read FObjectManager_Id Write FObjectManager_Id;
    property ObjectManager: String Read FObjectManager Write FObjectManager;
    // Tegelikkuses peab olema ajaprofiil objektiga seotud, mitte nagu algne info anti
    // property TimeProfile_Id: Integer Read FTimeProfile_Id Write FTimeProfile_Id;
    property Status_Clf_Id: Integer Read FStatus_Clf_Id Write FStatus_Clf_Id;
    property Comments: String Read FComments Write FComments;
    property Department_Id: Integer Read FDepartment_Id Write FDepartment_Id;
    property Company_Id: Integer Read FCompany_Id Write FCompany_Id;
    function GetProjectManagerName: String;
    function GetProjectManagerPhone: String;
    function GetObjectManagerName: String;
    function GetObjectManagerPhone: String;
    function GetFullAddr: String;
    constructor Create; override;
  end;

implementation

constructor TPObject.Create;
begin
  inherited Create;
end;

function TPObject.GetProjectManagerName: String;
begin
  if ProjectManager <> '' then
    Result := ProjectManager
  else
    Result := _getCachedEmployeeData(FProjectManager_Id, _ced_name);
end;

function TPObject.GetProjectManagerPhone: String;
begin
  Result := _getCachedEmployeeData(FProjectManager_Id, _ced_phone);
end;

function TPObject.GetObjectManagerName: String;
begin
  if ObjectManager <> '' then
    Result := ObjectManager
  else
    Result := _getCachedEmployeeData(FObjectManager_Id, _ced_name);
end;

function TPObject.GetObjectManagerPhone: String;
begin
  Result := _getCachedEmployeeData(FObjectManager_Id, _ced_phone);
end;

function TPObject.GetFullAddr: String;
begin
  Result := '';
end;
end.
