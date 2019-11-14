program TrocaDB;

uses
  Vcl.Forms,
  frmPrincipal in 'frmPrincipal.pas' {frPrincipal},
  frBanco in 'frBanco.pas' {frmBanco};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrPrincipal, frPrincipal);
  Application.Run;
end.
