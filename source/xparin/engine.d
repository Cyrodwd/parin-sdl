/***
 * The code is similar to Parin lol
 * Is basically a ‘port’.
 * Also, dyaml will be used later
***/

module xparin.engine;

import joka;
import bindbc.sdl;

private:

alias defaultWinpos = SDL_WINDOWPOS_CENTERED;

struct EngineState
{
    Color   backgroundColor;
    // IStr    assetsPath;

    SDL_Event       event;
    SDL_Window*     window = null;
    SDL_Renderer*   renderer = null;

    /* Delta time */
    bool            loop;
    long            lastTick, currentTick;
    float           deltaTime;

    /* Keyboard */
    ubyte[SDL_NUM_SCANCODES] currentKeyboardState;
    ubyte[SDL_NUM_SCANCODES] lastKeyboardState;
}

/// Engine instance
EngineState gEngineState = {};

void _UpdateKeyboard()
{
    const ubyte* keyboardState = SDL_GetKeyboardState(null);

    jokaMemcpy(&gEngineState.lastKeyboardState, &gEngineState.currentKeyboardState, SDL_NUM_SCANCODES);
    jokaMemcpy(&gEngineState.currentKeyboardState, keyboardState, SDL_NUM_SCANCODES);
}

/* Window */

bool _OpenWindow(int w, int h, ICStr title) {
    bool result = false;

    // Basic window creation
    const int windowFlags = SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE;
    gEngineState.window = SDL_CreateWindow(title, defaultWinpos, defaultWinpos, w, h, windowFlags);

    if (gEngineState.window is null)
    {
        printfln("Error has ocurred creating window: {}", SDL_GetError());
        return result;
    }

    // Creating renderer :)
    const int rendererFlags = SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC;
    gEngineState.renderer = SDL_CreateRenderer(gEngineState.window, -1, rendererFlags);

    if (gEngineState.renderer is null) {
        printfln("Error has ocurred creating renderer: {}", SDL_GetError());
        return result;
    }

    gEngineState.backgroundColor = black;
    gEngineState.lastTick = 0;
    gEngineState.currentTick = 0;
    gEngineState.deltaTime = 0.0f;
    // gEngineState.assetsPath = toStr("assets/");
    gEngineState.loop = true;
    result = true;

    return result;
}

void _PollEngineEvents()
{
    // Maybe one of the largest switch expression that I'll write
    switch (gEngineState.event.type)
    {
        case SDL_QUIT:
            gEngineState.loop = false;
            break;
        default:
            break;
    }
}

/// Updates & Draw the window/renderer. Basically we depend on updateFunction to stop or not
bool _UpdateWindow(bool function() updateFunction, void function() renderFunction) {
    // Update application events (important)
    while(SDL_PollEvent(&gEngineState.event))
        _PollEngineEvents();

    _UpdateKeyboard();

    // Update delta time
    gEngineState.lastTick = gEngineState.currentTick;
    gEngineState.currentTick = SDL_GetPerformanceCounter();
    gEngineState.deltaTime = (gEngineState.currentTick - gEngineState.lastTick) / cast(float) SDL_GetPerformanceFrequency();

    // Update function
    auto result = updateFunction();

    // Clear Background
    ref Color clsColor = gEngineState.backgroundColor;
    SDL_SetRenderDrawColor(gEngineState.renderer, clsColor.r, clsColor.g, clsColor.b, clsColor.a);
    SDL_RenderClear(gEngineState.renderer);

    // Call Draw function
    renderFunction();

    // Display
    SDL_RenderPresent(gEngineState.renderer);
    return result;
}

void _CloseWindow() {
    if (gEngineState.renderer !is null) {
        SDL_DestroyRenderer(gEngineState.renderer);
        gEngineState.renderer = null;
    }

    if (gEngineState.window !is null) {
        SDL_DestroyWindow(gEngineState.window);
        gEngineState.window = null;
    }
}

/* Public functions for mixin template RunGame. */

/// Do not call this manually .. unless you want to use your OWN main function
public:

/* Keyboard */

enum Scancode : ushort
{
    none = SDL_SCANCODE_UNKNOWN,
    apostrophe = SDL_SCANCODE_APOSTROPHE,
    comma = SDL_SCANCODE_COMMA,
    minus = SDL_SCANCODE_MINUS,
    period = SDL_SCANCODE_PERIOD,
    slash = SDL_SCANCODE_SLASH,
    n0 = SDL_SCANCODE_0,
    n1 = SDL_SCANCODE_1,
    n2 = SDL_SCANCODE_2,
    n3 = SDL_SCANCODE_3,
    n4 = SDL_SCANCODE_4,
    n5 = SDL_SCANCODE_5,
    n6 = SDL_SCANCODE_6,
    n7 = SDL_SCANCODE_7,
    n8 = SDL_SCANCODE_8,
    n9 = SDL_SCANCODE_9,
    kp0 = SDL_SCANCODE_KP_0,
    kp1 = SDL_SCANCODE_KP_1,
    kp2 = SDL_SCANCODE_KP_2,
    kp3 = SDL_SCANCODE_KP_3,
    kp4 = SDL_SCANCODE_KP_4,
    kp5 = SDL_SCANCODE_KP_5,
    kp6 = SDL_SCANCODE_KP_6,
    kp7 = SDL_SCANCODE_KP_7,
    kp8 = SDL_SCANCODE_KP_8,
    kp9 = SDL_SCANCODE_KP_9,
    semicolon = SDL_SCANCODE_SEMICOLON,
    equal = SDL_SCANCODE_EQUALS,
    // Alphabet keys lol
    a = SDL_SCANCODE_A,
    b = SDL_SCANCODE_B,
    c = SDL_SCANCODE_C,
    d = SDL_SCANCODE_D,
    e = SDL_SCANCODE_E,
    f = SDL_SCANCODE_F,
    g = SDL_SCANCODE_G,
    h = SDL_SCANCODE_H,
    i = SDL_SCANCODE_I,
    j = SDL_SCANCODE_J,
    k = SDL_SCANCODE_K,
    l = SDL_SCANCODE_L,
    m = SDL_SCANCODE_M,
    n = SDL_SCANCODE_N,
    o = SDL_SCANCODE_O,
    p = SDL_SCANCODE_P,
    q = SDL_SCANCODE_Q,
    r = SDL_SCANCODE_R,
    s = SDL_SCANCODE_S,
    t = SDL_SCANCODE_T,
    u = SDL_SCANCODE_U,
    v = SDL_SCANCODE_V,
    w = SDL_SCANCODE_W,
    x = SDL_SCANCODE_X,
    y = SDL_SCANCODE_Y,
    z = SDL_SCANCODE_Z,
    /* special */
    bracketLeft = SDL_SCANCODE_LEFTBRACKET,
    bracketRight = SDL_SCANCODE_RIGHTBRACKET,
    backslash = SDL_SCANCODE_BACKSLASH,
    grave = SDL_SCANCODE_GRAVE,
    space = SDL_SCANCODE_SPACE,
    escape = SDL_SCANCODE_ESCAPE,
    tab = SDL_SCANCODE_TAB,
    backspace = SDL_SCANCODE_BACKSPACE,
    insert = SDL_SCANCODE_INSERT,
    del = SDL_SCANCODE_DELETE,
    right = SDL_SCANCODE_RIGHT,
    left = SDL_SCANCODE_LEFT,
    down = SDL_SCANCODE_DOWN,
    up = SDL_SCANCODE_UP,
    pageUp = SDL_SCANCODE_PAGEUP,
    pageDown = SDL_SCANCODE_PAGEDOWN,
    home = SDL_SCANCODE_HOME,
    end = SDL_SCANCODE_END,
    capsLock = SDL_SCANCODE_CAPSLOCK,
    scrollLock = SDL_SCANCODE_SCROLLLOCK,
    numLock = SDL_SCANCODE_NUMLOCKCLEAR,
    printScreen = SDL_SCANCODE_PRINTSCREEN,
    pause = SDL_SCANCODE_PAUSE,
    shift = SDL_SCANCODE_LSHIFT,
    shiftRight = SDL_SCANCODE_RSHIFT,
    ctrl = SDL_SCANCODE_LCTRL,
    ctrlRight = SDL_SCANCODE_RCTRL,
    alt = SDL_SCANCODE_LALT,
    altRight = SDL_SCANCODE_RALT,
    superKey = SDL_SCANCODE_LGUI, // Left GUI - Super/Windows key
    superKeyRight = SDL_SCANCODE_RGUI, // Right GUI interesting
    menu = SDL_SCANCODE_MENU,
    f1 = SDL_SCANCODE_F1,
    f2 = SDL_SCANCODE_F2,
    f3 = SDL_SCANCODE_F3,
    f4 = SDL_SCANCODE_F4,
    f5 = SDL_SCANCODE_F5,
    f6 = SDL_SCANCODE_F6,
    f7 = SDL_SCANCODE_F7,
    f8 = SDL_SCANCODE_F8,
    f9 = SDL_SCANCODE_F9,
    f10 = SDL_SCANCODE_F10,
    f11 = SDL_SCANCODE_F11,
    f12 = SDL_SCANCODE_F12,
}

// More-parin
alias Keyboard = Scancode;

bool IsDown(in Scancode scancode)
{
    return gEngineState.currentKeyboardState[scancode] != 0;
}

bool IsPressed(in Scancode scancode)
{
    return gEngineState.lastKeyboardState[scancode] == 0
        && gEngineState.currentKeyboardState[scancode] != 0;
}

bool IsReleased(in Scancode scancode)
{
    return gEngineState.lastKeyboardState[scancode] != 0
        && gEngineState.currentKeyboardState[scancode] == 0;
}

/* Time */

float GetDeltaTime()
{
    return gEngineState.deltaTime;
}

/* Game */

byte InitGame(bool function() startFunc)
{
    if (SDL_Init(SDL_INIT_VIDEO) < 0)
    {
        printfln("An error has ocurred initializing SDL: {}", SDL_GetError());
        return -1;
    }

    if (!_OpenWindow(800, 600, "RunGame"))
    {
        printfln("An error has ocurred creating the window and renderer: {}", SDL_GetError());
        return -1;
    }

    if (!startFunc())
    {
        printfln("An error has ocurred initializing game");
        return -1;
    }
    
    return 0;
}

/// Do not call this manually. Unless you want to use your OWN main function
/// Mixes in a game loop template all the functions you include
void UpdateGame(bool function() updateFunction, void function() renderFunction) {
    while (true)
        if (!gEngineState.loop || !_UpdateWindow(updateFunction, renderFunction)) break;
}

/// Don't call this manually. Unless you want to use your OWN main function.
/// It releases the resources of the engine
void QuitGame(void function() quitFunction)
{
    quitFunction();

    // Clean Keyboard?
    gEngineState.currentKeyboardState = null;
    gEngineState.lastKeyboardState = null;

    _CloseWindow();
    SDL_Quit();
}

/// Initializes, updates and finish the game
mixin template RunGame(alias startFunc, alias updateFunc, alias renderFunc, alias quitFunc)
{
    // Desktop main
    int main()
    {
        if (InitGame(&startFunc) < 0) return 1;
        scope (exit) QuitGame(&quitFunc);

        UpdateGame(&updateFunc, &renderFunc);
        return 0;
    }
}
