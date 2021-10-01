unit UAddress;
// Author: Ingmar Tammeväli www.stiigo.com

interface
{$I Conf.inc}
uses UBase;

type
  TAddress = class(TBase)
  protected
    FCountry_id: Integer;
    FCountry: String;
    FCounty_id: Integer;
    FCounty: String;
    FCity_id: Integer;
    FCity: String;
    FStreet_id: Integer;
    FStreet: String;
    FHouse_nr: String;
    FFlat_nr: String;
    function GetCountry: String;
    function GetCounty: String;
    function GetCity: String;
    function GetStreet: String;
  public
    property Country_id: Integer Read FCountry_id Write FCountry_id;
    property Country: String Read GetCountry Write FCountry;
    property County_id: Integer Read FCounty_id Write FCounty_id;
    property County: String Read GetCounty Write FCounty;
    property City_id: Integer Read FCity_id Write FCity_id;
    property City: String Read GetCity Write FCity;
    property Street_id: Integer Read FStreet_id Write FStreet_id;
    property Street: String Read GetStreet Write FStreet;
    property House_nr: String Read FHouse_nr Write FHouse_nr;
    property Flat_nr: String Read FFlat_nr Write FFlat_nr;
    class function JSONToObject(const AJson: String): TObject; override;
    function GetFullAddress: String; virtual;
  end;

implementation
uses REST.JSON, SysUtils;

class function TAddress.JSONToObject(const AJson: String): TObject;
begin
 //  Result := TJson.JsonToObject<TAddress>(AJson);
  Result := inherited JSONToObject(AJson);
  TAddress(Result).Init();
end;

function TAddress.GetFullAddress: String;
begin
  Result := Trim(Country + #32 + County + #32 + City + #32 + Street  + #32 + House_nr);
  if Flat_nr <> '' then
    Result := Result + ' - ' + Flat_nr;
end;

function TAddress.GetCountry: String;
begin
  Result := FCountry;
end;

function TAddress.GetCounty: String;
begin
  Result := FCounty;
end;

function TAddress.GetCity: String;
begin
  Result := FCity;
end;

function TAddress.GetStreet: String;
begin
  Result := FStreet;
end;
{

   LastTimeKeydown:TDatetime;
    Keys:string;

var
  aStr:string;
  I: Integer;
begin
  if key=vkReturn then exit;
  if (keychar in [chr(48)..chr(57)]) or (keychar in [chr(65)..chr(90)]) or (keychar in [chr(97)..chr(122)]) then begin
    //combination of keys? (500) is personal reference
    if MilliSecondsBetween(LastTimeKeydown,Now)<500 then
      keys:=keys+keychar
    else // start new combination
      keys:=keychar;
    //last time key was pressed
    LastTimeKeydown:=Now;
    //lookup item
    for I := 0 to count-1 do
      if uppercase(copy(items[i],0,keys.length))=uppercase(keys) then begin
        itemindex:=i;
        exit;  //first item found is good
      end;
  end;
  inherited;
  }

end.
