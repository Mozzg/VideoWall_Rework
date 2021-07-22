object Form5: TForm5
  Left = 0
  Top = 0
  Caption = 'Form5'
  ClientHeight = 603
  ClientWidth = 1023
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1023
    Height = 41
    Align = alTop
    TabOrder = 0
  end
  object Panel2: TPanel
    Left = 624
    Top = 41
    Width = 399
    Height = 562
    Align = alRight
    TabOrder = 1
    object Button1: TButton
      Left = 16
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Create'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 16
      Top = 37
      Width = 75
      Height = 25
      Caption = 'Frame'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 112
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Change width'
      TabOrder = 2
      OnClick = Button3Click
    end
    object Memo1: TMemo
      Left = 16
      Top = 208
      Width = 369
      Height = 337
      ScrollBars = ssBoth
      TabOrder = 3
    end
  end
  inline Frame81: TFrame8
    Left = 8
    Top = 47
    Width = 395
    Height = 334
    Color = clPurple
    ParentBackground = False
    ParentColor = False
    TabOrder = 2
    OnMouseDown = Frame81MouseDown
    OnMouseMove = Frame81MouseMove
    OnMouseUp = Frame81MouseUp
    OnResize = Frame81Resize
    ExplicitLeft = 8
    ExplicitTop = 47
  end
end
