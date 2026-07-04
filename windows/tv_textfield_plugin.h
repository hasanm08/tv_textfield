#ifndef FLUTTER_PLUGIN_TV_TEXTFIELD_PLUGIN_H_
#define FLUTTER_PLUGIN_TV_TEXTFIELD_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace tv_textfield {

class TvTextfieldPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  TvTextfieldPlugin();

  virtual ~TvTextfieldPlugin();

  // Disallow copy and assign.
  TvTextfieldPlugin(const TvTextfieldPlugin&) = delete;
  TvTextfieldPlugin& operator=(const TvTextfieldPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace tv_textfield

#endif  // FLUTTER_PLUGIN_TV_TEXTFIELD_PLUGIN_H_
