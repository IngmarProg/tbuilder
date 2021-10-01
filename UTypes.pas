unit UTypes;

interface
uses Classes, System.Generics.Collections;

type
  TOnSaveData = reference to function(const AObj: TObject; var AErrMsg: String): TStringlist;
  TOnSaveData2 = reference to function(const AJson: String; var AErrMsg: String): TStringlist;

  TOnDeleteData = reference to procedure(const AObj: TObject);
  TOnDeleteData2 = reference to procedure(const AObj: TObject; const AId: TArray<Integer>; var AErrMsg: String);
  TOnReadData = reference to function(const AClassname: String; const AId: Integer;
    const AFilt: TStringlist; var AErrMsg: String): String;

const
  CDummyUserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:85.0) Gecko/20100101 Firefox/85.0';

// Misc
const
  CRLF = #13#10;
  CMYSQLEmptyDate = '0000-00-00 00:00:00';

// Colors
const
  CLightGrayV1 = $FFFCFCFC;
//  CLightGrayV2 = $FFF2F1F1;
  CLightGrayV2 = $FFF8F7F7;
  CLightGrayV3 = $FFF5F4F4;

  CPlaceholderTextColor = $FFBCBCBC;
  CMediumBlack = $FF030303;

const
  CCommonGridTitleFontSize = 10;

implementation

end.
