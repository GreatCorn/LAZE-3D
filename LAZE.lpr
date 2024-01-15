program LAZE;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lazopenglcontext, MASMZE, Settings;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='LAZE-3D';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TFMain, FMain);  
  Application.CreateForm(TFSettings, FSettings);
  Application.Run;
end.

