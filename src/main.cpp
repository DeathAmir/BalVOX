#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <Windows.h>
#include "WickedEngine.h"

class BalVOXPath final : public wi::RenderPath3D
{
public:
    wi::scene::TransformComponent cameraTransform;

    void InitializeScene()
    {
        cameraTransform.Translate(XMFLOAT3(0.0f, 28.0f, -58.0f));
        cameraTransform.RotateRollPitchYaw(XMFLOAT3(0.34f, 0.0f, 0.0f));
        cameraTransform.UpdateTransform();
        wi::scene::GetCamera().TransformCamera(cameraTransform);

        setAO(AO_SSAO);
        setAORange(2.0f);
        setAOSampleCount(24);
        setSSREnabled(true);
        setBloomEnabled(true);
        setShadowsEnabled(true);
        setReflectionsEnabled(true);
        setColorGradingEnabled(true);
        setFXAAEnabled(false);
        setDepthOfFieldEnabled(false);
        setSharpenFilterEnabled(true);
        setSharpenFilterAmount(0.22f);
        wi::renderer::SetTemporalAAEnabled(true);

        wi::scene::LoadModel("Content/terrain/grass.wiscene");
    }

    void Update(float dt) override
    {
        wi::RenderPath3D::Update(dt);

        const float speed = wi::input::Down(wi::input::KEYBOARD_BUTTON_LSHIFT) ? 42.0f : 18.0f;
        const float step = speed * dt;

        if (wi::input::Down((wi::input::BUTTON)'W')) cameraTransform.Translate(XMFLOAT3(0, 0, step));
        if (wi::input::Down((wi::input::BUTTON)'S')) cameraTransform.Translate(XMFLOAT3(0, 0, -step));
        if (wi::input::Down((wi::input::BUTTON)'A')) cameraTransform.Translate(XMFLOAT3(-step, 0, 0));
        if (wi::input::Down((wi::input::BUTTON)'D')) cameraTransform.Translate(XMFLOAT3(step, 0, 0));
        if (wi::input::Down(wi::input::KEYBOARD_BUTTON_SPACE)) cameraTransform.Translate(XMFLOAT3(0, step, 0));
        if (wi::input::Down(wi::input::KEYBOARD_BUTTON_LCONTROL)) cameraTransform.Translate(XMFLOAT3(0, -step, 0));

        const float turn = 1.15f * dt;
        if (wi::input::Down(wi::input::KEYBOARD_BUTTON_LEFT)) cameraTransform.RotateRollPitchYaw(XMFLOAT3(0, turn, 0));
        if (wi::input::Down(wi::input::KEYBOARD_BUTTON_RIGHT)) cameraTransform.RotateRollPitchYaw(XMFLOAT3(0, -turn, 0));
        if (wi::input::Down(wi::input::KEYBOARD_BUTTON_UP)) cameraTransform.RotateRollPitchYaw(XMFLOAT3(turn, 0, 0));
        if (wi::input::Down(wi::input::KEYBOARD_BUTTON_DOWN)) cameraTransform.RotateRollPitchYaw(XMFLOAT3(-turn, 0, 0));

        cameraTransform.UpdateTransform();
        wi::scene::GetCamera().TransformCamera(cameraTransform);
    }
};

static wi::Application application;
static BalVOXPath gamePath;

int APIENTRY wWinMain(HINSTANCE instance, HINSTANCE, LPWSTR commandLine, int showCommand)
{
    static auto windowProcedure = [](HWND window, UINT message, WPARAM wParam, LPARAM lParam) -> LRESULT
    {
        switch (message)
        {
        case WM_SIZE:
        case WM_DPICHANGED:
            if (application.is_window_active)
                application.SetWindow(window);
            break;
        case WM_INPUT:
            wi::input::rawinput::ParseMessage(reinterpret_cast<void*>(lParam));
            break;
        case WM_KILLFOCUS:
            application.is_window_active = false;
            break;
        case WM_SETFOCUS:
            application.is_window_active = true;
            break;
        case WM_DESTROY:
            PostQuitMessage(0);
            break;
        default:
            return DefWindowProcW(window, message, wParam, lParam);
        }
        return 0;
    };

    SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);

    WNDCLASSEXW windowClass{};
    windowClass.cbSize = sizeof(windowClass);
    windowClass.style = CS_HREDRAW | CS_VREDRAW;
    windowClass.lpfnWndProc = windowProcedure;
    windowClass.hInstance = instance;
    windowClass.hCursor = LoadCursorW(nullptr, IDC_ARROW);
    windowClass.lpszClassName = L"BalVOX.WickedEngine.Window";
    RegisterClassExW(&windowClass);

    HWND window = CreateWindowExW(
        0,
        windowClass.lpszClassName,
        L"BalVOX | Wicked Engine Sandbox",
        WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT,
        CW_USEDEFAULT,
        1600,
        900,
        nullptr,
        nullptr,
        instance,
        nullptr
    );

    if (!window)
        return 1;

    ShowWindow(window, showCommand);
    application.SetWindow(window);
    wi::arguments::Parse(commandLine);
    application.infoDisplay.active = true;
    application.infoDisplay.watermark = false;
    application.infoDisplay.resolution = true;
    application.infoDisplay.fpsinfo = true;

    application.Initialize();
    gamePath.InitializeScene();
    application.ActivatePath(&gamePath);

    MSG message{};
    while (message.message != WM_QUIT)
    {
        if (PeekMessageW(&message, nullptr, 0, 0, PM_REMOVE))
        {
            TranslateMessage(&message);
            DispatchMessageW(&message);
        }
        else
        {
            application.Run();
        }
    }

    wi::jobsystem::ShutDown();
    return static_cast<int>(message.wParam);
}
