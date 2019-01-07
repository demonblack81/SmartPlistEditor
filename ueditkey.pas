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
    function AddNeededParamInTypeCombobox(NeedeParm:integer): integer;
    procedure ClearAllControl;
  private
    { private declarations }
  public
    { public declarations }

  end;

var
  EditKeyForm: TEditKeyForm;
  b_isEditMode: Byte;
    // 0 - не выбран не один из режимов
    // 1 - Режим добавления параметра key date
    // 2 - Режим добавления параметра key boolean
    // 3 - Режим редактирования параметра key string, integer
    // 4 - Режим редактирования параметра key Date
    // 5 - Режим добавления параметра key boolean
    // 6 - Режим редактирования string, integer
    // 7 - Режим редакттирования array, dict и key array, dict
    // 8 - ???
    // 9 -
    // 10 -


implementation

{$R *.lfm}

{ TEditKeyForm }

procedure TEditKeyForm.OnFormShow(Sender: TObject);
begin
  case b_isEditMode of
    1: begin  // 1 - Режим добавления параметра Date
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
    2: begin // 2 - Режим добавления параметра key boolean,
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
    3: begin // 3 - Режим редактирования параметра key string, integer, real
      //KeyEdit.Text:= '';
      KeyBooleanCheckBox.Visible:= false;
      //ValueEdit.Text := '';
      ValueEdit.Visible:= true;
      EditLabel.Caption:= '';
      EditLabel.Visible:= false;
      DateTimePicker.Visible:= false;
      //TypeComboBox.Text:= '';
      TypeComboBox.Visible:= true;
    end;
    4: begin  // 4 - Режим редактирования параметра key Date
      //KeyEdit.Text:= '';
      ValueEdit.Visible:= false;
      KeyBooleanCheckBox.Visible:= false;
      DateTimePicker.Visible:= true;
      DateTimePicker.DateTime:=Now;
      EditLabel.Caption:= 'Дата';
      EditLabel.Visible:= true;
      KeyEdit.SetFocus;
      LabelType.Visible:=  false;
      TypeCombobox.Visible:= true;
    end;
    5: begin // 5 - Режим редактирования параметра key boolean
      //KeyEdit.Text:= '';
      //KeyBooleanCheckBox.Checked:= false;
      KeyBooleanCheckBox.Visible:= true;
      ValueEdit.Visible:= false;
      DateTimePicker.Visible:= false;
      EditLabel.Caption:= 'Вкл/Выкл';
      EditLabel.Visible:= true;
      KeyEdit.SetFocus;
      LabelType.Visible:=  false;
      TypeCombobox.Visible:= true;
    end;
    6: begin // 6 - Режим редактирования string, integer, real
      //KeyEdit.Text:= '';
      KeyEdit.Visible:= true;
      KeyBooleanCheckBox.Visible:= false;
      //ValueEdit.Text := '';
      ValueEdit.Visible:= false;
      EditLabel.Caption:= '';
      EditLabel.Visible:= false;
      DateTimePicker.Visible:= false;
      //TypeComboBox.Text:= '';
      TypeComboBox.Visible:= true;
    end;
    7: begin // 7 - Режим редакттирования array, dict
      //KeyEdit.Text:= '';
      KeyEdit.Visible:= false;
      ValueEdit.Visible:= false;
      KeyBooleanCheckBox.Visible:= false;
      DateTimePicker.Visible:= false;
      EditLabel.Visible:= false;
      LabelType.Visible:=  true;
      TypeCombobox.Visible:= true;
      // Нужно продумать
    end;
    8: begin // 8 - Режим редактирования key array или key dict
      //KeyEdit.Text:= '';
      KeyEdit.Visible:= true;
      ValueEdit.Visible:= false;
      KeyBooleanCheckBox.Visible:= false;
      DateTimePicker.Visible:= false;
      EditLabel.Visible:= false;
      LabelType.Visible:=  true;
      TypeCombobox.Visible:= true;
    end;

    else begin
      ValueEdit.Visible:= true;
      DateTimePicker.Visible:= false;
      EditLabel.Visible:= false;
      KeyBooleanCheckBox.Visible:= false;
    end;
  end;
end;

function TEditKeyForm.AddNeededParamInTypeCombobox(NeedeParm: integer): integer;
begin
  result := 0;
  EditKeyForm.TypeComboBox.Items.Clear;
  Case NeedeParm of
    1: begin // только dict и integer
      EditKeyForm.TypeComboBox.Items.Add('<array>');
      EditKeyForm.TypeComboBox.Items.Add('<dict>');
    end;
    2: begin // Все параметры <key>
      EditKeyForm.TypeComboBox.Items.Add('<key> <array>');
      EditKeyForm.TypeComboBox.Items.Add('<key> <dict>');
      EditKeyForm.TypeComboBox.Items.Add('<key> <string>');
      EditKeyForm.TypeComboBox.Items.Add('<key> <integer>');
      EditKeyForm.TypeComboBox.Items.Add('<key> <real>');
      EditKeyForm.TypeComboBox.Items.Add('<key> <date>');
      EditKeyForm.TypeComboBox.Items.Add('<key> <boolean>');
    end;
    3: begin // просто параметры
      EditKeyForm.TypeComboBox.Items.Add('<string>');
      EditKeyForm.TypeComboBox.Items.Add('<integer>');
      EditKeyForm.TypeComboBox.Items.Add('<real>');
      EditKeyForm.TypeComboBox.Items.Add('<date>');
    end;
    else begin // Все параметры
      EditKeyForm.TypeComboBox.Items.Add('<array>');
      EditKeyForm.TypeComboBox.Items.Add('<dict>');
      EditKeyForm.TypeComboBox.Items.Add('<key> <array>');
      EditKeyForm.TypeComboBox.Items.Add('<key> <dict>');
      EditKeyForm.TypeComboBox.Items.Add('<key> <string>');
      EditKeyForm.TypeComboBox.Items.Add('<key> <integer>');
      EditKeyForm.TypeComboBox.Items.Add('<key> <real>');
      EditKeyForm.TypeComboBox.Items.Add('<key> <date>');
      EditKeyForm.TypeComboBox.Items.Add('<key> <boolean>');
      EditKeyForm.TypeComboBox.Items.Add('<string>');
      EditKeyForm.TypeComboBox.Items.Add('<integer>');
      EditKeyForm.TypeComboBox.Items.Add('<real>');
      EditKeyForm.TypeComboBox.Items.Add('<date>');
    end;
  end;
end;

procedure TEditKeyForm.ClearAllControl;
begin
  EditKeyForm.TypeComboBox.Clear;
  KeyEdit.Text:= '';
  ValueEdit.Text := '';
end;

procedure TEditKeyForm.KeyBooleanCheckBoxChange(Sender: TObject);
begin
  if KeyBooleanCheckBox.Checked then  KeyBooleanCheckBox.Caption:= 'True'
  else KeyBooleanCheckBox.Caption:= 'False';
end;

end.

