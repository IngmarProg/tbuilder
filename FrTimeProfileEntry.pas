unit FrTimeProfileEntry;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FrBase, System.ImageList, FMX.ImgList, FMX.ListBox, FMX.Controls.Presentation,
  FMX.Objects, UProfiles, UTypes;


type
  TframeTimeProfileEntry = class(TframeBase)
    backgroundRect: TRectangle;
    cbAddAmount: TCheckBox;
    cbAddTime: TCheckBox;
    cbAmountRequired: TCheckBox;
    cbCommentReq: TCheckBox;
    cbComments: TCheckBox;
    cbPicture: TCheckBox;
    cbPictureRequired: TCheckBox;
    cbStartConfirm: TCheckBox;
    cmbLevel: TComboBox;
    cmbWkType: TComboBox;
    cbSubLevelReq: TCheckBox;
    ImageList1: TImageList;
    btnAdd: TSpeedButton;
    btnRemove: TSpeedButton;
    cbPrevChoice: TCheckBox;
    procedure btnAddClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
  protected
    FFrameIndex: Integer;
    FProfileItem: TProfileItem;
    FOnAddNewFrame: TOnAddNewFrame;
    FOnDeleteFrame: TOnDeleteFrame;
    procedure setFrameIndex(const v: Integer);
    procedure setProfileItem(const v: TProfileItem);
    procedure OnAddAmountChecked(Sender: TObject);
    procedure OnAddCommentsChecked(Sender: TObject);
    procedure OnAddPictureChecked(Sender: TObject);
  public
    property OnAddNewFrame: TOnAddNewFrame Read FOnAddNewFrame Write FOnAddNewFrame;
    property OnDeleteFrame: TOnDeleteFrame Read FOnDeleteFrame Write FOnDeleteFrame;
    property FrameIndex: Integer Read FFrameIndex Write setFrameIndex;
    property ProfileItem: TProfileItem Read FProfileItem Write setProfileItem;
    procedure AssignLevels(const ALevel: TStrings);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  frameTimeProfileEntry: TframeTimeProfileEntry;

implementation

{$R *.fmx}


procedure TframeTimeProfileEntry.btnAddClick(Sender: TObject);
begin
  inherited;
  if Assigned(OnAddNewFrame) then
    OnAddNewFrame(Self);
end;

procedure TframeTimeProfileEntry.btnRemoveClick(Sender: TObject);
begin
  inherited;
  if Assigned(OnDeleteFrame) then
    OnDeleteFrame(Self);
end;

procedure TframeTimeProfileEntry.OnAddAmountChecked(Sender: TObject);
var
  b: Boolean;
begin
  if TCheckBox(Sender).IsFocused then
  begin
    b := not TCheckBox(Sender).IsChecked;
    cbAmountRequired.Enabled := b;
    if not b then
      cbAmountRequired.IsChecked := False;
  end;
end;

procedure TframeTimeProfileEntry.OnAddCommentsChecked(Sender: TObject);
var
  b: Boolean;
begin
  if TCheckBox(Sender).IsFocused then
  begin
    b := not TCheckBox(Sender).IsChecked;
    cbCommentReq.Enabled := b;
    if not b then
      cbCommentReq.IsChecked := False;
  end;
end;

procedure TframeTimeProfileEntry.OnAddPictureChecked(Sender: TObject);
var
  b: Boolean;
begin
  if TCheckBox(Sender).IsFocused then
  begin
    b := not TCheckBox(Sender).IsChecked;
    cbPictureRequired.Enabled := b;
    if not b then
      cbPictureRequired.IsChecked := False;
  end;
end;

constructor TframeTimeProfileEntry.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FrameIndex := 0;
  cbAddAmount.OnClick := OnAddAmountChecked;
  cbComments.OnClick := OnAddCommentsChecked;
  cbPicture.OnClick := OnAddPictureChecked;
end;

destructor TframeTimeProfileEntry.Destroy;
begin
  inherited Destroy;
end;

procedure TframeTimeProfileEntry.setFrameIndex(const v: Integer);
begin
  if (v mod 2 <> 0) then
    backgroundRect.Fill.Color := CLightGrayV2 // TAlphaColors.Blue;
  else
    backgroundRect.Fill.Color := TAlphaColors.White;
  FFrameIndex := v;
end;

procedure TframeTimeProfileEntry.setProfileItem(const v: TProfileItem);
begin
  FProfileItem := v;
end;

procedure TframeTimeProfileEntry.AssignLevels(const ALevel: TStrings);
begin
  if Assigned(ALevel) then
  begin
    cmbLevel.Items.Assign(ALevel);
  end;
end;

end.
