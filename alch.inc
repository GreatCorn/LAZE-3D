(*
 * The ALCAPI, ALCAPIENTRY, and ALC_INVALID macros are deprecated, but are
 * included for applications porting code from AL 1.0
 *)

{ ALCAPI ALC_API
  ALCAPIENTRY ALC_APIENTRY
  ALC_INVALID                       = 0;


  ALC_VERSION_0_1                   = 1;}

type
  PALCDevice                        = ^ALCDevice;
  ALCDevice                         = record
  end;

  PALCContext                       = ^ALCContext;
  ALCContext                        = record
  end;


(** 8-bit boolean *)
  ALCBoolean                        = Boolean;
  PALCboolean                       = PBoolean;

(** character *)
  ALCChar                           = Char;
  PALCChar                          = PChar;

(** signed 8-bit 2's complement integer *)
  ALCByte                           = Int8;
  PALCByte                          = PInt8;

(** unsigned 8-bit integer *)
  ALCUByte                          = UInt8;
  PALCUByte                         = PUInt8;

(** signed 16-bit 2's complement integer *)
  ALCShort                          = Int16;
  PALCShort                         = PInt16;

(** unsigned 16-bit integer *)
  ALCUShort                         = UInt16;
  PALCUShort                        = PUInt16;

(** signed 32-bit 2's complement integer *)
  ALCInt                            = Int32;
  PALCInt                           = PInt32;

(** unsigned 32-bit integer *)
  ALCUInt                           = UInt32;
  PALCuint                          = PUInt32;

(** non-negative 32-bit binary integer size *)
  ALCSizeI                          = Int32;
  PALCsizei                         = PInt32;

(** enumerated 32-bit value *)
  ALCEnum                           = Int32;
  PALCEnum                          = PInt32;

(** 32-bit IEEE754 floating-point *)
  ALCFloat                          = Single;
  PALCFloat                         = PSingle;

(** 64-bit IEEE754 floating-point *)
  ALCDouble                         = Double;
  PALCDouble                        = PDouble;

(** void type (for opaque pointers only) *)
  PALCVoid                          = Pointer;


(* Enumerant values begin at column 50. No tabs. *)
const

(* Boolean False. *)
  ALC_FALSE                         = 0;

(* Boolean True. *)
  ALC_TRUE                          = 1;

(**
 * followed by <int> Hz
 *)
  ALC_FREQUENCY                     = $1007;

(**
 * followed by <int> Hz
 *)
  ALC_REFRESH                       = $1008;

(**
 * followed by AL_TRUE, AL_FALSE
 *)
  ALC_SYNC                          = $1009;

(**
 * followed by <int> Num of requested Mono (3D) Sources
 *)
  ALC_MONO_SOURCES                  = $1010;

(**
 * followed by <int> Num of requested Stereo Sources
 *)
  ALC_STEREO_SOURCES                = $1011;

(**
 * errors
 *)

(**
 * No error
 *)
  ALC_NO_ERROR                      = ALC_FALSE;

(**
 * No device
 *)
  ALC_INVALID_DEVICE                = $A001;

(**
 * invalid context ID
 *)
  ALC_INVALID_CONTEXT               = $A002;

(**
 * bad enum
 *)
  ALC_INVALID_ENUM                  = $A003;

(**
 * bad value
 *)
  ALC_INVALID_VALUE                 = $A004;

(**
 * Out of memory.
 *)
  ALC_OUT_OF_MEMORY                 = $A005;


(**
 * The Specifier string for default device
 *)
  ALC_DEFAULT_DEVICE_SPECIFIER      = $1004;
  ALC_DEVICE_SPECIFIER              = $1005;
  ALC_EXTENSIONS                    = $1006;

  ALC_MAJOR_VERSION                 = $1000;
  ALC_MINOR_VERSION                 = $1001;

  ALC_ATTRIBUTES_SIZE               = $1002;
  ALC_ALL_ATTRIBUTES                = $1003;

(**
 * Capture extension
 *)
  ALC_CAPTURE_DEVICE_SPECIFIER      = $310;
  ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER = $311;
  ALC_CAPTURE_SAMPLES               = $312;


(*
 * Context Management
 *)
function alcCreateContext(device: PALCDevice; const attrlist: PALCInt): PALCContext; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

function alcMakeContextCurrent(context: PALCContext): ALCBoolean; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alcProcessContext(context: PALCContext); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alcSuspendContext(context: PALCContext); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alcDestroyContext(context: PALCContext); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

function alcGetCurrentContext: PALCContext; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

function alcGetContextsDevice(context: PALCContext): PALCDevice; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};


(*
 * Device Management
 *)
function alcOpenDevice(const devicename: PALCChar): PALCDevice; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

function alcCloseDevice(device: PALCDevice): ALCBoolean; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};


(*
 * Error support.
 * Obtain the most recent Context error
 *)
function alcGetError(device: PALCDevice): ALCEnum; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};


(* 
 * Extension support.
 * Query for the presence of an extension, and obtain any appropriate
 * function pointers and enum values.
 *)
function alcIsExtensionPresent(device: PALCDevice; const extname: PALCChar): ALCBoolean; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

function alcGetProcAddress(device: PALCDevice; const funcname: PALCChar): pointer; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

function alcGetEnumValue(device: PALCDevice; const enumname: PALCChar): ALCEnum; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};


(*
 * Query functions
 *)
function alcGetString(device: PALCDevice; param: ALCEnum): PALCChar; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alcGetIntegerv(device: PALCDevice; param: ALCEnum; size: ALCSizeI; data: PALCInt); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};


(*
 * Capture functions
 *)
function alcCaptureOpenDevice(const devicename: PALCChar; frequency: ALCUInt; format: ALCEnum; buffersize: ALCSizeI): PALCDevice; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

function alcCaptureCloseDevice(device: PALCDevice): ALCBoolean; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alcCaptureStart(device: PALCDevice); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alcCaptureStop(device: PALCDevice); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alcCaptureSamples(device: PALCDevice; buffer: PALCvoid; samples: ALCSizeI); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

