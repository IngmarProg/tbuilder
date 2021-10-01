unit UAssets;

interface
uses UBase;

type
  TAssets = class(TBase)
  protected
    FAsset_name : String;
    FAsset_code : String;
    FType_Clf_Id: Integer;
    FSp_Employee_Id: Integer;
    FBase_Warehouse_Id: Integer;
    FStatus_Clf_Id: Integer;
    FModel_name: String;
    FManufact_Clf_Id: Integer;
    FManufact_name: String;
    FSerial_nr: String;
    FPurchase_date: TDateTime;
    FWarranty_Expiration_date: TDateTime;
    FSeller_name: String;
    FGroup_Clf_id: Integer;
    FNext_maintenance_date: TDateTime;
    FMaintenance_interval_clf_id: Integer;
    FDepartment_id: Integer;
    FCompany_id: Integer;
    FComments: String;
    FBooking_start: TDateTime;
    FBooking_end: TDateTime;
    FBookedby_employee_id: Integer;
    FAvailable_units: Integer;
  public
    property Asset_name: String Read FAsset_name Write FAsset_name;
    property Asset_code: String Read FAsset_code Write FAsset_code;
    property Type_Clf_Id: Integer Read FType_Clf_Id Write FType_Clf_Id;
    property Sp_Employee_Id: Integer Read FSp_Employee_Id Write FSp_Employee_Id;
    property Base_Warehouse_Id: Integer Read FBase_Warehouse_Id Write FBase_Warehouse_Id;
    property Status_Clf_Id: Integer Read FStatus_Clf_Id Write FStatus_Clf_Id;
    property Model_name: String Read FModel_name Write FModel_name;
    property Manufact_Clf_Id: Integer Read FManufact_Clf_Id Write FManufact_Clf_Id;
    property Manufact_name: String Read FManufact_name Write FManufact_name;
    property Serial_nr: String Read FSerial_nr Write FSerial_nr;
    property Purchase_date: TDateTime Read FPurchase_date Write FPurchase_date;
    property Warranty_Expiration_date: TDateTime Read FWarranty_Expiration_date Write FWarranty_Expiration_date;
    property Seller_name: String Read FSeller_name Write FSeller_name;
    property Next_maintenance_date: TDateTime Read FNext_maintenance_date Write FNext_maintenance_date;
    property Maintenance_interval_clf_id: Integer Read FMaintenance_interval_clf_id Write FMaintenance_interval_clf_id;
    property Comments: String Read FComments Write FComments;
    property Booking_start: TDateTime Read FBooking_start Write FBooking_start;
    property Booking_end: TDateTime Read FBooking_end Write FBooking_end;
    property Bookedby_employee_id: Integer Read FBookedby_employee_id Write FBookedby_employee_id;
    property Available_units: Integer Read FAvailable_units Write FAvailable_units;
    property Department_id: Integer Read FDepartment_id Write FDepartment_id;
    property Company_id: Integer Read FCompany_id Write FCompany_id;
  end;


implementation

end.
