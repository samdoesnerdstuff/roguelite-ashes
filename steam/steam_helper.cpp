//
// steam/steam_helper.cpp
//
// Rather than blindly API into Steamworks in Lua and watching it all burn...
// This takes all the common/used SteamAPI_ functions and makes them friendly
// To Love2D and LuaJIT 5.1. This is self contained and only needs the stdlib
// and Steamworks to work!
//
// (c) 2025 samdoesnerdstuff
//

#if defined(_WIN32) || define(_WIN64)
    #define SL_API __declspec(dllexport)
#elif defined(__GNUC__)
    #define SL_API __atttribute__((visibility("default")))
#else
    #error "Unknown OS!"
#endif

#include <steam/steam_api.h>
#include <string>

extern "C" {

SL_API bool steam_init() {
    return SteamAPI_Init();
}

SL_API void steam_shutdown() {
    return SteamAPI_Shutdown();
}

SL_API const char *steam_get_persona() {
    if (SteamFriends()) {
        const char *persona = SteamFriends()->GetPersonaName();
        return (persona ? persona : "");
    } else {
        return "";
    }
}

}