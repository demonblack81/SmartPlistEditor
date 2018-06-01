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
    procedure KeyBooleanCheckBoxChange(Sender: TObject);
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
    // 1 - Режим добавления параметра Date
    // 2 - Режим добавления параметра boolean
    // 3 - Режим редактирования параметра string, integer
    // 4 - Режим редактирования параметра Date
    // 5 - Режим редактирования параметра boolean
    // 6 - Режим добавления Date

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
      KeyBooleanCheckBox.Visible:= true;
      ValueEdit.Visible:= false;
      DateTimePicker.Visible:= false;
      EditLabel.Caption:= 'Вкл/Выкл';
      EditLabel.Visible:= true;
      KeyEdit.SetFocus;
    end;
    6: begin
      KeyEdit.Text:= '';
      KeyEdit.Visible:= false;
      ValueEdit.Visible:= false;
      KeyBooleanCheckBox.Visible:= false;
      DateTimePicker.Visible:= true;
      DateTimePicker.DateTime:=Now;
      EditLabel.Caption:= 'Дата';
      EditLabel.Visible:= true;
    end;
    else begin
      ValueEdit.Visible:= true;
      DateTimePicker.Visible:= false;
      EditLabel.Visible:= false;
      KeyBooleanCheckBox.Visible:= false;
    end;
  end;

end;

procedure TEditKeyForm.KeyBooleanCheckBoxChange(Sender: TObject);
begin
  if KeyBooleanCheckBox.Checked then  KeyBooleanCheckBox.Caption:= 'True'
  else KeyBooleanCheckBox.Caption:= 'False';
end;

end.

