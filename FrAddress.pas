{$I Conf.inc}
unit FrAddress;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.ComboEdit, UAddress, UTools;

type
  TframeAddress = class(TFrame)
    cmbCountry: TComboEdit;
    lblCountry: TLabel;
    lblCounty: TLabel;
    cmbCounty: TComboEdit;
    lblCity: TLabel;
    cmbCountyCity: TComboEdit;
    lblStreet: TLabel;
    cmbStreet: TComboEdit;
    lblHouse: TLabel;
    edHousenr: TEdit;
    Label1: TLabel;
    edFlat: TEdit;
  private
  public
    procedure LoadData(const AAddr: TAddress); virtual;
    procedure AssignData(const AAddr: TAddress); virtual;
  end;

implementation
{$R *.fmx}

procedure TframeAddress.LoadData(const AAddr: TAddress);
begin
  with AAddr do
  begin
    if not CmbSetData(cmbCountry, Country_id) then
      cmbCountry.Text := Country;

    if not CmbSetData(cmbCounty, County_id) then
      cmbCounty.Text := County;

    if not CmbSetData(cmbCountyCity, City_id) then
      cmbCountyCity.Text := City;

    if not CmbSetData(cmbStreet, Street_id) then
      cmbStreet.Text := Street;

    edHousenr.Text := House_nr;
    edFlat.Text := Flat_nr;
  end;
end;

procedure TframeAddress.AssignData(const AAddr: TAddress);
begin
  with AAddr do
  begin
    Country_id := CmbGetData(cmbCountry);
    if Country_id < 1 then
      Country := cmbCountry.Text
    else
      Country := '';

    County_id := CmbGetData(cmbCounty);
    if County_id < 1 then
      County := cmbCounty.Text
    else
      County := '';

    City_id := CmbGetData(cmbCountyCity);
    if City_id < 1 then
      City := cmbCountyCity.Text
    else
      City := '';

    Street_id := CmbGetData(cmbStreet);
    if Street_id < 1 then
      Street := cmbStreet.Text
    else
      Street := '';

    House_nr := edHousenr.Text;
    Flat_nr := edFlat.Text;
  end;
end;

end.
