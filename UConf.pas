unit UConf;
// Author: Ingmar Tammeväli www.stiigo.com
interface

const
  CWebPath =
  {$IFDEF DEBUG}
  'https://www.stiigo.com/tbuilder/'
  //  'http://127.0.0.1/tbuilder/'
  {$ELSE}
  'https://www.stiigo.com/tbuilder/'
  {$ENDIF};
  CWebService = CWebPath + 'webservice.php';
  CWebFileUpload = CWebPath + 'upload.php';


{$IFDEF DEBUG}
const
  CPhpRootDrive = 'R:/';
  CPhpRootDir = 'R:/TBuilder/Php/';
{$ENDIF}

const
  CDbName = 'stiigo'; // sqllite

type
  TConf = class
  public
    class var ServiceURL: String;
    class var ServiceUsr: String;
    class var ServicePwd: String;
    class var currDepartmentId: Integer;
    class var currCompanyId: Integer;
    class var currUserId: Integer;
    class var currEmployeeId: Integer;
    class var currEmployeeGroupId: Integer;
  end;

implementation

end.
