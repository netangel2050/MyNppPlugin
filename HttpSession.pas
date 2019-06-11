unit HttpSession;

{\$DEFINE UseIndy}

interface

uses
{$IFDEF MSWINDOWS}
  Winapi.Windows,
{$ENDIF}
  System.SysUtils,
  System.Classes,
  System.DateUtils,
{$IFDEF UseIndy}
  IdHTTP,
  IdCookieManager,
  IdSSLOpenSSL,
  IdCompressorZLib,
{$ELSE}
  System.Net.URLClient,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
{$ENDIF}
  System.RegularExpressions,
  System.Generics.Collections;

type


  // 自动释放用
  IHttpParams = interface
    function Add(AKey, AVal: string): IHttpParams;
    function &Set(AKey, AVal: string): IHttpParams;
    function Del(AKey: string): IHttpParams;
    function GetParams: string;

    property Params: string read GetParams;
  end;

  THttpParams = class(TInterfacedObject, IHttpParams)
  private
    FItems: TDictionary<string, string>;
    function GetParams: string;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function Add(AKey, AVal: string): IHttpParams;
    function &Set(AKey, AVal: string): IHttpParams;
    function Del(AKey: string): IHttpParams;
  end;


  THttpSession = class
  private
  {$IFDEF UseIndy}
    FHttp: TIdHTTP;
    FIdSSLHandler: TIdSSLIOHandlerSocketOpenSSL;
    FIdCookieManager: TIdCookieManager;
    FIdCompressor: TIdCompressorZLib;
  {$ELSE}
    FHttp: TNetHTTPClient;
    FHttpReq: TNetHTTPRequest;
  {$ENDIF}
    FEncdoing: TEncoding;

    // utf8
    function Post(const AURL: string; AArgs: array of const;
      AParams: string; ATimeout: Integer = -1): string;

    function Get(const AUrl: string; AArgs: array of const;
      ATimeout: Integer = -1): string;


    function GetCookies: string;
  public
    constructor Create(AEncoding: TEncoding = nil);
    destructor Destroy; override;

    function GetStream(const AUrl: string; AStream: TStream;
      ATimeout: Integer = -1): Boolean;

    function GetRegEx(AUrl: string; AArgs: array of const; APattern: string;
      ATimeout: Integer = -1): TMatch;

    function GetText(AUrl: string; AArgs: array of const;
      ATimeout: Integer = -1): string;

    // 自动解析版本
    function PostJSON<P, R>(const AURL: string; AArgs: array of const;
      AParams: P; ATimeout: Integer = -1): R;
    function PostJSONEmpty<R>(const AURL: string; AArgs: array of const;
      ATimeout: Integer = -1): R;

    function PostJSONText(const AURL: string; AArgs: array of const;
      AJsonStr: string; ATimeout: Integer = -1): string;


    function PostStream(const AUrl: string; AStream: TStream; AOut: TStream;
      ATimeout: Integer = -1): Boolean;


    function PostText(AUrl: string; AArgs: array of const; AParams: IHttpParams;
      ATimeout: Integer = -1): string;

    function PostText2(AUrl: string; AParams: TStrings;
      ATimeout: Integer = -1): string;

    function GetJSON<T>(const AUrl: string; AArgs: array of const;
      ATimeout: Integer = -1): T;
    function GetXML<T>(const AUrl: string; AArgs: array of const;
      ATimeout: Integer = -1; AThread: Boolean = True): T;

    function GetImage(AUrl: string; AArgs: array of const; AOut: TStream;
       ATimeout: Integer = -1): Boolean;

    procedure SetCookies(const ACookies: string);

    function Clone: THttpSession;
    procedure Disconnect;
  public
    property Cookies: string read GetCookies write SetCookies;
  end;

  function DateTimeToUnix(const AValue: TDateTime): Int64; inline;
  function GetCurTime10: Int64; inline;
  function GetCurTime13: Int64; inline;


implementation

uses
  MarshalCommon,
  XmlMarshal,
  JsonMarshal;

const
  USER_AGENT = 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) CriOS/56.0.2924.75 Mobile/14E5239e Safari/602.1';
  MAX_RETRY  = 2;

function DateTimeToUnix(const AValue: TDateTime): Int64; inline;
begin
  Result := (System.DateUtils.DateTimeToUnix(AValue) - 28800);
end;

function GetCurTime10: Int64;
begin
  Result := DateTimeToUnix(Now);
end;

function GetCurTime13: Int64;
begin
  Result := GetCurTime10 * 1000 + Random(999);;
end;




{ THttpSession }

function THttpSession.Clone: THttpSession;
begin
  Result := THttpSession.Create(FEncdoing);
  Result.Cookies := Cookies;
end;

constructor THttpSession.Create(AEncoding: TEncoding);
begin
  inherited Create;

  FEncdoing := AEncoding;
  if FEncdoing = nil then
    FEncdoing := TEncoding.UTF8;
{$IFDEF UseIndy}
  FHttp := TIdHTTP.Create(nil);
  FIdCompressor := TIdCompressorZLib.Create(nil);
  FIdSSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  FIdCookieManager := TIdCookieManager.Create(nil);

  FHttp.Compressor := FIdCompressor;
  FHttp.IOHandler := FIdSSLHandler;
  FHttp.CookieManager := FIdCookieManager;

  FHttp.HandleRedirects := True;
  FHttp.Request.UserAgent := USER_AGENT;
  FHttp.Request.Accept := '*/*';
  FHttp.Request.AcceptEncoding := 'gzip';
  FHttp.Request.Connection := 'keep-alive';
  FHttp.Request.AcceptLanguage := 'zh-CN,zh;q=0.8';
{$ELSE}
  FHttp := TNetHTTPClient.Create(nil);
  FHttp.UserAgent := USER_AGENT;
  FHttpReq := TNetHTTPRequest.Create(nil);
  FHttpReq.Client := FHttp;
  FHttpReq.Accept := '*/*';
//  FHttpReq.AcceptEncoding := 'gzip';
  FHttpReq.AcceptLanguage := 'zh-CN,zh;q=0.8';
{$ENDIF}
end;

destructor THttpSession.Destroy;
begin
{$IFDEF UseIndy}
  FreeAndNil(FIdCookieManager);
  FreeAndNil(FIdSSLHandler);
  FreeAndNil(FIdCompressor);
{$ELSE}
  FreeAndNil(FHttpReq);
{$ENDIF}
  FreeAndNil(FHttp);
  inherited;
end;

procedure THttpSession.Disconnect;
begin
{$IFDEF UseIndy}
  if FHttp.Connected then
    FHttp.Disconnect;
{$ENDIF}
end;

function THttpSession.Get(const AUrl: string; AArgs: array of const;
  ATimeout: Integer): string;
var
  LResponse: TStringStream;
  I: Integer;
begin
  Result := '';
{$IFDEF UseIndy}
  FHttp.ReadTimeout := ATimeout;
{$ELSE}
  FHttpReq.ResponseTimeout := ATimeout;
  FHttpReq.ConnectionTimeout := ATimeout;
{$ENDIF}
  LResponse := TStringStream.Create('', FEncdoing);
  try
    for I := 1 to MAX_RETRY do
    begin
      try
        LResponse.Clear;
      {$IFDEF UseIndy}
        FHttp.Get(Format(AUrl, AArgs), LResponse);
      {$ELSE}
        FHttpReq.Get(Format(AUrl, AArgs), LResponse);
      {$ENDIF}
        Break;
      except
        on E: Exception do
        begin
          if I = MAX_RETRY then
            raise Exception.Create(E.Message)
          else
            Sleep(300);
        end;
      end;
    end;
    if LResponse.Size > 0 then
      Result := LResponse.DataString;
  finally
    LResponse.Free;
  end;
end;

function THttpSession.GetCookies: string;
begin
{$IFDEF UseIndy}
  Result := FHttp.Request.CustomHeaders.Values['Cookie'];
  if Result.Trim = '' then
     Result := FHttp.Request.RawHeaders.Values['Cookie'];
{$ELSE}
  Result := FHttpReq.CustomHeaders['Cookie'];
  //if Result.Trim = '' then
  //   Result := FHttp.CookieManager.CookieHeaders()
{$ENDIF}
end;

function THttpSession.GetImage(AUrl: string; AArgs: array of const; AOut: TStream; ATimeout: Integer): Boolean;
begin
{$IFDEF UseIndy}
  FHttp.Request.Accept := 'image/*,*/*;q=0.8';
  FHttp.Request.ContentType := '';
{$ELSE}
  FHttpReq.Accept := 'image/*,*/*;q=0.8';
  FHttp.ContentType := '';
{$ENDIF}
  Result := GetStream(Format(AUrl, AArgs), AOut, ATimeout);
end;

function THttpSession.GetJSON<T>(const AUrl: string; AArgs: array of const;
  ATimeout: Integer): T;
begin
{$IFDEF UseIndy}
  FHttp.Request.Accept := 'application/json, text/plain, */*';
{$ELSE}
  FHttpReq.Accept := 'application/json, text/plain, */*';
{$ENDIF}
  TJsonMarshal.UnMarshal<T>(Get(AUrl, AArgs, ATimeout), Result);
end;

function THttpSession.GetRegEx(AUrl: string; AArgs: array of const;
  APattern: string; ATimeout: Integer): TMatch;
begin
{$IFDEF UseIndy}
  FHttp.Request.Accept := 'text/plain, */*';
  FHttp.Request.ContentType := '';
{$ELSE}
  FHttpReq.Accept := 'image/*,*/*;q=0.8';
  FHttp.ContentType := '';
{$ENDIF}
  Result := TRegEx.Match(Get(AUrl, AArgs, ATimeout), APattern);
end;

function THttpSession.GetStream(const AUrl: string; AStream: TStream;
  ATimeout: Integer): Boolean;
begin
  AStream.Position := 0;
{$IFDEF UseIndy}
  FHttp.ReadTimeout := ATimeout;
  FHttp.Get(AUrl, AStream);
{$ELSE}
  FHttpReq.ResponseTimeout := ATimeout;
  FHttpReq.Get(AUrl, AStream);
{$ENDIF}
  Result := AStream.Size > 0;
  if Result then
    AStream.Position := 0;
end;

function THttpSession.GetText(AUrl: string; AArgs: array of const;
  ATimeout: Integer): string;
begin
{$IFDEF UseIndy}
  FHttp.Request.Accept := 'text/plain, */*';
  FHttp.Request.ContentType := '';
{$ELSE}
  FHttpReq.Accept := 'text/plain, */*';
  FHttp.ContentType := '';
{$ENDIF}
  Result := Get(AUrl, AArgs, ATimeout);
end;

function THttpSession.GetXML<T>(const AUrl: string; AArgs: array of const;
  ATimeout: Integer; AThread: Boolean): T;
var
  LData: string;
  LResult: T;
begin
{$IFDEF UseIndy}
  FHttp.Request.Accept := 'text/xml, text/plain, */*';
  FHttp.Request.ContentType := '';
{$ELSE}
  FHttpReq.Accept := 'text/xml, text/plain, */*';
  FHttp.ContentType := '';
{$ENDIF}
  if AThread then
  begin
    LData := Get(AUrl, AArgs, ATimeout);
    TThread.Synchronize(nil, procedure begin
      TXmlMarshal.UnMarshal<T>(LData, LResult);
    end);
    Result := LResult;
  end else
    TXmlMarshal.UnMarshal<T>(Get(AUrl, AArgs, ATimeout), Result);
end;

function THttpSession.Post(const AURL: string; AArgs: array of const;
  AParams: string; ATimeout: Integer): string;
var
  LParams, LResponse: TStringStream;
  I: Integer;
begin
  Result := '';
{$IFDEF UseIndy}
  FHttp.ReadTimeout := ATimeout;
{$ELSE}
  FHttpReq.ResponseTimeout := ATimeout;
{$ENDIF}
  LResponse := TStringStream.Create('', FEncdoing);
  try
    LParams := TStringStream.Create('', FEncdoing);
    try
      LParams.WriteString(AParams);
      LParams.Position := 0;

      for I := 1 to MAX_RETRY do
      begin
        try
          LResponse.Clear;
        {$IFDEF UseIndy}
          FHttp.Post(Format(AURL, AArgs), LParams, LResponse);
        {$ELSE}
          FHttpReq.Post(Format(AURL, AArgs), LParams, LResponse);
        {$ENDIF}
          Break;
        except
          on E: Exception do
          begin
            if I = MAX_RETRY then
              raise Exception.Create(E.Message)
            else
              Sleep(300);
          end;
        end;
      end;
      if LResponse.Size > 0 then
        Result := LResponse.DataString;
    finally
      LParams.Free;
    end;
  finally
    LResponse.Free;
  end;
end;

function THttpSession.PostJSON<P, R>(const AURL: string;
  AArgs: array of const; AParams: P; ATimeout: Integer): R;
var
  LJsonData: string;
begin
  TJsonMarshal.Marshal<P>(AParams, LJsonData);
{$IFDEF UseIndy}
  FHttp.Request.Accept := 'application/json, text/plain, */*';
  FHttp.Request.ContentType := 'application/json;charset=UTF-8';
{$ELSE}
  FHttpReq.Accept := 'application/json, text/plain, */*';
  FHttp.ContentType := 'application/json;charset=UTF-8';
{$ENDIF}
  TJsonMarshal.UnMarshal<R>(Post(AURL, AArgs, LJsonData), Result);
end;

function THttpSession.PostJSONText(const AURL: string; AArgs: array of const;
  AJsonStr: string; ATimeout: Integer): string;
begin
{$IFDEF UseIndy}
  FHttp.Request.Accept := 'application/json, text/plain, */*';
  FHttp.Request.ContentType := 'application/json;charset=UTF-8';
{$ELSE}
  FHttpReq.Accept := 'application/json, text/plain, */*';
  FHttp.ContentType := 'application/json;charset=UTF-8';
{$ENDIF}
  Result := Post(AURL, AArgs, AJsonStr);
end;

function THttpSession.PostStream(const AUrl: string; AStream: TStream;
  AOut: TStream; ATimeout: Integer): Boolean;
begin
  AStream.Position := 0;
{$IFDEF UseIndy}
  FHttp.ReadTimeout := ATimeout;
  FHttp.Post(AUrl, AStream, AOut);
{$ELSE}
  FHttpReq.ResponseTimeout := ATimeout;
  FHttpReq.Post(AUrl, AStream, AOut);
{$ENDIF}
  Result := AOut.Size > 0;
  if Result then
    AOut.Position := 0;
end;

function THttpSession.PostJSONEmpty<R>(const AURL: string;
  AArgs: array of const; ATimeout: Integer): R;
begin
  Result := PostJSON<string, R>(AURL, AArgs, '{}', ATimeout);
end;

function THttpSession.PostText(AUrl: string; AArgs: array of const;
  AParams: IHttpParams; ATimeout: Integer): string;
begin
{$IFDEF UseIndy}
  FHttp.Request.Accept := 'text/plain, */*';
  FHttp.Request.ContentType := '';
{$ELSE}
  FHttpReq.Accept := 'text/plain, */*';
  FHttp.ContentType := '';
{$ENDIF}
  Result := Post(AUrl, AArgs, AParams.Params, ATimeout);
end;

function THttpSession.PostText2(AUrl: string; AParams: TStrings;
  ATimeout: Integer): string;
var
  LResponse: TStringStream;
  I: Integer;
begin
  Result := '';
  LResponse := TStringStream.Create('', FEncdoing);
  try
  {$IFDEF UseIndy}
    FHttp.Request.Accept := 'text/plain, */*';
    FHttp.Request.ContentType := '';
  {$ELSE}
    FHttpReq.Accept := 'text/plain, */*';
    FHttp.ContentType := '';
  {$ENDIF}
    for I := 1 to MAX_RETRY do
    begin
      try
      {$IFDEF UseIndy}
        FHttp.Post(AUrl, AParams, LResponse);
      {$ELSE}
        FHttpReq.Post(AUrl, AParams, LResponse);
      {$ENDIF}
        if LResponse.Size > 0 then
          Result := LResponse.DataString;
        Break;
      except
        on E: Exception do
        begin
          if I = MAX_RETRY then
            raise Exception.Create(E.Message);
        end;
      end;
    end;
  finally
    LResponse.Free;
  end;
end;

procedure THttpSession.SetCookies(const ACookies: string);
begin
{$IFDEF UseIndy}
  FHttp.Request.CustomHeaders.Values['Cookie'] := ACookies;
{$ELSE}
  FHttpReq.CustomHeaders['Cookie'] := ACookies;
{$ENDIF}
end;

{ THttpParams }

constructor THttpParams.Create;
begin
  inherited Create;
  FItems := TDictionary<string, string>.Create;
end;

destructor THttpParams.Destroy;
begin
  FItems.Free;
  inherited;
end;

function THttpParams.GetParams: string;
var
  LItem: TPair<string, string>;
  I: Integer;
begin
  Result := '';
  I := 0;
  for LItem in FItems do
  begin
    if I > 0 then
      Result := Result + '&';
    Result := Result + LItem.Key + '=' + LItem.Value;
    Inc(I);
  end;
end;

function THttpParams.Add(AKey, AVal: string): IHttpParams;
begin
  Result := Self;
  FItems.Add(AKey, AVal);
end;

function THttpParams.Del(AKey: string): IHttpParams;
begin
  Result := Self;
  if FItems.ContainsKey(AKey) then
    FItems.Remove(AKey);
end;

function THttpParams.&Set(AKey, AVal: string): IHttpParams;
begin
  Result := Self;
  FItems.AddOrSetValue(AKey, AVal);
end;

end.
