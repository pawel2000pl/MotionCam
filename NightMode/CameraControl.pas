program CameraControl;

{$mode objfpc}{$inline on}

uses
    SysUtils, Classes, FPImage, UniversalImage, INIFiles, math;
    
const 
    MAX_BRIGHT = (high(TFPColor.red) + high(TFPColor.green) + high(TFPColor.blue)) div 3;
    ExpectedAverage = 0.5;
    ExpectedStd = 0.4; //of current average
    
    MaxBrightness = 80;
    MinBrightness = 20;
    DefBrightness = 50;
    MaxContrast = 90;
    MinContrast = 0; 
    DefContrast = 0;
    
function PixelBrightness(const c : TFPColor) : Integer; inline;
begin
    Result := max(max(c.red, c.blue), c.green);
end;
    
var
    Image : TUniversalImage; 
    SampleFileName, ConfigFileName : AnsiString;
    Configuration : TINIFile;
    x, y : Integer;
    sum : QWord;
    aver, std : Double;
    Brightness, Contrast : Integer;
    DayMode : 0..1; // 0=Night  1=Day 
    ChangeModeDelay : Integer;
    NeedRestart, ChangedDayMode : Boolean;
begin
//Need parameters: Config file, Sample Image
    
    if paramCount < 2 then
        exit;
    
    ConfigFileName := ParamStr(1);
    Configuration := TINIFile.Create(ConfigFileName);
    
    Brightness := Configuration.ReadInteger('Settings', 'Brightness', DefBrightness);
    Contrast := Configuration.ReadInteger('Settings', 'Contrast', DefContrast);
    DayMode := Configuration.ReadInteger('Settings', 'DayMode', 0);
    ChangeModeDelay := Configuration.ReadInteger('Status', 'ChangeModeDelay', 0)+1;
    NeedRestart := False;
    ChangedDayMode := false;
    if not (DayMode in [0..1]) then
        DayMode := 0;
    
    SampleFileName := ParamStr(2);
    if not fileexists(SampleFileName) then
    begin
        writeln(StdErr, 'Cannot find a file: "' + SampleFileName + '"');
        exit;
    end; 
        
    Image := TUniversalImage.CreateEmpty;
    Image.LoadFromFile(SampleFileName);

    sum := 0;
    for x := 0 to Image.Width-1 do
        for y := 0 to Image.Height-1 do
            sum += PixelBrightness(Image.DirectColor[x, y]);
        
    Aver := sum/(Image.Width*Image.Height)/MAX_BRIGHT;
       
    std := 0;
    for x := 0 to Image.Width-1 do
        for y := 0 to Image.Height-1 do
            std += sqr(PixelBrightness(Image.DirectColor[x, y])/MAX_BRIGHT-Aver);
    std := sqrt(std/(Image.Width*Image.Height));
    Image.Free;
    
    //writeln(Aver:2:4, #9, std:2:4, #9, Aver*(DefBrightness/(Brightness+0.1)):2:4);
    
    if ChangeModeDelay >= 6 then
    begin
        if (Aver*(DefBrightness/(Brightness+0.1)) > 0.7) then
        begin
            if DayMode = 0 then
            begin
                DayMode := 1;
                changedDayMode := true;
            end
            else
                NeedRestart := (std < 0.8*ExpectedStd*Aver) and (Contrast = MaxContrast);
        end    
        else 
        if (Aver*(DefBrightness/(Brightness+0.1)) < 0.1) then
        begin
            if DayMode = 0 then
                NeedRestart := (Brightness = MaxBrightness)
            else
            begin
                DayMode := 0;
                changedDayMode := true;
            end;
        end;   
    end; 
        
    if ChangedDayMode or NeedRestart then
    begin
        ChangeModeDelay := 0;
        Brightness := (Brightness+DefBrightness) div 2;
        Contrast := (Contrast+DefContrast) div 2;
    end else begin
        Brightness += round(40*(ExpectedAverage-Aver));
        Contrast += round(150*(ExpectedStd*Aver-Std));
        
        if Brightness > MaxBrightness then
            Brightness := MaxBrightness
        else if Brightness < MinBrightness then
            Brightness := MinBrightness;
        if Contrast > MaxContrast then
            Contrast := MaxContrast
        else if Contrast < MinContrast then
            Contrast := MinContrast;
    end;
            
    Configuration.WriteInteger('Settings', 'DayMode', DayMode);
    Configuration.WriteInteger('Settings', 'NightMode', 1-DayMode);
    Configuration.WriteInteger('Settings', 'Brightness', Brightness);
    Configuration.WriteInteger('Settings', 'Contrast', Contrast);
    Configuration.WriteInteger('Status', 'ChangeModeDelay', min(65536, ChangeModeDelay));
    if NeedRestart then
        Configuration.WriteInteger('Actions', 'NeedRestart', 1)
    else
        Configuration.WriteInteger('Actions', 'NeedRestart', 0);
            
    configuration.Free;
end.    
    
