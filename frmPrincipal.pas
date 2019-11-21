unit frmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.DBCtrls, FireDAC.Comp.Client, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Phys.FB, FireDAC.Phys.FBDef;

type
  TfrPrincipal = class(TForm)
    db: TFDConnection;
    qryDados: TFDQuery;
    ts: TFDTransaction;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    edDiretorioAlterdbIni: TEdit;
    Label3: TLabel;
    GroupBox2: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    btGravar: TButton;
    btnCarregar: TButton;
    dsDados: TDataSource;
    qryAux: TFDQuery;
    cbServidorDestino: TComboBox;
    cbPathDestino: TComboBox;
    SpeedButton2: TSpeedButton;
    edServidorAtual: TEdit;
    edPathAtual: TEdit;
    chkServidor: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCarregarClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure btGravarClick(Sender: TObject);
    procedure chkServidorClick(Sender: TObject);
    procedure cbServidorDestinoChange(Sender: TObject);
    procedure edDiretorioAlterdbIniExit(Sender: TObject);
  private
    function ConectaBanco: Boolean;
    procedure CarregaCombo(pCombo: TComboBox);
    function ValidaCadastroNovo: Boolean;
    function ValidaOK: Boolean;
    procedure CarregaIni;
    procedure GravaIni;
    procedure CarregaDados;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frPrincipal: TfrPrincipal;

implementation

{$R *.dfm}

uses IniFiles, System.Math,
     frBanco;

procedure TfrPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrPrincipal.FormCreate(Sender: TObject);
begin
  btnCarregar.Click;
end;

procedure TfrPrincipal.SpeedButton2Click(Sender: TObject);
begin
  Application.CreateForm(TfrmBanco,frmBanco);
  frmBanco.ShowModal;
  ConectaBanco;
end;

procedure TfrPrincipal.btGravarClick(Sender: TObject);
begin
  if MessageDlg('Confirma alteração?',mtConfirmation, mbYesNo, 0) = mrNo then
    Exit;

  if ValidaOK then
  begin
    if ValidaCadastroNovo then
      ShowMessage('Salvo com sucesso!');
  end;
  GravaIni;
  CarregaDados;
end;

function TfrPrincipal.ValidaOK: Boolean;
begin
  Result := True;
  if Trim(cbServidorDestino.Text) = EmptyStr then
  begin
    ShowMessage('Servidor obrigatório!');
    Result := False;
    cbServidorDestino.SetFocus;
    Exit;
  end;

  if Trim(cbPathDestino.Text) = EmptyStr then
  begin
    ShowMessage('Path obrigatório!');
    Result := False;
    cbPathDestino.SetFocus;
    Exit;
  end;
end;

function TfrPrincipal.ValidaCadastroNovo: Boolean;
begin
  Result := False;
  qryAux.Close;
  qryAux.SQL.Text := Format('SELECT count(id) as qtd FROM SERVIDOR WHERE NOMESERVIDOR = %s and PATHSERVIDOR = %s',[QuotedStr(cbServidorDestino.Text), QuotedStr(cbPathDestino.Text)]);
  qryAux.Open;
  if qryAux.FieldByName('qtd').AsInteger = 0 then
  begin
    qryAux.Close;
    qryAux.SQL.Text := ' insert into SERVIDOR (NOMESERVIDOR, PATHSERVIDOR) values (:NOMESERVIDOR, :PATHSERVIDOR);';
    qryAux.ParamByName('NOMESERVIDOR').AsString := cbServidorDestino.Text;
    qryAux.ParamByName('PATHSERVIDOR').AsString := cbPathDestino.Text;
    try
      qryAux.ExecSQL;
      Result := True;
    except on E: Exception do
      ShowMessage('Ocorreu um erro ao gravar novo registro no banco' + #13 + e.Message);
    end;
  end
  else
    Result := True;
end;

procedure TfrPrincipal.btnCarregarClick(Sender: TObject);
begin
  if not db.Connected then
    ConectaBanco;

  CarregaDados;
end;

procedure TfrPrincipal.CarregaDados;
begin
  CarregaIni;
  CarregaCombo(cbServidorDestino);
  CarregaCombo(cbPathDestino);
end;

procedure TfrPrincipal.cbServidorDestinoChange(Sender: TObject);
begin
  CarregaCombo(cbPathDestino);
end;

procedure TfrPrincipal.chkServidorClick(Sender: TObject);
begin
  GravaIni;
  CarregaCombo(cbPathDestino);
end;

function TfrPrincipal.ConectaBanco: Boolean;
var
  vIniBanco: TIniFile;
  vServidor,
  vPath    : String;
begin
  if FileExists(ChangeFileExt(Application.ExeName,'.ini')) then
  begin
    vIniBanco := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'));
    try
      db.Params.Clear;
      db.DriverName := 'FB';
      vServidor := vIniBanco.ReadString('SERVIDOR', 'NOMESERVIDOR', '');
      vPath     := vIniBanco.ReadString('PATH', 'PATHPAR', '') + '\DADOS.FDB';
      db.Params.Add(Format('Server=%s',[vServidor]));
      db.Params.Add(Format('Database=%s',[vPath]));
      db.Params.Add('User_name=SYSDBA');
      db.Params.Add('Password=masterkey');
    finally
      FreeAndNil(vIniBanco)
    end;
  end;


  try
    db.Connected := True;
    Result       := db.Connected;
  except
    ShowMessage('Não foi possível se conectar ao banco de dados!' + #13 +
               'Valide o arquivo do banco de dados em:' + #13 +
               'Servidor: ' + vServidor + #13 +
               'Path: ' + vPath);
  end;
end;

procedure TfrPrincipal.edDiretorioAlterdbIniExit(Sender: TObject);
begin
  if FileExists(edDiretorioAlterdbIni.Text) then
  begin
    CarregaDados;
  end
  else
  begin
    ShowMessage('Arquivo indicado não encontrado, Verifique!');
    CarregaIni;
    edDiretorioAlterdbIni.SetFocus;
  end;
end;

procedure TfrPrincipal.CarregaCombo(pCombo: TComboBox);
const
  SQL_SERVIDOR = 'SELECT DISTINCT NOMESERVIDOR, PORTA FROM SERVIDOR ORDER BY NOMESERVIDOR ASC';
  SQL_PATH     = 'SELECT ID, NOMESERVIDOR, PATHSERVIDOR, PORTA FROM SERVIDOR %s ORDER BY NOMESERVIDOR ASC, PATHSERVIDOR ASC';
var
  vServidor: String;
begin
  qryAux.Close;
  qryAux.SQL.Clear;
  if TComboBox(pCombo).Name = cbServidorDestino.Name then
    qryAux.SQL.Text := SQL_SERVIDOR
  else
    qryAux.SQL.Text := SQL_PATH;

  if chkServidor.Checked and (TComboBox(pCombo).Name = cbPathDestino.Name) then
    qryAux.SQL.Text := Format(qryAux.SQL.Text,[' WHERE NOMESERVIDOR = ' + QuotedStr(Trim(cbServidorDestino.Text)) + ' '])
  else
    qryAux.SQL.Text := Format(qryAux.SQL.Text,[EmptyStr]);

  qryAux.Open;

  pCombo.Items.Clear;
  while not qryAux.Eof do
  begin
    if TComboBox(pCombo).Name = cbServidorDestino.Name then
      pCombo.Items.Add(Trim(qryAux.FieldByName('NOMESERVIDOR').AsString))
    else
    begin
      if not chkServidor.Checked then
      begin
        if vServidor <> Trim(qryAux.FieldByName('NOMESERVIDOR').AsString) then
        begin
          pCombo.Items.Add('-- ' + Trim(qryAux.FieldByName('NOMESERVIDOR').AsString) + ' --');
          vServidor := Trim(qryAux.FieldByName('NOMESERVIDOR').AsString)
        end;
        pCombo.Items.Add(Trim(qryAux.FieldByName('PATHSERVIDOR').AsString));
      end
      else
        pCombo.Items.Add(Trim(qryAux.FieldByName('PATHSERVIDOR').AsString));
    end;
    qryAux.Next;
  end;

  if TComboBox(pCombo).Name = cbServidorDestino.Name then
    pCombo.ItemIndex := pCombo.Items.Indexof(edServidorAtual.Text)
  else
    pCombo.ItemIndex := pCombo.Items.Indexof(edPathAtual.Text);

  if pCombo.ItemIndex < 0 then
    pCombo.Text := EmptyStr;
end;

procedure TfrPrincipal.CarregaIni;
var
  vAlterdbIni,
  vIniBanco  : TIniFile;
begin
  vIniBanco := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'));
  try
    chkServidor.Checked  := (vIniBanco.ReadInteger('PATH', 'PREFERENCIAPATH', 0) = 1);
    edDiretorioAlterdbIni.text := vIniBanco.ReadString('PATH', 'DIRETORIOINIFC', '')
  finally
    FreeAndNil(vIniBanco)
  end;

  vAlterdbIni := TIniFile.Create(edDiretorioAlterdbIni.text);
  try
    edServidorAtual.Text := vAlterdbIni.ReadString('SERVIDOR', 'NOMESERVIDOR', '');
    edPathAtual.Text     := vAlterdbIni.ReadString('PATH',     'PATHPAR', '');
  finally
    FreeAndNil(vAlterdbIni)
  end;
end;

procedure TfrPrincipal.GravaIni;
var
  vAlterdbIni,
  vIniBanco  : TIniFile;
begin
  vAlterdbIni := TIniFile.Create(edDiretorioAlterdbIni.text);
  try
    try
      vAlterdbIni.DeleteKey('SERVIDOR', 'NOMESERVIDOR');
      vAlterdbIni.WriteString('SERVIDOR', 'NOMESERVIDOR', cbServidorDestino.Text);
      vAlterdbIni.DeleteKey('PATH', 'PATHPAR');
      vAlterdbIni.WriteString('PATH', 'PATHPAR', cbPathDestino.Text);
    except
      ShowMessage('Ocorreu um erro ao salvar no INI');
    end;
  finally
    FreeAndNil(vAlterdbIni)
  end;

  vIniBanco := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'));
  try
    vIniBanco.DeleteKey('PATH', 'PREFERENCIAPATH');
    vIniBanco.WriteInteger('PATH', 'PREFERENCIAPATH', ifthen(chkServidor.Checked,1,0));
    vIniBanco.DeleteKey('PATH', 'DIRETORIOINIFC');
    vIniBanco.WriteString('PATH', 'DIRETORIOINIFC', edDiretorioAlterdbIni.text);
  finally
    FreeAndNil(vIniBanco)
  end;
end;

end.
