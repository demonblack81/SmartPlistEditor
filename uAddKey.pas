unit uAddKey;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons, StdCtrls;

type

  { TAddKeyForm }

  TAddKeyForm = class(TForm)
    AddBtn: TButton;
    CancelBtn: TButton;
    KeyEdit: TLabeledEdit;
    ValueEdit: TLabeledEdit;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  AddKeyForm: TAddKeyForm;

implementation

{$R *.lfm}

end.

