#include "include/tv_textfield/tv_textfield_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "tv_textfield_plugin.h"

void TvTextfieldPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  tv_textfield::TvTextfieldPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
