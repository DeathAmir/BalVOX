#include <algorithm>
#include <cmath>

#if defined(_WIN32)
#define BV_EXPORT extern "C" __declspec(dllexport)
#else
#define BV_EXPORT extern "C" __attribute__((visibility("default")))
#endif

BV_EXPORT double balvox_drag_factor(double speed, double density, double area, double coefficient, double mass) {
    if (!std::isfinite(speed) || !std::isfinite(density) || !std::isfinite(area) ||
        !std::isfinite(coefficient) || !std::isfinite(mass) || mass <= 0.0) return 0.0;
    const double drag = 0.5 * std::max(0.0, density) * std::max(0.0, area) *
                        std::max(0.0, coefficient) * speed * std::abs(speed);
    return std::clamp(drag / mass, -100000.0, 100000.0);
}

BV_EXPORT int balvox_native_version() { return 2; }
