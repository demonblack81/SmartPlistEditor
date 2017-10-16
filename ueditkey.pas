unit uEditKey;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, DateTimePicker, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, Buttons, StdCtrls;

type

  { TEditKeyForm }

  TEditKeyForm = class(TForm)
    CancelBitBtn: TBitBtn;
    OKBitBtn: TBitBtn;
    KeyBooleanCheckBox: TCheckBox;
    DateTimePicker: TDateTimePicker;
    KeyEdit: TLabeledEdit;
    EditLabel: TLabel;
    ValueEdit: TLabeledEdit;
    procedure OnFormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }

  end;

var
  EditKeyForm: TEditKeyForm;
  b_isEditMode: Byte;
    // 0 - не выбран не один из режимов
    // 1 - Режим добавления параметра date
    // 2 - Режим добавления параметра boolean
    // 3 - Режим редактирования параметра string, integer
    // 4 - Режим редактирования параметра date
    // 5 - Режим редактирования параметра boolean

implementation

{$R *.lfm}

{ TEditKeyForm }

procedure TEditKeyForm.OnFormShow(Sender: TObject);
begin
  case b_isEditMode of
    1: begin
      KeyEdit.Text:= '';
      ValueEdit.Visible:= false;
      KeyBooleanCheckBox.Visible:= false;
      DateTimePicker.Visible:= true;
      DateTimePicker.DateTime:=Now;
      EditLabel.Caption:= 'Дата';
      EditLabel.Visible:= true;
      KeyEdit.SetFocus;
    end;
    2: begin
      KeyEdit.Text:= '';
      KeyBooleanCheckBox.Checked:= false;
      ValueEdit.Visible:= false;
      DateTimePicker.Visible:= false;
      KeyBooleanCheckBox.Visible:= false;
      EditLabel.Caption:= 'Вкл/Выкл';
      EditLabel.Visible:= true;
      KeyEdit.SetFocus;
    end;
    else begin
      ValueEdit.Visible:= true;
      DateTimePicker.Visible:= false;
      EditLabel.Visible:= false;
      KeyBooleanCheckBox.Visible:= false;
    end;
  end;

end;

end.

