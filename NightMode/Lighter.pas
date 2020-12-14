program Lighter;

{$mode objfpc}
{$inline on}

uses
	SysUtils, Classes, FPImage, UniversalImage, math;
	
const 
    MAX_BRIGHT = (high(TFPColor.red) + high(TFPColor.green) + high(TFPColor.blue)) div 3;
    
function Brightness(const c : TFPColor) : Integer; inline;
begin
    Result := max(max(c.red, c.blue), c.green);
end;	

function BrightnessAver(const c : TFPColor) : Double; inline;
begin
    Result := (c.red + c.blue + c.green)/3;
end;	
	
var
	Image : TUniversalImage;
	FileName : AnsiString;
	x, y : Integer;
	sum : QWord;
	Minimal, curr : Integer;
	Aver, k : Double;
	c : TFPColor;
begin
	if ParamCount < 1 then
		exit;
	FileName := ParamStr(1);
	if not fileexists(FileName) then
		exit;
		
	Image := TUniversalImage.CreateEmpty;
	Image.LoadFromFile(FileName);
	
	Minimal := MAX_BRIGHT;
	Sum := 1;
	for x := 0 to Image.Width-1 do
		for y := 0 to Image.Height-1 do
		begin
			curr := Brightness(Image.DirectColor[x, y]);
			sum += curr;
			if curr < Minimal then
				Minimal := curr;
		end;	
		
    Aver := sum/(Image.Width*Image.Height)/MAX_BRIGHT;
    k := 0.5/(Aver-Minimal/MAX_BRIGHT);
    
	for x := 0 to Image.Width-1 do
		for y := 0 to Image.Height-1 do
		begin
			c := Image.DirectColor[x, y];
			c.Green := max(c.green, min($FFFF, trunc((BrightnessAver(c)-Minimal)*k))); 
			Image.DirectColor[x, y] := c;
		end;	

	Image.SaveToFile(FileName, 82);
	Image.Free;
end.	
