{
  Basic relocatable low-level architecture stack implementation.
  Object Pascal port from the MASMZE-3D HeapStack unit.
	Copyright (C) 2023  Yevhenii Ionenko (aka GreatCorn)

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
}

unit HeapStack;

{$MODE ObjFPC}

interface

type
  THeapStack = class(TObject)
    protected
      _Buffer: Pointer;
      _BufferIndex: PtrUInt;   
      _BufferSize: PtrUInt;
      _IndexSize: PtrUInt;
    public
      constructor Create(const Size: PtrUInt);
      destructor Destroy; override;
      procedure Clear;
      procedure Push(const Value: PtrInt);
      procedure Pop(const PReturn: PPtrInt);
      function Pop: PtrInt;
      property Buffer: Pointer read _Buffer;     
      property BufferIndex: PtrUInt read _BufferIndex;  
      property BufferSize: PtrUInt read _BufferSize;
      property IndexSize: PtrUInt read _IndexSize;
  end;

implementation

constructor THeapStack.Create(const Size: PtrUInt);
begin
  _IndexSize := Size;
  _BufferSize := Size * SizeOf(PtrInt);
  GetMem(_Buffer, _BufferSize);
  _BufferIndex := 0;
end;

destructor THeapStack.Destroy;
begin
  FreeMem(_Buffer);
  inherited;
end;

procedure THeapStack.Clear;
begin
  _BufferIndex := 0;
end;

procedure THeapStack.Push(const Value: PtrInt);
begin                                       
  if (_BufferIndex >= _BufferSize) then RunError(202);
  PPtrInt(_Buffer + _BufferIndex)^ := Value;
  _BufferIndex := _BufferIndex + SizeOf(PtrInt);
end;

procedure THeapStack.Pop(const PReturn: PPtrInt);
begin                            
  if (_BufferIndex = 0) then RunError(202);
  _BufferIndex := _BufferIndex - SizeOf(PtrInt);
  PReturn^ := PPtrInt(_Buffer + _BufferIndex)^;
end;

function THeapStack.Pop: PtrInt;
begin
  Pop(@Result);
end;

end.

