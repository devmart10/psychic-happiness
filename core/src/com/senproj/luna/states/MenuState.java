package com.senproj.luna.states;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.senproj.luna.gui.GuiButton;
import com.senproj.luna.gui.GuiButtonConstants;
import com.senproj.luna.gui.GuiButtonFactory;
import com.senproj.luna.helpers.Settings;
import com.senproj.luna.render.RenderableTexture;

import java.util.ArrayList;

public class MenuState extends GameState {
    private RenderableTexture background;
    private ArrayList<GuiButton> buttons;

    public MenuState(GameStateManager gsm) {
        super(gsm);
        background = new RenderableTexture(0, 0, "menu/background/temp_mainmenu.png");
        buttons = new ArrayList<>();
        buttons.add(GuiButtonFactory.createButton(GuiButtonConstants.NEW_GAME_BUTTON));
        buttons.add(GuiButtonFactory.createButton(GuiButtonConstants.EXIT_GAME_BUTTON));
    }

    @Override
    public void update(float dt) {
        handleInput();
    }

    @Override
    public void render() {
        background.render();
        for (GuiButton button : buttons) {
            button.render();
        }
    }

    @Override
    public void handleInput() {
        if (Gdx.input.justTouched()) {
            int mouseX = Gdx.input.getX(), mouseY = Settings.SCREEN_HEIGHT - Gdx.input.getY();
            for (GuiButton button : buttons) {
                if (button.isClicked(mouseX, mouseY)) {
                    switch (button.getTag()) {
                        case NEW_GAME_BUTTON:
                            gsm.setState(new PlayState(gsm));
                            return;
                        case EXIT_GAME_BUTTON:
                            Gdx.app.exit();
                            return;
                        default:
                            return;
                    }
                }
            }
        }
    }

    @Override
    public void dispose() {
        background.dispose();
        for (GuiButton button : buttons) {
            button.dispose();
        }
    }
}
