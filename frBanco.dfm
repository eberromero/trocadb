object frmBanco: TfrmBanco
  Left = 0
  Top = 0
  Caption = 'Banco'
  ClientHeight = 139
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 8
    Width = 40
    Height = 13
    Caption = 'Servidor'
  end
  object Label2: TLabel
    Left = 16
    Top = 56
    Width = 179
    Height = 13
    Caption = 'Diret'#243'rio do Banco de Dados TrocaDB'
  end
  object edServidor: TEdit
    Left = 16
    Top = 27
    Width = 281
    Height = 21
    TabOrder = 0
  end
  object edPath: TEdit
    Left = 16
    Top = 75
    Width = 593
    Height = 21
    TabOrder = 1
  end
  object btnGravar: TButton
    Left = 248
    Top = 104
    Width = 129
    Height = 25
    Caption = 'Gravar/Conectar'
    TabOrder = 2
    OnClick = btnGravarClick
  end
end
