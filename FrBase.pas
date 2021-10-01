unit FrBase;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.ExtCtrls, System.ImageList, FMX.ImgList,
  FMX.Controls.Presentation, FMX.ListBox, FMX.Edit, FrAddress, UBase;

const
  CImgSave = 0;
  CImgDelete = 1;
  CImgAddNewFile = 2;
  CImgDymmyOcrCode = 3;
  CImgPlussSign = 4;

type
  TframeBase = class(TFrame)
    Lang1: TLang;
    frameImageList: TImageList;
  protected
    FBizObjBase: TBase;
    FDataLoaded: Boolean;
    function _t(const AStr: String): String;
  public
    property DataLoaded: Boolean Read FDataLoaded Write FDataLoaded;
    procedure FocusFrameFirstControl; virtual;
    procedure LoadObj(const AObj: TBase); virtual;
    procedure LoadData(const AJson: String = ''); virtual;
    // procedure Save(); virtual; abstract;
    // procedure Cancel(); virtual; abstract;
    procedure Save(); virtual;
    procedure Cancel(); virtual;
  end;

type
  TOnDeleteFrame = reference to procedure(AFrame: TframeBase);
  TOnAddNewFrame = reference to procedure(AFrame: TframeBase);

implementation
{$R *.fmx}

procedure TframeBase.LoadObj(const AObj: TBase);
begin
  // --
end;

procedure TframeBase.LoadData(const AJson: String = '');
begin
  // --
end;

procedure TframeBase.Save();
begin
  // --
end;

procedure TframeBase.Cancel();
begin
  // --
end;

procedure TframeBase.FocusFrameFirstControl;
begin
  // --
end;

function TframeBase._t(const AStr: String): String;
begin
  Result := AStr;
end;

end.
