#include <windows.h>
#include <VersionHelpers.h>
#include <shlobj.h>
#include <shellapi.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <filesystem>
#include <fstream>
#include <cstdint>
#include <cstring>
#include <iterator>
#include <sstream>
#include <string>
#include <vector>

namespace free_space {

class FreeSpacePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FreeSpacePlugin();
  virtual ~FreeSpacePlugin();

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

std::wstring Utf8ToWide(const std::string& value) {
  const int length = MultiByteToWideChar(
      CP_UTF8, MB_ERR_INVALID_CHARS, value.c_str(), -1, nullptr, 0);
  if (length <= 0) return {};
  std::wstring result(length, L'\0');
  MultiByteToWideChar(
      CP_UTF8, MB_ERR_INVALID_CHARS, value.c_str(), -1, result.data(), length);
  result.pop_back();
  return result;
}

std::wstring FindRecycleDataPath(const std::wstring& original_path) {
  wchar_t volume_path[MAX_PATH] = {};
  if (!GetVolumePathNameW(original_path.c_str(), volume_path, MAX_PATH)) {
    return {};
  }
  const std::filesystem::path recycle_root =
      std::filesystem::path(volume_path) / L"$Recycle.Bin";
  std::error_code error;
  for (std::filesystem::directory_iterator sid(recycle_root, error), end;
       !error && sid != end; sid.increment(error)) {
    if (!sid->is_directory(error)) continue;
    for (std::filesystem::directory_iterator entry(sid->path(), error), entry_end;
         !error && entry != entry_end; entry.increment(error)) {
      const std::wstring filename = entry->path().filename().wstring();
      if (filename.size() < 3 || filename[0] != L'$' ||
          (filename[1] != L'I' && filename[1] != L'i')) {
        continue;
      }
      std::ifstream metadata(entry->path(), std::ios::binary);
      std::vector<char> bytes(
          (std::istreambuf_iterator<char>(metadata)),
          std::istreambuf_iterator<char>());
      if (bytes.size() < 18) continue;
      uint64_t version = 0;
      if (bytes.size() >= sizeof(version)) {
        memcpy(&version, bytes.data(), sizeof(version));
      }
      const size_t offsets[] = {version == 2 ? 24u : 16u, 24u, 16u};
      bool matches = false;
      for (const size_t offset : offsets) {
        if (bytes.size() <= offset + 2) continue;
        std::wstring stored;
        for (size_t i = offset; i + 1 < bytes.size(); i += 2) {
          wchar_t character = 0;
          memcpy(&character, bytes.data() + i, sizeof(character));
          if (character == L'\0') break;
          stored.push_back(character);
        }
        if (_wcsicmp(stored.c_str(), original_path.c_str()) == 0) {
          matches = true;
          break;
        }
      }
      if (matches) {
        std::wstring data_name = filename;
        data_name[1] = L'R';
        const auto data_path = sid->path() / data_name;
        if (std::filesystem::exists(data_path, error)) {
          return data_path.wstring();
        }
      }
    }
  }
  return {};
}

flutter::EncodableList ListRecycleBinItems() {
  flutter::EncodableList items;
  const DWORD drives = GetLogicalDrives();
  for (wchar_t drive = L'A'; drive <= L'Z'; ++drive) {
    if ((drives & (1u << (drive - L'A'))) == 0) continue;
    const std::filesystem::path recycle_root =
        std::wstring(1, drive) + L":\\$Recycle.Bin";
    std::error_code error;
    for (std::filesystem::directory_iterator sid(recycle_root, error), end;
         !error && sid != end; sid.increment(error)) {
      if (!sid->is_directory(error)) continue;
      for (std::filesystem::directory_iterator entry(sid->path(), error), entry_end;
           !error && entry != entry_end; entry.increment(error)) {
        const std::wstring metadata_name = entry->path().filename().wstring();
        if (metadata_name.size() < 3 || metadata_name[0] != L'$' ||
            (metadata_name[1] != L'I' && metadata_name[1] != L'i')) {
          continue;
        }

        std::ifstream metadata(entry->path(), std::ios::binary);
        const std::vector<char> bytes(
            (std::istreambuf_iterator<char>(metadata)),
            std::istreambuf_iterator<char>());
        if (bytes.size() < 26) continue;

        uint64_t version = 0;
        uint64_t size_bytes = 0;
        memcpy(&version, bytes.data(), sizeof(version));
        memcpy(&size_bytes, bytes.data() + 8, sizeof(size_bytes));
        const size_t path_offset = version == 2 ? 28u : 24u;
        if (bytes.size() <= path_offset + 1) continue;

        std::wstring original_path;
        for (size_t index = path_offset; index + 1 < bytes.size(); index += 2) {
          wchar_t character = 0;
          memcpy(&character, bytes.data() + index, sizeof(character));
          if (character == L'\0') break;
          original_path.push_back(character);
        }
        if (original_path.empty()) continue;

        std::wstring data_name = metadata_name;
        data_name[1] = L'R';
        const auto data_path = sid->path() / data_name;
        if (!std::filesystem::exists(data_path, error)) continue;

        const size_t name_start = original_path.find_last_of(L"\\/");
        const std::wstring name = name_start == std::wstring::npos
            ? original_path
            : original_path.substr(name_start + 1);
        const std::wstring data_path_wide = data_path.wstring();
        const int name_length = WideCharToMultiByte(
            CP_UTF8, WC_ERR_INVALID_CHARS, name.c_str(), -1,
            nullptr, 0, nullptr, nullptr);
        const int utf8_length = WideCharToMultiByte(
            CP_UTF8, WC_ERR_INVALID_CHARS, data_path_wide.c_str(), -1,
            nullptr, 0, nullptr, nullptr);
        if (name_length <= 0 || utf8_length <= 0) continue;
        std::string utf8_name(name_length, '\0');
        WideCharToMultiByte(
            CP_UTF8, WC_ERR_INVALID_CHARS, name.c_str(), -1,
            utf8_name.data(), name_length, nullptr, nullptr);
        utf8_name.pop_back();
        std::string utf8_path(utf8_length, '\0');
        WideCharToMultiByte(
            CP_UTF8, WC_ERR_INVALID_CHARS, data_path_wide.c_str(), -1,
            utf8_path.data(), utf8_length, nullptr, nullptr);
        utf8_path.pop_back();

        flutter::EncodableMap item;
        item[flutter::EncodableValue("name")] =
            flutter::EncodableValue(utf8_name);
        item[flutter::EncodableValue("trashPath")] =
            flutter::EncodableValue(utf8_path);
        item[flutter::EncodableValue("sizeBytes")] =
            flutter::EncodableValue(static_cast<int64_t>(size_bytes));
        items.emplace_back(flutter::EncodableValue(item));
      }
    }
  }
  return items;
}

void FreeSpacePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "com.freespace.app/platform",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<FreeSpacePlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

FreeSpacePlugin::FreeSpacePlugin() {}
FreeSpacePlugin::~FreeSpacePlugin() {}

void FreeSpacePlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getStorageInfo") == 0) {
    ULARGE_INTEGER freeBytesAvailable, totalNumberOfBytes, totalNumberOfFreeBytes;
    if (GetDiskFreeSpaceExW(L"C:\\", &freeBytesAvailable, &totalNumberOfBytes, &totalNumberOfFreeBytes)) {
        flutter::EncodableMap map;
        map[flutter::EncodableValue("totalBytes")] = flutter::EncodableValue(static_cast<int64_t>(totalNumberOfBytes.QuadPart));
        map[flutter::EncodableValue("freeBytes")] = flutter::EncodableValue(static_cast<int64_t>(totalNumberOfFreeBytes.QuadPart));
        map[flutter::EncodableValue("usedBytes")] = flutter::EncodableValue(static_cast<int64_t>(totalNumberOfBytes.QuadPart - totalNumberOfFreeBytes.QuadPart));
        result->Success(flutter::EncodableValue(map));
    } else {
        result->Error("ERROR", "Failed to get disk space");
    }
  } else if (method_call.method_name().compare("scanDirectory") == 0) {
      result->Error("UNSUPPORTED", "Not implemented completely yet");
  } else if (method_call.method_name().compare("showInFileManager") == 0) {
    const auto* arguments = std::get_if<flutter::EncodableMap>(
        method_call.arguments());
    if (arguments == nullptr) {
      result->Error("INVALID_ARGUMENT", "Path is required");
      return;
    }
    const auto path_entry = arguments->find(flutter::EncodableValue("path"));
    if (path_entry == arguments->end()) {
      result->Error("INVALID_ARGUMENT", "Path is required");
      return;
    }
    const auto* path = std::get_if<std::string>(&path_entry->second);
    if (path == nullptr) {
      result->Error("INVALID_ARGUMENT", "Path must be a string");
      return;
    }
    const int required = MultiByteToWideChar(
        CP_UTF8, MB_ERR_INVALID_CHARS, path->c_str(), -1, nullptr, 0);
    if (required == 0) {
      result->Error("INVALID_PATH", "Path could not be converted");
      return;
    }
    std::wstring wide_path(required, L'\0');
    MultiByteToWideChar(
        CP_UTF8, MB_ERR_INVALID_CHARS, path->c_str(), -1,
        wide_path.data(), required);
    wide_path.pop_back();
    if (GetFileAttributesW(wide_path.c_str()) == INVALID_FILE_ATTRIBUTES) {
      result->Error("ITEM_NOT_FOUND", "The selected item no longer exists");
      return;
    }
    std::wstring parameters = L"/select,\"" + wide_path + L"\"";
    const auto status = reinterpret_cast<INT_PTR>(ShellExecuteW(
        nullptr, L"open", L"explorer.exe", parameters.c_str(), nullptr,
        SW_SHOWNORMAL));
    if (status <= 32) {
      result->Error("REVEAL_FAILED", "File Explorer could not be opened");
    } else {
      result->Success(flutter::EncodableValue(true));
    }
  } else if (method_call.method_name().compare("moveItemsToSystemTrash") == 0) {
    const auto* arguments = std::get_if<flutter::EncodableMap>(
        method_call.arguments());
    if (arguments == nullptr) {
      result->Error("INVALID_ARGUMENT", "Item paths are required");
      return;
    }
    const auto paths_entry = arguments->find(flutter::EncodableValue("paths"));
    const auto* paths = paths_entry == arguments->end()
        ? nullptr
        : std::get_if<flutter::EncodableList>(&paths_entry->second);
    if (paths == nullptr || paths->empty()) {
      result->Error("INVALID_ARGUMENT", "Item paths are required");
      return;
    }

    flutter::EncodableMap moved;
    for (const auto& encoded_path : *paths) {
      const auto* path = std::get_if<std::string>(&encoded_path);
      if (path == nullptr) continue;
      const std::wstring wide_path = Utf8ToWide(*path);
      if (wide_path.empty() ||
          GetFileAttributesW(wide_path.c_str()) == INVALID_FILE_ATTRIBUTES) {
        continue;
      }
      std::wstring source_list = wide_path;
      source_list.push_back(L'\0');
      source_list.push_back(L'\0');
      SHFILEOPSTRUCTW operation = {};
      operation.wFunc = FO_DELETE;
      operation.pFrom = source_list.c_str();
      operation.fFlags = FOF_ALLOWUNDO | FOF_NOCONFIRMATION |
                         FOF_SILENT | FOF_NOERRORUI;
      const int status = SHFileOperationW(&operation);
      if (status != 0 || operation.fAnyOperationsAborted) continue;
      const std::wstring recycle_path = FindRecycleDataPath(wide_path);
      moved[flutter::EncodableValue(*path)] =
          recycle_path.empty()
              ? flutter::EncodableValue()
              : flutter::EncodableValue(recycle_path);
    }
    result->Success(flutter::EncodableValue(moved));
  } else if (method_call.method_name().compare("restoreItemsFromSystemTrash") == 0) {
    const auto* arguments = std::get_if<flutter::EncodableMap>(
        method_call.arguments());
    if (arguments == nullptr) {
      result->Error("INVALID_ARGUMENT", "Items to restore are required");
      return;
    }
    const auto items_entry = arguments->find(flutter::EncodableValue("items"));
    const auto* items = items_entry == arguments->end()
        ? nullptr
        : std::get_if<flutter::EncodableList>(&items_entry->second);
    if (items == nullptr) {
      result->Error("INVALID_ARGUMENT", "Items to restore are required");
      return;
    }
    for (const auto& encoded_item : *items) {
      const auto* item = std::get_if<flutter::EncodableMap>(&encoded_item);
      if (item == nullptr) continue;
      const auto original_entry = item->find(flutter::EncodableValue("originalPath"));
      const auto trash_entry = item->find(flutter::EncodableValue("trashPath"));
      if (original_entry == item->end()) continue;
      const auto* original = std::get_if<std::string>(&original_entry->second);
      if (original == nullptr) continue;
      std::wstring recycle_path;
      if (trash_entry != item->end()) {
        const auto* saved_path = std::get_if<std::string>(&trash_entry->second);
        if (saved_path != nullptr) recycle_path = Utf8ToWide(*saved_path);
      }
      const std::wstring original_path = Utf8ToWide(*original);
      if (recycle_path.empty()) {
        recycle_path = FindRecycleDataPath(original_path);
      }
      if (recycle_path.empty() ||
          !MoveFileExW(recycle_path.c_str(), original_path.c_str(),
                       MOVEFILE_COPY_ALLOWED | MOVEFILE_WRITE_THROUGH)) {
        result->Error("RESTORE_FAILED", "Could not restore item from Recycle Bin");
        return;
      }
      std::wstring metadata_path = recycle_path;
      const size_t filename_start = metadata_path.find_last_of(L"\\/");
      if (filename_start != std::wstring::npos &&
          filename_start + 1 < metadata_path.size()) {
        metadata_path[filename_start + 1] = L'I';
        DeleteFileW(metadata_path.c_str());
      }
    }
    result->Success(flutter::EncodableValue(true));
  } else if (method_call.method_name().compare(
                 "permanentlyDeleteItemsFromSystemTrash") == 0) {
    const auto* arguments = std::get_if<flutter::EncodableMap>(
        method_call.arguments());
    if (arguments == nullptr) {
      result->Error("INVALID_ARGUMENT", "System Trash paths are required");
      return;
    }
    const auto paths_entry = arguments->find(flutter::EncodableValue("paths"));
    const auto* paths = paths_entry == arguments->end()
        ? nullptr
        : std::get_if<flutter::EncodableList>(&paths_entry->second);
    if (paths == nullptr) {
      result->Error("INVALID_ARGUMENT", "System Trash paths are required");
      return;
    }
    flutter::EncodableList deleted;
    for (const auto& encoded_path : *paths) {
      const auto* path = std::get_if<std::string>(&encoded_path);
      if (path == nullptr) continue;
      const std::wstring wide_path = Utf8ToWide(*path);
      const std::filesystem::path recycle_path(wide_path);
      bool is_recycle_path = false;
      for (const auto& component : recycle_path) {
        if (_wcsicmp(component.c_str(), L"$Recycle.Bin") == 0) {
          is_recycle_path = true;
          break;
        }
      }
      if (!is_recycle_path || wide_path.empty() ||
          GetFileAttributesW(wide_path.c_str()) == INVALID_FILE_ATTRIBUTES) {
        continue;
      }
      std::wstring source_list = wide_path;
      source_list.push_back(L'\0');
      source_list.push_back(L'\0');
      SHFILEOPSTRUCTW operation = {};
      operation.wFunc = FO_DELETE;
      operation.pFrom = source_list.c_str();
      operation.fFlags = FOF_NOCONFIRMATION | FOF_SILENT | FOF_NOERRORUI;
      const int status = SHFileOperationW(&operation);
      if (status != 0 || operation.fAnyOperationsAborted) continue;

      std::filesystem::path metadata_path = recycle_path;
      std::wstring metadata_name = metadata_path.filename().wstring();
      if (metadata_name.size() > 1 &&
          (metadata_name[0] == L'$') &&
          (metadata_name[1] == L'R' || metadata_name[1] == L'r')) {
        metadata_name[1] = L'I';
        metadata_path.replace_filename(metadata_name);
        DeleteFileW(metadata_path.c_str());
      }
      deleted.emplace_back(flutter::EncodableValue(*path));
    }
    result->Success(flutter::EncodableValue(deleted));
  } else if (method_call.method_name().compare("listSystemTrashItems") == 0) {
    result->Success(flutter::EncodableValue(ListRecycleBinItems()));
  } else {
    result->NotImplemented();
  }
}

}  // namespace free_space

void FreeSpacePluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  free_space::FreeSpacePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
