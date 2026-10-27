#include "flutter_window.h"
#include "data_files.h"

#include <optional>
#include <flutter/standard_method_codec.h>
#include <wtsapi32.h>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  audio_channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(), "articulate/audio_platform",
      &flutter::StandardMethodCodec::GetInstance());
  audio_channel_->SetMethodCallHandler([](const auto& call, auto result) {
    if (call.method_name() != "freeBytes") { result->NotImplemented(); return; }
    const auto* path = std::get_if<std::string>(call.arguments());
    if (!path) { result->Error("storage", "Missing storage path"); return; }
    int count = MultiByteToWideChar(CP_UTF8, 0, path->c_str(), -1, nullptr, 0);
    std::wstring wide(count, L'\0');
    MultiByteToWideChar(CP_UTF8, 0, path->c_str(), -1, wide.data(), count);
    ULARGE_INTEGER free_bytes;
    if (GetDiskFreeSpaceExW(wide.c_str(), &free_bytes, nullptr, nullptr)) {
      result->Success(flutter::EncodableValue(static_cast<int64_t>(free_bytes.QuadPart)));
    } else { result->Error("storage", "Could not check available storage"); }
  });
  data_channel_ = CreateDataFilesChannel(flutter_controller_->engine()->messenger(), GetHandle());
  WTSRegisterSessionNotification(GetHandle(), NOTIFY_FOR_THIS_SESSION);
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  WTSUnRegisterSessionNotification(GetHandle());
  audio_channel_.reset();
  data_channel_.reset();
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  if (message == kDataFilesDialogMessage) {
    RunDataFilesDialog(lparam);
    return 0;
  }
  if (audio_channel_) {
    const char* reason = nullptr;
    if (message == WM_SIZE && wparam == SIZE_MINIMIZED) reason = "Window minimized";
    if (message == WM_POWERBROADCAST && wparam == PBT_APMSUSPEND) reason = "Computer suspending";
    if (message == WM_WTSSESSION_CHANGE && wparam == WTS_SESSION_LOCK) reason = "Desktop locked";
    if (reason) audio_channel_->InvokeMethod("audioInterrupted", std::make_unique<flutter::EncodableValue>(reason));
  }
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
