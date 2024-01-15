(**
 * OpenAL cross platform audio library
 * Copyright (C) 1999-2000 by authors.
 * This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Library General Public
 *  License as published by the Free Software Foundation; either
 *  version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 *  License along with this library; if not, write to the
 *  Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA 02110-1301, USA.
 * Or go to http://www.gnu.org/copyleft/lgpl.html
 *)


(*
 * The OPENAL, ALAPI, ALAPIENTRY, AL_INVALID, AL_ILLEGAL_ENUM, and
 * AL_ILLEGAL_COMMAND macros are deprecated, but are included for
 * applications porting code from AL 1.0
 *)

{ OPENAL
  ALAPI AL_API
  ALAPIENTRY AL_APIENTRY
  AL_INVALID                        = (-1);
  AL_ILLEGAL_ENUM                   = AL_INVALID_ENUM;
  AL_ILLEGAL_COMMAND                = AL_INVALID_OPERATION;

  AL_VERSION_1_0
  AL_VERSION_1_1}


type

(** 8-bit boolean *)
  ALBoolean                         = Boolean;
  PALBoolean                        = PBoolean;

(** character *)
  ALChar                            = Char;
  PALChar                           = PChar;

(** signed 8-bit 2's complement integer *)
  ALByte                            = Int8;
  PALByte                           = PInt8;

(** unsigned 8-bit integer *)
  ALUByte                           = UInt8;
  PALUByte                          = PUInt8;

(** signed 16-bit 2's complement integer *)
  ALshort                           = Int16;
  PALshort                          = PInt16;

(** unsigned 16-bit integer *)
  ALushort                          = UInt16;
  PALushort                         = PUInt16;

(** signed 32-bit 2's complement integer *)
  ALInt                             = Int32;
  PALint                            = PInt32;

(** unsigned 32-bit integer *)
  ALUInt                            = UInt32;
  PALuint                           = PUInt32;

(** non-negative 32-bit binary integer size *)
  ALSizeI                           = Int32;
  PALsizei                          = PInt32;

(** enumerated 32-bit value *)
  ALEnum                            = Int32;
  PALenum                           = PInt32;

(** 32-bit IEEE754 floating-point *)
  ALFloat                           = Single;
  PALfloat                          = PSingle;

(** 64-bit IEEE754 floating-point *)
  ALdouble                          = Double;
  PALdouble                         = PDouble;

(** void type (for opaque pointers only) *)
  PALvoid                           = Pointer;


(* Enumerant values begin at column 50. No tabs. *)

const
(* "no distance model" or "no buffer" *)
  AL_NONE                           = 0;

(* Boolean False. *)
  AL_FALSE                          = 0;

(** Boolean True. *)
  AL_TRUE                           = 1;

(** Indicate Source has relative coordinates. *)
  AL_SOURCE_RELATIVE                = $202;



(**
 * Directional source, inner cone angle, in degrees.
 * Range:    [0-360] 
 * Default:  360
 *)
  AL_CONE_INNER_ANGLE               = $1001;

(**
 * Directional source, outer cone angle, in degrees.
 * Range:    [0-360] 
 * Default:  360
 *)
  AL_CONE_OUTER_ANGLE               = $1002;

(**
 * Specify the pitch to be applied, either at source,
 *  or on mixer results, at listener.
 * Range:   [0.5-2.0]
 * Default: 1.0
 *)
  AL_PITCH                          = $1003;
  
(** 
 * Specify the current location in three dimensional space.
 * OpenAL, like OpenGL, uses a right handed coordinate system,
 *  where in a frontal default view X (thumb) points right, 
 *  Y points up (index finger), and Z points towards the
 *  viewer/camera (middle finger). 
 * To switch from a left handed coordinate system, flip the
 *  sign on the Z coordinate.
 * Listener position is always in the world coordinate system.
 *) 
  AL_POSITION                       = $1004;
  
(** Specify the current direction. *)
  AL_DIRECTION                      = $1005;
  
(** Specify the current velocity in three dimensional space. *)
  AL_VELOCITY                       = $1006;

(**
 * Indicate whether source is looping.
 * Type: ALBoolean?
 * Range:   [AL_TRUE, AL_FALSE]
 * Default: FALSE.
 *)
  AL_LOOPING                        = $1007;

(**
 * Indicate the buffer to provide sound samples. 
 * Type: ALUInt.
 * Range: any valid Buffer id.
 *)
  AL_BUFFER                         = $1009;
  
(**
 * Indicate the gain (volume amplification) applied. 
 * Type:   ALFloat.
 * Range:  ]0.0-  ]
 * A value of 1.0 means un-attenuated/unchanged.
 * Each division by 2 equals an attenuation of -6dB.
 * Each multiplicaton with 2 equals an amplification of +6dB.
 * A value of 0.0 is meaningless with respect to a logarithmic
 *  scale; it is interpreted as zero volume - the channel
 *  is effectively disabled.
 *)
  AL_GAIN                           = $100A;

(*
 * Indicate minimum source attenuation
 * Type: ALFloat
 * Range:  [0.0 - 1.0]
 *
 * Logarthmic
 *)
  AL_MIN_GAIN                       = $100D;

(**
 * Indicate maximum source attenuation
 * Type: ALFloat
 * Range:  [0.0 - 1.0]
 *
 * Logarthmic
 *)
  AL_MAX_GAIN                       = $100E;

(**
 * Indicate listener orientation.
 *
 * at/up 
 *)
  AL_ORIENTATION                    = $100F;

(**
 * Source state information.
 *)
  AL_SOURCE_STATE                   = $1010;
  AL_INITIAL                        = $1011;
  AL_PLAYING                        = $1012;
  AL_PAUSED                         = $1013;
  AL_STOPPED                        = $1014;

(**
 * Buffer Queue params
 *)
  AL_BUFFERS_QUEUED                 = $1015;
  AL_BUFFERS_PROCESSED              = $1016;

(**
 * Source buffer position information
 *)
  AL_SEC_OFFSET                     = $1024;
  AL_SAMPLE_OFFSET                  = $1025;
  AL_BYTE_OFFSET                    = $1026;

(*
 * Source type (Static, Streaming or undetermined)
 * Source is Static if a Buffer has been attached using AL_BUFFER
 * Source is Streaming if one or more Buffers have been attached using alSourceQueueBuffers
 * Source is undetermined when it has the NULL buffer attached
 *)
  AL_SOURCE_TYPE                    = $1027;
  AL_STATIC                         = $1028;
  AL_STREAMING                      = $1029;
  AL_UNDETERMINED                   = $1030;

(** Sound samples: format specifier. *)
  AL_FORMAT_MONO8                   = $1100;
  AL_FORMAT_MONO16                  = $1101;
  AL_FORMAT_STEREO8                 = $1102;
  AL_FORMAT_STEREO16                = $1103;

(**
 * source specific reference distance
 * Type: ALFloat
 * Range:  0.0 - +inf
 *
 * At 0.0, no distance attenuation occurs.  Default is
 * 1.0.
 *)
  AL_REFERENCE_DISTANCE             = $1020;

(**
 * source specific rolloff factor
 * Type: ALFloat
 * Range:  0.0 - +inf
 *
 *)
  AL_ROLLOFF_FACTOR                 = $1021;

(**
 * Directional source, outer cone gain.
 *
 * Default:  0.0
 * Range:    [0.0 - 1.0]
 * Logarithmic
 *)
  AL_CONE_OUTER_GAIN                = $1022;

(**
 * Indicate distance above which sources are not
 * attenuated using the inverse clamped distance model.
 *
 * Default: +inf
 * Type: ALFloat
 * Range:  0.0 - +inf
 *)
  AL_MAX_DISTANCE                   = $1023;

(** 
 * Sound samples: frequency, in units of Hertz [Hz].
 * This is the number of samples per second. Half of the
 *  sample frequency marks the maximum significant
 *  frequency component.
 *)
  AL_FREQUENCY                      = $2001;
  AL_BITS                           = $2002;
  AL_CHANNELS                       = $2003;
  AL_SIZE                           = $2004;

(**
 * Buffer state.
 *
 * Not supported for public use (yet).
 *)
  AL_UNUSED                         = $2010;
  AL_PENDING                        = $2011;
  AL_PROCESSED                      = $2012;


(** Errors: No Error. *)
  AL_NO_ERROR                       = AL_FALSE;

(** 
 * Invalid Name paramater passed to AL call.
 *)
  AL_INVALID_NAME                   = $A001;

(** 
 * Invalid parameter passed to AL call.
 *)
  AL_INVALID_ENUM                   = $A002;

(** 
 * Invalid enum parameter value.
 *)
  AL_INVALID_VALUE                  = $A003;

(** 
 * Illegal call.
 *)
  AL_INVALID_OPERATION              = $A004;

  
(**
 * No mojo.
 *)
  AL_OUT_OF_MEMORY                  = $A005;


(** Context strings: Vendor Name. *)
  AL_VENDOR                         = $B001;
  AL_VERSION                        = $B002;
  AL_RENDERER                       = $B003;
  AL_EXTENSIONS                     = $B004;

(** Global tweakage. *)

(**
 * Doppler scale.  Default 1.0
 *)
  AL_DOPPLER_FACTOR                 = $C000;

(**
 * Tweaks speed of propagation.
 *)
  AL_DOPPLER_VELOCITY               = $C001;

(**
 * Speed of Sound in units per second
 *)
  AL_SPEED_OF_SOUND                 = $C003;

(**
 * Distance models
 *
 * used in conjunction with DistanceModel
 *
 * implicit: NONE, which disances distance attenuation.
 *)
  AL_DISTANCE_MODEL                 = $D000;
  AL_INVERSE_DISTANCE               = $D001;
  AL_INVERSE_DISTANCE_CLAMPED       = $D002;
  AL_LINEAR_DISTANCE                = $D003;
  AL_LINEAR_DISTANCE_CLAMPED        = $D004;
  AL_EXPONENT_DISTANCE              = $D005;
  AL_EXPONENT_DISTANCE_CLAMPED      = $D006;

(*
 * Renderer State management
 *)
procedure alEnable(capability: ALEnum); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alDisable(capability: ALEnum); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

function alIsEnabled(capability: ALEnum): ALBoolean; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};


(*
 * State retrieval
 *)
function alGetString(param: ALEnum): PALchar; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alGetBooleanv(param: ALEnum; data: PALboolean); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alGetIntegerv(param: ALEnum; data: PALint); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alGetFloatv(param: ALEnum; data: PALfloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alGetDoublev(param: ALEnum; data: PALdouble); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

function alGetBoolean(param: ALEnum): ALBoolean; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

function alGetInteger(param: ALEnum): ALInt; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

function alGetFloat(param: ALEnum): ALFloat; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

function alGetDouble(param: ALEnum): ALdouble; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};


(*
 * Error support.
 * Obtain the most recent error generated in the AL state machine.
 *)
function alGetError: ALEnum; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};


(* 
 * Extension support.
 * Query for the presence of an extension, and obtain any appropriate
 * function pointers and enum values.
 *)
function alIsExtensionPresent(const extname: PALChar): ALBoolean; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

function alGetProcAddress(const fname: PALChar): pointer; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

function alGetEnumValue(const ename: PALChar): ALEnum; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};


(*
 * LISTENER
 * Listener represents the location and orientation of the
 * 'user' in 3D-space.
 *
 * Properties include: -
 *
 * Gain         AL_GAIN         ALFloat
 * Position     AL_POSITION     ALFloat[3]
 * Velocity     AL_VELOCITY     ALFloat[3]
 * Orientation  AL_ORIENTATION  ALFloat[6] (Forward then Up vectors)
*)

(*
 * Set Listener parameters
 *)
procedure alListenerf(param: ALEnum; value: ALFloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alListener3f(param: ALEnum; value1, value2, value3: ALFloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alListenerfv(param: ALEnum; const values: PALfloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alListeneri(param: ALEnum; value: ALInt); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alListener3i(param: ALEnum; value1, value2, value3: ALInt); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alListeneriv(param: ALEnum; const values: PALint); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

(*
 * Get Listener parameters
 *)
procedure alGetListenerf(param: ALEnum; out value: ALFloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alGetListener3f(param: ALEnum; out value1, value2, value3: ALFloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alGetListenerfv(param: ALEnum; values: PALfloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alGetListeneri(param: ALEnum; out value: ALInt); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alGetListener3i(param: ALEnum; out value1, value2, value3: ALInt); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alGetListeneriv(param: ALEnum; values: PALint); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};


(**
 * SOURCE
 * Sources represent individual sound objects in 3D-space.
 * Sources take the PCM data provided in the specified Buffer,
 * apply Source-specific modifications, and then
 * submit them to be mixed according to spatial arrangement etc.
 * 
 * Properties include: -
 *
 * Gain                              AL_GAIN                 ALFloat
 * Min Gain                          AL_MIN_GAIN             ALFloat
 * Max Gain                          AL_MAX_GAIN             ALFloat
 * Position                          AL_POSITION             ALFloat[3]
 * Velocity                          AL_VELOCITY             ALFloat[3]
 * Direction                         AL_DIRECTION            ALFloat[3]
 * Head Relative Mode                AL_SOURCE_RELATIVE      ALInt (AL_TRUE or AL_FALSE)
 * Reference Distance                AL_REFERENCE_DISTANCE   ALFloat
 * Max Distance                      AL_MAX_DISTANCE         ALFloat
 * RollOff Factor                    AL_ROLLOFF_FACTOR       ALFloat
 * Inner Angle                       AL_CONE_INNER_ANGLE     ALInt or ALFloat
 * Outer Angle                       AL_CONE_OUTER_ANGLE     ALInt or ALFloat
 * Cone Outer Gain                   AL_CONE_OUTER_GAIN      ALInt or ALFloat
 * Pitch                             AL_PITCH                ALFloat
 * Looping                           AL_LOOPING              ALInt (AL_TRUE or AL_FALSE)
 * MS Offset                         AL_MSEC_OFFSET          ALInt or ALFloat
 * Byte Offset                       AL_BYTE_OFFSET          ALInt or ALFloat
 * Sample Offset                     AL_SAMPLE_OFFSET        ALInt or ALFloat
 * Attached Buffer                   AL_BUFFER               ALInt
 * State (Query only)                AL_SOURCE_STATE         ALInt
 * Buffers Queued (Query only)       AL_BUFFERS_QUEUED       ALInt
 * Buffers Processed (Query only)    AL_BUFFERS_PROCESSED    ALInt
 *)

(* Create Source objects *)
procedure alGenSources(n: ALSizeI; sources: PALuint); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

(* Delete Source objects *)
procedure alDeleteSources(n: ALSizeI; const sources: PALuint); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

(* Verify a handle is a valid Source *) 
function alIsSource(sid: ALUInt): ALBoolean; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

(*
 * Set Source parameters
 *)
procedure alSourcef(sid: ALUInt; param: ALEnum; value: ALFloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alSource3f(sid: ALUInt; param: ALEnum; value1, value2, value3: ALFloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alSourcefv(sid: ALUInt; param: ALEnum; const values: PALfloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alSourcei(sid: ALUInt; param: ALEnum; value: ALInt); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alSource3i(sid: ALUInt; param: ALEnum; value1, value2, value3: ALInt); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alSourceiv(sid: ALUInt; param: ALEnum; const values: PALint); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

(*
 * Get Source parameters
 *)
procedure alGetSourcef(sid: ALUInt; param: ALEnum; out value: ALFloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alGetSource3f(sid: ALUInt; param: ALEnum; out value1, value2, value3: ALFloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alGetSourcefv(sid: ALUInt; param: ALEnum; values: PALfloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alGetSourcei(sid: ALUInt; param: ALEnum; out value: ALInt); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alGetSource3i(sid: ALUInt; param: ALEnum; out value1, value2, value3: ALInt); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alGetSourceiv(sid: ALUInt; param: ALEnum; values: PALint); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};


(*
 * Source vector based playback calls
 *)

(* Play, replay, or resume (if paused) a list of Sources *)
procedure alSourcePlayv(ns: ALSizeI; const sids: PALuint); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

(* Stop a list of Sources *)
procedure alSourceStopv(ns: ALSizeI; const sids: PALuint); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

(* Rewind a list of Sources *)
procedure alSourceRewindv(ns: ALSizeI; const sids: PALuint); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

(* Pause a list of Sources *)
procedure alSourcePausev(ns: ALSizeI; const sids: PALuint); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

(*
 * Source based playback calls
 *)

(* Play, replay, or resume a Source *)
procedure alSourcePlay(sid: ALUInt); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

(* Stop a Source *)
procedure alSourceStop(sid: ALUInt); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

(* Rewind a Source (set playback postiton to beginning) *)
procedure alSourceRewind(sid: ALUInt); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

(* Pause a Source *)
procedure alSourcePause(sid: ALUInt); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

(*
 * Source Queuing 
 *)
procedure alSourceQueueBuffers(sid: ALUInt; numEntries: ALSizeI; const bids: PALuint); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alSourceUnqueueBuffers(sid: ALUInt; numEntries: ALSizeI; bids: PALuint); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};


(**
 * BUFFER
 * Buffer objects are storage space for sample data.
 * Buffers are referred to by Sources. One Buffer can be used
 * by multiple Sources.
 *
 * Properties include: -
 *
 * Frequency (Query only)    AL_FREQUENCY      ALInt
 * Size (Query only)         AL_SIZE           ALInt
 * Bits (Query only)         AL_BITS           ALInt
 * Channels (Query only)     AL_CHANNELS       ALInt
 *)

(* Create Buffer objects *)
procedure alGenBuffers(n: ALSizeI; buffers: PALuint); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

(* Delete Buffer objects *)
procedure alDeleteBuffers(n: ALSizeI; const buffers: PALuint); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

(* Verify a handle is a valid Buffer *)
function alIsBuffer(bid: ALUInt): ALBoolean; cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

(* Specify the data to be copied into a buffer *)
procedure alBufferData(bid: ALUInt; format: ALEnum; data: PALvoid; size: ALSizeI; freq: ALSizeI); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

(*
 * Set Buffer parameters
 *)
procedure alBufferf(bid: ALUInt; param: ALEnum; value: ALFloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alBuffer3f(bid: ALUInt; param: ALEnum; value1, value2, value3: ALFloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alBufferfv(bid: ALUInt; param: ALEnum; const values: PALfloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alBufferi(bid: ALUInt; param: ALEnum; value: ALInt); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alBuffer3i(bid: ALUInt; param: ALEnum; value1, value2, value3: ALInt); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alBufferiv(bid: ALUInt; param: ALEnum; const values: ALInt); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

(*
 * Get Buffer parameters
 *)
procedure alGetBufferf(bid: ALUInt; param: ALEnum; out value: ALFloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alGetBuffer3f(bid: ALUInt; param: ALEnum; out value1, value2, value3: ALFloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alGetBufferfv(bid: ALUInt; param: ALEnum; values: PALfloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alGetBufferi(bid: ALUInt; param: ALEnum; out value: ALInt); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alGetBuffer3i(bid: ALUInt; param: ALEnum; out value1, value2, value3: ALInt); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alGetBufferiv(bid: ALUInt; param: ALEnum; values: ALInt); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};


(*
 * Global Parameters
 *)
procedure alDopplerFactor(value: ALFloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alDopplerVelocity(value: ALFloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alSpeedOfSound(value: ALFloat); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};

procedure alDistanceModel(distanceModel: ALEnum); cdecl; external {$IFDEF DYNLINK}openallib{$ENDIF};
