program TBuilder;

{$R *.dres}

uses
  System.StartUpCopy,
  FMX.Forms,
  FMainForm in 'FMainForm.pas' {MainForm},
  FrAddress in 'FrAddress.pas' {frameAddress: TFrame},
  UBase in 'UBase.pas',
  UAddress in 'UAddress.pas',
  UTools in 'UTools.pas',
  UDepartment in 'UDepartment.pas',
  UProfiles in 'UProfiles.pas',
  UConf in 'UConf.pas',
  UTypes in 'UTypes.pas',
  UPHPClassesBuilder in 'UPHPClassesBuilder.pas',
  UEmployee in 'UEmployee.pas',
  FrBase in 'FrBase.pas' {frameBase: TFrame},
  FrStaffManagement in 'FrStaffManagement.pas' {frameStaffManagement: TFrame},
  UClassificators in 'UClassificators.pas',
  FrTimeProfileCommonView in 'FrTimeProfileCommonView.pas' {frameTimeProfileCommonView: TFrame},
  FrWarehouse in 'FrWarehouse.pas' {frameWarehouse: TFrame},
  UDataAndImgmodule in 'UDataAndImgmodule.pas' {CommonData: TDataModule},
  FrAssets in 'FrAssets.pas' {frameAssets: TFrame},
  FrObject in 'FrObject.pas' {frameObject: TFrame},
  FrObjectList in 'FrObjectList.pas' {frameObjectList: TFrame},
  UPObject in 'UPObject.pas',
  FCommonForm in 'FCommonForm.pas' {CommonForm},
  FrTimeProfileEntry in 'FrTimeProfileEntry.pas' {frameTimeProfileEntry: TFrame},
  FrTimeProfile in 'FrTimeProfile.pas' {frameTimeProfile: TFrame},
  UNotification in 'UNotification.pas',
  UProfileItemGrouping in 'UProfileItemGrouping.pas',
  UAsyncDownloader in 'UAsyncDownloader.pas',
  FTimeProfile in 'FTimeProfile.pas' {TimeProfileForm},
  FrEmployee in 'FrEmployee.pas' {frameEmployee: TFrame},
  UAssets in 'UAssets.pas',
  FrEmployeeList in 'FrEmployeeList.pas' {frameWorkerList: TFrame};

{$R *.res}

begin

  Application.Initialize;
  {$IFDEF DEBUG}
  TConf.ServiceURL := 'http://www.stiigo.com/tbuilder/webservice.php';
  // ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  Application.CreateForm(TCommonData, CommonData);
  Application.CreateForm(TMainForm, MainForm);
  // Application.CreateForm(TframeTimeProfileEntry, frameTimeProfileEntry);
  // Application.CreateForm(TframeTimeProfile, frameTimeProfile);
  Application.Run;
end.
