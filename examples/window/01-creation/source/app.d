import xparin;
import joka;

void start()
{
	println("Hello from parin-sdl");
}

bool update()
{
	println("Updating parin-sdl");
	return true;
}

void draw()
{
	println("Drawing parin-sdl!");
}

void finish()
{
	println("Bye bye parin-sdl!");
}

mixin RunGame!(start, update, draw, finish);