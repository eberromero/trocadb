object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Trocar servidor de Banco do F'#243'rmula Certa - v1.0'
  ClientHeight = 205
  ClientWidth = 751
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
  PixelsPerInch = 96
  TextHeight = 13
  object SpeedButton1: TSpeedButton
    Left = 710
    Top = 21
    Width = 23
    Height = 24
    Caption = '...'
  end
  object Label3: TLabel
    Left = 13
    Top = 6
    Width = 112
    Height = 13
    Caption = 'Diret'#243'rio do alterdb.INI'
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 56
    Width = 360
    Height = 110
    Caption = ' Atual '
    TabOrder = 0
    object Label1: TLabel
      Left = 5
      Top = 16
      Width = 40
      Height = 13
      Caption = 'Servidor'
    end
    object Label2: TLabel
      Left = 5
      Top = 59
      Width = 22
      Height = 13
      Caption = 'Path'
    end
    object cbServidorAtual: TComboBox
      Left = 5
      Top = 32
      Width = 348
      Height = 21
      Style = csDropDownList
      TabOrder = 0
    end
    object cbPathAtual: TComboBox
      Left = 4
      Top = 75
      Width = 348
      Height = 21
      Style = csDropDownList
      TabOrder = 1
    end
  end
  object Edit1: TEdit
    Left = 8
    Top = 22
    Width = 696
    Height = 22
    TabOrder = 1
    Text = 'E:\dese.git\Executaveis\FormulaCerta\alterdb.ini'
  end
  object GroupBox2: TGroupBox
    Left = 374
    Top = 56
    Width = 360
    Height = 110
    Caption = ' Destino '
    TabOrder = 2
    object Label4: TLabel
      Left = 5
      Top = 16
      Width = 40
      Height = 13
      Caption = 'Servidor'
    end
    object Label5: TLabel
      Left = 5
      Top = 59
      Width = 22
      Height = 13
      Caption = 'Path'
    end
    object cbServidorDestino: TComboBox
      Left = 4
      Top = 32
      Width = 348
      Height = 21
      Style = csDropDownList
      TabOrder = 0
    end
    object cbPathDestino: TComboBox
      Left = 4
      Top = 75
      Width = 348
      Height = 21
      Style = csDropDownList
      TabOrder = 1
    end
  end
  object btGravar: TButton
    Left = 501
    Top = 169
    Width = 107
    Height = 25
    Caption = 'Gravar Destino'
    TabOrder = 3
  end
  object btnCarregar: TButton
    Left = 135
    Top = 169
    Width = 107
    Height = 25
    Caption = 'Carregar Dados'
    TabOrder = 4
    OnClick = btnCarregarClick
  end
  object db: TFDConnection
    Params.Strings = (
      'Database=E:\Prototipos\TrocaDB\DB\DADOS.FDB'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'CharacterSet=WIN1252'
      'Protocol=TCPIP'
      'Server=EBER-1963'
      'Port=3050'
      'DriverID=FB')
    LoginPrompt = False
    Transaction = ts
    Left = 472
  end
  object qryDados: TFDQuery
    Connection = db
    SQL.Strings = (
      'select * from SERVIDOR')
    Left = 576
  end
  object ts: TFDTransaction
    Connection = db
    Left = 512
  end
  object dsDados: TDataSource
    DataSet = qryDados
    Left = 614
  end
  object qryAux: TFDQuery
    Connection = db
    Left = 696
  end
end
