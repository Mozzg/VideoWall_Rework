unit uSerialThread;

interface

uses
  synaser,
  Classes,
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SyncObjs
  ;

type
{$IFDEF UNIX}
  TBaudRate=(br_____0, br____50, br____75, br___110, br___134, br___150,
             br___200, br___300, br___600, br__1200, br__1800, br__2400,
             br__4800, br__9600, br_19200, br_38400, br_57600, br115200,
             br230400
   {$IFNDEF DARWIN}   // LINUX
             , br460800, br500000, br576000, br921600, br1000000, br1152000,
             br1500000, br2000000, br2500000, br3000000, br3500000, br4000000
   {$ENDIF} );
{$ELSE}      // MSWINDOWS
   TBaudRate=(br___110,br___300, br___600, br__1200, br__2400, br__4800,
           br__9600,br_14400, br_19200, br_38400,br_56000, br_57600,
           br115200,br128000, br230400,br256000, br460800, br921600);
{$ENDIF}
  TDataBits=(db8bits,db7bits,db6bits,db5bits);
  TParity=(pNone,pOdd,pEven,pMark,pSpace);
  TFlowControl=(fcNone,fcXonXoff,fcHardware);
  TStopBits=(sbOne,sbOneAndHalf,sbTwo);

const
{$IFDEF UNIX}
    ConstsBaud: array[TBaudRate] of integer=
    (0, 50, 75, 110, 134, 150, 200, 300, 600, 1200, 1800, 2400, 4800, 9600,
    19200, 38400, 57600, 115200, 230400
    {$IFNDEF DARWIN}  // LINUX
       , 460800, 500000, 576000, 921600, 1000000, 1152000, 1500000, 2000000,
       2500000, 3000000, 3500000, 4000000
    {$ENDIF}  );
{$ELSE}      // MSWINDOWS
    ConstsBaud: array[TBaudRate] of integer=
    (110, 300, 600, 1200, 2400, 4800, 9600, 14400, 19200, 38400, 56000, 57600,
    115200, 128000, 230400, 256000, 460800, 921600 );
{$ENDIF}

  ConstsBits: array[TDataBits] of integer=(8, 7 , 6, 5);
  ConstsParity: array[TParity] of char=('N', 'O', 'E', 'M', 'S');
  ConstsStopBits: array[TStopBits] of integer=(SB1,SB1AndHalf,SB2);

type
  TReadCallbackProc = procedure(AData: string) of object;

  TSerialReadThread = class(TThread)
  private
    FSynSerial: TBlockSerial;
    FReadCallback: TReadCallbackProc;
  public
    constructor Create(ASerial: TBlockSerial);
    procedure Execute; override;

    property OnReadCallback: TReadCallbackProc read FReadCallback write FReadCallback;
  published
    property Terminated;
  end;

  TCustomSerial = class(TObject)
  private
    FSerial: TBlockSerial;
    FInternalReadThread: TSerialReadThread;

    FInternalReadBuffer: string;
    FCritSectionReadBuffer: TCriticalSection;
    FDataAvailableEvent: TEvent;

    FActive: boolean;
    FDeviceName: string;
    FBaudRate: TBaudRate;
    FDataBits: TDataBits;
    FParity: TParity;
    FStopBits: TStopBits;
    FSoftflow, FHardflow: boolean;
    FFlowControl: TFlowControl;

    procedure DeviceOpen;
    procedure DeviceClose;
    procedure ConfigSerial;

    procedure SerialReadCallback(AData: string);
  protected
    procedure SetActive(AValue: boolean);
    procedure SetDeviceName(AValue: string);
    procedure SetBaudRate(AValue: TBaudRate);
    procedure SetDataBits(AValue: TDataBits);
    procedure SetParity(AValue: TParity);
    procedure SetStopBits(AValue: TStopBits);
    procedure SetFlowControl(AValue: TFlowControl);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Open;
    procedure Close;

    function DataAvailable: boolean;
    function ReadData: string;
    function WriteString(AInput: string): integer;
    function WriteBuffer(var ABuf; ASize: integer): integer;

    property Active: boolean read FActive write SetActive;
    property DeviceName: string read FDeviceName write SetDeviceName;
    property BaudRate: TBaudRate read FBaudRate write SetBaudRate;
    property DataBits: TDataBits read FDataBits write SetDataBits;
    property Parity: TParity read FParity write SetParity;
    property StopBits: TStopBits read FStopBits write SetStopBits;
    property FlowControl: TFlowControl read FFlowControl write SetFlowControl;
  end;

implementation

uses
  SysUtils
{$IFDEF FPC}
  ,LConvEncoding
{$ENDIF}
  ;

{ TSerialReadThread }

constructor TSerialReadThread.Create(ASerial: TBlockSerial);
begin
  inherited Create(true);

  if ASerial = nil then Exception.Create('nil parameter in SerialReadThread constructor');

  FSynSerial := ASerial;
  //Start;  the caller must start this thread
end;

procedure TSerialReadThread.Execute;
var buf: ansistring;
begin
  while not(Terminated) do
  begin
    buf := '';
    TThread.Yield;
    TThread.Sleep(1);

    if Assigned(FSynSerial) then
      if FSynSerial.CanReadEx(100) then
      begin
        if FSynSerial.Handle = INVALID_HANDLE_VALUE then Exception.Create('can not read data from closed port in SerialReadThread');

        buf := FSynSerial.RecvPacket(0);
      end;

    if Assigned(FReadCallback) then FReadCallback(buf);
  end;
end;


{ TCustomSerial }

constructor TCustomSerial.Create;
begin
  inherited Create;

  FActive := false;
  {$IFDEF LINUX}
  FDeviceName := '/dev/ttyS0';
  {$ELSE}
  FDeviceName := 'COM1';
  {$ENDIF}
  FBaudRate := br_19200;
  FDataBits := db8bits;
  FParity := pEven;
  FStopBits := sbOne;
  FSoftflow := false;
  FHardflow := false;
  FFlowControl := fcNone;

  FSerial := TBlockSerial.Create;
  FCritSectionReadBuffer := TCriticalSection.Create;
  FDataAvailableEvent := TEvent.Create(nil, true, false, '');
end;

destructor TCustomSerial.Destroy;
begin
  if Assigned(FInternalReadThread) then
  begin
    FInternalReadThread.FreeOnTerminate := false;
    FInternalReadThread.Terminate;
    FInternalReadThread.WaitFor;
    FInternalReadThread.Free;
    FInternalReadThread := nil;
  end;
  if Assigned(FSerial) then FSerial.Free;
  if Assigned(FCritSectionReadBuffer) then FCritSectionReadBuffer.Free;
  if Assigned(FDataAvailableEvent) then FDataAvailableEvent.Free;

  inherited Destroy;
end;

procedure TCustomSerial.DeviceOpen;
begin
  FSerial.Connect(FDeviceName);
  if FSerial.Handle = INVALID_HANDLE_VALUE then
    raise Exception.Create('could not open device:'+FDeviceName+', internal device:'+FSerial.Device);

  ConfigSerial;

  FInternalReadThread := TSerialReadThread.Create(FSerial);
{$IFDEF FPC}
  FInternalReadThread.OnReadCallback := @Self.SerialReadCallback;
{$ELSE}
  FInternalReadThread.OnReadCallback := Self.SerialReadCallback;
{$ENDIF}
  FInternalReadThread.Start;
end;

procedure TCustomSerial.DeviceClose;
begin
  //destroy read thread
  if Assigned(FInternalReadThread) then
  begin
    FInternalReadThread.FreeOnTerminate := false;
    FInternalReadThread.Terminate;
    FInternalReadThread.WaitFor;
    FInternalReadThread.Free;
    FInternalReadThread := nil;
  end;

  if FSerial.Handle <> INVALID_HANDLE_VALUE then
  begin
    FSerial.Flush;
    FSerial.Purge;
    FSerial.CloseSocket;
  end;
end;

procedure TCustomSerial.ConfigSerial;
begin
  if FSerial.Handle <> INVALID_HANDLE_VALUE then
    FSerial.Config(ConstsBaud[FBaudRate], ConstsBits[FDataBits], ConstsParity[FParity],
    ConstsStopBits[FStopBits], FSoftflow, FHardflow);
end;

procedure TCustomSerial.SerialReadCallback(AData: string);
begin
  FCritSectionReadBuffer.Enter;
  try
    FInternalReadBuffer := FInternalReadBuffer + AData;
    if length(FInternalReadBuffer) > 5000 then FInternalReadBuffer := '';
    if length(FInternalReadBuffer) <> 0 then FDataAvailableEvent.SetEvent;
  finally
    FCritSectionReadBuffer.Leave;
  end;
end;

procedure TCustomSerial.SetActive(AValue: boolean);
begin
  if AValue = FActive then exit;

  if AValue = true then DeviceOpen
  else DeviceClose;

  FActive := AValue;
end;

procedure TCustomSerial.SetDeviceName(AValue: string);
begin
  if FDeviceName = AValue then exit;

  if FActive = false then FDeviceName := AValue
  else
  begin
    Active := false;
    FDeviceName := AValue;
    Active := true;
  end;
end;

procedure TCustomSerial.SetBaudRate(AValue: TBaudRate);
begin
  if AValue = FBaudRate then exit;

  FBaudRate := AValue;
  ConfigSerial;
end;

procedure TCustomSerial.SetDataBits(AValue: TDataBits);
begin
  if AValue = FDataBits then exit;

  FDataBits := AValue;
  ConfigSerial;
end;

procedure TCustomSerial.SetParity(AValue: TParity);
begin
  if AValue = FParity then exit;

  FParity := AValue;
  ConfigSerial;
end;

procedure TCustomSerial.SetStopBits(AValue: TStopBits);
begin
  if AValue = FStopBits then exit;

  FStopBits := AValue;
  ConfigSerial;
end;

procedure TCustomSerial.SetFlowControl(AValue: TFlowControl);
begin
  if AValue = FFlowControl then exit;

  FFlowControl := AValue;
  case FFlowControl of
    fcXonXoff:
    begin
      FSoftflow:=true;
      FHardflow:=false;
    end;
    fcHardware:
    begin
      FSoftflow:=false;
      FHardflow:=true;
    end;
    else
    begin
      FSoftflow:=false;
      FHardflow:=false;
    end;
  end;
  ConfigSerial;
end;

procedure TCustomSerial.Open;
begin
  Active := true;
end;

procedure TCustomSerial.Close;
begin
  Active := false;
end;

function TCustomSerial.DataAvailable: boolean;
begin
  if FDataAvailableEvent.WaitFor(0) <> wrSignaled then Result := false
  else Result := true;
end;

function TCustomSerial.ReadData: string;
begin
  FCritSectionReadBuffer.Enter;
  try
    {$IFDEF FPC}
    Result := cp1251toutf8(FInternalReadBuffer);
    {$ELSE}
    Result := FInternalReadBuffer;
    {$ENDIF}
    FInternalReadBuffer := '';
    FDataAvailableEvent.ResetEvent;
  finally
    FCritSectionReadBuffer.Leave;
  end;
end;

function TCustomSerial.WriteString(AInput: string): integer;
var str: AnsiString;
begin
  str := AInput;
  Result := WriteBuffer(str[1], length(str));
end;

function TCustomSerial.WriteBuffer(var ABuf; ASize: integer): integer;
begin
  Result := FSerial.SendBuffer(Pointer(@ABuf), ASize);
end;

end.
