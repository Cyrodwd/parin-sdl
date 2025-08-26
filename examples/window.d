module examples.window;
import joka;
import xparin;

bool start() {
    println("Hello Parin");
    return true;
}

bool update() {
    println("Update parin");
    return true;
}

void draw() {}

void finish() {
    println("Bye parin");
}

mixin RunGame!(start, update, draw, finish);