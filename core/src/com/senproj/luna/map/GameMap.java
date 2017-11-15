package com.senproj.luna.map;

import com.senproj.luna.map.blocks.Block;
import com.senproj.luna.map.blocks.BlockType;
import com.senproj.luna.map.factories.BlockFactory;
import com.senproj.luna.render.Renderable;

public class GameMap {
    private Block[][] world;

    public GameMap() {
        world = generateNewMap(120, 68);
    }

    public Block[][] generateNewMap(int width, int height) {
        int skyHeight = 2;
        Block[][] retWorld = new Block[width][height];

        for (int i = 0; i < width; i++) {
            for (int j = 0; j < height; j++) {
                // temp code to fill sky
                if (j > skyHeight) {
                    retWorld[i][j] = BlockFactory.createBlock(i, j, BlockType.SKY);
                } else { // fill with ground
                    retWorld[i][j] = BlockFactory.createBlock(i, j, BlockType.DIRT);
                }
            }
        }

        return retWorld;
    }

    public void dispose() {

    }

    public void render() {
        for (int i = 0; i < world.length; i++) {
            for (int j = 0; j < world[i].length; j++) {
                if (world[i][j] instanceof Renderable) {
                    ((Renderable)world[i][j]).render();
                }
            }
        }
    }

    public Block[][] getWorld() {
        return world;
    }
}
