#include "data_files.h"
#include <flutter/standard_method_codec.h>
#include <shobjidl.h>
#include <wrl/client.h>
#include <string>
#include <functional>

void RunDataFilesDialog(LPARAM operation) {
  std::unique_ptr<std::function<void()>> action(reinterpret_cast<std::function<void()>*>(operation));
  (*action)();
}

std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> CreateDataFilesChannel(flutter::BinaryMessenger* messenger, HWND owner) {
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(messenger, "articulate/data_files", &flutter::StandardMethodCodec::GetInstance());
  channel->SetMethodCallHandler([owner](const auto& call, auto result) {
    bool save = call.method_name() == "chooseExport";
    if (!save && call.method_name() != "chooseImport") { result->NotImplemented(); return; }
    const auto* argument = std::get_if<std::string>(call.arguments());
    const std::string suggested = argument ? *argument : "Articulate.articulate";
    auto reply = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
    // Show the modal after returning from the engine's platform-message callback.
    auto operation = std::make_unique<std::function<void()>>([owner, save, suggested, result = reply]() {
    Microsoft::WRL::ComPtr<IFileDialog> dialog;
    HRESULT hr = CoCreateInstance(save ? CLSID_FileSaveDialog : CLSID_FileOpenDialog, nullptr, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&dialog));
    if (FAILED(hr)) { result->Error("picker", "Could not open the file dialog"); return; }
    DWORD options = 0;
    dialog->GetOptions(&options);
    dialog->SetOptions(options | FOS_FORCEFILESYSTEM | FOS_PATHMUSTEXIST | (save ? FOS_OVERWRITEPROMPT : FOS_FILEMUSTEXIST));
    const COMDLG_FILTERSPEC filter[] = {{L"Articulate archive", L"*.articulate"}};
    dialog->SetFileTypes(1, filter); dialog->SetDefaultExtension(L"articulate");
    dialog->SetTitle(save ? L"Export Articulate library" : L"Preview Articulate restore");
    if (save) {
      const auto* name = &suggested;
        int length = MultiByteToWideChar(CP_UTF8, 0, name->c_str(), -1, nullptr, 0);
        std::wstring wide(length, L'\0'); MultiByteToWideChar(CP_UTF8, 0, name->c_str(), -1, wide.data(), length); dialog->SetFileName(wide.c_str());
    }
    hr = dialog->Show(owner);
    if (hr == HRESULT_FROM_WIN32(ERROR_CANCELLED)) { result->Success(); return; }
    if (FAILED(hr)) { result->Error("picker", "File selection failed"); return; }
    Microsoft::WRL::ComPtr<IShellItem> item;
    PWSTR path = nullptr;
    if (FAILED(dialog->GetResult(&item)) || FAILED(item->GetDisplayName(SIGDN_FILESYSPATH, &path))) { result->Error("picker", "Choose a local filesystem destination"); return; }
    int length = WideCharToMultiByte(CP_UTF8, 0, path, -1, nullptr, 0, nullptr, nullptr);
    std::string utf8(length, '\0'); WideCharToMultiByte(CP_UTF8, 0, path, -1, utf8.data(), length, nullptr, nullptr); CoTaskMemFree(path); utf8.pop_back();
    result->Success(flutter::EncodableValue(utf8));
    });
    if (PostMessage(owner, kDataFilesDialogMessage, 0, reinterpret_cast<LPARAM>(operation.get()))) {
      operation.release();
    } else { reply->Error("picker", "Could not schedule the file dialog"); }
  });
  return channel;
}
