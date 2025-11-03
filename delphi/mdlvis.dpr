{Апрель 2005 года}
{FuncNum=385}
program mdlvis;

{%ToDo 'mdlvis.todo'}

uses
  Forms,
  frmmain in 'frmmain.pas' {frm1},
  mdlwork in 'mdlwork.pas',
  mdlDraw in 'mdlDraw.pas',
  objedut in 'objedut.pas',
  unTex in 'unTex.pas' {frmTex},
  Glow in 'glow.pas',
  Real3D in 'Real3D.pas',
  addFrame in 'addFrame.pas' {frmAdd},
  unAbout in 'unAbout.pas' {frmAbout},
  un_obj in 'un_obj.pas' {frm_obj},
  cabstract in 'cabstract.pas',
  tests in 'tests.pas',
  guic in 'guic.pas',
  crash in 'crash.pas',
  un_optimize in 'un_optimize.pas' {frm_optimize},
  un_warn in 'un_warn.pas' {frm_warn};

//{$R-}
{$R *.RES}
{$R visxp.res}
begin
  RegisterExceptionHandler;
  Application.Initialize;
  Application.CreateForm(Tfrm1, frm1);
  Application.CreateForm(TfrmTex, frmTex);
  Application.CreateForm(TfrmAdd, frmAdd);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(Tfrm_obj, frm_obj);
  Application.CreateForm(Tfrm_optimize, frm_optimize);
  Application.CreateForm(Tfrm_warn, frm_warn);
  Application.Run;
  UnregisterExceptionHandler;
end.
