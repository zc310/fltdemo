/// <summary>
/// ���͹��˲��ģ��
/// </summary>
unit MaXingFltForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs, StdCtrls,
  Buttons, RzButton, ExtCtrls, Graphics;

type

  /// <summary>
  /// ���͹����������ô���
  /// </summary>
  TfrmMaXingFlt = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Bevel2: TBevel;
    Label6: TLabel;
    Label7: TLabel;
    Label14: TLabel;
    lstAllMX: TListBox;
    btnAddMX: TBitBtn;
    btnAddAllMX: TBitBtn;
    btnMXDelete: TBitBtn;
    btnMXDeleteAll: TBitBtn;
    lstMXFilter: TListBox;
    Panel2: TPanel;
    btnCancel: TBitBtn;
    btnHelp: TBitBtn;
    btnOK: TBitBtn;
    Bevel1: TBevel;
    btnSave: TBitBtn;
    btnLoad: TBitBtn;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    rdbDelete: TRadioButton;
    rdbKeep: TRadioButton;
    procedure btnAddMXClick(Sender: TObject);
    procedure btnAddAllMXClick(Sender: TObject);
    procedure btnMXDeleteClick(Sender: TObject);
    procedure btnMXDeleteAllClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    { Private declarations }
  public
    bCancel: boolean;
    procedure SetFilter(str: String);
    function GetFilter(): String;
  end;

var
  frmMaXingFlt: TfrmMaXingFlt;
  /// <summary>
  /// ��ʳ���ѡ��
  /// </summary>
  GZc9Select: string = 'YYYYYYYYYYYYYY';
  /// <summary>
  /// �����ѡ������
  /// </summary>
  GZc9SelCount: integer = 14;

  /// <summary>
  /// ��������
  /// </summary>
function GetMaXingD(sChip: String): String;

implementation


{$R *.dfm}


function GetMaXingD(sChip: String): String;
var
  i: integer;
  nNumCount: array [0 .. 3] of byte;
begin
  for i := Low(nNumCount) to High(nNumCount) do
    nNumCount[i] := 0;

  for i := 1 to Length(sChip) do
  begin
    Inc(nNumCount[StrToInt(sChip[i])]);
  end;
  Result := Format('%2d-%2d-%2d', [nNumCount[3], nNumCount[1], nNumCount[0]]);;
end;

procedure TfrmMaXingFlt.btnAddMXClick(Sender: TObject);
var
  i: integer;
begin
  for i := lstAllMX.Items.Count - 1 downto 0 do
  begin
    if lstAllMX.Selected[i] then
    begin
      lstMXFilter.Items.Add(lstAllMX.Items[i]);
      lstAllMX.Items.Delete(i);
    end;
  end;
end;

procedure TfrmMaXingFlt.btnAddAllMXClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to lstAllMX.Items.Count - 1 do
  begin
    lstMXFilter.Items.Add(lstAllMX.Items[i]);
  end;
  lstAllMX.Clear;
end;

procedure TfrmMaXingFlt.btnMXDeleteClick(Sender: TObject);
var
  i: integer;
begin
  for i := lstMXFilter.Items.Count - 1 downto 0 do
  begin
    if lstMXFilter.Selected[i] then
    begin
      lstAllMX.Items.Add(lstMXFilter.Items[i]);
      lstMXFilter.Items.Delete(i);
    end;
  end;
end;

procedure TfrmMaXingFlt.btnMXDeleteAllClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to lstMXFilter.Items.Count - 1 do
  begin
    lstAllMX.Items.Add(lstMXFilter.Items[i]);
  end;
  lstMXFilter.Clear;
end;

procedure TfrmMaXingFlt.FormCreate(Sender: TObject);
var
  i, j, k: integer;
  sTemp: String;
begin
  // ������п��õ�����
  lstAllMX.Sorted := False;
  for i := 0 to GZc9SelCount do
    for j := 0 to GZc9SelCount - i do
    begin
      sTemp := Format('%2d-%2d-%2d', [i, j, GZc9SelCount - i - j]);
      if lstMXFilter.Items.IndexOf(sTemp) < 0 then
        lstAllMX.Items.Add(sTemp);
    end;

  lstAllMX.Sorted := True;
  bCancel := True;
end;

procedure TfrmMaXingFlt.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMaXingFlt.btnHelpClick(Sender: TObject);
var
  msg: String;
begin
  msg := '�����͹��ˡ�' + #13#10#13#10 + '���͹�������Ե�ע��ʤ��3����ƽ��1��������0�������������ʽ���й��ˡ�'
    + #13#10 + '���磺33111031031031 ������Ϊ 2- 3- 1'
    + #13#10 + '���磺33330313130031 ������Ϊ 4- 1- 2';
  Application.MessageBox(PChar(msg), '���͹���');
end;

procedure TfrmMaXingFlt.btnOKClick(Sender: TObject);
begin
  bCancel := False;
  Close;
end;

function TfrmMaXingFlt.GetFilter: String;
begin
  if rdbDelete.Checked then
    Result := 'D|'
  else
    Result := 'K|';
  Result := Result + StringReplace(lstMXFilter.Items.Text, #13#10, ';', [rfReplaceAll]);
end;

procedure TfrmMaXingFlt.SetFilter(str: String);
var
  i, nID: integer;
begin
  if Copy(str, 2, 1) = '|' then
  begin
    rdbDelete.Checked := (str[1] in ['d', 'D']);
    str := Copy(str, 3, Length(str));
  end;
  rdbKeep.Checked := not rdbDelete.Checked;

  lstMXFilter.Items.Text := StringReplace(str, ';', #13#10, [rfReplaceAll]);
  for i := 0 to lstMXFilter.Count - 1 do
  begin
    nID := lstAllMX.Items.IndexOf(lstMXFilter.Items[i]);
    if nID >= 0 then
      lstAllMX.Items.Delete(nID);
  end;
end;

end.
