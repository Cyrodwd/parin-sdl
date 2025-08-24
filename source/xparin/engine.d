/***
 * The code is similar to Parin lol
 * Is basically a ‘port’.
 * Also, dyaml will be used later
***/

module xparin.engine;

import joka;
import bindbc.sdl;

private alias defaultWinpos = SDL_WINDOWPOS_CENTERED;

private struct EngineState
{
    Color   backgroundColor;
    // IStr    assetsPath;

    SDL_Event       event;
    SDL_Window*     window = null;
    SDL_Renderer*   renderer = null;

    bool            loop;
    long            lastTick, currentTick;
    float           deltaTime;
}

private EngineState gEngineState = {};

private bool OpenWindow(int w, int h, ICStr title) {
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

private void PollEngineEvents()
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
private bool UpdateWindow(bool function() updateFunction, void function() renderFunction) {
    // Update application events (important)
    while(SDL_PollEvent(&gEngineState.event))
        PollEngineEvents();

    // Update delta time
    gEngineState.lastTick = gEngineState.currentTick;
    gEngineState.currentTick = SDL_GetPerformanceCounter();
    gEngineState.deltaTime = (gEngineState.lastTick - gEngineState.currentTick) / SDL_GetPerformanceFrequency();

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

private void CloseWindow() {
    if (gEngineState.renderer !is null) {
        SDL_DestroyRenderer(gEngineState.renderer);
        gEngineState.renderer = null;
    }

    if (gEngineState.window !is null) {
        SDL_DestroyWindow(gEngineState.window);
        gEngineState.window = null;
    }
}

// Public functions for mixin template RunGame.

/// Do not call this manually .. unless you want to use your OWN main function
public byte InitGame()
{
    if (SDL_Init(SDL_INIT_VIDEO) < 0)
    {
        printfln("An error has ocurred initializing SDL: {}", SDL_GetError());
        return -1;
    }

    if (!OpenWindow(800, 600, "RunGame"))
    {
        printfln("An error has ocurred creating the window and renderer: {}", SDL_GetError());
        return -1;
    }
    
    return 0;
}

/// Do not call this manually. Unless you want to use your OWN main function
/// Mixes in a game loop template all the functions you include
public void UpdateGame(void function() startFunction, bool function() updateFunction,
    void function() renderFunction, void function() quitFunction) {
    startFunction();

    while (true)
        if (!gEngineState.loop || !UpdateWindow(updateFunction, renderFunction)) break;
    
    quitFunction();
}

/// Don't call this manually. Unless you want to use your OWN main function.
/// It releases the resources of the engine
public void QuitGame()
{
    CloseWindow();
    SDL_Quit();
}

/// Initializes, updates and finish the game
mixin template RunGame(alias startFunc, alias updateFunc, alias renderFunc, alias quitFunc)
{
    // Desktop main
    int main()
    {
        if (InitGame() < 0) return 1;

        UpdateGame(&startFunc, &updateFunc, &renderFunc, &quitFunc);

        QuitGame();
        return 0;
    }
}