unit FTimeProfile;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, UProfiles,
  FrBase, FrTimeProfile, UAsyncDownloader, FMX.Objects, System.Generics.Collections,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListBox, UPObject;

type
  TTimeProfileForm = class(TForm)
    Rectangle1: TRectangle;
    frameTimeProfile1: TframeTimeProfile;
  private
    FPreSave: TAsyncDownloader;
    FProfile: TProfiles;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function createAndShow(var AProfile: TProfiles; const AObjects: TObjectList<TPObject> = nil): Boolean;
  end;


implementation
uses UNotification, UTools, UBase;

{$R *.fmx}

constructor TTimeProfileForm.Create(AOwner: TComponent);
begin
  // NB NB ID tekib väikese viitega !
  inherited Create(AOwner);
  FPreSave := TAsyncDownloader.Create();
  self.Fill.Color := TForm(Application.MainForm).Fill.Color;
end;

destructor TTimeProfileForm.Destroy;
begin
  FPreSave.CancelDownload := True;
  FPreSave.Free;
  inherited Destroy;
end;

class function TTimeProfileForm.createAndShow;
begin
  with Self.Create(nil) do
  try
    FProfile := AProfile;
    if not FProfile.IsAssigned then
    begin
      FPreSave.Post(AProfile.PostURI, AProfile.ToJson(), CContentJson, False);
      FPreSave.OnDataEventComplete :=
        procedure(const AData: String; const AEMsg: String;
          const ANotifId: Integer; const ANotifType: TNotificationTypes; const AMiscData: NativeUInt)
        var
          emsg2: String;
        begin
          if AEMsg <> '' then
            ShowError(AEMsg)
          else
          begin
            emsg2 := '';
            UBase.AssignJsonRPID(AData, emsg2);
            if emsg2 <> '' then
            begin
              ShowError(AEMsg);
              Exit;
            end;

            FProfile.CalcHash; // nägemaks, kas kasutaja reaalselt ka andmeid muutis
            frameTimeProfile1.LoadData(FProfile);
          end;
      end
    end
    else
      frameTimeProfile1.LoadData(FProfile, AObjects);
    Result := Showmodal = mrOk;
  finally
    Free;
  end;
end;
end.
