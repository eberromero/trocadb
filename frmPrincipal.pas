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
    Edit1: TEdit;
    SpeedButton1: TSpeedButton;
    Label3: TLabel;
    GroupBox2: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    btGravar: TButton;
    btnCarregar: TButton;
    dsDados: TDataSource;
    cbServidorAtual: TComboBox;
    cbPathAtual: TComboBox;
    qryAux: TFDQuery;
    cbServidorDestino: TComboBox;
    cbPathDestino: TComboBox;
    SpeedButton2: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCarregarClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    function ConectaBanco: Boolean;
    procedure CarregaCombo(pCombo: TComboBox);
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
//  if not ConectaBanco then
//  begin
//    SpeedButton2.Click;
//  end;
//
//  btnCarregar.Click;
end;

procedure TfrPrincipal.SpeedButton2Click(Sender: TObject);
begin
  Application.CreateForm(TfrmBanco,frmBanco);
  frmBanco.ShowModal;
  ConectaBanco;
end;

procedure TfrPrincipal.btnCarregarClick(Sender: TObject);
begin
  if not db.Connected then
    ConectaBanco;

  CarregaCombo(cbServidorDestino);
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
      vPath     := vIniBanco.ReadString('DIRETORIO', 'PATH', '') + '\DADOS.FDB';
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
    ShowMessage('N�o foi poss�vel se conectar ao banco de dados!' + #13 +
               'Valide o arquivo do banco de dados em:' + #13 +
               'Servidor: ' + vServidor + #13 +
               'Path: ' + vPath);
  end;
end;

procedure TfrPrincipal.CarregaCombo(pCombo: TComboBox);
const
  SQL_SERVIDOR = 'SELECT DISTINCT NOMESERVIDOR, PORTA FROM SERVIDOR ORDER BY ID ASC';
  SQL_PATH     = 'SELECT ID, NOMESERVIDOR, PATHSERVIDOR, PORTA FROM SERVIDOR';
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
      pCombo.Items.Add(Trim(qryAux.FieldByName('PATHSERVIDOR').AsString));
    qryAux.Next;
  end;
  pCombo.ItemIndex := -1;
end;

end.
