{
  Compact refactor (also for the purpose of having a
  changeable library path) of the OpenAL headers for FreePascal
  Original headers Copyright (C) 2006 by Ivo Steinmann
}

unit SoftOAL;

{$MODE ObjFPC}

interface

{$IFDEF WINDOWS}
  {$DEFINE DYNLINK}
{$ENDIF}

{$IF Defined(DYNLINK)}
const
{$IF Defined(WINDOWS)}
  openallib = 'soft_oal';
{$ELSEIF Defined(UNIX)}
  openallib = 'libopenal.so';
{$ELSE}
  {$MESSAGE ERROR 'DYNLINK not supported'}
{$IFEND}
{$ELSEIF Defined(Darwin)}
{$linkframework OpenAL}
{$ELSE}
  {$LINKLIB openal}
{$ENDIF}

{$include alh.inc}
{$include alch.inc}

implementation

end.
