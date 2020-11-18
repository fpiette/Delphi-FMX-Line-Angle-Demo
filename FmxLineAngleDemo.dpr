program FmxLineAngleDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  FmxLineAngleDemoMain in 'FmxLineAngleDemoMain.pas' {FmxLineAngleDemoMainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFmxLineAngleDemoMainForm, FmxLineAngleDemoMainForm);
  Application.Run;
end.
