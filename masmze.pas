{
	LAZE-3D is a cross-platform Pascal (Lazarus) rewrite project of
  MASMZE-3D (v1.1), a half-game, half-(tech)demo made on MASM32 and WinAPI.
	Copyright (C) 2023  Yevhenii Ionenko (aka GreatCorn)

	This program is free software: you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free Software
  Foundation, either version 3 of the License, or (at your option) any later
  version.

	This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with
  this program. If not, see <http://www.gnu.org/licenses/>.
}

unit MASMZE;

{$MODE ObjFPC}
{$H+}
{$Q-}   
{$R-}

{$MACRO ON}
{ DEBUG symbol defined in Debug mode in Custom Options }  
{$DEFINE RenderDirectly}

{$IFDEF DEBUG}
  {$DEFINE Print:=WriteLn}
{$ELSE}
  {$DEFINE Print:=//WriteLn}
{$ENDIF}


interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  OpenGLContext, GL, Glu, HeapStack, SoftOAL, Registry
  {$IFDEF WINDOWS}, Windows{$ENDIF};

type

  PPSmallInt = ^PSmallInt;

  { OpenAL }
  ALEnum = LongInt;
  ALSizeI = LongInt;
  ALUInt = LongWord;
  PALEnum = ^LongInt;
  PALSizeI = ^LongInt;
  PALUInt = ^ALUInt;

  { TFMain }
  TFMain = class(TForm)
    GLC: TOpenGLControl;
    RenderTimer: TTimer;
    procedure AlertWB(const Loudness: Byte);  
    function CheckBlocked(const XFrom, YFrom, XTo, YTo: Single): Boolean;
    function CheckWBBKVisible(const Dist, Th1, Th2: Single): Boolean;
    procedure CollidePlayer(const X1, X2, Y1, Y2: Single; const Vertical: Boolean);
    procedure CollidePlayerWall(const PosX, PosY: Single; const Vertical: Boolean);
    procedure Control;
    procedure CreateModels;
    procedure DoMenu;
    procedure DoPlayerState;
    procedure DrawAscend;
    procedure DrawBitmapText(const TextString: AnsiString; const X, Y: Single;
      const TextAlign: Byte);
    procedure DrawBorder;
    procedure DrawCheckpoint(const PosX, PosY: Single);
    procedure DrawCroa;  
    procedure DrawEbd;
    procedure DrawExitDoor(const PosX, PosY: Single);
    procedure DrawFloorRoof(const List: GLUInt);
    procedure DrawFloorRoofEnd;
    procedure DrawGlyphs;  
    procedure DrawHbd;
    procedure DrawKubale;
    procedure DrawMap;
    procedure DrawMaze;  
    procedure DrawMazeItems;
    procedure DrawMotrya;
    procedure DrawNoise(const Texture: GLUInt);
    procedure DrawSave;
    procedure DrawTeleporter(const First: Boolean);
    procedure DrawTram;  
    procedure DrawVas;
    procedure DrawVebra;
    procedure DrawVirdya;
    procedure DrawWall(const List:GLUint; const PosX, PosY: Single;
      const Vertical: Boolean);
    procedure DrawWasteland;
    procedure DrawWB;        
    procedure DrawWBBK;
    procedure DrawWmblyk;    
    procedure DrawWmblykAngry;
    procedure EraseSave;        
    procedure EraseTempSave;
    procedure FinishMazeGeneration;
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure FreeMaze;
    procedure GenerateMaze(const Seed: LongWord);
    function GetCellMZC(const X, Y: LongWord; const MZC: Byte): Boolean;
    procedure GetDelta;
    procedure GetMazeCellPos(const PosX, PosY: Single;
      const PosXPtr, PosYPtr: PLongWord);
    function GetOffset(const PosX, PosY: LongWord): LongWord;
    procedure GetPosition(const PosOffset: LongWord; const XPtr, YPtr: PLongWord);
    procedure GetRandomMazePosition(const XPtr, YPtr: PSingle);
    procedure GetWindowCenter;
    procedure InitAudio;
    procedure InitContext; 
    procedure KubaleAI;
    procedure KubaleEvent;
    procedure LoadGame;
    procedure MakeKubale;
    procedure MakeWmblykStealthy;
    procedure MKeyPress(const Key: Word; const State: Boolean);
    function MoveAndCollide(const PosXPtr, PosYPtr,
      SpeedXPtr, SpeedYPtr: PSingle; const WallSize: Single;
      const Bounce: Boolean): Boolean;
    procedure OnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure OnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ProcessShn;                                       
    procedure Render(Sender: TObject);
    procedure RenderLoop(Sender: TObject; var Done: Boolean);
    procedure RenderUI;
    procedure SaveGame;
    procedure SetFullscreen(const FS: Boolean);
    procedure SetNoiseOpacity;
    procedure SetupShopMap;
    procedure Shake(const Amplitude: Single);
    procedure ShowSubtitles(const MString: AnsiString;
      const Interval: Single = 2.0);
    procedure SpawnMazeElements;
    procedure SpawnTrench;
    procedure TimerRender(Sender: TObject);
    function VirdyaReact(const PosX, PosY, Dist: Single): Boolean;
    procedure WBCreate;
    function WBFront(const Rand: Boolean): Boolean;
    procedure WBMove(const Speed: Single);
    procedure WBSetSolve(const ToX, ToY: Single);
    procedure WBSolve(const FromX, FromY, ToX, ToY: LongWord);
    procedure WmblykShuffle;
  end;

const          
  stb_vorbis_lib = 'stb_vorbis';

  GFXDir = 'GFX'+DirectorySeparator;
  FontDir = GFXDir+'font'+DirectorySeparator; 
  SFXDir = 'SFX'+DirectorySeparator;

  FontSymbols: Array[0..40] of AnsiString = ('GFX\font\a.gct', 'GFX\font\b.gct',
  'GFX\font\c.gct', 'GFX\font\d.gct', 'GFX\font\e.gct', 'GFX\font\f.gct',
  'GFX\font\g.gct', 'GFX\font\h.gct', 'GFX\font\i.gct', 'GFX\font\j.gct',
  'GFX\font\k.gct', 'GFX\font\l.gct', 'GFX\font\m.gct', 'GFX\font\n.gct',
  'GFX\font\o.gct', 'GFX\font\p.gct', 'GFX\font\q.gct', 'GFX\font\r.gct',
  'GFX\font\s.gct', 'GFX\font\t.gct', 'GFX\font\u.gct', 'GFX\font\v.gct',
  'GFX\font\w.gct', 'GFX\font\x.gct', 'GFX\font\y.gct', 'GFX\font\z.gct',
  'GFX\font\0.gct', 'GFX\font\1.gct', 'GFX\font\2.gct', 'GFX\font\3.gct',
  'GFX\font\4.gct', 'GFX\font\5.gct', 'GFX\font\6.gct', 'GFX\font\7.gct',
  'GFX\font\8.gct', 'GFX\font\9.gct', 'GFX\font\1.gcg', 'GFX\font\2.gcg',
  'GFX\font\3.gcg', 'GFX\font\4.gcg', 'GFX\font\5.gcg');

  { LCL render loop setup }
  UseTimerForRenderLoop: Boolean = True;
  RenderLoopTimerInterval: LongWord = 8;

  IMG_BMP = 1; { Obsolete, not using BMPs anymore }
  IMG_GCT565 = 2;     
  IMG_GCT332 = 4;
  IMG_GCT4 = 8;
  IMG_GCT5A1 = 16;
{ Due to bad decisions in format specification, only the width of the texture
  is stored at the beginning of a GCT file, as a DWORD. Thus, if the texture's
  width is half of its height, or the opposite, it has to be explicitly defined
  while importing. Same goes for the color format }
  IMG_HALFX = 64;
  IMG_HALFY = 128;
  IMG_GCT = IMG_GCT565;

  D2R: Single = 0.0174532;
  R2D: Single = 57.29578;
  R2I: Single = 0.6366197;
  MPI: Single = 3.1415927;
  MPIHalf: Single = 1.5707;
  MPI2: Single = 6.2831;

  MZC_PASSTOP = 1; { Maze cell constants for bitwise operations }
  MZC_PASSLEFT = 2;
  MZC_VISITED = 4;
  MZC_LAMP = 8;
  MZC_PIPE = 16;
  MZC_WIRES = 32;
  MZC_TABURETKA = 64;
  MZC_ROTATED = 128;

  FNT_LEFT = 0; { Font alignment constants for DrawBitmapText }
  FNT_CENTERED = 1;
  FNT_RIGHT = 2;

  AppName = 'MASMZE-3D';

  CCEscape = 'ESC TO CLOSE'; { Subtitles and miscellaneous strings }
  CCEscapeJ = 'START TO CLOSE';

  CCLevel = 'LAYER:';

  { Random subtitles to show when entering a layer }
  CCRandom1 = 'I REMEMBER THIS PLACE.';
  CCRandom2 = 'IT SMELLS WET HERE.';
  CCRandom3 = 'THE AIR TASTES STAGNANT.';
  CCRandom4 = 'DAMPNESS CLINGS TO THE WALLS.';
  CCRandom5 = 'SOMETHING WATCHES FROM AFAR.';
  CCRandom6 = 'THE WALLS VIBRATE SLIGHTLY.';

  CCAscend1 = 'I REMEMBER EVERYTHING.';
  CCAscend2 = 'IT SMELLS BURNT HERE.';
  CCAscend3 = 'THE AIR TASTES METALLIC.';
  CCAscend4 = 'DUST CLINGS TO THE WALLS.';
  CCAscend5 = 'NOBODY IS PRESENT.';
  CCAscend6 = 'THE WALLS ARE SILENT.';

  CCTrench = 'THE CYCLE PERSEVERETH.';

  CCShn1 = 'I HAVE BEEN HERE FOR TOO LONG.';
  CCShn2 = 'I NEED TO FIND A WAY OUT.';
  CCShn3 = 'SOMETHING HORRIBLE OCCURED.';

  CCCompass = 'PICKED UP COMPASS.'; { Functional subtitles }
  CCGlyphNone = 'THE ABYSS IMMURETH THY MALEFACTIONS.';
  CCGlyphRestore = 'THINE EXCULPATION BETIDETH.';
  CCKey = 'PICKED UP KEY.';
  CCShop = 'PRESS ENTER TO BUY MAP FOR 5 GLYPHS';
  CCShopJ = 'PRESS SELECT TO BUY MAP FOR 5 GLYPHS';
  CCShopBuy = 'THANK YOU FOR YOUR PURCHASE.';
  CCShopNo = 'NOT ENOUGH GLYPHS.';
  CCSpace = 'MASH SPACE TO FIGHT BACK';
  CCSpaceJD = 'MASH CROSS TO FIGHT BACK';
  CCSpaceJX = 'MASH A TO FIGHT BACK';
  CCTeleport = 'REALITY CONTORTS, FRACTURES EMERGE.';
  CCTeleportBad = 'TIME SHIFTS, CONTROL SLIPS AWAY.';
  CCTram = 'PRESS ENTER TO GET ON';
  CCTramJ = 'PRESS SELECT TO GET ON';
  CCTramExit = 'PRESS ENTER TO GET OFF';
  CCTramExitJ = 'PRESS SELECT TO GET OFF';

  CCCroa1 = 'THOU HADST A PATH ENDURING.';
  CCCroa2 = 'WE GREET THY CONCEPTION';
  CCCroa3 = 'AND THINE INADVERTENT SCRIPTOR.';
  CCCroa4 = 'WE HAVE NOT CONTROL OVER THE PROFANED MUNDY,';
  CCCroa5 = 'AND IN THE CONTEXT OF TIME,';
  CCCroa6 = 'OUR PERSISTENCE HERE IS BUT PALTRY.';
  CCCroa7 = 'THOU HAST ARRIVED TO THE BORDER.';
  CCCroa8 = 'YET, AS A BOUND ENTITY,';
  CCCroa9 = 'ADVANCE IT THOU CANST NOT.';
  CCCroa10 = 'HAVING A MEANS TO PEER INTO THE ABYSSES,';
  CCCroa11 = 'YOU MAYST PERSEVERE THE CYCLE,';
  CCCroa12 = 'OR HALT, ABANDON AND FORGET.';
  CCCroa13 = 'PERHAPS WE MAY MEET ANOTHER TIME.';

  CCIntro1 = 'GREATCORN PRESENTS';
  CCIntro2 = 'A GAME WRITTEN IN PASCAL#WITH LAZARUS AND OPENGL';

  CCCheckpoint = 'PRESS ENTER TO PROCEED';
  CCCheckpointJ = 'PRESS SELECT TO PROCEED';
  CCLoad = 'IS THIS WHERE I WAS BEFORE?';
  CCSave = 'THE DIVINE PROGENITRESS AWAITS.';
  CCSaved = 'THY CONCEPTION HATH BEEN PRESERVED.';
  CCSaveErase = 'PRESS ENTER TO ERASE SAVE';
  CCSaveEraseJ = 'PRESS SELECT TO ERASE SAVE';

  MenuBrightness = 'BRIGHTNESS'; { Menu-related strings }
  MenuSettings = 'SETTINGS';
  MenuPaused = 'MASMZE-3D IS PAUSED';
  MenuResume = 'RESUME';
  MenuSensitivity = 'SENSITIVITY';
  MenuExit = 'EXIT';


  Note1 =
    'PRAISED BE THE DIVINE'+#35+
    'MASTERS OF THE MUNDI,'+#35+
    'TORLAGG AND NEQAOTOR!'+#35+
    'MANY PLEAS OF MINE'  +#35+
    'FOR SALVATION REMAIN'+#35+
    'UNANSWERED, BUT I'   +#35+
    'BELIEVE IN THEE AND' +#35+
    'THINE OMNIPOTENCE!'  +#35+
    'THE ABYSS IS BROAD'  +#35+
    'AND DEEP, BUT I WILL'+#35+
    'FIND MY EXIT, WITH'  +#35+
    'THE HELP OF THE CROA'+#35+
    'I WILL, SURELY...';

  Note2 =
    'THEY CALLED IT TO-NE,'+#35+
    'FOR IT MUST BE THE'	 +#35+
    'LAND UNDER THE RULE'  +#35+
    'OF THE NETHER AND'	   +#35+
    'EASTERN CROA, BUT I'	 +#35+
    'SEE NO SIGNS OF THEIR'+#35+
    'WORK HERE... I FOUND' +#35+
    'IT APPROPRIATE TO'    +#35+
    'ASSOCIATE SV WITH'    +#35+
    'AOTIR MUNDY, BUT NOW' +#35+
    'I AM NOT AS SURE AS I'+#35+
    'WAS BEFORE...';

  Note3 =
    'GRAND DISCONCERTMENT' +#35+
    'BEFELL ME. EITHER I'  +#35+
    'FOUND A POSSIBLE'	   +#35+
    'CONNECTION TO THE'    +#35+
    'MUND OF NEQAOTOR, OR' +#35+
    'I HAVE DISCOVERED THE'+#35+
    'FUNCTION OF THIS'		 +#35+
    'ABYSS.'				       +#35+
    'TO-NE PRAISES SIN AND'+#35+
    'THROUGH BLASPHEMY, I' +#35+
    'AM ABLE TO PERSIST IN'+#35+
    'A MORE STABLE MANNER.';

  Note4 =
    'THE GLYPHS, I AM'	   +#35+
    'BEGINNING TO'		  	 +#35+
    'UNDERSTAND THEM. I'	 +#35+
    'MAY BE ABLE TO'	  	 +#35+
    'DECIPHER THE MEANINGS'+#35+
    'OF THE INSCRIPTIONS'	 +#35+
    'HERE. THEY LOOK TO BE'+#35+
    'THE SAME AS WHAT SV'	 +#35+
    'USES. IF I AM'		     +#35+
    'SUCCESSFUL, THIS WILL'+#35+
    'BE A SIGNIFICANT'		 +#35+
    'ACCOMPLISHMENT FOR'	 +#35+
    'KURLYKISTAN.';

  Note5 =
    'SANCTA VITA.'			   +#35+
    'THESE WORDS STILL'	   +#35+
    'RING IN MY HEAD AS IF'+#35+
    'UTTERED A MERE'	     +#35+
    'FRACTION OF A MOMENT' +#35+
    'BEFORE. I WANTED'		 +#35+
    'ANSWERS AND I FOUND'	 +#35+
    'THEM, BUT I HAVE'		 +#35+
    'DOOMED MYSELF. THE'	 +#35+
    'SMILE OF THE'			   +#35+
    'PROGENITRESS BRINGS'	 +#35+
    'ME ONLY DISFAVOR.'	   +#35+
    'I MISS MY HOME.';

  Note6 =
    'ENDLESS. INEXACT.'	   +#35+
    'EVERPRESENT.'			   +#35+
    'IMPRUDENT BE BROUGHT' +#35+
    'TO REASON.'			     +#35+
    'WHEN TIME IS LOST,'	 +#35+
    'BEGOTTEN BE A NEW'	   +#35+
    'CONCEPT.'				     +#35+
    'I HAVE BEEN DECEIVED.'+#35+
    'I HAVE BEEN'			     +#35+
    'RIDICULED.'			     +#35+
    'I FOUND NOT A SINGLE' +#35+
    'ANSWER BUT LED MYSELF'+#35+
    'TO MINE OWN DEMISE.';

  Note7 =
    'AZ POHEHBET MYOLIC' +#35+
    'OKKLQS SANCTA VITA.'+#35+
    #35+
    'SGORT AZA NA SYXNE' +#35+
    'SYY NE ESMOVETU'		 +#35+
    'SHOMBOM,'				   +#35+
    'TAKVO ONEM AZA'		 +#35+
    'ESMOVETY HOMBET NA' +#35+
    'TRUMB K YERHENY'		 +#35+
    'M O T R E,'			   +#35+
    #35+
    'DA SANTITSY YGA'		 +#35+
    'DA ESMOVAYU ADRAST.';

  RegPath = 'Software'+DirectorySeparator+'GreatCorn'+DirectorySeparator+'MASMZE-3D';
  RegLayer = 'Layer';
  RegCompass = 'Compass';
  RegCurLayer = 'CurLayer';
  RegCurWidth = 'CurWidth';
  RegCurHeight = 'CurHeight';
  RegGlyphs = 'Glyphs';
  RegFloor = 'Floor';
  RegWall = 'Wall';
  RegRoof = 'Roof';
  RegMazeW = 'MazeW';
  RegMazeH = 'MazeH';
  RegComplete = 'Complete';


  mclBlack:    Array[0..3] of Single = (0.0,  0.0,  0.0,  1.0);
  mclDarkGray: Array[0..3] of Single = (0.2,  0.2,  0.2,  1.0);
  mclGray:     Array[0..3] of Single = (0.5,  0.5,  0.5,  1.0);
  mclTrench:   Array[0..3] of Single = (0.24, 0.24, 0.22, 1.0);
  mclYellow:   Array[0..3] of Single = (1.0,  0.83, 0.56, 1.0);
  mclWhite:    Array[0..3] of Single = (1.0,  1.0,  1.0,  1.0);

  flCamHeight: Single = -1.2; { Default camera height }
  flCamSpeed: Single = 3.6; { Default camera speed }
  flDoor: Single = 0.65; { Door offset }
  flStep: Single = 6.0; { Step animation speed }
  flWTh: Single = 0.4; { Wall thickness }
  flWMr: Single = 0.15; { Wall margin }
  flWLn: Single = 2.15; { Wall length }
  flRaycast: Single = 1.0; { Raycast resolution }
  flPaper: Single = 640.0; { Paper width }

  mnButton: Array[0..1] of Single = (256.0, 48.0); { Menu button size }
  mnFont: Array[0..1] of Single = (16.0, 32.0); { Menu font size }
  mnFontSpacing: Single = 1.25; { Menu font spacing (in scaled units) }

  { Array of 4-direction angles in radians to iterate through }
  rotations: Array[0..3] of Single = (0.0, 1.5707, 3.1415, -1.5707);

var
  { ----- INITIALIZED DATA ----- }
  CCGlyph: AnsiString = 'PLACED GLYPH. ? REMAINING.';
  CCDeath: AnsiString = 'YOU DIED.';

  canControl: Boolean = False; { Boolean to enable/disable player control }
  mFocused: Boolean = True; { Window focus }
  fullscreen: Boolean = False; { Boolean to store if the game is fullscreen }
  screenSize: Array[0..1] of LongWord = (800, 600); { Screen size, changes when resizing }
  playerState: Byte = 11; { Player state for various uses, like cutscenes }
  windowSize: Array[0..1] of LongWord = (800, 600); { Window size to change back to after fullscreen }
  windowPos: Array[0..1] of LongWord = (0, 0); { Window position to change back to }

  mkeyUp: Boolean = False; { Keys, too lazy to do bitwise stuff }
  mkeyDown: Boolean = False;
  mkeyLeft: Boolean = False;
  mkeyRight: Boolean = False;
  mkeySpace: Boolean = False;
  mkeyCtrl: Boolean = False;
  mkeyLMB: Byte = 0;
  debugF: Boolean = False;

  msX: Single = 0.0; { Mouse position as REAL4 }
  msY: Single = 0.0;
  winWH: SmallInt = 0;
  winHH: SmallInt = 0;
  winCX: SmallInt = 0; { Window center }
  winCY: SmallInt = 0;

  camCrouch: Single = 0.0; { Camera crouch value that gets added to Y }
  camCurSpeed: Array[0..2] of Single = (0.0, 0.0, 0.0);	{ Current camera speed }
  camForward: Array[0..2] of Single = (0.0, 0.0, 0.0); { Camera forward vector }
  { Camera listener position and orientation, used to pass to alListenerfv }
  camListener: Array[0..5] of Single = (0.0, 0.0, 0.0, 0.0, -1.0, 0.0);
  camLight: Array[0..3] of Single = (-0.0, 0.0, -0.0, -1.0); { Camera light local position }
  { Only the camera uses negative coordinates in glTranslatef }
  camPos: Array[0..3] of Single = (-0.6, -1.2, -1.0, 1.0); { Camera position (negative) }
  camPosN: Array[0..1] of Single = (0.0, 0.0); { Camera negative position (positive) }
  camPosL: Array[0..2] of Single = (-0.0, -1.2, -0.0); { Lerped camera position }
  camPosNext: Array[0..2] of Single = (-0.0, -1.2, -0.0); { Next camera position, for collision }
  camStranglePos: Array[0..1] of Single = (0.0, 0.0); { Position to return to after strangling }
  camRight: Array[0..2] of Single = (0.0, 0.0, 0.0); { Camera right vector }
  camRot: Array[0..2] of Single = (-0.5, -3.1, 0.0); { Camera rotation, in radians }
  camRotL: Array[0..2] of Single = (0.0, 3.14, 0.0); { Lerped camera rotation }
  camStep: Single = 0.0;			{ Value for animating walking }
  camStepSide: Single = 0.0;	{ Side step animation }
  camTilt: Single = 0.0;			{ Dynamic tilt when strafing }
  camTurnSpeed: Single = 0.3; { Mouse sensitivity }
  camJoySpeed: Single = 2.0;	{ Joystick sensitivity }

  lastStepSnd: ALUInt = 0; { Last step sound index, to not repeat it }

  mouseRel: Array [0..1] of SmallInt = (0, 0); { Mouse position, relative to screen center }
  mousePos: Array [0..1] of SmallInt = (0, 0); { Absolute mouse position }
  mousePrev: Array[0..1] of SmallInt = (0, 0); { See GetWindowCenter }

  ccTimer: Single = -1.0; { Subtitles timer }
  ccText: AnsiString; { Subtitles text }
  ccTextLast: Byte = 255; { Last subtitles index, to not repeat it }

  wmblyk: GLUInt = 0; { Wmblyk's state }
  wmblykAnim: GLUInt = 0; { Wmblyk's animation }
  wmblykPos: Array[0..1] of Single = (1.0, 7.0); { Wmblyk's position }
  wmblykDir: Single = 0.0; { Wmblyk's direction }
  wmblykBlink: Single = 5.0; { Wmblyk's blink and general-purpose timer }
  wmblykJumpscare: Single = 0.0; { Wmblyk's jumpscare value (used as alpha) }
  wmblykWalkAnim: Single = 7.0; { Wmblyk's walk animation speed etc }
  wmblykStrAnim: Single = 3.0; { Wmblyk's strangle animation speed etc }
  wmblykDirI: LongWord = 0; { Wmblyk's direction index (from rotations) }
  wmblykDirS: Array[0..3] of Byte = (0, 1, 2, 3); { Wmblyk's direction pool (possible indices) }
  wmblykTurn: Boolean = False; { Boolean if Wmblyk should turn }
  wmblykStr: Single = 0.0; { Strangling/fighting back value etc }
  wmblykStrState: GLUInt = 13; { Wmblyk's strangling state }
  wmblykStrM: Single = 0.0; { Wmblyk's strangling music gain }
  wmblykStealth: Single = 0.0; { Wmblyk's general-purpose stealth value etc }
  wmblykStealthy: Byte = 0; { Wmblyk's stealth state }

  kubaleAppeared: Boolean = False; { Boolean if Kubale ever appeared }
  kubale: GLUInt = 0; { Kubale state }
  kubaleDir: Single = 0.0; { Kubale direction }
  kubalePos: Array[0..1] of Single = (3.0, 3.0); { The act of transferring the Kubale }
  kubaleSpeed: Array[0..1] of Single = (0.0, 0.0); { Kubale speed, for collision }
  kubaleInkblot: GLUInt = 0; { Kubale inkblot index }
  kubaleVision: Single = 0.0; { Kubale vision value (used as alpha and gain) }
  kubaleRun: Single = 0.0; { Kubale scampering sound gain }

  vasPos: Array[0..1] of Single = (0.0, 0.0);

  hbd: Byte = 0; { Huenbergondel's state }
  hbdPos: Array[0..1] of LongWord = (0, 0); { Huenbergondel's position, in maze cell integers }
  hbdPosF: Array[0..1] of Single = (1.0, 1.0); { Huenbergondel's position, in floats (for drawing) }
  hbdRot: LongWord = 0; { Huenbergondel's rotation, in rotations[] index }
  hbdRotF: Single = 0.0; { Huenbergondel's rotation, in floats }
  hbdTimer: Single = 6.0; { Huenbergondel's timer }
  hbdMdl: GLUInt = 56; { Huenbergondel's model index }

  doorSlam: Byte = 0; { Door slam event state }
  doorSlamRot: Single = 0.0; { The entrance door rotation (for drawing) }

  virdya: GLUInt = 0; { Virdya's model index }
  virdyaEmote: Byte = 6; { Virdya's emote cooldown }
  virdyaBlink: Single = 1.0; { Virdya's blink and facial timer }
  virdyaDest: Array[0..1] of Single = (1.0, 1.0); { Virdya's destination position for walking state }
  virdyaFace: GLUInt = 0; { Virdya's face texture pointer }
  virdyaHeadRot: Array[0..1] of Single = (0.0, 0.0); { Virdya's head rotation (X, Y) }
  virdyaPos: Array[0..1] of Single = (3.0, 3.0); { Virdya's position }
  virdyaPosPrev: Array[0..1] of Single = (3.0, 3.0); { Virdya's previous position (for calculating speed) }
  virdyaRot: Single = 3.1; { Virdya's global rotation }
  virdyaRotL: Array[0..2] of Single = (0.0, 0.0, 0.0); { Virdya's interpolated rotation }
  virdyaTimer: Single = 0.0; { Virdya's state timer }
  virdyaSpeed: Array[0..1] of Single = (0.0, 0.0); { Virdya's calculated speed }
  virdyaState: Byte = 0; { Virdya's state }
  virdyaSound: Single = 0.0; { Virdya's defensive sound gain }

  camAspect: Double = 1.0; { Camera aspect ratio, changed when resizing }
  camFOV: Double = 75.0;   { Camera FOV, may be dynamic }

  deltaTime: Single = 0.01; { Delta time multiplier }
  delta2: Single = 0.01;    { deltaTime * 2 }
  delta20: Single = 0.01;   { deltaTime * 10 }
  lastTime: LongWord = 0;   { Used to compare tick counter for deltaTime }

  fade: Single = 1.0; { Fade value, used as alpha }
  fadeState: Byte = 0; { Fade state, 0 = no fade, 1 = fade in, 2 = fade out }
  fogDensity: Single = 0.5; { Exponential fog density value, set with fade }
  vignetteRed: Single = 0.0; { Red vignette alpha }

  mMenu: Byte = 0; { Menu state, 0 = no menu, 1 = pause, 2 = options }
  Gamma: Single = 0.5; { Fake gamma / brightness multiplier }

  Compass: Byte = 0; { Compass state, 0 = none, 1 = in layer, 2 = in possession }
  CompassPos: Array[0..1] of Single = (0.0, 0.0); { Compass item layer position }
  CompassRot: Single = 0.0; { Compass arrow rotation }
  CompassMapPos: Array[0..1] of Single = (0.0, 0.0); { Compass and map position to display more smoothly }

  Glyphs: Byte = 7; { Available glyphs }
  GlyphsInLayer: Byte = 0; { Glyphs placed in layer }
  GlyphOffset: Byte = 0; { Glyph offset to not repeat placed }
  GlyphPos: Array[0..13] of Single = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
  0.0, 0.0, 0.0, 0.0, 0.0, 0.0); { Glyph positions }
  GlyphRot: Array[0..6] of Single = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0); { Glyph rotations }

  MazeSeed: LongWord = 0; { Sneed's Feed & Seed (Formerly Chuck's) }
  MazeW: LongWord = 6;	{ Maze width }
  MazeH: LongWord = 6;	{ Maze height }
  MazeWM1: LongWord = 0; { Maze width-1 }
  MazeHM1: LongWord = 0; { Maze height-1 }
  MazePool: LongWord = 0;	{ Used when generating maze }
  MazeSize: LongWord = 0;	{ Maze byte size }
  MazeSizeM1: LongWord = 0;	{ Maze - (1, 1) byte size }
  MazeType: Byte = 0; { 0 - normal, 1 - squiggly, 2 - broken }
  MazeCrevice: Byte = 0; { Maze crevice active }
  MazeCrevicePos: Array[0..1] of LongWord = (0, 0); { Maze crevice cell position }
  MazeDoor: Single = 0.0; { Maze end door value, used for rotating }
  MazeDoorPos: Array[0..1] of Single = (0.0, 0.0); { Maze end door cell center position in REAL4 }
  MazeGlyphs: Byte = 0; { Maze glyphs item }
  MazeGlyphsPos: Array[0..1] of Single = (0.0, 0.0); { Glyphs item position in layer }
  MazeGlyphsRot: Single = 0.0; { Glyphs item rotation }
  MazeLocked: Byte = 0; { Locked layer, 0 = not locked, 1 = locked, 2 = unlocked }
  MazeKeyPos: Array[0..1] of Single = (0.0, 0.0); { Key position }
  MazeKeyRot: Array[0..1] of Single = (0.0, 0.0); { Key rotation }
  MazeHostile: Byte = 0; { Used with intro and endings }
  MazeNote: Byte = 0; { Note state }
  MazeNotePos: Array[0..1] of Single = (0.0, 0.0); { Note position, rotation determined by MagnitudeSqr }
  MazeSiren: Single = 0.0; { Siren gain etc (intro) }
  MazeSirenTimer: Single = 51.0; { Siren timer (intro) }
  MazeTeleport: Byte = 0; { Teleporters state }
  MazeTeleportPos: Array[0..3] of Single = (0.0, 0.0, 0.0, 0.0); { First & second tele positions }
  MazeTeleportRot: Single = 0.0; { Teleporter rotation for animating }
  MazeTram: Byte = 0; { Tram state }
  MazeTramDoors: LongWord = 99; { Tram doors list to draw }
  MazeTramArea: Array[0..1] of LongWord = (0, 0); { The area (X from, X to) that the rails occupy }
  MazeTramRot: LongWord = 2; { Tram direction (rotations[]) }
  MazeTramRotS: Single = 0.0; { Single rotation }
  MazeTramPlr: Byte = 0; { Tram player state }
  MazeTramPos: Array[0..2] of Single = (0.0, 0.0, 0.0); { Tram position (XYZ, for light) }
  MazeTramSpeed: Single = 0.0; { Tram speed to accelerate }
  MazeTramSnd: ALUInt = 0; { Tram sound index }
  MazeRandTimer: Single = 10.0; { Random ambient sound timer }
  MazeRandPos: Array[0..1] of Single = (0.0, 0.0); { Random ambient sound position }

  WmblykTram: Boolean = False; { Wmblyk can get on the tram }

  Checkpoint: Byte = 0; { Checkpoint state }
  CheckpointDoor: Single = 0.0; { Checkpoint exit door rotation }
  CheckpointMus: Single = 0.0; { Checkpoint music gain level for interpolation }
  CheckpointPos: Array[0..1] of Single = (0.0, 0.0); { Checkpoint position }

  AscendDoor: Byte = 0; { Ascension door state for sound }
  { Ascension & wasteland sky & fog color }
  AscendColor: Array[0..3] of Single = (0.0, 0.0, 0.0, 0.0);
  { Ascension volume value and lerp target }
  AscendVolume: Array[0..1] of Single = (0.0, 0.0);
  AscendSky: Single = 0.0; { Value to set AscendColor to }

  MotryaDist: Single = 40.0; { Motrya's desired distance in wasteland }

  Motrya: GLUInt = 0; { Motrya's state }
  MotryaTimer: Single = 0.1; { Motrya's timer (used for white fade too) }
  MotryaPos: Array[0..1] of Single = (0.0, 0.0); { Motrya's position }
  Save: Byte = 0; { Save light state }
  SaveSize: Single = 0.0; { Save light size }
  SavePos: Array[0..2] of Single = (1.0, 0.2, 0.2); { Save XY position plus Y target position to lerp to }

  PMSeed: LongWord = 0; { Previous maze layer seed }
  PMW: LongWord = 0; { Previous maze width }
  PMH: LongWord = 0; { Previous maze height }

  MazeLevel: LongWord = 0; { Current maze layer }
  MazeLevelPopup: Byte = 0; { Maze layer popup, 0 = none, 1 = down, 2 = up }
  MazeLevelPopupY: Single = -48.0;
  MazeLevelPopupTimer: Single = 0.0;

  Shn: Byte = 0;
  ShnTimer: Single = 80.0;
  ShnPos: Array[0..1] of Single = (1.0, 1.0);

  Vebra: GLUInt = 0; { Vebra animation frame (and state) }
  VebraTimer: Single = 1.0; { Vebra animation timer }

  WBBK: Byte = 0; { WBBK state }
  WBBKCamDir: Single = 0.0; { WBBK cam direction for lerping }
  WBBKDist: Single = 4.0; { WBBK distance factor }
  WBBKPos: Array[0..1] of Single = (1.0, 5.0); { WBBK position to draw at }
  WBBKSndID: ALUInt = 5; { WBBK last ambient sound ID }
  WBBKSndPos: Array[0..3] of Single = (0.0, 0.0, 0.0, 0.0); { WBBK sound position (from - to) }
  WBBKTimer: Single = 0.0; { WBBK general-purpose timer }
  WBBKSTimer: Single = 20.0; { WBBK timer when player isn't moving }

  { Was intended to be unabstracted Webubychko, but it was too thicc so changed it }
  WB: Byte = 0; { WB unabstracted state }
  WBAnim: Byte = 0; { WB animation (0 - idle, 1 - walk, 2 - attack) }
  WBFrame: GLUInt = 114; { WB animation frame }
  WBMirror: Boolean = True; { WB mirror animation }
  WBAnimTimer: Single = 0.0; { WB animation timer }
  WBTimer: Single = 0.0; { WB Timer }
  WBPos: Array[0..1] of Single = (1.0, 3.0); { WB position } 
  WBPosI: Array[0..1] of LongWord = (0, 0); { WB integer position }
  WBPosL: Array[0..1] of Single = (1.0, 3.0); { WB lerp position }   
  WBPosP: Array[0..1] of Single = (1.0, 3.0); { WB previous position }
  WBRot: Array[0..1] of Single = (0.0, 0.0); { WB rotation + target }
  WBStack: THeapStack; { WB heapstack for solving }
  WBNext: Array[0..1] of LongWord = (0, 0); { WB next cell position }
  WBTarget: Array[0..1] of Single = (0.0, 0.0); { WB current target position }
  WBFinal: Array[0..1] of Single = (0.0, 0.0); { WB final target position }
  WBSpeed: Array[0..1] of Single = (0.0, 0.0); { WB calculated speed }
  WBSpMul: Single = 0.0; { WB speed multiplier }
  WBCurSpd: Single = 0.0; { WB current speed }

  MazeDrawCull: LongWord = 5; { The 'radius', in cells, to draw }

  Map: Byte = 0; { Map state }
  MapBRID: LongWord = 0; { Map bottom-right cell ID (to not draw it) }
  MapOffset: Array[0..1] of Single = (0.0, 0.0); { Map offset to center it (not yet used) }
  MapSize: Single = 0.0; { Map size multiplier to fit it into the parchment }

  NoiseOpacity: Array[0..1] of Single = (0.1, 0.1);

  EBD: Byte = 0; { Eblodryn state }
  EBDAnim: Single = 0.0; { Eblodryn animation variable }
  EBDPos: Array[0..1] of Single = (3.0, 3.0); { Eblodryn position }
  EBDSound: Single = 0.0; { Eblodryn attack sound gain }

  Shop: Byte = 1;            { Shop state }
  ShopKoluplyk: GLUInt = 78; { Koluplyk's list }
  ShopTimer: Single = 0.0;   { Koluplyk's timer for animation }
  ShopWall: Single = 3.0;    { For moving the shop wall after purchasing }

  Croa: Byte = 0;            { Croa state}
  CroaCC: Byte = 0;          { Croa subtitles state }
  CroaTimer: Single = 3.0;   { Croa timer }
  CroaCCTimer: Single = 5.0; { Croa subtitles timer }
  CroaPos: Single = 1.5;     { For positioning Croa }
  CroaColor: Array[0..3] of Single = (0.0, 0.0, 0.0, 0.0); { Croa light color }

  Trench: Byte = 0; { Trench state }
  TrenchTimer: Single = 0.0; { Trench timer, set in Control with movement }
  TrenchColor: Array[0..3] of Single = (1.0, 1.0, 1.0, 1.0); { To use as fog and clear color }

  { GetSettings on WM_CREATE had problems }
  GetIniSettingsOnFirstFrame: Boolean = False;

  Complete: Byte = 0; { Game has been completed }

  { ----- UNINITIALIZED DATA ----- }

  FMain: TFMain;

  Maze: Array of Byte; { Maze memory }
  MazeLevelStr: AnsiString; { String, containing the layer number }

  defKey: TRegistry;

  {$I Textures.inc} { Texture identifiers }
  {$I Sounds.inc}   { Sound identifiers }

  AudioDevice: Pointer;
  AudioContext: Pointer;
  CurrentFloor, CurrentRoof, CurrentWall, CurrentWallMDL: GLUInt;

function Sign(const Val: Single): Single;

implementation

uses
  Settings;

{$R *.lfm}

{ Audio + Importers }
function stb_vorbis_decode_filename(const filename:PChar; channels:PInteger;
  sample_rate:PInteger; output:PPSmallInt): Integer; cdecl;
  external stb_vorbis_lib;

procedure ErrorOut(const StrText: AnsiString);
begin
  ShowMessage(StrText);
end;
procedure LoadAudio(const FilePath: AnsiString; const AudioPTR: PALUInt);
var
  channels, sample: Integer;
  decoded: PSmallInt;
  buffer: ALUInt;
  bufferSize: ALSizeI;
  format: ALEnum;
begin
  bufferSize := stb_vorbis_decode_filename(PChar(FilePath), @channels, @sample, @decoded);
  bufferSize := bufferSize * 2 * channels;

  alGenBuffers(1, @buffer);
  if (channels = 2) then
    format := AL_FORMAT_STEREO16
  else
    format := AL_FORMAT_MONO16;
  alBufferData(buffer, format, decoded, bufferSize, sample);
  alGenSources(1, AudioPTR);
  alSourcei(AudioPTR^, AL_BUFFER, buffer);
end;
procedure LoadGCM(const FilePath: AnsiString; const ListIndex: GLUInt);
var
  hFile: File of Single;
  x, y, z: Single;
begin
  Assign(hFile, FilePath);
  Reset(hFile);

  glNewList(ListIndex, GL_COMPILE);
  glBegin(GL_TRIANGLES);

  while not EOF(hFile) do begin
    Read(hFile, x); Read(hFile, y);
    glTexCoord2f(x, y);

    Read(hFile, x); Read(hFile, y); Read(hFile, z);
    glNormal3f(x, y, z);

    Read(hFile, x); Read(hFile, y); Read(hFile, z);
    glVertex3f(x, y, z);
  end;

  glEnd;
  glEndList;

  Close(hFile);
end;
function LoadTexture(const FilePath: AnsiString; const ImageType:LongWord): GLUInt;    
var
  hPic: Pointer = nil;
  hTxtr: GLUInt;
  dwFileSize: LongWord;
  xPic: LongWord = 0;
  yPic: LongWord = 0;
  procedure LoadGCT;
  var
    hFile: File;
  begin
    Assign(hFile, FilePath);
    Reset(hFile, 1);
    dwFileSize := FileSize(hFile) - 4;

    BlockRead(hFile, xPic, 4);
    yPic := xPic;

    GetMem(hPic, dwFileSize);

    BlockRead(hFile, hPic^, dwFileSize);
    Close(hFile);
  end;
begin
  if ((ImageType and IMG_BMP) <> 0) then
    { LoadBMP; }
  else
    LoadGCT;

  glGenTextures(1, @hTxtr);
  glBindTexture(GL_TEXTURE_2D, hTxtr);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

  if ((ImageType and IMG_HALFX) <> 0) then
    yPic := yPic * 2;   
  if ((ImageType and IMG_HALFY) <> 0) then
    yPic := yPic div 2;

  if ((ImageType and IMG_GCT565) <> 0) then
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, xPic, yPic, 0, GL_RGB, $8363, hPic);
  if ((ImageType and IMG_GCT332) <> 0) then
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, xPic, yPic, 0, GL_RGB, $8032, hPic);   
  if ((ImageType and IMG_GCT4) <> 0) then
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA4, xPic, yPic, 0, GL_RGBA, $8033, hPic);  
  if ((ImageType and IMG_GCT5A1) <> 0) then
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB5_A1, xPic, yPic, 0, GL_RGBA, $8034, hPic);

  Freemem(hPic);

  Result := hTxtr;
end;

{ Maths }

procedure Angleify(const Value: PSingle);
begin
  if (Value^ > MPI) then
    Value^ := Value^ - MPI2;  
  if (Value^ < -MPI) then
    Value^ := Value^ + MPI2;
end;

function ATan2(const Y, X: Single): Single;
begin
  Result := 0;
  if (X > 0) then Result := ArcTan(Y / X)
  else if ((X < 0) and (Y >= 0)) then Result := ArcTan(Y / X) + mPI
  else if ((X < 0) and (Y < 0)) then Result := ArcTan(Y / X) - mPI
  else if ((X = 0) and (Y > 0)) then Result := ArcTan(mPIHalf)
  else if ((X = 0) and (Y < 0)) then Result := ArcTan(-mPIHalf);
end;

function Clamp(const Value, MinVal, MaxVal: Single): Single;
begin
  Result := Value;
  if (Value > MaxVal) then
    Result := MaxVal
  else if (Value < MinVal) then
    Result := MinVal;
end;

function DistanceScalar(const SFrom, STo: Single): Single;
begin
  Result := Abs(SFrom - STo);
end;

function DistanceToSqr(const XFrom, YFrom, XTo, YTo: Single): Single;
begin
  Result := Sqr(XFrom - XTo) + Sqr(YFrom - YTo);
end;

function GetDirection(const XFrom, YFrom, XTo, YTo: Single): Single;
begin
  GetDirection := ATan2(XFrom - XTo, YFrom - YTo);
end;

function InRange(const PosX, PosY, X1, X2, Y1, Y2: Single): Boolean;
begin
  Result := ((PosX > X1) and (PosX < X2) and (PosY > Y1) and (PosY < Y2));
end;

procedure Lerp(const LerpA: PSingle; const LerpB, LerpT: Single);
begin
  LerpA^ := LerpA^ + (LerpB - LerpA^) * LerpT;
end;

procedure LerpAngle(const LerpA: PSingle; const LerpB, LerpT: Single);
var
  LerpBV: Single;
begin
  LerpBV := LerpB - LerpA^;
  Angleify(@LerpBV);
  LerpA^ := LerpA^ + LerpBV * LerpT;
end;

function MagnitudeSqr(const X, Y: Single): Single;
begin
  Result := X * X + Y * Y;
end;

procedure MoveTowards(const MoveA: PSingle; const MoveB, MoveT: Single);
begin
  if (DistanceScalar(MoveA^, MoveB) <= MoveT) then begin
    MoveA^ := MoveB;
    Exit;
  end;

  MoveA^ := Sign(MoveB - MoveA^) * MoveT + MoveA^;
end;

procedure MoveTowardsAngle(const MoveA: PSingle; const MoveB, MoveT: Single);
var
  MoveAV: Single;
begin
  MoveAV := MoveA^;
  if (DistanceScalar(MoveAV, MoveB) < MoveT) then begin
    MoveA^ := MoveB;
    Exit;
  end;

  MoveAV := MoveB - MoveAV;
  Angleify(@MoveAV);
  MoveA^ := Sign(MoveAV) * MoveT + MoveA^;
end;

procedure Normalize(const X, Y: PSingle);
var
  XV, YV: Single;
  LengthSQ: Single;
begin
  XV := X^;
  YV := Y^;
  LengthSQ := (XV * XV) + (YV * YV);

  if (LengthSQ < 0.0) then begin
    X^ := 0;
    Y^ := 0;
    Exit;
  end;
  LengthSQ := Sqrt(LengthSQ);

  XV := XV / LengthSQ;
  YV := YV / LengthSQ;

  X^ := XV;
  Y^ := YV;
end;

procedure RandomFloat(const Value: PSingle; Range: Single);
begin
  Value^ := Random * Range * 2 - Range;
end;

function RandomRange2(const MinVal, MaxVal: LongInt): LongInt;
begin
  Result := Random(MaxVal - MinVal) + MinVal;
end;

function Sign(const Val: Single): Single;
begin
  if (Val < 0) then
    Result := -1.0
  else if (Val > 0) then
    Result := 1.0
  else
    Result := 0;
end;

{ TFMain }

{ Sound alert WB (0 - 4) }
procedure TFMain.AlertWB(const Loudness: Byte);
var
  distancePlayer, rndVal, XR, YR: Single;
begin
  if (WB = 0) then Exit;

  distancePlayer := DistanceToSqr(WBPos[0], WBPos[1], camPosN[0], camPosN[1]);

  if (Loudness <> 0) then begin
    if (distancePlayer < 1.0) then begin
      WB := 4;
      Exit;
    end;
    if (distancePlayer < 3.0) then begin
      WBSetSolve(camPosN[0], camPosN[1]);
      Exit;
    end;
  end;

  case Loudness of
    0: begin
      RandomFloat(@rndVal, 2);
      rndVal := rndVal + 2.0;
      if (distancePlayer < rndVal) then begin
        RandomFloat(@rndVal, 1);
        XR := distancePlayer * 0.1 * rndVal + camPosN[0];
        RandomFloat(@rndVal, 1);
        YR := distancePlayer * 0.1 * rndVal + camPosN[1];
        WBSetSolve(XR, YR);
      end;
    end;
    1: begin
      Randomfloat(@rndVal, 10);
      rndVal := rndVal + 20.0;
      if (distancePlayer < rndVal) then begin
        RandomFloat(@rndVal, 1);
        XR := distancePlayer * 0.1 * rndVal + camPosN[0];
        RandomFloat(@rndVal, 1);
        YR := distancePlayer * 0.1 * rndVal + camPosN[1];
        WBSetSolve(XR, YR);

        if (Random(5) = 0) then
          alSourcePlay(SndWBAlarm);
      end;
      if ((WB = 2) or (WB = 3)) then
        WBSpMul := WBSpMul + 1.0;
    end;
    2: begin { Loud }
      alSourcePlay(SndWBAlarm);
      WBSetSolve(camPosN[0], camPosN[1]);
    end;
    3: WB := 4; { Near }
  end;

  Print('Alert level ', Loudness);
end;

{ Lazy raycast implementation }
function TFMain.CheckBlocked(const XFrom, YFrom, XTo, YTo: Single): Boolean;
var
  Direction: Single;
  CheckX, CheckY: Single;
  MazeX, MazeY, ToMazeX, ToMazeY: LongWord;
  DirInt, Iterations: Byte;
begin
  Result := False;

  CheckX := XFrom;
  CheckY := YFrom;

  for Iterations:=0 to 63 do begin
    Direction := GetDirection(CheckX, CheckY, XTo, YTo);
    if (Direction < 0.0) then
      Direction := Direction + MPI2;

    GetMazeCellPos(CheckX, CheckY, @MazeX, @MazeY);
    GetMazeCellPos(XTo, YTo, @ToMazeX, @ToMazeY);

    if ((MazeX = ToMazeX) and (MazeY = ToMazeY)) then
      Break;

    DirInt := Round(Direction * R2I);

    case DirInt of
      0, 4: begin { -Y }
        if (not GetCellMZC(MazeX, MazeY, MZC_PASSTOP)) then begin
          Result := True;
          Break;
        end else if (MazeCrevice <> 0) then
          if ((MazeX = MazeCrevicePos[0]) and (MazeY = MazeCrevicePos[1])) then
          begin
            Result := True;
            Break;
          end;
        CheckY := CheckY - flRaycast;
      end;
      1: begin { -X }
        if (not GetCellMZC(MazeX, MazeY, MZC_PASSLEFT)) then begin
          Result := True;
          Break;
        end else if (MazeCrevice <> 0) then
          if ((MazeX = MazeCrevicePos[0]) and (MazeY = MazeCrevicePos[1])) then
          begin
            Result := True;
            Break;
          end;
        CheckX := CheckX - flRaycast;
      end;
      2: begin { +Y }
        Inc(MazeY);
        if (not GetCellMZC(MazeX, MazeY, MZC_PASSTOP)) then begin
          Result := True;
          Break;
        end else if (MazeCrevice <> 0) then
          if ((MazeX = MazeCrevicePos[0]) and (MazeY = MazeCrevicePos[1])) then
          begin
            Result := True;
            Break;
          end;
        CheckY := CheckY + flRaycast;
      end;   
      3: begin { +X }
        Inc(MazeX);
        if (not GetCellMZC(MazeX, MazeY, MZC_PASSLEFT)) then begin
          Result := True;
          Break;
        end else if (MazeCrevice <> 0) then
          if ((MazeX = MazeCrevicePos[0]) and (MazeY = MazeCrevicePos[1])) then
          begin
            Result := True;
            Break;
          end;
        CheckX := CheckX + flRaycast;
      end;
    end;

    if (DistanceToSqr(CheckX, CheckY, XTo, YTo) < flRaycast) then
      Break;
  end;
end;

{ Check if WBBK is either too far (Th1) or not being looked at at distance Th2 }
function TFMain.CheckWBBKVisible(const Dist, Th1, Th2: Single): Boolean;
var
  dotX, dotY: Single;
begin
  if (Dist > Th1) then begin
    Result := False;
    Exit;
  end;

  if (Dist > Th2) then begin
    dotX := camPosN[0] - WBBKPos[0];
    dotY := camPosN[1] - WBBKPos[1];

    Normalize(@dotX, @dotY);
    if ((dotX * camForward[0] + dotY * camForward[2]) < 0.33) then begin
      Result := False;
      Exit;
    end;
  end;

  Result := True;
  Exit;
end;

{ Player collision with boundary from (X1, Y1) to (X2, Y2) }
procedure TFMain.CollidePlayer(const X1, X2, Y1, Y2: Single; const Vertical: Boolean);
begin
  if (InRange(camPosNext[0], camPosNext[2], X1, X2, Y1, Y2)) then begin
    if (Vertical) then
      camCurSpeed[0] := 0
    else
      camCurSpeed[2] := 0;

    { Second check because I like messing up performance }
    camPosNext[0] := camPosN[0] - camCurSpeed[0];
    camPosNext[2] := camPosN[1] - camCurSpeed[2];

    if (InRange(camPosNext[0], camPosNext[2], X1, X2, Y1, Y2)) then begin
      camCurSpeed[0] := -camCurSpeed[0];
      camCurSpeed[2] := -camCurSpeed[2];
    end;
  end;
end;

{ Player collision with wall at (PosX, PosY) }
procedure TFMain.CollidePlayerWall(const PosX, PosY: Single; const Vertical: Boolean);
begin
  if (DistanceToSqr(camPosNext[0], camPosNext[2], PosX, PosY) < 6.0) then begin
    if (not Vertical) then
      CollidePlayer(PosX - flWMr, PosX + flWLn, PosY - flWTh, PosY + flWTh, Vertical)
    else
      CollidePlayer(PosX - flWTh, PosX + flWTh, PosY - flWMr, PosY + flWLn, Vertical);
  end;
end;

{ Control player, called if canControl is True }
procedure TFMain.Control;
var
  curSpeed: Single;
  i: Byte;
begin
  curSpeed := 0;
  camCurSpeed[0] := 0.0;
  camCurSpeed[2] := 0.0;

  if (mkeyUp or mkeyDown) then begin
    if (mkeyDown) then begin
      camCurSpeed[0] := camCurSpeed[0] - camForward[0];
      camCurSpeed[2] := camCurSpeed[2] - camForward[2];
    end else begin
      camCurSpeed[0] := camCurSpeed[0] + camForward[0];
      camCurSpeed[2] := camCurSpeed[2] + camForward[2];
    end;
  end;    
  if (mkeyLeft or mkeyRight) then begin
    if (mkeyLeft) then begin
      camCurSpeed[0] := camCurSpeed[0] - camRight[0];
      camCurSpeed[2] := camCurSpeed[2] - camRight[2];
    end else begin
      camCurSpeed[0] := camCurSpeed[0] + camRight[0];
      camCurSpeed[2] := camCurSpeed[2] + camRight[2];
    end;
  end;

  if ((mkeyCtrl) or (MazeCrevice = 2)) then
    Lerp(@camCrouch, 2.0, delta20)
  else
    Lerp(@camCrouch, 0.0, delta20);

  if (MazeTramPlr = 0) then
    camPos[1] := camCrouch * 0.25 + flCamHeight;

  //JOYSTICK CONTROL

  { Tilt }
  Lerp(@camTilt, camCurSpeed[0] * camRight[0] - camCurSpeed[2] * camRight[2], delta2);

  curSpeed := MagnitudeSqr(camCurSpeed[0], camCurSpeed[2]); { Clamp magnitude }
  if (curSpeed > 1.0) then begin
    curSpeed := Sqrt(curSpeed);
    camCurSpeed[0] := camCurSpeed[0] / curSpeed;  
    camCurSpeed[2] := camCurSpeed[2] / curSpeed;
  end;

  curSpeed := MagnitudeSqr(camCurSpeed[0], camCurSpeed[2]) * deltaTime;

  camCurSpeed[0] := (flCamSpeed - camCrouch) * camCurSpeed[0] * deltaTime; { Deltatimize }
  camCurSpeed[2] := (flCamSpeed - camCrouch) * camCurSpeed[2] * deltaTime;

  if (Trench <> 0) then begin
    TrenchTimer := TrenchTimer - curSpeed * deltaTime;

    Print(TrenchTimer);

    camCurSpeed[0] := camCurSpeed[0] * 0.5;
    camCurSpeed[2] := camCurSpeed[2] * 0.5;

    curSpeed := curSpeed * 0.5;

    if (TrenchTimer < 0.0) then begin
      alSourcePlay(SndMistake);
      Trench := 0;
      fade := 1.0;
      fadeState := 1;
      glClearColor(0, 0, 0, 0);
      glFogfv(GL_FOG_COLOR, @mclBlack);
      alSourceStop(SndAmbT);
      alSourcePlay(SndAmb);

      alSourcef(SndWmblykB, AL_PITCH, 1.0);   
      alSourcef(SndWmblykB, AL_GAIN, 1.0);
      alSourceStop(SndWmblykB);

      camFOV := 75.0;

      ShowSubtitles(CCTrench);

      SpawnMazeElements;
    end;
  end;
  if ((MazeHostile >= 8) and (MazeHostile <= 11)) then begin
    camCurSpeed[0] := NoiseOpacity[0] * 2.0 * camCurSpeed[0];
    camCurSpeed[2] := NoiseOpacity[0] * 2.0 * camCurSpeed[2];

    curSpeed := NoiseOpacity[0] * 2.0 * curSpeed;
  end;

  camStep := curSpeed * flStep + camStep; { Walk animation }
  camStepSide := curSpeed * flStep + camStepSide;

  if ((curSpeed <> 0) and (WBBK <> 0)) then
    WBBKSTimer := 10.0;

  curSpeed := 3.0 - camCrouch * 0.4;
  alSourcef(SndStep[0], AL_GAIN, curSpeed);  
  alSourcef(SndStep[1], AL_GAIN, curSpeed);  
  alSourcef(SndStep[2], AL_GAIN, curSpeed);  
  alSourcef(SndStep[3], AL_GAIN, curSpeed);

  if (camStep > MPI) then begin
    camStep := camStep - MPI;
    repeat
      i := Random(4);
    until (i <> lastStepSnd);
    lastStepSnd := i;
    alSourcePlay(SndStep[i]);
    if (curSpeed > 0.5) then
      AlertWB(1)
    else
      AlertWB(0);
  end;
  if (camStepSide > MPI2) then
    camStepSide := camStepSide - MPI2;

  if (mFocused) then begin
    mouseRel[0] := Mouse.CursorPos.X - winCX; { Mouselook }
    mouseRel[1] := Mouse.CursorPos.Y - winCY;

    camRot[1] := camRot[1] - (mouseRel[0] * camTurnSpeed * deltaTime);
    camRot[0] := camRot[0] + (mouseRel[1] * camTurnSpeed * deltaTime);

    { Loop the direction once it has rotated fully }
    Angleify(@camRot[1]);
    Angleify(@camRotL[1]);
  end;
  camRot[0] := Clamp(camRot[0], -MPIHalf, MPIHalf);
end;

{ Load all models and textures }
procedure TFMain.CreateModels;
var
  i: LongWord;
begin
  Print('Creating models...');
  glNewList(3, GL_COMPILE_AND_EXECUTE);
	glBegin(GL_QUADS);
		glTexCoord2f(0.0, 1.0);
		glVertex3f(0.0, 1.0, 0.0);
		glTexCoord2f(1.0, 1.0);
		glVertex3f(1.0, 1.0, 0.0);
		glTexCoord2f(1.0, 0.0);
		glVertex3f(1.0, 0.0, 0.0);
		glTexCoord2f(0.0, 0.0);
		glVertex3f(0.0, 0.0, 0.0);
	glEnd;
	glEndList;

  LoadGCM(GFXDir+'wallM.gcm',            1);
  LoadGCM(GFXDir+'plane.gcm',            2);
  { Quad built in code                   3);}
  LoadGCM(GFXDir+'door.gcm',             4);
  LoadGCM(GFXDir+'doorFrame.gcm',        5);
  LoadGCM(GFXDir+'doorwayM.gcm',         6);
  LoadGCM(GFXDir+'lamp.gcm',             7);
	LoadGCM(GFXDir+'wmblykBody.gcm',       8);
	LoadGCM(GFXDir+'wmblykHead.gcm',       9);
	LoadGCM(GFXDir+'wmblykBodyG.gcm',      10);
	LoadGCM(GFXDir+'wmblykWalk1.gcm',      11);
	LoadGCM(GFXDir+'wmblykWalk2.gcm',      12);
	LoadGCM(GFXDir+'wmblykWalk3.gcm',      13);
	LoadGCM(GFXDir+'wmblykWalk4.gcm',      14);
	LoadGCM(GFXDir+'wmblykStr1.gcm',       15);
	LoadGCM(GFXDir+'wmblykStr2.gcm',       16);
	LoadGCM(GFXDir+'wmblykStr0.gcm',       17);
	LoadGCM(GFXDir+'wmblykStrL1.gcm',      18);
	LoadGCM(GFXDir+'wmblykStrL2.gcm',      19);
	LoadGCM(GFXDir+'wmblykStrL0.gcm',      20);
	LoadGCM(GFXDir+'wmblykStrW1.gcm',      21);
	LoadGCM(GFXDir+'wmblykStrW2.gcm',      22);
	LoadGCM(GFXDir+'wmblykStrW0.gcm',      23);
	LoadGCM(GFXDir+'wmblykDead.gcm',       24);
	LoadGCM(GFXDir+'wallT.gcm',            25);
	LoadGCM(GFXDir+'wallB.gcm',            26);
	LoadGCM(GFXDir+'stairsM.gcm',          27);
	LoadGCM(GFXDir+'pipe.gcm',             28);
	LoadGCM(GFXDir+'kubale1.gcm',          29);
	LoadGCM(GFXDir+'kubale2.gcm',          30);
	LoadGCM(GFXDir+'kubale3.gcm',          31);
	LoadGCM(GFXDir+'kubale4.gcm',          32);
	LoadGCM(GFXDir+'doorFrameLock.gcm',    33);
	LoadGCM(GFXDir+'padlock.gcm',          34);
	LoadGCM(GFXDir+'key.gcm',              35);
	LoadGCM(GFXDir+'glyphs.gcm',           36);
	LoadGCM(GFXDir+'wires.gcm',            37);
	LoadGCM(GFXDir+'compassWorld.gcm',     38);
	LoadGCM(GFXDir+'compassArrow.gcm',     39);
	LoadGCM(GFXDir+'cityConcrete.gcm',     40);
	LoadGCM(GFXDir+'cityFacade.gcm',       41);
	LoadGCM(GFXDir+'cityTerrain.gcm',      42);
	LoadGCM(GFXDir+'outskirtsRoad.gcm',    43);
	LoadGCM(GFXDir+'outskirtsTerrain.gcm', 44);
	LoadGCM(GFXDir+'outskirtsTrees.gcm',   45);
	LoadGCM(GFXDir+'outskirtsBunker.gcm',  46);
	LoadGCM(GFXDir+'sigil1.gcm',           47);
	LoadGCM(GFXDir+'sigil2.gcm',           48);
	LoadGCM(GFXDir+'taburetka.gcm',        49);
	LoadGCM(GFXDir+'wallTR.gcm',           50);
	LoadGCM(GFXDir+'planks.gcm',           51);
	LoadGCM(GFXDir+'vasT1.gcm',            52);
	LoadGCM(GFXDir+'vasT2.gcm',            53);
	LoadGCM(GFXDir+'vasT3.gcm',            54);
	LoadGCM(GFXDir+'hbd.gcm',              55);
	LoadGCM(GFXDir+'hbdS.gcm',             56);
	LoadGCM(GFXDir+'virdyaHead.gcm',       57);
	LoadGCM(GFXDir+'virdyaBody.gcm',       58);
	LoadGCM(GFXDir+'virdyaWalk1.gcm',      59);
	LoadGCM(GFXDir+'virdyaWalk2.gcm',      60);
	LoadGCM(GFXDir+'virdyaWalk3.gcm',      61);
	LoadGCM(GFXDir+'virdyaWalk4.gcm',      62);
	LoadGCM(GFXDir+'virdyaWalk5.gcm',      63);
	LoadGCM(GFXDir+'virdyaWalk6.gcm',      64);
	LoadGCM(GFXDir+'virdyaWalk7.gcm',      65);
	LoadGCM(GFXDir+'virdyaWalk8.gcm',      66);
	LoadGCM(GFXDir+'virdyaRest.gcm',       67);
	LoadGCM(GFXDir+'virdyaBack1.gcm',      68);
	LoadGCM(GFXDir+'virdyaBack2.gcm',      69);
	LoadGCM(GFXDir+'virdyaBack3.gcm',      70);
	LoadGCM(GFXDir+'virdyaBack4.gcm',      71);
	LoadGCM(GFXDir+'virdyaBack5.gcm',      72);
	LoadGCM(GFXDir+'virdyaBack6.gcm',      73);
	LoadGCM(GFXDir+'virdyaH1.gcm',         74);
	LoadGCM(GFXDir+'virdyaH2.gcm',         75);
	LoadGCM(GFXDir+'wallS.gcm',            76);
	LoadGCM(GFXDir+'signs1.gcm',           77);
	LoadGCM(GFXDir+'koluplykShop1.gcm',    78);
	LoadGCM(GFXDir+'koluplykShop2.gcm',    79);
	LoadGCM(GFXDir+'koluplykDig1.gcm',     80);
	LoadGCM(GFXDir+'koluplykDig2.gcm',     81);
	LoadGCM(GFXDir+'koluplykDig3.gcm',     82);
	LoadGCM(GFXDir+'koluplykDig4.gcm',     83);
	LoadGCM(GFXDir+'planeC.gcm',           84);
	LoadGCM(GFXDir+'checkFloor.gcm',       85);
	LoadGCM(GFXDir+'checkWalls.gcm',       86);
	LoadGCM(GFXDir+'checkRoof.gcm',        87);
	LoadGCM(GFXDir+'motrya1.gcm',          88);
	LoadGCM(GFXDir+'motrya2.gcm',          89);
	LoadGCM(GFXDir+'motrya3.gcm',          90);
	LoadGCM(GFXDir+'motrya4.gcm',          91);
	LoadGCM(GFXDir+'wallT2.gcm',           92);
	LoadGCM(GFXDir+'wallW.gcm',            93);
	LoadGCM(GFXDir+'upFloor.gcm',          94);
	LoadGCM(GFXDir+'upWalls.gcm',          95);
	LoadGCM(GFXDir+'upRoof.gcm',           96);
	LoadGCM(GFXDir+'terrain.gcm',          97);
	LoadGCM(GFXDir+'tram.gcm',             98);
	LoadGCM(GFXDir+'tramD1.gcm',           99);
	LoadGCM(GFXDir+'tramD2.gcm',           100);
	LoadGCM(GFXDir+'tramD3.gcm',           101);
	LoadGCM(GFXDir+'tramD4.gcm',           102);
	LoadGCM(GFXDir+'track.gcm',            103);
	LoadGCM(GFXDir+'trackTurn.gcm',        104);
	LoadGCM(GFXDir+'wmblykTram.gcm',       105);
	LoadGCM(GFXDir+'crevice.gcm',          106);
	LoadGCM(GFXDir+'wmblykCrawl1.gcm',     107);
	LoadGCM(GFXDir+'wmblykCrawl2.gcm',     108);
	LoadGCM(GFXDir+'neqaotor.gcm',         109);
	LoadGCM(GFXDir+'torlagg.gcm',          110);
	LoadGCM(GFXDir+'borderFloor.gcm',      111);
	LoadGCM(GFXDir+'borderWall.gcm',       112);
	LoadGCM(GFXDir+'sky.gcm',              113);
	LoadGCM(GFXDir+'wbWalk1.gcm',          114);
	LoadGCM(GFXDir+'wbWalk2.gcm',          115);
	LoadGCM(GFXDir+'wbWalk3.gcm',          116);
	LoadGCM(GFXDir+'wbIdle1.gcm',          117);
	LoadGCM(GFXDir+'wbIdle2.gcm',          118);
	LoadGCM(GFXDir+'wbAttack1.gcm',        119);
	LoadGCM(GFXDir+'wbAttack2.gcm',        120);
	LoadGCM(GFXDir+'wbAttack3.gcm',        121);
	LoadGCM(GFXDir+'wbbk.gcm',             122);
	LoadGCM(GFXDir+'virdyaWave1.gcm',      123);
	LoadGCM(GFXDir+'virdyaWave2.gcm',      124);
	LoadGCM(GFXDir+'virdyaWave3.gcm',      125);
	LoadGCM(GFXDir+'virdyaWave4.gcm',      126);
	LoadGCM(GFXDir+'virdyaWave5.gcm',      127);
	LoadGCM(GFXDir+'virdyaWave4.gcm',      128);	{ Ultra lazy }
	LoadGCM(GFXDir+'virdyaWave5.gcm',      129);
	LoadGCM(GFXDir+'virdyaWave4.gcm',      130);
	LoadGCM(GFXDir+'virdyaWave2.gcm',      131);
	LoadGCM(GFXDir+'wallD.gcm',            132);
	LoadGCM(GFXDir+'vebraLook1.gcm',       133);
	LoadGCM(GFXDir+'vebraLook2.gcm',       134);
	LoadGCM(GFXDir+'vebraExit1.gcm',       135);
	LoadGCM(GFXDir+'vebraExit2.gcm',       136);
	LoadGCM(GFXDir+'vebraExit3.gcm',       137);
	LoadGCM(GFXDir+'vebraExit4.gcm',       138);
	LoadGCM(GFXDir+'vebraExit5.gcm',       139);
	LoadGCM(GFXDir+'vebraExit6.gcm',       140);

  TexBricks := LoadTexture(GFXDir+'bricks.gct', IMG_GCT);   
  TexCompass := LoadTexture(GFXDir+'compass.gct', IMG_GCT5A1);  
  TexCompassWorld := LoadTexture(GFXDir+'compassWorld.gct', IMG_GCT5A1);   
  TexConcrete := LoadTexture(GFXDir+'concrete.gct', IMG_GCT);
  TexConcreteRoof := LoadTexture(GFXDir+'concreteRoof.gct', IMG_GCT);  
  TexCroa := LoadTexture(GFXDir+'croa.gct', IMG_GCT5A1);
  TexCursor := LoadTexture(GFXDir+'cursor.gct', IMG_GCT332);   
  TexDiamond := LoadTexture(GFXDir+'diamond.gct', IMG_GCT);  
  TexDirt := LoadTexture(GFXDir+'dirt.gct', IMG_GCT);        
  TexDoor := LoadTexture(GFXDir+'door.gct', IMG_GCT);
  TexDoorblur := LoadTexture(GFXDir+'doorblur.gct', IMG_GCT);   
  TexEBD[0] := LoadTexture(GFXDir+'EBD1.gct', IMG_GCT4 or IMG_HALFX);  
  TexEBD[1] := LoadTexture(GFXDir+'EBD2.gct', IMG_GCT4 or IMG_HALFX);
  TexEBD[2] := LoadTexture(GFXDir+'EBD3.gct', IMG_GCT4 or IMG_HALFX);  
  TexEBDShadow := LoadTexture(GFXDir+'EBDShadow.gct', IMG_GCT332);  
  TexFacade := LoadTexture(GFXDir+'facade.gct', IMG_GCT);          
  TexFloor := LoadTexture(GFXDir+'floor.gct', IMG_GCT);
  TexGlyphs := LoadTexture(GFXDir+'glyphs.gct', IMG_GCT);   
  TexHbd := LoadTexture(GFXDir+'hbd.gct', IMG_GCT);      
  TexKey := LoadTexture(GFXDir+'key.gct', IMG_GCT5A1 or IMG_HALFX); 
  TexKoluplyk := LoadTexture(GFXDir+'koluplyk.gct', IMG_GCT);       
  TexLamp := LoadTexture(GFXDir+'lamp.gct', IMG_GCT);
  TexLight := LoadTexture(GFXDir+'light.gct', IMG_GCT);   
  TexMap := LoadTexture(GFXDir+'map.gct', IMG_GCT5A1);
  TexMetal := LoadTexture(GFXDir+'metal.gct', IMG_GCT);  
  TexMetalFloor := LoadTexture(GFXDir+'metalFloor.gct', IMG_GCT);  
  TexMetalRoof := LoadTexture(GFXDir+'metalRoof.gct', IMG_GCT);    
  TexMotrya := LoadTexture(GFXDir+'motrya.gct', IMG_GCT);        
  TexNoise := LoadTexture(GFXDir+'noise.gct', IMG_GCT);
  TexPaper := LoadTexture(GFXDir+'paper.gct', IMG_GCT5A1);
  TexPipe := LoadTexture(GFXDir+'pipe.gct', IMG_GCT);      
  TexPlanks := LoadTexture(GFXDir+'planks.gct', IMG_GCT);  
  TexPlaster := LoadTexture(GFXDir+'plaster.gct', IMG_GCT);   
  TexRain := LoadTexture(GFXDir+'rain.gct', IMG_GCT);         
  TexRoof := LoadTexture(GFXDir+'roof.gct', IMG_GCT);
  TexSigns1 := LoadTexture(GFXDir+'signs1.gct', IMG_GCT);   
  TexShadow := LoadTexture(GFXDir+'shadow.gct', IMG_GCT);   
  TexSky := LoadTexture(GFXDir+'sky.gct', IMG_GCT or IMG_HALFX);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);  
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);    
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);  
  TexTaburetka := LoadTexture(GFXDir+'taburetka.gct', IMG_GCT);  
  TexTileBig := LoadTexture(GFXDir+'tileBig.gct', IMG_GCT);      
  TexTilefloor := LoadTexture(GFXDir+'tilefloor.gct', IMG_GCT);   
  TexTone := LoadTexture(GFXDir+'tone.gct', IMG_GCT332);     
  TexTram := LoadTexture(GFXDir+'tram.gct', IMG_GCT);
  TexTree := LoadTexture(GFXDir+'tree.gct', IMG_GCT5A1);
  TexTutorial := LoadTexture(GFXDir+'tutorial.gct', IMG_GCT332);   
  TexTutorialJ := LoadTexture(GFXDir+'tutorialJ.gct', IMG_GCT332);
  TexVas := LoadTexture(GFXDir+'vas.gct', IMG_GCT);               
  TexVebra := LoadTexture(GFXDir+'vebra.gct', IMG_GCT);
  TexVignette := LoadTexture(GFXDir+'vignette.gct', IMG_GCT or IMG_HALFY);   
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);   
  TexVignetteRed := LoadTexture(GFXDir+'vignetteRed.gct', IMG_GCT or IMG_HALFY);
  TexWall := LoadTexture(GFXDir+'wall.gct', IMG_GCT);                     
  TexWB := LoadTexture(GFXDir+'WB.gct', IMG_GCT or IMG_HALFX);
  TexWBBK := LoadTexture(GFXDir+'WBBK.gct', IMG_GCT);        
  TexWBBKP := LoadTexture(GFXDir+'WBBKP.gct', IMG_GCT);
  TexWBBK1 := LoadTexture(GFXDir+'WBBK1.gct', IMG_GCT);  
  TexWhitewall := LoadTexture(GFXDir+'whitewall.gct', IMG_GCT);

  TexGlyph[0] := LoadTexture(GFXDir+'glyph1.gct', IMG_GCT332 or IMG_HALFX);  
  TexGlyph[1] := LoadTexture(GFXDir+'glyph2.gct', IMG_GCT332 or IMG_HALFX); 
  TexGlyph[2] := LoadTexture(GFXDir+'glyph3.gct', IMG_GCT332 or IMG_HALFX);  
  TexGlyph[3] := LoadTexture(GFXDir+'glyph4.gct', IMG_GCT332 or IMG_HALFX);
  TexGlyph[4] := LoadTexture(GFXDir+'glyph5.gct', IMG_GCT332 or IMG_HALFX);  
  TexGlyph[5] := LoadTexture(GFXDir+'glyph6.gct', IMG_GCT332 or IMG_HALFX);  
  TexGlyph[6] := LoadTexture(GFXDir+'glyph7.gct', IMG_GCT332 or IMG_HALFX);

  TexWmblykHappy := LoadTexture(GFXDir+'wmblykHappy.gct', IMG_GCT565 or IMG_HALFX); 
  TexWmblykNeutral := LoadTexture(GFXDir+'wmblykNeutral.gct', IMG_GCT332 or IMG_HALFX);  
  TexWmblykJumpscare := LoadTexture(GFXDir+'wmblykJumpscare.gct', IMG_GCT565 or IMG_HALFY);
  TexWmblykStr := LoadTexture(GFXDir+'wmblykStr.gct', IMG_GCT332 or IMG_HALFX);        
  TexWmblykL1 := LoadTexture(GFXDir+'wmblykL1.gct', IMG_GCT332 or IMG_HALFX);
  TexWmblykL2 := LoadTexture(GFXDir+'wmblykL2.gct', IMG_GCT332 or IMG_HALFX);  
  TexWmblykL3 := LoadTexture(GFXDir+'wmblykL3.gct', IMG_GCT332 or IMG_HALFX);
  TexWmblykW1 := LoadTexture(GFXDir+'wmblykW1.gct', IMG_GCT565 or IMG_HALFX); 
  TexWmblykW2 := LoadTexture(GFXDir+'wmblykW2.gct', IMG_GCT565 or IMG_HALFX);

  TexVirdyaBlink := LoadTexture(GFXDir+'virdyaBlink.gct', IMG_GCT332 or IMG_HALFY);  
  TexVirdyaDown := LoadTexture(GFXDir+'virdyaDown.gct', IMG_GCT332 or IMG_HALFY);    
  TexVirdyaN := LoadTexture(GFXDir+'virdyaN.gct', IMG_GCT332 or IMG_HALFY);
  TexVirdyaNeut := LoadTexture(GFXDir+'virdyaNeut.gct', IMG_GCT332 or IMG_HALFY);   
  TexVirdyaUp := LoadTexture(GFXDir+'virdyaUp.gct', IMG_GCT332 or IMG_HALFY);

  TexKubale := LoadTexture(GFXDir+'kubale.gct', IMG_GCT);     
  TexKubaleInkblot[0] := LoadTexture(GFXDir+'kubaleV1.gct', IMG_GCT332);   
  TexKubaleInkblot[1] := LoadTexture(GFXDir+'kubaleV2.gct', IMG_GCT332);
  TexKubaleInkblot[2] := LoadTexture(GFXDir+'kubaleV3.gct', IMG_GCT332);  
  TexKubaleInkblot[3] := LoadTexture(GFXDir+'kubaleV4.gct', IMG_GCT332);
  TexKubaleInkblot[4] := LoadTexture(GFXDir+'kubaleV5.gct', IMG_GCT332); 
  TexKubaleInkblot[5] := LoadTexture(GFXDir+'kubaleV6.gct', IMG_GCT332); 
  TexKubaleInkblot[6] := LoadTexture(GFXDir+'kubaleV7.gct', IMG_GCT332);  
  TexKubaleInkblot[7] := LoadTexture(GFXDir+'kubaleV8.gct', IMG_GCT332); 
  TexKubaleInkblot[8] := LoadTexture(GFXDir+'kubaleV9.gct', IMG_GCT332);

  for i:=0 to Length(TexFont)-1 do begin
    TexFont[i] := LoadTexture(FontSymbols[i], IMG_GCT332 or IMG_HALFX);   
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, $812F);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, $812F);
  end;

  CurrentFloor := TexFloor;
  CurrentRoof := TexRoof;
  CurrentWall := TexWall;
  CurrentWallMDL := 1;
end;

{ Operate menu }
procedure TFMain.DoMenu;
var
  AudSt: ALInt = 0;
begin
  if (mMenu = 0) then begin
    Inc(mMenu);
    canControl := False;
    camCurSpeed[0] := 0;
    camCurSpeed[1] := 0;
    mFocused := False;

    alGetSourcei(SndAlarm, AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndAlarm);   
    alGetSourcei(SndAmb, AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndAmb);
    alGetSourcei(SndDrip, AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndDrip);   
    alGetSourcei(SndEBD, AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndEBD);
    alGetSourcei(SndEBDA, AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndEBDA);    
    alGetSourcei(SndExit, AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndExit);
    alGetSourcei(SndHbd, AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndHbd);     
    alGetSourcei(SndIntro, AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndIntro);
    alGetSourcei(SndKubale, AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndKubale);   
    alGetSourcei(SndKubaleAppear, AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndKubaleAppear);  
    alGetSourcei(SndKubaleV, AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndKubaleV);     
    alGetSourcei(SndMus5, AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndMus5);       
    alGetSourcei(SndSiren, AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndSiren);
    alGetSourcei(SndTram, AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndTram);      
    alGetSourcei(SndTramAnn[0], AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndTramAnn[0]);   
    alGetSourcei(SndTramAnn[1], AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndTramAnn[1]);
    alGetSourcei(SndTramAnn[2], AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndTramAnn[2]);
    alGetSourcei(SndWhisper, AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndWhisper);
    alGetSourcei(SndWBBK, AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndWBBK);      
    alGetSourcei(SndWmblyk, AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndWmblyk);
    alGetSourcei(SndWmblykB, AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndWmblykB);    
    alGetSourcei(SndWmblykStr, AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndWmblykStr);    
    alGetSourcei(SndWmblykStrM, AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndWmblykStrM);    
    alGetSourcei(SndAmbW[0], AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndAmbW[0]);        
    alGetSourcei(SndAmbW[1], AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndAmbW[1]);
    alGetSourcei(SndAmbW[2], AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndAmbW[2]);   
    alGetSourcei(SndAmbW[3], AL_SOURCE_STATE, AudSt);
    if (AudSt = AL_PLAYING) then
      alSourcePause(SndAmbW[3]);
    Exit;
  end else begin
    Dec(mMenu);
    if (mMenu = 1) then begin
      //DESTROY SETTINGS
      GLC.Cursor := crNone;
    end else if (mMenu = 0) then begin
      if ((playerState = 0) or (playerState = 19)) then
        canControl := True;
      mFocused := True;

      alGetSourcei(SndAlarm, AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndAlarm);
      alGetSourcei(SndAmb, AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndAmb);
      alGetSourcei(SndDrip, AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndDrip);
      alGetSourcei(SndEBD, AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndEBD);
      alGetSourcei(SndEBDA, AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndEBDA);
      alGetSourcei(SndExit, AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndExit);
      alGetSourcei(SndHbd, AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndHbd);
      alGetSourcei(SndIntro, AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndIntro);
      alGetSourcei(SndKubale, AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndKubale);
      alGetSourcei(SndKubaleAppear, AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndKubaleAppear);
      alGetSourcei(SndKubaleV, AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndKubaleV);
      alGetSourcei(SndMus5, AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndMus5);
      alGetSourcei(SndSiren, AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndSiren);
      alGetSourcei(SndTram, AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndTram);
      alGetSourcei(SndTramAnn[0], AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndTramAnn[0]);
      alGetSourcei(SndTramAnn[1], AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndTramAnn[1]);
      alGetSourcei(SndTramAnn[2], AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndTramAnn[2]);
      alGetSourcei(SndWhisper, AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndWhisper);
      alGetSourcei(SndWBBK, AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndWBBK);
      alGetSourcei(SndWmblyk, AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndWmblyk);
      alGetSourcei(SndWmblykB, AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndWmblykB);
      alGetSourcei(SndWmblykStr, AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndWmblykStr);
      alGetSourcei(SndWmblykStrM, AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndWmblykStrM);
      alGetSourcei(SndAmbW[0], AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndAmbW[0]);
      alGetSourcei(SndAmbW[1], AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndAmbW[1]);
      alGetSourcei(SndAmbW[2], AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndAmbW[2]);
      alGetSourcei(SndAmbW[3], AL_SOURCE_STATE, AudSt);
      if (AudSt = AL_PAUSED) then
        alSourcePlay(SndAmbW[3]);
    end;
  end;
end;

{ Operate playerState, for player cutscenes and more }
procedure TFMain.DoPlayerState;
var
  mtplr: Single;
begin
  { playerState 0 is for general gameplay }
  case playerState of
    1: begin { Enter maze, setup everything }
      camRot[0] := 0.3;
      camRotL[0] := 0.3;
      camRot[1] := MPI;
      camPos[0] := -1.0;
      camPos[1] := flCamHeight;
      camPos[2] := -0.2;
      camPosL[0] := -1.0;
      camPosL[2] := -0.2;

      camStep := 0;
      camStepSide := 0;

      MazeDoor := 0;

      fade := 1.0;
      fadeState := 1;

      playerState := 2;
    end;
    2: begin { Enter continuous }
      Lerp(@camRot[0], 0, delta2);
      Lerp(@camPos[2], -1.1, delta2);

     if (camPos[2] < -1.0) then
       if (MazeHostile <> 12) then begin
         canControl := True;
         playerState := 0;
       end else
         playerState := 18;
    end;
    3: begin { Exit continuous opendoor }
      canControl := False;
      camCurSpeed[0] := 0;
      camCurSpeed[2] := 0;

      if (MazeLevel = 63) then
        Lerp(@camRot[0], 0, delta2)
      else if (MazeHostile = 5) then
        Lerp(@camRot[0], -0.3, delta2)
      else
        Lerp(@camRot[0], 0.3, delta2);
      LerpAngle(@camRot[1], MPI, delta2);

      if (kubale < 29) then
        kubale := 0;

      Lerp(@camPos[0], MazeDoorPos[0], delta2);
      Lerp(@camPos[2], MazeDoorPos[1], delta2);

      if (Checkpoint <> 0) then begin
        if ((MazeHostile = 1) or (Glyphs = 7)) then begin
          Lerp(@CheckpointMus, 0, delta2);
          alSourcef(SndMus3, AL_GAIN, CheckpointMus);
          Lerp(@CheckpointDoor, -100.0, delta2);
          mtplr := CheckpointDoor;;
        end else begin
          Lerp(@MazeDoor, -100.0, delta2);
          mtplr := MazeDoor;
        end;
      end else begin
        Lerp(@MazeDoor, -100.0, delta2);
        mtplr := MazeDoor;
      end;
      if (mtplr < -90.0) then begin
        MazeDoorPos[1] := MazeDoorPos[1] - 2.0;
        fade := 0;
        fadeState := 2;
        playerState := 4;
        if (Checkpoint <> 0) then begin
          if (MazeHostile = 1) then
            alSourcePlay(SndAmb);
          alSourceStop(SndMus3);
        end;
      end;
    end;
    4: begin { Exit continuous }
      LerpAngle(@camRot[1], PI, delta2);

      Lerp(@camPos[0], MazeDoorPos[0], delta2);

      if (MazeHostile < 5) then
        Lerp(@camPos[1], 0.5 + flCamHeight, deltaTime);
      Lerp(@camPos[2], MazeDoorPos[1], delta2);

      if (Shn <> 0) then begin
        alGetSourcef(SndAlarm, AL_GAIN, mtplr);
        Lerp(@mtplr, 0, delta2);
        alSourcef(SndAlarm, AL_GAIN, mtplr);
      end;

      if (fade > 1.0) then begin
        PMSeed := MazeSeed;
        PMW := MazeW;
        PMH := MazeH;

        case Random(5) of
          0: Inc(MazeW);
          1: Inc(MazeH);
        end;

        if (MazeHostile < 5) then begin
          FreeMaze;
          MazeSeed := GetTickCount64;
          GenerateMaze(MazeSeed);
        end else if (MazeHostile = 5) then begin { Croa ending setup }
          if (Glyphs = 7) then begin
            Print('Croa');
            alSourcef(SndAmbT, AL_GAIN, 2.0);
            alSourcef(SndAmbT, AL_PITCH, 0.2);
            alSourcePlay(SndAmbT);
            MazeHostile := 12;
            Checkpoint := 0;
            canControl := False;
            glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @mclBlack);
            glLightf(GL_LIGHT0, GL_CONSTANT_ATTENUATION, 0.1);
            glLightf(GL_LIGHT0, GL_QUADRATIC_ATTENUATION, 0.01);
            { glLightf(GL_LIGHT0, GL_LINEAR_ATTENUATION, 1.0); }
            glLightfv(GL_LIGHT0, GL_DIFFUSE, @mclBlack);
            glLightfv(GL_LIGHT0, GL_SPECULAR, @mclBlack);
            camLight[1] := 32.0;
            camLight[2] := -20.0;
            glLightfv(GL_LIGHT0, GL_POSITION, @camLight);
          end else begin { Ascension ending setup }
            { Maze is already freed }
            Inc(MazeLevel);
            MazeHostile := 6;
            Checkpoint := 0;
            GlyphsInLayer := 0;
            MotryaTimer := 0;
            alSourcef(SndAmbT, AL_GAIN, 0);
            alSourcef(SndAmbT, AL_PITCH, 0.2);
            alSourcePlay(SndAmbT);
            alSourcef(SndVirdya, AL_GAIN, 0);
            alSourcePlay(SndVirdya);
            alSourcef(SndWBBK, AL_GAIN, 0);
            alSourcePlay(SndWBBK);
            alSourcePlay(SndMus4);
          end;
        end;

        playerState := 5;
        MazeLevelPopupTimer := 2.0;
        MazeLevelPopup := 1;
      end;
    end;
    5: begin { Exit wait }
      Lerp(@MazeDoor, MPI, delta20);
      if (MazeDoor < MPI2) then
        playerState := 1;
    end;
    6: begin { Strangle setup }
      canControl := False;
      camCurSpeed[0] := 0;
      camCurSpeed[2] := 0;

      camStranglePos[0] := camPos[0];   
      camStranglePos[1] := camPos[2];

      camRot[1] := GetDirection(camPosN[0], camPosN[1], wmblykPos[0], wmblykPos[1]);

      playerState := 7
    end;
    7: begin { Strangle continuous }
      // JOYSTICK SUBTITLES
      ShowSubtitles(CCSpace);

      camRot[0] := mouseRel[1] * deltaTime + wmblykStr;
      mtplr := 0.9 - Sqr(wmblykStr + 0.5);

      camPos[0] := -(camForward[0] * mtplr + wmblykPos[0]);
      camPos[2] := -(camForward[2] * mtplr + wmblykPos[1]);

      camPos[1] := (Abs(wmblykStr * 0.5) + flCamHeight) - (wmblykStr + 0.1) * 0.1;

      { Screen shake }
      Shake(D2R);

      { Time limit }
      fade := fade + deltaTime * 0.1;
      if (fade > 1.0) then
        playerState := 9;
      Lerp(@vignetteRed, 1.0, deltaTime);

      alSourcef(SndWmblykB, AL_GAIN, wmblykStr + 0.5);
    end;
    8: begin { Strangle ogovtuyetsia }
      ccTimer := 0;

      Lerp(@camRot[0], 0.1, deltaTime);   
      Lerp(@camPos[0], camStranglePos[0], deltaTime);  
      Lerp(@camPos[2], camStranglePos[1], deltaTime);  
      Lerp(@camPos[1], flCamHeight, deltaTime);       
      Lerp(@fade, -0.1, deltaTime);            
      Lerp(@vignetteRed, 0, delta2);
      Lerp(@wmblykStr, -0.5, delta2);

      alSourcef(SndWmblykB, AL_GAIN, wmblykStr + 0.5);

      if (fade <= 0) then begin
        fade := 0;
        camPos[1] := flCamHeight;
        playerState := 0;
        camRot[0] := 0;
        canControl := True;
        alSourceStop(SndWmblykB);
      end;
    end;
    9, 10: begin { Dead }
      Lerp(@camRot[0], -MPIHalf, deltaTime);
      EraseTempSave;
      if (playerState = 9) then begin
        canControl := False;
        Lerp(@fade, 1.2, deltaTime);
        if (fade > 1.0) then begin
          alSourcePlay(SndDeath);
          MazeTram := 0;
          alSourceStop(SndTram);
          alSourceStop(SndTramAnn[0]);  
          alSourceStop(SndTramAnn[1]);  
          alSourceStop(SndTramAnn[2]);
          WB := 0;
          alSourceStop(SndHbd);
          hbd := 0;

          playerState := 10;
        end;
      end;

      alGetSourcef(SndAmb, AL_GAIN, mtplr);
      Lerp(@mtplr, 0, deltaTime);
      alSourcef(SndAmb, AL_GAIN, mtplr);

      alGetSourcef(SndWmblykB, AL_GAIN, mtplr);
      Lerp(@mtplr, 0, deltaTime);
      alSourcef(SndWmblykB, AL_GAIN, mtplr);

      alGetSourcef(SndWmblykStrM, AL_GAIN, mtplr);
      Lerp(@mtplr, 0, deltaTime);
      alSourcef(SndWmblykStrM, AL_GAIN, mtplr);     

      alGetSourcef(SndHbd, AL_GAIN, mtplr);
      Lerp(@mtplr, 0, deltaTime);
      alSourcef(SndHbd, AL_GAIN, mtplr);
    end;
    11, 13, 15, 17: begin { Intro black }
      if (MazeHostile = 11) then
        Exit;
      fade := 0;
      fogDensity := 0.1;
      if (wmblykBlink < 0.0) then begin
        if (playerState = 17) then begin
          GenerateMaze(GetTickCount64);
          MazeHostile := 0;
          playerState := 1;
          alSourcePlay(SndSiren);
          Exit;
        end;
        Inc(playerState);
        wmblykBlink := 4.0;
      end;
    end;
    12: begin { Intro looks around city }
      mtplr := deltaTime * 0.1;
      Lerp(@camRot[0], -0.6, mtplr);
      LerpAngle(@camRot[1], 3.0, deltaTime);

      Lerp(@fogDensity, 0.5, mtplr);

      if (wmblykBlink < 0.0) then begin
        Inc(playerState);
        wmblykBlink := 4.0;
        camRot[0] := 0;
        camRot[1] := MPI;
      end;
    end;
    14: begin { Intro runs through the outskirts }
      camPos[2] := camPos[2] - deltaTime * 6.0;
      camStep := camStep + delta2 * 5.0;
      camStepSide := camStep;

      Lerp(@fogDensity, 0.1, deltaTime);

      if (wmblykBlink < 0.0) then begin
        Inc(playerState);
        wmblykBlink := 4.0;
        fogDensity := 0.5;
        camPos[2] := -16.0;
      end;
    end;
    16: begin { Intro runs through the woods, towards Maze }
      camPos[2] := camPos[2] - deltaTime * 6.0;
      camStep := camStep + delta2 * 5.0;
      camStepSide := camStep;

      Lerp(@fogDensity, 0.1, deltaTime);
      if (wmblykBlink < 0.0) then begin
        Inc(playerState);
        wmblykBlink := 5.0;
      end;
    end;
  end;

  if ((playerState >= 11) and (playerState <= 17)) then { Intro timer }
    wmblykBlink := wmblykBlink - deltaTime;
end;

{ Draw the ascend part of ending }
procedure TFMain.DrawAscend;
var
  ColCheck: Single;
  i: Byte;
begin
  Lerp(@NoiseOpacity[0], NoiseOpacity[1], deltaTime);

  ColCheck := NoiseOpacity[0] * 0.1 + 1.0;
  camCurSpeed[0] := camCurSpeed[0] * ColCheck;
  camCurSpeed[2] := camCurSpeed[2] * ColCheck;

  if (MazeHostile = 7) then begin { Last door opened }
    glClearColor(1.0, 1.0, 1.0, 1.0);
    Lerp(@camPos[0], -1.0, deltaTime);
    Lerp(@camRot[0], 0, deltaTime);
    LerpAngle(@camRot[1], MPI, deltaTime);

    ColCheck := deltaTime * 0.33;
    Lerp(@AscendSky, 1.0, ColCheck);

    AscendColor[0] := AscendSky;  
    AscendColor[1] := AscendSky;
    AscendColor[2] := AscendSky;
    AscendColor[3] := AscendSky;
    glFogfv(GL_FOG_COLOR, @AscendColor);
    fogDensity := fogDensity + delta2;

    MotryaTimer := MotryaTimer + ColCheck;

    camPos[2] := camPos[2] - deltaTime;

    camCurSpeed[0] := 0;
    camCurSpeed[2] := 0;

    if (MazeLevel = 0) then
      if (camPosN[1] > 2.0) then begin
        MazeHostile := 8;
        NoiseOpacity[0] := 0.5;
        canControl := True;
        camPos[0] := 0;
        camPos[2] := 0;
        camPosL[0] := 0;
        camPosL[2] := 0;
      end;
  end;

  { Collision }
  if (camPosNext[0] < flWTh) then
    camCurSpeed[0] := 0;
  if (camPosNext[0] > (2.0 - flWTh)) then
    camCurSpeed[0] := 0;

  if (camPosNext[2] < flWTh) then
    camCurSpeed[2] := 0;

  CollidePlayerWall(-flDoor - flDoor, 12.0, False);

  CollidePlayerWall(flDoor + flDoor, 12.0, False);


  alSource3f(SndCheckpoint, AL_POSITION, camPosN[0], 3.0, camPosN[1]); 
  alSource3f(SndDoorClose, AL_POSITION, camPosN[0], 3.0, camPosN[1]);   
  alSource3f(SndWBBK, AL_POSITION, camPosN[0], 3.0, camPosN[1]);        
  alSource3f(SndMus4, AL_POSITION, camPosN[0], 3.0, camPosN[1]);

  Lerp(@AscendVolume[0], AscendVolume[1], deltaTime);
  alSourcef(SndAmbT, AL_GAIN, AscendVolume[0]);
  alSourcef(SndVirdya, AL_GAIN, AscendVolume[0]);   
  alSourcef(SndMus4, AL_GAIN, AscendVolume[0]);
  alSourcef(SndWBBK, AL_GAIN, AscendVolume[0] * 0.2);

  ColCheck := Clamp((2.0 + camPos[2]) * 0.5, -4.0, 0);

  if (camPosN[1] > 10.0) then begin { Open / close door }
    if (MazeHostile = 7) then
      Lerp(@MazeDoor, -100.0, deltaTime)
    else
      Lerp(@MazeDoor, -100.0, delta2);
    if (AscendDoor = 0) then begin
      AscendDoor := 1;
      if (MazeLevel = 2) then begin
        canControl := False;
        MazeHostile := 7;
        alSourcePlay(SndExit1);
        alSourceStop(SndAmbT);
        alSourceStop(SndVirdya);
        alSourceStop(SndWBBK);
        alSourceStop(SndMus4);
      end else
        alSourcePlay(SndCheckpoint);
    end;
  end else begin
    Lerp(@MazeDoor, 0, delta2);
    if (AscendDoor = 1) then begin
      AscendDoor := 0;
      alSourcePlay(SndDoorClose);
    end;
  end;

  glPushMatrix;
    glTranslatef(0, ColCheck, 0);

    glBindTexture(GL_TEXTURE_2D, TexFloor);
    glCallList(94);
    glBindTexture(GL_TEXTURE_2D, TexWall);
    glCallList(95);
    glBindTexture(GL_TEXTURE_2D, TexRoof);
    glCallList(96);

    glBindTexture(GL_TEXTURE_2D, TexDoor);
    glCallList(5);
    glPushMatrix;
      glTranslatef(flDoor, 0, 0);
      glRotatef(MazeDoor, 0, 1.0, 0);
      glCallList(4);
    glPopMatrix;

    glPushMatrix;
      glTranslatef(0, 4.0, 12.0);

      if (MazeLevel > 2) then begin
        glBindTexture(GL_TEXTURE_2D, TexFloor);
        glCallList(94);
        glBindTexture(GL_TEXTURE_2D, TexWall);
        glCallList(95);
        glBindTexture(GL_TEXTURE_2D, TexRoof);
        glCallList(96);
      end;

      glBindTexture(GL_TEXTURE_2D, TexDoor);
      glCallList(5);
      glTranslatef(flDoor, 0, 0);
      glRotatef(MazeDoor, 0, 1.0, 0);
      glCallList(4);
    glPopMatrix;

    glPushMatrix;
      glTranslatef(0, -4.0, -12.0);

      glBindTexture(GL_TEXTURE_2D, TexFloor);
      glCallList(94);
      glBindTexture(GL_TEXTURE_2D, TexWall);  
      glCallList(95);
      glBindTexture(GL_TEXTURE_2D, TexRoof);   
      glCallList(96);

      glBindTexture(GL_TEXTURE_2D, TexDoor);
      glCallList(5);
      glTranslatef(flDoor, 0, 0);
      glRotatef(MazeDoor, 0, 1.0, 0);
      glCallList(4);
    glPopMatrix;
  glPopMatrix;

  if (camPos[2] < -13.0) then begin { Advance layers }
    camPos[2] := camPos[2] + 12.0;
    camPosL[2] := camPosL[2] + 12.0;
    MazeLevel := MazeLevel - 2;
    Str(MazeLevel, MazeLevelStr);
    MazeLevelPopupTimer := 2.0;
    MazeLevelPopup := 1;

    SetNoiseOpacity;

    AscendVolume[1] := 3.0 / (MazeLevel * 2.0);

    if ((MazeLevel < 36) and (MazeLevel <> 0)) then begin
      i := Random(30);
      if (i <> ccTextLast) then begin
        ccTextLast := i;
        case i of
          0: ShowSubtitles(CCAscend1);  
          1: ShowSubtitles(CCAscend2);
          2: ShowSubtitles(CCAscend3);
          3: ShowSubtitles(CCAscend4);
          4: ShowSubtitles(CCAscend5);
          5: ShowSubtitles(CCAscend6);
        end;
      end;
    end;
  end;
end;

{ Draw TextString text at (X, Y) }
procedure TFMain.DrawBitmapText(const TextString: AnsiString; const X, Y: Single;
  const TextAlign: Byte);
var
  Carriage: Boolean = False;
  MChar: Char;
  StrIdx: LongWord;
  StrLength: LongInt = 0;
begin
  glPushMatrix;
  glTranslatef(X, Y, 0);
  glScalef(mnFont[0], mnFont[1], 1.0);

  StrLength := TextString.IndexOf(#35);
  if (StrLength = -1) then StrLength := Length(TextString)
  else Carriage := True;

  if (TextAlign <> FNT_LEFT) then begin
    if (TextAlign = FNT_CENTERED) then
      glTranslatef(-(mnFontSpacing * StrLength * 0.5), 0, 0);
  end;
  StrIdx := 0;

  while True do begin
    if (StrLength = 0) then Break;
    MChar := TextString[StrIdx+1];

    if (MChar > #64) and (MChar < #91) then begin
      glBindTexture(GL_TEXTURE_2D, TexFont[Ord(MChar) - 65]);
      glCallList(3);
    end else if (MChar > #47) and (MChar < #58) then begin
      glBindTexture(GL_TEXTURE_2D, TexFont[Ord(MChar) - 22]);
      glCallList(3)
    end else begin
      case MChar of
        #46: begin
          glBindTexture(GL_TEXTURE_2D, TexFont[36]);
          glCallList(3);
        end;      
        #44: begin
          glBindTexture(GL_TEXTURE_2D, TexFont[37]);
          glCallList(3);
        end;
        #63: begin
          glBindTexture(GL_TEXTURE_2D, TexFont[39]);
          glCallList(3);
        end;    
        #33: begin
          glBindTexture(GL_TEXTURE_2D, TexFont[38]);
          glCallList(3);
        end;   
        #45: begin
          glBindTexture(GL_TEXTURE_2D, TexFont[40]);
          glCallList(3);
        end;
      end;
    end;

    glTranslatef(mnFontSpacing, 0, 0);

    Inc(StrIdx);
    Dec(StrLength);
  end;

  glPopMatrix;

  if (Carriage) then begin
    DrawBitmapText(TextString.Substring(StrIdx+1), X, Y+mnFont[0]+mnFont[1], TextAlign);
  end;
end;

{ Draw the abyss border part of ending }
procedure TFMain.DrawBorder;
var
  mtplr: Single;
begin
  if (CroaTimer > 75.0) then begin
    Lerp(@CroaTimer, 74.0, delta2);
    camFOV := CroaTimer;
  end;

  CroaCCTimer := deltaTime * 0.2 + CroaCCTimer;

  GlyphRot[0] := GlyphRot[0] + deltaTime;
  GlyphPos[0] := (Sin(GlyphRot[0]) + 3.0) * 0.25;

  glBindTexture(GL_TEXTURE_2D, TexFloor);
  glCallList(111);
  glBindTexture(GL_TEXTURE_2D, TexWall);
  glCallList(112);
  glBindTexture(GL_TEXTURE_2D, TexDoor);
  glCallList(5);

  glPushMatrix;
    glTranslatef(flDoor, 0, 0);
    glCallList(4);
  glPopMatrix;
  CollidePlayerWall(0, 0.2, False);
  CollidePlayerWall(0, 0.2, True);
  CollidePlayerWall(2.0, 0, True);    
  CollidePlayerWall(-1.5, 1.8, False);  
  CollidePlayerWall(1.5, 1.8, False);

  if (camPosN[1] > 2.5) then begin
    canControl := False;
    fade := deltaTime * 0.75 + fade;
    Lerp(@ShopTimer, 10.0, deltaTime);
    camPos[1] := ShopTimer * deltaTime + camPos[1];
    fadeState := 0;

    alGetSourcef(SndAmbT, AL_GAIN, mtplr);
    Lerp(@mtplr, 0, deltaTime);
    alSourcef(SndAmbT, AL_GAIN, mtplr);

    if (fade > 1.5) then begin
      playerState := 17;
      MazeHostile := 11;
      NoiseOpacity[0] := 0;
      MotryaTimer := 0;

      defKey := TRegistry.Create;
      defKey.OpenKey(RegPath, True);
      Complete := 2;
      defKey.WriteBinaryData(RegComplete, Complete, 1);
      defKey.Free;

      EraseTempSave;
    end;
  end;

  glPushMatrix;
    glTranslatef(camPosN[0], 0, camPosN[1]);
    glRotatef(CroaCCTimer, 0, 1.0, 0);
    glScalef(GlyphPos[0], GlyphPos[0], GlyphPos[0]);
    glColor3f(GlyphPos[0], GlyphPos[0], GlyphPos[0]);
    glDisable(GL_FOG);
    glDisable(GL_LIGHTING);
    glBindTexture(GL_TEXTURE_2D, TexSky);
    glCallList(113);
    glEnable(GL_FOG);
    glEnable(GL_LIGHTING);
  glPopMatrix;
  glColor3fv(@mclWhite);
end;

{ Draw save checkpoint }
procedure TFMain.DrawCheckpoint(const PosX, PosY: Single);
var
  PosX1, PosY1: Single;
begin
  { Behold, collisions }
  CollidePlayerWall(PosX - flDoor - flDoor, PosY, False);
  CollidePlayerWall(PosX + flDoor + flDoor, PosY, False);

  PosY1 := PosY + 4.0;
  if (MazeLevel = 63) then
    PosY1 := PosY1 + 2.0;

  CollidePlayer(PosX, PosX + flDoor + flWMr, PosY, PosY1, True);

  PosX1 := PosX + 2.0;
  CollidePlayer(PosX1 - flDoor - flWMr, PosX1, PosY, PosY1, True);

  if (MazeLevel <> 63) then begin
    PosY1 := PosY1 + 2.0;
    PosX1 := PosX + flWMr;
    CollidePlayer(PosX1 - 0.5, PosX1, PosY, PosY1, True);

    PosX1 := PosX + 2.0 - flWMr;
    CollidePlayer(PosX1, PosX1 + 0.5, PosY, PosY1, True);
  end;

  CollidePlayerWall(PosX, PosY1, False);

  if ((Checkpoint > 2) and ((playerState = 0) or (playerState = 19))) then begin
    Lerp(@CheckpointMus, 0.33, deltaTime);
    alSourcef(SndMus3, AL_GAIN, CheckpointMus);

    if (DistanceScalar(camPosN[1], PosY1) < 1.2) then begin
      Checkpoint := 4;
      if (ccTimer < 0.0) then begin
        //JOYSTICK USED
        ccText := CCCheckpoint;
        cctimer := 0.1;
      end;
    end else if (Checkpoint = 4) then
      Checkpoint := 3;
  end;

  glPushMatrix;
    glTranslatef(CheckpointPos[0], 0, CheckpointPos[1]);

    if ((MazeLevel = 63) and (Length(Maze) = 0) and (Glyphs < 7)) then begin
      if (playerState = 19) then
        Lerp(@MazeDoor, 0, delta2);

      glTranslatef(1.0, 0, 3.0);
      PosX1 := Clamp(-(PosY + 2.0 + camPosL[2]) * 0.5, 0, 1.0) * MPI * R2D;
      glRotatef(PosX1, 0, 1.0, 0);
      glTranslatef(-1.0, 0, -3.0);
    end;

    glBindTexture(GL_TEXTURE_2D, CurrentWall);
    glCallList(86);
    if (Length(Maze) = 0) then begin { Draw door if just loaded in with no maze }
      glCallList(6);
      glBindTexture(GL_TEXTURE_2D, TexDoor);
      glCallList(5);

      glPushMatrix;
        glTranslatef(flDoor, 0, 0);
        glRotatef(MazeDoor, 0, 1.0, 0);
        glCallList(4);
      glPopMatrix;
      CollidePlayerWall(PosX, PosY, False);
    end;

    glBindTexture(GL_TEXTURE_2D, CurrentFloor);
    glCallList(85);
    glBindTexture(GL_TEXTURE_2D, CurrentRoof);
    glCallList(87);

    glTranslatef(0, 0, 6.0);

    glPushMatrix;
      DrawFloorRoofEnd;
      glBindTexture(GL_TEXTURE_2D, CurrentWall);
      glCallList(6);
      glBindTexture(GL_TEXTURE_2D, TexDoor);
      glCallList(5);
      glTranslatef(flDoor, 0, 0);
      glRotatef(Checkpointdoor, 0, 1.0, 0);
      glCallList(4);
    glPopMatrix;

    glTranslatef(1.0, 2.2, -0.01);
    glScalef(0.6, 0.6, 0.6);
    glEnable(GL_BLEND);
    glDisable(GL_LIGHTING);
    glDisable(GL_FOG);
    glBlendFunc(GL_ONE, GL_ONE);
    glBindTexture(GL_TEXTURE_2D, TexTone);
    glCallList(84);
    glDisable(GL_BLEND);
    glEnable(GL_LIGHTING);
    glEnable(GL_FOG);
  glPopMatrix;


end;

{ The Croa have come }
procedure TFMain.DrawCroa;
var
  fltVal: Single;
begin
  CroaTimer := CroaTimer - deltaTime;
  if (CroaTimer < 0.0) then begin
    case Croa of
      0: begin { Move in }
        alSourcef(SndAlarm, AL_PITCH, 0.3);
        alSourcef(SndAlarm, AL_GAIN, 0.3);
        alSourcePlay(SndAlarm);
        CroaTimer := 8.0;
        Croa := 1;
      end;
      1: begin { Settle }
        CroaTimer := 35.8;
        Croa := 2;
      end;
      2: begin { Disappear }
        MazeHostile := 13;
        fadeState := 1;
        fade := 1.0;
        Motrya := 2;
        MotryaTimer := 1.0;
        canControl := True;
        playerState := 19;

        alSourceStop(SndAlarm);
        alSourcef(SndDistress, AL_PITCH, 0.5);
        alSourcePlay(SndDistress);

        alSourcef(SndAmbT, AL_PITCH, 1.0);

        glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @mclDarkGray);
        glLightf(GL_LIGHT0, GL_CONSTANT_ATTENUATION, 1.0);
			  glLightf(GL_LIGHT0, GL_QUADRATIC_ATTENUATION, 0);
			  glLightfv(GL_LIGHT0, GL_DIFFUSE, @mclWhite);
			  glLightfv(GL_LIGHT0, GL_SPECULAR, @mclGray);

        CroaTimer := 180.0;  { Set FOV to 180 }
        ShopTimer := 0;	     { Set fall speed to 0 }
      end;
    end;
  end;

  if (CroaCC < 14) then begin
    CroaCCTimer := CroaCCTimer - deltaTime;
    if (CroaCCTimer < 0.0) then begin
      case CroaCC of
        0: begin
          alSourcePlay(SndMus5);
          CroaCCTimer := 0.5;
        end;
        1: begin
          ShowSubtitles(CCCroa1, 2.5);
          CroaCCTimer := 3.5;
        end;    
        2: begin
          ShowSubtitles(CCCroa2, 2.3);
          CroaCCTimer := 2.5;
        end;      
        3: begin
          ShowSubtitles(CCCroa3, 2.5);
          CroaCCTimer := 3.5;
        end;
        4: begin
          ShowSubtitles(CCCroa4, 3.0);
          CroaCCTimer := 3.25;
        end;  
        5: begin
          ShowSubtitles(CCCroa5, 2.0);
          CroaCCTimer := 2.25;
        end; 
        6: begin
          ShowSubtitles(CCCroa6, 3.5);
          CroaCCTimer := 4.5;
        end;   
        7: begin
          ShowSubtitles(CCCroa7, 2.25);
          CroaCCTimer := 2.5;
        end;     
        8: begin
          ShowSubtitles(CCCroa8, 1.75);
          CroaCCTimer := 2.0;
        end;
        9: begin
          ShowSubtitles(CCCroa9, 2.75);
          CroaCCTimer := 3.0;
        end;     
        10: begin
          ShowSubtitles(CCCroa10, 3.0);
          CroaCCTimer := 3.25;
        end;     
        11: begin
          ShowSubtitles(CCCroa11, 2.5);
          CroaCCTimer := 2.75;
        end;   
        12: begin
          ShowSubtitles(CCCroa12, 3.5);
          CroaCCTimer := 5.0;
        end; 
        13: ShowSubtitles(CCCroa13, 3.0);
      end;
      Inc(CroaCC);
    end;
  end;

  if (Croa <> 0) then begin
    fltVal := deltaTime * 0.5;
    Lerp(@CroaPos, 2.0, fltVal);

    Lerp(@AscendSky, 0.9, delta2); { Lighting }
    AscendSky := fltVal * 0.1 + AscendSky;
    Lerp(@camLight[1], -2.0, deltaTime);
    Lerp(@camLight[2], -2.0, deltaTime);
    glLightfv(GL_LIGHT0, GL_POSITION, @camLight);
    AscendColor[0] := AscendSky;
    AscendColor[1] := AscendSky * 0.75;   
    AscendColor[2] := AscendColor[1] * 0.75;
    glLightfv(GL_LIGHT0, GL_SPECULAR, @AscendColor);
    if (Croa = 2) then begin
      Lerp(@CroaColor[0], 0.01, fltVal);
      CroaColor[0] := CroaColor[0] + fltVal;   
      CroaColor[1] := CroaColor[0] * 0.75;     
      CroaColor[2] := CroaColor[1] * 0.75;    
      glLightfv(GL_LIGHT0, GL_AMBIENT, @CroaColor);
    end;
  end;

  MazeGlyphsPos[0] := MazeGlyphsPos[0] + deltaTime;
  MazeGlyphsPos[1] := deltaTime * 0.9 + MazeGlyphsPos[1];

  glEnable(GL_ALPHA_TEST);
  glAlphaFunc(GL_GREATER, 0);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glBindTexture(GL_TEXTURE_2D, TexCroa);
  glPushMatrix;
    glTranslatef(CroaPos, Sin(MazeGlyphsPos[0]) * 0.01, 5.0 - CroaPos);
    glRotatef(CroaPos * 8.0, 0, 1.0, 0);
    glCallList(110);
  glPopMatrix;
  glPushMatrix;
    glTranslatef(2.0 - CroaPos, Sin(MazeGlyphsPos[1]) * 0.01, 5.0 - CroaPos);
    glRotatef(-(CroaPos * 8.0), 0, 1.0, 0);
    glCallList(109);
  glPopMatrix;
  glDisable(GL_ALPHA_TEST);
end;

{ Draw and process Eblodryn }
procedure TFMain.DrawEbd;
var
  animSin, dist, sinOff: Single;
  xPos, yPos, zPos, xNeg: Single;
  hairID, i: Byte;
begin
  dist := DistanceToSqr(EBDPos[0], EBDPos[1], camPosN[0], camPosN[1]);
  animSin := (13.0 - Clamp(dist, 0, 10.0)) * 0.5 * deltaTime;

  if (playerState = 0) then
    if (dist < 1.0) then begin
      if (camCrouch < 1.0) then begin
        animSin := animSin + delta20;

        Lerp(@EBDSound, 1.0, delta20);
        fade := fade + deltaTime + delta2;
        vignetteRed := vignetteRed + delta2 + delta2;
        if (fade > 1.0) then begin
          canControl := False;
          playerState := 9;
          alSourceStop(SndEBD);
          alSourceStop(SndEBDA);
        end;
      end else begin
        if ((kubale = 0) and (virdya = 0)) then begin
          Lerp(@fade, 0, delta2);
          Lerp(@vignetteRed, 0, delta2);
        end;
        Lerp(@EBDSound, 0, delta20);
      end;
    end else begin
      if ((kubale = 0) and (virdya = 0)) then begin
        Lerp(@fade, 0, delta2);
        Lerp(@vignetteRed, 0, delta2);
      end;
      Lerp(@EBDSound, 0, delta20);
    end;

  alSourcef(SndEBDA, AL_GAIN, EBDSound);

  EBDAnim := EBDAnim + animSin;
  if (EBDAnim > MPI2) then
    EBDAnim := EBDAnim - MPI2;

  glEnable(GL_BLEND);
  glDisable(GL_LIGHTING);

  glBindTexture(GL_TEXTURE_2D, TexEBDShadow);
  glDisable(GL_FOG);
  glBlendFunc(GL_ZERO, GL_SRC_COLOR);
  glPushMatrix;
    glTranslatef(EBDPos[0], 2.0, EBDPos[1]);
    glRotatef(180.0, 1.0, 0, 0);
    glTranslatef(-1.0, 0.01, -1.0);
    glCallList(2);
  glPopMatrix;
  glEnable(GL_FOG);
  glDisable(GL_CULL_FACE);
  glEnable(GL_ALPHA_TEST);
  glAlphaFunc(GL_GREATER, 0);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  sinOff := 0;
  for hairID:=0 to 2 do begin
    glPushMatrix;
      glTranslatef(EBDPos[0], 2.0, EBDPos[1]);
      case hairID of
        0: begin
          glTranslatef(-0.2, 0, -0.2);
          glBindTexture(GL_TEXTURE_2D, TexEBD[0]);
        end;
        1: begin
          glTranslatef(0.2, 0, -0.2);
          glBindTexture(GL_TEXTURE_2D, TexEBD[1]);
        end;
        2: begin
          glTranslatef(0, 0, 0.2);
          glBindTexture(GL_TEXTURE_2D, TexEBD[2]);
        end;
      end;
      glScalef(1.0, 1.2, 1.0);
      glRotatef(180.0, 1.0, 0, 0);
      animSin := -GetDirection(EBDPos[0], EBDPos[1], camPosN[0], camPosN[1]);
      glRotatef(animSin * R2D, 0, 1.0, 0);

      yPos := 0;
      zPos := 0;
      xNeg := -0.2;
      xPos := 0.2;
      glBegin(GL_QUADS);
      for i:=0 to 3 do begin
        glTexCoord2f(0, yPos);
        glVertex3f(xNeg, yPos, zPos);
        glTexCoord2f(1.0, yPos);
        glVertex3f(xPos, yPos, zPos);

        sinOff := sinOff + 0.33;

        yPos := yPos + 0.25;

        zPos := yPos / (dist + 1.0);

        animSin := Sin(sinOff + EBDAnim) * 0.2 * yPos;
        xNeg := animSin - 0.2;
        xPos := animSin + 0.2;

        glTexCoord2f(1.0, yPos);
        glVertex3f(xPos, yPos, zPos);
        glTexCoord2f(0, yPos);
        glVertex3f(xNeg, yPos, zPos);
      end;
      glEnd;
    glPopMatrix;
  end;
  glDisable(GL_BLEND);
  glEnable(GL_LIGHTING);
  glEnable(GL_CULL_FACE);
  glEnable(GL_FOG);
  glDisable(GL_ALPHA_TEST);
  glAlphaFunc(GL_ALWAYS, 0);
end;

{ Draw the exit door and operate it (behavior depends on the checkpoint) }
procedure TFMain.DrawExitDoor(const PosX, PosY: Single);
begin
  glCallList(6);
  glBindTexture(GL_TEXTURE_2D, TexDoor);
  if (MazeLocked <> 0) then
    glCallList(33)
  else
    glCallList(5);
  if (MazeLocked = 1) then
    glCallList(34);

  glPushMatrix;
    glTranslatef(flDoor, 0, 0);
    glRotatef(MazeDoor, 0, 1.0, 0);
    glCallList(4);
  glPopMatrix;

  if ((Checkpoint <> 0) and (MazeLocked <> 1)) then begin
    case Checkpoint of
      1: if ((playerState = 0) and (MazeLocked <> 1)) then begin
        if (InRange(camPosN[0], camPosN[1], PosX, PosX + 2.0, PosY - 2.0, PosY)) then begin
          alSource3f(SndCheckpoint, AL_POSITION, PosX, 0, PosY);
          alSourcePlay(SndCheckpoint);
          alSourceStop(SndAmb);
          if (MazeLevel <> 63) then
            Motrya := 1;
          MotryaPos[0] := PosX + 1.0;
          MotryaPos[1] := PosY + 5.0;
          Checkpoint := 2;
          CheckpointDoor := 0;
          CheckpointPos[0] := PosX;
          CheckpointPos[1] := PosY;
          MazeDoorPos[0] := -MotryaPos[0];
          MazeDoorPos[1] := -MotryaPos[1];
        end;
      end;
      2: begin
        Lerp(@MazeDoor, -98.0, delta2);

        alSource3f(SndDoorClose, AL_POSITION, PosX + 1.0, 0, PosY);
        if (DistanceToSqr(camPosN[0], camPosN[1], PosX + 1.0, PosY + 1.0) < 0.5) then begin
          alSourcePlay(SndDoorClose);
          if (Motrya <> 0) then
            ShowSubtitles(CCSave);
          Checkpoint := 3;
          playerState := 19;

          if (MazeLevel = 63) then begin
            FreeMaze;
            EBD := 0;
            Compass := 0;
            Map := 0;
            MazeGlyphs := 0;
            MazeTeleport := 0;
            MazeTram := 0;
            MazeDoor := 0;
            hbd := 0;
            kubale := 0;
            Shop := 0;
            Shn := 0;
            virdya := 0;
            Vebra := 0;
            wmblyk := 0;
            WB := 0;
            WBBK := 0;
            MazeHostile := 5;
            alSourceStop(SndAlarm);  
            alSourceStop(SndDrip);
            alSourceStop(SndEBD);
            alSourceStop(SndEBDA);
            alSourceStop(SndHbd);
            alSourceStop(SndKubale);
            alSourceStop(SndKubaleV);
            alSourceStop(SndTram);
            alSourceStop(SndTramAnn[0]);   
            alSourceStop(SndTramAnn[1]);
            alSourceStop(SndTramAnn[2]);  
            alSourceStop(SndWhisper);
            alSourceStop(SndWmblykB);
            fade := 0;
          end;
        end;
      end;
      else begin
        Lerp(@MazeDoor, 0, delta2);
        CollidePlayerWall(PosX, PosY, False);
      end;
    end;
  end else begin
    CollidePlayerWall(PosX, PosY, False);
    DrawFloorRoofEnd;

    if ((playerState = 0) and (MazeLocked <> 1)) then
      if (InRange(camPosN[0], camPosN[1], PosX, PosX + 2.0, PosY - 2.0, PosY)) then begin
        alSourcePlay(SndExit);
        playerState := 3;
      end;
  end;
end;

{ Draw maze floor and ceiling }
procedure TFMain.DrawFloorRoof(const List: GLUInt);
begin
  glBindTexture(GL_TEXTURE_2D, CurrentFloor);
  glCallList(List);

  if (Trench <> 0) then Exit;
  glPushMatrix;
    glTranslatef(0, 2.0, 2.0);
    glRotatef(180.0, 1.0, 0, 0);
    glBindTexture(GL_TEXTURE_2D, CurrentRoof);
    glCallList(List);
  glPopMatrix;
end;

{ Draw the end floor and ceiling, what is visible when the end door opens }
procedure TFMain.DrawFloorRoofEnd;
begin
  glBindTexture(GL_TEXTURE_2D, CurrentFloor);
  glCallList(27);

  glPushMatrix;
    glTranslatef(0, 0.01, 0);
    glEnable(GL_BLEND);
    glDisable(GL_LIGHTING);
    glDisable(GL_FOG);
      glBlendFunc(GL_ZERO, GL_SRC_COLOR);
      glBindTexture(GL_TEXTURE_2D, TexDoorblur);
      glCallList(27);

      glTranslatef(0, -0.02, 0);
      glCallList(27);
    glDisable(GL_BLEND);
    glEnable(GL_LIGHTING);
    glEnable(GL_FOG);
  glPopMatrix;
end;

{ Draw placed glyphs }
procedure TFMain.DrawGlyphs;
var
  i: Byte;
begin
  glDisable(GL_LIGHTING);
  glDisable(GL_FOG);
  glEnable(GL_BLEND);
  glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ONE_MINUS_SRC_COLOR);
  for i:=0 to GlyphsInLayer-1 do begin
    glPushMatrix;
      glTranslatef(GlyphPos[i+i], 0.01, GlyphPos[i+i+1]);
      glRotatef(GlyphRot[i], 0, 1.0, 0);
      glTranslatef(-0.2, 0, -0.5);
      glRotatef(90.0, 1.0, 0, 0);
      glScalef(0.4, 0.9, 0.9);
      glBindTexture(GL_TEXTURE_2D, TexGlyph[GlyphOffset + i]);
      glCallList(3);
    glPopMatrix;
  end;
  glEnable(GL_LIGHTING);
  glEnable(GL_FOG);
  glDisable(GL_BLEND);
end;

{ Huenbergondel }
procedure TFMain.DrawHbd;
var
  Dist: Single;
  PosOff: LongWord;
  MZC: Boolean;
begin
  hbdTimer := hbdTimer - deltaTime;

  if (hbdTimer < 0.0) then begin
    case hbd of
      1: begin
        alSourcePlay(SndHbdO);
        alSource3f(SndHbdO, AL_POSITION, hbdPosF[0], 0, hbdPosF[1]);
        hbdMdl := 55;
        hbdRot := Random(4);
        if ((hbdRot = 0) or (hbdRot = 1)) then
          PosOff := GetOffset(hbdPos[0], hbdPos[1])
        else if (hbdRot = 2) then
          PosOff := GetOffset(hbdPos[0], hbdPos[1] + 1)
        else
          PosOff := GetOffset(hbdPos[0] + 1, hbdPos[1]);

        if ((hbdRot = 0) or (hbdRot = 8)) then
          MZC := (Maze[PosOff] and MZC_PASSTOP) <> 0
        else
          MZC := (Maze[PosOff] and MZC_PASSLEFT) <> 0;

        if (MazeCrevice <> 0) then
          if (PosOff = GetOffset(MazeCrevicePos[0], MazeCrevicePos[1])) then
            MZC := False;

        if (MZC) then begin
          hbdTimer := 1.0;
          Inc(hbd);
        end;
      end;
      2: begin
        alSourcePlay(SndHbd);
        case hbdRot of
          0: Dec(hbdPos[1]);
          1: Dec(hbdPos[0]);
          2: Inc(HbdPos[1]);
          3: Inc(HbdPos[0]);
        end;
        hbdTimer := 1.0;
        Inc(hbd);
      end;
      3: begin
        alSourceStop(SndHbd);
        hbdTimer := 0.5;
        Inc(hbd);
      end;
      else begin
        hbdMdl := 56;
        hbdTimer := 4.0;
        hbd := 1;
      end;
    end;
  end;

  Dist := DistanceToSqr(hbdPosF[0], hbdPosF[1], camPosNext[0], camPosNext[2]);
  if (Dist < 1.0)
  then begin { Chocar con jugador }
    if (hbd = 3) then begin
      if ((Dist < 0.9) and (playerState = 0)) then begin
        alSourcePlay(SndImpact);
        playerState := 9;
        fadeState := 2;
      end;
      if (playerState = 9) then
        Lerp(@camPos[1], -0.1, delta2);
    end;
    camCurSpeed[0] := -camCurSpeed[0];
    camCurSpeed[2] := -camCurSpeed[2];
  end;

  glPushMatrix; { Draw }
    if (hbd <> 1) then begin
      if (hbd = 3) then
        alSource3f(SndHbd, AL_POSITION, hbdPosF[0], 0, hbdPosF[1]);

      MoveTowards(@hbdPosF[0], hbdPos[0] * 2.0 + 1.0, delta2);
      MoveTowards(@hbdPosF[1], hbdPos[1] * 2.0 + 1.0, delta2);

      MoveTowards(@hbdRotF, rotations[hbdRot], delta20);
    end;

    glTranslatef(hbdPosF[0], 0, hbdPosF[1]);
    glRotatef(hbdRotF * R2D, 0, 1.0, 0);
    glBindTexture(GL_TEXTURE_2D, TexHbd);
    glCallList(hbdMdl);
  glPopMatrix;
end;

{ Draw Kubale }
procedure TFMain.DrawKubale;
begin
  glPushMatrix;
    glTranslatef(kubalePos[0], 0, kubalePos[1]);
    glRotatef(kubaleDir, 0, 1.0, 0);
    glBindTexture(GL_TEXTURE_2D, TexKubale);
    glCallList(kubale);
  glPopMatrix;
end;

{ Draw map layout }
procedure TFMain.DrawMap;
var
  i, x, y: LongWord;
begin
  glPushMatrix;
    glTranslatef(CompassMapPos[0], 0.505, CompassMapPos[1]);

    glTranslatef(0, camCrouch * -0.2, 0);

    glRotatef(camRot[1] * R2D, 0, 1.0, 0);
    glRotatef(90.0, 1.0, 0, 0);
    glTranslatef(MapOffset[0], MapOffset[1], 0);
    glScalef(0.6, 0.6, 1.0);
    glBindTexture(GL_TEXTURE_2D, 0);
    glColor4fv(@mclBlack);

    glScalef(MapSize, MapSize, 1.0);
    glPushMatrix;
      for i:=0 to MapBRID-1 do begin
        GetPosition(i, @x, @y);

        if (i <> 0) then begin
          glTranslatef(1.0, 0, 0);
          if (x = 0) then begin
            glPopMatrix;
            glTranslatef(0, 1.0, 0);
            glPushMatrix;
          end;
        end;

        if (y <> MazeHM1) then begin
          if (not GetCellMZC(x, y, MZC_PASSLEFT)) then begin
            glPushMatrix;
              glScalef(0.1, 1.0, 1.0);
              glCallList(3);
            glPopMatrix;
          end;
        end;

        if (x <> MazeWM1) then begin
          if (not GetCellMZC(x, y, MZC_PASSTOP)) then begin
            glPushMatrix;
              glScalef(1.0, 0.1, 1.0);
              glCallList(3);
            glPopMatrix;
          end;
        end;
      end;
    glPopMatrix;

    glTranslatef(0, -MazeHM1, 0);

    glTranslatef(CompassMapPos[0] * 0.5, CompassMapPos[1] * 0.5, 0);
    glScalef(0.2, 0.2, 1.0);
    glCallList(3);
  glPopMatrix;
end;

{ Draw maze with culling }
procedure TFMain.DrawMaze;
var
  xFrom, yFrom, xTo, yTo, xPos, yPos, i: LongWord;
  PassTop, PassLeft: Boolean;
  MazeX, MazeY, MazeX1, MazeY1: Single;
  MazeXI, MazeYI: LongWord;
  Misc: Byte;
  Rotate: Boolean;
begin
  xPos := Round(camPosN[0] * 0.5);     
  yPos := Round(camPosN[1] * 0.5);

  yFrom := (yPos - MazeDrawCull) * MazeW;
  if (yFrom > 2147483647) then yFrom := 0; { < 0 }

  xFrom := (xPos - MazeDrawCull);
  if (xFrom > 2147483647) then xFrom := 0; { < 0 }
  yFrom := yFrom + xFrom;

  xTo := xPos + MazeDrawCull;
  if (xTo > MazeWM1) then xTo := MazeWM1;

  yTo := (MazeDrawCull + MazeDrawCull) * MazeW + yFrom;
  if (yTo > MazeSizeM1) then yTo := MazeSizeM1;

  i := yFrom;
  while (i < yTo) do begin { Cull start index to cull end index }
    { Get cell }
    PassTop := Maze[i] and MZC_PASSTOP <> 0;
    PassLeft := Maze[i] and MZC_PASSLEFT <> 0;

    GetPosition(i, @MazeXI, @MazeYI);
    if (MazeXI >= xTo) then begin
      i := MazeW - xTo + xFrom + i;
      Continue;
    end;

    MazeX := MazeXI * 2.0;
    MazeY := MazeYI * 2.0;

    if (MazeTram <> 0) then
      if ((MazeXI >= MazeTramArea[0]) and (MazeXI <= MazeTramArea[1])) then begin
        if ((MazeXI = MazeTramArea[0]) or (MazeXI = MazeTramArea[1])) then begin
          glPushMatrix;
            glTranslatef(MazeX, 0, MazeY);
            glBindTexture(GL_TEXTURE_2D, TexMetal);
            if (MazeYI = 0) then begin
              if (MazeXI = MazeTramArea[0]) then begin
                glRotatef(-90.0, 0, 1.0, 0);
                glTranslatef(0, 0, -2.0);
                glCallList(104);
              end else begin
                glRotatef(180.0, 0, 1.0, 0);
                glTranslatef(-2.0, 0, -2.0);
                glCallList(104);
              end;
            end else if (MazeYI = MazeHM1 - 1) then begin
              if (MazeXI = MazeTramArea[0]) then
                glCallList(104)
              else begin
                glRotatef(90.0, 0, 1.0, 0);
                glTranslatef(-2.0, 0, 0);
                glCallList(104);
              end;
            end else
              glCallList(103);
          glPopMatrix;
        end else begin
          if ((MazeYI = 0) or (MazeYI = MazeHM1 - 1)) then begin
            glPushMatrix;
              glTranslatef(MazeX, 0, MazeY);
              glRotatef(90.0, 0, 1.0, 0);
              glTranslatef(-2.0, 0, 0);
              glBindTexture(GL_TEXTURE_2D, TexMetal);
              glCallList(103);
            glPopMatrix;
          end;
        end;
        Inc(i);
        Continue;
      end;

    glPushMatrix;
    glTranslatef(MazeX, 0, MazeY);
    { Draw walls }
    glBindTexture(GL_TEXTURE_2D, CurrentWall);
    if (MazeCrevice <> 0) then begin
      if ((MazeXI = MazeCrevicePos[0]) and (MazeYI = MazeCrevicePos[1])) then begin
        glCallList(106);
        MazeX1 := MazeX + 2.0;
        MazeY1 := MazeY + 2.0;
        if (camCrouch < 1.0) then begin
          CollidePlayerWall(MazeX, MazeY, False);
          CollidePlayerWall(MazeX, MazeY1, False);
          CollidePlayerWall(MazeX, MazeY, True);
          CollidePlayerWall(MazeX1, MazeY, True);
        end else begin
          if (InRange(camPosN[0], camPosN[1], MazeX - flWTh, MazeX1 + flWTh,
          MazeY - flWTh, MazeY1 + flWTh)) then
            MazeCrevice := 2
          else
            MazeCrevice := 1;
        end;
      end;
    end;
    if (i = 0) then begin { Enter door }
      glBindTexture(GL_TEXTURE_2D, TexDoor);
      glCallList(5);
      glTranslatef(flDoor, 0, 0);

      case doorSlam of
        1: if (playerState = 0) then
             if ((camPosN[0] > 6.0) or (camPosN[1] > 6.0)) then begin
               doorSlam := 2;
               doorSlamRot := 0;
             end;
        2: begin
          Lerp(@doorSlamRot, -24.0, delta2);
          if (DistanceToSqr(1.0, 0.0, camPosN[0], camPosN[1]) < 4.0) then begin
            alSourcePlay(SndSlam);
            AlertWB(3);
            doorSlam := 3;
          end;
        end;
        3: begin
          MoveTowards(@doorSlamRot, 0, delta20 * 10.0);
          if (doorSlamRot = 0) then
            doorSlam := 0;
        end;
      end;

      if (doorSlam > 1) then begin
        glPushMatrix;
        glRotatef(doorSlamRot, 0, 1.0, 0);
        glCallList(4);
        glPopMatrix;
      end else
        glCallList(4);
      glTranslatef(-0.65, 0, 0);
      glBindTexture(GL_TEXTURE_2D, CurrentWall);
      DrawWall(6, 0, 0, False);
    end else if (not PassTop) then begin
      Misc := 0;
      if (Trench <> 0) then begin
        Inc(Misc);
        if ((Maze[i] and MZC_ROTATED) = 0) then begin
          Inc(Misc);
          if ((Maze[i] and MZC_PIPE) <> 0) then
            Inc(Misc);
        end;
      end;
      if (Misc = 3) then begin
        glBindTexture(GL_TEXTURE_2D, TexPlanks);
        DrawWall(1, MazeX, MazeY, False);
        glBindTexture(GL_TEXTURE_2D, CurrentWall);
      end else
        DrawWall(CurrentWallMDL, MazeX, MazeY, False);
    end;
    if (not PassLeft) then begin
      Misc := 0;
      glRotatef(-90.0, 0, 1.0, 0);

      if (Trench <> 0) then begin
        Inc(Misc);
        if ((Maze[i] and MZC_ROTATED) <> 0) then begin
          Inc(Misc);
          if ((Maze[i] and MZC_PIPE) <> 0) then
            Inc(Misc);
        end;
      end;
      if (Misc = 3) then begin
        glBindTexture(GL_TEXTURE_2D, TexPlanks);
        DrawWall(1, MazeX, MazeY, True);
      end else if ((i = 0) and (Shop <> 0)) then begin
        DrawWall(76, MazeX, MazeY, True);
        DrawFloorRoof(2);
        glBindTexture(GL_TEXTURE_2D, TexSigns1);
        glCallList(77);
        if (ShopKoluplyk < 84) then begin
          glBindTexture(GL_TEXTURE_2D, TexKoluplyk);
          glCallList(ShopKoluplyk);
          ShopTimer := ShopTimer - deltaTime;
        end;

        if ((Shop = 1) or (Shop = 2)) then begin { Shop }
          if (camPosN[0] < 2.0) and (camPosN[1] < 2.0) then begin
            if (ccTimer < 0.0) then begin
              //JOYSTICK USED
              ccText := CCShop;
              ccTimer := 0.1;
            end;     
            Shop := 2;
          end else
            Shop := 1;

          if (ShopTimer < 0.0) then begin
            if (ShopKoluplyk = 78) then
              Inc(ShopKoluplyk)
            else
              Dec(ShopKoluplyk);
            ShopTimer := 1.0;
          end;
        end else if (Shop = 3) then begin
          MoveTowards(@ShopWall, 0, delta2);
          glPushMatrix;
          glTranslatef(0, 0, ShopWall);
          glBindTexture(GL_TEXTURE_2D, CurrentWall);
          glCallList(CurrentWallMDL);
          glPopMatrix;
          Shake(0.01);
          alSource3f(SndHbd, AL_POSITION, -ShopWall, 0, 1.0);
          if (ShopWall = 0) then begin
            alSourceStop(SndHbd);
            Shop := 0;
          end;

          if (ShopTimer < 0.0) then begin
            Inc(ShopKoluplyk);
            ShopTimer := 0.1;
          end;
        end;
      end else begin
        Misc := 0;
        if ((MazeTram <> 0) and (MazeTramArea[1] + 1 = MazeXI)) then
          Inc(Misc);
        if (Misc = 0) then
          DrawWall(CurrentWallMDL, MazeX, MazeY, True);
      end;
      glRotatef(90.0, 0, 1.0, 0);
    end;

    Misc := 0;
    if (MazeTram <> 0) then
      if ((MazeXI = MazeTramArea[0] - 1) or (MazeXI = MazeTramArea[1] + 1)) then
        Inc(Misc);

    if (Misc <> 0) then begin
      glBindTexture(GL_TEXTURE_2D, CurrentFloor);
      glCallList(2);
    end else
      DrawFloorRoof(2);

    { Miscellaneous }
    if (Trench <> 0) then begin
      if ((Maze[i] and MZC_LAMP) <> 0) then begin
        glBindTexture(GL_TEXTURE_2D, TexPlanks);
        glCallList(51);
      end;
    end else begin
      Rotate := (Maze[i] and MZC_ROTATED) <> 0;
      if (Rotate) then
        glRotatef(-90.0, 0, 1.0, 0);

      if ((Maze[i] and MZC_LAMP) <> 0) then begin
        glBindTexture(GL_TEXTURE_2D, TexLamp);
        glCallList(7);
      end;

      if ((Maze[i] and MZC_PIPE) <> 0) then begin
        glBindTexture(GL_TEXTURE_2D, TexPipe);
        glCallList(28);
      end;

      if ((Maze[i] and MZC_WIRES) <> 0) then begin
        glBindTexture(GL_TEXTURE_2D, TexLamp);
        glCallList(37);
      end;

      if ((Maze[i] and MZC_TABURETKA) <> 0) then begin
        glBindTexture(GL_TEXTURE_2D, TexTaburetka);
        glCallList(49);
      end;

      if (Rotate) then
        glRotatef(90.0, 0, 1.0, 0);
    end;

    { Draw border walls }
    if (MazeXI = MazeWM1 - 1) then begin
      glPushMatrix;
        glTranslatef(2.0, 0, 0);
        glRotatef(-90.0, 0, 1.0, 0);
        glBindTexture(GL_TEXTURE_2D, CurrentWall);
        DrawWall(CurrentWallMDL, MazeX + 2.0, MazeY, True);
      glPopMatrix;
    end;
    if (MazeYI = MazeHM1 - 1) then begin
      glTranslatef(0, 0, 2.0);
      glBindTexture(GL_TEXTURE_2D, CurrentWall);
      if (MazeXI = MazeWM1 - 1) then { Exit door }
        DrawExitDoor(MazeX, MazeY + 2.0)
      else
        DrawWall(CurrentWallMDL, MazeX, MazeY + 2.0, False);
    end;
    glPopMatrix;

    Inc(i);
  end;
end;

{ Draw items in the maze like the key, glyphs etc }
procedure TFMain.DrawMazeItems;
var
  rotVal: Single;
begin
  if (MazeLocked = 1) then begin { Key }
    if (Random(100) = 0) then
      MazeKeyRot[1] := Random(360);
    Lerp(@MazeKeyRot[0], MazeKeyRot[1], deltaTime * 0.1);
    glPushMatrix;
      glEnable(GL_LIGHTING);
      glEnable(GL_FOG);
      glEnable(GL_BLEND);
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
      glBindTexture(GL_TEXTURE_2D, TexKey);
      glTranslatef(MazeKeyPos[0], 0, MazeKeyPos[1]);
      glRotatef(MazeKeyRot[0], 0, 1.0, 0);
      glCallList(35);
      glDisable(GL_BLEND);
    glPopMatrix;
    if (DistanceToSqr(camPosN[0], camPosN[1], MazeKeyPos[0], MazeKeyPos[1])
    < 1.0) then begin
      MazeLocked := 2;
      ShowSubtitles(CCKey);
      alSource3f(SndKey, AL_POSITION, MazeKeyPos[0], 1.0, MazeKeyPos[1]);
      alSourcePlay(SndKey);
      AlertWB(2);
    end;
  end;

  if (Compass = 1) then begin { Compass }
    glPushMatrix;
      glEnable(GL_LIGHTING);
      glEnable(GL_FOG);
      glBindTexture(GL_TEXTURE_2D, TexCompassWorld);
      glTranslatef(CompassPos[0], 0, CompassPos[1]);
      glCallList(38);
    glPopMatrix;
    if (DistanceToSqr(camPosN[0], camPosN[1], CompassPos[0], CompassPos[1])
    < 1.0) then begin
      Compass := 2;
      ShowSubtitles(CCCompass);
      alSourcePlay(SndMistake);
    end;
  end;
  if (((Compass = 2) or (Map <> 0)) and (playerState = 0)) then begin
    Lerp(@CompassMapPos[0], camPosN[0], delta20);
    Lerp(@CompassMapPos[1], camPosN[1], delta20);
    if (camRot[0] > 0.4) then begin
      glPushMatrix;
        glDisable(GL_LIGHTING);
        glDisable(GL_FOG);
        glDisable(GL_DEPTH_TEST);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glTranslatef(CompassMapPos[0], 0.5, CompassMapPos[1]);

        glTranslatef(0, camCrouch * (-0.2), 0);

        glRotatef(camRot[1] * R2D, 0, 1.0, 0);
        glRotatef(90.0, 1.0, 0, 0);
        if (Map <> 0) then begin
          glBindTexture(GL_TEXTURE_2D, TexMap);
          glTranslatef(-0.33, -0.33, 0);
          glScalef(0.66, 0.66, 1.0);
        end else begin
          glBindTexture(GL_TEXTURE_2D, TexCompass);
          glTranslatef(-0.166, -0.166, 0);
          glScalef(0.33, 0.33, 1.0);
        end;
        glCallList(3);
      glPopMatrix;
      if (Compass = 2) then begin
        glPushMatrix;
          glTranslatef(CompassMapPos[0], 0.51, CompassMapPos[1]);

          glTranslatef(0, camCrouch * (-0.2), 0);

          if (MazeLocked = 1) then
            rotVal := GetDirection(MazeKeyPos[0], MazeKeyPos[1],
              camPosN[0], camPosN[1])
          else
            rotVal := GetDirection(camPos[0], camPos[2],
              MazeDoorPos[0], MazeDoorPos[1]);
          rotVal := camRot[1] - rotVal;
          Angleify(@rotVal);
          Angleify(@CompassRot);
          LerpAngle(@CompassRot, rotVal, delta2);
          glRotatef((camRot[1] - CompassRot) * R2D, 0, 1.0, 0);
          if (Map <> 0) then
            glColor4f(1.0, 1.0, 1.0, 0.5);
          glBindTexture(GL_TEXTURE_2D, TexCompassWorld);
          glCallList(39);
        glPopMatrix;
      end;
      glDisable(GL_BLEND);
      if (Map <> 0) then { Map }
        DrawMap;
      glEnable(GL_DEPTH_TEST);
      glEnable(GL_LIGHTING);
    end;
  end;

  glColor4fv(@mclWhite);
  if (MazeGlyphs <> 0) then begin { Glyphs }
    MazeGlyphsRot := MazeGlyphsRot + deltaTime;
    rotVal := Sin(MazeGlyphsRot) * 0.2;

    Angleify(@MazeGlyphsRot);

    glPushMatrix;
      glDisable(GL_LIGHTING);
      glEnable(GL_FOG);
      glBindTexture(GL_TEXTURE_2D, TexGlyphs);
      glTranslatef(MazeGlyphsPos[0], rotVal, MazeGlyphsPos[1]);
      glRotatef(MazeGlyphsRot * R2D, 0, 1.0, 0);
      glCallList(36);
    glPopMatrix;
    glEnable(GL_LIGHTING);
    if (DistanceToSqr(camPosN[0], camPosN[1], MazeGlyphsPos[0], MazeGlyphsPos[1])
    < 1.0) then begin
      MazeGlyphs := 0;
      ShowSubtitles(CCGlyphRestore);
      alSourcePlay(SndMistake);
      Glyphs := 7;
      GlyphOffset := 0;
      GlyphsInLayer:= 0;
      virdyaState := 0;
      fade := 0;
      vignetteRed := 0;
    end;
  end;

  if ((MazeNote <> 0) and (MazeNote < 16)) then begin { Notes }
    glDisable(GL_LIGHTING);
    glEnable(GL_FOG);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glPushMatrix;
      glBindTexture(GL_TEXTURE_2D, TexPaper);
      glTranslatef(MazeNotePos[0], 0.01, MazeNotePos[1]);
      glRotatef(MagnitudeSqr(MazeNotePos[0], MazeNotePos[1]) * R2D, 0, 1.0, 0);
      glRotatef(90.0, 1.0, 0, 0);

      glTranslatef(-0.166, -0.166, 0);
      glScalef(0.33, 0.33, 1.0);
      glCallList(3);
    glPopMatrix;
    glEnable(GL_LIGHTING);

    if ((DistanceToSqr(camPosN[0], camPosN[1], MazeNotePos[0], MazeNotePos[1])
    < 0.6) and (playerState = 0)) then begin
      MazeNote := MazeNote + 16;
      canControl := False;
      camCurSpeed[0] := 0;
      camCurSpeed[2] := 0;
    end;
  end;

  if (MazeTeleport <> 0) then begin
    MazeTeleportRot := MazeTeleportRot + delta20;

    if (MazeTeleportRot > 360.0) then
      MazeTeleportRot := MazeTeleportRot - 360.0;

    glDisable(GL_LIGHTING);
    glEnable(GL_FOG);
    glDisable(GL_BLEND);
    glBindTexture(GL_TEXTURE_2D, 0);
    glEnable(GL_LIGHTING);

    DrawTeleporter(True);
    DrawTeleporter(False);
  end;
end;

{ Draw Motrya that saves the game (checkpoint) }
procedure TFMain.DrawMotrya;
var
  playing: ALInt = 0;
begin
  if (Motrya = 2) then begin
    Lerp(@MotryaTimer, -0.1, delta2);
    if (MotryaTimer < 0.0) then begin
      Motrya := 3;
      MotryaTimer := 2.0;
    end;
    Exit;
  end else if (Motrya = 3) then begin
    MotryaTimer := MotryaTimer - deltaTime;
    if (MotryaTimer < 0.0) then begin
      Motrya := 0;
      alGetSourcei(SndMus3, AL_SOURCE_STATE, playing);
      if (playing <> AL_PLAYING) then begin
        CheckpointMus := 0;
        alSourcef(SndMus3, AL_GAIN, 0);
        alSourcePlay(SndMus3);
      end;
    end;
    Exit;
  end;

  if (Motrya = 1) then begin
    if (DistanceToSqr(camPosN[0], camPosN[1], MotryaPos[0], MotryaPos[1]) < 6.0) then begin
      Motrya := 88;
      Save := 1;
      SavePos[0] := MotryaPos[0];
      SavePos[1] := MotryaPos[1];
      SavePos[2] := SavePos[1] - 4.7;
      SaveSize := 0;
      alSourcePlay(SndSave);
    end;
  end else begin
    Shake(SaveSize);

    MotryaTimer := MotryaTimer - deltaTime;

    if (MotryaTimer < 0.0) then begin
      Inc(Motrya);
      MotryaTimer := 0.1;
      if (Motrya = 92) then begin
        SaveGame;
        Motrya := 2;
        ShowSubtitles(CCSaved);
        MotryaTimer := 1.0;
      end;
    end;
  end;

  glPushMatrix;
    glTranslatef(MotryaPos[0], 0, MotryaPos[1]);
    glBindTexture(GL_TEXTURE_2D, TexMotrya);
    if (Motrya = 1) then
      glCallList(88)
    else
      glCallList(Motrya);
  glPopMatrix;
end;

{ Draw UI noise, made a PROC for intro rain }
procedure TFMain.DrawNoise(const Texture: GLUInt);
var
  noiseX, noiseY, i, j: LongWord;
begin
  glLoadIdentity;
  glBindTexture(GL_TEXTURE_2D, Texture);

  glTranslatef(-Random(512), -Random(512), 0);

  glScalef(512.0, 512.0, 0);

  noiseX := Width div 512 + 2;
  noiseY := Height div 512 + 2;

  for i:=0 to noiseY-1 do begin
    glPushMatrix;
    for j:=0 to noiseX-1 do begin
      glCallList(3);
      glTranslatef(1.0, 0, 0);
    end;
    glPopMatrix;
    glTranslatef(0, 1.0, 0);
  end;
end;

{ Draw the light flare that represents the save (checkpoint) }
procedure TFMain.DrawSave;
var
  lightColor: Single;
begin
  Lerp(@SaveSize, 1.0, deltaTime);
  Lerp(@SavePos[1], SavePos[2], deltaTime);

  if (DistanceToSqr(camPosN[0], camPosN[1], SavePos[0], SavePos[2]) < 2.0) then
  begin
    Save := 2;
    if (ccTimer < 0.0) then begin
      //JOYSTICK USED
      ccText := CCSaveErase;
      ccTimer := 0.1;
    end;
  end else if (Save = 2) then
    Save := 1;

  glPushMatrix;
    glTranslatef(SavePos[0], 1.0, SavePos[1]);
    glRotatef(GetDirection(SavePos[0], SavePos[1], camPosN[0], camPosN[1])
      * R2D, 0, 1.0, 0);
    glScalef(SaveSize, SaveSize, SaveSize);

    RandomFloat(@lightColor, 1);
    lightColor := (lightColor * 0.1 + 0.9) * SaveSize;

    glDisable(GL_DEPTH_TEST);
    glDisable(GL_LIGHTING);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE);
    glBindTexture(GL_TEXTURE_2D, TexLight);
    glColor3f(lightColor, lightColor, lightColor);
    glCallList(84);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_LIGHTING);
    glDisable(GL_BLEND);
    glColor3fv(@mclWhite);
  glPopMatrix;
end;

{ Draw teleporter to eliminate spaghetti }
procedure TFMain.DrawTeleporter(const First: Boolean);
var
  PosX, PosY: Single;
begin
  glPushMatrix;
    if (First) then begin
      PosX := MazeTeleportPos[0];
      PosY := MazeTeleportPos[1];
    end else begin
      PosX := MazeTeleportPos[2];
      PosY := MazeTeleportPos[3];
    end;

    glTranslatef(PosX, 0, PosY);
    glRotatef(MazeTeleportRot, 0, 1.0, 0);
    glCallList(47);
    glRotatef(-MazeTeleportRot - MazeTeleportRot, 0, 1.0 ,0);
    glCallList(48);

    if (DistanceToSqr(camPosN[0], camPosN[1], PosX, PosY) < 0.2) then begin
      canControl := False;
      playerState := 18;
      fadeState := 2;
      Lerp(@camPosN[0], PosX, deltaTime);
      camPos[0] := -camPosN[0];
      Lerp(@camPosN[1], PosY, deltaTime);
      camPos[2] := -camPosN[1];
      camCurSpeed[0] := 0;
      camCurSpeed[2] := 0;

      if (fade > 1.0) then begin
        if ((Random(20) <> 0) or (PMSeed = 0) or (MazeLevel = 20) or
        (MazeLevel = 41) or (MazeLevel = 62)) then begin
          ShowSubtitles(CCTeleport);
          alSourcePlay(SndMistake);
          if (First) then begin
            Print('Teleported player with first teleporter.');
            camPos[0] := -MazeTeleportPos[2];
            camPosNext[0] := camPos[0];
            camPosL[0] := camPos[0];
            camPos[2] := -MazeTeleportPos[3];
            camPosNext[2] := camPos[2];
            camPosL[2] := camPos[2];
          end else begin
            Print('Teleported player with second teleporter.');
            camPos[0] := -MazeTeleportPos[0];
            camPosNext[0] := camPos[0];
            camPosL[0] := camPos[0];
            camPos[2] := -MazeTeleportPos[1];
            camPosNext[2] := camPos[2];
            camPosL[2] := camPos[2];
          end;
          fadeState := 1;
          MazeTeleport := 0;
          canControl := True;
          playerState := 0;
        end else begin
          ShowSubtitles(CCTeleportBad);
          alSourcePlay(SndDistress);
          Print('Teleported player badly.');
          FreeMaze;

          if (Random(2) <> 0) then begin
            MazeSeed := PMSeed;
            MazeW := PMW;
            MazeH := PMH;
            MazeLevel := MazeLevel - 2;
          end else
            MazeSeed := GetTickCount64;
          GenerateMaze(MazeSeed);
          GetRandomMazePosition(@camPosN[0], @camPosN[1]);
          camPos[0] := -camPosN[0];
          camPosNext[0] := camPos[0];   
          camPosL[0] := camPos[0];
          camPos[2] := -camPosN[1];
          camPosNext[2] := camPos[2];
          camPosL[2] := camPos[2]; 
          fadeState := 1;
          MazeTeleport := 0;
          canControl := True;
          playerState := 0;

          MazeLevelPopupTimer := 2.0;
          MazeLevelPopup := 1;
        end;
      end;
    end;
  glPopMatrix;
end;

{ Draw tram and operate it }
procedure TFMain.DrawTram;
var
  deltaVal: Single;
begin
  Angleify(@MazeTramRotS);
  MoveTowardsAngle(@MazeTramRotS, rotations[MazeTramRot], delta2);
  Angleify(@MazeTramRotS);

  deltaVal := MPIHalf - DistanceScalar(MazeTramRotS, rotations[MazeTramRot])
    * delta2;

  if (MazeTramPlr > 1) then begin
    camPos[0] := -MazeTramPos[0];
    camPos[2] := -MazeTramPos[1];
    camPos[1] := -1.6;

    camRot[1] := (rotations[MazeTramRot] - MazeTramRotS) * delta2 + camRot[1];

    Shake(MazeTramSpeed * 0.01);
    if (MazeTramPlr = 3) then begin
      //JOYSTICK USED
      ccText := CCTramExit;
      ccTimer := 0.1;
    end;
  end;

  alSourcef(SndTram, AL_PITCH, MazeTramSpeed);
  alSource3f(SndTram, AL_POSITION, MazeTramPos[0], 2.0, MazeTramPos[2]);
  alSource3f(SndTramAnn[MazeTramSnd], AL_POSITION,
    MazeTramPos[0], 1.0, MazeTramPos[2]);

  case MazeTram of
    1: begin
      MoveTowards(@MazeTramSpeed, 1.0, deltaTime * 0.5);

      if (DistanceScalar(MazeTramPos[2], MazeHM1) < 0.5) then
        MazeTram := 2;
    end;
    2: begin
      MoveTowards(@MazeTramSpeed, 0, deltaTime);
      if (MazeTramSpeed = 0) then begin
        MazeTeleportRot := 0.5;
        MazeTram := 3;
      end;
    end;
    3: begin
      if (MazeTramDoors < 102) then begin
        MazeTeleportRot := MazeTeleportRot - deltaTime;
        if (MazeTeleportRot < 0.0) then begin
          if (MazeTramDoors = 99) then begin
            alSource3f(SndTramOpen, AL_POSITION,
              MazeTramPos[0], 2.0, MazeTramPos[2]);
            alSourcePlay(SndTramOpen);
          end;
          MazeTeleportRot := 0.1;
          Inc(MazeTramDoors);
        end;
      end else begin
        MazeTram := 4;
        MazeTeleportRot := 4.0;
      end;
    end;
    4: begin
      if (MazeTramPlr < 2) then begin
        if (DistanceToSqr(MazeTramPos[0], MazeTramPos[2],
        camPosN[0], camPosN[1]) < 3.0) then begin
          MazeTramPlr := 1;
          if (ccTimer < 0.0) then begin
            //JOYSTICK USED
            ccText := CCTram;
            ccTimer := 0.1;
          end;
        end else
          MazeTramPlr := 0;
        if (wmblyk = 11) then
          if (DistanceToSqr(MazeTramPos[0], MazeTramPos[2],
          wmblykPos[0], wmblykPos[1]) < 5.0) then begin
            wmblyk := 0;
            WmblykTram := True;
            alSourceStop(SndWmblykB);
          end;
      end else if (MazeTramPlr = 2) then
        MazeTramPlr := 3;

      MazeTeleportRot := MazeTeleportRot - deltaTime;
      if (MazeTeleportRot < 0.0) then begin
        if (MazeTramPlr = 1) then
          MazeTramPlr := 0
        else if (MazeTramPlr = 3) then
          MazeTramPlr := 2;
        MazeTram := 5;
        MazeTeleportRot := 0.1;

        alSource3f(SndTramClose, AL_POSITION,
          MazeTramPos[0], 2.0, MazeTramPos[2]);
        alSourcePlay(SndTramClose);
      end;
    end;
    5: begin
      if (MazeTramDoors > 99) then begin
        MazeTeleportRot := MazeTeleportRot - deltaTime;
        if (MazeTeleportRot < 0.0) then begin
          MazeTeleportRot := 0.1;
          Dec(MazeTramDoors);
        end;
      end else
        MazeTram := 6;
    end;
    6: begin
      MoveTowards(@MazeTramSpeed, 1.0, deltaTime * 0.5);
      if (MazeTramSpeed = 1.0) then begin
        MazeTram := 1;
        case Random(8) of
          0: begin
            alSourcePlay(SndTramAnn[0]);
            MazeTramSnd := 0;
          end;
          1: begin       
            alSourcePlay(SndTramAnn[1]);
            MazeTramSnd := 1;
          end;      
          2: begin
            alSourcePlay(SndTramAnn[2]);
            MazeTramSnd := 2;
          end;
        end;
      end;
    end;
  end;

  if (camPosNext[0] > (MazeTramArea[0] * 2.0 - flWTh)) then
    if (camPosNext[0] < ((MazeTramArea[1] + 1.0) * 2.0 + flWTh)) then
      camCurSpeed[0] := 0;

  case MazeTramRot of
    0: begin
      if (DistanceScalar(MazeTramPos[2], 1.0) < 2.0) then
        MazeTramRot := 1;

      MoveTowards(@MazeTramPos[0], MazeTramArea[1] * 2.0 + 1.0, deltaVal);
    end;
    1: begin
      if (DistanceScalar(MazeTramPos[0], MazeTramArea[0] * 2.0 + 1.0) < 2.0)
        then MazeTramRot := 8;

      MoveTowards(@MazeTramPos[2], 1.0, deltaVal);
    end;
    2: begin
      if (DistanceScalar(MazeTramPos[2], (MazeHM1 - 1.0) * 2.0 + 1.0) < 2.0)
        then MazeTramRot := 3;

      MoveTowards(@MazeTramPos[0], MazeTramArea[0] * 2.0 + 1.0, deltaVal);
    end;
    3: begin
      if (DistanceScalar(MazeTramPos[0], MazeTramArea[1] * 2.0 + 1.0) < 2.0)
        then MazeTramRot := 0;

      MoveTowards(@MazeTramPos[2], (MazeHM1 - 1.0) * 2.0 + 1.0, deltaVal);
    end;
  end;

  MazeTramPos[0] := MazeTramPos[0] - Sin(MazeTramRotS)*deltaVal*MazeTramSpeed;
  MazeTramPos[2] := MazeTramPos[2] - Cos(MazeTramRotS)*deltaVal*MazeTramSpeed;

  glPushMatrix;
    glTranslatef(MazeTramPos[0], 0, MazeTramPos[2]);
    glRotatef(MazeTramRotS * R2D, 0, 1.0, 0);

    glBindTexture(GL_TEXTURE_2D, TexTram);
    glCallList(98);
    glCallList(MazeTramDoors);

    if (WmblykTram) then begin
      glDisable(GL_LIGHTING);
      glDisable(GL_FOG);
      glBindTexture(GL_TEXTURE_2D, TexWmblykNeutral);
      glCallList(105);
      glEnable(GL_LIGHTING);
      glEnable(GL_FOG);
    end;
  glPopMatrix;
end;

{ Draw  in the trench }
procedure TFMain.DrawVas;
var
  Dir: Single;
begin
  glPushMatrix;
    glTranslatef(vasPos[0], 0, vasPos[1]);

    Dir := GetDirection(vasPos[0], vasPos[1], camPosN[0], camPosN[1]);

    vasPos[0] := Sin(Dir) * deltaTime * (-0.7) + vasPos[0];    
    vasPos[1] := Cos(Dir) * deltaTime * (-0.7) + vasPos[1];

    glRotatef(Dir * R2D - 10.0 + Random(20), 0, 1.0, 0);

    Dir := DistanceToSqr(vasPos[0], vasPos[1], camPosN[0], camPosN[1]);
    if (Dir < 1.0) then begin
      fullscreen := not fullscreen;
      SetFullscreen(fullscreen);
    end;
    if (Dir < 0.5) then begin
      ErrorOut('OpenGL error occured.');
    end;

    glBindTexture(GL_TEXTURE_2D, TexVas);
    glCallList(Random(3) + 52);

    alSource3f(SndWmblykB, AL_POSITION, vasPos[0], 0, vasPos[1]);

    Dir := Clamp(Dir * 0.1, 0, 1.0);

    TrenchColor[0] := mclTrench[0] * Dir;  
    TrenchColor[1] := mclTrench[1] * Dir;   
    TrenchColor[2] := mclTrench[2] * Dir;
  glPopMatrix;
end;

{ Draw Vebra exiting the layer }
procedure TFMain.DrawVebra;
var
  PosX, PosY, Dist: Single;
begin
  Vebratimer := VebraTimer - deltaTime;

  PosX := -MazeDoorPos[0];
  PosY := -MazeDoorPos[1];

  if (VebraTimer < 0.0) then begin
    if (Vebra < 135) then begin
      VebraTimer := 1.0;
      Inc(Vebra);
      if (Vebra = 135) then
        Vebra := 133;
    end else begin
      VebraTimer := 0.1;
      Inc(Vebra);
      case Vebra of
        139: begin
          alSource3f(SndDoorClose, AL_POSITION, PosX, 0, PosY);
          alSourcePlay(SndDoorClose);
        end;
        140: VebraTimer := 0.33;
        141: begin
          Vebra := 0;
          MazeDoor := 0;
          Exit;
        end;
      end;
    end;
  end;

  if ((Vebra < 135) and (playerState <> 1) and (playerState <> 5)) then begin
    Dist := DistanceToSqr(camPos[0], camPos[2], MazeDoorPos[0], MazeDoorPos[1]);
    if (Dist < 32.0) then begin
      if (not CheckBlocked(camPosN[0], camPosN[1], PosX, PosY)) then begin
        Vebra := 135;
        VebraTimer := 0.1;
        Print('I''m outta here');
        alSource3f(SndCheckpoint, AL_POSITION, PosX, 0, PosY);
        alSourcePlay(SndCheckpoint);
      end;
      if (Dist < 13.0) then begin
        Vebra := 135;
        VebraTimer := 0.1;     
        Print('I''m outta here');
        alSource3f(SndCheckpoint, AL_POSITION, PosX, 0, PosY);
        alSourcePlay(SndCheckpoint);
      end;
    end;
  end else if ((Vebra >= 135) and (Vebra <= 138)) then
    Lerp(@MazeDoor, -100.0, delta2 * 2.0)
  else
    Lerp(@MazeDoor, 0, delta2 * 2.0);

  glPushMatrix;
    glTranslatef(PosX, 0, PosY);
    glBindTexture(GL_TEXTURE_2D, TexVebra);
    glCallList(Vebra);
    glColor3fv(@mclWhite);
  glPopMatrix;
end;

{ Draw Virdya }
procedure TFMain.DrawVirdya;
var
  collided, closeBy: Boolean;
  distance, headHeight, randRot: Single;
  rand: Byte;
  tempFace: GLUInt;
begin
  Angleify(@virdyaRot);
  Angleify(@virdyaRotL);
  if (virdyaState = 0) then
    LerpAngle(@virdyaRotL[0], virdyaRot, deltaTime)
  else if ((virdyaState = 1) or (virdyaState = 3)) then
    LerpAngle(@virdyaRotL[0], virdyaRot, delta20)
  else
    LerpAngle(@virdyaRotL[0], virdyaRot, delta2);
  Lerp(@virdyaRotL[1], virdyaHeadRot[0], delta2);
  Lerp(@virdyaRotL[2], virdyaHeadRot[1], delta2);

  distance := DistanceToSqr(virdyaPos[0], virdyaPos[1],
    camPosNext[0], camPosNext[2]);

  if (distance < 0.2) then begin { Collide with player }
    headHeight := GetDirection(virdyaPos[0], virdyaPos[1],
      camPosN[0], camPosN[1]);

    camCurSpeed[0] := Abs(Cos(headHeight)) * camCurSpeed[0];   
    camCurSpeed[2] := Abs(Sin(headHeight)) * camCurSpeed[2];
  end;
  if ((distance < 0.25) and (virdyaState = 1)) then begin
    virdya := 58;
    virdyaState := 0;
    virdyaRot := GetDirection(virdyaPos[0], virdyaPos[1],
      camPosN[0], camPosN[1]);
    virdyaHeadRot[0] := -10.0;
    virdyaHeadRot[1] := 0;
    virdyaSpeed[0] := 0;
    virdyaSpeed[1] := 0;
  end;

  collided := MoveAndCollide(@virdyaPos[0], @virdyaPos[1],
    @virdyaSpeed[0], @virdyaSpeed[1], 0.5, False);

  virdyaTimer := virdyaTimer - deltaTime; { Behavior timer }
  if (virdyaTimer < 0.0) then
    if (virdyaState = 0) then begin { Standing chill }
      rand := Random(6);
      virdyaTimer := (rand + 2.0) * 0.1;

      if (rand < 2) then begin
        RandomFloat(@virdyaHeadRot[0], 25);
        virdyaHeadRot[0] := virdyaHeadRot[0] - 10.0;
        RandomFloat(@virdyaHeadRot[1], 45);

        if (rand = 0) then begin
          closeBy := False;
          if (distance < 6.0) then
            closeBy := True
          else begin
            virdya := 58;
            virdyaState := 1;
            virdyaTimer := 0;
            virdyaDest[0] := camPosN[0];
            virdyaDest[1] := camPosN[1];
            virdyaHeadRot[0] := -10.0;
            virdyaHeadRot[1] := 0;
          end;

          if ((Random(2) <> 0) and (closeBy)) then begin { Look at player }
            virdyaRot := GetDirection(virdyaPos[0], virdyaPos[1],
              camPosN[0], camPosN[1]);
            virdyaHeadRot[0] := -10.0;
            virdyaHeadRot[1] := 0;
          end else
            virdyaRot := RandomRange2(-90, 90) * D2R + virdyaRot;
        end;
      end else if (rand = 2) then begin
        virdya := 58;
        virdyaState := 1;
        virdyaTimer := 0;
        RandomFloat(@randRot, 6);
        virdyaDest[0] := virdyaPos[0] + randRot;
        RandomFloat(@randRot, 6);
        virdyaDest[1] := virdyaPos[1] + randRot;
      end else if (rand = 3) then begin
        case Random(2) of
          0: virdya := 67;
          1: virdya := 58;
        end
      end else if (rand = 4) then
        if ((virdyaFace <> TexVirdyaN) and (Glyphs = 7)) then
          if (distance < 8.0) then begin
            if (virdyaEmote = 0) then begin
              Print('Virdya emotes');
              virdya := 123;
              virdyaState := 4;
              virdyaSpeed[0] := 0;
              virdyaSpeed[1] := 0;

              virdyaTimer := 0.2;
              virdyaEmote := Random(8) + 6;
            end else
              Dec(virdyaEmote);
          end else begin
            virdyaEmote := Random(4) + 3;
          end;
    end else if (virdyaState = 1) then begin { Walking }
      Inc(virdya);
      virdyaTimer := 0.1;
      if (virdya = 67) then
        virdya := 59;
    end else if ((virdyaState = 2) and (virdya >= 68) and (virdya <= 73)) then
    begin
      Inc(virdya);
      virdyaTimer := 0.2;
      if (virdya = 74) then
        virdya := 68;
    end else if (virdyaState = 4) then begin { Waving }
      Inc(virdya);
      virdyaTimer := 0.1;
      if (virdya = 132) then begin
        virdyaState := 0;
        virdya := 58;
      end;
    end;

  headHeight := 1.37;
  case virdyaState of
    0: begin { Standing process }
      virdyaSpeed[0] := 0;
      virdyaSpeed[1] := 0;
      Lerp(@virdyaSound, 0, delta2);
      if (virdyaSound < 0.01) then
        virdyaSound := 0;
      if ((playerState = 0) and (kubaleVision <> 0)) then begin
        Lerp(@fade, 0, delta2);
        Lerp(@vignetteRed, 0, delta2);
      end;
    end;
    1: begin { Walking process }
      headHeight := headHeight - Sin(virdya) * 0.005;

      virdyaRot := GetDirection(virdyaPos[0], virdyaPos[1],
        virdyaDest[0], virdyaDest[1]);

      virdyaSpeed[0] := Sin(virdyaRot) * deltaTime;   
      virdyaSpeed[1] := Cos(virdyaRot) * deltaTime;

      if (collided) then begin
        virdyaState := 0;
        virdya := 58;
      end;

      if (DistanceToSqr(virdyaPos[0], virdyaPos[1],
      virdyaDest[0], virdyaDest[1]) < 0.2) then begin
        virdyaState := 0;
        virdya := 58;
      end;
      Lerp(@virdyaSound, 0, delta2);
      if (virdyaSound < 0.01) then
        virdyaSound := 0;
    end;
    2: begin { Glyph placed process }
      if ((GlyphsInLayer <> 0) and (Glyphs = 6)) then begin
        distance := DistanceToSqr(virdyaPos[0], virdyaPos[1],
          GlyphPos[0], GlyphPos[1]);
        virdyaDest[0] := GlyphPos[0];
        virdyaDest[1] := GlyphPos[1];
      end else begin
        virdyaDest[0] := camPosN[0];
        virdyaDest[1] := camPosN[1];
      end;

      virdyaRot := GetDirection(virdyaPos[0], virdyaPos[1],
        virdyaDest[0], virdyaDest[1]);
      virdyaRotL[2] := (virdyaRot - virdyaRotL[0]) * R2D;

      virdyaRotL[1] := 1.0 / (distance + 2.0) * (-90.0);

      if (distance < 5.0) then begin
        virdyaSpeed[0] := Sin(virdyaRot) * deltaTime * (-0.7);   
        virdyaSpeed[1] := Cos(virdyaRot) * deltaTime * (-0.7);

        if ((DistanceToSqr(virdyaPos[0], virdyaPos[1],
        virdyaPosPrev[0], virdyaPosPrev[1]) * 1000.0) > deltaTime) then begin
          if (virdya = 58) then
            virdya := 68;
        end else
          virdya := 58;
      end else begin
        virdyaSpeed[0] := 0;
        virdyaSpeed[1] := 0;
        virdya := 58;
      end;
    end;
    3: begin { Defensive process }
      virdyaRot := GetDirection(virdyaPos[0], virdyaPos[1],
        camPosN[0], camPosN[1]);

      virdyaRotL[2] := (virdyaRot - virdyaRotL[0]) * R2D;

      virdyaRotL[1] := (1.0 / (distance + 2.0) * (-90.0)) - (camCrouch * 10.0);

      if (playerState = 0) then begin
        closeBy := False;
        if (((distance < 12.0) and (not CheckBlocked(virdyaPos[0], virdyaPos[1],
        camPosN[0], camPosN[1]))) or (distance < 2.0)) then begin
          virdya := 74;
          if (distance < 10.0) then begin
            virdya := 75;
            fade := deltaTime * 0.2 + fade;
            if (fade > 1.0) then begin
              canControl := False;
              playerState := 9;
            end;
            Lerp(@virdyaSound, 1.0, deltaTime);
            Lerp(@vignetteRed, 1.0, deltaTime);
            camCurSpeed[0] := camCurSpeed[0] * 0.33;   
            camCurSpeed[2] := camCurSpeed[2] * 0.33;

            closeBy := True;

            if (distance < 2.0) then begin
              virdyaSpeed[0] := -(Sin(virdyaRot) * deltaTime * 0.1);  
              virdyaSpeed[1] := -(Cos(virdyaRot) * deltaTime * 0.1);
            end;
          end;
        end else
          virdya := 58;
        if (not closeBy) then begin
          if (kubaleVision = 0) then begin
            Lerp(@fade, 0, delta2);
            Lerp(@vignetteRed, 0, delta2);
          end;
          Lerp(@virdyaSound, 0, delta2);
          if (virdyaSound < 0.01) then
            virdyaSound := 0;
        end;
      end else begin        
        Lerp(@virdyaSound, 0, delta2);
        if (virdyaSound < 0.01) then
          virdyaSound := 0;
      end;
    end;
    4: begin { Waving process }
      virdyaRot := GetDirection(virdyaPos[0], virdyaPos[1],
        camPosN[0], camPosN[1]);
      virdyaHeadRot[1] := 0;

      virdyaHeadRot[0] := (1.0 / (distance + 2.0) * (-90.0))-(camCrouch * 10.0);
    end;
  end;

  { React to glyphs }
  if ((Glyphs < 7) and (Glyphs >= 5) and (virdyaState <> 2)) then begin
    if (GlyphsInLayer <> 0) then begin
      distance := DistanceToSqr(virdyaPos[0], virdyaPos[1],
        GlyphPos[0], GlyphPos[1]);
      if ((distance < 10.0) or (Glyphs = 5)) then begin
        virdyaState := 2;
        virdya := 58;
        virdyaBlink := 0;
      end;
    end;
  end else if (Glyphs < 5) then begin
    if ((Distance < (32.0 - camCrouch * 10.0)) and (virdyaState <> 3)) then
    begin
      Print('Virdya is going apeshit');
      virdyaState := 3;
      virdya := 58;
      virdyaBlink := 0;
      virdyaSpeed[0] := 0;
      virdyaSpeed[1] := 0;
    end;
    if ((Distance > 32.0) and (virdyaState = 3)) then begin
      Print('Virdya is fine');
      virdyaState := 0;
      virdya := 58;
    end;
  end;

  closeBy := False;
  if ((wmblyk = 11) or (wmblyk = 12)) then { React to Wmblyk }
    closeBy := closeBy or VirdyaReact(wmblykPos[0], wmblykPos[1], 2.0);
  if (WB <> 0) then
    closeBy := closeBy or VirdyaReact(WBPosL[0], WBPosL[1], 4.0);   
  if (kubale > 1) then
    closeBy := closeBy or VirdyaReact(kubalePos[0], kubalePos[1], 6.0);

  if ((Glyphs = 7) and (virdyaState > 1) and (not closeBy)
  and (virdyaState <> 4)) then
    virdyaState := 0;

  virdyaBlink := virdyaBlink - deltaTime;
  if (virdyaBlink < 0.0) then begin { Blink and facial timer }
    if (Random(5) = 0) then
      tempFace := TexVirdyaBlink
    else
      tempFace := virdyaFace;
    if (tempFace = TexVirdyaBlink) then begin
      if ((virdyaState < 2) or (virdyaState = 4)) then begin
        virdyaBlink := Random(3) + 1;
        case Random(8) of
          0: virdyaFace := TexVirdyaDown;
          1: virdyaFace := TexVirdyaUp;
          else virdyaFace := TexVirdyaNeut;
        end;
      end else begin
        virdyaBlink := Random(5) + 1;
        virdyaFace := TexVirdyaN;
      end;
    end else begin
      virdyaBlink := 0.1;
      virdyaFace := TexVirdyaBlink;
      if ((Random(3) = 0) and (virdyaState = 1)) then
        virdyaState := 0
    end;
  end;

  virdyaPosPrev[0] := virdyaPos[0];     
  virdyaPosPrev[1] := virdyaPos[1];

  alSourcef(SndVirdya, AL_GAIN, virdyaSound);

  glPushMatrix;
    glTranslatef(virdyaPos[0], 0, virdyaPos[1]);
    glRotatef(virdyaRotL[0] * R2D, 0, 1.0, 0);
    glDisable(GL_CULL_FACE);
    glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, 1);
    glBindTexture(GL_TEXTURE_2D, virdyaFace);
    glCallList(virdya);

    glPushMatrix;
      glTranslatef(0, headHeight, -0.06);
      glRotatef(virdyaRotL[2], 0, 1.0, 0);
      glRotatef(virdyaRotL[1], 1.0, 0, 0);
      glCallList(57);
    glPopMatrix;

    glEnable(GL_CULL_FACE);
    glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, 0);

    glEnable(GL_BLEND);
    glDisable(GL_LIGHTING);
    glDisable(GL_FOG);
    glBlendFunc(GL_ZERO, GL_SRC_COLOR);
    glScalef(2.0, 2.0, 2.0);
    glTranslatef(-0.5, 0.01, -0.5);
    glRotatef(90.0, 1.0, 0, 0);

    glColor3fv(@mclWhite);
    glBindTexture(GL_TEXTURE_2D, TexShadow);
    glCallList(3);
    glDisable(GL_BLEND);
    glEnable(GL_LIGHTING);
    glEnable(GL_FOG);
  glPopMatrix;
end;

{ Draw wall and check collision from every wall (in radius) }
procedure TFMain.DrawWall(const List:GLUint; const PosX, PosY: Single;
  const Vertical: Boolean);
begin
  { Draw stuff }
  glCallList(List);
  if (not canControl) then Exit;

  CollidePlayerWall(PosX, PosY, Vertical);
end;

{ Draw ending wasteland }
procedure TFMain.DrawWasteland;
var
  deltaHalf: Single;
  TerrX, TerrY, TerrX1, TerrY1: Single;
begin
  deltaHalf := deltaTime * 0.5;
  if (MazeHostile = 8) then begin { Fade in }
    Lerp(@MotryaTimer, -0.1, deltaHalf);
    Lerp(@fogDensity, 0.6, deltaTime);
    Lerp(@AscendColor[0], mclTrench[0], deltaTime);
    Lerp(@AscendColor[1], mclTrench[1], deltaTime);
    Lerp(@AscendColor[2], mclTrench[2], deltaTime);
    glClearColor(AscendColor[0], AscendColor[1], AscendColor[2], 1.0);
    glFogfv(GL_FOG_COLOR, @AscendColor);

    if (MotryaTimer < 0.0) then begin
      MotryaTimer := 0;
      MazeHostile := 9;
    end;
  end else if (MazeHostile = 9) then begin { Faded in, play music }
    Lerp(@fogDensity, 0.3, deltaHalf);
    if (fogDensity < 0.5) then begin
      MazeHostile := 10;
      alSourcePlay(SndMus1);
    end;
  end else if (MazeHostile = 10) then begin { Fade out }
    if (NoiseOpacity[0] < 0.0) then begin
      canControl := False;
      playerState := 17;
      MazeHostile := 11;

      defKey := TRegistry.Create;
      defKey.OpenKey(RegPath, True);
      Complete := 1;
      defKey.WriteBinaryData(RegComplete, Complete, 1);
      defKey.Free;

      EraseTempSave;
    end;
  end;

  vignetteRed := deltaTime * 0.015 + vignetteRed;
  fade := vignetteRed;
  NoiseOpacity[0] := 1.0 - (fade * 0.5 + 0.5);

  MotryaDist := NoiseOpacity[0] * 6.0 + 5.0;
  TerrX1 := Sqr(MotryaDist) - 10.0; { Min distance }
  TerrY1 := TerrX1 + 13.0; { Max distance }

  deltaHalf := DistanceToSqr(MotryaPos[0], MotryaPos[1], camPosN[0], camPosN[1]);
  if ((deltaHalf < TerrX1) or (deltaHalf > TerrY1)) then begin
    MotryaPos[0] := camPosN[0] - camForward[0] * MotryaDist;
    MotryaPos[1] := camPosN[1] - camForward[2] * MotryaDist;
  end;

  TerrX := Round(camPosN[0] / 20.0) * 20.0;   
  TerrY := Round(camPosN[1] / 20.0) * 20.0;

  glBindTexture(GL_TEXTURE_2D, TexConcreteRoof);
  glPushMatrix;
    glTranslatef(TerrX, 0, TerrY);
    glCallList(97);
    glTranslatef(-20.0, 0, 0);     
    glCallList(97);
    glTranslatef(0, 0, -20.0);
    glCallList(97);
    glTranslatef(20.0, 0, 0);
    glCallList(97);
    glTranslatef(20.0, 0, 0);
    glCallList(97);
    glTranslatef(0, 0, 20.0);
    glCallList(97);
    glTranslatef(0, 0, 20.0);
    glCallList(97);
    glTranslatef(-20.0, 0, 0);
    glCallList(97);
    glTranslatef(-20.0, 0, 0);
    glCallList(97);
  glPopMatrix;

  glBindTexture(GL_TEXTURE_2D, TexMotrya);
  glColor3fv(@mclDarkGray);
  glPushMatrix;
    glTranslatef(MotryaPos[0], 0, MotryaPos[1]);
    glRotatef(GetDirection(MotryaPos[0], MotryaPos[1], camPosN[0], camPosN[1])
      * R2D, 0, 1.0, 0);
    glCallList(88);
  glPopMatrix;
  glColor3fv(@mclWhite);
end;

{ Draw and process WB }
procedure TFMain.DrawWB;
var
  distancePlayer, PlrX, PlrY, fltVal: Single;
  found: Boolean;
  alState: ALInt;
begin
  GetMazeCellPos(WBPos[0], WBPos[1], @WBPosI[0], @WBPosI[1]);

  distancePlayer := DistanceToSqr(WBPos[0], WBPos[1],
    camPosNext[0], camPosNext[2]);

  if ((distancePlayer < 0.33) and (mMenu = 0)) then begin { Collide with player }
    camCurSpeed[0] := -camCurSpeed[0];
    camCurSpeed[2] := -camCurSpeed[2];

    if (WB <> 2) then begin
      WBTarget[0] := WBPos[0];
      WBTarget[1] := WBPos[1];
    end;

    WBSpeed[0] := -WBSpeed[0];
    WBSpeed[1] := -WBSpeed[1];

    { Check if collision is in front }
    if ((Abs(camCurSpeed[0]) > deltaTime) or (Abs(camCurSpeed[2]) > deltaTime))
    then
      if (WBFront(True)) then
        AlertWB(3);
  end;

  WBTimer := WBTimer - deltaTime;
  if (WBTimer < 0.0) then begin
    if (WB = 1) then begin { Wander }
      if (Random(3) = 0) then begin
        GetRandomMazePosition(@PlrX, @PlrY);

        WBSetSolve(PlrX, PlrY);
        Print('Random maze position');
      end else begin
        RandomFloat(@fltVal, 2);
        WBTimer := fltVal + 3.0;
        WB := 1;

        RandomFloat(@fltVal, 1);
        WBTarget[0] := fltVal * 2.0 + WBPos[0];
        RandomFloat(@fltVal, 1);
        WBTarget[1] := fltVal * 2.0 + WBPos[1];
      end;
    end else if (WB = 3) then begin { Close searching }
      RandomFloat(@fltVal, 2);
      WBTimer := fltVal + 4.0;
      WB := 1;
    end;
  end;

  case WB of
    1: WBMove(2.0); { Wander }
    2: begin { Rushing }
      WBAnim := 1;

      Lerp(@WBSpMul, Clamp(DistanceToSqr(WBPos[0], WBPos[1],
        WBFinal[0], WBFinal[1]) * 0.2 + 2.0, 0, 8.0), delta2);

      fltVal := WBSpMul * deltaTime;

      WBRot[1] := GetDirection(WBPos[0], WBPos[1], WBTarget[0], WBTarget[1]);
      MoveTowardsAngle(@WBRot[0], WBRot[1], fltVal);
      MoveTowards(@WBPos[0], WBTarget[0], fltVal);    
      MoveTowards(@WBPos[1], WBTarget[1], fltVal);

      found := False;

      if (WBStack <> nil) then begin
        if ((WBPosI[0] = WBNext[0]) and (WBPosI[1] = WBNext[1])) then begin
          if (WBStack.BufferIndex <> 0) then begin
            Print('Popping stack');
            WBStack.Pop(@WBNext[1]);
            WBStack.Pop(@WBNext[0]);
            WBTarget[0] := WBNext[0] * 2.0 + 1.0;
            WBTarget[1] := WBNext[1] * 2.0 + 1.0;
          end else
            found := True;
        end;
      end;

      if (distancePlayer < 2.0) then
        found := True;

      if (found) then begin
        Print('Found you.');
        WBAnim := 0;
        WB := 3;
        RandomFloat(@fltVal, 2);
        WBTimer := fltVal + 3.0;
        if (WBTimer < 1.2) then
          WB := 4;
      end;
    end;
    3: begin { Close searching }
      RandomFloat(@fltVal, 1);
      if (fltVal > 0.75) then begin
        RandomFloat(@fltVal, 1);
        WBTarget[0] := fltVal * 0.5 + WBPos[0];   
        RandomFloat(@fltVal, 1);
        WBTarget[1] := fltVal * 0.5 + WBPos[1];
      end;
      WBMove(4.0);
    end;
    4: begin { Attacking player }
      if (WBFront(False)) then begin
        if (WBAnim <> 2) then begin
          alSource3f(SndWBAttack, AL_POSITION, WBPosL[0], 0, WBPosL[1]);
          alSourcePlay(SndWBAttack);
          WBAnim := 2;
          WBFrame := 119;
          WBAnimTimer := 0.2;
        end;
      end else begin
        WBRot[1] := GetDirection(WBPos[0], WBPos[1], camPosN[0], camPosN[1]);
        MoveTowardsAngle(@WBRot[0], WBRot[1], delta20);
      end;
    end;
  end;

  alSource3f(SndWBAlarm, AL_POSITION, WBPosL[0], 0, WBPosL[1]);    
  alSource3f(SndWBIdle[0], AL_POSITION, WBPosL[0], 0, WBPosL[1]);
  alSource3f(SndWBIdle[1], AL_POSITION, WBPosL[0], 0, WBPosL[1]);

  alSource3f(SndWmblykB, AL_POSITION, WBPosL[0], 0, WBPosL[1]);

  if (WBAnim = 1) then { Animate }
    WBAnimTimer := WBAnimTimer - deltaTime * WBCurSpd * 0.5
  else
    WBAnimTimer := WBAnimTimer - deltaTime;

  if (WBAnimTimer < 0.0) then begin
    case Random(12) of
      0: begin
        alGetSourcei(SndWBIdle[1], AL_SOURCE_STATE, alState);
        if (alState <> AL_PLAYING) then
          alSourcePlay(SndWBIdle[0]);
      end;       
      1: begin
        alGetSourcei(SndWBIdle[0], AL_SOURCE_STATE, alState);
        if (alState <> AL_PLAYING) then
          alSourcePlay(SndWBIdle[1]);
      end;
    end;

    Inc(WBFrame);
    case WBAnim of
      0: begin { Idle }
        if (WBFrame >= 119) then begin
          WBFrame := 117;
          RandomFloat(@WBAnimTimer, 1);
          WBAnimTimer := WBAnimTimer + 1.0;
        end else
          WBAnimTimer := 0.1;
      end;
      1: begin { Walk }
        if (WBFrame >= 117) then begin
          WBFrame := 114;
          WBMirror := not WBMirror;

          alState := Random(4);
          alSource3f(SndWBStep[alState], AL_POSITION, WBPosL[0], 0, WBPosL[1]);
          alSourcePlay(SndWBStep[alState]);
        end;
        WBAnimTimer := 0.2;
      end;
      2: begin { Attack }
        if (WBFrame >= 122) then begin
          WBAnim := 0;
          WBFrame := 117;
          WB := 3;
          WBTimer := 3.0;
        end else if ((WBFrame = 121) and (playerState = 0)) then
          if ((distancePlayer < 0.75) and (WBFront(False))) then begin
            alSource3f(SndHurt, AL_POSITION, WBPosL[0], 0, WBPosL[1]);
            alSourcePlay(SndHurt);
            playerState := 9;
            fadeState := 2;
            canControl := False;
            camCurSpeed[0] := 0;
            camCurSpeed[2] := 0;
          end;
        WBAnimtimer := 0.1;
      end;
    end;
  end;

  Lerp(@WBPosL[0], WBPos[0], delta20);
  Lerp(@WBPosL[1], WBPos[1], delta20);

  { Get speed }
  WBCurSpd := DistanceToSqr(WBPosL[0], WBPosL[1], WBPosP[0], WBPosP[1]) * 1000;

  WBPosP[0] := WBPosL[0];     
  WBPosP[1] := WBPosL[1];

  glPushMatrix; { Draw }
    glTranslatef(WBPosL[0], 0, WBPosL[1]);
    glRotatef(WBRot[0] * R2D, 0, 1.0, 0);
    glScalef(0.9, 0.9, 0.9);
    if (WBMirror) then begin
      glScalef(-1.0, 1.0, 1.0);
      glCullFace(GL_FRONT);
    end;
    glBindTexture(GL_TEXTURE_2D, TexWB);
    glCallList(WBFrame);
    if (WBMirror) then
      glCullFace(GL_BACK);
  glPopMatrix;
end;

{ Draw Webubychko }
procedure TFMain.DrawWBBK;
var
  rotDir, dist: Single;
begin
  rotDir := GetDirection(WBBKPos[0], WBBKPos[1], camPosN[0], camPosN[1]);
  dist := DistanceToSqr(WBBKPos[0], WBBKPos[1], camPosNext[0], camPosNext[2]);
  WBBKTimer := WBBKTimer - deltaTime * 0.25;
  if (WBBKTimer < 0.0) then begin
    WBBKTimer := MPI;

    if (Random(2) = 0) then begin
      RandomFloat(@WBBKSndPos[2], 6);
      WBBKSndPos[2] := WBBKSndPos[2] + camPosN[0];  
      RandomFloat(@WBBKSndPos[3], 6);
      WBBKSndPos[3] := WBBKSndPos[3] + camPosN[1];

      WBBKSndID := Random(4);
      alSourcePlay(SndAmbW[WBBKSndID]);
      Print('Played sound ', WBBKSndID);
    end;
  end;

  if (WBBK < 3) then begin { Abstracted }
    if (WBBK = 1) then begin
      Lerp(@WBBKSndPos[0], WBBKSndPos[2], delta2);     
      Lerp(@WBBKSndPos[1], WBBKSndPos[3], delta2);
      alSource3f(SndAmbW[WBBKSndID], AL_POSITION, WBBKSndPos[0], 0, WBBKSndPos[1]);

      WBBKDist := Sin(WBBKTimer) * 2.0 + 4.0; { Distance factor }

      Angleify(@WBBKCamDir);
      LerpAngle(@WBBKCamDir, camRot[1], deltaTime);

      WBBKPos[0] := camPosN[0] - Sin(WBBKCamDir) * WBBKDist; { Position }
      WBBKPos[1] := camPosN[1] - Cos(WBBKCamDir) * WBBKDist;

      WBBKSTimer := WBBKSTimer - deltaTime;
      if (WBBKSTimer < 0.0) then begin
        WBBK := 2;
        Print('WEBUBYCHKO');
        alSourcePlay(SndWBBK);
        alSource3f(SndWBBK, AL_POSITION, WBBKPos[0], 0, WBBKPos[1]);
      end;
    end else if (WBBK = 2) then begin { Jumpscare }
      WBBKPos[0] := WBBKPos[0] - Sin(rotDir) * delta20;  
      WBBKPos[1] := WBBKPos[1] - Cos(rotDir) * delta20;

      alSource3f(SndWBBK, AL_POSITION, WBBKPos[0], 0, WBBKPos[1]);

      if (dist < 0.33) then begin
        WBBK := 1;
        WBBKSTimer := 10.0;
        alSourceStop(SndWBBK);
      end;
    end;

    glPushMatrix;
      glDisable(GL_LIGHTING);
      glEnable(GL_BLEND);
      glBlendFunc(GL_ONE, GL_ONE);
      glTranslatef(WBBKPos[0], 0.75, WBBKPos[1]);
      glRotatef(rotDir * D2R, 0, 1.0, 0);
      if (WBBK = 1) then
        glBindTexture(GL_TEXTURE_2D, TexWBBK)
      else
        glBindTexture(GL_TEXTURE_2D, TexWBBK1);
      glCallList(84);
      glEnable(GL_LIGHTING);
    glPopMatrix;
  end else begin { Unabstracted }
    if (not CheckWBBKVisible(dist, 20.0, 8.0)) then begin
      WBBKCamDir := rotDir;
      if (dist > 5.0) then begin
        GetRandomMazePosition(@WBBKPos[0], @WBBKPos[1]);
        while True do begin
          dist := DistanceToSqr(WBBKPos[0], WBBKPos[1],
            camPosNext[0], camPosNext[2]);
          if (CheckWBBKVisible(dist, 20.0, 5.0)) then begin
            GetRandomMazePosition(@WBBKPos[0], @WBBKPos[1]);
            Print('TELEPORTING');
          end else begin
            WBMirror := Boolean(Random(1));
            Break;
          end;
        end;
      end;
    end else begin
      WBBKSTimer := WBBKSTimer - delta2;
      if (WBBKSTimer < 0.0) then begin
        if (Random(3) <> 0) then
          WBMirror := not WBMirror
        else begin
          alSourcePlay(SndDistress);
          fade := 1.0;
          fadeState := 1;
          GetRandomMazePosition(@camPosN[0], @camPosN[1]);
          camPos[0] := -camPosN[0];
          camPosNext[0] := camPos[0];
          camPosL[0] := camPos[0];       
          camPos[2] := -camPosN[1];
          camPosNext[2] := camPos[2];
          camPosL[2] := camPos[2];
        end;
      end;
    end;

    rotDir := WBBKPos[0] - 1.0;
    dist := WBBKPos[1] - 1.0;
    CollidePlayerWall(rotDir, dist, False);
    CollidePlayerWall(rotDir, dist, True);   
    CollidePlayerWall(rotDir + 2.0, dist, True);  
    CollidePlayerWall(rotDir, dist + 2.0, False);

    rotDir := Trunc(WBBKCamDir * R2I) * 90.0;

    glPushMatrix;
      glTranslatef(WBBKPos[0], 0, WBBKPos[1]);
      glRotatef(rotDir, 0, 1.0, 0);
      if (WBMirror) then begin
        glScalef(-1.0, 1.0, 1.0);
        glCullFace(GL_FRONT);
      end;
      glBindTexture(GL_TEXTURE_2D, TexWBBKP);
      glCallList(122);
      if (WBMirror) then
        glCullFace(GL_BACK);
    glPopMatrix;
  end;
end;

{ Draw and process Wmblyk the jumpscarer (plus stealthy) }
procedure TFMain.DrawWmblyk;
var
  tX, tY, distance: Single;
  turn: Boolean;
begin
  tX := GetDirection(wmblykPos[0], wmblykPos[1], camPosN[0], camPosN[1]);

  Angleify(@wmblykDir);
  if (wmblyk = 10) then begin
    LerpAngle(@wmblykDir, tX, delta20);
    wmblykPos[0] := wmblykPos[0] - Sin(tX) * delta2;
    wmblykPos[1] := wmblykPos[1] - Cos(tX) * delta2;
  end else begin
    if (wmblykStealthy = 0) then
      LerpAngle(@wmblykDir, tX, delta2)
    else
      wmblykDir := tX;
  end;

  tY := wmblykDir * R2D;

  distance := DistanceToSqr(wmblykPos[0], wmblykPos[1], camPosN[0], camPosN[1]);

  wmblykBlink := wmblykBlink - deltaTime;

  if (wmblykBlink < 0.0) then begin
    case wmblykStealthy of
      0: begin
        if (wmblyk = 10) then begin
          wmblyk := 1;
          wmblykJumpscare := 1.0;
          alSourcePlay(SndWmblyk);
          if (Random(2) = 0) then
            MakeWmblykStealthy;
          Exit;
        end;
        glColor4fv(@mclBlack);

        wmblykBlink := Random(3) + 2;
      end;
      1: begin { Waited for appearing }
        Print('Wmblyk will now appear');
        wmblykBlink := 1.0;
        wmblykStealth := camRot[1];
        wmblykStealthy := 2;
      end;
      2: begin { Waited for turn }
        Print('Wmblyk has appeared');
        wmblykStealth := 2.0;
        wmblykStealthy := 3;
      end;
      4: begin { LOOGAME }
        if (Random(9) <> 0) then
          MakeWmblykStealthy;
      end;
    end;
  end;

  Print(wmblykBlink:0:3, #32, wmblykStealthy);

  case wmblykStealthy of
    2: begin
      turn := False;
      if (DistanceScalar(wmblykStealth, camRot[1]) > 1.0) then
        turn := True
      else if (DistanceScalar(camRot[0], 0) > 1.0) then
        turn := True;

      if (turn) then begin { Camera rotated }
        wmblykBlink := 1.0;
        wmblykStealth := camRot[1];
      end;
    end;
    3: begin
      turn := False;
      if (distance > 1.0) then
        turn := True
      else if (distance < 0.1) then
        turn := True;

      if (turn) then begin{ Camera moved too far }
        wmblykPos[0] := camForward[0] * 0.5 + camPosN[0];
        wmblykPos[1] := camForward[2] * 0.5 + camPosN[1];

        tX := GetDirection(wmblykPos[0], wmblykPos[1], camPosN[0], camPosN[1]);
      end;

      { If camera looks at Wmblyk }
      if (DistanceScalar(DistanceScalar(tX, camRot[1]), MPI) < 2.0) then begin
        wmblykStealthy := 4;
        wmblykStealth := 1.0;
        wmblykBlink := 1.0;
      end;

      if (camRot[0] > 1.0) then begin
        wmblykStealthy := 4;
        wmblykStealth := 1.0;
        wmblykBlink := 1.0;
      end;
    end;
    4: begin
      Lerp(@wmblykStealth, 0, delta20 * 0.5);
    end;
  end;

  if ((wmblykStealthy = 0) or (wmblykStealthy >= 3)) then begin
    glDisable(GL_LIGHTING);
    glDisable(GL_FOG);
    glBindTexture(GL_TEXTURE_2D, TexWmblykNeutral);
    glPushMatrix;
      glTranslatef(wmblykPos[0], 0, wmblykPos[1]);

      if (wmblykStealthy = 4) then begin
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glColor4f(wmblykStealth, wmblykStealth, wmblykStealth, wmblykStealth);
      end;

      glPushMatrix;
        glRotatef(tY, 0, 1.0, 0);
        glCallList(wmblyk);
      glPopMatrix;

      glPushMatrix;
        glTranslatef(0, 1.56, 0);
        tX := tX * R2D;
        glRotatef(tX, 0, 1.0, 0);

        { Grab }
        if (wmblykStealthy = 0) then
          if (distance < 1.0) and (wmblyk = 8) then begin
            wmblyk := 10;
            wmblykBlink := 0.1;
          end;

        tX := (1.0 / (distance + 2.0) * (-90.0)) - camCrouch * 10.0;
        glRotatef(tX, 1.0, 0, 0);
        glCallList(9);
      glPopMatrix;

      if (wmblykStealthy = 0) then begin
        glColor3fv(@mclWhite);

        glEnable(GL_BLEND);
        glBlendFunc(GL_ZERO, GL_SRC_COLOR);
        glScalef(2.0, 2.0, 2.0);
        glTranslatef(-0.5, 0.2, -0.5);
        glRotatef(90.0, 1.0, 0, 0);
        glBindTexture(GL_TEXTURE_2D, TexShadow);
        glCallList(3);
      end;

    glPopMatrix;
    if (wmblykStealthy = 4) then
      glColor4fv(@mclWhite);
  end;
end;

{ Draw and process Wmblyk the strangler }
procedure TFMain.DrawWmblykAngry;
var
  MazeX, MazeY: LongWord;
  WalkX, WalkY: Single;
  ChoosePath, ChooseByte, i: Byte;
  kubaleClose: Boolean;
  face: GLUInt = 0;
begin
  if (wmblyk <> 13) then
    alSource3f(SndWmblykB, AL_POSITION, wmblykPos[0], 0, wmblykPos[1]);

  wmblykBlink := wmblykBlink - deltaTime; { --wmblykBlink }
  if (wmblyk = 11) then begin
    face := TexWmblykNeutral;

    if (wmblykBlink < 0.0) then begin
      wmblykBlink := 0.15;
      Inc(wmblykAnim);
    end;

    { Animate walking }
    if (wmblykAnim < 107) then begin
      if (wmblykAnim >= 15) then
        wmblykAnim := 11;
    end else if (wmblykAnim >= 109) then
      wmblykAnim := 107;

    if (MazeCrevice <> 0) then begin
      if (DistanceToSqr(wmblykPos[0], wmblykPos[1],
      MazeCrevicePos[0] * 2.0 + 1.0, MazeCrevicePos[1] * 2.0 + 1.0) < 1.2) then
      begin
        if (wmblykAnim < 107) then
          wmblykAnim := 107;
      end else if (wmblykAnim > 107) then
        wmblykAnim := 11;
    end;

    { Walk algorithm }
    MazeX := Trunc(wmblykPos[0] * 0.5);
    MazeY := Trunc(wmblykPos[1] * 0.5);

    WalkX := wmblykPos[0] * 0.5 - MazeX;
    WalkY := wmblykPos[1] * 0.5 - MazeY;

    ChoosePath := 0;
    if (DistanceScalar(WalkX, 0.5) < 0.1) then
      Inc(ChoosePath);
    if (DistanceScalar(WalkY, 0.5) < 0.1) then
      Inc(ChoosePath);

    kubaleClose := False;
    if (kubale > 28) then begin
      if (DistanceToSqr(wmblykPos[0], wmblykPos[1], kubalePos[0], kubalePos[1])
      <= 0.5) then begin
        Print('Close to Kubale');
        ChoosePath := 2;
        wmblykTurn := False;
        kubaleClose := True;
      end;
    end;

    if ((ChoosePath <> 2) and (wmblykTurn)) then
      wmblykTurn := False;

    if ((ChoosePath = 2) and (not wmblykTurn)) then begin
      wmblykTurn := True;
      Print('Turn');
      ChoosePath := 0;
      ChooseByte := 0;
      WmblykShuffle;

      while (ChoosePath = 0) do begin
        i := ChooseByte;
        if (kubaleClose) then
          i := 3;
        wmblykDirI := wmblykDirS[i];

        ChoosePath := 1;
        case wmblykDirI of
          0: if (not GetCellMZC(MazeX, MazeY, MZC_PASSTOP)) then begin
            Print('Top blocked');
            ChoosePath := 0;
          end;
          1: if (not GetCellMZC(MazeX, MazeY, MZC_PASSLEFT)) then begin
            Print('Left blocked');
            ChoosePath := 0;
          end;  
          2: if ((not GetCellMZC(MazeX, MazeY+1, MZC_PASSTOP)) or
          (MazeY = MazeHM1)) then begin
            Print('Bottom blocked');
            ChoosePath := 0;
          end;      
          3: if ((not GetCellMZC(MazeX+1, MazeY, MZC_PASSLEFT)) or
          (MazeX = MazeWM1)) then begin
            Print('Right blocked');
            ChoosePath := 0;
          end;
        end;

        Inc(ChooseByte);
        if (ChooseByte > 3) then Break;
      end;
    end;
    if (wmblykDirI = 4) then
      wmblykDirI := 0
    else begin
      LerpAngle(@wmblykDir, rotations[wmblykDirI], delta20);

      wmblykPos[0] := wmblykPos[0] + (-Sin(rotations[wmblykDirI]))*delta2*2.0;
      wmblykPos[1] := wmblykPos[1] + (-Cos(rotations[wmblykDirI]))*delta2*2.0;
    end;

    if (playerState = 0) then begin
      if (DistanceToSqr(wmblykPos[0], wmblykPos[1], camPosN[0], camPosN[1])
      < 1.2) then begin
        wmblyk := 12;
        playerState := 6;
        wmblykStr := 0;
        wmblykStrState := 14;
        wmblykBlink := 1.1;
        alSourcePlay(SndWmblykStr); 
        alSourcePlay(SndWmblykStrM);
      end;
    end;
  end else if (wmblyk = 12) then begin
    wmblykAnim := Trunc(wmblykBlink * wmblykStrAnim);

    wmblykAnim := wmblykAnim + wmblykStrState;
    wmblykStr := wmblykStr - deltaTime * 0.33;

    if ((playerState <> 9) and (playerState <> 10)) then begin
      Lerp(@wmblykStrM, 1.0, deltaTime);
      alSourcef(SndWmblykStrM, AL_GAIN, wmblykStrM);
    end;

    if (wmblykStr > flDoor) then begin
      i := 0;
      Print(Complete);
      if (Complete <> 0) then
        if ((Glyphs = 6) and (GlyphsInLayer = 1)) then begin
          if (DistanceToSqr(wmblykPos[0], wmblykPos[1],
          GlyphPos[0], GlyphPos[1]) < 1.0) then
            Inc(i);
        end;
      if (i <> 0) then begin
        alSourceStop(SndWmblykB);   
        alSourceStop(SndWmblykStr);  
        alSourceStop(SndWmblykStrM);
        fade := 0;
        vignetteRed := 0;
        wmblyk := 14;
        playerState := 18;
        face := TexWmblykL2;
        camPos[0] := -(wmblykPos[0] - camForward[0]); 
        camPos[2] := -(wmblykPos[1] - camForward[2]);
        alSource3f(SndSplash, AL_POSITION, camPosN[0], 0, camPosN[1]);
        alSourcePlay(SndSplash);
      end else begin
        wmblykAnim := 24;
        playerState := 8;
        wmblyk := 13;
        camPos[1] := -1.0;
        face := TexWmblykL1;
      end;
    end else begin
      if (wmblykStr > 0.2) then begin
        face := TexWmblykL1;
        if (wmblykStr > 0.33) then
          face := TexWmblykL2;
        if (wmblykStrState <> 17) then begin
          wmblykBlink := 1.1;
          wmblykStrState := 17;
        end;
      end else begin
        LerpAngle(@wmblykDir, GetDirection(wmblykPos[0], wmblykPos[1],
          camPosN[0], camPosN[1]), delta20);
        face := TexWmblykStr;
        if (wmblykStr < -0.1) then begin
          face := TexWmblykW1;
          if (wmblykStr < -0.2) then begin
            face := TexWmblykW2;
            if (wmblykStrState <> 20) then begin
              wmblykBlink := 1.1;
              wmblykStrState := 20;
            end;
            if (wmblykStr < -0.7) then
              if ((playerState <> 9) and (playerState <> 10)) then begin
                canControl := False;
                playerState := 9;
              end;
          end;
        end else if (wmblykStrState <> 14) then begin
          wmblykBlink := 1.1;
          wmblykStrState := 14;
        end;
      end;
      if (wmblykBlink < 0.5) then
        wmblykBlink := 0.9;
    end;
  end else if (wmblyk = 13) then begin
    wmblykAnim := 24;
    glColor3fv(@mclBlack);

    if (DistanceToSqr(wmblykPos[0], wmblykPos[1], camPosN[0], camPosN[1])
    > 32.0) then begin
      wmblyk := 0;
      alSourceStop(SndWmblykStrM);
    end;

    if (wmblykStrM <= 0.0) then
      alSourceStop(SndWmblykStrM)
    else begin
      alSourcef(SndWmblykStrM, AL_GAIN, wmblykStrM);
      Lerp(@wmblykStrM, -0.1, deltaTime);
    end;
  end else if (wmblyk >= 14) then begin
    face := TexWmblykL1;
    wmblykAnim := 19;
    if (wmblyk = 14) then begin
      camPos[0] := -(wmblykPos[0] - camForward[0] * 0.2);   
      camPos[2] := -(wmblykPos[1] - camForward[2] * 0.2);
      camPos[1] := -1.1;
      wmblyk := 15;
      wmblykBlink := 1.0;
    end else if (wmblyk = 15) then begin
      if (wmblykBlink < 0.0) then begin
        wmblykStealth := 0;
        wmblyk := 16;
      end;
    end else if (wmblyk = 16) then begin
      wmblykStealth := deltaTime * 0.5 + wmblykStealth;
      if (wmblykStealth > 1.5) then begin
        alSourceStop(SndAmb);
        fade := 1.0;
        playerState := 9;
        wmblyk := 17;
        CCDeath[5] := #71;  
        CCDeath[6] := #65;    
        CCDeath[7] := #89;
        CCDeath[8] := #46;  
        CCDeath[9] := #0;
      end;
    end;
  end;

  glDisable(GL_LIGHTING);
  glDisable(GL_FOG);
  glBindTexture(GL_TEXTURE_2D, face);
  glPushMatrix;
    glTranslatef(wmblykPos[0], 0, wmblykPos[1]);
    glRotatef(wmblykDir * R2D, 0, 1.0, 0);

    if (wmblyk >= 14) then
      glDisable(GL_DEPTH_TEST);
    glCallList(wmblykAnim);

    glEnable(GL_BLEND);
    if (wmblyk = 16) then begin
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
      glColor4f(1.0, 1.0, 1.0, wmblykStealth);
      glBindTexture(GL_TEXTURE_2D, TexWmblykL3);
      glCallList(wmblykAnim);
      glEnable(GL_DEPTH_TEST);
      glColor4fv(@mclWhite);
    end;
    glBlendFunc(GL_ZERO, GL_SRC_COLOR);
    glScalef(2.0, 2.0, 2.0);
    glTranslatef(-0.5, 0.02, -0.5);
    glRotatef(90.0, 1.0, 0, 0);

    glColor3fv(@mclWhite);
    glBindTexture(GL_TEXTURE_2D, TexShadow);
    glCallList(3);
  glPopMatrix;
end;

{ Erase saved data }
procedure TFMain.EraseSave;
begin
  MotryaTimer := 1.0;
  Motrya := 2;
  Save := 0;

  defKey := TRegistry.Create;
  defKey.OpenKey(RegPath, True);

  defKey.DeleteValue(RegLayer);
  defKey.DeleteValue(RegCompass);
  defKey.DeleteValue(RegGlyphs);    
  defKey.DeleteValue(RegFloor);
  defKey.DeleteValue(RegWall);
  defKey.DeleteValue(RegRoof);  
  defKey.DeleteValue(RegMazeW);
  defKey.DeleteValue(RegMazeH);

  defKey.Free
end;

{ Erase current progress save data }
procedure TFMain.EraseTempSave;
begin
  defKey := TRegistry.Create;
  defKey.OpenKey(RegPath, True);
  defKey.DeleteValue(RegCurLayer);
  defKey.DeleteValue(RegCurWidth);
  defKey.DeleteValue(RegCurHeight);
  defKey.Free;
end;

{ Set all states to 0, stop sounds and do the final touches }
procedure TFMain.FinishMazeGeneration;
var
  i, j, k: LongWord;
  PosX, PosY, PoolX, PoolY: LongWord;
begin
  MazeDoorPos[0] := -((MazeWM1 - 1.0) * 2.0 + 1.0); 
  MazeDoorPos[1] := -((MazeHM1 - 1.0) * 2.0 + 1.0);
  Print(MazeDoorPos[0], #32, MazeDoorPos[1]);

  Inc(MazeLevel);
  Str(MazeLevel, MazeLevelStr);

  Checkpoint := 0;
  doorSlam := 0;
  EBD := 0;
  GlyphsInLayer := 0;
  hbd := 0;
  kubale := 0;
  MazeCrevice := 0;
  MazeGlyphs := 0;
  MazeLocked := 0;
  MazeNote := 0;
  MazeTeleport := 0;
  MazeTram := 0;
  Map := 0;
  Save := 0;
  Shop := 0;
  Shn := 0;
  Vebra := 0;
  virdya := 0;
  vignetteRed := 0;
  WB := 0;
  wmblyk := 0;
  wmblykStealthy := 0;
  WmblykTram := False;

  if (WBBK <> 0) then begin
    WBBK := 0;
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @mclDarkGray);
    glLightf(GL_LIGHT0, GL_CONSTANT_ATTENUATION, 1.0);      
    glLightf(GL_LIGHT0, GL_QUADRATIC_ATTENUATION, 0);

    alSourceStop(SndAmbT);
    alSourcef(SndAmbT, AL_PITCH, 1.0);
    alSourcePlay(SndAmb);
    alSourcef(SndStep[0], AL_PITCH, 1.0);   
    alSourcef(SndStep[1], AL_PITCH, 1.0);  
    alSourcef(SndStep[2], AL_PITCH, 1.0);   
    alSourcef(SndStep[3], AL_PITCH, 1.0);

    alSourcef(SndDistress, AL_PITCH, 1.0);
  end;

  alSourceStop(SndAlarm);
  alSourceStop(SndEBD);
  alSourceStop(SndEBDA);
  alSourceStop(SndHbd);
  alSourceStop(SndKubale);
  alSourceStop(SndKubaleV);  
  alSourceStop(SndVirdya);     
  alSourceStop(SndTram);       
  alSourceStop(SndWBBK); 
  alSourceStop(SndWhisper);   
  alSourceStop(SndWmblykB);

  GlyphOffset := (Glyphs - 7) * (-4);

  if (MazeLevel > 22) then
    if (Random(12) = 0) then
      SpawnTrench;

  if (MazeSize > 64) then
    if (Random(20) = 0) then begin
      PoolX := Round(MazeWM1 * 0.33);
      PoolY := Round(MazeHM1 * 0.33);
      PosX := PoolX + PoolX;
      PosY := PoolY + PoolY;
      for i:=PoolY to PosY - 1 do
        for j:=PoolX to PosX - 1 do begin
          k := GetOffset(j, i);
          Maze[k] := Maze[k] or MZC_PASSTOP;   
          Maze[k] := Maze[k] or MZC_PASSLEFT;
        end;
    end;

  defKey := TRegistry.Create;
  defKey.OpenKey(RegPath, True);
  defKey.WriteInteger(RegCurLayer, MazeLevel);  
  defKey.WriteInteger(RegCurWidth, MazeW);
  defKey.WriteInteger(RegCurHeight, MazeH);
  defKey.Free;

  if (Trench = 0) then
    SpawnMazeElements;
end;

{ WM_CREATE }
procedure TFMain.FormCreate(Sender: TObject);
begin            
  DefaultFormatSettings.DecimalSeparator := '.';
  Randomize;

  InitContext;
  CreateModels;
  Print('Finished initializing');
  InitAudio;
  LoadGame;
  Application.OnDeactivate := @FormDeactivate;
  GLC.Cursor := crNone;

  { BorderSize := LCLIntf.GetSystemMetrics(32);
  CaptionSize := LCLIntf.GetSystemMetrics(4); }
end;

{ WM_KILLFOCUS }
procedure TFMain.FormDeactivate(Sender: TObject);
begin
  mFocused := False;
end;

{ WM_DESTROY }
procedure TFMain.FormDestroy(Sender: TObject);
begin
  Halt;
end;

{ WM_KEYDOWN }
procedure TFMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  MKeyPress(Key, True);
end;

{ WM_KEYUP }
procedure TFMain.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  MKeyPress(Key, False);
end;

{ Handle window resize }
procedure TFMain.FormResize(Sender: TObject);
begin
  GetWindowCenter;
  Print('Resolution changed to: ', Width, 'x', Height);
  { screenSize[0] := Width;
  screenSize[1] := Height; }

  glViewport(0, 0, Width, Height);
  camAspect := Width / Height;

  if (not GetIniSettingsOnFirstFrame) then begin
    GetIniSettingsOnFirstFrame := True;
    FSettings.GetSettings;
  end;
end;

{ Free maze data from memory (SetLength truly frees only with cmem) }
procedure TFMain.FreeMaze;
begin
  SetLength(Maze, 0);
  MazeSize := 0;
  MazeSizeM1 := 0;
  Print('Freed maze');
end;

{ Generates the maze and spawns maze elements with other procedures }
procedure TFMain.GenerateMaze(const Seed: LongWord);
var
  PosX, PosY: LongWord;
  i: LongWord;
  dwStack: THeapStack;
  ByteChosen, PoolI, Misc: Byte;
begin
  Print('Generating maze with size ', MazeW, #32, MazeH, #9, MazeSize);
  Print('Seed: ', Seed);

  alSourceStop(SndDrip);
  alSourceStop(SndWhisper);
  alSourceStop(SndWmblykB);

  MazeSize := MazeW * MazeH;

  MazeWM1 := MazeW - 1;
  MazeHM1 := MazeH - 1;
  MazeSizeM1 := MazeW * MazeHM1;

  SetLength(Maze, MazeSize); { Create array }

  for i:=0 to MazeSize - 1 do { Clear all cells }
    Maze[i] := 0;

  i := Random(10);
  if (i > 2) then
    MazeType := 0
  else begin
    MazeType := i;
    Print('Maze type is: ', MazeType);
  end;

  RandSeed := Seed;
  PosX := Random(MazeWM1);
  PosY := Random(MazeHM1);

  if (MazeLevel = 0) then begin
    PosX := 0;
    PosY := 0;
  end;
  Print('Random position ', PosX, #32, PosY);

  dwStack := THeapStack.Create(MazeSize * 2);

  while True do begin
    repeat
      MazePool := 0; { Create pool, in which we'll add possible ways }

      if (PosY > 0) then begin { 0, -1 }
        if (not GetCellMZC(PosX, PosY - 1, MZC_VISITED)) then
          MazePool := MazePool + $00000001; { [0, -1] }
      end;   
      if (PosX > 0) then begin { -1, 0 }
        if (not GetCellMZC(PosX - 1, PosY, MZC_VISITED)) then
          MazePool := MazePool + $00000100; { [-1, 0] }
      end;
      if (PosY < (MazeHM1 - 1)) then begin { 0, 1 }
        if (not GetCellMZC(PosX, PosY + 1, MZC_VISITED)) then
          MazePool := MazePool + $00010000; { [0, 1] }
      end;      
      if (PosX < (MazeWM1 - 1)) then begin { 1, 0 }
        if (not GetCellMZC(PosX + 1, PosY, MZC_VISITED)) then
          MazePool := MazePool + $01000000; { [1, 0] }
      end;

      if ((MazeLevel = 0) and (PosX = 0) and (PosY = 0)) then
        MazePool := $010000000;

      {Print('Pos: ', PosX, #32, PosY, ', MazePool is ', IntToHex(MazePool, 8));}

      if (MazePool = 0) then begin { No direction to draw from }
        {Print('No direction, MazePool is ', MazePool);}
        if (dwStack.BufferIndex = 0) then begin { This is the end, the bitter, bitter end }
          Print('Back to start');

          dwStack.Destroy;
          FinishMazeGeneration;
          Exit;
        end;

        PosY := dwStack.Pop; { Continue our journey }
        PosX := dwStack.Pop;
      end;
    until (MazePool <> 0);

    PoolI := 248; { -8 }
    ByteChosen := 0; { Pool index = random(Pool.Length) }
    while (ByteChosen = 0) do begin
      if (MazeType = 1) then
        PoolI := PoolI + 8
      else
        PoolI := Random(4) * 8; { Random shift amount }

      ByteChosen := (MazePool >> PoolI) and $FF;

      if (ByteChosen = 0) then Continue;

      i := GetOffset(PosX, PosY); { Maze[x, y].Visited = True }
      Maze[i] := Maze[i] or MZC_VISITED;

      { Offset (Pool[Pool index]) }
      case PoolI of
        0: begin { [0, -1] }
          Maze[i] := Maze[i] or MZC_PASSTOP;
          Dec(PosY);
          {Print('Going up');}
        end;   
        8: begin { [-1, 0] }
          Maze[i] := Maze[i] or MZC_PASSLEFT;
          Dec(PosX);     
          {Print('Going left');}
        end;      
        16: begin { [0, 1] }
          Inc(PosY);
          i := GetOffset(PosX, PosY);
          Maze[i] := Maze[i] or MZC_PASSTOP;   
          {Print('Going down');}
        end;
        else begin { [1, 0] }
          Inc(PosX);
          i := GetOffset(PosX, PosY);
          Maze[i] := Maze[i] or MZC_PASSLEFT;          
          {Print('Going right');}
        end;
      end;
                
      i := GetOffset(PosX, PosY);
      if (MazeType = 2) then { Maze[x, y].Visited = True }
        Misc := Random(10)
      else
        Misc := 0;
      if (Misc = 0) then begin
        Maze[i] := Maze[i] or MZC_VISITED;
      end;

      if (Random(32) = 0) then { Misc }
        Maze[i] := Maze[i] or MZC_LAMP;     
      if (Random(30) = 0) then
        Maze[i] := Maze[i] or MZC_PIPE;
      if (Random(29) = 0) then
        Maze[i] := Maze[i] or MZC_WIRES;

      if ((Random(33) = 0) or ((MazeLevel = 0) and (PosX = 1) and (PosY = 0))) then
        Maze[i] := Maze[i] or MZC_TABURETKA;

      if (Random(2) <> 0) then
        Maze[i] := Maze[i] or MZC_ROTATED;

      dwStack.Push(PosX);
      dwStack.Push(PosY);
    end;
  end;
end;

{ Bitwise AND maze cell with maze constant (MZC) }
function TFMain.GetCellMZC(const X, Y: LongWord; const MZC: Byte): Boolean;
begin
  Result := (Maze[GetOffset(X, Y)] and MZC) <> 0;
end;

{ Calculate deltaTime }
procedure TFMain.GetDelta;
var
  diff, tick: LongWord;
begin
  tick := GetTickCount64;
  diff := tick - lastTime;

  if (diff = 0) or (lastTime = 0) then begin
    lastTime := tick;
    Exit;
  end;

  if (mMenu = 0) and (MazeNote < 16) then
    deltaTime := diff / 1000.0
  else
    deltaTime := 0;
  if (debugF) then
    deltaTime := deltaTime * 4.0;

  delta2 := deltaTime * 2.0;
  delta20 := delta2 * 10.0;

  lastTime := tick;
end;

{ Get maze cell position from world position }
procedure TFMain.GetMazeCellPos(const PosX, PosY: Single;
  const PosXPtr, PosYPtr: PLongWord);
begin
  PosXPtr^ := Trunc(PosX * 0.5);
  PosYPtr^ := Trunc(PosY * 0.5);
end;

{ Get the pointer offset for use in 2D array (maze) and return to EAX }
function TFMain.GetOffset(const PosX, PosY: LongWord): LongWord;
var
  TestX, TestY: LongWord;
begin
  TestX := PosX;
  if (TestX > 2147483647) then
    TestX := 0
  else if (TestX > MazeWM1) then
    TestX := MazeWM1;

  TestY := PosY;
  if (TestY > 2147483647) then
    TestY := 0
  else if (TestY > MazeHM1) then
    TestY := MazeHM1;

  Result := TestY * MazeW + TestX
end;

{ Get the position from pointer offset, return X to EDX, Y to EAX }
procedure TFMain.GetPosition(const PosOffset: LongWord; const XPtr, YPtr: PLongWord);
begin
  YPtr^ := PosOffset div MazeW;
  XPtr^ := PosOffset mod MazeW;
end;

{ Get random position in maze (float) for items }
procedure TFMain.GetRandomMazePosition(const XPtr, YPtr: PSingle);
var
  XPos, YPos: LongWord;
begin
  XPos := (Random(MazeWM1 - 2) + 1) * 2 + 1;
  YPos := (Random(MazeHM1 - 2) + 1) * 2 + 1;

  if (MazeCrevice <> 0) then begin
    if (((MazeCrevicePos[0] * 2 + 1) = XPos) and ((MazeCrevicePos[1] * 2 + 1) = YPos)) then begin
      Print('Crevice pos object stuck');
      GetRandomMazePosition(XPtr, YPtr);
      Exit;
    end;
  end;
  if (MazeTram <> 0) then begin
    if ((XPos >= (MazeTramArea[0] * 2 + 1)) and (XPos <= (MazeTramArea[1] * 2 + 1))) then begin
      Print('Tram area object stuck');
      GetRandomMazePosition(XPtr, YPtr);
      Exit;
    end;
  end;

  XPtr^ := XPos;
  YPtr^ := YPos;
end;

{ Get global window center with position }
procedure TFMain.GetWindowCenter;
begin
  winWH := Width div 2;
  winHH := Height div 2;

  winCX := winWH + Left;   
  winCY := winHH + Top;
end;

{ WM_LBUTTONDOWN }
procedure TFMain.OnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ((mMenu = 0) and (not mFocused)) then
    mFocused := True;
  mkeyLMB := 1;
  //JOYSTICK USED
end;

{ Handle mouse movement (pos) }
procedure TFMain.OnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  { Different implementation, as getting border size is platform-dependent }
  mousePos[0] := X;
  mousePos[1] := Y;

  msX := mousePos[0]; 
  msY := mousePos[1];

  if ((not mFocused) or (not canControl)) then
    Exit;
end;

{ WM_LBUTTONUP }
procedure TFMain.OnMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  mkeyLMB := 0;
end;

{ Initialize audio libraries and load sounds }
procedure TFMain.InitAudio;
begin
  AudioDevice := alcOpenDevice(nil);
  if (AudioDevice = nil) then
    ErrorOut('Could not open OpenAL device.');
  AudioContext := alcCreateContext(AudioDevice, nil);
  alcMakeContextCurrent(AudioContext);

  LoadAudio(SFXDir+'alarm.gcs', @SndAlarm);
  LoadAudio(SFXDir+'amb.gcs', @SndAmb);
	LoadAudio(SFXDir+'ambT.gcs', @SndAmbT);
	LoadAudio(SFXDir+'checkpoint.gcs', @SndCheckpoint);
	LoadAudio(SFXDir+'death.gcs', @SndDeath);
	LoadAudio(SFXDir+'dig.gcs', @SndDig);
	LoadAudio(SFXDir+'distress.gcs', @SndDistress);
	LoadAudio(SFXDir+'doorClose.gcs', @SndDoorClose);
	LoadAudio(SFXDir+'drip.gcs', @SndDrip);
	LoadAudio(SFXDir+'ebd.gcs', @SndEBD);
	LoadAudio(SFXDir+'ebdA.gcs', @SndEBDA);
	LoadAudio(SFXDir+'exit.gcs', @SndExit);
	LoadAudio(SFXDir+'exit1.gcs', @SndExit1);
	LoadAudio(SFXDir+'explosion.gcs', @SndExplosion);
	LoadAudio(SFXDir+'hbd.gcs', @SndHbd);
	LoadAudio(SFXDir+'hbdO.gcs', @SndHbdO);
	LoadAudio(SFXDir+'hurt.gcs', @SndHurt);
	LoadAudio(SFXDir+'impact.gcs', @SndImpact);
	LoadAudio(SFXDir+'intro.gcs', @SndIntro);
	LoadAudio(SFXDir+'step-01.gcs', @SndStep[0]);
	LoadAudio(SFXDir+'step-02.gcs', @SndStep[1]);
	LoadAudio(SFXDir+'step-03.gcs', @SndStep[2]);
	LoadAudio(SFXDir+'step-04.gcs', @SndStep[3]);
	LoadAudio(SFXDir+'key.gcs', @SndKey);
	LoadAudio(SFXDir+'kubale.gcs', @SndKubale);
	LoadAudio(SFXDir+'kubaleAppear.gcs', @SndKubaleAppear);
	LoadAudio(SFXDir+'kubaleV.gcs', @SndKubaleV);
	LoadAudio(SFXDir+'mistake.gcs', @SndMistake);
	LoadAudio(SFXDir+'rand1.gcs', @SndRand[0]);
	LoadAudio(SFXDir+'rand2.gcs', @SndRand[1]);
	LoadAudio(SFXDir+'rand3.gcs', @SndRand[2]);
	LoadAudio(SFXDir+'rand4.gcs', @SndRand[3]);
	LoadAudio(SFXDir+'rand5.gcs', @SndRand[4]);
	LoadAudio(SFXDir+'rand6.gcs', @SndRand[5]);
	LoadAudio(SFXDir+'save.gcs', @SndSave);
	LoadAudio(SFXDir+'scribble.gcs', @SndScribble);
	LoadAudio(SFXDir+'siren.gcs', @SndSiren);
	LoadAudio(SFXDir+'slam.gcs', @SndSlam);
	LoadAudio(SFXDir+'splash.gcs', @SndSplash);
	LoadAudio(SFXDir+'tram.gcs', @SndTram);
	LoadAudio(SFXDir+'tramAnn1.gcs', @SndTramAnn[0]);
	LoadAudio(SFXDir+'tramAnn2.gcs', @SndTramAnn[1]);
	LoadAudio(SFXDir+'tramAnn3.gcs', @SndTramAnn[2]);
	LoadAudio(SFXDir+'tramClose.gcs', @SndTramClose);
	LoadAudio(SFXDir+'tramOpen.gcs', @SndTramOpen);
	LoadAudio(SFXDir+'virdya.gcs', @SndVirdya);
	LoadAudio(SFXDir+'wbAlarm.gcs', @SndWBAlarm);
	LoadAudio(SFXDir+'wbAttack.gcs', @SndWBAttack);
	LoadAudio(SFXDir+'wbIdle1.gcs', @SndWBIdle[0]);
	LoadAudio(SFXDir+'wbIdle2.gcs', @SndWBIdle[1]);
	LoadAudio(SFXDir+'wbStep-01.gcs', @SndWBStep[0]);
	LoadAudio(SFXDir+'wbStep-02.gcs', @SndWBStep[1]);
	LoadAudio(SFXDir+'wbStep-03.gcs', @SndWBStep[2]);
	LoadAudio(SFXDir+'wbStep-04.gcs', @SndWBStep[3]);
	LoadAudio(SFXDir+'wbbk.gcs', @SndWBBK );
	LoadAudio(SFXDir+'wh.gcs', @SndWhisper);
	LoadAudio(SFXDir+'wmblyk.gcs', @SndWmblyk);
	LoadAudio(SFXDir+'wmblykB.gcs', @SndWmblykB);
	LoadAudio(SFXDir+'wmblykStr.gcs', @SndWmblykStr);
	LoadAudio(SFXDir+'wmblykStrM.gcs', @SndWmblykStrM);

	LoadAudio(SFXDir+'amb1.gcs', @SndAmbW[0]);
	LoadAudio(SFXDir+'amb2.gcs', @SndAmbW[1]);
	LoadAudio(SFXDir+'amb3.gcs', @SndAmbW[2]);
	LoadAudio(SFXDir+'amb4.gcs', @SndAmbW[3]);

  LoadAudio(SFXDir+'mus1.gcs', @SndMus1);
  alSourcef(SndMus1, AL_GAIN, 0.5);        
  LoadAudio(SFXDir+'mus2.gcs', @SndMus2);
  alSourcef(SndMus2, AL_GAIN, 0.5);
  LoadAudio(SFXDir+'mus3.gcs', @SndMus3);
  alSourcef(SndMus3, AL_GAIN, 0);
  alSourcef(SndMus3, AL_LOOPING, AL_True);
  LoadAudio(SFXDir+'mus4.gcs', @SndMus4);
  alSourcef(SndMus4, AL_GAIN, 0);
  alSourcef(SndMus4, AL_LOOPING, AL_True); 
  LoadAudio(SFXDir+'mus5.gcs', @SndMus5);
  alSourcef(SndMus5, AL_GAIN, 0.5);

  alSourcei(SndAlarm, AL_LOOPING, AL_True);
	alSourcei(SndAmb, AL_LOOPING, AL_True);
	alSourcei(SndAmbT, AL_LOOPING, AL_True);
	alSourcei(SndEBD, AL_LOOPING, AL_True);
	alSourcef(SndEBD, AL_ROLLOFF_FACTOR, 4.0);
	alSourcei(SndEBDA, AL_LOOPING, AL_True);
	alSourcei(SndDrip, AL_LOOPING, AL_True);
	alSourcef(SndDrip, AL_ROLLOFF_FACTOR, 2.0);
	alSourcei(SndHbd, AL_LOOPING, AL_True);
	alSourcef(SndHbd, AL_ROLLOFF_FACTOR, 3.0);
	alSourcei(SndKubale, AL_LOOPING, AL_True);
	alSourcef(SndKubale, AL_GAIN, 0);
	alSourcef(SndKubaleAppear, AL_ROLLOFF_FACTOR, 2.0);
	alSourcei(SndKubaleV, AL_LOOPING, AL_True);
	alSourcef(SndKubaleV, AL_GAIN, 0);
	alSourcei(SndSiren, AL_LOOPING, AL_True);
	alSourcef(SndSiren, AL_GAIN, 0);
	alSource3f(SndSlam, AL_POSITION, 1.0, 1.0, 0);
	alSourcei(SndTram, AL_LOOPING, AL_True);
	alSourcef(SndTram, AL_ROLLOFF_FACTOR, 1.5);
	alSourcef(SndTramClose, AL_ROLLOFF_FACTOR, 1.5);
	alSourcef(SndTramOpen, AL_ROLLOFF_FACTOR, 1.5);
	alSourcef(SndTramAnn[0], AL_ROLLOFF_FACTOR, 3.0);
	alSourcef(SndTramAnn[1], AL_ROLLOFF_FACTOR, 3.0);
	alSourcef(SndTramAnn[2], AL_ROLLOFF_FACTOR, 3.0);
	alSourcef(SndVirdya, AL_GAIN, 0);
	alSourcei(SndVirdya, AL_LOOPING, AL_True);
	alSourcei(SndWBBK, AL_LOOPING, AL_True);
	alSourcef(SndWBBK, AL_ROLLOFF_FACTOR, 10.0);
	alSourcef(SndWBAlarm, AL_ROLLOFF_FACTOR, 1.5);
	alSourcef(SndWBIdle[0], AL_ROLLOFF_FACTOR, 4.0);
	alSourcef(SndWBIdle[1], AL_ROLLOFF_FACTOR, 4.0);
	alSourcef(SndWBStep[0], AL_ROLLOFF_FACTOR, 3.0);
	alSourcef(SndWBStep[1], AL_ROLLOFF_FACTOR, 3.0);
	alSourcef(SndWBStep[2], AL_ROLLOFF_FACTOR, 3.0);
	alSourcef(SndWBStep[3], AL_ROLLOFF_FACTOR, 3.0);
	alSourcei(SndWhisper, AL_LOOPING, AL_True);
	alSourcef(SndWhisper, AL_ROLLOFF_FACTOR, 2.0);
	alSourcei(SndWmblykB, AL_LOOPING, AL_True);
	alSourcef(SndWmblykB, AL_ROLLOFF_FACTOR, 4.0);
	alSourcei(SndWmblykStrM, AL_LOOPING, AL_True);
	alSourcef(SndWmblykStrM, AL_GAIN, 0);

  Print(alGetError);

  alSourcePlay(SndIntro);  
  Print(alGetError);
end;

{ Initialize OpenGL context }
procedure TFMain.InitContext;
begin
  GLC := TOpenGLControl.Create(Self);
  GLC.Parent := Self;
  GLC.Align := alClient;
  GLC.OnPaint := @Render;   
  GLC.OnMouseDown := @OnMouseDown;  
  GLC.OnMouseUp := @OnMouseUp;
  GLC.OnMouseMove := @OnMouseMove;
  GLC.MakeCurrent;
  GLC.Invalidate;
  if (UseTimerForRenderLoop) then begin
    RenderTimer := TTimer.Create(Self);
    RenderTimer.Interval := RenderLoopTimerInterval;
    RenderTimer.OnTimer := @TimerRender;
  end else
    Application.OnIdle := @RenderLoop;

  glEnable(GL_CULL_FACE); { Scene initialization }
	glShadeModel(GL_SMOOTH);
	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);

	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glLightfv(GL_LIGHT0, GL_SPECULAR, @mclGray);
	glLightf(GL_LIGHT0, GL_CONSTANT_ATTENUATION, 1.0);

	glEnable(GL_FOG);
	glEnable(GL_TEXTURE_2D);

	glMaterialf(GL_FRONT, GL_SHININESS, 64.0);
	glMaterialfv(GL_FRONT, GL_SPECULAR, @mclGray);
end;

{ Process Kubale AI }
procedure TFMain.KubaleAI;
var
  distance, lookAt: Single;
  dotX, dotY, dotProduct: Single;
  teleportAttempts: Byte;
begin
  if (playerState <> 0) then begin
    Lerp(@kubaleRun, 0, delta20);
    Lerp(@kubaleVision, 0, delta2);
    if (kubaleVision < 0.01) then
      kubaleVision := 0;
    alSourcef(SndKubaleV, AL_GAIN, kubaleVision);
    alSourcef(SndKubale, AL_GAIN, kubaleRun);
    Exit;
  end;

  distance := DistanceToSqr(kubalePos[0], kubalePos[1],
    camPosNext[0], camPosNext[2]);

  if (distance > 1000.0) then begin
    teleportAttempts := 0;
    repeat
      Print('TELEPORTING');
      GetRandomMazePosition(@kubalePos[0], @kubalePos[1]);

      Inc(teleportAttempts);

      distance := DistanceToSqr(kubalePos[0], kubalePos[1],
        camPosNext[0], camPosNext[2]);
    until ((distance > 32.0) or (teleportAttempts > 8));
    Exit;
  end;

  if (distance < 0.33) then begin
    camCurSpeed[0] := -camCurSpeed[0];
    camCurSpeed[2] := -camCurSpeed[2];
  end;

  dotX := camPosN[0] - kubalePos[0];
  dotY := camPosN[1] - kubalePos[1];

  Normalize(@dotX, @dotY);
  dotProduct := dotX * camForward[0] + dotY * camForward[2];

  if (dotProduct < 0.33) then begin { If not visible }
    lookAt := GetDirection(kubalePos[0], kubalePos[1], camPosN[0], camPosN[1]);

    kubaleDir := lookAt * R2D;

    if (distance > 0.7) then begin
      dotProduct := deltaTime * distance * 1.5 + delta2; { Get speed to move }

      kubaleSpeed[0] := Sin(lookAt) * dotProduct;
      kubaleSpeed[1] := Cos(lookAt) * dotProduct;

      MoveAndCollide(@kubalePos[0], @kubalePos[1],
        @kubaleSpeed[0], @kubaleSpeed[1], 0.2, True);

      kubale := Random(4) + 29;

      Lerp(@kubaleRun, 1.0, delta20);
    end else
      Lerp(@kubaleRun, 0, delta20);

    if (distance < 2.0) then begin
      Lerp(@kubaleVision, 1.0, delta2);
      Lerp(@vignetteRed, 1.0, deltaTime);
      fade := deltaTime + fade;
      if (fade > 1.0) then
        playerState := 9;
    end else begin
      Lerp(@kubaleVision, 0, delta2);
      if (kubaleVision < 0.01) then
        kubaleVision := 0;
      if (virdyaSound = 0) then begin
        Lerp(@vignetteRed, 0, deltaTime);
        Lerp(@fade, 0, deltaTime);
      end;
    end;
  end else begin
    Lerp(@kubaleVision, 0, delta2);
    if (kubaleVision < 0.01) then
      kubaleVision := 0;
    Lerp(@kubaleRun, 0, delta20);
    if (virdyaSound = 0) then begin
      Lerp(@vignetteRed, 0, deltaTime);
      Lerp(@fade, 0, deltaTime);
    end;
  end;

  alSourcef(SndKubaleV, AL_GAIN, kubaleVision);
  alSourcef(SndKubale, AL_GAIN, kubaleRun);
  alSource3f(SndKubale, AL_POSITION, kubalePos[0], 0, kubalePos[1]);

  if (distance < 75.0) then
    DrawKubale;

end;

{ Kubale light flicker appearance }
procedure TFMain.KubaleEvent;
begin
  kubaleDir := kubaleDir - deltaTime;

  case kubale of
    2: fogDensity := Random(6) * 0.1 + 0.5; { Flickering }
    3: Lerp(@fogDensity, 12.0, delta20); { Going dark }
  end;

  if ((kubaleDir < 0.0) and (playerState = 0)) then
    case kubale of
      1: begin { Waited }
        alSourcePlay(SndKubaleAppear);
        kubaleDir := 1.0;
        kubale := 2;
      end;
      2: begin { Flickered }
        kubaleDir := 2.0;
        kubale := 3;
      end;
      3: begin { Waited in darkness }
        fade := 1.0;
        fadeState := 1;
        MakeKubale;
      end;
    end;
end;

{ Check if the game was saved and load it }
procedure TFMain.LoadGame;
begin
  defKey := TRegistry.Create;
  if (not defKey.OpenKey(RegPath, True)) then begin
    Print('Failed to create registry key.');   
    defKey.Free;
    Exit;
  end;
  if (defKey.ValueExists(RegComplete)) then
    defKey.ReadBinaryData(RegComplete, Complete, 1);
  if (defKey.ValueExists(RegCurLayer)) then begin { Load temporary progress }
    MazeLevel := defKey.ReadInteger(RegCurLayer);
    MazeW := defKey.ReadInteger(RegCurWidth);
    MazeH := defKey.ReadInteger(RegCurHeight);

    defKey.Free;

    ShowSubtitles(CCLoad);
    alSourcePlay(SndDistress);
    alSourcePlay(SndAmb);

    Dec(MazeLevel);

    if ((Random(5) = 0) and (MazeLevel > 1)) then
      Dec(MazeLevel);
    MazeHostile := 1;

    MazeSeed := GetTickCount64;
    GenerateMaze(MazeSeed); { This reopens and closes the registry }

    GetRandomMazePosition(@camPosN[0], @camPosN[1]);
    camPosNext[0] := camPosN[0];
    camPosL[0] := -camPosN[0];
    camPos[0] := camPosL[0];
    camPosNext[2] := camPosN[1];
    camPosL[2] := -camPosN[1];
    camPos[2] := camPosL[2];
  end else begin { Load from checkpoint }
    if (not defKey.ValueExists(RegLayer)) then begin
      Print('Failed to read layer value (DWORD).');
      Print(MazeLevel);
      Exit;
    end;

    MazeLevel := defKey.ReadInteger(RegLayer);
    CurrentFloor := defKey.ReadInteger(RegFloor);
    CurrentWall := defKey.ReadInteger(RegWall);
    CurrentRoof := defKey.ReadInteger(RegRoof);
    MazeW := defKey.ReadInteger(RegMazeW);
    MazeH := defKey.ReadInteger(RegMazeH);

    defKey.Free;

    alSourcePlay(SndMus3);
    Checkpoint := 3;
    Save := 1;
    MazeHostile := 1;

    camPos[0] := -1.0;
    camPosL[0] := -1.0;
    camPos[2] := -3.0;

    MazeDoorPos[0] := -1.0;
    MazeDoorPos[1] := -5.0;
  end;

  defKey := TRegistry.Create;
  defKey.OpenKey(RegPath, True);
  if (defKey.ValueExists(RegCompass)) then
    defKey.ReadBinaryData(RegCompass, Compass, 1);
  if (defKey.ValueExists(RegGlyphs)) then
    defKey.ReadBinaryData(RegGlyphs, Glyphs, 1);
  defKey.Free;

  Mouse.CursorPos := TPoint.Create(winCX, winCY);
  camRot[0] := 0;
  Str(MazeLevel, MazeLevelStr);
  MazeLevelPopupTimer := 2.0;
  MazeLevelPopup := 1;

  alSourceStop(SndIntro);
  playerState := 2;
  fadeState := 1;
end;

{ Spawn Kubale into the layer with random position }
procedure TFMain.MakeKubale;
begin
  kubale := 29;

  alSourcePlay(SndKubale);
  alSourcePlay(SndKubaleV);

  GetRandomMazePosition(@kubalePos[0], @kubalePos[1]);
end;

{ Turn Wmblyk into his stealthy state }
procedure TFMain.MakeWmblykStealthy;
begin
  Print('Wmblyk is stealthy');

  wmblykStealthy := 1;
  wmblykBlink := Random(7) + 4;
  wmblyk := 8;
end;

{ Handle key press (key down, key up) }
procedure TFMain.MKeyPress(const Key: Word; const State: Boolean);
begin
  case Key of
    87: mkeyUp := State;    { W }
    83: mkeyDown := State;  { S }
    65: mkeyLeft := State;  { A }
    68: mkeyRight := State; { D }
    17: mkeyCtrl := State;  { Ctrl }
    13: begin { Enter, confirm different things }
      if (Shop = 2) then
        if (Glyphs >= 5) then begin
          Glyphs := Glyphs - 5;
          Shop := 3;
          alSourcePlay(SndHbd);
          AlertWB(3);
          alSource3f(SndDig, AL_POSITION, -1.0, 0.0, 1.0);
          alSourcePlay(SndDig);
          alSourcePlay(SndMistake);
          ShopKoluplyk := 80;
          ShopTimer := 0;
          ShopWall := 3.0;
          Map := 1;
          if (Glyphs = 0) then
            ShowSubtitles(CCGlyphNone)
          else
            ShowSubtitles(CCShopBuy);
        end else
          ShowSubtitles(CCShopNo);
      if (not State) then
        if (MazeTramPlr = 1) then
          MazeTramPlr := 2
        else if (MazeTramPlr = 3) then begin
          MazeTramPlr := 0;
          camPos[0] := camPos[0] - Cos(MazeTramRotS) * 2.0;
          camPos[1] := flCamHeight;
        end;
      if (Checkpoint = 4) then begin
        canControl := False;
        playerState := 3;
        alSourcePlay(SndExit);
        Checkpoint := 3;
      end;
      if (Save = 2) then begin
        alSourcePlay(SndDistress);
        EraseSave;
      end;
    end;
    27: begin { Escape, skip intro and use menu }
      if ((playerState >= 11) and (playerState <= 17) and (MazeHostile <> 11)) then begin
        alSourceStop(SndIntro);
        alSourcePlay(SndSiren);
        MazeHostile := 0;
        playerState := 1;
        GenerateMaze(GetTickCount64);
        Exit;
      end;
      if (State) then begin
        if (MazeNote > 16) then begin
          MazeNote := 0;
          canControl := True;
          Exit;
        end;
        DoMenu;
      end;
    end;
    115: if (not State) then begin { F4, toggle fullscreen }
      fullscreen := not fullscreen;
      SetFullscreen(fullscreen);
    end;
    32: if (mkeySpace <> State) and (mMenu = 0) then begin { Space, fight Wmblyk }
      mkeySpace := State;
      if ((State) and (playerState <> 9) and (playerState <> 10)) then
        wmblykStr := 0.4 / Sqrt(MazeLevel) + wmblykStr;
    end;
    71: if ((State) and (canControl) and (Length(Maze) <> 0)
    and (MazeTramPlr < 2)) then begin { G, place glyph }
      if (Glyphs <> 0) then begin
        Dec(Glyphs);
        GlyphPos[GlyphsInLayer * 2] := camPosN[0];
        GlyphPos[GlyphsInLayer * 2 + 1] := camPosN[1];

        GlyphRot[GlyphsInLayer] := Random(360);

        Inc(GlyphsInLayer);
        alSourcePlay(SndScribble);
        AlertWB(2);
        if (Glyphs = 0) then
          alSourcePlay(SndMistake);
      end;
      if (Glyphs = 0) then
        ShowSubtitles(CCGlyphNone)
      else begin
        CCGlyph[15] := Chr(Glyphs + 48);
        ShowSubtitles(CCGlyph);
      end;
    end;
    {$IFDEF DEBUG}
    { DEBUG BININGS FOR TESTING }
    70: if (debugF <> State) then begin
      debugF := State;
      if (debugF) then begin
        alSourcef(SndAlarm, AL_PITCH, 4.0); 
        alSourcef(SndAmb, AL_PITCH, 4.0);    
        alSourcef(SndExplosion, AL_PITCH, 4.0);      
        alSourcef(SndExit, AL_PITCH, 4.0);
        alSourcef(SndImpact, AL_PITCH, 4.0);      
        alSourcef(SndIntro, AL_PITCH, 4.0);     
        alSourcef(SndKubaleAppear, AL_PITCH, 4.0);  
        alSourcef(SndMus1, AL_PITCH, 4.0);
        alSourcef(SndMus5, AL_PITCH, 4.0);     
        alSourcef(SndSiren, AL_PITCH, 4.0);
      end else begin
        alSourcef(SndAlarm, AL_PITCH, 1.0);
        alSourcef(SndAmb, AL_PITCH, 1.0);
        alSourcef(SndExplosion, AL_PITCH, 1.0);
        alSourcef(SndExit, AL_PITCH, 1.0);
        alSourcef(SndImpact, AL_PITCH, 1.0);
        alSourcef(SndIntro, AL_PITCH, 1.0);
        alSourcef(SndKubaleAppear, AL_PITCH, 1.0);
        alSourcef(SndMus1, AL_PITCH, 1.0);
        alSourcef(SndMus5, AL_PITCH, 1.0);
        alSourcef(SndSiren, AL_PITCH, 1.0);
      end;
    end;
    69: if (not State) then begin
      Print('Spawned Eblodryn');
      EBD := 1;
      GetRandomMazePosition(@EBDPos[0], @EBDPos[1]);
      alSource3f(SndEBD, AL_POSITION, EBDPos[0], 0, EBDPos[1]);
      alSourcef(SndEBDA, AL_GAIN, 0);
      alSourcePlay(SndEBD);
      alSourcePlay(SndEBDA);
    end;
    84: if (not State) then begin
      camPos[0] := MazeDoorPos[0];
      camPos[2] := MazeDoorPos[1]; 
    end;
    75: if (not State) then begin
      kubaleDir := 1.0;
      kubale := 1;
    end;
    219: if (not State) then Inc(MazeW);
    221: if (not State) then Inc(MazeH);
    220: if (not State) then WBCreate;
    117: if (not State) then SaveGame;
    89: if (not State) then begin
      if (wmblyk = 0) then begin
        wmblykPos[0] := 1.0;
        wmblykPos[1] := 1.0;
      end;
      wmblyk := 11;
      alSourcePlay(SndWmblykB);
      wmblykAnim := 11;
      wmblykBlink := 0;      
    end;
    66: if (not State) then Glyphs := 7;
    78: if (not State) then begin
      hbd := 0;
      kubale := 0;
      wmblyk := 0;
    end;
    67: if (not State) then begin
      Compass := 2;
      MazeLocked := 2;
    end;
    73: if (not State) then begin
      alSourceStop(SndSiren);
      alSourcePlay(SndAmb);
      MazeHostile := 1;
    end;
    88: if (not State) then begin
      camPos[0] := -1.0;
      camPos[2] := -1.0;
    end;
    90: if (not State) then begin
      Inc(MazeLevel);
      Print(MazeLevel);    
    end;
    190: if (not State) then begin
      MazeLevel := MazeLevel + 5;
      Print(MazeLevel);
    end;   
    188: if (not State) then begin
      MazeLevel := MazeLevel - 5;
      Print(MazeLevel);
    end;
    86: if (not State) then begin
      virdyaPos[0] := camPosN[0];
      virdyaPos[1] := camPosN[1];
      virdya := 67;
      alSourcePlay(SndVirdya);
      Vebra := 133;
    end;
    {$ENDIF}
  end;
end;

{ A unified collision algorithm for multiple entities }
function TFMain.MoveAndCollide(const PosXPtr, PosYPtr,
  SpeedXPtr, SpeedYPtr: PSingle; const WallSize: Single;
  const Bounce: Boolean): Boolean;
var
  SpdXF, SpdYF, NextPosX, NextPosY, DistanceX, DistanceY: Single;
  MazePosX, MazePosY: LongWord;
  CellCntX, CellCntY: Single;
  ColX, ColY: Boolean;
begin
  SpdXF := SpeedXPtr^;
  SpdYF := SpeedYPtr^;

  NextPosX := PosXPtr^ - SpdXF; { Get next position }
  NextPosY := PosYPtr^ - SpdYF;

  { Collide with maze (janky, but that's a feature) }
  GetMazeCellPos(NextPosX, NextPosY, @MazePosX, @MazePosY);

  CellCntX := MazePosX * 2.0 + 1.0; { Get maze cell center }
  CellCntY := MazePosY * 2.0 + 1.0;

  Result := False;

  { Spaghetti }
  CellCntX := NextPosX - CellCntX; { Get distance to cell center and act }
  DistanceX := Abs(CellCntX);  
  CellCntY := NextPosY - CellCntY;
  DistanceY := Abs(CellCntY);

  ColX := False;
  ColY := False;

  if (DistanceX > WallSize) then
    if (CellCntX < 0.0) then begin
      if (not GetCellMZC(MazePosX, MazePosY, MZC_PASSLEFT)) then
        ColX := True { Collides X- }
      else if (not Bounce) then { Check corners }
        if ((DistanceY > WallSize) and (MazePosX > 0)) then
          if ((CellCntY < 0.0) and (MazePosY > 0)) then begin
            if (not GetCellMZC(MazePosX, MazePosY - 1, MZC_PASSLEFT)) then
              ColY := True; { Collides Y- left }
          end else if (MazePosY < MazeHM1) then begin
            if (not GetCellMZC(MazePosX, MazePosY + 1, MZC_PASSLEFT)) then
              ColY := True; { Collides Y+ left }
          end;
    end else begin
      Inc(MazePosX);
      if (not GetCellMZC(MazePosX, MazePosY, MZC_PASSLEFT)) then
        ColX := True { Collides X+ }
      else if (not Bounce) then { Check corners }
        if ((DistanceY > WallSize) and (MazePosX < MazeWM1)) then
          if ((CellCntY < 0.0) and (MazePosY > 0)) then begin
            if (not GetCellMZC(MazePosX, MazePosY - 1, MZC_PASSLEFT)) then
              ColY := True; { Collides Y- left }
          end else if (MazePosY < MazeHM1) then begin
            if (not GetCellMZC(MazePosX, MazePosY + 1, MZC_PASSLEFT)) then
              ColY := True; { Collides Y+ left }
          end;
      Dec(MazePosX);
    end;

  if (DistanceY > WallSize) then
    if (CellCntY < 0.0) then begin
      if (not GetCellMZC(MazePosX, MazePosY, MZC_PASSTOP)) then
        ColY := True { Collides Y- }
      else if (not Bounce) then { Check corners }
        if ((DistanceX > WallSize) and (MazePosY > 0)) then
          if ((CellCntX < 0.0) and (MazePosX > 0)) then begin
            if (not GetCellMZC(MazePosX - 1, MazePosY, MZC_PASSTOP)) then
              ColX := True; { Collides X- left }
          end else if (MazePosX < MazeWM1) then begin
            if (not GetCellMZC(MazePosX + 1, MazePosY, MZC_PASSTOP)) then
              ColX := True; { Collides X+ left }
          end;
    end else begin
      Inc(MazePosY);
      if (not GetCellMZC(MazePosX, MazePosY, MZC_PASSTOP)) then
        ColY := True { Collides Y+ }
      else if (not Bounce) then { Check corners }
        if ((DistanceX > WallSize) and (MazePosY < MazeHM1)) then
          if ((CellCntX < 0.0) and (MazePosX > 0)) then begin
            if (not GetCellMZC(MazePosX - 1, MazePosY, MZC_PASSTOP)) then
              ColX := True; { Collides X- left }
          end else if (MazePosX < MazeWM1) then begin
            if (not GetCellMZC(MazePosX + 1, MazePosY, MZC_PASSTOP)) then
              ColX := True; { Collides X+ left }
          end;
    end;

  if (MazeCrevice <> 0) then
    if ((not ColX) and (not ColY)) then begin
      CellCntX := MazeCrevicePos[0] * 2.0;
      DistanceX := CellCntX - WallSize;
      CellCntY := MAzeCrevicePos[1] * 2.0;
      DistanceY := CellCntY - WallSize;
      CellCntX := CellCntX + flWLn;
      CellCntY := CellCntY + flWLn;
      if (InRange(NextPosX, NextPosY, DistanceX, CellCntX, DistanceY, CellCntY))
      then begin
        ColX := True;
        ColY := True;
      end;
    end;

  if (ColX) then begin
    if (Bounce) then
      SpdXF := -SpdXF
    else
      SpdXF := 0;
    Result := True;
  end;  
  if (ColY) then begin
    if (Bounce) then
      SpdYF := -SpdYF
    else
      SpdYF := 0;
    Result := True;
  end;

  PosXPtr^ := PosXPtr^ - SpdXF;
  PosYPtr^ := PosYPtr^ - SpdYF;
  SpeedXPtr^ := SpdXF;         
  SpeedYPtr^ := SpdYF;
end;

{ Process and draw Shnurpshik }
procedure TFMain.ProcessShn;
var
  teleportAttempts: Byte;
  fltVal: Single;
begin
  ShnTimer := ShnTimer - deltaTime;
  if (ShnTimer < 0.0) then
    case Shn of
      1: begin
        ShowSubtitles(CCShn1);
        ShnTimer := 48.0;
        Shn := 2;
      end;
      2: begin
        ShowSubtitles(CCShn2);
        alSourcef(SndAlarm, AL_GAIN, 0);
        alSourcePlay(SndAlarm);
        ShnTimer := 48.0;
        Shn := 3;
      end;
      3: begin
        ShowSubtitles(CCShn3);
        alSourcef(SndAlarm, AL_GAIN, 1.0);
        alSourcePlay(SndAlarm);
        alSourcePlay(SndWBBK);
        alSourcePlay(SndMistake);
        Shn := 4;
        fade := 1.0;
        Shop := 0;
        hbd := 0;
        alSourceStop(SndHbd);
        kubale := 0;
        alSourceStop(SndKubale);
        virdya := 0;
        wmblyk := 0;
        alSourceStop(SndVirdya);
        if (playerState = 7) then begin
          playerState := 0;
          alSourceStop(SndWmblykB);
          alSourceStop(SndWmblykStrM);
        end;

        teleportAttempts := 0;
        repeat
          GetRandomMazePosition(@ShnPos[0], @ShnPos[1]);

          Inc(teleportAttempts);
        until ((DistanceToSqr(ShnPos[0], ShnPos[1], camPosN[0], camPosN[1])
        > 32.0) or (teleportAttempts > 8)) ;
      end;
    end;

  if (playerState = 0) then begin
    case Shn of
      2: begin
        Lerp(@fogDensity, 0.6, deltaTime * 0.1);
      end;
      3: begin
        alSourcef(SndAlarm, AL_GAIN, (48.0 - ShnTimer) * 0.001);
        Lerp(@fogDensity, 0.75, deltaTime * 0.1);
      end;
      4: begin
        fogDensity := 1;
        Lerp(@fade, 0, deltaTime);
        alSource3f(SndWBBK, AL_POSITION, ShnPos[0], 0, ShnPos[1]);

        fltVal := GetDirection(ShnPos[0], ShnPos[1], camPosN[0], camPosN[1]);

        ShnPos[0] := ShnPos[0] - Sin(fltVal) * deltaTime * 2.0;  
        ShnPos[1] := ShnPos[1] - Cos(fltVal) * deltaTime * 2.0;

        glPushMatrix;
          glTranslatef(ShnPos[0], 0, ShnPos[1]);
          glRotatef(fltVal * R2D, 0, 1.0, 0);
          glBindTexture(GL_TEXTURE_2D, TexVas);
          glCallList(Random(3) + 52);
          glDisable(GL_FOG);
          glDisable(GL_LIGHTING);
          glDisable(GL_CULL_FACE);
          glEnable(GL_BLEND);
          glBlendFunc(GL_DST_COLOR, GL_ZERO);
          glBindTexture(GL_TEXTURE_2D, TexKubaleInkblot[Random(9)]);
          glTranslatef(0.5, 0.5, 0.5);
          glCallList(84);
          glTranslatef(-1.0, 0, 0);
          glScalef(-1.0, 1.0, 1.0);
          glCallList(84);
          glEnable(GL_FOG);
          glEnable(GL_LIGHTING);
          glEnable(GL_CULL_FACE);
          glDisable(GL_BLEND);
        glPopMatrix;

        if (DistanceToSqr(ShnPos[0], ShnPos[1], camPosN[0], camPosN[1]) < 0.5)
        then begin
          alSourcePlay(SndWmblyk);
          Print('Teleported player badly');
          FreeMaze;

          MazeSeed := PMSeed;
          PMW := MazeW;
          PMH := MazeH;
          MazeLevel := MazeLevel - 2;

          GenerateMaze(MazeSeed);
          GetRandomMazePosition(@camPosN[0], @camPosN[1]);
          camPos[0] := -camPosN[0];
          camPosNext[0] := camPos[0];
          camPosL[0] := camPos[0];    
          camPos[2] := -camPosN[1];
          camPosNext[2] := camPos[2];
          camPosL[2] := camPos[2];
          fadeState := 1;
          canControl := True;
          playerState := 0;

          fade := 1.0;
          fadeState := 1;

          MazeLevelPopupTimer := 2.0;
          MazeLevelPopup := 1;
        end;
      end;
    end;
  end;
end;

{ Render frame }
procedure TFMain.Render(Sender: TObject);
var
  camSin, camCos: Single;
  camRotDeg: Single;
  i: LongWord;
begin
  GetDelta;

  glFogf(GL_FOG_DENSITY, fogDensity);

  { Camera control }
  camForward[0] := Sin(camRotL[1]);
  camRight[2] := camForward[0];
  camSin := -camForward[0];
  camForward[2] := Cos(camRotL[1]);
  camRight[0] := -camForward[2];
  camCos := camForward[2];

  alListener3f(AL_POSITION, camPosN[0], 0, camPosN[1]);
  camListener[0] := camForward[0];
  camListener[2] := camForward[2];
  alListenerfv(AL_ORIENTATION, @camListener);

  //TODO JOYSTICK CONTROLS

  if (canControl) then
    Control;

  if (mFocused) then { Mouse lock }
    Mouse.CursorPos := TPoint.Create(winCX, winCY);

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(camFOV, camAspect, 0.01, 100.0);

  glMatrixMode(GL_MODELVIEW);

  DoPlayerState; { Cutscenes, etc }

  case MazeHostile of
    0: begin { Play siren }
      Lerp(@MazeSiren, 1.0 - MazeLevel * 0.1, delta2);
      alSourcef(SndSiren, AL_GAIN, MazeSiren);

      MazeSirenTimer := MazeSirenTimer - deltaTime;
      if (MazeSirenTimer < 0.0) then begin
        MazeHostile := 2;
        MazeSirenTimer := 10.0;
      end;
    end;
    1: begin { Normal gameplay }
      if (playerState = 0) then begin { Random noises }
        MazeRandTimer := MazeRandTimer - deltaTime;

        if (MazeRandTimer < 0.0) then begin
          RandomFloat(@MazeRandTimer, 20);
          MazeRandTimer := MazeRandTimer + 32.0;
          RandomFloat(@MazeRandPos[0], 3);
          RandomFloat(@MazeRandPos[1], 3);
          MazeRandPos[0] := camPosN[0] + MazeRandPos[0];
          MazeRandPos[1] := camPosN[1] + MazeRandPos[1];

          i := Random(6);
          alSource3f(SndRand[i], AL_POSITION, MazeRandPos[0], 2.0, MazeRandPos[1]);
          alSourcePlay(SndRand[i]);
          Print('Playing random noise ', i);
        end;
      end;
    end;
    2: begin { Stop siren }
      Lerp(@MazeSiren, 0, delta2);
      alSourcef(SndSiren, AL_GAIN, MazeSiren);

      MazeSirenTimer := MazeSirenTimer - deltaTime;

      if (MazeSirenTimer < 0.0) then begin
        MazeHostile := 3;
        MazeSirenTimer := MazeLevel * 0.1;

        alSourcef(SndExplosion, AL_GAIN, 1.0 - MazeLevel * 0.01);
        alSourcePlay(SndExplosion);

        alSourceStop(SndSiren);
      end;
    end;
    3: begin { Wait for impact }
      MazeSirenTimer := MazeSirenTimer - deltaTime;

      if (MazeSirenTimer < 0.0) then begin
        MazeHostile := 4;
        MazeSirenTimer := 3.0;

        alSourcef(SndImpact, AL_GAIN, 1.0 - MazeLevel * 0.1);
        alSourcePlay(SndImpact);

        MazeSiren := 0.1 - MazeLevel * 0.01;
      end;
    end;
    4: begin { Shake screen }
      MazeSirenTimer := MazeSirenTimer - deltaTime;

      Lerp(@MazeSiren, 0, delta2);
      Shake(MazeSiren);

      if (MazeSirenTimer < 0.0) then begin
        MazeHostile := 1;
        alSourcePlay(SndAmb);
        if (Random(2) <> 0) then
          alSourcePlay(SndMus2);
      end;
    end;
  end;

  glLoadIdentity;

  if (MazeHostile <> 12) then
    glLightfv(GL_LIGHT0, GL_POSITION, @camLight[0]); { Draw light }

  if (Trench <> 0) then { Slow down if trench }
    camRotDeg := delta2 * 4.0
  else if ((MazeHostile >= 8) and (MazeHostile <= 11)) then { or if ending }
    camRotDeg := delta20 * NoiseOpacity[0]
  else
    camRotDeg := delta20;
  Lerp(@camRotL[0], camRot[0], camRotDeg);
  LerpAngle(@camRotL[1], camRot[1], camRotDeg);

  glRotatef(-camRotL[1] * R2D, 0, 1.0, 0); { Rotate camera }
  glRotatef(camRotL[0] * R2D, camCos, 0, camSin);
  Lerp(@camTilt, 0, delta2);
  glRotatef(camTilt, camSin, 0, camCos);


  glRotatef(Sin(camStepSide), 0, 1.0, 0); { Walk animation }
  glRotatef(Sin(camStep * 2.0) * 0.5, camCos, 0, camSin);

  Lerp(@camPosL[0], camPos[0], delta20);
  Lerp(@camPosL[1], camPos[1], delta20);
  Lerp(@camPosL[2], camPos[2], delta20);

  camPosN[0] := -camPos[0];
  camPosN[1] := -camPos[2];

  glTranslatef(camPosL[0], camPosL[1], camPosL[2]);

  camPosNext[0] := camPosN[0] - camCurSpeed[0]; { Set next pos for collision }
  camPosNext[2] := camPosN[1] - camCurSpeed[2];

  //glDisable(GL_LIGHTING);
  case playerState of { Draw intro scenery }
    12: begin
      glBindTexture(GL_TEXTURE_2D, TexRoof);
      glCallList(40);
      glBindTexture(GL_TEXTURE_2D, TexFacade);
      glCallList(41);
      glBindTexture(GL_TEXTURE_2D, TexFloor);
      glCallList(42);
    end;
    14: begin
      glBindTexture(GL_TEXTURE_2D, TexRoof);
      glCallList(43);
      glBindTexture(GL_TEXTURE_2D, TexFloor);
      glCallList(44);
      glEnable(GL_BLEND);
      glEnable(GL_ALPHA_TEST);
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
      glAlphaFunc(GL_GREATER, 0);
      glBindTexture(GL_TEXTURE_2D, TexTree);
      glCallList(45);
      glDisable(GL_BLEND);
      glDisable(GL_ALPHA_TEST);
      glAlphaFunc(GL_ALWAYS, 0);
    end;
    16: begin
      glBindTexture(GL_TEXTURE_2D, TexDoor);
      glCallList(46);
      glBindTexture(GL_TEXTURE_2D, TexFloor);
      glCallList(44);
      glEnable(GL_BLEND);
      glEnable(GL_ALPHA_TEST);
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
      glAlphaFunc(GL_GREATER, 0);
      glBindTexture(GL_TEXTURE_2D, TexTree);
      glCallList(45);
      glDisable(GL_BLEND);
      glDisable(GL_ALPHA_TEST);
      glAlphaFunc(GL_ALWAYS, 0);
    end;
  end;

  if (Length(Maze) <> 0) then
    DrawMaze; { Draw maze }
  if ((MazeHostile = 6) or (MazeHostile = 7)) then { Ascend }
    DrawAscend;
  if ((MazeHostile >= 8) and (MazeHostile <= 11)) then { Wasteland }
    DrawWasteland;
  if (MazeHostile = 12) then { Croa }
    DrawCroa;
  if (MazeHostile = 13) then { Border }
    DrawBorder;
  if (Checkpoint > 1) then
    DrawCheckpoint(CheckpointPos[0], CheckpointPos[1]);

  if (MazeLevel = 1) then begin
    glPushMatrix;
      glTranslatef(0, 0, 1.9);
      glRotatef(-90.0, 1.0, 0.0, 0.0);
      glEnable(GL_BLEND);
      glDisable(GL_LIGHTING);
      glDisable(GL_FOG);
      glBlendFunc(GL_ZERO, GL_SRC_COLOR);
      glTranslatef(0, 0.01, 0);
      //JOYSTICK USED
      glBindTexture(GL_TEXTURE_2D, TexTutorial);
      glCallList(2);
      glDisable(GL_BLEND);
      glEnable(GL_LIGHTING);
      glEnable(GL_FOG);
    glPopMatrix;
  end;

  if (MazeTram <> 0) then
    DrawTram;

  if (Motrya <> 0) then
    DrawMotrya;

  if (Save <> 0) then
    DrawSave;

  if (Trench <> 0) then begin
    glFogfv(GL_FOG_COLOR, @TrenchColor);
    glClearColor(TrenchColor[0], TrenchColor[1], TrenchColor[2], TrenchColor[3]);
    DrawVas;
  end;

  if (GlyphsInLayer > 0) then
    DrawGlyphs;

  if (virdya <> 0) then
    DrawVirdya;

  if (hbd <> 0) then
    DrawHbd;

  if (Vebra <> 0) then
    DrawVebra;

  if (WB <> 0) then
    DrawWB;

  if (WBBK <> 0) then
    DrawWBBK;

  if (kubale > 28) then
    KubaleAI
  else if (kubale > 0) then
    KubaleEvent;

  if (EBD <> 0) then
    DrawEBD;

  if ((wmblyk = 8) or (wmblyk = 10)) then
    DrawWmblyk
  else if (wmblyk > 10) then
    DrawWmblykAngry;

  glDisable(GL_BLEND);
  DrawMazeItems;

  if (Shn <> 0) then
    ProcessShn;

  camPos[0] := camPos[0] + camCurSpeed[0];
  camPos[2] := camPos[2] + camCurSpeed[2];

  RenderUI;

  GLC.SwapBuffers;
  glFlush;
end;

{ Application.OnIdle }
procedure TFMain.RenderLoop(Sender: TObject; var Done: Boolean);
begin      
  {$IFDEF RenderDirectly}
    Render(Sender);
  {$ELSE}
    GLC.Invalidate;
  {$ENDIF}
  Done := False;
end;

{ Render user interface }
procedure TFMain.RenderUI;
var
  btnOffX, btnOffY, btnOffXE, btnOffYE, btnA: Single;
begin
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;

  gluOrtho2D(0, Width, Height, 0);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;


  glDisable(GL_DEPTH_TEST);
  glDisable(GL_LIGHTING);
  glDisable(GL_FOG);

  glEnable(GL_BLEND); { Draw vignette }
  glBlendFunc(GL_ZERO, GL_SRC_COLOR);
  glBindTexture(GL_TEXTURE_2D, TexVignette);
  glScalef(Width, Height, 0);
  glCallList(3);
  glBlendFunc(GL_ZERO, GL_ONE_MINUS_SRC_COLOR);
  glColor3f(vignetteRed, vignetteRed, vignetteRed);
  glBindTexture(GL_TEXTURE_2D, TexVignetteRed);
  glCallList(3);

  glBindTexture(GL_TEXTURE_2D, 0); { Gamma (not really) }
  glBlendFunc(GL_DST_COLOR, GL_SRC_COLOR);
  glColor3f(Gamma, Gamma, Gamma);
  glCallList(3);

  if (fadeState = 1) then begin { Fade in }
    Lerp(@fade, -0.1, delta2);
    fogDensity := fade + 0.5;
    if (fade < 0.0) then begin
      fade := 0;
      fadeState := 0;
    end;
  end else if (fadeState = 2) then begin { Fade out }    
    Lerp(@fade, 1.1, delta2);
    fogDensity := fade + 0.5;
    if (fade < 0.0) then begin
      fade := 1.0;
      fadeState := 0;
    end;
  end;
  glBindTexture(GL_TEXTURE_2D, 0);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glColor4f(0, 0, 0, fade);
  glCallList(3);

  { Motrya flash }
  if ((Motrya = 2) or ((MazeHostile > 6) and (MazeHostile < 12))) then begin
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glColor4f(1.0, 1.0, 1.0, MotryaTimer);
    glCallList(3);
  end;

  if (wmblyk = 1) then begin { Wmblyk jumpscare }
    glBindTexture(GL_TEXTURE_2D, TexWmblykJumpscare);
    glColor4f(1.0, 1.0, 1.0, wmblykJumpscare);
    glCallList(3);

    Lerp(@wmblykJumpscare, -0.1, delta2);
    if (wmblykJumpscare < 0.0) then begin
      wmblykJumpscare := 0;
      if (wmblykStealthy = 0) then
        wmblyk := 0
      else
        wmblyk := 8;
    end;
  end;

  if (kubale > 28) then begin
    glBindTexture(GL_TEXTURE_2D, TexKubaleInkblot[Random(9)]);

    glColor4f(kubaleVision, kubaleVision, kubaleVision, 1.0);
    glBlendFunc(GL_ZERO, GL_ONE_MINUS_SRC_COLOR);
    glScalef(0.5, 1.0, 1.0);
    glCallList(3);
    glDisable(GL_CULL_FACE);
    glTranslatef(2.0, 0.0, 0.0);
    glScalef(-1.0, 1.0, 1.0);
    glCallList(3);
    glEnable(GL_CULL_FACE);
  end;
  glColor4fv(@mclWhite);

  if (ccTimer > 0.0) then begin { Subtitles }
    ccTimer := ccTimer - deltaTime;

    glLoadIdentity;
    glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ONE_MINUS_SRC_COLOR);
    DrawBitmapText(CCText, winWH, Height - 90.0, FNT_CENTERED);
  end;

  if (MazeLevelPopup <> 0) then begin
    glLoadIdentity;
    glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ONE_MINUS_SRC_COLOR);
    glTranslatef(8.0, 8.0, 0.0);
    DrawBitmapText(CCLevel, 0, MazeLevelPopupY, FNT_LEFT);
    DrawBitmapText(MazeLevelStr, 120.0, MazeLevelPopupY, FNT_LEFT);
    MazeLevelPopupTimer := MazeLevelPopupTimer - deltaTime;
    if (MazeLevelPopup = 1) then begin
      Lerp(@MazeLevelPopupY, 0, delta2 * 2.0);
      if (MazeLevelPopupTimer < 0.0) then begin
        MazeLevelPopup := 2;
        MazeLevelPopupTimer := 2.0;
      end;
    end else begin
      Lerp(@MazeLevelPopupY, -48.0, delta2 * 2.0);
      if (MazeLevelPopupTimer < 0.0) then
        MazeLevelPopup := 0;
    end;
  end;

  case playerState of
    10: begin { Death screen }
      glLoadIdentity;
      glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ONE_MINUS_SRC_COLOR);
      DrawBitmapText(CCDeath, winWH, winHH - 32.0, FNT_CENTERED);

      DrawBitmapText(CCLevel, winWH - 32.0, winHH + 32.0, FNT_CENTERED);
      DrawBitmapText(MazeLevelStr, winWH + 58.0, winHH + 32.0, FNT_LEFT);
    end;
    13: begin { GreatCorn presents }   
      glLoadIdentity;
      glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ONE_MINUS_SRC_COLOR);
      DrawBitmapText(CCIntro1, winWH, winHH, FNT_CENTERED);
    end;    
    15: begin { Something something }
      glLoadIdentity;
      glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ONE_MINUS_SRC_COLOR);
      DrawBitmapText(CCIntro2, winWH, winHH - 32.0, FNT_CENTERED);
    end;
    17: begin { MASMZE-3D }
      glLoadIdentity;
      glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ONE_MINUS_SRC_COLOR);
      DrawBitmapText(AppName, winWH, winHH, FNT_CENTERED);
    end;
  end;

  if (MazeNote > 16) then begin
    glLoadIdentity; { BG }
    glScalef(Width, Height, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    glColor4f(0, 0, 0, 0.5);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glCallList(3);

    btnOffX := (Width - flPaper) * 0.5;   
    btnOffY := (Height - flPaper) * 0.5;
    glLoadIdentity;
    glTranslatef(btnOffX, btnOffY, 0);
    glScalef(640.0, 640.0, 0);
    glBindTexture(GL_TEXTURE_2D, TexPaper);
    glColor4fv(@mclWhite);
    glCallList(3);

    btnOffX := btnOffX + 110.0;
    btnOffY := btnOffY + 10.0;
    glLoadIdentity;
    glBlendFunc(GL_ZERO, GL_ONE_MINUS_SRC_COLOR);

    case MazeNote of
      17: DrawBitmapText(Note1, btnOffX, btnOffY, FNT_LEFT);   
      18: DrawBitmapText(Note2, btnOffX, btnOffY, FNT_LEFT);  
      19: DrawBitmapText(Note3, btnOffX, btnOffY, FNT_LEFT);   
      20: DrawBitmapText(Note4, btnOffX, btnOffY, FNT_LEFT);
      21: DrawBitmapText(Note5, btnOffX, btnOffY, FNT_LEFT);
      22: DrawBitmapText(Note6, btnOffX, btnOffY, FNT_LEFT);
      23: DrawBitmapText(Note7, btnOffX, btnOffY, FNT_LEFT);
    end;

    glLoadIdentity;
    glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ONE_MINUS_SRC_COLOR);
    glTranslatef(8.0, 8.0, 0);
    //JOYSTICK TEXT
    DrawBitmapText(CCEscape, 0, 0, FNT_LEFT);
  end;

  if (mMenu = 1) then begin
    glLoadIdentity; { BG }
    glScalef(Width, Height, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    glColor4f(0, 0, 0, 0.5);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glCallList(3);

    glLoadIdentity; { Cursor }
    glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ONE_MINUS_SRC_COLOR);
    glTranslatef(msX, msY, 0);
    glScalef(16.0, 16.0, 1.0);
    glBindTexture(GL_TEXTURE_2D, TexCursor);
    glColor4fv(@mclWhite);
    glCallList(3);

    glLoadIdentity; { Maze layer }
    glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ONE_MINUS_SRC_COLOR);
    glTranslatef(8.0, 8.0, 0);
    DrawBitmapText(CCLevel, 0, 0, FNT_LEFT);
    DrawBitmapText(MazeLevelStr, 120.0, 0, FNT_LEFT);

    { Buttons }
    glLoadIdentity;

    btnOffX := (Width - mnButton[0]) * 0.5;
    btnOffXE := btnOffX + mnButton[0];

    btnOffY := (Height - mnButton[1]) * 0.5;
    btnOffYE := btnOffY + mnButton[1];

    glTranslatef(btnOffX, btnOffY, 0);
    glScalef(mnButton[0], mnButton[1], 1.0);

    glBindTexture(GL_TEXTURE_2D, 0);

    { RESUME }
    if (not InRange(msX, msY, btnOffX, btnOffXE, btnOffY, btnOffYE)) then
      btnA := 1.0
    else begin
      btnA := 0.6;
      if (mkeyLMB = 1) then
        DoMenu;
    end;
    glColor3f(btnA, btnA, btnA);
    glCallList(3);

    { OPTIONS }
    btnOffYE := btnOffYE + 12.0 + mnButton[1];
    if (not InRange(msX, msY, btnOffX, btnOffXE, btnOffYE - mnButton[1], btnOffYE)) then
      btnA := 1.0
    else begin
      btnA := 0.6;
      if (mkeyLMB = 1) then begin
        Inc(mMenu);
        FSettings.ShowModal;
      end;
    end;
    glColor3f(btnA, btnA, btnA);
    glTranslatef(0, mnFontSpacing, 0);
    glCallList(3);

    { EXIT }
    btnOffYE := btnOffYE + 12.0 + mnButton[1];
    if (not InRange(msX, msY, btnOffX, btnOffXE, btnOffYE - mnButton[1], btnOffYE)) then
      btnA := 1.0
    else begin
      btnA := 0.6;
      if (mkeyLMB = 1) then begin
        Inc(mMenu);
        Destroy;
      end;
    end;
    glColor3f(btnA, btnA, btnA);
    glTranslatef(0, mnFontSpacing, 0);
    glCallList(3);

    { Text }
    glLoadIdentity;
    glTranslatef(winWH, btnOffY, 0);
    glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ONE_MINUS_SRC_COLOR);
    glColor4fv(@mclWhite);

    DrawBitmapText(MenuPaused, 0, -96, FNT_CENTERED);

    glBlendFunc(GL_ZERO, GL_ONE_MINUS_SRC_COLOR);

    { RESUME }
    DrawBitmapText(MenuResume, 0, 8.0, FNT_CENTERED);

    { SETTINGS }
    DrawBitmapText(MenuSettings, 0, 68.0, FNT_CENTERED);

    { EXIT }        
    DrawBitmapText(MenuExit, 0, 128.0, FNT_CENTERED);
  end;

  glBlendFunc(GL_DST_COLOR, GL_SRC_COLOR);
  DrawNoise(TexNoise);
  if (MazeHostile > 4) then begin
    glBlendFunc(GL_SRC_COLOR, GL_ONE);
    glColor3f(NoiseOpacity[0], NoiseOpacity[0], NoiseOpacity[0]);
    DrawNoise(TexNoise);
  end;

  if ((playerState = 12) or (playerState = 14) or (playerState = 16)) then begin
    glBlendFunc(GL_SRC_COLOR, GL_ONE);
    DrawNoise(TexRain);
  end;

  glDisable(GL_BLEND);

  glEnable(GL_FOG);
  glEnable(GL_LIGHTING);
  glEnable(GL_DEPTH_TEST);

  if (mkeyLMB = 1) then
    mkeyLMB := 2;
end;

{ Save current progress into registry }
procedure TFMain.SaveGame;
begin
  EraseTempSave;

  defKey := TRegistry.Create;
  if (not defKey.OpenKey(RegPath, True)) then begin
    Print('Failed to create registry key');
    defKey.Free;
    Exit;
  end;

  defKey.WriteInteger(RegLayer, MazeLevel);
  if (Compass = 2) then
    defKey.WriteBinaryData(RegCompass, Compass, 1);
  defKey.WriteBinaryData(RegGlyphs, Glyphs, 1);
  defKey.WriteInteger(RegFloor, CurrentFloor);
  defKey.WriteInteger(RegWall, CurrentWall);
  defKey.WriteInteger(RegRoof, CurrentRoof);
  defKey.WriteInteger(RegMazeW, MazeW);
  defKey.WriteInteger(RegMazeH, MazeH);

  defKey.Free;
end;

{ Set fullscreen mode to FS }
procedure TFMain.SetFullscreen(const FS: Boolean);
begin
  Print('Setting fullscreen: ', FS);
  if (FS) then begin
    windowSize[0] := Width;
    windowSize[1] := Height;

    windowPos[0] := Left;
    windowPos[1] := Top;

    Width := Screen.Width;
    Height := Screen.Height;
    Left := 0;
    Top := 0;

    FormStyle := fsStayOnTop;  
    {BorderStyle := bsNone;} { The GL context shits itself when I do this }

    { Windows-specific }
    {$IFDEF WINDOWS}
    SetWindowLong(Handle, -16, -2147483648);
    SetWindowPos(Handle, 4294967295, 0, 0, Screen.Width, Screen.Height,
    $4 or $20 or $40);
    {$ENDIF}
  end else begin
    Left := windowPos[0];
    Top := windowPos[1];

    FormStyle := fsNormal;   
    { BorderStyle := bsSizeable; }

    { Windows-specific }
    {$IFDEF WINDOWS}
    SetWindowLong(Handle, -16, $CF0000);
    SetWindowPos(Handle, 4294967295, windowPos[0], windowPos[1], windowSize[0], windowSize[1],
    $4 or $20 or $40);
    Icon := Application.Icon;
    {$ENDIF}

    Width := windowSize[0];
    Height := windowSize[1];
  end;
end;

{ Set noise opacity (used for ending only) }
procedure TFMain.SetNoiseOpacity;
begin
  if (MazeLevel = 0) then begin
    NoiseOpacity[1] := 1.0;
    Exit;
  end;
  NoiseOpacity[1] := 1.0 / (MazeLevel * 0.1);
end;

{ Setup shop to sell map and stuff for drawing the map }
procedure TFMain.SetupShopMap;
begin
  Shop := 1;
  ShopKoluplyk := 78;

  MapOffset[0] := -0.3;
  MapOffset[1] := -0.3;

  MapBRID := MazeSize - 1;

  { TODO: Make map centered, don't know how }
  if (MazeW > MazeH) then
    MapSize := 1.0 / MazeWM1
  else
    MapSize := 1.0 / MazeHM1;
end;

{ Shake screen }
procedure TFMain.Shake(const Amplitude: Single);
begin
  camRotL[0] := camRotL[0] + (Random * Amplitude * 2 - Amplitude);  
  camRotL[1] := camRotL[1] + (Random * Amplitude * 2 - Amplitude);
end;

{ Show subtitles, 2 seconds by default, change ccTimer to get different duration }
procedure TFMain.ShowSubtitles(const MString: AnsiString;
  const Interval: Single = 2.0);
begin
  ccText := MString;
  ccTimer := Interval;
end;

{ Spawns maze elements (items, monsters) depending on layer }
procedure TFMain.SpawnMazeElements;
var
  i, j: LongWord;
begin
  if (MazeLevel > 1) then begin
    case Random(6) of
      0: CurrentWall := TexWall;
      1: CurrentWall := TexMetal;
      2: CurrentWall := TexWhitewall;
      3: CurrentWall := TexBricks;
      4: CurrentWall := TexConcrete;
      5: CurrentWall := TexPlaster;
    end;
    case Random(6) of
      0: CurrentWallMDL := 1;  
      1: CurrentWallMDL := 25;
      2: CurrentWallMDL := 26;
      3: CurrentWallMDL := 92;
      4: CurrentWallMDL := 93;
      5: CurrentWallMDL := 132;
    end;       
    case Random(3) of
      0: CurrentRoof := TexRoof;
      1: CurrentRoof := TexMetalRoof;
      2: CurrentRoof := TexConcreteRoof;
    end;
    case Random(5) of
      0: CurrentFloor := TexFloor;    
      1: CurrentFloor := TexMetalFloor;
      2: CurrentFloor := TexTilefloor;
      3: CurrentFloor := TexDiamond;
      4: CurrentFloor := TexTileBig;
    end;
  end;

  { Random env sounds, hijacks Wmblyk's labels }
  wmblyk := Random(6);
  if (wmblyk < 2) then begin
    wmblykPos[0] := Random(MazeW) * 2;
    wmblykPos[1] := Random(MazeH) * 2;
    Print(wmblykPos[0], #32, wmblykPos[1]);

    case wmblyk of
      0: begin
        alSource3f(SndDrip, AL_POSITION, wmblykPos[0], 2.0, wmblykPos[1]);
        alSourcePlay(SndDrip);
      end;
      1: begin
        alSource3f(SndWhisper, AL_POSITION, wmblykPos[0], 2.0, wmblykPos[1]);
        alSourcePlay(SndWhisper);
      end;
    end;
  end;

  if ((Random(10) > 6) and (MazeLevel > 4)) then begin { Maze crevice }
    Print('Spawned crevice');
    MazeCrevice := 1;
    MazeCrevicePos[0] := Random(MazeWM1 - 2) + 1; { Don't want it near the end nor start }
    MazeCrevicePos[1] := Random(MazeHM1 - 2) + 1;
  end;

  if (MazeHostile = 1) then begin
    if ((MazeW > 13) and (MazeCrevice = 0) and (Random(3) <> 0)) then begin
      if (not GetCellMZC(0, 0, MZC_PASSTOP)) then begin { Test for trench }
        MazeTram := 1; { Spawn tram }
        MazeTramArea[0] := MazeW div 3;
        MazeTramArea[1] := MazeTramArea[0] + MazeTramArea[0];

        for i:=0 to MazeHM1 - 1 do begin
          j := GetOffset(MazeTramArea[0], i);
          if (i <> 0) then
            Maze[j] := Maze[j] or MZC_PASSTOP or MZC_PASSLEFT;

          Inc(MazeTramArea[0]);
          Maze[GetOffset(MazeTramArea[0], i)] := 0;
          Dec(MazeTramArea[0]);

          j := GetOffset(MazeTramArea[1], i);
          Maze[j] := MZC_PASSTOP;
          if (i = 0) then
            Maze[j] := 0;

          Inc(MazeTramArea[1]);
          if (GetCellMZC(MazeTramArea[1], i, MZC_ROTATED)) then begin
            j := GetOffset(MazeTramArea[1], i);
            Maze[j] := Maze[j] xor MZC_ROTATED;
          end;
          Dec(MazeTramArea[1]);
        end;

        Inc(MazeTramArea[0]);
        Dec(MazeTramArea[1]);

        MazeTramPos[0] := MazeTramArea[0] * 2.0 + 1.0;
        MazeTramPos[2] := MazeHM1;

        alSourcePlay(SndTram);
      end;
    end;

    if (Random(3) = 0) then begin
      Print('Will slam door');
      doorSlam := 1;
    end;

    if (Random(MazeLevel) > 7) then begin { Key }
      Print('Locked maze');
      MazeLocked := 1;
      GetRandomMazePosition(@MazeKeyPos[0], @MazeKeyPos[1]);
    end;

    if (Glyphs < 5) then
      if ((Random(3) = 0) or (Glyphs = 0)) then begin { Glyphs }
        Print('Spawned glyphs');
        MazeGlyphs := 1;
        GetRandomMazePosition(@MazeGlyphsPos[0], @MazeGlyphsPos[1]);
      end;

    if ((Compass <> 2) and (MazeLevel > 11)) then begin { Compass }
      Compass := 0;
      if (Random(2) = 0) then begin
        Print('Spawned compass');
        Compass := 1;
        GetRandomMazePosition(@CompassPos[0], @CompassPos[1]);
      end;
    end;

    case MazeLevel of { Notes }
      8: begin
        MazeNote := 1;
        MazeNotePos[0] := 1.0;
        MazeNotePos[1] := 3.0;
        j := GetOffset(0, 1);
        Maze[j] := Maze[j] or MZC_PASSTOP;
      end;
      12: begin
        MazeNote := 2;
        GetRandomMazePosition(@MazeNotePos[0], @MazeNotePos[1]);
      end;    
      16: begin
        MazeNote := 3;
        GetRandomMazePosition(@MazeNotePos[0], @MazeNotePos[1]);
      end;        
      23: begin
        MazeNote := 4;
        GetRandomMazePosition(@MazeNotePos[0], @MazeNotePos[1]);
      end;   
      36: begin
        MazeNote := 5;
        GetRandomMazePosition(@MazeNotePos[0], @MazeNotePos[1]);
      end;        
      41: begin
        MazeNote := 6;
        GetRandomMazePosition(@MazeNotePos[0], @MazeNotePos[1]);
      end;       
      62: begin
        MazeNote := 7;
        GetRandomMazePosition(@MazeNotePos[0], @MazeNotePos[1]);
      end;
    end;

    wmblyk := 0;
    wmblykStealthy := 0;
    wmblykBlink := 0;
    if (MazeLevel > 6) then { Wmblyk }
      if (Random(2) = 0) then begin
        GetRandomMazePosition(@wmblykPos[0], @wmblykPos[1]);

        Print('Spawned Wmblyk');
        wmblyk := 8;
        if (Random(2) = 0) then
          MakeWmblykStealthy;

        if (MazeLevel > 9) then
          if (Random(2) = 0) then begin
            wmblykStealthy := 0;
            wmblyk := 11;
            wmblykTurn := False;
            wmblykAnim := 11;
            alSourcef(SndWmblykB, AL_GAIN, 1.0);
            alSourcef(SndWmblykB, AL_PITCH, 1.0);
            alSourcePlay(SndWmblykB);
            Print('Wmblyk is angry');
          end;
      end;

    if ((MazeLevel > 12) and (MazeTram = 0)) then { Kubale }
      if (Random(4) = 0) then begin
        Print('Spawned Kubale');
        if ((Random(10) = 0) or (not kubaleAppeared)) then begin
          kubaleAppeared := True;
          kubaleDir := Random(6) + 2;
          kubale := 1;
        end else
          MakeKubale;
      end;

    if ((MazeSize > 90) and (MazeTram = 0)) then begin
      if (Random(10) = 0) then begin
        Print('Shnurpshik will be projected');
        Shn := 1;
        ShnTimer := 75.0;
      end;
    end;

    if ((Random(20) = 0) and (MazeLocked = 0)) then begin { Vebra }
      Print('Spawned Vebra');
      Vebra := 133;
    end;

    if ((MazeLevel > 15) and (Random(3) = 0)) then begin { Virdya }
      Print('Spawned Virdya');
      virdya := 63;
      virdyaState := 0;
      virdyaFace := TexVirdyaNeut;
      virdyaSound := 0;
      alSourcePlay(SndVirdya);
      GetRandomMazePosition(@virdyaPos[0], @virdyaPos[1]);
    end;

    if ((MazeLevel > LongWord(RandomRange2(28, 56))) and (kubale = 0) { WB }
    and (MazeCrevice = 0)) then
      if ((wmblyk = 0) or (wmblykStealthy <> 0)) then begin
        Print('Spawned WB');
        WBCreate;
      end;

    if (MazeLevel > LongWord(RandomRange2(9, 78))) then begin
      Print('Spawned Eblodryn');
      EBD := 1;
      GetRandomMazePosition(@EBDPos[0], @EBDPos[1]);
      alSource3f(SndEBD, AL_POSITION, EBDPos[0], 0, EBDPos[1]);
      alSourcef(SndEBDA, AL_GAIN, 0);
      alSourcePlay(SndEBD);
      alSourcePlay(SndEBDA);
    end;

    { Huenbergondel }
    if ((MazeLevel > 21) and (kubale = 0) and (virdya = 0) and (WB = 0)) then
      if (MazeType = 1) then begin
        if (Random(2) = 0) then begin
          Print('Spawned WB');
          WBCreate;
        end;
      end else if ((wmblyk = 0) or (wmblykStealthy <> 0)) then begin
        Print('Spawned Huenbergondel');
        hbd := 1;

        i := 0;
        while (i = 0) do begin
          Inc(i);
          hbdPos[0] := Random(MazeWM1 - 1) + 1;   
          hbdPos[1] := Random(MazeHM1 - 1) + 1;
          if (MazeCrevice <> 0) then begin
            if ((hbdPos[0] = MazeCrevicePos[0])
            and (hbdPos[1] = MazeCrevicePos[1])) then begin
              Print('Huenbergondel stuck in crevice');
              i := 0;
            end else
              Inc(i);
          end;
          if (MazeTram <> 0) then begin
            if ((hbdPos[0] >= MazeTramArea[0])
            and (hbdPos[0] <= MazeTramArea[1])) then begin
              Print('Huenbergondel stuck in tram area');
              i := 0;
            end else
              Inc(i);
          end;
        end;

        hbdPosF[0] := hbdPos[0] * 2.0 + 1.0;
        hbdPosF[1] := hbdPos[1] * 2.0 + 1.0;
      end;

    if ((MazeLevel > 17) and (MazeTram = 0) and (Vebra = 0)) then { Teleporters }
      if (Random(3) = 0) then begin
        Print('Spawned teleporters');
        MazeTeleport := 1;
        GetRandomMazePosition(@MazeTeleportPos[0], @MazeTeleportPos[1]);  
        GetRandomMazePosition(@MazeTeleportPos[2], @MazeTeleportPos[3]);
      end;

    if (MazeSize > 80) then { Shop }
      if (((Glyphs >= 5) or (MazeGlyphs = 1)) and (Random(2) <> 0)) then
        SetupShopMap;

    if ((MazeLevel > 17) and (MazeSize < 128) and (MazeTram = 0)) then { WBBK }
      if (Random(13) = 0) then begin
        hbd := 0;
        kubale := 0;
        MazeGlyphs := 0;
        MazeLocked := 0;
        Shop := 0;
        Vebra := 0;
        virdya := 0;
        wmblyk := 0;

        WBBK := 1;
        if (Random(3) = 0) then begin
          Print('Webubychko is unabstracted');
          WBBK := 3;
          WBBKPos[0] := 13.0;
          WBBKPos[1] := 13.0;
          WB := 0;
        end;

        glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @mclBlack);
        glLightf(GL_LIGHT0, GL_CONSTANT_ATTENUATION, 0);
        glLightf(GL_LIGHT0, GL_QUADRATIC_ATTENUATION, 2.0);

        alSourceStop(SndAmb);
        alSourceStop(SndWmblykB);
        alSourcef(SndAmbT, AL_PITCH, 0.2);
        alSourcePlay(SndAmbT);
        alSourcef(SndStep[0], AL_PITCH, 0.33); 
        alSourcef(SndStep[1], AL_PITCH, 0.33);   
        alSourcef(SndStep[2], AL_PITCH, 0.33);  
        alSourcef(SndStep[3], AL_PITCH, 0.33);

        alSourcef(SndDistress, AL_PITCH, 0.5);
      end;
  end;

  if ((MazeLevel = 21) or (MazeLevel = 42) or (MazeLevel = 63)) then
    Checkpoint := 1;

  if (ccTimer < 0.0) then begin
    i := Random(20);
    if (i = ccTextLast) then Exit;
    ccTextLast := i;
    case i of
      0: ShowSubtitles(CCRandom1);    
      1: ShowSubtitles(CCRandom2);
      2: ShowSubtitles(CCRandom3);
      3: ShowSubtitles(CCRandom4);
      4: ShowSubtitles(CCRandom5);
      5: ShowSubtitles(CCRandom6);
    end;
  end;
end;

{ Sets up the environment for the trench }
procedure TFMain.SpawnTrench;
var
  i, PosX, PosY: LongWord;
  WallCheck: Boolean;
begin
  Print('Trench');
  Trench := 1;
  TrenchTimer := Sqrt(MazeLevel) * 0.02;

  CurrentWall := TexDirt;
  CurrentFloor := TexDirt;
  CurrentWallMDL := 50;

  camFOV := 60.0;

  alSourcePlay(SndAmbT);
  alSourcef(SndWmblykB, AL_PITCH, 0.2);
  alSourcef(SndWmblykB, AL_GAIN, 10.0);
  alSourcePlay(SndWmblykB);
  alSourceStop(SndAmb);

  alSourceStop(SndSiren); { DEBUG }
  MazeHostile := 1;

  vasPos[1] := MazeHM1 * 2.0 - 1.0;

  for i:=0 to MazeSize - 1 do begin
    GetPosition(i, @PosX, @PosY);

    if (PosX = 0) then
      Maze[i] := Maze[i] or MZC_PASSTOP;

    WallCheck := False;
    if (not GetCellMZC(PosX, PosY, MZC_PASSTOP)) then
      WallCheck := True;

    if (GetCellMZC(PosX, PosY, MZC_LAMP)) then
      Maze[i] := Maze[i] xor MZC_LAMP;

    if (GetCellMZC(PosX, PosY, MZC_PIPE)) then
      Maze[i] := Maze[i] xor MZC_PIPE;

    if (Random(2) <> 0) then
      if ((not GetCellMZC(PosX, PosY + 1, MZC_PASSTOP)) and (WallCheck)) then
        Maze[i] := Maze[i] or MZC_LAMP;

    if (Random(5) = 0) then
      Maze[i] := Maze[i] or MZC_PIPE;
  end;
end;

{ RenderTimer.OnTimer }
procedure TFMain.TimerRender(Sender: TObject);
begin
  {$IFDEF RenderDirectly}
    Render(Sender);
  {$ELSE}
    GLC.Invalidate;
  {$ENDIF}
end;

{ Make Virdya react to something at (PosX, PosY) with distance threshold Dist }
function TFMain.VirdyaReact(const PosX, PosY, Dist: Single): Boolean;
begin
  if (DistanceToSqr(virdyaPos[0], virdyaPos[1], PosX, PosY) < Dist) then begin
    if (Random(100) <> 0) then
      virdyaBlink := 1.0
    else
      virdyaBlink := 0.000001;

    if (kubaleVision = 0) then begin
      Lerp(@fade, 0, delta2);
      Lerp(@vignetteRed, 0, delta2);
    end;
    Lerp(@virdyaSound, 0, delta2);
    if (virdyaSound < 0.01) then
      virdyaSound := 0;

    virdyaState := 2;
    virdyaFace := TexVirdyaN;
    virdyaRot := GetDirection(virdyaPos[0], virdyaPos[1], PosX, PosY);

    virdyaRotL[2] := (virdyaRot - virdyaRotL[0]) * R2D;

    virdyaRotL[1] := 0;

    virdyaSpeed[0] := -(Sin(virdyaRot) * deltaTime);
    virdyaSpeed[1] := -(Cos(virdyaRot) * deltaTime);

    if (virdya < 68) then
      virdya := 68;
    Result := True;
  end else
    Result := False;
end;

{ Create and prepare WB (stack, sound, etc) }
procedure TFMain.WBCreate;
begin
  if (WBStack <> nil) then begin
    Print('Freeing stack');
    WBStack.Destroy;
    WBStack := nil;
    Print('Stack freed successfully');
  end;

  Print('Creating new stack.');
  WBStack := THeapStack.Create(MazeSize * 2);

  Print('Stack size (in bytes): ', WBStack.BufferSize);

  WB := 1;
  GetRandomMazePosition(@WBPos[0], @WBPos[1]);
  alSourcef(SndWmblykB, AL_GAIN, 2.0);
  alSourcef(SndWmblykB, AL_PITCH, 0.5);
  alSourcePlay(SndWmblykB);
end;

{ Check if player is in front of WB, if Rand - randomize result chance }
function TFMain.WBFront(const Rand: Boolean): Boolean;
var
  dirVal, fltVal: Single;
begin
  dirVal := DistanceScalar(GetDirection(WBPos[0], WBPos[1],
    camPosN[0], camPosN[1]), WBRot[0]);
  Angleify(@dirVal);
  dirVal := Abs(dirVal);

  fltVal := 0.9;

  if (Rand) then begin
    RandomFloat(@fltVal, 2);
    fltVal := fltVal + MPIHalf;

    Print(fltVal:0:3, #32, dirVal:0:3);
  end;

  Result := dirVal < fltVal;
end;

{ WB close movement, far movement with solving is in DrawWB, WB == 2 }
procedure TFMain.WBMove(const Speed: Single);
var
  deltaSpd: Single;
begin
  Lerp(@WBSpMul, Speed, delta2);
  deltaSpd := WBSpMul * deltaTime;

  if (DistanceToSqr(WBPos[0], WBPos[1], WBTarget[0], WBTarget[1]) > 0.1) then
  begin
    if (WBCurSpd > 0.1) then begin
      if (WBAnim <> 1) then begin
        WBAnim := 1;
        WBAnimTimer := 0;
      end;
    end else
      WBAnim := 0;

    WBRot[1] := GetDirection(WBPos[0], WBPos[1], WBTarget[0], WBTarget[1]);
    MoveTowardsAngle(@WBRot[0], WBRot[1], deltaSpd);

    WBSpeed[0] := Sin(WBRot[1]) * deltaSpd;
    WBSpeed[1] := Cos(WBRot[1]) * deltaSpd;
    MoveAndCollide(@WBPos[0], @WBPos[1], @WBSpeed[0], @WBSpeed[1], 0.5, True);
  end else
    WBSpMul := 0;
end;

{ Call WBSolve to solve from WBPos to (ToX, ToY) in world coords }
procedure TFMain.WBSetSolve(const ToX, ToY: Single);
var
  ToXM, ToYM: LongWord;
begin
  Print('Entered WBSetSolve');

  GetMazeCellPos(ToX, ToY, @ToXM, @ToYM);

  WBFinal[0] := ToX;
  WBFinal[1] := ToY;

  WBSolve(WBPosI[0], WBPosI[1], ToXM, ToYM);
  WBNext[0] := WBPosI[0];
  WBNext[1] := WBPosI[1];

  WB := 2;
end;

{ Solve path from (FromX, FromY) to (ToX, ToY), in maze cells }
procedure TFMain.WBSolve(const FromX, FromY, ToX, ToY: LongWord);
var
  DeltaX, DeltaY: LongInt;
  PosX, PosY: LongWord;
  Vis: Boolean;
  i: LongWord;
begin
  if ((FromX = ToX) and (FromY = ToY)) then begin
    WB := 3;
    Exit;
  end;

  Print('Entered WBSolve');

  WBStack.Clear;

  for i:=0 to MazeSize-1 do { Clear visited }
    if ((Maze[i] and MZC_VISITED) <> 0) then
      Maze[i] := Maze[i] xor MZC_VISITED;

  PosX := ToX;
  PosY := ToY;

  Print('Started solving');
  i := GetOffset(PosX, PosY); { Set start to visited }
  Maze[i] := Maze[i] or MZC_VISITED;
  while True do begin
    { Behold, the ULTIMATE SPAGHETTI }
    Vis := False;
    DeltaX := 0;
    DeltaY := 0;

    if ((PosY > 0) and (not GetCellMZC(PosX, PosY - 1, MZC_VISITED)) and
    (GetCellMZC(PosX, PosY, MZC_PASSTOP))) then begin
        DeltaX := 0;
        DeltaY := -1;
        Vis := True;
      end;
    if (not Vis) then begin
      if ((PosX < MazeWM1) and (not GetCellMZC(PosX + 1, PosY, MZC_VISITED)) and
      (GetCellMZC(PosX + 1, PosY, MZC_PASSLEFT))) then begin
        DeltaX := 1;
        DeltaY := 0;
        Vis := True;
      end;

      if (not Vis) then begin
        if ((PosY < MazeHM1) and (not GetCellMZC(PosX, PosY + 1, MZC_VISITED))
        and (GetCellMZC(PosX, PosY + 1, MZC_PASSTOP))) then begin
          DeltaX := 0;
          DeltaY := 1;
          Vis := True;
        end;

        if (not Vis) then begin
          if ((PosX > 0) and (not GetCellMZC(PosX - 1, PosY, MZC_VISITED)) and
          (GetCellMZC(PosX, PosY, MZC_PASSLEFT))) then begin
            DeltaX := -1;
            DeltaY := 0;
            Vis := True;
          end;

          if (not Vis) then begin
            if (WBStack.BufferIndex = 0) then begin
              Print('No way found');
              Exit;
            end;

            WBStack.Pop(@PosY);
            WBStack.Pop(@PosX);
            Continue;
          end;
        end;
      end;
    end;

    if (WBStack.BufferIndex < WBStack.BufferSize) then begin
      WBStack.Push(PosX); { Save pos to stack }
      WBStack.Push(PosY);
    end else
      Print('PUSH LIMIT REACHED');

    PosX := PosX + DeltaX;
    PosY := PosY + DeltaY;

    i := GetOffset(PosX, PosY);
    Maze[i] := Maze[i] or MZC_VISITED;

    if ((PosX = FromX) and (PosY = FromY)) then begin { Found }
      Print('Found way.');
      Break;
    end;
  end;

  for i:=0 to MazeSize-1 do { Clear visited }
    if ((Maze[i] and MZC_VISITED) <> 0) then
      Maze[i] := Maze[i] xor MZC_VISITED;
end;

{ Shuffle Wmblyk's direction pool, placing the opposite direction at the end }
procedure TFMain.WmblykShuffle;
var
  al, bl, cl, dl, opp: Byte;
begin
  bl := Random(4);
  al := Random(4);
  cl := wmblykDirS[bl];
  dl := wmblykDirS[al];
  wmblykDirS[bl] := dl;
  wmblykDirS[al] := cl;

  al := wmblykDirI + 2;
  if (al > 3) then
    al := al - 4;
  opp := al;
  bl := 0;
  while (bl < 4) do begin
    cl := wmblykDirS[bl];
    if (cl = opp) then begin
      cl := wmblykDirS[bl];
      dl := wmblykDirS[3];
      wmblykDirS[bl] := dl;
      wmblykDirS[3] := cl;
      Break;
    end;
    Inc(bl);
  end;
end;

end.

