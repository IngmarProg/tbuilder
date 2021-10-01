{$I Conf.inc}
unit UClassificators;
// Author: Ingmar Tammeväli www.stiigo.com
interface

uses UBase, Generics.Collections;

type
  TClassificatorTypes = (
    clf_undefined = 0,
    clf_wk_levels = 1,       // tööde nivoo klassifikaatorites
    clf_employee_group = 2,  // töötajate grupp
    clf_asset_type = 3,      // vara tüüp
    clf_asset_status = 4,    // vara staatus
    clf_manufacturer = 5,    // tootja nimetused
    clf_asset_maint_intv = 6 // vara hooldus interval
  );

const
  TClassificatorTypesStr : array[TClassificatorTypes] of String = (
    'UD',
    'WL',
    'WK',
    'AT',
    'AS',
    'MF',
    'MI'
  );


type
  TClassificators = class(TBase)
  protected
    FCf_Type: String;
    FCf_Name: String;
    FCf_Value: String;
    FCf_Descr: String;
    FCf_Misc: Integer;
    FDepartment_Id: Integer;
    FCompany_Id: Integer;
  public
    property Cf_Type: String Read FCf_Type Write FCf_Type;
    property Cf_Name: String Read FCf_Name Write FCf_Name;
    property Cf_Value: String Read FCf_Value Write FCf_Value;
    property Cf_Descr: String Read FCf_Descr Write FCf_Descr;
    property Cf_Misc: Integer Read FCf_Misc Write FCf_Misc;
    property Department_Id: Integer Read FDepartment_Id Write FDepartment_Id;
    property Company_Id: Integer Read FCompany_Id Write FCompany_Id;
    constructor Create(const ACfType: String; const ACfName: String); reintroduce; overload;
  end;

type
  TClassificatorsList = TObjectList<TClassificators>;

implementation
uses UConf;

constructor TClassificators.Create(const ACfType: String; const ACfName: String);
begin
  inherited Create;
  FCf_Type := ACfType;
  FCf_Name := ACfName;
  FDepartment_Id := UConf.TConf.currDepartmentId;
  FCompany_Id := UConf.TConf.currCompanyId;
end;

end.
