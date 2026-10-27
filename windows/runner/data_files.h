#ifndef ARTICULATE_DATA_FILES_H_
#define ARTICULATE_DATA_FILES_H_
#include <flutter/method_channel.h>
#include <flutter/encodable_value.h>
#include <windows.h>
#include <memory>
constexpr UINT kDataFilesDialogMessage = WM_APP + 52;
void RunDataFilesDialog(LPARAM operation);
std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> CreateDataFilesChannel(flutter::BinaryMessenger* messenger, HWND owner);
#endif
