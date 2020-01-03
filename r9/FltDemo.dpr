/// <summary>
/// ���͹���
/// </summary>
Library FltDemo;

uses
  ShareMem,
  SysUtils,
  Forms,
  Windows,
  Classes,
  MaXingFltForm in 'MaXingFltForm.pas' {frmMaXingFlt};

{$R *.res}


var
  /// <summary>
  /// ���������ַ���
  /// </summary>
  FFilterStr: ansistring;

  /// <summary>
  /// ���͹�������
  /// </summary>
  ssFltSet: TStringList;

  /// <summary>
  /// �Ƿ�ɾ������
  /// </summary>
  FDeleteFlag: boolean;

type

  /// <summary>
  /// ������������У����
  /// </summary>
  TOneDebugResult = record
    /// <summary>
    /// ��������(������¼����#13#10�ָ�)
    /// </summary>
    FilterStr: ansistring;

    /// <summary>
    /// У����(������¼����#13#10�ָ�)
    /// </summary>
    ResultStr: ansistring;
    /// <summary>
    /// �Ƿ񲻷����������˳����ͣ�0-������1-��2-����
    /// </summary>
    DeleteFlag: integer;
  end;

  /// <summary>
  /// ����У�鷵�ؽ���ṹ
  /// </summary>
  TDebugResult = record
    /// <summary>
    /// ��������
    /// </summary>
    FilterName: ansistring;
    /// <summary>
    /// ȫ��������������У����
    /// </summary>
    ArrResult: array of TOneDebugResult;
    /// <summary>
    /// ����У������(����֧�־ɰ�У����)
    /// </summary>
    StrResult: ansistring;
    /// <summary>
    /// �����ݴ�
    /// </summary>
    LocalErrTimes: integer;
    /// <summary>
    /// ���ݴ�������
    /// </summary>
    SupErrTimes: integer;
    /// <summary>
    /// ���ճ�����������ݴ�
    /// </summary>
    FinallyErrTimes: integer;
  end;

  /// <summary>
  /// DLL��ں���
  /// </summary>
  /// <remarks>
  /// �û����ڸú����жԹ��˲�����г�ʼ�������Լ���Դ�ͷŴ���
  /// </remarks>

procedure DLLEntryPoint(dwReason: DWORD);
begin
  case dwReason of
    DLL_PROCESS_ATTACH: // DLL����
      begin
        FFilterStr := '';
        FDeleteFlag := true;
        ssFltSet := TStringList.Create;
      end;
    DLL_PROCESS_DETACH: // DLL�˳�
      begin
        ssFltSet.Free;
      end;
  end;
end;

/// <summary>
/// ��ȡ���˲��������
/// </summary>
/// <returns>
/// ���˲��������, ������Ӧ�ò������еĹ���ģ��ͬ��
/// </returns>
function GetFilterName: PAnsiChar; stdcall;
begin
  Result := '���͹���V1';
end;

/// <summary>
/// ��ȡ���˲���İ汾��Ϣ
/// </summary>
/// <returns>
/// ���˲���İ汾��Ϣ
/// </returns>
function GetVersion: PAnsiChar; stdcall;
begin
  Result := '1.0.0';
end;

/// <summary>
/// ��ȡ���˲����������Ϣ
/// </summary>
/// <returns>
/// ���˲����������Ϣ
/// </returns>
function GetAuthor: PAnsiChar; stdcall;
begin
  Result := '����Ӯ�ʿƼ����޹�˾';
end;

/// <summary>
/// ��ȡ���˲���Ĺ��������ַ���
/// </summary>
/// <returns>
/// ���������ַ���
/// </returns>
function GetFilterStr(): PAnsiChar; stdcall;
begin
  Result := PAnsiChar(FFilterStr);
end;

/// <summary>
/// ���ù��˲���Ĺ��������ַ���
/// </summary>
/// <param name="Astr">
/// ���������ַ���
/// </param>
procedure SetFilterStr(Astr: PAnsiChar); stdcall;
begin
  FFilterStr := Astr;
end;

/// <summary>
/// ִ�й��˲���
/// </summary>
/// <param name="AChip">
/// Ҫ���й��˵�һ����ʽͶע���磺3313011301303
/// </param>
/// <returns>
/// ��������ĵ�ʽͶע�������й�����������Ӧ�������򷵻�0�����򷵻�1
/// </returns>
function FltExecute(AChip: PAnsiChar): integer; stdcall;

var
  sTemp: string;
  bFind: boolean;
begin
  Result := 0;

  // todo��ִ�й��˲���
  sTemp := GetMaXingD(AChip);
  bFind := (ssFltSet.IndexOf(sTemp) >= 0);
  // �����ж�
  if (bFind and FDeleteFlag) or ((not bFind) and (not FDeleteFlag)) then
    Result := 1;
end;

/// <summary>
/// ����У��
/// </summary>
/// <param name="AChip">
/// Ҫ���й��˵�һ����ʽͶע���磺3313011301303
/// </param>
/// <param name="bShowAll">
/// <para>
/// �Ƿ���ʾȫ������У����
/// </para>
/// <para>
/// ���ΪFalse����ֻ���ز����Ϲ���������У���������򷵻�ȫ��У����
/// </para>
/// </param>
/// <returns>
/// �����ĵ�ʽͶע�Ĺ���У����Ϣ
/// </returns>
function FltDebug(AChip: PAnsiChar; bShowAll: boolean = false): TDebugResult; stdcall;

var
  sTemp: string;
  bFind, bDelete: boolean;
begin
  // ��ʼ����
  SetLength(Result.ArrResult, 0);
  Result.StrResult := '';
  Result.FilterName := GetFilterName();
  Result.LocalErrTimes := 0;
  Result.SupErrTimes := 0;
  Result.FinallyErrTimes := 0;

  // todo������У��
  sTemp := GetMaXingD(AChip);
  bFind := (ssFltSet.IndexOf(sTemp) >= 0);
  bDelete := (bFind and FDeleteFlag) or ((not bFind) and (not FDeleteFlag));
  if bDelete then
    Inc(Result.LocalErrTimes);
  if bShowAll or bDelete then
  begin
    SetLength(Result.ArrResult, 1);
    Result.ArrResult[0].FilterStr := '...';
    Result.ArrResult[0].ResultStr := sTemp;
    // ɾ����־
    if bDelete then
      Result.ArrResult[0].DeleteFlag := 1
    else
      Result.ArrResult[0].DeleteFlag := 0;
  end;
end;

/// <summary>
/// �򿪹����������ô��� <br />
/// </summary>
/// <returns>
/// �����������óɹ����
/// </returns>
/// <remarks>
/// �������û�ȷ�Ϻ�ʱˢ��FFilterStrֵ
/// </remarks>
function FltOpen(hApp: integer = 0): boolean; stdcall;

var
  oldApp: integer;
begin
  oldApp := Application.Handle;
  Application.Handle := hApp;
  frmMaXingFlt := TfrmMaXingFlt.Create(nil);
  frmMaXingFlt.SetFilter(FFilterStr);
  frmMaXingFlt.ShowModal;
  // todo�����ù�������
  Result := not frmMaXingFlt.bCancel;
  if Result then
    FFilterStr := frmMaXingFlt.GetFilter();
  frmMaXingFlt.Free;
  Application.Handle := oldApp;
end;

/// <summary>
/// ���������Ϸ�����֤���ú�����ʱ��Ч����ֱ�ӷ���True���ɣ�
/// </summary>
/// <returns>
/// �����������ʽ������ȷ�򷵻�true�����򷵻�false
/// </returns>
function FltValidate(FltStr: PAnsiChar): boolean; stdcall;
begin
  Result := true;
end;

/// <summary>
/// ��������Ԥ�����ڸú����п�ִ�й����������Ż������Լ�������������Ч�Լ���
/// </summary>
/// <returns>
/// ���������Ԥ����ɹ��򷵻�true�����򷵻�false
/// </returns>
function FltPrepare(): boolean; stdcall;

var
  sFlt: string;
begin
  Result := false;

  // todo��׼����������
  sFlt := Trim(FFilterStr);
  if Length(sFlt) < 3 then
    Exit;

  FDeleteFlag := true;
  if sFlt[2] = '|' then
  begin
    FDeleteFlag := (sFlt[1] in ['d', 'D']);
    sFlt := Copy(sFlt, 3, Length(sFlt));
  end;

  ssFltSet.Text := StringReplace(sFlt, ';', #13#10, [rfReplaceAll]);
  Result := (ssFltSet.Count > 0);
end;

/// <summary>
/// ���ó���ѡ��
/// </summary>
/// <param name="ASelect">
/// ����ѡ�񴮣�14λ��Y-ѡ��n-δѡ�񣩣��磺YYYnnYYYYYnYYn
/// </param>
procedure SetZc9Selected(ASelect: PAnsiChar); stdcall;

var
  i: integer;
begin
  GZc9Select := ASelect;
  GZc9SelCount := 0;
  for i := 1 to Length(GZc9Select) do
    if GZc9Select[i] = 'Y' then
      Inc(GZc9SelCount);
end;

// DLL����ӿں���
exports

  FltExecute,
  FltDebug,
  FltOpen,
  FltPrepare,
  GetFilterStr,
  SetFilterStr,
  GetFilterName,
  GetVersion,
  GetAuthor,
  SetZc9Selected
    ;

begin
  DLLProc := @DLLEntryPoint;
  DLLEntryPoint(DLL_PROCESS_ATTACH);

end.
