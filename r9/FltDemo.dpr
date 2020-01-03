/// <summary>
/// 码型过滤
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
  /// 过滤条件字符串
  /// </summary>
  FFilterStr: ansistring;

  /// <summary>
  /// 码型过滤条件
  /// </summary>
  ssFltSet: TStringList;

  /// <summary>
  /// 是否删除操作
  /// </summary>
  FDeleteFlag: boolean;

type

  /// <summary>
  /// 单个过滤条件校验结果
  /// </summary>
  TOneDebugResult = record
    /// <summary>
    /// 过滤条件(多条记录间以#13#10分割)
    /// </summary>
    FilterStr: ansistring;

    /// <summary>
    /// 校验结果(多条记录间以#13#10分割)
    /// </summary>
    ResultStr: ansistring;
    /// <summary>
    /// 是否不符合条件（滤除类型：0-保留，1-错，2-超错）
    /// </summary>
    DeleteFlag: integer;
  end;

  /// <summary>
  /// 过滤校验返回结果结构
  /// </summary>
  TDebugResult = record
    /// <summary>
    /// 过滤名称
    /// </summary>
    FilterName: ansistring;
    /// <summary>
    /// 全部单个过滤条件校验结果
    /// </summary>
    ArrResult: array of TOneDebugResult;
    /// <summary>
    /// 过滤校验结果串(用于支持旧版校验结果)
    /// </summary>
    StrResult: ansistring;
    /// <summary>
    /// 本级容错
    /// </summary>
    LocalErrTimes: integer;
    /// <summary>
    /// 超容错出错次数
    /// </summary>
    SupErrTimes: integer;
    /// <summary>
    /// 最终出错次数（总容错）
    /// </summary>
    FinallyErrTimes: integer;
  end;

  /// <summary>
  /// DLL入口函数
  /// </summary>
  /// <remarks>
  /// 用户可在该函数中对过滤插件进行初始化处理以及资源释放处理
  /// </remarks>

procedure DLLEntryPoint(dwReason: DWORD);
begin
  case dwReason of
    DLL_PROCESS_ATTACH: // DLL启动
      begin
        FFilterStr := '';
        FDeleteFlag := true;
        ssFltSet := TStringList.Create;
      end;
    DLL_PROCESS_DETACH: // DLL退出
      begin
        ssFltSet.Free;
      end;
  end;
end;

/// <summary>
/// 获取过滤插件的名称
/// </summary>
/// <returns>
/// 过滤插件的名称, 该名称应该不与现有的过滤模块同名
/// </returns>
function GetFilterName: PAnsiChar; stdcall;
begin
  Result := '码型过滤V1';
end;

/// <summary>
/// 获取过滤插件的版本信息
/// </summary>
/// <returns>
/// 过滤插件的版本信息
/// </returns>
function GetVersion: PAnsiChar; stdcall;
begin
  Result := '1.0.0';
end;

/// <summary>
/// 获取过滤插件的作者信息
/// </summary>
/// <returns>
/// 过滤插件的作者信息
/// </returns>
function GetAuthor: PAnsiChar; stdcall;
begin
  Result := '北京赢彩科技有限公司';
end;

/// <summary>
/// 获取过滤插件的过滤条件字符串
/// </summary>
/// <returns>
/// 过滤条件字符串
/// </returns>
function GetFilterStr(): PAnsiChar; stdcall;
begin
  Result := PAnsiChar(FFilterStr);
end;

/// <summary>
/// 设置过滤插件的过滤条件字符串
/// </summary>
/// <param name="Astr">
/// 过滤条件字符串
/// </param>
procedure SetFilterStr(Astr: PAnsiChar); stdcall;
begin
  FFilterStr := Astr;
end;

/// <summary>
/// 执行过滤操作
/// </summary>
/// <param name="AChip">
/// 要进行过滤的一个单式投注，如：3313011301303
/// </param>
/// <returns>
/// 如果给定的单式投注符合所有过滤条件（即应保留）则返回0，否则返回1
/// </returns>
function FltExecute(AChip: PAnsiChar): integer; stdcall;

var
  sTemp: string;
  bFind: boolean;
begin
  Result := 0;

  // todo：执行过滤操作
  sTemp := GetMaXingD(AChip);
  bFind := (ssFltSet.IndexOf(sTemp) >= 0);
  // 过滤判断
  if (bFind and FDeleteFlag) or ((not bFind) and (not FDeleteFlag)) then
    Result := 1;
end;

/// <summary>
/// 过滤校验
/// </summary>
/// <param name="AChip">
/// 要进行过滤的一个单式投注，如：3313011301303
/// </param>
/// <param name="bShowAll">
/// <para>
/// 是否显示全部过滤校验结果
/// </para>
/// <para>
/// 如果为False，则只返回不符合过滤条件的校验结果，否则返回全部校验结果
/// </para>
/// </param>
/// <returns>
/// 给定的单式投注的过滤校验信息
/// </returns>
function FltDebug(AChip: PAnsiChar; bShowAll: boolean = false): TDebugResult; stdcall;

var
  sTemp: string;
  bFind, bDelete: boolean;
begin
  // 初始处理
  SetLength(Result.ArrResult, 0);
  Result.StrResult := '';
  Result.FilterName := GetFilterName();
  Result.LocalErrTimes := 0;
  Result.SupErrTimes := 0;
  Result.FinallyErrTimes := 0;

  // todo：过滤校验
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
    // 删除标志
    if bDelete then
      Result.ArrResult[0].DeleteFlag := 1
    else
      Result.ArrResult[0].DeleteFlag := 0;
  end;
end;

/// <summary>
/// 打开过滤条件设置窗口 <br />
/// </summary>
/// <returns>
/// 过滤条件设置成功与否
/// </returns>
/// <remarks>
/// 必须在用户确认后及时刷新FFilterStr值
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
  // todo：设置过滤条件
  Result := not frmMaXingFlt.bCancel;
  if Result then
    FFilterStr := frmMaXingFlt.GetFilter();
  frmMaXingFlt.Free;
  Application.Handle := oldApp;
end;

/// <summary>
/// 过滤条件合法性验证（该函数暂时无效，可直接返回True即可）
/// </summary>
/// <returns>
/// 如过滤条件格式设置正确则返回true，否则返回false
/// </returns>
function FltValidate(FltStr: PAnsiChar): boolean; stdcall;
begin
  Result := true;
end;

/// <summary>
/// 过滤条件预处理在该函数中可执行过滤条件的优化处理以及过滤条件的有效性检验
/// </summary>
/// <returns>
/// 如过滤条件预处理成功则返回true，否则返回false
/// </returns>
function FltPrepare(): boolean; stdcall;

var
  sFlt: string;
begin
  Result := false;

  // todo：准备过滤条件
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
/// 设置场次选择串
/// </summary>
/// <param name="ASelect">
/// 场次选择串（14位，Y-选择，n-未选择），如：YYYnnYYYYYnYYn
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

// DLL对外接口函数
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
