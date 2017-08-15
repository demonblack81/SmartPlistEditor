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
  end;

var
  EditKeyForm: TEditKeyForm;

implementation

{$R *.lfm}

end.

