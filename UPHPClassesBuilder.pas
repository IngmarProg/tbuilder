{$DEFINE XAUTOCREATE_PHP_FILES}
unit UPHPClassesBuilder;
// Author: Ingmar Tammeväli www.stiigo.com

interface

implementation
uses Classes, SysUtils
{$IFDEF DEBUG}, UConf, UBase, UAddress, UDepartment, UProfiles, UEmployee,
  UClassificators, UPObject, UTools, UTypes, UProfileItemGrouping, UAssets
{$ENDIF};

{$IFDEF DEBUG}
procedure AutoBuildPHPClasses;
const
  CPHPExtFileDir = 'C:\Projektid\TBuilder\PHPIncFiles\';

  function phpIfCls(const AClassName: String; const AAddElse: Boolean = True): String;
  begin
    Result := ''
      + #09'if (strtolower($classname) == strtolower("T' + AClassName + '")) {' + CRLF
      + #09#09'$cls = new ' + AClassName + '();' + CRLF
      + #09'} ' + CRLF;
    if AAddElse then
      Result := Result + #09'else ';
  end;
var
  c1: TAddress;
  c2: TDepartment;
  c3: TProfiles;
  c4: TProfileItem;
  c5: TProfileItemAttr;
  c6: TProfileItemAttrDef;
  c7: TProfileItemGrouping;
  c8: TClassificators;
  c9: TPObject;
  c10: TEmployee;
  c11: TAssets;
  c12: TProfileItemValue;
  req: TStringlist; // meie required list
  res: TStringlist; // php resolver
  i: Integer;
  phpclsname: String;
begin

  res := TStringlist.Create;
  res.Add('');
  res.Add('function _dResolveClass($classname) {');

  req := TStringlist.Create;
  req.Add('<?php');
  req.Add(CRLF + _autocreated_header() + CRLF);

  c1 := TAddress.Create;
  req.Add(c1.BuildPHPClasses(phpclsname));
  res.Add(phpIfCls(phpclsname));
  c1.Free;

  c2 := TDepartment.Create;
  req.Add(c2.BuildPHPClasses(phpclsname));
  res.Add(phpIfCls(phpclsname));
  c2.Free;

  c3 := TProfiles.Create;
  req.Add(c3.BuildPHPClasses(phpclsname, CPHPExtFileDir));
  res.Add(phpIfCls(phpclsname));
  c3.Free;

  c4 := TProfileItem.Create;
  req.Add(c4.BuildPHPClasses(phpclsname));
  res.Add(phpIfCls(phpclsname));
  c4.Free;

  c5 := TProfileItemAttr.Create;
  req.Add(c5.BuildPHPClasses(phpclsname));
  res.Add(phpIfCls(phpclsname));
  c5.Free;

  c6 := TProfileItemAttrDef.Create;
  req.Add(c6.BuildPHPClasses(phpclsname));
  res.Add(phpIfCls(phpclsname));
  c6.Free;

  c7 :=  TProfileItemGrouping.Create;
  req.Add(c7.BuildPHPClasses(phpclsname));
  res.Add(phpIfCls(phpclsname));
  c7.Free;

  c8 := TClassificators.Create;
  req.Add(c8.BuildPHPClasses(phpclsname));
  res.Add(phpIfCls(phpclsname));
  c8.Free;

  c9 := TPObject.Create;
  req.Add(c9.BuildPHPClasses(phpclsname));
  res.Add(phpIfCls(phpclsname));
  c9.Free;

  c10 := TEmployee.Create;
  req.Add(c10.BuildPHPClasses(phpclsname));
  res.Add(phpIfCls(phpclsname));
  c10.Free;

  c11 := TAssets.Create;
  req.Add(c11.BuildPHPClasses(phpclsname));
  res.Add(phpIfCls(phpclsname));
  c11.Free;

  c12 := TProfileItemValue.Create;
  req.Add(c12.BuildPHPClasses(phpclsname));
  res.Add(phpIfCls(phpclsname));
  c12.Free;


  for i := 2 to req.Count - 1 do
    req.Strings[i] := Format('require_once("%s");', [req.Strings[i]]);
  // define('__ROOT__', dirname(dirname(__FILE__)));
  // require_once(__ROOT__.'/config.php');
  res.Add(#09#09'$cls = null;');
  res.Add(#09'return $cls;'); // @@_dResolveClass

  res.Add('}');
  req.Add(res.Text);

  req.Add('?>');
  req.SaveToFile(CPhpRootDir + 'dclasses.inc.php');
  req.Free;
  res.Free;

end;
{$ENDIF}

initialization
{$IFDEF DEBUG}
  {$IFDEF AUTOCREATE_PHP_FILES}
  if DirectoryExists(CPhpRootDrive) then
    AutoBuildPHPClasses;
  {$ENDIF}
{$ENDIF}
end.
