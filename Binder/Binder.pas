program Binder;

{$mode objfpc}

uses
	SysUtils, Classes;
	
var
	SrcFileName : AnsiString;
	DestFileName : AnsiString;
	
	Src : TFileStream;
	Dest : TFileStream;
	
begin
	if ParamCount < 2 then
		exit;
		
	SrcFileName := ParamStr(1);
	DestFileName := ParamStr(2);

	if not fileexists(SrcFileName) then
		exit;
		
	Src := TFileStream.Create(SrcFileName, fmOpenRead);	
	Src.Position := 0;
	if fileexists(DestFileName) then
		Dest := TFileStream.Create(DestFileName, fmOpenWrite)
		else
		Dest := TFileStream.Create(DestFileName, fmCreate);
		
	Dest.Seek(0, soFromEnd);
	Dest.WriteDWord(Src.Size);
	Dest.CopyFrom(Src, Src.Size);
	Src.Free;
	Dest.Free;
end.
	
