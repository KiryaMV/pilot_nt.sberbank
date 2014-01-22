{ ������ ������ � �������� ��������� }
{
  ������� ������ ������� ����������
  ��� ������ (��������) ������� �� ���������� ����� �������� ��������� ������ ������� �� ���������� ��������� ������� card_authorize(), �������� ���� TType � Amount � ������ ������� �������� � ��������� �����.
  �� ��������� ������ ������� ���������� ���������������� ���� RCode. ���� � ��� ���������� �������� �0� ��� �00�, ����������� ��������� ������� �����������, � ��������� ������ � �����������.
  ����� �����, ���������� ��������� �������� ���� Check. ���� ��� �� ����� NULL, ��� ���������� ��������� �� ������ (� ������������ ������) � ����� ������� ������� ������� GlobalFree().
  � ������, ���� ������� ��������� �� ������������ ��������������� ������ ���������� ���� �� ���� Check, ��� ����� ������������ ��������� ������:
  1) ��������� �������  card_authorize().
  2) ����� ���������� ������ ������� card_authorize(), ���� ���������� ��������� �������, ������� ������� SuspendTrx() � ���������� � ������ ����.
  3) ���� ��� ��������� �������, ������� ������� CommitTrx().
  4) ���� �� ����� ������ ���� �������� ������������ ��������, ������� ������� RollbackTrx() ��� ������ �������.
  ���� � ���� ������ ���� ���������� ��������� ��� ��� ���� �������, �� ���������� ��������� � ������������ ���������. ��� ��������� ������ ����� � ������ ��� ������������� ���������.

  ��� �������� ����� �������� ��������� ������ ������� �� ���������� ��������� ������� close_day(), �������� ���� TType = 7 � ������ ������� �������� � ��������� �����.
  �� ��������� ������ ������� ���������� ��������� �������� ���� Check. ���� ���� Check �� ����� NULL, ��� ���������� ��������� �� ������ (� ������������ ������) � ����� ����� ������� ������� ������� GlobaFree().
}

unit Core.PinPad;

interface

uses Classes, Windows, SysUtils;

const
  LibName: string = '.\pinpad\pilot_nt.dll';

type
  // ��������� ������
  PAuthAnswer = ^TAuthAnswer;

  TAuthAnswer = packed record
    TType: integer;
    // IN ��� ���������� (1 - ������, 3 - �������/������ ������, 7 - ������ ������)
    Amount: UINT; // IN ����� �������� � ��������
    Rcode: array [0 .. 2] of AnsiChar;
    // OUT ��������� ����������� (0 ��� 00 - �������� �����������, ������ �������� - ������)
    AMessage: array [0 .. 15] of AnsiChar;
    // OUT � ������ ������ � ����������� �������� ������� ��������� � ������� ������
    CType: integer;
    { OUT ��� ����������� �����. ��������� ��������:
      1 � VISA
      2 � MasterCard
      3 � Maestro
      4 � American Express
      5 � Diners Club
      6 � VISA Electron }
    Check: PAnsiChar;
    // OUT ��� �������� ����������� �������� ����� ���������� ����, ������� ���������� ��������� ������ ��������� �� ������, � ����� ���������� ������� ������� GlobalFree()
    // ����� ����� �������� nil. � ���� ������ ������� �������� � ��� ���������� ��������� ��������� �� ������.
  end;

  PAuthAnswer7 = ^TAuthAnswer7;

  TAuthAnswer7 = packed record
    AuthAnswer: TAuthAnswer;
    // ����/�����: �������� ��������� �������� (��.����)
    AuthCode: array [0 .. 6] of AnsiChar; // ��� �����������
    // OUT ��� �������� ����������� (�� ������������� �����) �������� ��� �����������. ��� �������� �� ����� �������� ���� ����� ��������� ��������� �*�.
    CardID: array [0 .. 24] of AnsiChar; // ����� �����
    // OUT ��� �������� ����������� (�� ������������� �����) �������� ����� �����. ��� ������������� ���� ��� �������, ����� ������ 6 � ��������� 4, ����� �������� ��������� �*�.
    SberOwnCard: integer;
    // OUT �������� 1, ���� ����������� ����� ������ ����������, ��� 0 � � ��������� ������
  end;

  PAuthAnswer9 = ^TAuthAnswer9;

  TAuthAnswer9 = packed record
    AuthAnswer: TAuthAnswer;
    // ����/�����: �������� ��������� �������� (��.����)
    AuthCode: array [0 .. 6] of AnsiChar; // ��� �����������
    // OUT ��� �������� ����������� (�� ������������� �����) �������� ��� �����������. ��� �������� �� ����� �������� ���� ����� ��������� ��������� �*�.
    CardID: array [0 .. 24] of AnsiChar; // ����� �����
    // OUT ��� �������� ����������� (�� ������������� �����) �������� ����� �����. ��� ������������� ���� ��� �������, ����� ������ 6 � ��������� 4, ����� �������� ��������� �*�.
    SberOwnCard: integer;
    // OUT �������� 1, ���� ����������� ����� ������ ����������, ��� 0 � � ��������� ������
    Hash: array [0 .. 40] of AnsiChar;
    // OUT ��� SHA1 �� ������ ����� � ������� ASCIIZ
  end;

  TOperationType = (sberPayment = 1, sberReturn = 3, sberCloseDay = 7);

  TCardAuthorize9 = function(track2: Pchar; auth_ans: PAuthAnswer9)
    : integer; cdecl;

  TCardAuthorize = function(track2: Pchar; auth_ans: PAuthAnswer)
    : integer; cdecl;

  TCardAuthorize7 = function(track2: Pchar; auth_ans: PAuthAnswer7)
    : integer; cdecl;
  {
    ������� ������������ ��� ���������� ����������� �� ���������� �����, � ����� ��� ������������� ��� ��������/������ �������.

    ������� ������:
    track2 - ����� ����� �������� NULL ��� ��������� ������ 2-� ������� �����, ��������� �������� ����������
    TType	-	��� ��������: 1 � ������, 3 ��������/������ ������.
    Amount - ����� �������� � ��������.
    �������� ���������:
    RCode - ��������� �����������. �������� �00� ��� �0� �������� �������� �����������, ����� ������ � ����� � �����������.
    AMessage - � ������ ������ � ����������� �������� ������� ��������� � ������� ������. ��������: ���� �� ����� ������������ ����� 0�00.
    CType
    ��� ����������� �����. ��������� ��������:
    1 � VISA
    2 � MasterCard
    3 � Maestro
    4 � American Express
    5 � Diners Club
    6 � VISA Electron
    �heck
    ��� �������� ����������� �������� ����� ���������� ����, ������� ���������� ��������� ������ ��������� �� ������, � ����� ���������� ������� ������� GlobalFree().
    ����� ����� �������� NULL. � ���� ������ ������� �������� � ��� ���������� ��������� ��������� �� ������.
    AuthCode - ��� �������� ����������� (�� ������������� �����) �������� ��� �����������. ��� �������� �� ����� �������� ���� ����� ��������� ��������� �*�.
    CardID - ��� �������� ����������� (�� ������������� �����) �������� ����� �����. ��� ������������� ���� ��� �������, ����� ������ 6 � ��������� 4, ����� �������� ��������� �*�.
    SberOwnCard - �������� 1, ���� ����������� ����� ������ ����������, ��� 0 � � ��������� ������.
  }

  TTestPinPad = function(): integer; cdecl;
  {
    ������� ��������� ������� �������. ��� �������� ���������� ���������� 0 (������ ���������), ��� ��������� � ��� ������ (������ �� ��������� ��� ����������).
  }

  TCloseDay = function(auth_ans: PAuthAnswer): integer; cdecl;
  {
    ������� ������������ ��� ����������� �������� ����� �� ������ � ������������ �������.

    ������� ���������:
    TType - ��� ��������: 7 � �������� ��� �� ������.
    Amount - �� ������������.
    �������� ���������:
    Rcode - �� ������������.
    AMessage - �� ������������.
    CType - �� ������������.
    Check - �������� ����� ������ �� ������, ������� ���������� ��������� ������ ��������� �� ������, � ����� ���������� ������� ������� GlobalFree().
    ����� ����� �������� NULL. � ���� ������ ������� �������� � ��� ���������� ��������� ��������� �� ������.
  }

  TReadTrack2 = function(track2: Pchar): integer; cdecl;
  {
    ������� ��������� ������� �������. ��� �������� ���������� ���������� 0 (������ ���������), ��� ��������� � ��� ������ (������ �� ��������� ��� ����������).

    Track2 - �����, ���� ������� ���������� ����������� 2-� �������.
  }

  // SuspendTrx
  TSuspendTrx = function(dwAmount: DWORD; pAuthCode: PAnsiString)
    : integer; cdecl;
  {
    ������� ��������� ��������� �������� ���������� � ������������ ���������. ���� ���������� ��������� � ���� ���������, �� ��� ��������� ������ ����� � ������ ��� ����� ��������.
    ������� ���������:
    dwAmount - ����� �������� (� ��������).
    pAuthCode - ��� �����������.
    ������� ������� ���������� ����� ��������� (����� � ��� �����������) �� ���������� � ��������� �������� ��������, ������� ���� ��������� ����� ����������. ���� ���� �� ���� �������� �� ���������, ������� ���������� ��� ������ 4140 � �� ��������� ������� ��������.
  }

  // CommitTrx
  TCommitTrx = function(dwAmount: DWORD; pAuthCode: PAnsiString)
    : integer; cdecl;
  {
    ������� ���������� ��������� �������� ���������� � ����������� ���������. ����� ����� ���������� ����� �������� � ����� � ��������������� ��� ��������. ��������� �� ����� � ������������ ��������� ����� ��� ������.
    ������� ���������:
    dwAmount - ����� �������� (� ��������).
    pAuthCode - ��� �����������.
    ������� ������� ���������� ����� ��������� (����� � ��� �����������) �� ���������� � ��������� �������� ��������, ������� ���� ��������� ����� ����������. ���� ���� �� ���� �������� �� ���������, ������� ���������� ��� ������ 4140 � �� ��������� ������� ��������.
  }

  // RollBackTrx
  TRollBackTrx = function(dwAmount: DWORD; pAuthCode: PAnsiString)
    : integer; cdecl;
  {
    ������� �������� ����������� ������ ��������� �������� �������� (��������, ����� ������������ � ������������ ���������, ���� ��� � �� �����������). ���� ���������� ��� ���� ���������� � ����������� ��������� �������� CommitTrx(), �� ������� RollbackTrx() ���������� � ����� ������ 4141, �� �������� ������� ��������.

    ������� ���������:
    dwAmount - ����� �������� (� ��������).
    pAuthCode - ��� �����������.
    ������� ������� ���������� ����� ��������� (����� � ��� �����������) �� ���������� � ��������� �������� ��������, ������� ���� ��������� ����� ����������. ���� ���� �� ���� �������� �� ���������, ������� ���������� ��� ������ 4140 � �� ��������� ������� ��������.
  }

  TPinPad = class
    strict private
      FAuthAnswer: TAuthAnswer;
      FAuthAnswer7: TAuthAnswer7;
      FAuthAnswer9: TAuthAnswer9;
      FCheque: string;
      FRCode: string;
      FMessage: string;
      FAuthCode: string;
      FTrack2: string;
    public
      constructor create;
      destructor destroy;
      function CardAuth(Summ: Currency; Operation: TOperationType): integer;
      function CardAuth7(Summ: Currency; Operation: TOperationType): integer;
      function CardAuth9(Summ: Currency; Operation: TOperationType): integer;
      function TestPinPad: boolean;
      function ReadTrack2: string;
      function CloseDay: integer;
      function SuspendTrx: integer;
      function CommitTrx: integer;
      function RollBackTrx: integer;
      property AuthAnswer: TAuthAnswer read FAuthAnswer;
      property AuthAnswer7: TAuthAnswer7 read FAuthAnswer7;
      property AuthAnswer9: TAuthAnswer9 read FAuthAnswer9;
      property Cheque: string read FCheque;
      property Rcode: string read FRCode;
      property Msg: string read FMessage;
      property track2: string read FTrack2;
      property AuthCode: string read FAuthCode;
  end;

implementation

{ TPinPad }

function TPinPad.CardAuth(Summ: Currency; Operation: TOperationType): integer;
var
  H: THandle;
  Func: TCardAuthorize;
  Sum: UINT;
begin
  Sum                := Round(Summ * 100);
  FAuthAnswer.Amount := Sum;
  FAuthAnswer.TType  := integer(Operation);
  FAuthAnswer.CType  := 0;

  H := LoadLibrary(Pchar(LibName));

  try
    @Func := GetProcAddress(H, Pchar('_card_authorize'));

    Result   := Func(Pchar(''), @FAuthAnswer);
    FCheque  := PAnsiChar(FAuthAnswer.Check);
    FRCode   := AnsiString(FAuthAnswer.Rcode);
    FMessage := AnsiString(FAuthAnswer.AMessage);
  finally
    Func := nil;
    FreeLibrary(H);
  end;
end;

function TPinPad.CardAuth7(Summ: Currency; Operation: TOperationType): integer;
var
  H: THandle;
  Func: TCardAuthorize7;
  Sum: UINT;
begin
  Sum                := Round(Summ * 100);
  FAuthAnswer.Amount := Sum;
  FAuthAnswer.TType  := integer(Operation);
  FAuthAnswer.CType  := 0;

  FAuthAnswer7.AuthAnswer := FAuthAnswer;

  H := LoadLibrary(Pchar(LibName));

  try
    @Func := GetProcAddress(H, Pchar('_card_authorize7'));

    Result := Func(Pchar(''), @FAuthAnswer7);

    FCheque   := PAnsiChar(FAuthAnswer7.AuthAnswer.Check);
    FRCode    := AnsiString(FAuthAnswer7.AuthAnswer.Rcode);
    FMessage  := AnsiString(FAuthAnswer7.AuthAnswer.AMessage);
    FAuthCode := AnsiString(FAuthAnswer7.AuthCode);
  finally
    Func := nil;
    FreeLibrary(H);
  end;
end;

function TPinPad.CardAuth9(Summ: Currency; Operation: TOperationType): integer;
var
  H: THandle;
  Func: TCardAuthorize9;
  Sum: UINT;
begin
  Sum                := Round(Summ * 100);
  FAuthAnswer.Amount := Sum;
  FAuthAnswer.TType  := integer(Operation);
  FAuthAnswer.CType  := 0;

  FAuthAnswer9.AuthAnswer := FAuthAnswer;

  H := LoadLibrary(Pchar(LibName));

  try
    @Func := GetProcAddress(H, Pchar('_card_authorize9'));

    Result    := Func(Pchar(''), @FAuthAnswer9);
    FCheque   := PAnsiChar(FAuthAnswer9.AuthAnswer.Check);
    FRCode    := AnsiString(FAuthAnswer9.AuthAnswer.Rcode);
    FMessage  := AnsiString(FAuthAnswer9.AuthAnswer.AMessage);
    FAuthCode := AnsiString(FAuthAnswer9.AuthCode);
  finally
    Func := nil;
    FreeLibrary(H);
  end;
end;

function TPinPad.CloseDay: integer;
var
  Func: TCloseDay;
  H: THandle;
begin
  FAuthAnswer.TType  := integer(sberCloseDay);
  FAuthAnswer.Amount := 0;
  FAuthAnswer.CType  := 0;
  FAuthAnswer.Check  := PAnsiChar('');

  H := LoadLibrary(Pchar(LibName));
  if H <= 0 then
    begin
      raise Exception.create(Format('�� ���� ��������� %s', [LibName]));
      Exit;
    end;

  @Func := GetProcAddress(H, Pchar('_close_day'));

  if not assigned(Func) then
    raise Exception.create('Could not find _close_day function');

  try
    Result   := Func(@FAuthAnswer);
    FCheque  := PAnsiChar(FAuthAnswer.Check);
    FMessage := AnsiString(FAuthAnswer.AMessage);
    FRCode   := AnsiString(FAuthAnswer.Rcode);
  except
    on E: Exception do
      raise Exception.create(E.Message);
  end;

  FreeLibrary(H);
end;

function TPinPad.CommitTrx: integer;
var
  H: THandle;
  Func: TCommitTrx;
begin
  H := LoadLibrary(Pchar(LibName));
  if H <= 0 then
    begin
      raise Exception.create(Format('�� ���� ��������� %s', [LibName]));
      Exit;
    end;

  try
    @Func := GetProcAddress(H, Pchar('_CommitTrx'));
    try
      Result := Func(FAuthAnswer.Amount, PAnsiString(AnsiString(FAuthCode)));
    except
      on E: Exception do;
    end;

  finally
    FreeLibrary(H);
  end;

end;

constructor TPinPad.create;
begin
  inherited create;
  FAuthAnswer.Amount := 0;
  FAuthAnswer.TType  := 0;
end;

destructor TPinPad.destroy;
begin
  inherited destroy;
end;

function TPinPad.ReadTrack2: string;
var
  H: THandle;
  Func: TReadTrack2;
  Res: Pchar;
begin
  GetMem(Res, 255);

  H := LoadLibrary(Pchar(LibName));

  if H <= 0 then
    begin
      raise Exception.create(Format('�� ���� ��������� %s', [LibName]));
      Exit;
    end;

  try
    @Func := GetProcAddress(H, Pchar('_ReadTrack2'));
    try
      Func(Res);
      Result := PAnsiChar(Res);
    except
      on E: Exception do;
    end;

  finally
    FreeMem(Res, sizeof(Res^));
    FreeLibrary(H);
  end;

end;

function TPinPad.RollBackTrx: integer;
var
  H: THandle;
  Func: TRollBackTrx;
begin
  H := LoadLibrary(Pchar(LibName));

  if H <= 0 then
    begin
      raise Exception.create(Format('�� ���� ��������� %s', [LibName]));
      Exit;
    end;

  try
    @Func := GetProcAddress(H, Pchar('_RollbackTrx'));
    try
      Result := Func(FAuthAnswer.Amount, PAnsiString(AnsiString(FAuthCode)));
    except
      on E: Exception do;
    end;

  finally
    FreeLibrary(H);
  end;

end;

function TPinPad.SuspendTrx: integer;
var
  H: THandle;
  Func: TSuspendTrx;
begin
  H := LoadLibrary(Pchar(LibName));
  if H <= 0 then
    begin
      raise Exception.create(Format('�� ���� ��������� %s', [LibName]));
      Exit;
    end;

  try
    @Func := GetProcAddress(H, Pchar('_SuspendTrx'));
    try
      Result := Func(FAuthAnswer.Amount, PAnsiString(AnsiString(FAuthCode)));
    except
      on E: Exception do;
    end;

  finally
    FreeLibrary(H);
  end;

end;

function TPinPad.TestPinPad: boolean;
var
  H: THandle;
  Func: TTestPinPad;
begin
  Result := false;

  try
    H := LoadLibrary(Pchar(LibName));
    if H <= 0 then
      begin
        raise Exception.create(Format('�� ���� ��������� %s', [LibName]));
        Exit;
      end;

    @Func := GetProcAddress(H, Pchar('_TestPinpad'));
    try
      Result := Func = 0;
    except
      on E: Exception do;
    end;

  finally
    Func := nil;
    FreeLibrary(H);
  end;
end;

end.
