#include <steam/steam_api.h>
#include <string>
#include <unordered_map>
#include <iostream>

#define STEAMID 480

#if defined(_WIN32) || defined(_WIN64)
    #define EXPORT __declspec(dllexport)
#else
    #define EXPORT __attribute__((visibility("default")))
#endif

// ************************************************************************************** //
// Achievement Management System for Steamworks
// ************************************************************************************** //

class AchievementManager {
    public:
        AchievementManager();

        void Tick();
        void Unlock(const std::string &achievement_id);
        void SetStat(const std::string &name, int value);
        void AddStat(const std::string &name, int value);
        int GetStat(const std::string &name);
        void StoreStats();

    private:
        std::unordered_map<std::string, int> m_stats;
        std::unordered_map<std::string, bool> m_achievements;
        ISteamUserStats* m_steamUserStats;

        // Internal use funcs!

        bool CheckIfSteamActive();
        void OnUserStatsRecieved();
        void OnUserStatsStored();
        void OnAchievementStored();

};

// ************************************************************************************** //
// Implementation of AchievementManager
// ************************************************************************************** //

AchievementManager::AchievementManager() : m_steamUserStats(nullptr) {
    CheckIfSteamActive();
}

bool AchievementManager::CheckIfSteamActive() {
    if (!SteamAPI_Init()) {
        std::cerr << "SteamAPI isn't initalized." << std::endl;
        return false;
    } else {
        std::cout << "SteamAPI is already active." << std::endl;
        return true;
    }
}

void AchievementManager::Tick() {
    SteamAPI_RunCallbacks();
}

void AchievementManager::SetStat(const std::string &name, int value) {
    if (!SteamUserStats()) return;
    SteamUserStats()->SetStat(name.c_str(), value);
}

void AchievementManager::AddStat(const std::string &name, int value) {
    if (!SteamUserStats()) return;
    int current = 0;
    SteamUserStats()->GetStat(name.c_str(), &current);
    SteamUserStats()->SetStat(name.c_str(), current + value);
}

int AchievementManager::GetStat(const std::string &name) {
    if (!SteamUserStats()) return -1;
    int value = 0;
    if (SteamUserStats()->GetStat(name.c_str(), &value)) {
        return value;
    }
    return -1;
}

void AchievementManager::StoreStats() {
    if (SteamUserStats()) {
        SteamUserStats()->StoreStats();
    }
}

void AchievementManager::Unlock(const std::string &achievement_id) {
    m_achievements[achievement_id] = true;

    std::cout << "Achievement get: " << achievement_id << std::endl;
    SteamUserStats()->SetAchievement(achievement_id.c_str());
    SteamUserStats()->StoreStats();
}

// ************************************************************************************** //
// Exposed APIs (AKA what you use in Lua)
// ************************************************************************************** //

static AchievementManager g_achievements;

extern "C" {

// Initalizes the Steam APIs for use during gameplay.
EXPORT bool init() {
    if (SteamAPI_RestartAppIfNecessary(STEAMID)) {
        return SteamAPI_Init();
    }

    std::cerr << "Steam needs to be running!" << std::endl;
    return false;
}

// Shuts down the Steam APIs and closes active connections to Steamworks.
EXPORT void shutdown() {
    return SteamAPI_Shutdown();
}

// Returns the current players Steam Persona
EXPORT const char* get_username() {
    return SteamFriends()->GetPersonaName();
}

// Check if the SteamAPI is active and Steam is running on users PC.
// @return true / false
EXPORT bool is_active() {
    return SteamAPI_IsSteamRunning();
}

EXPORT void tick() {
    g_achievements.Tick();
}

// Unlock an achivement on Steam ( requires `char* ach_id` )
EXPORT void unlock_ach(const char* achievement_id) {
    if (!achievement_id || *achievement_id == '\0') {
        std::cerr << "Invalid Achievement ID format." << std::endl;
        return;
    }

    g_achievements.Unlock(std::string(achievement_id));
}

EXPORT void steam_set_stat(const char* name, int value) {
    g_achievements.SetStat(std::string(name), value);
}

EXPORT void steam_add_stat(const char* name, int value) {
    g_achievements.AddStat(std::string(name), value);
}

EXPORT int steam_get_stat(const char* name) {
    return g_achievements.GetStat(std::string(name));
}

EXPORT void steam_store_stats() {
    g_achievements.StoreStats();
}

} // extern "C"
