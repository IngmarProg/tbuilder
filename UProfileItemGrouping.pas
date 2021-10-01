unit UProfileItemGrouping;
// Author: Ingmar Tammeväli www.stiigo.com

interface
uses UBase, Generics.Collections;

type
  TProfileItemGroupingRec = record
    Profile_id: Integer;
    Profile_item_id: Integer; // work id
    Clf_id: Integer; // level id
  end;

type
  TProfileItemGroupingArr = array of TProfileItemGroupingRec;

type
  TProfileItemGrouping = class(TBase)
  protected
    FProfile_id: Integer;
    FProfile_item_id: Integer;
    FOrder_no: Integer;
    FClf_id: Integer;  //  28.02.2021 Ingmar; grupi tunnus
  public
    property Profile_id: Integer Read FProfile_id Write FProfile_id;
    property Profile_item_id: Integer Read FProfile_item_id Write FProfile_item_id;
    property Order_no: Integer Read FOrder_no Write FOrder_no;
    property Clf_id: Integer Read FClf_id Write FClf_id;
    constructor Create(const AProfileId: Integer;
      const AProfileItemId: Integer;
      const AClf_Id: Integer); reintroduce; overload;
  end;

type
  TProfileItemGroupingList = TObjectList<TProfileItemGrouping>;

function ConvItemGroupingToArr(const AList: TProfileItemGroupingList): TProfileItemGroupingArr;

implementation
// http://www.delphibasics.co.uk/Method.asp?NameSpace=System&Class=Array&Method=BinarySearch
function ConvItemGroupingToArr(const AList: TProfileItemGroupingList): TProfileItemGroupingArr;
var
  i: Integer;
begin
  Result := nil;
  if Assigned(AList) and (AList.Count > 0) then
  begin
    SetLength(Result, AList.Count);
    i := Low(Result);
    for var item in AList do
    begin
      Result[i].Profile_id := item.Profile_id;
      Result[i].Profile_item_id := item.Profile_item_id;
      Result[i].Clf_id := item.Clf_id;
      Inc(i);
    end;
  end;
  
end;


constructor TProfileItemGrouping.Create(const AProfileId: Integer;
  const AProfileItemId: Integer;
  const AClf_Id: Integer);
begin
  inherited Create;
  FProfile_id := AProfileId;
  FProfile_item_id := AProfileItemId;
  FClf_id := AClf_id;
end;


end.
