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
    DateTimePicker: TDateTimePicker;
    KeyEdit: TLabeledEdit;
    ValueEdit: TLabeledEdit;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  EditKeyForm: TEditKeyForm;

implementation

{$R *.lfm}

end.

