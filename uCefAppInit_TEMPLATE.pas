unit uCefAppInit;

interface

procedure AppCefInit;

implementation

uses
  SysUtils, Classes, Winapi.Windows,
  //
  uStringUtils, uGlobalFileIoFunc, uGlobalVars,
  //
  uCEFApplication, uCefTypes, uCEFConstants,
  //
  uCefRenderProcessMessageReceiver, uCefRenderProcessMessageReceiverCommon,
  //
  uAppCefRenderMessage;



procedure AppCefInit;
begin
  SetErrorMode(1 or 2);
  TThread.NameThreadForDebugging('VclMainThread');

  GlobalCEFApp := TCefApplication.Create;

  //GlobalCEFApp.SingleProcess := True;
  GlobalCEFApp.WindowlessRenderingEnabled := True;
  GlobalCEFApp.ReRaiseExceptions := True;
  GlobalCEFApp.RenderProcessHandler := uAppCefRenderMessage.AppCefRenderMessageInit();

  GlobalCEFApp.FlashEnabled := False;
  GlobalCEFApp.EnableSpellingService := False;
  GlobalCEFApp.EnableMediaStream := False;
  GlobalCEFApp.EnableSpeechInput := False;
  GlobalCEFApp.SmoothScrolling := False;
  GlobalCEFApp.FastUnload := True;
  GlobalCEFApp.NoSandbox := True;
  GlobalCEFApp.DisableSafeBrowsing := True;
  GlobalCEFApp.EnableHighDPISupport := False;
  GlobalCEFApp.MuteAudio := False;
  GlobalCEFApp.UserAgent := Trim(string(StringLoadFromFile(gDirApp + 'UserAgent.txt', True, False)));
//  GlobalCEFApp.SingleProcess := True;
  GlobalCEFApp.LogFile := gDirLog + 'cef.log';
  GlobalCEFApp.LogSeverity := LOGSEVERITY_VERBOSE;
//  GlobalCEFApp.PackLoadingDisabled := False;

  GlobalCEFApp.FrameworkDirPath     := gDirApp + 'cef\';
  GlobalCEFApp.ResourcesDirPath     := gDirApp + 'cef\';
  GlobalCEFApp.LocalesDirPath       := gDirApp + 'cef\locales\';
  GlobalCEFApp.Cache                := '';
  GlobalCEFApp.Cookies              := '';
  GlobalCEFApp.UserDataPath         := '';
  GlobalCEFApp.Locale               := 'en';

  //GlobalCEFApp.AddCustomCommandLine('force-device-scale-factor', '1');
  //GlobalCEFApp.AddCustomCommandLine('disable-gpu-compositing');
  //GlobalCEFApp.AddCustomCommandLine('disable-accelerated-compositing');
 // GlobalCEFApp.AddCustomCommandLine('disable-gpu');
 // GlobalCEFApp.AddCustomCommandLine('disable-webgl');
 // Forces the use of software GL instead of hardware gpu.
//const char kOverrideUseSoftwareGLForTests[] =
//    "override-use-software-gl-for-tests";


  InitCefAppRenderProcessMessage();
end;

end.
