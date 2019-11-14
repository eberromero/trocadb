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
  TForm1 = class(TForm)
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
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCarregarClick(Sender: TObject);
  private
    function ConectaBanco: Boolean;
    procedure CarregaCombo(pCombo: TComboBox);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  if not ConectaBanco then
  begin
    Close;
  end;

  btnCarregar.Click;
end;

procedure TForm1.btnCarregarClick(Sender: TObject);
begin
  CarregaCombo(cbServidorDestino);
  CarregaCombo(cbPathDestino);
end;

function TForm1.ConectaBanco: Boolean;
begin
  try
    db.Connected := True;
    Result := db.Connected;
  except
    ShowMessage('N�o foi poss�vel se conectar ao banco de dados!' + #13 +
               'Valide o arquivo do banco de dados em:' + #13 +
               '\\EBER-1963:E:\Prototipos\TrocaDB\DB\DADOS.FDB');
  end;
end;

procedure TForm1.CarregaCombo(pCombo: TComboBox);
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
