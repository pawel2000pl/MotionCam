{Warning: deprecated}
program NightMode;

{$mode objfpc}{$inline on}

uses
    SysUtils, Classes, FPImage, UniversalImage, DateUtils;

const 
    MAX_BRIGHT = high(TFPColor.red) + high(TFPColor.green) + high(TFPColor.blue);
    
function Brightness(const c : TFPColor) : Integer; inline;
begin
    Result := c.red + c.blue + c.green;
end;
    
var
    Image : TUniversalImage; 
    FileName : AnsiString;
    x, y : Integer;
    sum : QWord;
    aver : Double;
    r : AnsiString;
    UpBorder : Double;
begin
//Need parameters: if less, default, if gtr, filename
    
    if paramCount < 4 then
        exit;

    FileName := ParamStr(4);
    if not fileexists(FileName) then
    begin
        write(ParamStr(2));
        writeln(StdErr, 'Cannot find a file: "' + FileName + '"');
        exit;
    end; 
       
    try    
        Image := TUniversalImage.CreateEmpty;
        Image.LoadFromFile(FileName);

        sum := 0;
        for x := 0 to Image.Width-1 do
            for y := 0 to Image.Height-1 do
                sum += Brightness(Image.DirectColor[x, y]);
        
        Aver := sum/(Image.Width*Image.Height)/MAX_BRIGHT;
        Image.Free;
        
        //write(stdErr, aver, #9);
        
        if HourOf(now) in [8..16] then
            UpBorder := 0.5
            else
            UpBorder := 0.7;
        
        if Aver > UpBorder then
            r := ParamStr(3)
        else if Aver < 0.1 then
            r := ParamStr(1)
        else
            r := ParamStr(2);
    except
        r := ParamStr(2);
    end;
    write(r);
    //writeln(stdErr, r);
    setlength(r, 0);
end.    
    
