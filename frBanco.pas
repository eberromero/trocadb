unit frBanco;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IniFiles ;

type
  TfrmBanco = class(TForm)
    edServidor: TEdit;
    Label1: TLabel;
    edPath: TEdit;
    Label2: TLabel;
    btnGravar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
  private
    FIniBanco: TIniFile;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBanco: TfrmBanco;

implementation

{$R *.dfm}

procedure TfrmBanco.btnGravarClick(Sender: TObject);
begin
  FIniBanco.WriteString('SERVIDOR', 'NOMESERVIDOR',edServidor.Text);
  FIniBanco.WriteString('PATH',     'PATHPAR'       ,edPath.Text);
  Close;
end;

procedure TfrmBanco.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmBanco.FormCreate(Sender: TObject);
begin
  if not FileExists(ChangeFileExt(Application.ExeName,'.ini')) then
  begin
    ShowMessage('O arquivo TrocaDB.ini n�o foi encontrado!');
    Exit;
  end;

  FIniBanco := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'));

  edServidor.Text := FIniBanco.ReadString('SERVIDOR', 'NOMESERVIDOR', '');
  edPath.Text     := FIniBanco.ReadString('PATH',     'PATHPAR',      '');
end;

procedure TfrmBanco.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FIniBanco);
end;

end.
