module examples.texture;

import joka;
import xparin;

Texture myTexture;

bool Init()
{
    myTexture = loadTexture("res/simple.png");
    return true;
}

bool Update()
{
    if (!myTexture.isEmpty()) println("Update texture");
    return true;
}

void Draw()
{
    drawTexture(myTexture, GRect!int(0, 0, myTexture.width, myTexture.height), Vec2.zero);
}

void Finish()
{
    myTexture.free();
    println("Texture freed successfully");
}

mixin RunGame!(Init, Update, Draw, Finish);