#include "luasteam.cpp"
#include <iostream>
#include <string>
#include <vector>

#if !defined(EXPORT)
    #if defined(_WIN32) || defined(_WIN64)
        #define EXPORT __declspec(dllexport)
    #else
        #define EXPORT __attribute__((visibility("default")))
    #endif
#endif

// ************************************************************************************** //
// Telemetry Management for User Stats from Lua->Steamworks
// ************************************************************************************** //
//
// Works in tandem with AchievementManager for more complex achievements.
// This system extends beyond basic achievement unlocking and stat storage.
// It is designed to track ongoing "telemetry" during gameplay. That can include:
//   - Complex achievement progress
//   - Aggregated counters for in-game events
//   - Tracking pre-requisites for chained achievements
//   - Storing ephemeral stats that may or may not get pushed to Steam
//
// ************************************************************************************** //

static enum KnownAchievements {
    ka_id_NONE = 0
};

class TelemetryManager {
    public:
        TelemetryManager();
        ~TelemetryManager();

        void Tick();

        void RecordEvent(const std::string &event_name, int value = 1);
        int GetEventCount(const std::string &event_name);

        void CheckComplexAchievements();
        void Reset();
    
    private:
        std::unordered_map<std::string, int> m_eventCounters;
        void DebugPrintEvent(const std::string &event_name);
};

// ************************************************************************************** //
// Implementation
// ************************************************************************************** //

TelemetryManager::TelemetryManager() {
    std::cout << "[Telemetry] Manager initialized." << std::endl;
}

TelemetryManager::~TelemetryManager() {
    std::cout << "[Telemetry] Manager shutting down." << std::endl;
}

void TelemetryManager::Tick() {
    // Future: flush data, run periodic checks, sync with AchievementManager
    CheckComplexAchievements();
}

void TelemetryManager::RecordEvent(const std::string& event_name, int value) {
    m_eventCounters[event_name] += value;
    DebugPrintEvent(event_name);
}

int TelemetryManager::GetEventCount(const std::string& event_name) {
    auto it = m_eventCounters.find(event_name);
    if (it != m_eventCounters.end()) {
        return it->second;
    }
    return 0;
}

void TelemetryManager::CheckComplexAchievements() {

}

void TelemetryManager::Reset() {
    m_eventCounters.clear();
}

void TelemetryManager::DebugPrintEvent(const std::string& event_name) {
    std::cout << "[Telemetry] " << event_name 
              << " = " << m_eventCounters[event_name] << std::endl;
}

// ************************************************************************************** //
// Exposed Lua API
// ************************************************************************************** //

static TelemetryManager g_telemetry;

extern "C" {

// Update telemetry manager each frame
EXPORT void telemetry_tick() {
    g_telemetry.Tick();
}

// Record a telemetry event (e.g., "jump", "kill", etc.)
EXPORT void telemetry_record(const char* event_name, int value) {
    if (!event_name || *event_name == '\0') {
        std::cerr << "[Telemetry] Invalid event name." << std::endl;
        return;
    }
    g_telemetry.RecordEvent(std::string(event_name), value);
}

// Get the current counter for a telemetry event
EXPORT int telemetry_get_count(const char* event_name) {
    if (!event_name || *event_name == '\0') return 0;
    return g_telemetry.GetEventCount(std::string(event_name));
}

// Reset telemetry state (for debugging or new runs)
EXPORT void telemetry_reset() {
    g_telemetry.Reset();
}

} // extern "C"
