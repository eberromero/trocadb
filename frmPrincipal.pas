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
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCarregarClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure btGravarClick(Sender: TObject);
  private
    function ConectaBanco: Boolean;
    procedure CarregaCombo(pCombo: TComboBox);
    procedure CarregaConfiguracaoAtual;
    function ValidaCadastroNovo: Boolean;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frPrincipal: TfrPrincipal;

implementation

{$R *.dfm}

uses IniFiles, frBanco;

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
var
  vIniBanco: TIniFile;
begin
  if MessageDlg('Confirma alteração?',mtConfirmation, mbYesNo, 0) = mrNo then
    Exit;

  if FileExists(ChangeFileExt(Application.ExeName,'.ini')) then
  begin
    vIniBanco := TIniFile.Create(edDiretorioAlterdbIni.text);
    try
      try
        vIniBanco.DeleteKey('SERVIDOR', 'NOMESERVIDOR');
        vIniBanco.WriteString('SERVIDOR', 'NOMESERVIDOR', cbServidorDestino.Text);
        vIniBanco.DeleteKey('PATH', 'PATHPAR');
        vIniBanco.WriteString('PATH', 'PATHPAR', cbPathDestino.Text);
        if ValidaCadastroNovo then
          ShowMessage('Salvo com sucesso!');
      except
        ShowMessage('Ocorreu um erro ao salvar no INI');
      end;
    finally
      FreeAndNil(vIniBanco)
    end;
  end;
  btnCarregar.Click;
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
  end;
end;

procedure TfrPrincipal.btnCarregarClick(Sender: TObject);
begin
  if not db.Connected then
    ConectaBanco;

  CarregaConfiguracaoAtual;
  CarregaCombo(cbServidorDestino);
  CarregaCombo(cbPathDestino);
end;

procedure TfrPrincipal.CarregaConfiguracaoAtual;
var
  vIniBanco: TIniFile;
begin
  if FileExists(ChangeFileExt(Application.ExeName,'.ini')) then
  begin
    vIniBanco := TIniFile.Create(edDiretorioAlterdbIni.text);
    try
      edServidorAtual.Text := vIniBanco.ReadString('SERVIDOR', 'NOMESERVIDOR', '');
      edPathAtual.Text     := vIniBanco.ReadString('PATH', 'PATHPAR', '');
    finally
      FreeAndNil(vIniBanco)
    end;
  end;
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

procedure TfrPrincipal.CarregaCombo(pCombo: TComboBox);
const
  SQL_SERVIDOR = 'SELECT DISTINCT NOMESERVIDOR, PORTA FROM SERVIDOR ORDER BY ID ASC';
  SQL_PATH     = 'SELECT ID, NOMESERVIDOR, PATHSERVIDOR, PORTA FROM SERVIDOR ORDER BY NOMESERVIDOR ASC, PATHSERVIDOR ASC';
var
  vServidor: String;
begin
  qryAux.Close;
  qryAux.SQL.Clear;
  if TComboBox(pCombo).Name = cbServidorDestino.Name then
    qryAux.SQL.Text := SQL_SERVIDOR
  else
    qryAux.SQL.Text := SQL_PATH;
  qryAux.Open;

  pCombo.Items.Clear;
  while not qryAux.Eof do
  begin
    if TComboBox(pCombo).Name = cbServidorDestino.Name then
      pCombo.Items.Add(Trim(qryAux.FieldByName('NOMESERVIDOR').AsString))
    else
    begin
      if vServidor <> Trim(qryAux.FieldByName('NOMESERVIDOR').AsString) then
      begin
        pCombo.Items.Add('-- ' + Trim(qryAux.FieldByName('NOMESERVIDOR').AsString) + ' --');
        vServidor := Trim(qryAux.FieldByName('NOMESERVIDOR').AsString)
      end;
      pCombo.Items.Add(Trim(qryAux.FieldByName('PATHSERVIDOR').AsString));
    end;
    qryAux.Next;
  end;

  if TComboBox(pCombo).Name = cbServidorDestino.Name then
    pCombo.ItemIndex := pCombo.Items.Indexof(edServidorAtual.Text)
  else
    pCombo.ItemIndex := pCombo.Items.Indexof(edPathAtual.Text);
end;

end.
