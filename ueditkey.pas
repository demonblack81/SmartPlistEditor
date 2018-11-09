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
    TypeComboBox: TComboBox;
    LabelType: TLabel;
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
    // 3 - Режим редактирования параметра key string, integer
    // 4 - Режим редактирования параметра key Date
    // 5 - Режим редактирования параметра key boolean
    // 6 - Режим добавления Date
    // 7 - Режим редакттирования array, dict
    // 8 - Режим редактирования key array или key dict
    // 9 - Режим редактирования string, integer
    // 10 - Режим редактирования Date ?? (Нужно убедится что такое бывает)


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
      LabelType.Visible:=  false;
      TypeCombobox.Visible:= false;
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
      LabelType.Visible:=  false;
      TypeCombobox.Visible:= false;
    end;
    3: begin
       KeyEdit.Text:= '';
       KeyBooleanCheckBox.Visible:= false;
       ValueEdit.Text := '';
       ValueEdit.Visible:= true;
       DateTimePicker.Visible:= false;
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
      LabelType.Visible:=  false;
      TypeCombobox.Visible:= false;
    end;
    7: begin
      LabelType.Visible:=  true;
      TypeCombobox.Visible:= true;
      // Нужно продумать

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

