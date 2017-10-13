package com.senproj.luna.gui;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.math.Vector2;

/**
 * A class to hold data representing a button on the GUI.
 */
public class GuiButton {
    private GuiButtonConstants tag;
    private Texture tex;
    Vector2 bottomLeft;
    Vector2 topRight;

    public GuiButton() {
        Gdx.app.debug("GUI", String.format("Warning: GUI button default constructor used"));
    }

    /**
     * A standard GUI button
     * @param posX the x-coordinate of the center of the button
     * @param posY the y-coordinate of the center of the button
     * @param tag the enum of the button (set in GuiButtonConstants.java)
     * @param tex the texture to display for the button
     */
    public GuiButton(int posX, int posY, GuiButtonConstants tag, Texture tex) {
        this.tex = tex;
        this.tag = tag;
        bottomLeft = new Vector2(posX - tex.getWidth() / 2.0f, posY - tex.getHeight() / 2.0f);
        topRight = new Vector2(posX + tex.getWidth() / 2.0f, posY + tex.getHeight() / 2.0f);
    }

    public boolean isClicked(int mouseX, int mouseY) {
        return mouseX >= bottomLeft.x && mouseX <= topRight.x && mouseY > bottomLeft.y && mouseY < topRight.y;
    }

    public void draw(SpriteBatch batch) {
        batch.draw(tex, bottomLeft.x, bottomLeft.y);
    }

    public GuiButtonConstants getTag() {
        return tag;
    }

    public void dispose() {
        tex.dispose();
    }
}
