unit uEditKey;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, DateTimePicker, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, Buttons, StdCtrls;

type

  { TEditKeyForm }

  TEditKeyForm = class(TForm)
    AddBtn: TButton;
    CancelBtn: TButton;
    KeyBooleanCheckBox: TCheckBox;
    DateTimePicker: TDateTimePicker;
    KeyEdit: TLabeledEdit;
    EditLabel: TLabel;
    ValueEdit: TLabeledEdit;
  private
    { private declarations }
  public
    { public declarations }
    b_isEditMode: Byte;
    // 0 - не выбран не один из режимов
    // 1 - Режим добавления параметра date
    // 2 - Режим добавления параметра boolean
    // 3 - Режим редактирования параметра string, integer
    // 4 - Режим редактирования параметра date
    // 5 - Режим редактирования параметра boolean
  end;

var
  EditKeyForm: TEditKeyForm;

implementation

{$R *.lfm}

end.

