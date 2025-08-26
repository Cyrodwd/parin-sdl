module examples.keyboard;
import joka;
import xparin;

bool start()
{
    println("Keyboard test");
    return true;
}

bool update()
{
    if (IsDown(Scancode.space)) println("You are pressing space!");
    if (IsPressed(Scancode.z)) println("You pressed Z");
    if (IsReleased(Scancode.z)) println("You released Z");

    return true;
}

void draw() { }

void finish()
{
    println("bye bye keyboard");
}

mixin RunGame!(start, update, draw, finish);