{
  LAZE-3D Settings form and related
}

unit Settings;

{$MODE ObjFPC}
{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  ExtCtrls, SoftOAL, IniFiles
  {$IFDEF WINDOWS}, Windows{$ENDIF};

type

  { TFSettings }

  TFSettings = class(TForm)
    stOkBtn: TButton;
    stJSensLabel: TLabel;
    stVolTrack: TTrackBar;
    stVolLabel: TLabel;
    stMSensTrack: TTrackBar;
    stMSensLabel: TLabel;
    stBrigLabel: TStaticText;
    stJSensTrack: TTrackBar;
    stResolCombo: TComboBox;
    stJoyCombo: TComboBox;
    stResolLabel: TStaticText;
    stFullCheck: TCheckBox;
    stBrigTrack: TTrackBar;
    stJoyLabel: TStaticText;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);      
    procedure GetSettings;
    procedure stBrigTrackChange(Sender: TObject);
    procedure stFullCheckClick(Sender: TObject);
    procedure stJSensTrackChange(Sender: TObject);
    procedure stMSensTrackChange(Sender: TObject);
    procedure stOkBtnClick(Sender: TObject);
    procedure stResolComboChange(Sender: TObject);
    procedure stVolTrackChange(Sender: TObject);
  private

  public

  end;

const
  IniPath = 'settings.ini';
  IniAudio = 'Audio';
  IniGraphics = 'Graphics';
  IniFullscreen = 'Fullscreen';
  IniWidth = 'Width';
  IniHeight = 'Height';
  IniBrightness = 'Brightness';
  IniControls = 'Controls';
  IniHoystickID = 'JoystickID';
  IniJoystickSensitivity = 'JoystickSensitivity';
  IniMouseSensitivity = 'MouseSensitivity';
  IniVolume = 'Volume';
  IniFalse = 'false';
  IniTrue = 'true';

var
  FSettings: TFSettings; 
  IniHandle: TIniFile;

implementation

uses MASMZE;

{$R *.lfm}

{ TFSettings }
             
procedure TFSettings.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if (mMenu = 2) then
    FMain.DoMenu;
end;

procedure TFSettings.FormShow(Sender: TObject);
var
  {$IFDEF WINDOWS}dm: DEVMODEA;{$ENDIF}
  i, j, scrW, scrH: LongWord;
  volFlt: Single;
begin
  FMain.GLC.Cursor := crDefault;

  stFullCheck.Checked := fullscreen;

  { Populate resolution combobox }
  stResolCombo.Items.Clear;
  {$IFDEF WINDOWS}
    scrW := 0;
    scrH := 0;
    i := 0;
    j := 0;
    while EnumDisplaySettingsA(nil, i, @dm) do begin
      if ((scrW <> dm.dmPelsWidth) or (scrH <> dm.dmPelsHeight)) then begin
        scrW := dm.dmPelsWidth;
        scrH := dm.dmPelsHeight;
        stResolCombo.Items.Add(scrW.ToString+'x'+scrH.ToString);
        if ((FMain.Width = LongInt(scrW)) and (FMain.Height = LongInt(scrH)))
        then stResolCombo.ItemIndex := j;
        Inc(j);
      end;
      Inc(i);
    end;
    stResolCombo.Enabled := not fullscreen;
  {$ELSE}
    {$WARNING Available screen resolution enumeration needs platform-specific variants}
  {$ENDIF}

  { Populate joystick combobox }
  //JOYSTICK CODE GOES HERE

  { Configure trackbars }
  stBrigTrack.Position := Round(Gamma * 100);
  stMSensTrack.Position := Round(camTurnSpeed * 100);
  stJSensTrack.Position := Round(camJoySpeed * 100);
  alGetListenerf(AL_GAIN, volFlt);
  stVolTrack.Position := Round(volFlt * 100);
end;

{ Get saved settings from settings.ini and apply them }
procedure TFSettings.GetSettings;
begin               
  IniHandle := TIniFile.Create(IniPath);
  FMain.Width := IniHandle.ReadInteger(IniGraphics, IniWidth, 800);  
  FMain.Height := IniHandle.ReadInteger(IniGraphics, IniHeight, 600);

  { Fullscreen }
  fullscreen := IniHandle.ReadBool(IniGraphics, IniFullscreen, False);
  if (fullscreen) then
    FMain.SetFullscreen(fullscreen);

  { Brightness }
  Gamma := IniHandle.ReadFloat(IniGraphics, IniBrightness, 0.5);

  { Joystick ID }
  //JOYSTICK CODE GOES HERE

  { Joystick sensitivity }
  //JOYSTICK CODE GOES HERE

  { Mouse sensitivity }
  camTurnSpeed := IniHandle.ReadFloat(IniControls, IniMouseSensitivity, 0.3);

  { Audio volume }
  alListenerf(AL_GAIN, IniHandle.ReadFloat(IniAudio, IniVolume, 1.0));

  IniHandle.Free;
end;

procedure TFSettings.stBrigTrackChange(Sender: TObject);
begin
  Gamma := stBrigTrack.Position * 0.01;

  IniHandle := TIniFile.Create(IniPath);
  IniHandle.WriteFloat(IniGraphics, IniBrightness, Gamma);
  IniHandle.Free;
end;

procedure TFSettings.stFullCheckClick(Sender: TObject);
begin
  fullscreen := stFullCheck.Checked;
  stResolCombo.Enabled := not fullscreen;
  FMain.SetFullscreen(fullscreen);
  BringToFront;

  IniHandle := TIniFile.Create(IniPath);
  IniHandle.WriteBool(IniGraphics, IniFullscreen, fullscreen);
  IniHandle.Free;
end;

procedure TFSettings.stJSensTrackChange(Sender: TObject);
begin
  camJoySpeed := stJSensTrack.Position * 0.01;

  IniHandle := TIniFile.Create(IniPath);
  IniHandle.WriteFloat(IniControls, IniJoystickSensitivity, camJoySpeed);
  IniHandle.Free;
end;

procedure TFSettings.stMSensTrackChange(Sender: TObject);
begin
  camTurnSpeed := stMSensTrack.Position * 0.01;

  IniHandle := TIniFile.Create(IniPath);
  IniHandle.WriteFloat(IniControls, IniMouseSensitivity, camTurnSpeed);
  IniHandle.Free;
end;

procedure TFSettings.stOkBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TFSettings.stResolComboChange(Sender: TObject);
var
  xPos: Word;
  resStr: AnsiString;
begin
  resStr := stResolCombo.Items[stResolCombo.ItemIndex];
  xPos := resStr.IndexOf('x');
  FMain.Width := resStr.Remove(xPos).ToInteger;
  FMain.Height := resStr.Substring(xPos+1).ToInteger;

  IniHandle := TIniFile.Create(IniPath);
  IniHandle.WriteInteger(IniGraphics, IniWidth, FMain.Width);  
  IniHandle.WriteInteger(IniGraphics, IniHeight, FMain.Height);
  IniHandle.Free;
end;

procedure TFSettings.stVolTrackChange(Sender: TObject);
begin
  alListenerf(AL_GAIN, stVolTrack.Position * 0.01);

  IniHandle := TIniFile.Create(IniPath);
  IniHandle.WriteFloat(IniAudio, IniVolume, (stVolTrack.Position * 0.01));
  IniHandle.Free;
end;

end.

